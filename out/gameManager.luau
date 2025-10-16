-- Compiled with roblox-ts v3.0.0
local TS = require(game:GetService("ReplicatedStorage"):WaitForChild("rbxts_include"):WaitForChild("RuntimeLib"))
local ChessBoard = TS.import(script, game:GetService("ReplicatedStorage"), "ChessGame", "board").ChessBoard
local BoardRenderer = TS.import(script, game:GetService("ReplicatedStorage"), "ChessGame", "renderer").BoardRenderer
local ChessAI = TS.import(script, game:GetService("ReplicatedStorage"), "ChessGame", "ai").ChessAI
local GameUI = TS.import(script, game:GetService("ReplicatedStorage"), "ChessGame", "gameUI").GameUI
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
		self.ui = GameUI.new()
		currentGameManager = self
		self:updateDisplay()
	end
	function GameManager:getUI()
		return self.ui
	end
	function GameManager:updateDisplay()
		local gameState = self.board:getGameState()
		-- Check for checkmate
		if self.board:isInCheckmate(gameState.currentPlayer) then
			local winner = if gameState.currentPlayer == "white" then "black" else "white"
			local isPlayerWinner = winner == "white"
			print(`CHECKMATE! {if winner == "white" then "White" else "Black"} wins!`)
			self.ui:showCheckmate(winner, isPlayerWinner)
			self.gameRunning = false
		elseif self.board:isInCheck(gameState.currentPlayer) then
			print(`{if gameState.currentPlayer == "white" then "White" else "Black"} is in CHECK!`)
			self.ui:showCheck(gameState.currentPlayer)
		end
		self.renderer:renderBoard(self.board, gameState.selectedSquare)
		self.renderer:highlightValidMoves(gameState.validMoves)
	end
	function GameManager:selectSquare(row, col)
		local gameState = self.board:getGameState()
		-- Track if this is a piece selection or a move
		if gameState.selectedSquare then
			-- This is a move attempt
			self.lastMoveFrom = {
				row = gameState.selectedSquare.row,
				col = gameState.selectedSquare.col,
			}
			self.lastMoveTo = {
				row = row,
				col = col,
			}
		end
		local previousPlayer = gameState.currentPlayer
		self.board:selectSquare(row, col)
		local newGameState = self.board:getGameState()
		-- If the player changed, a move was made
		if newGameState.currentPlayer ~= previousPlayer and self.lastMoveFrom and self.lastMoveTo then
			local piece = self.board:getBoard()[self.lastMoveTo.row + 1][self.lastMoveTo.col + 1]
			if piece then
				-- Convert board coordinates to chess notation
				local fromNotation = self:coordinatesToNotation(self.lastMoveFrom.row, self.lastMoveFrom.col)
				local toNotation = self:coordinatesToNotation(self.lastMoveTo.row, self.lastMoveTo.col)
				self.ui:addMove(fromNotation, toNotation, piece.type, previousPlayer)
			end
		end
		self:updateDisplay()
	end
	function GameManager:coordinatesToNotation(row, col)
		local files = { "a", "b", "c", "d", "e", "f", "g", "h" }
		local ranks = { "8", "7", "6", "5", "4", "3", "2", "1" }
		return `{files[col + 1]}{ranks[row + 1]}`
	end
	function GameManager:makeAIMove()
		local currentPlayer = self.board:getGameState().currentPlayer
		if currentPlayer ~= "black" then
			return nil
		end
		local move = self.ai:findBestMove(self.board)
		if move then
			print(`AI moved from [{move.from.row},{move.from.col}] to [{move.to.row},{move.to.col}]`)
			-- selectSquare will automatically track and add the move to UI
			self:selectSquare(move.from.row, move.from.col)
			self:selectSquare(move.to.row, move.to.col)
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
		self.ui:destroy()
	end
end
return {
	selectSquareGlobal = selectSquareGlobal,
	GameManager = GameManager,
}
