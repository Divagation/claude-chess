import { ChessBoard } from "./board";
import { Piece } from "./types";

const SQUARE_SIZE = 2;
const PIECE_HEIGHT = 0.5;
const BOARD_Y_POSITION = 5;

export class BoardRenderer {
	private boardParts: Map<string, Part> = new Map();
	private pieceParts: Map<string, Model> = new Map();
	private workspace: Workspace;
	private boardContainer: Folder;
	private highlightParts: Part[] = [];
	private board: ChessBoard;
	private capturedPieceParts: Part[] = [];
	private onSquareSelect: (row: number, col: number) => void;

	constructor(board: ChessBoard, onSquareSelect: (row: number, col: number) => void) {
		this.board = board;
		this.onSquareSelect = onSquareSelect;
		this.workspace = game.GetService("Workspace");

		// Clear any existing chess board to prevent conflicts
		const existingBoard = this.workspace.FindFirstChild("ChessBoard");
		if (existingBoard) {
			existingBoard.Destroy();
		}

		this.boardContainer = new Instance("Folder") as Folder;
		this.boardContainer.Name = "ChessBoard";
		this.boardContainer.Parent = this.workspace;

		this.createTable();
	}

	private createTable(): void {
		// Board center is at (7, 7) since board goes from 0-14 in X and Z
		const boardCenterX = 7;
		const boardCenterZ = 7;

		// Create table surface under the board
		const tableTop = new Instance("Part") as Part;
		tableTop.Name = "TableTop";
		tableTop.Size = new Vector3(24, 1, 24); // Larger than board
		tableTop.Position = new Vector3(boardCenterX, BOARD_Y_POSITION - 0.65, boardCenterZ); // Position table just below board
		tableTop.Anchored = true;
		tableTop.Color = Color3.fromRGB(101, 67, 33); // Brown wood color
		tableTop.Material = Enum.Material.Wood;
		tableTop.TopSurface = Enum.SurfaceType.Smooth;
		tableTop.BottomSurface = Enum.SurfaceType.Smooth;
		tableTop.Parent = this.boardContainer;

		// Create table legs (relative to board center)
		const legPositions = [
			new Vector3(boardCenterX - 10, BOARD_Y_POSITION - 4.15, boardCenterZ - 10), // Connected to raised table
			new Vector3(boardCenterX + 10, BOARD_Y_POSITION - 4.15, boardCenterZ - 10),
			new Vector3(boardCenterX - 10, BOARD_Y_POSITION - 4.15, boardCenterZ + 10),
			new Vector3(boardCenterX + 10, BOARD_Y_POSITION - 4.15, boardCenterZ + 10),
		];

		for (const pos of legPositions) {
			const leg = new Instance("Part") as Part;
			leg.Name = "TableLeg";
			leg.Size = new Vector3(1, 6, 1);
			leg.Position = pos;
			leg.Anchored = true;
			leg.Color = Color3.fromRGB(101, 67, 33);
			leg.Material = Enum.Material.Wood;
			leg.Parent = this.boardContainer;
		}
	}

	renderBoard(board: ChessBoard, selectedSquare: { row: number; col: number } | undefined): void {
		const boardArray = board.getBoard();
		const gameState = board.getGameState();

		// Track which piece positions should exist
		const activePieces = new Set<string>();

		for (let row = 0; row < 8; row++) {
			for (let col = 0; col < 8; col++) {
				const squareKey = `${row}-${col}`;
				const x = col * SQUARE_SIZE;
				const z = row * SQUARE_SIZE;
				const y = BOARD_Y_POSITION;
				const isWhiteSquare = (row + col) % 2 === 0;

				let square = this.boardParts.get(squareKey);
				if (!square) {
					square = new Instance("Part") as Part;
					square.Name = `Square_${squareKey}`;
					square.Size = new Vector3(SQUARE_SIZE, 0.2, SQUARE_SIZE);
					square.CanCollide = false;
					square.Anchored = true;
					square.CFrame = new CFrame(x, y, z);
					square.TopSurface = Enum.SurfaceType.Smooth;
					square.BottomSurface = Enum.SurfaceType.Smooth;
					square.Parent = this.boardContainer;
					this.boardParts.set(squareKey, square);

					// Add click detector to board square
					const clickDetector = new Instance("ClickDetector");
					clickDetector.MaxActivationDistance = 100;
					clickDetector.Parent = square;
					clickDetector.MouseClick.Connect(() => {
						this.onSquareSelect(row, col);
					});
				}

				// Highlight selected square or use normal colors
				const isSelectedSquare = selectedSquare && selectedSquare.row === row && selectedSquare.col === col;
				if (isSelectedSquare) {
					square.Color = Color3.fromRGB(255, 255, 100); // Highlight selected square in light yellow
				} else {
					square.Color = isWhiteSquare ? Color3.fromRGB(240, 217, 181) : Color3.fromRGB(181, 136, 99);
				}

				const piece = boardArray[row][col];
				const pieceKey = `piece-${row}-${col}`;

				if (piece) {
					activePieces.add(pieceKey);
					const isSelected = selectedSquare && selectedSquare.row === row && selectedSquare.col === col;
					const isKingInCheck = piece.type === "king" && board.isInCheck(piece.color);
					this.renderPiece(piece, row, col, isSelected, isKingInCheck);
				}
			}
		}

		// Remove pieces that are no longer on the board
		for (const [key, part] of this.pieceParts) {
			if (!activePieces.has(key)) {
				part.Destroy();
				this.pieceParts.delete(key);
			}
		}

		// Render captured pieces
		this.renderCapturedPieces(gameState.capturedByWhite, gameState.capturedByBlack);
	}

	private renderPiece(piece: Piece, row: number, col: number, isSelected: boolean = false, isKingInCheck: boolean = false): void {
		const pieceKey = `piece-${row}-${col}`;
		const x = col * SQUARE_SIZE;
		const z = row * SQUARE_SIZE;
		const baseY = BOARD_Y_POSITION + 0.2; // Raise pieces to sit on top of board squares (square height is 0.2)

		// Always recreate the piece to avoid cache issues
		const existingPiece = this.pieceParts.get(pieceKey);
		if (existingPiece) {
			existingPiece.Destroy();
			this.pieceParts.delete(pieceKey);
		}

		// Create a Model for each piece to contain multiple parts
		const pieceModel = new Instance("Model") as Model;
		pieceModel.Name = `${piece.color}_${piece.type}`;
		pieceModel.Parent = this.boardContainer;
		this.pieceParts.set(pieceKey, pieceModel);

		// Set piece color
		const pieceColor = piece.color === "white" ? Color3.fromRGB(255, 255, 255) : Color3.fromRGB(0, 0, 0);
		switch (piece.type) {
			case "pawn":
				this.createPawn(pieceModel, x, z, baseY, pieceColor);
				break;
			case "rook":
				this.createRook(pieceModel, x, z, baseY, pieceColor);
				break;
			case "knight":
				this.createKnight(pieceModel, x, z, baseY, pieceColor);
				break;
			case "bishop":
				this.createBishop(pieceModel, x, z, baseY, pieceColor);
				break;
			case "queen":
				this.createQueen(pieceModel, x, z, baseY, pieceColor);
				break;
			case "king":
				this.createKing(pieceModel, x, z, baseY, pieceColor);
				break;
		}


		// Add click detector to the main part of the piece
		const primaryPart = pieceModel.PrimaryPart || pieceModel.FindFirstChildWhichIsA("Part");
		if (primaryPart) {
			const clickDetector = new Instance("ClickDetector");
			clickDetector.MaxActivationDistance = 100;
			clickDetector.Parent = primaryPart;
			clickDetector.MouseClick.Connect(() => {
				this.onSquareSelect(row, col);
			});
		}
	}

	private createPawn(pieceModel: Model, x: number, z: number, baseY: number, color: Color3): void {
		// Simple cylinder pawn with rounded top
		const base = new Instance("Part") as Part;
		base.Name = "Base";
		base.Shape = Enum.PartType.Cylinder;
		base.Size = new Vector3(0.3, 0.4, 0.3);
		base.Position = new Vector3(x, baseY + 0.2, z);
		base.Anchored = true;
		base.CanCollide = false;
		base.Color = color;
		base.Material = Enum.Material.Plastic;
		base.Parent = pieceModel;

		// Rounded top
		const top = new Instance("Part") as Part;
		top.Name = "Top";
		top.Shape = Enum.PartType.Ball;
		top.Size = new Vector3(0.25, 0.25, 0.25);
		top.Position = new Vector3(x, baseY + 0.45, z);
		top.Anchored = true;
		top.CanCollide = false;
		top.Color = color;
		top.Material = Enum.Material.Plastic;
		top.Parent = pieceModel;

		pieceModel.PrimaryPart = base;
	}

	private createRook(pieceModel: Model, x: number, z: number, baseY: number, color: Color3): void {
		// Tower-style rook with battlements
		const base = new Instance("Part") as Part;
		base.Name = "Base";
		base.Size = new Vector3(0.4, 0.3, 0.4);
		base.Position = new Vector3(x, baseY + 0.15, z);
		base.Anchored = true;
		base.CanCollide = false;
		base.Color = color;
		base.Material = Enum.Material.Plastic;
		base.Parent = pieceModel;

		// Tower body
		const tower = new Instance("Part") as Part;
		tower.Name = "Tower";
		tower.Size = new Vector3(0.3, 0.4, 0.3);
		tower.Position = new Vector3(x, baseY + 0.5, z);
		tower.Anchored = true;
		tower.CanCollide = false;
		tower.Color = color;
		tower.Material = Enum.Material.Plastic;
		tower.Parent = pieceModel;

		// Battlements (4 smaller cubes on top corners)
		const battlement1 = new Instance("Part") as Part;
		battlement1.Name = "Battlement_1";
		battlement1.Size = new Vector3(0.1, 0.15, 0.1);
		battlement1.Position = new Vector3(x - 0.12, baseY + 0.75, z + 0.12);
		battlement1.Anchored = true;
		battlement1.CanCollide = false;
		battlement1.Color = color;
		battlement1.Material = Enum.Material.Plastic;
		battlement1.Parent = pieceModel;

		const battlement2 = new Instance("Part") as Part;
		battlement2.Name = "Battlement_2";
		battlement2.Size = new Vector3(0.1, 0.15, 0.1);
		battlement2.Position = new Vector3(x + 0.12, baseY + 0.75, z + 0.12);
		battlement2.Anchored = true;
		battlement2.CanCollide = false;
		battlement2.Color = color;
		battlement2.Material = Enum.Material.Plastic;
		battlement2.Parent = pieceModel;

		const battlement3 = new Instance("Part") as Part;
		battlement3.Name = "Battlement_3";
		battlement3.Size = new Vector3(0.1, 0.15, 0.1);
		battlement3.Position = new Vector3(x - 0.12, baseY + 0.75, z - 0.12);
		battlement3.Anchored = true;
		battlement3.CanCollide = false;
		battlement3.Color = color;
		battlement3.Material = Enum.Material.Plastic;
		battlement3.Parent = pieceModel;

		const battlement4 = new Instance("Part") as Part;
		battlement4.Name = "Battlement_4";
		battlement4.Size = new Vector3(0.1, 0.15, 0.1);
		battlement4.Position = new Vector3(x + 0.12, baseY + 0.75, z - 0.12);
		battlement4.Anchored = true;
		battlement4.CanCollide = false;
		battlement4.Color = color;
		battlement4.Material = Enum.Material.Plastic;
		battlement4.Parent = pieceModel;

		pieceModel.PrimaryPart = tower;
	}

	private createKnight(pieceModel: Model, x: number, z: number, baseY: number, color: Color3): void {
		// Horse-shaped knight with long nose (original design, facing correct direction)
		const base = new Instance("Part") as Part;
		base.Name = "Base";
		base.Size = new Vector3(0.35, 0.25, 0.35);
		base.Position = new Vector3(x, baseY + 0.125, z);
		base.Anchored = true;
		base.CanCollide = false;
		base.Color = color;
		base.Material = Enum.Material.Plastic;
		base.Parent = pieceModel;

		// Body
		const body = new Instance("Part") as Part;
		body.Name = "Body";
		body.Size = new Vector3(0.3, 0.3, 0.25);
		body.Position = new Vector3(x, baseY + 0.4, z);
		body.Anchored = true;
		body.CanCollide = false;
		body.Color = color;
		body.Material = Enum.Material.Plastic;
		body.Parent = pieceModel;

		// Head (facing forward - white pieces face -Z, black pieces face +Z)
		const headOffset = color === Color3.fromRGB(255, 255, 255) ? -0.15 : 0.15;
		const head = new Instance("Part") as Part;
		head.Name = "Head";
		head.Size = new Vector3(0.2, 0.25, 0.15);
		head.Position = new Vector3(x, baseY + 0.45, z + headOffset);
		head.Anchored = true;
		head.CanCollide = false;
		head.Color = color;
		head.Material = Enum.Material.Plastic;
		head.Parent = pieceModel;

		// Long nose (the key feature!) pointing in correct direction
		const noseOffset = color === Color3.fromRGB(255, 255, 255) ? -0.3 : 0.3;
		const nose = new Instance("Part") as Part;
		nose.Name = "Nose";
		nose.Size = new Vector3(0.25, 0.08, 0.08);
		nose.Position = new Vector3(x, baseY + 0.42, z + noseOffset);
		nose.Anchored = true;
		nose.CanCollide = false;
		nose.Color = color;
		nose.Material = Enum.Material.Plastic;
		nose.Parent = pieceModel;

		// Ear
		const earOffset = color === Color3.fromRGB(255, 255, 255) ? -0.1 : 0.1;
		const ear = new Instance("Part") as Part;
		ear.Name = "Ear";
		ear.Size = new Vector3(0.08, 0.15, 0.08);
		ear.Position = new Vector3(x, baseY + 0.6, z + earOffset);
		ear.Anchored = true;
		ear.CanCollide = false;
		ear.Color = color;
		ear.Material = Enum.Material.Plastic;
		ear.Parent = pieceModel;

		pieceModel.PrimaryPart = body;
	}

	private createBishop(pieceModel: Model, x: number, z: number, baseY: number, color: Color3): void {
		// Bishop with pointed hat
		const base = new Instance("Part") as Part;
		base.Name = "Base";
		base.Size = new Vector3(0.35, 0.25, 0.35);
		base.Position = new Vector3(x, baseY + 0.125, z);
		base.Anchored = true;
		base.CanCollide = false;
		base.Color = color;
		base.Material = Enum.Material.Plastic;
		base.Parent = pieceModel;

		// Body
		const body = new Instance("Part") as Part;
		body.Name = "Body";
		body.Size = new Vector3(0.25, 0.35, 0.25);
		body.Position = new Vector3(x, baseY + 0.4, z);
		body.Anchored = true;
		body.CanCollide = false;
		body.Color = color;
		body.Material = Enum.Material.Plastic;
		body.Parent = pieceModel;

		// Pointed hat (cone shape using wedge)
		const hat = new Instance("Part") as Part;
		hat.Name = "Hat";
		hat.Size = new Vector3(0.2, 0.25, 0.2);
		hat.Position = new Vector3(x, baseY + 0.65, z);
		hat.Anchored = true;
		hat.CanCollide = false;
		hat.Color = color;
		hat.Material = Enum.Material.Plastic;
		hat.Parent = pieceModel;

		// Small ball on top
		const ball = new Instance("Part") as Part;
		ball.Name = "Ball";
		ball.Shape = Enum.PartType.Ball;
		ball.Size = new Vector3(0.1, 0.1, 0.1);
		ball.Position = new Vector3(x, baseY + 0.8, z);
		ball.Anchored = true;
		ball.CanCollide = false;
		ball.Color = color;
		ball.Material = Enum.Material.Plastic;
		ball.Parent = pieceModel;

		pieceModel.PrimaryPart = body;
	}

	private createQueen(pieceModel: Model, x: number, z: number, baseY: number, color: Color3): void {
		// Queen with crown
		const base = new Instance("Part") as Part;
		base.Name = "Base";
		base.Size = new Vector3(0.4, 0.3, 0.4);
		base.Position = new Vector3(x, baseY + 0.15, z);
		base.Anchored = true;
		base.CanCollide = false;
		base.Color = color;
		base.Material = Enum.Material.Plastic;
		base.Parent = pieceModel;

		// Body
		const body = new Instance("Part") as Part;
		body.Name = "Body";
		body.Size = new Vector3(0.35, 0.4, 0.35);
		body.Position = new Vector3(x, baseY + 0.5, z);
		body.Anchored = true;
		body.CanCollide = false;
		body.Color = color;
		body.Material = Enum.Material.Plastic;
		body.Parent = pieceModel;

		// Crown base
		const crownBase = new Instance("Part") as Part;
		crownBase.Name = "CrownBase";
		crownBase.Size = new Vector3(0.3, 0.1, 0.3);
		crownBase.Position = new Vector3(x, baseY + 0.75, z);
		crownBase.Anchored = true;
		crownBase.CanCollide = false;
		crownBase.Color = color;
		crownBase.Material = Enum.Material.Plastic;
		crownBase.Parent = pieceModel;

		// Crown points (5 points)
		const crownPoint1 = new Instance("Part") as Part;
		crownPoint1.Name = "CrownPoint_1";
		crownPoint1.Size = new Vector3(0.08, 0.15, 0.08);
		crownPoint1.Position = new Vector3(x - 0.12, baseY + 0.85, z);
		crownPoint1.Anchored = true;
		crownPoint1.CanCollide = false;
		crownPoint1.Color = color;
		crownPoint1.Material = Enum.Material.Plastic;
		crownPoint1.Parent = pieceModel;

		const crownPoint2 = new Instance("Part") as Part;
		crownPoint2.Name = "CrownPoint_2";
		crownPoint2.Size = new Vector3(0.08, 0.15, 0.08);
		crownPoint2.Position = new Vector3(x - 0.06, baseY + 0.9, z);
		crownPoint2.Anchored = true;
		crownPoint2.CanCollide = false;
		crownPoint2.Color = color;
		crownPoint2.Material = Enum.Material.Plastic;
		crownPoint2.Parent = pieceModel;

		const crownPoint3 = new Instance("Part") as Part;
		crownPoint3.Name = "CrownPoint_3";
		crownPoint3.Size = new Vector3(0.08, 0.15, 0.08);
		crownPoint3.Position = new Vector3(x, baseY + 0.95, z);
		crownPoint3.Anchored = true;
		crownPoint3.CanCollide = false;
		crownPoint3.Color = color;
		crownPoint3.Material = Enum.Material.Plastic;
		crownPoint3.Parent = pieceModel;

		const crownPoint4 = new Instance("Part") as Part;
		crownPoint4.Name = "CrownPoint_4";
		crownPoint4.Size = new Vector3(0.08, 0.15, 0.08);
		crownPoint4.Position = new Vector3(x + 0.06, baseY + 0.9, z);
		crownPoint4.Anchored = true;
		crownPoint4.CanCollide = false;
		crownPoint4.Color = color;
		crownPoint4.Material = Enum.Material.Plastic;
		crownPoint4.Parent = pieceModel;

		const crownPoint5 = new Instance("Part") as Part;
		crownPoint5.Name = "CrownPoint_5";
		crownPoint5.Size = new Vector3(0.08, 0.15, 0.08);
		crownPoint5.Position = new Vector3(x + 0.12, baseY + 0.85, z);
		crownPoint5.Anchored = true;
		crownPoint5.CanCollide = false;
		crownPoint5.Color = color;
		crownPoint5.Material = Enum.Material.Plastic;
		crownPoint5.Parent = pieceModel;

		pieceModel.PrimaryPart = body;
	}

	private createKing(pieceModel: Model, x: number, z: number, baseY: number, color: Color3): void {
		// King with cross on top
		const base = new Instance("Part") as Part;
		base.Name = "Base";
		base.Size = new Vector3(0.45, 0.35, 0.45);
		base.Position = new Vector3(x, baseY + 0.175, z);
		base.Anchored = true;
		base.CanCollide = false;
		base.Color = color;
		base.Material = Enum.Material.Plastic;
		base.Parent = pieceModel;

		// Body
		const body = new Instance("Part") as Part;
		body.Name = "Body";
		body.Size = new Vector3(0.4, 0.45, 0.4);
		body.Position = new Vector3(x, baseY + 0.55, z);
		body.Anchored = true;
		body.CanCollide = false;
		body.Color = color;
		body.Material = Enum.Material.Plastic;
		body.Parent = pieceModel;

		// Crown base (wider than queen's)
		const crownBase = new Instance("Part") as Part;
		crownBase.Name = "CrownBase";
		crownBase.Size = new Vector3(0.35, 0.12, 0.35);
		crownBase.Position = new Vector3(x, baseY + 0.85, z);
		crownBase.Anchored = true;
		crownBase.CanCollide = false;
		crownBase.Color = color;
		crownBase.Material = Enum.Material.Plastic;
		crownBase.Parent = pieceModel;

		// Cross vertical part
		const crossVertical = new Instance("Part") as Part;
		crossVertical.Name = "CrossVertical";
		crossVertical.Size = new Vector3(0.06, 0.2, 0.06);
		crossVertical.Position = new Vector3(x, baseY + 1.05, z);
		crossVertical.Anchored = true;
		crossVertical.CanCollide = false;
		crossVertical.Color = color;
		crossVertical.Material = Enum.Material.Plastic;
		crossVertical.Parent = pieceModel;

		// Cross horizontal part
		const crossHorizontal = new Instance("Part") as Part;
		crossHorizontal.Name = "CrossHorizontal";
		crossHorizontal.Size = new Vector3(0.18, 0.06, 0.06);
		crossHorizontal.Position = new Vector3(x, baseY + 1.0, z);
		crossHorizontal.Anchored = true;
		crossHorizontal.CanCollide = false;
		crossHorizontal.Color = color;
		crossHorizontal.Material = Enum.Material.Plastic;
		crossHorizontal.Parent = pieceModel;

		pieceModel.PrimaryPart = body;
	}

	highlightValidMoves(validMoves: { row: number; col: number }[]): void {
		for (const highlight of this.highlightParts) {
			highlight.Destroy();
		}
		this.highlightParts = [];

		for (const move of validMoves) {
			const x = move.col * SQUARE_SIZE;
			const z = move.row * SQUARE_SIZE;
			const y = BOARD_Y_POSITION + 0.15;

			// Create green outline box around the square using a selection box
			const outlineBox = new Instance("Part") as Part;
			outlineBox.Name = `ValidMove_${move.row}-${move.col}`;
			outlineBox.Size = new Vector3(SQUARE_SIZE - 0.05, 0.01, SQUARE_SIZE - 0.05);
			outlineBox.CanCollide = false;
			outlineBox.Anchored = true;
			outlineBox.CFrame = new CFrame(x, y, z);
			outlineBox.Transparency = 1;
			outlineBox.Parent = this.boardContainer;
			this.highlightParts.push(outlineBox);

			// Add a selection box outline - this is what creates the green outline
			const selectionBox = new Instance("SelectionBox") as SelectionBox;
			selectionBox.LineThickness = 0.08;
			selectionBox.Color3 = Color3.fromRGB(0, 255, 0);
			selectionBox.Adornee = outlineBox;
			selectionBox.Parent = outlineBox;

			// Add click detector to the outline
			const clickDetector = new Instance("ClickDetector");
			clickDetector.MaxActivationDistance = 100;
			clickDetector.Parent = outlineBox;
			clickDetector.MouseClick.Connect(() => {
				this.onSquareSelect(move.row, move.col);
			});
		}
	}

	private renderCapturedPieces(capturedByWhite: Piece[], capturedByBlack: Piece[]): void {
		// Clear old captured piece displays
		for (const part of this.capturedPieceParts) {
			part.Destroy();
		}
		this.capturedPieceParts = [];

		// White captures black pieces -> show black pieces on black's side (right/top)
		let whiteIndex = 0;
		for (const piece of capturedByWhite) {
			// piece.color is "black" because white captured black's pieces
			const capturedPart = new Instance("Part") as Part;
			capturedPart.Name = `Captured_${piece.color}_${piece.type}`;
			capturedPart.Anchored = true;
			capturedPart.CanCollide = false;

			// Match size to piece type
			let size = new Vector3(0.3, PIECE_HEIGHT * 0.6, 0.3);
			if (piece.type === "king") {
				size = new Vector3(0.4, PIECE_HEIGHT * 0.7, 0.4);
			} else if (piece.type === "queen") {
				size = new Vector3(0.35, PIECE_HEIGHT * 0.65, 0.35);
			} else if (piece.type === "pawn") {
				size = new Vector3(0.25, PIECE_HEIGHT * 0.5, 0.25);
			}
			capturedPart.Size = size;

			// Position on right side (black's side) - sitting on table
			const xPos = 18;
			const zPos = whiteIndex * 0.5; // Space them out more
			capturedPart.Position = new Vector3(xPos, BOARD_Y_POSITION - 0.5 + (size.Y / 2), zPos);

			const color = piece.color === "white" ? Color3.fromRGB(255, 255, 255) : Color3.fromRGB(0, 0, 0);
			capturedPart.Color = color;
			capturedPart.Parent = this.boardContainer;
			this.capturedPieceParts.push(capturedPart);

			whiteIndex++;
		}

		// Black captures white pieces -> show white pieces on white's side (left/bottom)
		let blackIndex = 0;
		for (const piece of capturedByBlack) {
			// piece.color is "white" because black captured white's pieces
			const capturedPart = new Instance("Part") as Part;
			capturedPart.Name = `Captured_${piece.color}_${piece.type}`;
			capturedPart.Anchored = true;
			capturedPart.CanCollide = false;

			// Match size to piece type
			let size = new Vector3(0.3, PIECE_HEIGHT * 0.6, 0.3);
			if (piece.type === "king") {
				size = new Vector3(0.4, PIECE_HEIGHT * 0.7, 0.4);
			} else if (piece.type === "queen") {
				size = new Vector3(0.35, PIECE_HEIGHT * 0.65, 0.35);
			} else if (piece.type === "pawn") {
				size = new Vector3(0.25, PIECE_HEIGHT * 0.5, 0.25);
			}
			capturedPart.Size = size;

			// Position on left side (white's side) - sitting on table
			const xPos = -4;
			const zPos = 14 - (blackIndex * 0.5); // Start from back, space them out
			capturedPart.Position = new Vector3(xPos, BOARD_Y_POSITION - 0.5 + (size.Y / 2), zPos);

			const color = piece.color === "white" ? Color3.fromRGB(255, 255, 255) : Color3.fromRGB(0, 0, 0);
			capturedPart.Color = color;
			capturedPart.Parent = this.boardContainer;
			this.capturedPieceParts.push(capturedPart);

			blackIndex++;
		}
	}

	destroy(): void {
		this.boardContainer.Destroy();
	}
}
