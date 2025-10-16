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
		-- Create move history display
		self.moveHistoryFrame = Instance.new("Frame")
		self.moveHistoryFrame.Name = "MoveHistory"
		self.moveHistoryFrame.Size = UDim2.fromScale(0.3, 0.15)
		self.moveHistoryFrame.Position = UDim2.fromScale(0.35, 0.02)
		self.moveHistoryFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
		self.moveHistoryFrame.BackgroundTransparency = 0.3
		self.moveHistoryFrame.BorderSizePixel = 2
		self.moveHistoryFrame.BorderColor3 = Color3.fromRGB(200, 200, 200)
		self.moveHistoryFrame.Parent = self.screenGui
		-- Add rounded corners to move history
		local moveHistoryCorner = Instance.new("UICorner")
		moveHistoryCorner.CornerRadius = UDim.new(0, 8)
		moveHistoryCorner.Parent = self.moveHistoryFrame
		-- Title for move history
		local moveHistoryTitle = Instance.new("TextLabel")
		moveHistoryTitle.Name = "Title"
		moveHistoryTitle.Size = UDim2.fromScale(1, 0.25)
		moveHistoryTitle.Position = UDim2.fromScale(0, 0)
		moveHistoryTitle.BackgroundTransparency = 1
		moveHistoryTitle.Text = "Recent Moves"
		moveHistoryTitle.TextColor3 = Color3.fromRGB(255, 255, 255)
		moveHistoryTitle.TextScaled = true
		moveHistoryTitle.Font = Enum.Font.GothamBold
		moveHistoryTitle.Parent = self.moveHistoryFrame
		-- Move history text
		self.moveHistoryLabel = Instance.new("TextLabel")
		self.moveHistoryLabel.Name = "MovesText"
		self.moveHistoryLabel.Size = UDim2.fromScale(0.95, 0.7)
		self.moveHistoryLabel.Position = UDim2.fromScale(0.025, 0.28)
		self.moveHistoryLabel.BackgroundTransparency = 1
		self.moveHistoryLabel.Text = "No moves yet"
		self.moveHistoryLabel.TextColor3 = Color3.fromRGB(220, 220, 220)
		self.moveHistoryLabel.TextScaled = false
		self.moveHistoryLabel.TextSize = 16
		self.moveHistoryLabel.Font = Enum.Font.Gotham
		self.moveHistoryLabel.TextXAlignment = Enum.TextXAlignment.Left
		self.moveHistoryLabel.TextYAlignment = Enum.TextYAlignment.Top
		self.moveHistoryLabel.TextWrapped = true
		self.moveHistoryLabel.Parent = self.moveHistoryFrame
		-- Create game state message label (Check/Checkmate)
		self.gameStateLabel = Instance.new("TextLabel")
		self.gameStateLabel.Name = "GameState"
		self.gameStateLabel.Size = UDim2.fromScale(0.5, 0.12)
		self.gameStateLabel.Position = UDim2.fromScale(0.25, 0.4)
		self.gameStateLabel.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
		self.gameStateLabel.BackgroundTransparency = 0.2
		self.gameStateLabel.BorderSizePixel = 3
		self.gameStateLabel.Text = ""
		self.gameStateLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
		self.gameStateLabel.TextScaled = true
		self.gameStateLabel.Font = Enum.Font.GothamBold
		self.gameStateLabel.Visible = false
		self.gameStateLabel.Parent = self.screenGui
		-- Add rounded corners to game state
		local gameStateCorner = Instance.new("UICorner")
		gameStateCorner.CornerRadius = UDim.new(0, 12)
		gameStateCorner.Parent = self.gameStateLabel
		-- Add padding
		local padding = Instance.new("UIPadding")
		padding.PaddingLeft = UDim.new(0, 20)
		padding.PaddingRight = UDim.new(0, 20)
		padding.PaddingTop = UDim.new(0, 10)
		padding.PaddingBottom = UDim.new(0, 10)
		padding.Parent = self.gameStateLabel
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
		self.gameStateLabel.BorderColor3 = Color3.fromRGB(255, 200, 0)
		self.gameStateLabel.Visible = true
		-- Hide after 2 seconds
		task.delay(2, function()
			self.gameStateLabel.Visible = false
		end)
	end
	function GameUI:showCheckmate(winner, isPlayerWinner)
		if isPlayerWinner then
			self.gameStateLabel.Text = "Checkmate! You Win!"
			self.gameStateLabel.TextColor3 = Color3.fromRGB(0, 255, 100)
			self.gameStateLabel.BorderColor3 = Color3.fromRGB(0, 255, 100)
		else
			self.gameStateLabel.Text = "Checkmate! You Lose!"
			self.gameStateLabel.TextColor3 = Color3.fromRGB(255, 50, 50)
			self.gameStateLabel.BorderColor3 = Color3.fromRGB(255, 50, 50)
		end
		self.gameStateLabel.Visible = true
		-- Don't hide checkmate message
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
