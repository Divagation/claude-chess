-- Compiled with roblox-ts v3.0.0
local UpdatesMenu
do
	UpdatesMenu = setmetatable({}, {
		__tostring = function()
			return "UpdatesMenu"
		end,
	})
	UpdatesMenu.__index = UpdatesMenu
	function UpdatesMenu.new(...)
		local self = setmetatable({}, UpdatesMenu)
		return self:constructor(...) or self
	end
	function UpdatesMenu:constructor(onBack)
		self.onBackCallback = onBack
		local players = game:GetService("Players")
		local player = players.LocalPlayer
		local playerGui = player:WaitForChild("PlayerGui")
		-- Create main ScreenGui
		self.screenGui = Instance.new("ScreenGui")
		self.screenGui.Name = "UpdatesMenu"
		self.screenGui.ResetOnSpawn = false
		self.screenGui.IgnoreGuiInset = true
		self.screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
		self.screenGui.Parent = playerGui
		-- Full-screen background
		local background = Instance.new("Frame")
		background.Name = "Background"
		background.Size = UDim2.fromScale(1, 1)
		background.BackgroundColor3 = Color3.fromRGB(240, 235, 220)
		background.BorderSizePixel = 0
		background.Parent = self.screenGui
		-- Content container
		local contentContainer = Instance.new("Frame")
		contentContainer.Name = "ContentContainer"
		contentContainer.Size = UDim2.fromScale(1, 1)
		contentContainer.BackgroundTransparency = 1
		contentContainer.BorderSizePixel = 0
		contentContainer.Parent = self.screenGui
		-- Back button (door emoji) - positioned below Roblox top bar
		local backButton = Instance.new("TextButton")
		backButton.Name = "BackButton"
		backButton.Size = UDim2.fromScale(0.1, 0.1)
		backButton.Position = UDim2.fromScale(0.02, 0.12)
		backButton.BackgroundTransparency = 1
		backButton.BorderSizePixel = 0
		backButton.Text = "🚪"
		backButton.TextColor3 = Color3.fromRGB(40, 40, 40)
		backButton.TextScaled = true
		backButton.Font = Enum.Font.GothamBold
		backButton.AutoButtonColor = false
		backButton.Parent = contentContainer
		backButton.MouseEnter:Connect(function()
			backButton.TextColor3 = Color3.fromRGB(100, 100, 100)
		end)
		backButton.MouseLeave:Connect(function()
			backButton.TextColor3 = Color3.fromRGB(40, 40, 40)
		end)
		backButton.MouseButton1Click:Connect(function()
			self:hide()
			if self.onBackCallback then
				self.onBackCallback()
			end
		end)
		-- Title
		local titleLabel = Instance.new("TextLabel")
		titleLabel.Name = "Title"
		titleLabel.Size = UDim2.fromScale(1, 0.12)
		titleLabel.Position = UDim2.fromScale(0, 0.12)
		titleLabel.BackgroundTransparency = 1
		titleLabel.Text = "updates"
		titleLabel.TextColor3 = Color3.fromRGB(40, 40, 40)
		titleLabel.TextScaled = true
		titleLabel.Font = Enum.Font.GothamBold
		titleLabel.Parent = contentContainer
		-- Updates text
		local updatesText = Instance.new("TextLabel")
		updatesText.Name = "UpdatesText"
		updatesText.Size = UDim2.fromScale(0.85, 0.7)
		updatesText.Position = UDim2.fromScale(0.075, 0.28)
		updatesText.BackgroundTransparency = 1
		updatesText.Text = "v1.1 alpha\n\n• full-screen main menu with minimalist ivory design\n• emoji-enhanced buttons (🎮 play, 📋 updates, ℹ️ about)\n• back to main menu button with confirmation dialog\n• move history relocated to left side\n• minimalist game ui throughout\n• mobile landscape orientation detection\n• about and updates menus\n• lowercase ui consistency\n• large pawn emoji on about page\n• back button positioned below roblox top bar"
		updatesText.TextColor3 = Color3.fromRGB(40, 40, 40)
		updatesText.TextScaled = false
		updatesText.TextSize = 16
		updatesText.Font = Enum.Font.Gotham
		updatesText.TextWrapped = true
		updatesText.TextYAlignment = Enum.TextYAlignment.Top
		updatesText.TextXAlignment = Enum.TextXAlignment.Left
		updatesText.Parent = contentContainer
		print("Updates menu created")
	end
	function UpdatesMenu:show()
		self.screenGui.Enabled = true
	end
	function UpdatesMenu:hide()
		self.screenGui.Enabled = false
	end
	function UpdatesMenu:destroy()
		self.screenGui:Destroy()
	end
end
return {
	UpdatesMenu = UpdatesMenu,
}
