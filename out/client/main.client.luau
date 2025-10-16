-- Compiled with roblox-ts v3.0.0
local TS = require(game:GetService("ReplicatedStorage"):WaitForChild("rbxts_include"):WaitForChild("RuntimeLib"))
local ParkEnvironment = TS.import(script, game:GetService("ReplicatedStorage"), "ChessGame", "shared", "parkEnvironment").ParkEnvironment
-- Remove player character
local players = game:GetService("Players")
local player = players.LocalPlayer
if player and player.Character then
	player.Character:Destroy()
end
-- Disable character spawning
player.CharacterAdded:Connect(function(character)
	character:Destroy()
end)
-- Create park environment
local parkEnvironment = ParkEnvironment.new()
-- Set up camera focused on chess board
local camera = workspace.CurrentCamera
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
-- Board parameters
local boardCenterX = 8
local boardCenterZ = 8
local boardCenterY = 5
local cameraDistance = 20
local cameraHeight = 12
local cameraAngle = 0
-- Update camera position based on input
local isRotatingRight = false
local isRotatingLeft = false
local isZoomingIn = false
local isZoomingOut = false
UserInputService.InputBegan:Connect(function(input)
	if input.KeyCode == Enum.KeyCode.D then
		isRotatingRight = true
	elseif input.KeyCode == Enum.KeyCode.A then
		isRotatingLeft = true
	elseif input.KeyCode == Enum.KeyCode.W then
		isZoomingIn = true
	elseif input.KeyCode == Enum.KeyCode.S then
		isZoomingOut = true
	end
end)
UserInputService.InputEnded:Connect(function(input)
	if input.KeyCode == Enum.KeyCode.D then
		isRotatingRight = false
	elseif input.KeyCode == Enum.KeyCode.A then
		isRotatingLeft = false
	elseif input.KeyCode == Enum.KeyCode.W then
		isZoomingIn = false
	elseif input.KeyCode == Enum.KeyCode.S then
		isZoomingOut = false
	end
end)
RunService.RenderStepped:Connect(function()
	-- Handle camera rotation
	if isRotatingRight then
		cameraAngle += 2
	end
	if isRotatingLeft then
		cameraAngle -= 2
	end
	-- Handle zoom
	if isZoomingIn then
		cameraDistance = math.max(10, cameraDistance - 0.5)
	end
	if isZoomingOut then
		cameraDistance = math.min(30, cameraDistance + 0.5)
	end
	-- Convert angle to radians
	local angleRad = math.rad(cameraAngle)
	local cameraX = boardCenterX + math.cos(angleRad) * cameraDistance
	local cameraZ = boardCenterZ - math.sin(angleRad) * cameraDistance
	local cameraY = cameraHeight
	local cameraPosition = Vector3.new(cameraX, cameraY, cameraZ)
	local lookAtPosition = Vector3.new(boardCenterX, boardCenterY, boardCenterZ)
	camera.CFrame = CFrame.new(cameraPosition, lookAtPosition)
end)
print("✓ Character removed")
print("✓ Camera setup complete")
print("✓ Use A/D to rotate camera")
print("✓ Use W/S to zoom in/out")
