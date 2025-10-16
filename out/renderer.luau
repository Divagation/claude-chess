-- Compiled with roblox-ts v3.0.0
local SQUARE_SIZE = 2
local PIECE_HEIGHT = 0.5
local BOARD_Y_POSITION = 5
local BoardRenderer
do
	BoardRenderer = setmetatable({}, {
		__tostring = function()
			return "BoardRenderer"
		end,
	})
	BoardRenderer.__index = BoardRenderer
	function BoardRenderer.new(...)
		local self = setmetatable({}, BoardRenderer)
		return self:constructor(...) or self
	end
	function BoardRenderer:constructor(board, onSquareSelect)
		self.boardParts = {}
		self.pieceParts = {}
		self.highlightParts = {}
		self.capturedPieceParts = {}
		self.board = board
		self.onSquareSelect = onSquareSelect
		self.workspace = game:GetService("Workspace")
		self.boardContainer = Instance.new("Folder")
		self.boardContainer.Name = "ChessBoard"
		self.boardContainer.Parent = self.workspace
		self:createTable()
	end
	function BoardRenderer:createTable()
		-- Board center is at (7, 7) since board goes from 0-14 in X and Z
		local boardCenterX = 7
		local boardCenterZ = 7
		-- Create table surface under the board
		local tableTop = Instance.new("Part")
		tableTop.Name = "TableTop"
		tableTop.Size = Vector3.new(24, 1, 24)
		tableTop.Position = Vector3.new(boardCenterX, BOARD_Y_POSITION - 1, boardCenterZ)
		tableTop.Anchored = true
		tableTop.Color = Color3.fromRGB(101, 67, 33)
		tableTop.Material = Enum.Material.Wood
		tableTop.TopSurface = Enum.SurfaceType.Smooth
		tableTop.BottomSurface = Enum.SurfaceType.Smooth
		tableTop.Parent = self.boardContainer
		-- Create table legs (relative to board center)
		local legPositions = { Vector3.new(boardCenterX - 10, BOARD_Y_POSITION - 4, boardCenterZ - 10), Vector3.new(boardCenterX + 10, BOARD_Y_POSITION - 4, boardCenterZ - 10), Vector3.new(boardCenterX - 10, BOARD_Y_POSITION - 4, boardCenterZ + 10), Vector3.new(boardCenterX + 10, BOARD_Y_POSITION - 4, boardCenterZ + 10) }
		for _, pos in legPositions do
			local leg = Instance.new("Part")
			leg.Name = "TableLeg"
			leg.Size = Vector3.new(1, 6, 1)
			leg.Position = pos
			leg.Anchored = true
			leg.Color = Color3.fromRGB(101, 67, 33)
			leg.Material = Enum.Material.Wood
			leg.Parent = self.boardContainer
		end
	end
	function BoardRenderer:renderBoard(board, selectedSquare)
		local boardArray = board:getBoard()
		local gameState = board:getGameState()
		-- Track which piece positions should exist
		local activePieces = {}
		for row = 0, 7 do
			for col = 0, 7 do
				local squareKey = `{row}-{col}`
				local x = col * SQUARE_SIZE
				local z = row * SQUARE_SIZE
				local y = BOARD_Y_POSITION
				local isWhiteSquare = (row + col) % 2 == 0
				local square = self.boardParts[squareKey]
				if not square then
					square = Instance.new("Part")
					square.Name = `Square_{squareKey}`
					square.Size = Vector3.new(SQUARE_SIZE, 0.2, SQUARE_SIZE)
					square.CanCollide = false
					square.Anchored = true
					square.CFrame = CFrame.new(x, y, z)
					square.TopSurface = Enum.SurfaceType.Smooth
					square.BottomSurface = Enum.SurfaceType.Smooth
					square.Parent = self.boardContainer
					local _boardParts = self.boardParts
					local _square = square
					_boardParts[squareKey] = _square
					-- Add click detector to board square
					local clickDetector = Instance.new("ClickDetector")
					clickDetector.MaxActivationDistance = 100
					clickDetector.Parent = square
					clickDetector.MouseClick:Connect(function()
						self.onSquareSelect(row, col)
					end)
				end
				-- Highlight selected square or use normal colors
				local isSelectedSquare = selectedSquare and selectedSquare.row == row and selectedSquare.col == col
				if isSelectedSquare then
					square.Color = Color3.fromRGB(255, 255, 100)
				else
					square.Color = if isWhiteSquare then Color3.fromRGB(240, 217, 181) else Color3.fromRGB(181, 136, 99)
				end
				local piece = boardArray[row + 1][col + 1]
				local pieceKey = `piece-{row}-{col}`
				if piece then
					activePieces[pieceKey] = true
					local isSelected = selectedSquare and selectedSquare.row == row and selectedSquare.col == col
					local isKingInCheck = piece.type == "king" and board:isInCheck(piece.color)
					self:renderPiece(piece, row, col, isSelected, isKingInCheck)
				end
			end
		end
		-- Remove pieces that are no longer on the board
		for key, part in self.pieceParts do
			if not (activePieces[key] ~= nil) then
				part:Destroy()
				self.pieceParts[key] = nil
			end
		end
		-- Render captured pieces
		self:renderCapturedPieces(gameState.capturedByWhite, gameState.capturedByBlack)
	end
	function BoardRenderer:renderPiece(piece, row, col, isSelected, isKingInCheck)
		if isSelected == nil then
			isSelected = false
		end
		if isKingInCheck == nil then
			isKingInCheck = false
		end
		local pieceKey = `piece-{row}-{col}`
		local x = col * SQUARE_SIZE
		local z = row * SQUARE_SIZE
		local y = BOARD_Y_POSITION + PIECE_HEIGHT / 2
		-- Always recreate the piece to avoid cache issues
		local existingPiece = self.pieceParts[pieceKey]
		if existingPiece then
			existingPiece:Destroy()
			self.pieceParts[pieceKey] = nil
		end
		local piecePart = Instance.new("Part")
		piecePart.Name = `{piece.color}_{piece.type}`
		piecePart.CanCollide = false
		piecePart.Anchored = true
		piecePart.CFrame = CFrame.new(x, y, z)
		piecePart.TopSurface = Enum.SurfaceType.Smooth
		piecePart.BottomSurface = Enum.SurfaceType.Smooth
		piecePart.Parent = self.boardContainer
		self.pieceParts[pieceKey] = piecePart
		-- Add click detector to piece
		local clickDetector = Instance.new("ClickDetector")
		clickDetector.MaxActivationDistance = 100
		clickDetector.Parent = piecePart
		clickDetector.MouseClick:Connect(function()
			self.onSquareSelect(row, col)
		end)
		-- Highlight piece based on state
		if isKingInCheck then
			piecePart.Color = Color3.fromRGB(255, 0, 0)
		elseif isSelected then
			piecePart.Color = Color3.fromRGB(255, 255, 0)
		else
			local color = if piece.color == "white" then Color3.fromRGB(255, 255, 255) else Color3.fromRGB(50, 50, 50)
			piecePart.Color = color
		end
		local size = Vector3.new(0.4, PIECE_HEIGHT, 0.4)
		if piece.type == "king" then
			size = Vector3.new(0.5, PIECE_HEIGHT * 1.2, 0.5)
		elseif piece.type == "queen" then
			size = Vector3.new(0.45, PIECE_HEIGHT * 1.15, 0.45)
		elseif piece.type == "rook" then
			size = Vector3.new(0.4, PIECE_HEIGHT, 0.4)
		elseif piece.type == "bishop" then
			size = Vector3.new(0.35, PIECE_HEIGHT * 1.1, 0.35)
		elseif piece.type == "knight" then
			size = Vector3.new(0.38, PIECE_HEIGHT * 0.9, 0.38)
		elseif piece.type == "pawn" then
			size = Vector3.new(0.3, PIECE_HEIGHT * 0.8, 0.3)
		end
		piecePart.Size = size
		piecePart.CFrame = CFrame.new(x, y, z)
	end
	function BoardRenderer:highlightValidMoves(validMoves)
		for _, highlight in self.highlightParts do
			highlight:Destroy()
		end
		self.highlightParts = {}
		for _, move in validMoves do
			local x = move.col * SQUARE_SIZE
			local z = move.row * SQUARE_SIZE
			local y = BOARD_Y_POSITION + 0.15
			-- Create green outline box around the square using a selection box
			local outlineBox = Instance.new("Part")
			outlineBox.Name = `ValidMove_{move.row}-{move.col}`
			outlineBox.Size = Vector3.new(SQUARE_SIZE - 0.05, 0.01, SQUARE_SIZE - 0.05)
			outlineBox.CanCollide = false
			outlineBox.Anchored = true
			outlineBox.CFrame = CFrame.new(x, y, z)
			outlineBox.Transparency = 1
			outlineBox.Parent = self.boardContainer
			local _exp = self.highlightParts
			table.insert(_exp, outlineBox)
			-- Add a selection box outline - this is what creates the green outline
			local selectionBox = Instance.new("SelectionBox")
			selectionBox.LineThickness = 0.08
			selectionBox.Color3 = Color3.fromRGB(0, 255, 0)
			selectionBox.Adornee = outlineBox
			selectionBox.Parent = outlineBox
			-- Add click detector to the outline
			local clickDetector = Instance.new("ClickDetector")
			clickDetector.MaxActivationDistance = 100
			clickDetector.Parent = outlineBox
			clickDetector.MouseClick:Connect(function()
				self.onSquareSelect(move.row, move.col)
			end)
		end
	end
	function BoardRenderer:renderCapturedPieces(capturedByWhite, capturedByBlack)
		-- Clear old captured piece displays
		for _, part in self.capturedPieceParts do
			part:Destroy()
		end
		self.capturedPieceParts = {}
		-- White captures black pieces -> show black pieces on black's side (right/top)
		local whiteIndex = 0
		for _, piece in capturedByWhite do
			-- piece.color is "black" because white captured black's pieces
			local capturedPart = Instance.new("Part")
			capturedPart.Name = `Captured_{piece.color}_{piece.type}`
			capturedPart.Anchored = true
			capturedPart.CanCollide = false
			-- Match size to piece type
			local size = Vector3.new(0.3, PIECE_HEIGHT * 0.6, 0.3)
			if piece.type == "king" then
				size = Vector3.new(0.4, PIECE_HEIGHT * 0.7, 0.4)
			elseif piece.type == "queen" then
				size = Vector3.new(0.35, PIECE_HEIGHT * 0.65, 0.35)
			elseif piece.type == "pawn" then
				size = Vector3.new(0.25, PIECE_HEIGHT * 0.5, 0.25)
			end
			capturedPart.Size = size
			-- Position on right side (black's side) - sitting on table
			local xPos = 18
			local zPos = whiteIndex * 0.5
			capturedPart.Position = Vector3.new(xPos, BOARD_Y_POSITION - 0.5 + (size.Y / 2), zPos)
			local color = if piece.color == "white" then Color3.fromRGB(255, 255, 255) else Color3.fromRGB(50, 50, 50)
			capturedPart.Color = color
			capturedPart.Parent = self.boardContainer
			local _exp = self.capturedPieceParts
			table.insert(_exp, capturedPart)
			whiteIndex += 1
		end
		-- Black captures white pieces -> show white pieces on white's side (left/bottom)
		local blackIndex = 0
		for _, piece in capturedByBlack do
			-- piece.color is "white" because black captured white's pieces
			local capturedPart = Instance.new("Part")
			capturedPart.Name = `Captured_{piece.color}_{piece.type}`
			capturedPart.Anchored = true
			capturedPart.CanCollide = false
			-- Match size to piece type
			local size = Vector3.new(0.3, PIECE_HEIGHT * 0.6, 0.3)
			if piece.type == "king" then
				size = Vector3.new(0.4, PIECE_HEIGHT * 0.7, 0.4)
			elseif piece.type == "queen" then
				size = Vector3.new(0.35, PIECE_HEIGHT * 0.65, 0.35)
			elseif piece.type == "pawn" then
				size = Vector3.new(0.25, PIECE_HEIGHT * 0.5, 0.25)
			end
			capturedPart.Size = size
			-- Position on left side (white's side) - sitting on table
			local xPos = -4
			local zPos = 14 - (blackIndex * 0.5)
			capturedPart.Position = Vector3.new(xPos, BOARD_Y_POSITION - 0.5 + (size.Y / 2), zPos)
			local color = if piece.color == "white" then Color3.fromRGB(255, 255, 255) else Color3.fromRGB(50, 50, 50)
			capturedPart.Color = color
			capturedPart.Parent = self.boardContainer
			local _exp = self.capturedPieceParts
			table.insert(_exp, capturedPart)
			blackIndex += 1
		end
	end
	function BoardRenderer:destroy()
		self.boardContainer:Destroy()
	end
end
return {
	BoardRenderer = BoardRenderer,
}
