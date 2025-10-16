-- Compiled with roblox-ts v3.0.0
local BOARD_ROWS = 8
local BOARD_COLS = 8
local ChessBoard
do
	ChessBoard = setmetatable({}, {
		__tostring = function()
			return "ChessBoard"
		end,
	})
	ChessBoard.__index = ChessBoard
	function ChessBoard.new(...)
		local self = setmetatable({}, ChessBoard)
		return self:constructor(...) or self
	end
	function ChessBoard:constructor()
		self.board = {}
		self.gameState = {
			board = self:createInitialBoard(),
			currentPlayer = "white",
			selectedSquare = nil,
			validMoves = {},
			moveHistory = {},
			isCheckmate = false,
			isStalemate = false,
			isCheck = false,
			enPassantTarget = nil,
			capturedByWhite = {},
			capturedByBlack = {},
		}
		self.board = self.gameState.board
	end
	function ChessBoard:createInitialBoard()
		local board = {}
		for row = 0, BOARD_ROWS - 1 do
			board[row + 1] = {}
			for col = 0, BOARD_COLS - 1 do
				board[row + 1][col + 1] = nil
			end
		end
		-- White pieces at bottom (rows 6-7)
		self:placePieceRow(board, 7, "white")
		for col = 0, BOARD_COLS - 1 do
			board[7][col + 1] = {
				type = "pawn",
				color = "white",
			}
		end
		-- Black pieces at top (rows 0-1)
		self:placePieceRow(board, 0, "black")
		for col = 0, BOARD_COLS - 1 do
			board[2][col + 1] = {
				type = "pawn",
				color = "black",
			}
		end
		return board
	end
	function ChessBoard:placePieceRow(board, row, color)
		local pieces = { "rook", "knight", "bishop", "queen", "king", "bishop", "knight", "rook" }
		for col = 0, BOARD_COLS - 1 do
			board[row + 1][col + 1] = {
				type = pieces[col + 1],
				color = color,
			}
		end
	end
	function ChessBoard:getBoard()
		return self.board
	end
	function ChessBoard:getGameState()
		return self.gameState
	end
	function ChessBoard:selectSquare(row, col)
		if row < 0 or row > 7 or col < 0 or col > 7 then
			return nil
		end
		local piece = self.board[row + 1][col + 1]
		if piece and piece.color == self.gameState.currentPlayer then
			self.gameState.selectedSquare = {
				row = row,
				col = col,
			}
			self.gameState.validMoves = self:getValidMoves(row, col)
		elseif self.gameState.selectedSquare and self:isValidMove(row, col) then
			self:makeMove(self.gameState.selectedSquare.row, self.gameState.selectedSquare.col, row, col)
			self.gameState.selectedSquare = nil
			self.gameState.validMoves = {}
		end
	end
	function ChessBoard:isValidMove(row, col)
		local validMoves = self.gameState.validMoves
		for _, move in validMoves do
			if move.row == row and move.col == col then
				return true
			end
		end
		return false
	end
	function ChessBoard:getValidMoves(row, col)
		local piece = self.board[row + 1][col + 1]
		if not piece then
			return {}
		end
		local moves = {}
		if piece.type == "pawn" then
			moves = self:getPawnMoves(row, col, piece.color)
		elseif piece.type == "knight" then
			moves = self:getKnightMoves(row, col, piece.color)
		elseif piece.type == "bishop" then
			moves = self:getBishopMoves(row, col, piece.color)
		elseif piece.type == "rook" then
			moves = self:getRookMoves(row, col, piece.color)
		elseif piece.type == "queen" then
			moves = self:getQueenMoves(row, col, piece.color)
		elseif piece.type == "king" then
			moves = self:getKingMoves(row, col, piece.color)
		end
		-- Filter out moves that would leave king in check
		local legalMoves = {}
		for _, move in moves do
			if self:doesntPutKingInCheck(row, col, move.row, move.col, piece.color) then
				table.insert(legalMoves, move)
			end
		end
		return legalMoves
	end
	function ChessBoard:doesntPutKingInCheck(fromRow, fromCol, toRow, toCol, color)
		-- Simulate the move
		local boardCopy = self:copyBoardForSimulation()
		local piece = boardCopy[fromRow + 1][fromCol + 1]
		if not piece then
			return false
		end
		boardCopy[toRow + 1][toCol + 1] = piece
		boardCopy[fromRow + 1][fromCol + 1] = nil
		-- Check if king is in check after the move
		local opponentColor = if color == "white" then "black" else "white"
		local kingPos = self:findKingInBoard(boardCopy, color)
		if not kingPos then
			return false
		end
		return not self:isSquareAttackedByColorInBoard(boardCopy, kingPos.row, kingPos.col, opponentColor)
	end
	function ChessBoard:getPawnMoves(row, col, color)
		local moves = {}
		local direction = if color == "white" then -1 else 1
		local startRow = if color == "white" then 6 else 1
		local nextRow = row + direction
		if nextRow >= 0 and nextRow <= 7 and not self.board[nextRow + 1][col + 1] then
			local _arg0 = {
				row = nextRow,
				col = col,
			}
			table.insert(moves, _arg0)
			if row == startRow and not self.board[row + 2 * direction + 1][col + 1] then
				local _arg0_1 = {
					row = row + 2 * direction,
					col = col,
				}
				table.insert(moves, _arg0_1)
			end
		end
		for colOffset = -1, 1, 2 do
			local captureCol = col + colOffset
			local captureRow = row + direction
			if captureCol >= 0 and captureCol <= 7 and captureRow >= 0 and captureRow <= 7 then
				local target = self.board[captureRow + 1][captureCol + 1]
				if target and target.color ~= color then
					local _arg0 = {
						row = captureRow,
						col = captureCol,
					}
					table.insert(moves, _arg0)
				end
			end
		end
		return moves
	end
	function ChessBoard:getKnightMoves(row, col, color)
		local moves = {}
		local offsets = { { -2, -1 }, { -2, 1 }, { -1, -2 }, { -1, 2 }, { 1, -2 }, { 1, 2 }, { 2, -1 }, { 2, 1 } }
		for _, offset in offsets do
			local newRow = row + offset[1]
			local newCol = col + offset[2]
			if newRow >= 0 and newRow <= 7 and newCol >= 0 and newCol <= 7 then
				local target = self.board[newRow + 1][newCol + 1]
				if not target or target.color ~= color then
					local _arg0 = {
						row = newRow,
						col = newCol,
					}
					table.insert(moves, _arg0)
				end
			end
		end
		return moves
	end
	function ChessBoard:getBishopMoves(row, col, color)
		return self:getDirectionalMoves(row, col, color, { { -1, -1 }, { -1, 1 }, { 1, -1 }, { 1, 1 } })
	end
	function ChessBoard:getRookMoves(row, col, color)
		return self:getDirectionalMoves(row, col, color, { { -1, 0 }, { 1, 0 }, { 0, -1 }, { 0, 1 } })
	end
	function ChessBoard:getQueenMoves(row, col, color)
		return self:getDirectionalMoves(row, col, color, { { -1, -1 }, { -1, 0 }, { -1, 1 }, { 0, -1 }, { 0, 1 }, { 1, -1 }, { 1, 0 }, { 1, 1 } })
	end
	function ChessBoard:getKingMoves(row, col, color)
		local moves = {}
		for rowOffset = -1, 1 do
			for colOffset = -1, 1 do
				if rowOffset == 0 and colOffset == 0 then
					continue
				end
				local newRow = row + rowOffset
				local newCol = col + colOffset
				if newRow >= 0 and newRow <= 7 and newCol >= 0 and newCol <= 7 then
					local target = self.board[newRow + 1][newCol + 1]
					if not target or target.color ~= color then
						local _arg0 = {
							row = newRow,
							col = newCol,
						}
						table.insert(moves, _arg0)
					end
				end
			end
		end
		return moves
	end
	function ChessBoard:getDirectionalMoves(row, col, color, directions)
		local moves = {}
		for _, dir in directions do
			local rowDir = dir[1]
			local colDir = dir[2]
			local newRow = row + rowDir
			local newCol = col + colDir
			while newRow >= 0 and newRow <= 7 and newCol >= 0 and newCol <= 7 do
				local target = self.board[newRow + 1][newCol + 1]
				if not target then
					local _arg0 = {
						row = newRow,
						col = newCol,
					}
					table.insert(moves, _arg0)
				elseif target.color ~= color then
					local _arg0 = {
						row = newRow,
						col = newCol,
					}
					table.insert(moves, _arg0)
					break
				else
					break
				end
				newRow += rowDir
				newCol += colDir
			end
		end
		return moves
	end
	function ChessBoard:makeMove(fromRow, fromCol, toRow, toCol)
		local piece = self.board[fromRow + 1][fromCol + 1]
		if not piece then
			return nil
		end
		local move = {
			from = {
				row = fromRow,
				col = fromCol,
			},
			to = {
				row = toRow,
				col = toCol,
			},
		}
		local target = self.board[toRow + 1][toCol + 1]
		if target then
			move.capturedPiece = target
			-- Track captured pieces
			if piece.color == "white" then
				local _exp = self.gameState.capturedByWhite
				table.insert(_exp, target)
			else
				local _exp = self.gameState.capturedByBlack
				table.insert(_exp, target)
			end
		end
		self.board[toRow + 1][toCol + 1] = piece
		self.board[fromRow + 1][fromCol + 1] = nil
		local _exp = self.gameState.moveHistory
		table.insert(_exp, move)
		self.gameState.currentPlayer = if self.gameState.currentPlayer == "white" then "black" else "white"
		self.gameState.enPassantTarget = nil
	end
	function ChessBoard:isLegalMove(fromRow, fromCol, toRow, toCol)
		local piece = self.board[fromRow + 1][fromCol + 1]
		if not piece or piece.color ~= self.gameState.currentPlayer then
			return false
		end
		local validMoves = self:getValidMoves(fromRow, fromCol)
		for _, move in validMoves do
			if move.row == toRow and move.col == toCol then
				return true
			end
		end
		return false
	end
	function ChessBoard:getPossibleMovesForColor(color)
		local moves = {}
		for row = 0, BOARD_ROWS - 1 do
			for col = 0, BOARD_COLS - 1 do
				local piece = self.board[row + 1][col + 1]
				if piece and piece.color == color then
					local validMoves = self:getValidMoves(row, col)
					for _, move in validMoves do
						local _arg0 = {
							from = {
								row = row,
								col = col,
							},
							to = move,
						}
						table.insert(moves, _arg0)
					end
				end
			end
		end
		return moves
	end
	function ChessBoard:findKing(color)
		for row = 0, BOARD_ROWS - 1 do
			for col = 0, BOARD_COLS - 1 do
				local piece = self.board[row + 1][col + 1]
				if piece and piece.color == color and piece.type == "king" then
					return {
						row = row,
						col = col,
					}
				end
			end
		end
		return nil
	end
	function ChessBoard:isSquareAttackedByColor(row, col, attackingColor)
		-- Check all pieces of attacking color to see if they can attack this square
		for r = 0, BOARD_ROWS - 1 do
			for c = 0, BOARD_COLS - 1 do
				local piece = self.board[r + 1][c + 1]
				if piece and piece.color == attackingColor then
					local moves = self:getValidMovesForPiece(r, c, piece)
					for _, move in moves do
						if move.row == row and move.col == col then
							return true
						end
					end
				end
			end
		end
		return false
	end
	function ChessBoard:getValidMovesForPiece(row, col, piece)
		if piece.type == "pawn" then
			return self:getPawnMoves(row, col, piece.color)
		elseif piece.type == "knight" then
			return self:getKnightMoves(row, col, piece.color)
		elseif piece.type == "bishop" then
			return self:getBishopMoves(row, col, piece.color)
		elseif piece.type == "rook" then
			return self:getRookMoves(row, col, piece.color)
		elseif piece.type == "queen" then
			return self:getQueenMoves(row, col, piece.color)
		elseif piece.type == "king" then
			return self:getKingMoves(row, col, piece.color)
		end
		return {}
	end
	function ChessBoard:isInCheck(color)
		local kingPos = self:findKing(color)
		if not kingPos then
			return false
		end
		local opponentColor = if color == "white" then "black" else "white"
		return self:isSquareAttackedByColor(kingPos.row, kingPos.col, opponentColor)
	end
	function ChessBoard:isInCheckmate(color)
		-- Must be in check first
		if not self:isInCheck(color) then
			return false
		end
		-- Check if there are any legal moves that get out of check
		local moves = self:getPossibleMovesForColor(color)
		for _, move in moves do
			-- Try the move
			local boardCopy = self:copyBoardForSimulation()
			local piece = boardCopy[move.from.row + 1][move.from.col + 1]
			if not piece then
				continue
			end
			boardCopy[move.to.row + 1][move.to.col + 1] = piece
			boardCopy[move.from.row + 1][move.from.col + 1] = nil
			-- Check if still in check
			local opponentColor = if color == "white" then "black" else "white"
			local kingPos = self:findKingInBoard(boardCopy, color)
			if kingPos and not self:isSquareAttackedByColorInBoard(boardCopy, kingPos.row, kingPos.col, opponentColor) then
				-- Found a legal move that escapes check
				return false
			end
		end
		-- No legal moves to escape check = checkmate
		return true
	end
	function ChessBoard:copyBoardForSimulation()
		local newBoard = {}
		for row = 0, BOARD_ROWS - 1 do
			newBoard[row + 1] = {}
			for col = 0, BOARD_COLS - 1 do
				local piece = self.board[row + 1][col + 1]
				if piece then
					local _object = table.clone(piece)
					setmetatable(_object, nil)
					newBoard[row + 1][col + 1] = _object
				else
					newBoard[row + 1][col + 1] = nil
				end
			end
		end
		return newBoard
	end
	function ChessBoard:findKingInBoard(board, color)
		for row = 0, BOARD_ROWS - 1 do
			for col = 0, BOARD_COLS - 1 do
				local piece = board[row + 1][col + 1]
				if piece and piece.color == color and piece.type == "king" then
					return {
						row = row,
						col = col,
					}
				end
			end
		end
		return nil
	end
	function ChessBoard:isSquareAttackedByColorInBoard(board, row, col, attackingColor)
		for r = 0, BOARD_ROWS - 1 do
			for c = 0, BOARD_COLS - 1 do
				local piece = board[r + 1][c + 1]
				if piece and piece.color == attackingColor then
					local moves = self:getValidMovesForPieceInBoard(board, r, c, piece)
					for _, move in moves do
						if move.row == row and move.col == col then
							return true
						end
					end
				end
			end
		end
		return false
	end
	function ChessBoard:getValidMovesForPieceInBoard(board, row, col, piece)
		-- Helper for checkmate detection - uses provided board instead of this.board
		if piece.type == "pawn" then
			return self:getPawnMovesInBoard(board, row, col, piece.color)
		elseif piece.type == "knight" then
			return self:getKnightMovesInBoard(board, row, col, piece.color)
		elseif piece.type == "bishop" then
			return self:getBishopMovesInBoard(board, row, col, piece.color)
		elseif piece.type == "rook" then
			return self:getRookMovesInBoard(board, row, col, piece.color)
		elseif piece.type == "queen" then
			return self:getQueenMovesInBoard(board, row, col, piece.color)
		elseif piece.type == "king" then
			return self:getKingMovesInBoard(board, row, col, piece.color)
		end
		return {}
	end
	function ChessBoard:getPawnMovesInBoard(board, row, col, color)
		local moves = {}
		local direction = if color == "white" then -1 else 1
		local startRow = if color == "white" then 6 else 1
		local nextRow = row + direction
		if nextRow >= 0 and nextRow <= 7 and not board[nextRow + 1][col + 1] then
			local _arg0 = {
				row = nextRow,
				col = col,
			}
			table.insert(moves, _arg0)
			if row == startRow and not board[row + 2 * direction + 1][col + 1] then
				local _arg0_1 = {
					row = row + 2 * direction,
					col = col,
				}
				table.insert(moves, _arg0_1)
			end
		end
		for colOffset = -1, 1, 2 do
			local captureCol = col + colOffset
			local captureRow = row + direction
			if captureCol >= 0 and captureCol <= 7 and captureRow >= 0 and captureRow <= 7 then
				local target = board[captureRow + 1][captureCol + 1]
				if target and target.color ~= color then
					local _arg0 = {
						row = captureRow,
						col = captureCol,
					}
					table.insert(moves, _arg0)
				end
			end
		end
		return moves
	end
	function ChessBoard:getKnightMovesInBoard(board, row, col, color)
		local moves = {}
		local offsets = { { -2, -1 }, { -2, 1 }, { -1, -2 }, { -1, 2 }, { 1, -2 }, { 1, 2 }, { 2, -1 }, { 2, 1 } }
		for _, offset in offsets do
			local newRow = row + offset[1]
			local newCol = col + offset[2]
			if newRow >= 0 and newRow <= 7 and newCol >= 0 and newCol <= 7 then
				local target = board[newRow + 1][newCol + 1]
				if not target or target.color ~= color then
					local _arg0 = {
						row = newRow,
						col = newCol,
					}
					table.insert(moves, _arg0)
				end
			end
		end
		return moves
	end
	function ChessBoard:getBishopMovesInBoard(board, row, col, color)
		return self:getDirectionalMovesInBoard(board, row, col, color, { { -1, -1 }, { -1, 1 }, { 1, -1 }, { 1, 1 } })
	end
	function ChessBoard:getRookMovesInBoard(board, row, col, color)
		return self:getDirectionalMovesInBoard(board, row, col, color, { { -1, 0 }, { 1, 0 }, { 0, -1 }, { 0, 1 } })
	end
	function ChessBoard:getQueenMovesInBoard(board, row, col, color)
		return self:getDirectionalMovesInBoard(board, row, col, color, { { -1, -1 }, { -1, 0 }, { -1, 1 }, { 0, -1 }, { 0, 1 }, { 1, -1 }, { 1, 0 }, { 1, 1 } })
	end
	function ChessBoard:getKingMovesInBoard(board, row, col, color)
		local moves = {}
		for rowOffset = -1, 1 do
			for colOffset = -1, 1 do
				if rowOffset == 0 and colOffset == 0 then
					continue
				end
				local newRow = row + rowOffset
				local newCol = col + colOffset
				if newRow >= 0 and newRow <= 7 and newCol >= 0 and newCol <= 7 then
					local target = board[newRow + 1][newCol + 1]
					if not target or target.color ~= color then
						local _arg0 = {
							row = newRow,
							col = newCol,
						}
						table.insert(moves, _arg0)
					end
				end
			end
		end
		return moves
	end
	function ChessBoard:getDirectionalMovesInBoard(board, row, col, color, directions)
		local moves = {}
		for _, dir in directions do
			local rowDir = dir[1]
			local colDir = dir[2]
			local newRow = row + rowDir
			local newCol = col + colDir
			while newRow >= 0 and newRow <= 7 and newCol >= 0 and newCol <= 7 do
				local target = board[newRow + 1][newCol + 1]
				if not target then
					local _arg0 = {
						row = newRow,
						col = newCol,
					}
					table.insert(moves, _arg0)
				elseif target.color ~= color then
					local _arg0 = {
						row = newRow,
						col = newCol,
					}
					table.insert(moves, _arg0)
					break
				else
					break
				end
				newRow += rowDir
				newCol += colDir
			end
		end
		return moves
	end
end
return {
	ChessBoard = ChessBoard,
}
