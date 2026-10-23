--!strict

local Players = game:GetService("Players")

export type QueuedPlayer = {
	player: Player,
	joinedAt: number,
	rating: number,
}

export type Queue = {
	mode: string,
	players: { QueuedPlayer },
}

local QueueService = {}

local queues: { [string]: Queue } = {}

function QueueService.getQueue(mode: string): Queue
	if not queues[mode] then
		queues[mode] = { mode = mode, players = {} }
	end
	return queues[mode]
end

function QueueService.enqueue(mode: string, player: Player, rating: number?): boolean
	local q = QueueService.getQueue(mode)
	for _, qp in q.players do
		if qp.player == player then
			return false
		end
	end
	table.insert(q.players, {
		player = player,
		joinedAt = os.clock(),
		rating = rating or 1000,
	})
	return true
end

function QueueService.dequeue(mode: string, player: Player): boolean
	local q = QueueService.getQueue(mode)
	for i, qp in ipairs(q.players) do
		if qp.player == player then
			table.remove(q.players, i)
			return true
		end
	end
	return false
end

function QueueService.removeFromAll(player: Player)
	for mode, q in queues do
		QueueService.dequeue(mode, player)
	end
end

function QueueService.tryFormMatch(mode: string, minPlayers: number): { QueuedPlayer }?
	local q = QueueService.getQueue(mode)
	if #q.players < minPlayers then
		return nil
	end
	local match: { QueuedPlayer } = {}
	for i = 1, minPlayers do
		table.insert(match, table.remove(q.players, 1) :: QueuedPlayer)
	end
	return match
end

function QueueService.getQueueSize(mode: string): number
	return #QueueService.getQueue(mode).players
end

function QueueService.cleanupDisconnected()
	for mode, q in queues do
		for i = #q.players, 1, -1 do
			if not q.players[i].player.Parent then
				table.remove(q.players, i)
			end
		end
	end
end

return QueueService
