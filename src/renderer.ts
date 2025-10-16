import { ChessBoard } from "./board";
import { Piece } from "./types";

const SQUARE_SIZE = 2;
const PIECE_HEIGHT = 0.5;
const BOARD_Y_POSITION = 5;

export class BoardRenderer {
	private boardParts: Map<string, Part> = new Map();
	private pieceParts: Map<string, Part> = new Map();
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
		tableTop.Position = new Vector3(boardCenterX, BOARD_Y_POSITION - 1, boardCenterZ);
		tableTop.Anchored = true;
		tableTop.Color = Color3.fromRGB(101, 67, 33); // Brown wood color
		tableTop.Material = Enum.Material.Wood;
		tableTop.TopSurface = Enum.SurfaceType.Smooth;
		tableTop.BottomSurface = Enum.SurfaceType.Smooth;
		tableTop.Parent = this.boardContainer;

		// Create table legs (relative to board center)
		const legPositions = [
			new Vector3(boardCenterX - 10, BOARD_Y_POSITION - 4, boardCenterZ - 10),
			new Vector3(boardCenterX + 10, BOARD_Y_POSITION - 4, boardCenterZ - 10),
			new Vector3(boardCenterX - 10, BOARD_Y_POSITION - 4, boardCenterZ + 10),
			new Vector3(boardCenterX + 10, BOARD_Y_POSITION - 4, boardCenterZ + 10),
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
		const y = BOARD_Y_POSITION + PIECE_HEIGHT / 2;

		// Always recreate the piece to avoid cache issues
		const existingPiece = this.pieceParts.get(pieceKey);
		if (existingPiece) {
			existingPiece.Destroy();
			this.pieceParts.delete(pieceKey);
		}

		const piecePart = new Instance("Part") as Part;
		piecePart.Name = `${piece.color}_${piece.type}`;
		piecePart.CanCollide = false;
		piecePart.Anchored = true;
		piecePart.CFrame = new CFrame(x, y, z);
		piecePart.TopSurface = Enum.SurfaceType.Smooth;
		piecePart.BottomSurface = Enum.SurfaceType.Smooth;
		piecePart.Parent = this.boardContainer;
		this.pieceParts.set(pieceKey, piecePart);

		// Add click detector to piece
		const clickDetector = new Instance("ClickDetector");
		clickDetector.MaxActivationDistance = 100;
		clickDetector.Parent = piecePart;
		clickDetector.MouseClick.Connect(() => {
			this.onSquareSelect(row, col);
		});

		// Highlight piece based on state
		if (isKingInCheck) {
			piecePart.Color = Color3.fromRGB(255, 0, 0); // Red for check
		} else if (isSelected) {
			piecePart.Color = Color3.fromRGB(255, 255, 0); // Yellow for selected
		} else {
			const color = piece.color === "white" ? Color3.fromRGB(255, 255, 255) : Color3.fromRGB(50, 50, 50);
			piecePart.Color = color;
		}

		let size = new Vector3(0.4, PIECE_HEIGHT, 0.4);
		if (piece.type === "king") {
			size = new Vector3(0.5, PIECE_HEIGHT * 1.2, 0.5);
		} else if (piece.type === "queen") {
			size = new Vector3(0.45, PIECE_HEIGHT * 1.15, 0.45);
		} else if (piece.type === "rook") {
			size = new Vector3(0.4, PIECE_HEIGHT, 0.4);
		} else if (piece.type === "bishop") {
			size = new Vector3(0.35, PIECE_HEIGHT * 1.1, 0.35);
		} else if (piece.type === "knight") {
			size = new Vector3(0.38, PIECE_HEIGHT * 0.9, 0.38);
		} else if (piece.type === "pawn") {
			size = new Vector3(0.3, PIECE_HEIGHT * 0.8, 0.3);
		}

		piecePart.Size = size;
		piecePart.CFrame = new CFrame(x, y, z);
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

			const color = piece.color === "white" ? Color3.fromRGB(255, 255, 255) : Color3.fromRGB(50, 50, 50);
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

			const color = piece.color === "white" ? Color3.fromRGB(255, 255, 255) : Color3.fromRGB(50, 50, 50);
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
