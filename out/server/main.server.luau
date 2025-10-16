-- Compiled with roblox-ts v3.0.0
local TS = require(game:GetService("ReplicatedStorage"):WaitForChild("rbxts_include"):WaitForChild("RuntimeLib"))
local GameManager = TS.import(script, game:GetService("ReplicatedStorage"), "ChessGame", "gameManager").GameManager
-- Remove baseplate and spawn locations
local workspace = game:GetService("Workspace")
-- Remove baseplate
local baseplate = workspace:FindFirstChild("Baseplate")
if baseplate then
	baseplate:Destroy()
end
-- Remove spawn location
local spawnLocation = workspace:FindFirstChild("SpawnLocation")
if spawnLocation then
	spawnLocation:Destroy()
end
-- Remove any other default parts
local parts = workspace:FindFirstChildOfClass("Part")
if parts then
	local allParts = workspace:GetDescendants()
	for _, part in allParts do
		if part:IsA("Part") and (part.Name == "Baseplate" or part.Name == "SpawnLocation") then
			part:Destroy()
		end
	end
end
-- Remove any existing ChessBoard folders from previous runs
local existingChessBoards = workspace:GetChildren()
for _, child in existingChessBoards do
	if child.Name == "ChessBoard" then
		child:Destroy()
	end
end
-- Start the game
local gameManager = GameManager.new()
gameManager:startGame()
print("✓ Baseplate and spawn location removed")
print("✓ Chess game started")
