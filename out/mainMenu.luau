-- Compiled with roblox-ts v3.0.0
local TS = require(game:GetService("ReplicatedStorage"):WaitForChild("rbxts_include"):WaitForChild("RuntimeLib"))
local AboutMenu = TS.import(script, game:GetService("ReplicatedStorage"), "ChessGame", "aboutMenu").AboutMenu
local UpdatesMenu = TS.import(script, game:GetService("ReplicatedStorage"), "ChessGame", "updatesMenu").UpdatesMenu
local MainMenu
do
	MainMenu = setmetatable({}, {
		__tostring = function()
			return "MainMenu"
		end,
	})
	MainMenu.__index = MainMenu
	function MainMenu.new(...)
		local self = setmetatable({}, MainMenu)
		return self:constructor(...) or self
	end
	function MainMenu:constructor(onPlay)
		self.onPlayCallback = onPlay
		local players = game:GetService("Players")
		local player = players.LocalPlayer
		local playerGui = player:WaitForChild("PlayerGui")
		-- Create main ScreenGui - full screen including under top bar
		self.screenGui = Instance.new("ScreenGui")
		self.screenGui.Name = "ChessMainMenu"
		self.screenGui.ResetOnSpawn = false
		self.screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
		self.screenGui.IgnoreGuiInset = true
		self.screenGui.Parent = playerGui
		-- Create full-screen background - light ivory
		local background = Instance.new("Frame")
		background.Name = "Background"
		background.Size = UDim2.fromScale(1, 1)
		background.Position = UDim2.fromScale(0, 0)
		background.BackgroundColor3 = Color3.fromRGB(240, 235, 220)
		background.BackgroundTransparency = 0
		background.BorderSizePixel = 0
		background.Parent = self.screenGui
		-- Create centered content container
		local contentContainer = Instance.new("Frame")
		contentContainer.Name = "ContentContainer"
		contentContainer.Size = UDim2.fromScale(1, 1)
		contentContainer.Position = UDim2.fromScale(0, 0)
		contentContainer.BackgroundTransparency = 1
		contentContainer.BorderSizePixel = 0
		contentContainer.Parent = self.screenGui
		-- Title - Large and centered with pawn emoji
		local titleLabel = Instance.new("TextLabel")
		titleLabel.Name = "Title"
		titleLabel.Size = UDim2.fromScale(1, 0.25)
		titleLabel.Position = UDim2.fromScale(0, 0.2)
		titleLabel.BackgroundTransparency = 1
		titleLabel.Text = "claude ♟️"
		titleLabel.TextColor3 = Color3.fromRGB(40, 40, 40)
		titleLabel.TextScaled = true
		titleLabel.Font = Enum.Font.GothamBold
		titleLabel.Parent = contentContainer
		-- Play vs AI Button - Side by side layout
		local playButton = self:createButton("PlayButton", "🎮 play", UDim2.fromScale(0.15, 0.08), UDim2.fromScale(0.25, 0.52), Color3.fromRGB(40, 40, 40), Color3.fromRGB(100, 100, 100))
		playButton.Parent = contentContainer
		-- Connect play button
		playButton.MouseButton1Click:Connect(function()
			self:hide()
			if self.onPlayCallback then
				self.onPlayCallback()
			end
		end)
		-- Updates Button
		local updatesButton = self:createButton("UpdatesButton", "📋 updates", UDim2.fromScale(0.15, 0.08), UDim2.fromScale(0.5, 0.52), Color3.fromRGB(40, 40, 40), Color3.fromRGB(100, 100, 100))
		updatesButton.Parent = contentContainer
		updatesButton.MouseButton1Click:Connect(function()
			self:showUpdates()
		end)
		-- About Button
		local aboutButton = self:createButton("AboutButton", "ℹ️ about", UDim2.fromScale(0.15, 0.08), UDim2.fromScale(0.75, 0.52), Color3.fromRGB(40, 40, 40), Color3.fromRGB(100, 100, 100))
		aboutButton.Parent = contentContainer
		aboutButton.MouseButton1Click:Connect(function()
			self:showAbout()
		end)
		print("Main menu created - full screen")
	end
	function MainMenu:createButton(name, text, size, position, normalColor, hoverColor)
		local button = Instance.new("TextButton")
		button.Name = name
		button.Size = size
		button.Position = position
		button.AnchorPoint = Vector2.new(0.5, 0)
		button.BackgroundColor3 = normalColor
		button.BackgroundTransparency = 1
		button.BorderSizePixel = 2
		button.BorderColor3 = normalColor
		button.Text = text
		button.TextColor3 = normalColor
		button.TextScaled = false
		button.TextSize = 20
		button.Font = Enum.Font.GothamBold
		button.AutoButtonColor = false
		-- Hover effects - minimalist style with border only
		button.MouseEnter:Connect(function()
			button.TextColor3 = hoverColor
			button.BorderColor3 = hoverColor
		end)
		button.MouseLeave:Connect(function()
			button.TextColor3 = normalColor
			button.BorderColor3 = normalColor
		end)
		return button
	end
	function MainMenu:showAbout()
		self:hide()
		if not self.aboutMenu then
			self.aboutMenu = AboutMenu.new(function()
				local _result = self.aboutMenu
				if _result ~= nil then
					_result:hide()
				end
				self:show()
			end)
		end
		self.aboutMenu:show()
	end
	function MainMenu:showUpdates()
		self:hide()
		if not self.updatesMenu then
			self.updatesMenu = UpdatesMenu.new(function()
				local _result = self.updatesMenu
				if _result ~= nil then
					_result:hide()
				end
				self:show()
			end)
		end
		self.updatesMenu:show()
	end
	function MainMenu:show()
		self.screenGui.Enabled = true
	end
	function MainMenu:hide()
		self.screenGui.Enabled = false
	end
	function MainMenu:destroy()
		self.screenGui:Destroy()
		if self.aboutMenu then
			self.aboutMenu:destroy()
		end
		if self.updatesMenu then
			self.updatesMenu:destroy()
		end
	end
end
return {
	MainMenu = MainMenu,
}
