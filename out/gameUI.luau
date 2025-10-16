-- Compiled with roblox-ts v3.0.0
local GameUI
do
	GameUI = setmetatable({}, {
		__tostring = function()
			return "GameUI"
		end,
	})
	GameUI.__index = GameUI
	function GameUI.new(...)
		local self = setmetatable({}, GameUI)
		return self:constructor(...) or self
	end
	function GameUI:constructor()
		self.moveHistory = {}
		local players = game:GetService("Players")
		local player = players.LocalPlayer
		local playerGui = player:WaitForChild("PlayerGui")
		-- Create main ScreenGui
		self.screenGui = Instance.new("ScreenGui")
		self.screenGui.Name = "ChessGameUI"
		self.screenGui.ResetOnSpawn = false
		self.screenGui.Parent = playerGui
		-- Create minimalist move history display (top left)
		self.moveHistoryFrame = Instance.new("Frame")
		self.moveHistoryFrame.Name = "MoveHistory"
		self.moveHistoryFrame.Size = UDim2.fromScale(0.15, 0.2)
		self.moveHistoryFrame.Position = UDim2.fromScale(0.02, 0.08)
		self.moveHistoryFrame.BackgroundTransparency = 1
		self.moveHistoryFrame.BorderSizePixel = 0
		self.moveHistoryFrame.Parent = self.screenGui
		-- Move history text - minimalist
		self.moveHistoryLabel = Instance.new("TextLabel")
		self.moveHistoryLabel.Name = "MovesText"
		self.moveHistoryLabel.Size = UDim2.fromScale(1, 1)
		self.moveHistoryLabel.Position = UDim2.fromScale(0, 0)
		self.moveHistoryLabel.BackgroundTransparency = 1
		self.moveHistoryLabel.Text = ""
		self.moveHistoryLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
		self.moveHistoryLabel.TextScaled = false
		self.moveHistoryLabel.TextSize = 12
		self.moveHistoryLabel.Font = Enum.Font.Gotham
		self.moveHistoryLabel.TextXAlignment = Enum.TextXAlignment.Left
		self.moveHistoryLabel.TextYAlignment = Enum.TextYAlignment.Top
		self.moveHistoryLabel.TextWrapped = true
		self.moveHistoryLabel.Parent = self.moveHistoryFrame
		-- Create game state message label (Check/Checkmate) - centered, minimalist
		self.gameStateLabel = Instance.new("TextLabel")
		self.gameStateLabel.Name = "GameState"
		self.gameStateLabel.Size = UDim2.fromScale(0.4, 0.1)
		self.gameStateLabel.Position = UDim2.fromScale(0.3, 0.45)
		self.gameStateLabel.AnchorPoint = Vector2.new(0.5, 0.5)
		self.gameStateLabel.BackgroundTransparency = 1
		self.gameStateLabel.BorderSizePixel = 0
		self.gameStateLabel.Text = ""
		self.gameStateLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
		self.gameStateLabel.TextScaled = true
		self.gameStateLabel.Font = Enum.Font.GothamBold
		self.gameStateLabel.Visible = false
		self.gameStateLabel.Parent = self.screenGui
		-- Create back button - top left corner (door emoji)
		local backButton = Instance.new("TextButton")
		backButton.Name = "BackButton"
		backButton.Size = UDim2.fromScale(0.06, 0.06)
		backButton.Position = UDim2.fromScale(0.02, 0.02)
		backButton.BackgroundTransparency = 1
		backButton.BorderSizePixel = 0
		backButton.Text = "🚪"
		backButton.TextColor3 = Color3.fromRGB(255, 255, 255)
		backButton.TextScaled = true
		backButton.Font = Enum.Font.GothamBold
		backButton.AutoButtonColor = false
		backButton.Parent = self.screenGui
		-- Hover effect for back button
		backButton.MouseEnter:Connect(function()
			backButton.TextColor3 = Color3.fromRGB(200, 200, 200)
		end)
		backButton.MouseLeave:Connect(function()
			backButton.TextColor3 = Color3.fromRGB(255, 255, 255)
		end)
		-- Back button click - show confirmation
		backButton.MouseButton1Click:Connect(function()
			self:showConfirmationDialog()
		end)
	end
	function GameUI:addMove(from, to, piece, color)
		local moveNotation = `{if color == "white" then "White" else "Black"} {piece}: {from} → {to}`
		local _exp = self.moveHistory
		table.insert(_exp, moveNotation)
		-- Keep only last 3 moves
		if #self.moveHistory > 3 then
			table.remove(self.moveHistory, 1)
		end
		-- Update display
		self.moveHistoryLabel.Text = table.concat(self.moveHistory, "\n")
	end
	function GameUI:showCheck(playerColor)
		self.gameStateLabel.Text = "Check!"
		self.gameStateLabel.TextColor3 = Color3.fromRGB(255, 200, 0)
		self.gameStateLabel.Visible = true
		-- Hide after 1.5 seconds
		task.delay(1.5, function()
			self.gameStateLabel.Visible = false
		end)
	end
	function GameUI:showCheckmate(winner, isPlayerWinner)
		if isPlayerWinner then
			self.gameStateLabel.Text = "YOU WIN"
			self.gameStateLabel.TextColor3 = Color3.fromRGB(0, 255, 100)
		else
			self.gameStateLabel.Text = "YOU LOSE"
			self.gameStateLabel.TextColor3 = Color3.fromRGB(255, 50, 50)
		end
		self.gameStateLabel.Visible = true
		-- Return to menu after 2 seconds
		task.delay(2, function()
			if self.onGameEndCallback then
				self.onGameEndCallback()
			end
		end)
	end
	function GameUI:setOnGameEndCallback(callback)
		self.onGameEndCallback = callback
	end
	function GameUI:setOnBackToMenuCallback(callback)
		self.onBackToMenuCallback = callback
	end
	function GameUI:showConfirmationDialog()
		local players = game:GetService("Players")
		local player = players.LocalPlayer
		local playerGui = player:WaitForChild("PlayerGui")
		-- Create confirmation dialog GUI
		local dialogGui = Instance.new("ScreenGui")
		dialogGui.Name = "ConfirmationDialog"
		dialogGui.ResetOnSpawn = false
		dialogGui.Parent = playerGui
		-- Semi-transparent overlay
		local overlay = Instance.new("Frame")
		overlay.Name = "Overlay"
		overlay.Size = UDim2.fromScale(1, 1)
		overlay.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
		overlay.BackgroundTransparency = 0.7
		overlay.BorderSizePixel = 0
		overlay.Parent = dialogGui
		-- Dialog box - minimalist
		local dialog = Instance.new("Frame")
		dialog.Name = "Dialog"
		dialog.Size = UDim2.fromScale(0.4, 0.25)
		dialog.Position = UDim2.fromScale(0.5, 0.5)
		dialog.AnchorPoint = Vector2.new(0.5, 0.5)
		dialog.BackgroundColor3 = Color3.fromRGB(240, 235, 220)
		dialog.BackgroundTransparency = 0
		dialog.BorderSizePixel = 0
		dialog.Parent = dialogGui
		-- Title
		local title = Instance.new("TextLabel")
		title.Name = "Title"
		title.Size = UDim2.fromScale(1, 0.4)
		title.Position = UDim2.fromScale(0, 0.05)
		title.BackgroundTransparency = 1
		title.Text = "Leave game?"
		title.TextColor3 = Color3.fromRGB(40, 40, 40)
		title.TextScaled = true
		title.Font = Enum.Font.GothamBold
		title.Parent = dialog
		-- Warning message
		local message = Instance.new("TextLabel")
		message.Name = "Message"
		message.Size = UDim2.fromScale(0.9, 0.3)
		message.Position = UDim2.fromScale(0.05, 0.35)
		message.BackgroundTransparency = 1
		message.Text = "Board will be cleared"
		message.TextColor3 = Color3.fromRGB(100, 100, 100)
		message.TextScaled = false
		message.TextSize = 14
		message.Font = Enum.Font.Gotham
		message.TextWrapped = true
		message.Parent = dialog
		-- Yes button
		local yesButton = Instance.new("TextButton")
		yesButton.Name = "YesButton"
		yesButton.Size = UDim2.fromScale(0.35, 0.18)
		yesButton.Position = UDim2.fromScale(0.08, 0.75)
		yesButton.BackgroundTransparency = 1
		yesButton.BorderSizePixel = 1
		yesButton.BorderColor3 = Color3.fromRGB(40, 40, 40)
		yesButton.Text = "YES"
		yesButton.TextColor3 = Color3.fromRGB(40, 40, 40)
		yesButton.TextScaled = true
		yesButton.Font = Enum.Font.GothamBold
		yesButton.AutoButtonColor = false
		yesButton.Parent = dialog
		-- No button
		local noButton = Instance.new("TextButton")
		noButton.Name = "NoButton"
		noButton.Size = UDim2.fromScale(0.35, 0.18)
		noButton.Position = UDim2.fromScale(0.57, 0.75)
		noButton.BackgroundTransparency = 1
		noButton.BorderSizePixel = 1
		noButton.BorderColor3 = Color3.fromRGB(40, 40, 40)
		noButton.Text = "NO"
		noButton.TextColor3 = Color3.fromRGB(40, 40, 40)
		noButton.TextScaled = true
		noButton.Font = Enum.Font.GothamBold
		noButton.AutoButtonColor = false
		noButton.Parent = dialog
		-- Yes button action
		yesButton.MouseButton1Click:Connect(function()
			dialogGui:Destroy()
			if self.onBackToMenuCallback then
				self.onBackToMenuCallback()
			end
		end)
		-- No button action
		noButton.MouseButton1Click:Connect(function()
			dialogGui:Destroy()
		end)
		-- Hover effects
		yesButton.MouseEnter:Connect(function()
			yesButton.BorderColor3 = Color3.fromRGB(0, 0, 0)
			yesButton.TextColor3 = Color3.fromRGB(0, 0, 0)
		end)
		yesButton.MouseLeave:Connect(function()
			yesButton.BorderColor3 = Color3.fromRGB(40, 40, 40)
			yesButton.TextColor3 = Color3.fromRGB(40, 40, 40)
		end)
		noButton.MouseEnter:Connect(function()
			noButton.BorderColor3 = Color3.fromRGB(0, 0, 0)
			noButton.TextColor3 = Color3.fromRGB(0, 0, 0)
		end)
		noButton.MouseLeave:Connect(function()
			noButton.BorderColor3 = Color3.fromRGB(40, 40, 40)
			noButton.TextColor3 = Color3.fromRGB(40, 40, 40)
		end)
	end
	function GameUI:clearGameState()
		self.gameStateLabel.Visible = false
	end
	function GameUI:destroy()
		self.screenGui:Destroy()
	end
end
return {
	GameUI = GameUI,
}
