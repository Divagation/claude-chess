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
		-- Clear any existing chess board to prevent conflicts
		local existingBoard = self.workspace:FindFirstChild("ChessBoard")
		if existingBoard then
			existingBoard:Destroy()
		end
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
		tableTop.Position = Vector3.new(boardCenterX, BOARD_Y_POSITION - 0.65, boardCenterZ)
		tableTop.Anchored = true
		tableTop.Color = Color3.fromRGB(101, 67, 33)
		tableTop.Material = Enum.Material.Wood
		tableTop.TopSurface = Enum.SurfaceType.Smooth
		tableTop.BottomSurface = Enum.SurfaceType.Smooth
		tableTop.Parent = self.boardContainer
		-- Create table legs (relative to board center)
		local legPositions = { Vector3.new(boardCenterX - 10, BOARD_Y_POSITION - 4.15, boardCenterZ - 10), Vector3.new(boardCenterX + 10, BOARD_Y_POSITION - 4.15, boardCenterZ - 10), Vector3.new(boardCenterX - 10, BOARD_Y_POSITION - 4.15, boardCenterZ + 10), Vector3.new(boardCenterX + 10, BOARD_Y_POSITION - 4.15, boardCenterZ + 10) }
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
		local baseY = BOARD_Y_POSITION + 0.2
		-- Check if piece already exists and matches current piece
		local existingPiece = self.pieceParts[pieceKey]
		if existingPiece and existingPiece.Name == `{piece.color}_{piece.type}` then
			-- Piece exists and hasn't changed - just update position if needed
			local primaryPart = existingPiece.PrimaryPart
			if primaryPart then
				local currentX = primaryPart.Position.X
				local currentZ = primaryPart.Position.Z
				-- Only update position if piece actually moved
				if math.abs(currentX - x) > 0.01 or math.abs(currentZ - z) > 0.01 then
					local offsetY = primaryPart.Position.Y - currentX
					existingPiece:SetPrimaryPartCFrame(CFrame.new(x, baseY + offsetY, z))
				end
			end
			return nil
		end
		-- Piece doesn't exist or changed type - create new one
		if existingPiece then
			existingPiece:Destroy()
		end
		local pieceModel = Instance.new("Model")
		pieceModel.Name = `{piece.color}_{piece.type}`
		pieceModel.Parent = self.boardContainer
		self.pieceParts[pieceKey] = pieceModel
		local pieceColor = if piece.color == "white" then Color3.fromRGB(255, 255, 255) else Color3.fromRGB(0, 0, 0)
		local _exp = piece.type
		repeat
			if _exp == "pawn" then
				self:createPawn(pieceModel, x, z, baseY, pieceColor)
				break
			end
			if _exp == "rook" then
				self:createRook(pieceModel, x, z, baseY, pieceColor)
				break
			end
			if _exp == "knight" then
				self:createKnight(pieceModel, x, z, baseY, pieceColor)
				break
			end
			if _exp == "bishop" then
				self:createBishop(pieceModel, x, z, baseY, pieceColor)
				break
			end
			if _exp == "queen" then
				self:createQueen(pieceModel, x, z, baseY, pieceColor)
				break
			end
			if _exp == "king" then
				self:createKing(pieceModel, x, z, baseY, pieceColor)
				break
			end
		until true
		-- Add click detector to the main part of the piece
		local primaryPart = pieceModel.PrimaryPart or pieceModel:FindFirstChildWhichIsA("Part")
		if primaryPart then
			local clickDetector = Instance.new("ClickDetector")
			clickDetector.MaxActivationDistance = 100
			clickDetector.Parent = primaryPart
			clickDetector.MouseClick:Connect(function()
				self.onSquareSelect(row, col)
			end)
		end
	end
	function BoardRenderer:createPawn(pieceModel, x, z, baseY, color)
		-- Simple cylinder pawn with rounded top
		local base = Instance.new("Part")
		base.Name = "Base"
		base.Shape = Enum.PartType.Cylinder
		base.Size = Vector3.new(0.3, 0.4, 0.3)
		base.Position = Vector3.new(x, baseY + 0.2, z)
		base.Anchored = true
		base.CanCollide = false
		base.Color = color
		base.Material = Enum.Material.Plastic
		base.Parent = pieceModel
		-- Rounded top
		local top = Instance.new("Part")
		top.Name = "Top"
		top.Shape = Enum.PartType.Ball
		top.Size = Vector3.new(0.25, 0.25, 0.25)
		top.Position = Vector3.new(x, baseY + 0.45, z)
		top.Anchored = true
		top.CanCollide = false
		top.Color = color
		top.Material = Enum.Material.Plastic
		top.Parent = pieceModel
		pieceModel.PrimaryPart = base
	end
	function BoardRenderer:createRook(pieceModel, x, z, baseY, color)
		-- Tower-style rook with battlements
		local base = Instance.new("Part")
		base.Name = "Base"
		base.Size = Vector3.new(0.4, 0.3, 0.4)
		base.Position = Vector3.new(x, baseY + 0.15, z)
		base.Anchored = true
		base.CanCollide = false
		base.Color = color
		base.Material = Enum.Material.Plastic
		base.Parent = pieceModel
		-- Tower body
		local tower = Instance.new("Part")
		tower.Name = "Tower"
		tower.Size = Vector3.new(0.3, 0.4, 0.3)
		tower.Position = Vector3.new(x, baseY + 0.5, z)
		tower.Anchored = true
		tower.CanCollide = false
		tower.Color = color
		tower.Material = Enum.Material.Plastic
		tower.Parent = pieceModel
		-- Battlements (4 smaller cubes on top corners)
		local battlement1 = Instance.new("Part")
		battlement1.Name = "Battlement_1"
		battlement1.Size = Vector3.new(0.1, 0.15, 0.1)
		battlement1.Position = Vector3.new(x - 0.12, baseY + 0.75, z + 0.12)
		battlement1.Anchored = true
		battlement1.CanCollide = false
		battlement1.Color = color
		battlement1.Material = Enum.Material.Plastic
		battlement1.Parent = pieceModel
		local battlement2 = Instance.new("Part")
		battlement2.Name = "Battlement_2"
		battlement2.Size = Vector3.new(0.1, 0.15, 0.1)
		battlement2.Position = Vector3.new(x + 0.12, baseY + 0.75, z + 0.12)
		battlement2.Anchored = true
		battlement2.CanCollide = false
		battlement2.Color = color
		battlement2.Material = Enum.Material.Plastic
		battlement2.Parent = pieceModel
		local battlement3 = Instance.new("Part")
		battlement3.Name = "Battlement_3"
		battlement3.Size = Vector3.new(0.1, 0.15, 0.1)
		battlement3.Position = Vector3.new(x - 0.12, baseY + 0.75, z - 0.12)
		battlement3.Anchored = true
		battlement3.CanCollide = false
		battlement3.Color = color
		battlement3.Material = Enum.Material.Plastic
		battlement3.Parent = pieceModel
		local battlement4 = Instance.new("Part")
		battlement4.Name = "Battlement_4"
		battlement4.Size = Vector3.new(0.1, 0.15, 0.1)
		battlement4.Position = Vector3.new(x + 0.12, baseY + 0.75, z - 0.12)
		battlement4.Anchored = true
		battlement4.CanCollide = false
		battlement4.Color = color
		battlement4.Material = Enum.Material.Plastic
		battlement4.Parent = pieceModel
		pieceModel.PrimaryPart = tower
	end
	function BoardRenderer:createKnight(pieceModel, x, z, baseY, color)
		-- Horse-shaped knight with long nose (original design, facing correct direction)
		local base = Instance.new("Part")
		base.Name = "Base"
		base.Size = Vector3.new(0.35, 0.25, 0.35)
		base.Position = Vector3.new(x, baseY + 0.125, z)
		base.Anchored = true
		base.CanCollide = false
		base.Color = color
		base.Material = Enum.Material.Plastic
		base.Parent = pieceModel
		-- Body
		local body = Instance.new("Part")
		body.Name = "Body"
		body.Size = Vector3.new(0.3, 0.3, 0.25)
		body.Position = Vector3.new(x, baseY + 0.4, z)
		body.Anchored = true
		body.CanCollide = false
		body.Color = color
		body.Material = Enum.Material.Plastic
		body.Parent = pieceModel
		-- Head (facing forward - white pieces face -Z, black pieces face +Z)
		local headOffset = if color == Color3.fromRGB(255, 255, 255) then -0.15 else 0.15
		local head = Instance.new("Part")
		head.Name = "Head"
		head.Size = Vector3.new(0.2, 0.25, 0.15)
		head.Position = Vector3.new(x, baseY + 0.45, z + headOffset)
		head.Anchored = true
		head.CanCollide = false
		head.Color = color
		head.Material = Enum.Material.Plastic
		head.Parent = pieceModel
		-- Long nose (the key feature!) pointing in correct direction
		local noseOffset = if color == Color3.fromRGB(255, 255, 255) then -0.3 else 0.3
		local nose = Instance.new("Part")
		nose.Name = "Nose"
		nose.Size = Vector3.new(0.25, 0.08, 0.08)
		nose.Position = Vector3.new(x, baseY + 0.42, z + noseOffset)
		nose.Anchored = true
		nose.CanCollide = false
		nose.Color = color
		nose.Material = Enum.Material.Plastic
		nose.Parent = pieceModel
		-- Ear
		local earOffset = if color == Color3.fromRGB(255, 255, 255) then -0.1 else 0.1
		local ear = Instance.new("Part")
		ear.Name = "Ear"
		ear.Size = Vector3.new(0.08, 0.15, 0.08)
		ear.Position = Vector3.new(x, baseY + 0.6, z + earOffset)
		ear.Anchored = true
		ear.CanCollide = false
		ear.Color = color
		ear.Material = Enum.Material.Plastic
		ear.Parent = pieceModel
		pieceModel.PrimaryPart = body
	end
	function BoardRenderer:createBishop(pieceModel, x, z, baseY, color)
		-- Bishop with pointed hat
		local base = Instance.new("Part")
		base.Name = "Base"
		base.Size = Vector3.new(0.35, 0.25, 0.35)
		base.Position = Vector3.new(x, baseY + 0.125, z)
		base.Anchored = true
		base.CanCollide = false
		base.Color = color
		base.Material = Enum.Material.Plastic
		base.Parent = pieceModel
		-- Body
		local body = Instance.new("Part")
		body.Name = "Body"
		body.Size = Vector3.new(0.25, 0.35, 0.25)
		body.Position = Vector3.new(x, baseY + 0.4, z)
		body.Anchored = true
		body.CanCollide = false
		body.Color = color
		body.Material = Enum.Material.Plastic
		body.Parent = pieceModel
		-- Pointed hat (cone shape using wedge)
		local hat = Instance.new("Part")
		hat.Name = "Hat"
		hat.Size = Vector3.new(0.2, 0.25, 0.2)
		hat.Position = Vector3.new(x, baseY + 0.65, z)
		hat.Anchored = true
		hat.CanCollide = false
		hat.Color = color
		hat.Material = Enum.Material.Plastic
		hat.Parent = pieceModel
		-- Small ball on top
		local ball = Instance.new("Part")
		ball.Name = "Ball"
		ball.Shape = Enum.PartType.Ball
		ball.Size = Vector3.new(0.1, 0.1, 0.1)
		ball.Position = Vector3.new(x, baseY + 0.8, z)
		ball.Anchored = true
		ball.CanCollide = false
		ball.Color = color
		ball.Material = Enum.Material.Plastic
		ball.Parent = pieceModel
		pieceModel.PrimaryPart = body
	end
	function BoardRenderer:createQueen(pieceModel, x, z, baseY, color)
		-- Queen with crown
		local base = Instance.new("Part")
		base.Name = "Base"
		base.Size = Vector3.new(0.4, 0.3, 0.4)
		base.Position = Vector3.new(x, baseY + 0.15, z)
		base.Anchored = true
		base.CanCollide = false
		base.Color = color
		base.Material = Enum.Material.Plastic
		base.Parent = pieceModel
		-- Body
		local body = Instance.new("Part")
		body.Name = "Body"
		body.Size = Vector3.new(0.35, 0.4, 0.35)
		body.Position = Vector3.new(x, baseY + 0.5, z)
		body.Anchored = true
		body.CanCollide = false
		body.Color = color
		body.Material = Enum.Material.Plastic
		body.Parent = pieceModel
		-- Crown base
		local crownBase = Instance.new("Part")
		crownBase.Name = "CrownBase"
		crownBase.Size = Vector3.new(0.3, 0.1, 0.3)
		crownBase.Position = Vector3.new(x, baseY + 0.75, z)
		crownBase.Anchored = true
		crownBase.CanCollide = false
		crownBase.Color = color
		crownBase.Material = Enum.Material.Plastic
		crownBase.Parent = pieceModel
		-- Crown points (5 points)
		local crownPoint1 = Instance.new("Part")
		crownPoint1.Name = "CrownPoint_1"
		crownPoint1.Size = Vector3.new(0.08, 0.15, 0.08)
		crownPoint1.Position = Vector3.new(x - 0.12, baseY + 0.85, z)
		crownPoint1.Anchored = true
		crownPoint1.CanCollide = false
		crownPoint1.Color = color
		crownPoint1.Material = Enum.Material.Plastic
		crownPoint1.Parent = pieceModel
		local crownPoint2 = Instance.new("Part")
		crownPoint2.Name = "CrownPoint_2"
		crownPoint2.Size = Vector3.new(0.08, 0.15, 0.08)
		crownPoint2.Position = Vector3.new(x - 0.06, baseY + 0.9, z)
		crownPoint2.Anchored = true
		crownPoint2.CanCollide = false
		crownPoint2.Color = color
		crownPoint2.Material = Enum.Material.Plastic
		crownPoint2.Parent = pieceModel
		local crownPoint3 = Instance.new("Part")
		crownPoint3.Name = "CrownPoint_3"
		crownPoint3.Size = Vector3.new(0.08, 0.15, 0.08)
		crownPoint3.Position = Vector3.new(x, baseY + 0.95, z)
		crownPoint3.Anchored = true
		crownPoint3.CanCollide = false
		crownPoint3.Color = color
		crownPoint3.Material = Enum.Material.Plastic
		crownPoint3.Parent = pieceModel
		local crownPoint4 = Instance.new("Part")
		crownPoint4.Name = "CrownPoint_4"
		crownPoint4.Size = Vector3.new(0.08, 0.15, 0.08)
		crownPoint4.Position = Vector3.new(x + 0.06, baseY + 0.9, z)
		crownPoint4.Anchored = true
		crownPoint4.CanCollide = false
		crownPoint4.Color = color
		crownPoint4.Material = Enum.Material.Plastic
		crownPoint4.Parent = pieceModel
		local crownPoint5 = Instance.new("Part")
		crownPoint5.Name = "CrownPoint_5"
		crownPoint5.Size = Vector3.new(0.08, 0.15, 0.08)
		crownPoint5.Position = Vector3.new(x + 0.12, baseY + 0.85, z)
		crownPoint5.Anchored = true
		crownPoint5.CanCollide = false
		crownPoint5.Color = color
		crownPoint5.Material = Enum.Material.Plastic
		crownPoint5.Parent = pieceModel
		pieceModel.PrimaryPart = body
	end
	function BoardRenderer:createKing(pieceModel, x, z, baseY, color)
		-- King with cross on top
		local base = Instance.new("Part")
		base.Name = "Base"
		base.Size = Vector3.new(0.45, 0.35, 0.45)
		base.Position = Vector3.new(x, baseY + 0.175, z)
		base.Anchored = true
		base.CanCollide = false
		base.Color = color
		base.Material = Enum.Material.Plastic
		base.Parent = pieceModel
		-- Body
		local body = Instance.new("Part")
		body.Name = "Body"
		body.Size = Vector3.new(0.4, 0.45, 0.4)
		body.Position = Vector3.new(x, baseY + 0.55, z)
		body.Anchored = true
		body.CanCollide = false
		body.Color = color
		body.Material = Enum.Material.Plastic
		body.Parent = pieceModel
		-- Crown base (wider than queen's)
		local crownBase = Instance.new("Part")
		crownBase.Name = "CrownBase"
		crownBase.Size = Vector3.new(0.35, 0.12, 0.35)
		crownBase.Position = Vector3.new(x, baseY + 0.85, z)
		crownBase.Anchored = true
		crownBase.CanCollide = false
		crownBase.Color = color
		crownBase.Material = Enum.Material.Plastic
		crownBase.Parent = pieceModel
		-- Cross vertical part
		local crossVertical = Instance.new("Part")
		crossVertical.Name = "CrossVertical"
		crossVertical.Size = Vector3.new(0.06, 0.2, 0.06)
		crossVertical.Position = Vector3.new(x, baseY + 1.05, z)
		crossVertical.Anchored = true
		crossVertical.CanCollide = false
		crossVertical.Color = color
		crossVertical.Material = Enum.Material.Plastic
		crossVertical.Parent = pieceModel
		-- Cross horizontal part
		local crossHorizontal = Instance.new("Part")
		crossHorizontal.Name = "CrossHorizontal"
		crossHorizontal.Size = Vector3.new(0.18, 0.06, 0.06)
		crossHorizontal.Position = Vector3.new(x, baseY + 1.0, z)
		crossHorizontal.Anchored = true
		crossHorizontal.CanCollide = false
		crossHorizontal.Color = color
		crossHorizontal.Material = Enum.Material.Plastic
		crossHorizontal.Parent = pieceModel
		pieceModel.PrimaryPart = body
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
			local color = if piece.color == "white" then Color3.fromRGB(255, 255, 255) else Color3.fromRGB(0, 0, 0)
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
			local color = if piece.color == "white" then Color3.fromRGB(255, 255, 255) else Color3.fromRGB(0, 0, 0)
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
