-- Compiled with roblox-ts v3.0.0
local TS = require(game:GetService("ReplicatedStorage"):WaitForChild("rbxts_include"):WaitForChild("RuntimeLib"))
local ChessBoard = TS.import(script, game:GetService("ServerScriptService"), "Shared", "board").ChessBoard
local MAX_VALUE = 999999
local MIN_VALUE = -999999
local ChessAI
do
	ChessAI = setmetatable({}, {
		__tostring = function()
			return "ChessAI"
		end,
	})
	ChessAI.__index = ChessAI
	function ChessAI.new(...)
		local self = setmetatable({}, ChessAI)
		return self:constructor(...) or self
	end
	function ChessAI:constructor()
		self.maxDepth = 3
	end
	function ChessAI:findBestMove(board)
		local moves = board:getPossibleMovesForColor("black")
		local isEmpty = true
		for _, _m in moves do
			isEmpty = false
			break
		end
		if isEmpty then
			return nil
		end
		local bestMoves = {}
		local bestScore = MIN_VALUE
		for _, move in moves do
			local boardCopy = self:copyBoard(board)
			local boardArrayBefore = board:getBoard()
			local targetPiece = boardArrayBefore[move.to.row + 1][move.to.col + 1]
			self:makeMove(boardCopy, move)
			-- Immediate capture bonus - if we're taking material, add it directly
			local captureBonus = 0
			if targetPiece then
				local captureValues = {
					pawn = 100,
					knight = 300,
					bishop = 300,
					rook = 500,
					queen = 900,
					king = 10000,
				}
				local _condition = captureValues[targetPiece.type]
				if not (_condition ~= 0 and _condition == _condition and _condition) then
					_condition = 0
				end
				captureBonus = _condition * 0.5
			end
			-- After black moves, it's white's turn (minimizing = false in the next layer means white is playing)
			local score = self:minimax(boardCopy, self.maxDepth - 1, MIN_VALUE, MAX_VALUE, false) + captureBonus + math.random() * 0.1
			if score > bestScore then
				bestScore = score
				bestMoves = { move }
			elseif score == bestScore then
				table.insert(bestMoves, move)
			end
		end
		-- Pick randomly from equally good moves
		local moveCount = 0
		for _, _ in bestMoves do
			moveCount += 1
		end
		if moveCount > 0 then
			local randomIndex = math.floor(math.random() * moveCount)
			local currentIndex = 0
			for _, move in bestMoves do
				if currentIndex == randomIndex then
					return move
				end
				currentIndex += 1
			end
		end
		return nil
	end
	function ChessAI:minimax(board, depth, alpha, beta, isMaximizing)
		if depth == 0 then
			local score = self:evaluatePosition(board)
			return score
		end
		-- isMaximizing = true means it's BLACK's turn (AI maximizes)
		-- isMaximizing = false means it's WHITE's turn (player minimizes)
		local moves = board:getPossibleMovesForColor(if isMaximizing then "black" else "white")
		-- Check if no moves available
		local hasMoves = false
		for _, _ in moves do
			hasMoves = true
			break
		end
		if not hasMoves then
			-- No moves = game over, return evaluation
			return self:evaluatePosition(board)
		end
		if isMaximizing then
			-- BLACK's turn - maximize score
			local maxEval = MIN_VALUE
			for _, move in moves do
				local boardCopy = self:copyBoard(board)
				self:makeMove(boardCopy, move)
				-- After black moves, it's white's turn (false)
				local evaluation = self:minimax(boardCopy, depth - 1, alpha, beta, false)
				maxEval = math.max(maxEval, evaluation)
				alpha = math.max(alpha, evaluation)
				if beta <= alpha then
					break
				end
			end
			return maxEval
		else
			-- WHITE's turn - minimize score
			local minEval = MAX_VALUE
			for _, move in moves do
				local boardCopy = self:copyBoard(board)
				self:makeMove(boardCopy, move)
				-- After white moves, it's black's turn (true)
				local evaluation = self:minimax(boardCopy, depth - 1, alpha, beta, true)
				minEval = math.min(minEval, evaluation)
				beta = math.min(beta, evaluation)
				if beta <= alpha then
					break
				end
			end
			return minEval
		end
	end
	function ChessAI:makeMove(board, move)
		board:selectSquare(move.from.row, move.from.col)
		board:selectSquare(move.to.row, move.to.col)
	end
	function ChessAI:evaluatePosition(board)
		local boardArray = board:getBoard()
		local score = 0
		local pieceValues = {
			pawn = 100,
			knight = 300,
			bishop = 325,
			rook = 500,
			queen = 900,
			king = 10000,
		}
		for row = 0, 7 do
			for col = 0, 7 do
				local piece = boardArray[row + 1][col + 1]
				if piece then
					local value = pieceValues[piece.type]
					-- Add positional bonuses
					if piece.type == "pawn" then
						-- Pawns are better when advanced
						if piece.color == "black" then
							value += row * 3
						else
							value += (7 - row) * 3
						end
					elseif piece.type == "knight" or piece.type == "bishop" then
						-- Knights and bishops better in center and developed
						local centerDistance = math.abs(3.5 - row) + math.abs(3.5 - col)
						value += (7 - centerDistance) * 3
						-- Bonus for development
						if piece.color == "black" and row > 1 then
							value += 20
						elseif piece.color == "white" and row < 6 then
							value += 20
						end
					elseif piece.type == "rook" then
						-- Rooks on open files are good
						local pawnCount = 0
						for r = 0, 7 do
							local p = boardArray[r + 1][col + 1]
							if p and p.type == "pawn" then
								pawnCount += 1
							end
						end
						if pawnCount == 0 then
							value += 30
						end
					end
					-- BLACK is maximizing (positive is good for black)
					-- WHITE is minimizing (negative is bad for black)
					if piece.color == "black" then
						score += value
					else
						score -= value
					end
				end
			end
		end
		return score
	end
	function ChessAI:copyBoard(board)
		local newBoard = ChessBoard.new()
		local originalBoard = board:getBoard()
		local newBoardArray = newBoard:getBoard()
		for row = 0, 7 do
			for col = 0, 7 do
				local piece = originalBoard[row + 1][col + 1]
				if piece then
					local _object = table.clone(piece)
					setmetatable(_object, nil)
					newBoardArray[row + 1][col + 1] = _object
				else
					newBoardArray[row + 1][col + 1] = nil
				end
			end
		end
		return newBoard
	end
end
return {
	ChessAI = ChessAI,
}
