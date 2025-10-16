-- Compiled with roblox-ts v3.0.0
local MobileControls
do
	MobileControls = setmetatable({}, {
		__tostring = function()
			return "MobileControls"
		end,
	})
	MobileControls.__index = MobileControls
	function MobileControls.new(...)
		local self = setmetatable({}, MobileControls)
		return self:constructor(...) or self
	end
	function MobileControls:constructor(controls)
		self.isRotatingLeft = false
		self.isRotatingRight = false
		self.isZoomingIn = false
		self.isZoomingOut = false
		print("🔧 Creating MobileControls...")
		self.controls = controls
		self.GuiService = game:GetService("GuiService")
		self.UserInputService = game:GetService("UserInputService")
		self.RunService = game:GetService("RunService")
		-- Create main ScreenGui
		self.screenGui = Instance.new("ScreenGui")
		self.screenGui.Name = "MobileCameraControls"
		self.screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
		self.screenGui.ResetOnSpawn = false
		-- Get the player service and wait for LocalPlayer
		local playersService = game:GetService("Players")
		local localPlayer = playersService.LocalPlayer
		if not localPlayer then
			print("❌ LocalPlayer not found, cannot create mobile controls")
			return nil
		end
		print("📱 Waiting for PlayerGui...")
		local playerGui = localPlayer:WaitForChild("PlayerGui")
		self.screenGui.Parent = playerGui
		print("✅ ScreenGui parented to PlayerGui")
		self:createControls()
		self:setupTouchInteractions()
		self:setupContinuousRotation()
		print("✅ MobileControls created successfully")
	end
	function MobileControls:createControls()
		-- Calculate button size based on screen size
		local camera = workspace.CurrentCamera
		local viewportSize = camera.ViewportSize
		local buttonSize = math.min(viewportSize.X, viewportSize.Y) * 0.12
		local padding = buttonSize * 0.3
		-- Left rotation button (bottom left)
		self:createButton("RotateLeft", "←", UDim2.new(0, padding, 1, -(buttonSize + padding)), UDim2.new(0, buttonSize, 0, buttonSize), function()
			return self.controls.onRotateLeft()
		end, function()
			self.isRotatingLeft = true
		end, function()
			self.isRotatingLeft = false
		end)
		-- Right rotation button (bottom right)
		self:createButton("RotateRight", "→", UDim2.new(1, -(buttonSize + padding), 1, -(buttonSize + padding)), UDim2.new(0, buttonSize, 0, buttonSize), function()
			return self.controls.onRotateRight()
		end, function()
			self.isRotatingRight = true
		end, function()
			self.isRotatingRight = false
		end)
		-- Zoom in button (right side, above rotation)
		self:createButton("ZoomIn", "+", UDim2.new(1, -(buttonSize + padding), 1, -(buttonSize * 2 + padding * 2)), UDim2.new(0, buttonSize, 0, buttonSize), function()
			return self.controls.onZoomIn()
		end, function()
			self.isZoomingIn = true
		end, function()
			self.isZoomingIn = false
		end)
		-- Zoom out button (right side, above zoom in)
		self:createButton("ZoomOut", "-", UDim2.new(1, -(buttonSize + padding), 1, -(buttonSize * 3 + padding * 3)), UDim2.new(0, buttonSize, 0, buttonSize), function()
			return self.controls.onZoomOut()
		end, function()
			self.isZoomingOut = true
		end, function()
			self.isZoomingOut = false
		end)
	end
	function MobileControls:createButton(name, text, position, size, onClick, onHoldStart, onHoldEnd)
		-- Create button frame
		local button = Instance.new("TextButton")
		button.Name = name
		button.Size = size
		button.Position = position
		button.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
		button.BackgroundTransparency = 0.3
		button.BorderSizePixel = 0
		button.Font = Enum.Font.SourceSansBold
		button.Text = text
		button.TextColor3 = Color3.fromRGB(255, 255, 255)
		button.TextScaled = true
		button.Parent = self.screenGui
		-- Add corner rounding
		local corner = Instance.new("UICorner")
		corner.CornerRadius = UDim.new(0, 8)
		corner.Parent = button
		-- Add shadow effect
		local shadow = Instance.new("ImageLabel")
		shadow.Name = "Shadow"
		shadow.Size = UDim2.new(1, 4, 1, 4)
		shadow.Position = UDim2.new(0, -2, 0, -2)
		shadow.BackgroundTransparency = 1
		shadow.Image = "rbxasset://textures/ui/Controls/dropdown_shadow.png"
		shadow.ImageColor3 = Color3.fromRGB(0, 0, 0)
		shadow.ImageTransparency = 0.7
		shadow.ScaleType = Enum.ScaleType.Slice
		shadow.SliceCenter = Rect.new(2, 2, 6, 6)
		shadow.ZIndex = button.ZIndex - 1
		shadow.Parent = button
		-- Button interaction handling
		local isPressed = false
		button.MouseEnter:Connect(function()
			if not self.UserInputService.TouchEnabled then
				button.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
				button.BackgroundTransparency = 0.2
			end
		end)
		button.MouseLeave:Connect(function()
			if not isPressed then
				button.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
				button.BackgroundTransparency = 0.3
			end
		end)
		button.MouseButton1Down:Connect(function()
			isPressed = true
			button.BackgroundColor3 = Color3.fromRGB(80, 80, 80)
			button.BackgroundTransparency = 0.1
			onClick()
			if onHoldStart then
				onHoldStart()
			end
		end)
		button.MouseButton1Up:Connect(function()
			isPressed = false
			button.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
			button.BackgroundTransparency = 0.3
			if onHoldEnd then
				onHoldEnd()
			end
		end)
		-- Touch support
		button.InputBegan:Connect(function(input)
			if input.UserInputType == Enum.UserInputType.Touch then
				isPressed = true
				button.BackgroundColor3 = Color3.fromRGB(80, 80, 80)
				button.BackgroundTransparency = 0.1
				onClick()
				if onHoldStart then
					onHoldStart()
				end
			end
		end)
		button.InputEnded:Connect(function(input)
			if input.UserInputType == Enum.UserInputType.Touch then
				isPressed = false
				button.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
				button.BackgroundTransparency = 0.3
				if onHoldEnd then
					onHoldEnd()
				end
			end
		end)
	end
	function MobileControls:setupContinuousRotation()
		self.RunService.RenderStepped:Connect(function()
			-- Continuous rotation while buttons are held
			if self.isRotatingLeft then
				self.controls.onRotateLeft()
			end
			if self.isRotatingRight then
				self.controls.onRotateRight()
			end
			if self.isZoomingIn then
				self.controls.onZoomIn()
			end
			if self.isZoomingOut then
				self.controls.onZoomOut()
			end
		end)
	end
	function MobileControls:setupTouchInteractions()
		-- Touch interactions are handled by the button Touch events in createButton
		-- Future enhancement: Add swipe gestures and pinch-to-zoom
		print("✓ Touch interactions configured")
	end
	function MobileControls:destroy()
		if self.screenGui then
			self.screenGui:Destroy()
		end
	end
	function MobileControls:setVisible(visible)
		self.screenGui.Enabled = visible
	end
	function MobileControls:isVisible()
		return self.screenGui.Enabled
	end
end
return {
	MobileControls = MobileControls,
}
