-- Compiled with roblox-ts v3.0.0
local TS = require(game:GetService("ReplicatedStorage"):WaitForChild("rbxts_include"):WaitForChild("RuntimeLib"))
local ChessBoard = TS.import(script, game:GetService("ServerScriptService"), "Shared", "board").ChessBoard
local BoardRenderer = TS.import(script, game:GetService("ServerScriptService"), "Shared", "renderer").BoardRenderer
local ChessAI = TS.import(script, game:GetService("ServerScriptService"), "Shared", "ai").ChessAI
-- Global reference for click handlers
local currentGameManager
local function selectSquareGlobal(row, col)
	if currentGameManager then
		currentGameManager:selectSquare(row, col)
	end
end
local GameManager
do
	GameManager = setmetatable({}, {
		__tostring = function()
			return "GameManager"
		end,
	})
	GameManager.__index = GameManager
	function GameManager.new(...)
		local self = setmetatable({}, GameManager)
		return self:constructor(...) or self
	end
	function GameManager:constructor()
		self.gameRunning = true
		self.board = ChessBoard.new()
		self.renderer = BoardRenderer.new(self.board, function(row, col)
			self:selectSquare(row, col)
		end)
		self.ai = ChessAI.new()
		currentGameManager = self
		self:updateDisplay()
	end
	function GameManager:updateDisplay()
		local gameState = self.board:getGameState()
		-- Check for checkmate
		if self.board:isInCheckmate(gameState.currentPlayer) then
			local winner = if gameState.currentPlayer == "white" then "Black" else "White"
			print(`CHECKMATE! {winner} wins!`)
			self.gameRunning = false
		elseif self.board:isInCheck(gameState.currentPlayer) then
			print(`{if gameState.currentPlayer == "white" then "White" else "Black"} is in CHECK!`)
		end
		self.renderer:renderBoard(self.board, gameState.selectedSquare)
		self.renderer:highlightValidMoves(gameState.validMoves)
	end
	function GameManager:selectSquare(row, col)
		self.board:selectSquare(row, col)
		self:updateDisplay()
	end
	function GameManager:makeAIMove()
		local currentPlayer = self.board:getGameState().currentPlayer
		if currentPlayer ~= "black" then
			return nil
		end
		local move = self.ai:findBestMove(self.board)
		if move then
			print(`AI moved from [{move.from.row},{move.from.col}] to [{move.to.row},{move.to.col}]`)
			self.board:selectSquare(move.from.row, move.from.col)
			self.board:selectSquare(move.to.row, move.to.col)
			self:updateDisplay()
		end
	end
	function GameManager:startGame()
		print("Chess game started! Player is White, AI is Black.")
		print("Click on pieces to select them and on highlighted squares to move.")
		local lastPlayer = "white"
		local aiThinking = false
		local connection
		connection = game:GetService("RunService").Heartbeat:Connect(function()
			if not self.gameRunning then
				connection:Disconnect()
				return nil
			end
			local gameState = self.board:getGameState()
			-- Check if it's AI's turn and we haven't processed this turn yet
			if gameState.currentPlayer == "black" and not aiThinking and lastPlayer == "white" then
				aiThinking = true
				lastPlayer = "black"
				-- Delay AI move slightly so the board updates
				task.wait(0.5)
				self:makeAIMove()
				aiThinking = false
			elseif gameState.currentPlayer == "white" and lastPlayer == "black" then
				lastPlayer = "white"
			end
		end)
	end
	function GameManager:stopGame()
		self.gameRunning = false
		self.renderer:destroy()
	end
end
return {
	selectSquareGlobal = selectSquareGlobal,
	GameManager = GameManager,
}
