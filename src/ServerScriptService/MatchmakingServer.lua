--!strict

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TeleportService = game:GetService("TeleportService")

local MatchConfig = require(ReplicatedStorage:WaitForChild("Modules"):WaitForChild("MatchConfig"))
local QueueService = require(ReplicatedStorage:WaitForChild("Modules"):WaitForChild("QueueService"))

local Remotes = ReplicatedStorage:WaitForChild("Remotes")
local function getRemote(name: string, className: string): Instance
	local r = Remotes:FindFirstChild(name)
	if not r then
		r = Instance.new(className)
		r.Name = name
		r.Parent = Remotes
	end
	return r
end
local JoinQueue = getRemote("JoinQueue", "RemoteEvent") :: RemoteEvent
local LeaveQueue = getRemote("LeaveQueue", "RemoteEvent") :: RemoteEvent
local QueueUpdate = getRemote("QueueUpdate", "RemoteEvent") :: RemoteEvent
local MatchFound = getRemote("MatchFound", "RemoteEvent") :: RemoteEvent
local MatchUpdate = getRemote("MatchUpdate", "RemoteEvent") :: RemoteEvent

type MatchState = "Idle" | "Queued" | "Countdown" | "InMatch" | "Results"
local playerState: { [number]: MatchState } = {}
local playerMode: { [number]: string } = {}
local activeMatches: { [string]: { players: { Player }, startedAt: number, kills: { [number]: number } } } = {}

local function setState(player: Player, state: MatchState)
	playerState[player.UserId] = state
end

local function broadcastQueue(mode: string)
	local qSize = QueueService.getQueueSize(mode)
	local cfg = MatchConfig.Modes[mode]
	local minPlayers = MatchConfig.DEMO_MODE and 1 or cfg.MinPlayers
	local needed = minPlayers - qSize
	for _, qp in QueueService.getQueue(mode).players do
		QueueUpdate:FireClient(qp.player, {
			mode = mode,
			queueSize = qSize,
			needed = math.max(0, needed),
			minPlayers = cfg.MinPlayers,
		})
	end
end

local function runMatch(matchId: string, players: { Player }, mode: string)
	local cfg = MatchConfig.Modes[mode]
	local spawns = { workspace:FindFirstChild("Spawn1"), workspace:FindFirstChild("Spawn2") }

	for i, p in players do
		local char = p.Character or p.CharacterAdded:Wait()
		local hrp = char:WaitForChild("HumanoidRootPart")
		if spawns[i] then
			hrp.CFrame = spawns[i].CFrame + Vector3.new(0, 3, 0)
		end
	end

	for t = MatchConfig.CountdownDuration, 1, -1 do
		for _, p in players do
			MatchUpdate:FireClient(p, { type = "Countdown", value = t })
		end
		task.wait(1)
	end
	for _, p in players do
		MatchUpdate:FireClient(p, { type = "Start" })
	end

	local match = activeMatches[matchId]
	local matchEnded = false
	local connections: { RBXScriptConnection } = {}

	local function endMatch(winner: Player?)
		if matchEnded then return end
		matchEnded = true
		for _, c in connections do
			pcall(function() c:Disconnect() end)
		end
		for _, p in players do
			MatchUpdate:FireClient(p, {
				type = "End",
				winner = winner and winner.Name or "Draw",
				kills = match.kills,
			})
		end
		task.wait(MatchConfig.ResultsDuration)
		for _, p in players do
			setState(p, "Idle")
			local spawnPart = workspace:FindFirstChild("SpawnLocation")
			local target = spawnPart and spawnPart.Position or Vector3.new(0, 5, 0)
			local char = p.Character
			if char then
				local hrp = char:FindFirstChild("HumanoidRootPart")
				if hrp then hrp.CFrame = CFrame.new(target + Vector3.new(0, 3, 0)) end
			end
		end
		activeMatches[matchId] = nil
	end

	for i, p in players do
		local function onDeath()
			if matchEnded then return end
			local opponent = players[i == 1 and 2 or 1]
			match.kills[opponent.UserId] = (match.kills[opponent.UserId] or 0) + 1
			for _, pl in players do
				MatchUpdate:FireClient(pl, {
					type = "Kill",
					killer = opponent.Name,
					kills = match.kills,
				})
			end
			if match.kills[opponent.UserId] >= (cfg.WinKills or 5) then
				endMatch(opponent)
				return
			end
			task.delay(2, function()
				if matchEnded then return end
				local char = p.Character or p.CharacterAdded:Wait()
				local hrp = char:WaitForChild("HumanoidRootPart")
				if spawns[i] then
					hrp.CFrame = spawns[i].CFrame + Vector3.new(0, 3, 0)
				end
			end)
		end

		local function hookCharacter(char: Model)
			local hum = char:WaitForChild("Humanoid")
			table.insert(connections, hum.Died:Connect(onDeath))
		end
		if p.Character then hookCharacter(p.Character) end
		table.insert(connections, p.CharacterAdded:Connect(hookCharacter))
	end

	task.delay(cfg.MatchDuration, function()
		if not matchEnded then
			local k1 = match.kills[players[1].UserId] or 0
			local k2 = match.kills[players[2].UserId] or 0
			local winner = nil
			if k1 > k2 then winner = players[1]
			elseif k2 > k1 then winner = players[2] end
			endMatch(winner)
		end
	end)
end

local function startMatch(players: { Player }, mode: string)
	local cfg = MatchConfig.Modes[mode]
	local matchId = tostring(os.clock()) .. "_" .. mode

	if MatchConfig.USE_RESERVED_SERVERS and MatchConfig.MatchPlaceId > 0 then
		local ok, code = pcall(function()
			return TeleportService:ReserveServer(MatchConfig.MatchPlaceId)
		end)
		if not ok or not code then
			warn("ReserveServer failed, falling back to in-place")
		else
			for t = 5, 1, -1 do
				for _, p in players do
					MatchUpdate:FireClient(p, { type = "Countdown", value = t })
				end
				task.wait(1)
			end
			local teleportData = { matchId = matchId, mode = mode }
			local options = Instance.new("TeleportOptions")
			options.ReservedServerAccessCode = code
			options:SetTeleportData(teleportData)
			for _, p in players do
				pcall(function()
					TeleportService:TeleportToPrivateServer(MatchConfig.MatchPlaceId, code, { p }, nil, teleportData)
				end)
			end
			return
		end
	end

	activeMatches[matchId] = { players = players, startedAt = os.clock(), kills = {} }
	for i, p in players do
		activeMatches[matchId].kills[p.UserId] = 0
		setState(p, "InMatch")
		MatchFound:FireClient(p, { matchId = matchId, mode = mode, demo = true, team = i })
	end
	task.spawn(function()
		runMatch(matchId, players, mode)
	end)
end

JoinQueue.OnServerEvent:Connect(function(player: Player, mode: unknown)
	if typeof(mode) ~= "string" or not MatchConfig.Modes[mode] then
		return
	end
	if playerState[player.UserId] and playerState[player.UserId] ~= "Idle" then
		return
	end
	local rating = 1000
	local ok = QueueService.enqueue(mode, player, rating)
	if not ok then
		return
	end
	playerMode[player.UserId] = mode
	setState(player, "Queued")
	QueueUpdate:FireClient(player, {
		mode = mode,
		queueSize = QueueService.getQueueSize(mode),
		needed = (MatchConfig.DEMO_MODE and 1 or MatchConfig.Modes[mode].MinPlayers) - QueueService.getQueueSize(mode),
		minPlayers = MatchConfig.DEMO_MODE and 1 or MatchConfig.Modes[mode].MinPlayers,
	})
end)

LeaveQueue.OnServerEvent:Connect(function(player: Player)
	local mode = playerMode[player.UserId]
	if mode then
		QueueService.dequeue(mode, player)
	end
	playerMode[player.UserId] = nil
	setState(player, "Idle")
	QueueUpdate:FireClient(player, { mode = mode, left = true })
end)

task.spawn(function()
	while true do
		task.wait(1)
		QueueService.cleanupDisconnected()
		for mode, cfg in MatchConfig.Modes do
			local minPlayers = MatchConfig.DEMO_MODE and 1 or cfg.MinPlayers
			local matchPlayers = QueueService.tryFormMatch(mode, minPlayers)
			if matchPlayers then
				local players: { Player } = {}
				for _, qp in matchPlayers do
					table.insert(players, qp.player)
				end
				startMatch(players, mode)
			else
				broadcastQueue(mode)
			end
		end
	end
end)

local defaultSpawn = workspace:FindFirstChild("SpawnLocation")
Players.PlayerAdded:Connect(function(player: Player)
	if defaultSpawn and defaultSpawn:IsA("SpawnLocation") then
		player.RespawnLocation = defaultSpawn
	end
end)
for _, p in Players:GetPlayers() do
	if defaultSpawn and defaultSpawn:IsA("SpawnLocation") then
		p.RespawnLocation = defaultSpawn
	end
end

Players.PlayerRemoving:Connect(function(player: Player)
	QueueService.removeFromAll(player)
	playerState[player.UserId] = nil
	playerMode[player.UserId] = nil
end)
