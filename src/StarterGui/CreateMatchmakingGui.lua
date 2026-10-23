-- Creates the MatchmakingGui in StarterGui.
-- Run this in the Roblox Studio Command Bar to generate the GUI.

local StarterGui = game:GetService("StarterGui")
local existing = StarterGui:FindFirstChild("MatchmakingGui")
if existing then existing:Destroy() end

local gui = Instance.new("ScreenGui")
gui.Name = "MatchmakingGui"
gui.ResetOnSpawn = false
gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
gui.Parent = StarterGui

local card = Instance.new("Frame")
card.Name = "ModeFrame"
card.Size = UDim2.new(0, 260, 0, 130)
card.Position = UDim2.new(0.5, -130, 1, -150)
card.BackgroundColor3 = Color3.fromRGB(18, 18, 28)
card.BorderSizePixel = 0
card.Parent = gui
local cardCorner = Instance.new("UICorner"); cardCorner.CornerRadius = UDim.new(0, 14); cardCorner.Parent = card
local cardStroke = Instance.new("UIStroke"); cardStroke.Color = Color3.fromRGB(60, 60, 90); cardStroke.Thickness = 1; cardStroke.Parent = card

local title = Instance.new("TextLabel")
title.Name = "Title"
title.Size = UDim2.new(1, 0, 0, 22)
title.Position = UDim2.new(0, 0, 0, 8)
title.Text = "MATCHMAKING"
title.Font = Enum.Font.GothamBlack
title.TextSize = 20
title.TextColor3 = Color3.fromRGB(255, 255, 255)
title.BackgroundTransparency = 1
title.Parent = card

local sub = Instance.new("TextLabel")
sub.Name = "Subtitle"
sub.Size = UDim2.new(1, 0, 0, 16)
sub.Position = UDim2.new(0, 0, 0, 34)
sub.Text = "Select a mode to queue"
sub.Font = Enum.Font.Gotham
sub.TextSize = 12
sub.TextColor3 = Color3.fromRGB(150, 150, 170)
sub.BackgroundTransparency = 1
sub.Parent = card

local playBtn = Instance.new("TextButton")
playBtn.Name = "PlayButton"
playBtn.Size = UDim2.new(0, 220, 0, 36)
playBtn.Position = UDim2.new(0.5, -110, 0, 58)
playBtn.Text = "1v1  •  Play"
playBtn.Font = Enum.Font.GothamBold
playBtn.TextSize = 16
playBtn.BackgroundColor3 = Color3.fromRGB(88, 101, 242)
playBtn.TextColor3 = Color3.new(1,1,1)
playBtn.BorderSizePixel = 0
playBtn.Parent = card
local playCorner = Instance.new("UICorner"); playCorner.CornerRadius = UDim.new(0, 10); playCorner.Parent = playBtn
local playStroke = Instance.new("UIStroke"); playStroke.Color = Color3.fromRGB(120, 130, 255); playStroke.Thickness = 1; playStroke.Parent = playBtn

local queueFrame = Instance.new("Frame")
queueFrame.Name = "QueueFrame"
queueFrame.Size = UDim2.new(0, 260, 0, 130)
queueFrame.Position = UDim2.new(0.5, -130, 1, -150)
queueFrame.BackgroundColor3 = Color3.fromRGB(18, 18, 28)
queueFrame.BorderSizePixel = 0
queueFrame.Visible = false
queueFrame.Parent = gui
local qCorner = Instance.new("UICorner"); qCorner.CornerRadius = UDim.new(0, 14); qCorner.Parent = queueFrame
local qStroke = Instance.new("UIStroke"); qStroke.Color = Color3.fromRGB(60, 60, 90); qStroke.Thickness = 1; qStroke.Parent = queueFrame

local statusLabel = Instance.new("TextLabel")
statusLabel.Name = "StatusLabel"
statusLabel.Size = UDim2.new(1, -30, 0, 22)
statusLabel.Position = UDim2.new(0, 15, 0, 16)
statusLabel.Text = "Searching for players..."
statusLabel.Font = Enum.Font.GothamMedium
statusLabel.TextSize = 14
statusLabel.TextColor3 = Color3.fromRGB(220, 220, 235)
statusLabel.BackgroundTransparency = 1
statusLabel.Parent = queueFrame

local barBg = Instance.new("Frame")
barBg.Name = "BarBg"
barBg.Size = UDim2.new(1, -30, 0, 6)
barBg.Position = UDim2.new(0, 15, 0, 48)
barBg.BackgroundColor3 = Color3.fromRGB(40, 40, 60)
barBg.BorderSizePixel = 0
barBg.Parent = queueFrame
local barBgCorner = Instance.new("UICorner"); barBgCorner.CornerRadius = UDim.new(1, 0); barBgCorner.Parent = barBg

local barFill = Instance.new("Frame")
barFill.Name = "BarFill"
barFill.Size = UDim2.new(0, 0, 1, 0)
barFill.BackgroundColor3 = Color3.fromRGB(88, 101, 242)
barFill.BorderSizePixel = 0
barFill.Parent = barBg
local barFillCorner = Instance.new("UICorner"); barFillCorner.CornerRadius = UDim.new(1, 0); barFillCorner.Parent = barFill

local countdownLabel = Instance.new("TextLabel")
countdownLabel.Name = "CountdownLabel"
countdownLabel.Size = UDim2.new(1, 0, 0, 60)
countdownLabel.Position = UDim2.new(0, 0, 0.5, -30)
countdownLabel.Text = ""
countdownLabel.Font = Enum.Font.GothamBlack
countdownLabel.TextSize = 48
countdownLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
countdownLabel.BackgroundTransparency = 1
countdownLabel.Visible = false
countdownLabel.Parent = queueFrame

local cancelBtn = Instance.new("TextButton")
cancelBtn.Name = "CancelButton"
cancelBtn.Size = UDim2.new(0, 140, 0, 36)
cancelBtn.Position = UDim2.new(0.5, -70, 1, -46)
cancelBtn.Text = "Cancel"
cancelBtn.Font = Enum.Font.GothamBold
cancelBtn.TextSize = 14
cancelBtn.BackgroundColor3 = Color3.fromRGB(220, 60, 60)
cancelBtn.TextColor3 = Color3.new(1,1,1)
cancelBtn.BorderSizePixel = 0
cancelBtn.Parent = queueFrame
local cancelCorner = Instance.new("UICorner"); cancelCorner.CornerRadius = UDim.new(0, 8); cancelCorner.Parent = cancelBtn
