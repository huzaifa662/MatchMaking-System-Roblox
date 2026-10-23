--!strict

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local player = Players.LocalPlayer
local Remotes = ReplicatedStorage:WaitForChild("Remotes")
local JoinQueue = Remotes:WaitForChild("JoinQueue") :: RemoteEvent
local LeaveQueue = Remotes:WaitForChild("LeaveQueue") :: RemoteEvent
local QueueUpdate = Remotes:WaitForChild("QueueUpdate") :: RemoteEvent
local MatchFound = Remotes:WaitForChild("MatchFound") :: RemoteEvent
local MatchUpdate = Remotes:WaitForChild("MatchUpdate") :: RemoteEvent

local gui = player:WaitForChild("PlayerGui"):WaitForChild("MatchmakingGui")
local modeFrame = gui:WaitForChild("ModeFrame")
local queueFrame = gui:WaitForChild("QueueFrame")
local statusLabel = queueFrame:WaitForChild("StatusLabel") :: TextLabel
local countdownLabel = queueFrame:FindFirstChild("CountdownLabel") :: TextLabel?
local playBtn = modeFrame:WaitForChild("PlayButton") :: TextButton
local cancelBtn = queueFrame:WaitForChild("CancelButton") :: TextButton

local currentMode = "1v1"

playBtn.MouseButton1Click:Connect(function()
	modeFrame.Visible = false
	queueFrame.Visible = true
	statusLabel.Visible = true
	statusLabel.Text = "Joining queue..."
	JoinQueue:FireServer(currentMode)
end)

cancelBtn.MouseButton1Click:Connect(function()
	LeaveQueue:FireServer()
	queueFrame.Visible = false
	modeFrame.Visible = true
	statusLabel.Text = "Cancelled"
end)

QueueUpdate.OnClientEvent:Connect(function(data)
	if data.left then
		return
	end
	statusLabel.Visible = true
	statusLabel.Text = string.format("Searching... %d/%d (need %d more)", data.queueSize, data.minPlayers, data.needed)
end)

MatchFound.OnClientEvent:Connect(function(data)
	statusLabel.Text = "Match found! Starting..."
	cancelBtn.Visible = false
end)

MatchUpdate.OnClientEvent:Connect(function(data)
	if data.type == "Countdown" then
		statusLabel.Visible = false
		local barBg = queueFrame:FindFirstChild("BarBg")
		if barBg then barBg.Visible = false end
		if countdownLabel then
			countdownLabel.Visible = true
			countdownLabel.Text = tostring(data.value)
		end
	elseif data.type == "Start" then
		statusLabel.Visible = true
		local barBg = queueFrame:FindFirstChild("BarBg")
		if barBg then barBg.Visible = true end
		if countdownLabel then countdownLabel.Visible = false end
		statusLabel.Text = "FIGHT! First to 5 kills"
		modeFrame.Visible = false
		queueFrame.Visible = false
		gui.Enabled = false
	elseif data.type == "Kill" then
		statusLabel.Text = data.killer .. " got a kill!"
	elseif data.type == "End" then
		statusLabel.Visible = true
		local barBg = queueFrame:FindFirstChild("BarBg")
		if barBg then barBg.Visible = true end
		if countdownLabel then countdownLabel.Visible = false end
		statusLabel.Text = "Winner: " .. data.winner
		gui.Enabled = true
		modeFrame.Visible = true
		queueFrame.Visible = false
	end
end)
