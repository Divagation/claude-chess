-- Compiled with roblox-ts v3.0.0
local AboutMenu
do
	AboutMenu = setmetatable({}, {
		__tostring = function()
			return "AboutMenu"
		end,
	})
	AboutMenu.__index = AboutMenu
	function AboutMenu.new(...)
		local self = setmetatable({}, AboutMenu)
		return self:constructor(...) or self
	end
	function AboutMenu:constructor(onBack)
		self.onBackCallback = onBack
		local players = game:GetService("Players")
		local player = players.LocalPlayer
		local playerGui = player:WaitForChild("PlayerGui")
		-- Create main ScreenGui
		self.screenGui = Instance.new("ScreenGui")
		self.screenGui.Name = "AboutMenu"
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
		-- Back button (door emoji)
		local backButton = Instance.new("TextButton")
		backButton.Name = "BackButton"
		backButton.Size = UDim2.fromScale(0.06, 0.06)
		backButton.Position = UDim2.fromScale(0.02, 0.08)
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
		titleLabel.Size = UDim2.fromScale(1, 0.15)
		titleLabel.Position = UDim2.fromScale(0, 0.15)
		titleLabel.BackgroundTransparency = 1
		titleLabel.Text = "about"
		titleLabel.TextColor3 = Color3.fromRGB(40, 40, 40)
		titleLabel.TextScaled = true
		titleLabel.Font = Enum.Font.GothamBold
		titleLabel.Parent = contentContainer
		-- About text
		local aboutText = Instance.new("TextLabel")
		aboutText.Name = "AboutText"
		aboutText.Size = UDim2.fromScale(0.8, 0.4)
		aboutText.Position = UDim2.fromScale(0.1, 0.28)
		aboutText.BackgroundTransparency = 1
		aboutText.Text = "hello! this chess game is made by f4II and claude code as an example of how powerful claude can be for use in roblox development. thanks for checking it out, and enjoy the game!"
		aboutText.TextColor3 = Color3.fromRGB(40, 40, 40)
		aboutText.TextScaled = false
		aboutText.TextSize = 18
		aboutText.Font = Enum.Font.Gotham
		aboutText.TextWrapped = true
		aboutText.TextYAlignment = Enum.TextYAlignment.Top
		aboutText.Parent = contentContainer
		-- Cool emoji at bottom
		local emojiLabel = Instance.new("TextLabel")
		emojiLabel.Name = "EmojiLabel"
		emojiLabel.Size = UDim2.fromScale(1, 0.2)
		emojiLabel.Position = UDim2.fromScale(0, 0.65)
		emojiLabel.BackgroundTransparency = 1
		emojiLabel.Text = "♟️"
		emojiLabel.TextColor3 = Color3.fromRGB(40, 40, 40)
		emojiLabel.TextScaled = true
		emojiLabel.Font = Enum.Font.GothamBold
		emojiLabel.Parent = contentContainer
		print("About menu created")
	end
	function AboutMenu:show()
		self.screenGui.Enabled = true
	end
	function AboutMenu:hide()
		self.screenGui.Enabled = false
	end
	function AboutMenu:destroy()
		self.screenGui:Destroy()
	end
end
return {
	AboutMenu = AboutMenu,
}
