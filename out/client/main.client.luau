-- Compiled with roblox-ts v3.0.0
local TS = require(game:GetService("ReplicatedStorage"):WaitForChild("rbxts_include"):WaitForChild("RuntimeLib"))
local ParkEnvironment = TS.import(script, game:GetService("ReplicatedStorage"), "ChessGame", "shared", "parkEnvironment").ParkEnvironment
local MobileControls = TS.import(script, script.Parent, "mobileControls").MobileControls
local GameManager = TS.import(script, game:GetService("ReplicatedStorage"), "ChessGame", "gameManager").GameManager
local MainMenu = TS.import(script, game:GetService("ReplicatedStorage"), "ChessGame", "mainMenu").MainMenu
-- Remove player character
local players = game:GetService("Players")
local player = players.LocalPlayer
if player and player.Character then
	player.Character:Destroy()
end
-- Disable character spawning
if player then
	player.CharacterAdded:Connect(function(character)
		character:Destroy()
	end)
end
-- Create park environment
local parkEnvironment = ParkEnvironment.new()
-- Set up camera focused on chess board
local camera = workspace.CurrentCamera
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
-- Mobile controls instance
local mobileControls
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
	-- Handle camera rotation (faster speed)
	if isRotatingRight then
		cameraAngle += 4
	end
	if isRotatingLeft then
		cameraAngle -= 4
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
-- Landscape orientation overlay
local orientationOverlay
local function createOrientationWarning()
	local players = game:GetService("Players")
	local player = players.LocalPlayer
	local playerGui = player:WaitForChild("PlayerGui")
	local gui = Instance.new("ScreenGui")
	gui.Name = "OrientationWarning"
	gui.ResetOnSpawn = false
	gui.IgnoreGuiInset = true
	gui.Parent = playerGui
	local background = Instance.new("Frame")
	background.Size = UDim2.fromScale(1, 1)
	background.BackgroundColor3 = Color3.fromRGB(240, 235, 220)
	background.BorderSizePixel = 0
	background.Parent = gui
	local message = Instance.new("TextLabel")
	message.Size = UDim2.fromScale(0.8, 0.3)
	message.Position = UDim2.fromScale(0.1, 0.35)
	message.BackgroundTransparency = 1
	message.Text = "please rotate to landscape ⟲"
	message.TextColor3 = Color3.fromRGB(40, 40, 40)
	message.TextScaled = true
	message.Font = Enum.Font.GothamBold
	message.TextWrapped = true
	message.Parent = background
	return gui
end
local function isPortraitMode()
	local screenSize = camera.ViewportSize
	return screenSize.Y > screenSize.X
end
local function checkOrientation()
	if not UserInputService.TouchEnabled then
		return nil
	end
	if isPortraitMode() then
		if not orientationOverlay then
			orientationOverlay = createOrientationWarning()
			print("⚠️  Portrait mode detected - showing landscape warning")
		end
	else
		if orientationOverlay then
			orientationOverlay:Destroy()
			orientationOverlay = nil
			print("✓ Landscape mode detected")
		end
	end
end
-- Platform detection and mobile controls setup
local function setupMobileControls()
	-- Debug logging
	print("🔍 Platform Detection Debug:")
	print(`TouchEnabled: {UserInputService.TouchEnabled}`)
	print(`KeyboardEnabled: {UserInputService.KeyboardEnabled}`)
	print(`MouseEnabled: {UserInputService.MouseEnabled}`)
	-- Check if user is on a mobile device
	local isMobileDevice = UserInputService.TouchEnabled and not UserInputService.KeyboardEnabled and not UserInputService.MouseEnabled
	-- Also check for tablets (touch enabled but may have keyboard/mouse)
	local isTablet = UserInputService.TouchEnabled and (UserInputService.KeyboardEnabled or UserInputService.MouseEnabled)
	print(`isMobileDevice: {isMobileDevice}`)
	print(`isTablet: {isTablet}`)
	-- Only show mobile controls on touch-enabled devices
	if UserInputService.TouchEnabled then
		mobileControls = MobileControls.new({
			onRotateLeft = function()
				cameraAngle -= 4
			end,
			onRotateRight = function()
				cameraAngle += 4
			end,
			onZoomIn = function()
				cameraDistance = math.max(10, cameraDistance - 0.5)
			end,
			onZoomOut = function()
				cameraDistance = math.min(30, cameraDistance + 0.5)
			end,
			onRotateDelta = function(delta)
				cameraAngle += delta
			end,
			onZoomDelta = function(delta)
				cameraDistance = math.clamp(cameraDistance + delta, 10, 30)
			end,
		})
		print("✓ Mobile controls enabled (swipe and pinch gestures)")
		-- Check orientation periodically for mobile devices
		game:GetService("RunService").Heartbeat:Connect(function()
			checkOrientation()
		end)
	end
end
-- Wait for player to be fully loaded before setting up controls
if player then
	player.CharacterAdded:Wait()
end
setupMobileControls()
print("✓ Character removed")
print("✓ Camera setup complete")
print("✓ Desktop: Use A/D to rotate camera, W/S to zoom")
print("✓ Mobile: Use on-screen buttons or touch gestures")
-- Game manager reference
local gameManager
-- Function to reset and return to menu
local mainMenu
local function returnToMenu()
	print("Returning to menu...")
	if gameManager then
		gameManager:stopGame()
	end
	mainMenu:show()
end
-- Function to start the game
local function startChessGame()
	print("Starting chess game...")
	gameManager = GameManager.new()
	-- Set callback to return to menu when game ends
	gameManager:getUI():setOnGameEndCallback(function()
		print("Game ended, returning to menu...")
		returnToMenu()
	end)
	-- Set callback for back button
	gameManager:getUI():setOnBackToMenuCallback(function()
		returnToMenu()
	end)
	gameManager:startGame()
	print("✓ Chess game started on client")
end
-- Create and show main menu
mainMenu = MainMenu.new(function()
	startChessGame()
end)
print("✓ Main menu displayed")
