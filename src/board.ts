import { Piece, PieceType, Color, Position, GameState, Move } from "./types";

const BOARD_ROWS = 8;
const BOARD_COLS = 8;

export class ChessBoard {
	private board: (Piece | undefined)[][] = [];
	private gameState: GameState;

	constructor() {
		this.gameState = {
			board: this.createInitialBoard(),
			currentPlayer: "white",
			selectedSquare: undefined,
			validMoves: [],
			moveHistory: [],
			isCheckmate: false,
			isStalemate: false,
			isCheck: false,
			enPassantTarget: undefined,
			capturedByWhite: [],
			capturedByBlack: [],
		};
		this.board = this.gameState.board;
	}

	private createInitialBoard(): (Piece | undefined)[][] {
		const board: (Piece | undefined)[][] = [];

		for (let row = 0; row < BOARD_ROWS; row++) {
			board[row] = [];
			for (let col = 0; col < BOARD_COLS; col++) {
				board[row][col] = undefined;
			}
		}

		// White pieces at bottom (rows 6-7)
		this.placePieceRow(board, 7, "white");
		for (let col = 0; col < BOARD_COLS; col++) {
			board[6][col] = { type: "pawn", color: "white" };
		}

		// Black pieces at top (rows 0-1)
		this.placePieceRow(board, 0, "black");
		for (let col = 0; col < BOARD_COLS; col++) {
			board[1][col] = { type: "pawn", color: "black" };
		}

		return board;
	}

	private placePieceRow(board: (Piece | undefined)[][], row: number, color: Color): void {
		const pieces: PieceType[] = ["rook", "knight", "bishop", "queen", "king", "bishop", "knight", "rook"];
		for (let col = 0; col < BOARD_COLS; col++) {
			board[row][col] = { type: pieces[col], color };
		}
	}

	getBoard(): (Piece | undefined)[][] {
		return this.board;
	}

	getGameState(): GameState {
		return this.gameState;
	}

	selectSquare(row: number, col: number): void {
		if (row < 0 || row > 7 || col < 0 || col > 7) return;

		const piece = this.board[row][col];

		if (piece && piece.color === this.gameState.currentPlayer) {
			this.gameState.selectedSquare = { row, col };
			this.gameState.validMoves = this.getValidMoves(row, col);
		} else if (this.gameState.selectedSquare && this.isValidMove(row, col)) {
			this.makeMove(this.gameState.selectedSquare.row, this.gameState.selectedSquare.col, row, col);
			this.gameState.selectedSquare = undefined;
			this.gameState.validMoves = [];
		}
	}

	private isValidMove(row: number, col: number): boolean {
		const validMoves = this.gameState.validMoves;
		for (const move of validMoves) {
			if (move.row === row && move.col === col) return true;
		}
		return false;
	}

	private getValidMoves(row: number, col: number): Position[] {
		const piece = this.board[row][col];
		if (!piece) return [];

		let moves: Position[] = [];

		if (piece.type === "pawn") {
			moves = this.getPawnMoves(row, col, piece.color);
		} else if (piece.type === "knight") {
			moves = this.getKnightMoves(row, col, piece.color);
		} else if (piece.type === "bishop") {
			moves = this.getBishopMoves(row, col, piece.color);
		} else if (piece.type === "rook") {
			moves = this.getRookMoves(row, col, piece.color);
		} else if (piece.type === "queen") {
			moves = this.getQueenMoves(row, col, piece.color);
		} else if (piece.type === "king") {
			moves = this.getKingMoves(row, col, piece.color);
		}

		// Filter out moves that would leave king in check
		const legalMoves: Position[] = [];
		for (const move of moves) {
			if (this.doesntPutKingInCheck(row, col, move.row, move.col, piece.color)) {
				legalMoves.push(move);
			}
		}

		return legalMoves;
	}

	private doesntPutKingInCheck(fromRow: number, fromCol: number, toRow: number, toCol: number, color: Color): boolean {
		// Simulate the move
		const boardCopy = this.copyBoardForSimulation();
		const piece = boardCopy[fromRow][fromCol];
		if (!piece) return false;

		boardCopy[toRow][toCol] = piece;
		boardCopy[fromRow][fromCol] = undefined;

		// Check if king is in check after the move
		const opponentColor = color === "white" ? "black" : "white";
		const kingPos = this.findKingInBoard(boardCopy, color);
		if (!kingPos) return false;

		return !this.isSquareAttackedByColorInBoard(boardCopy, kingPos.row, kingPos.col, opponentColor);
	}

	private getPawnMoves(row: number, col: number, color: Color): Position[] {
		const moves: Position[] = [];
		const direction = color === "white" ? -1 : 1;
		const startRow = color === "white" ? 6 : 1;

		const nextRow = row + direction;
		if (nextRow >= 0 && nextRow <= 7 && !this.board[nextRow][col]) {
			moves.push({ row: nextRow, col });

			if (row === startRow && !this.board[row + 2 * direction][col]) {
				moves.push({ row: row + 2 * direction, col });
			}
		}

		for (let colOffset = -1; colOffset <= 1; colOffset += 2) {
			const captureCol = col + colOffset;
			const captureRow = row + direction;
			if (captureCol >= 0 && captureCol <= 7 && captureRow >= 0 && captureRow <= 7) {
				const target = this.board[captureRow][captureCol];
				if (target && target.color !== color) {
					moves.push({ row: captureRow, col: captureCol });
				}
			}
		}

		return moves;
	}

	private getKnightMoves(row: number, col: number, color: Color): Position[] {
		const moves: Position[] = [];
		const offsets: number[][] = [[-2, -1], [-2, 1], [-1, -2], [-1, 2], [1, -2], [1, 2], [2, -1], [2, 1]];

		for (const offset of offsets) {
			const newRow = row + offset[0];
			const newCol = col + offset[1];
			if (newRow >= 0 && newRow <= 7 && newCol >= 0 && newCol <= 7) {
				const target = this.board[newRow][newCol];
				if (!target || target.color !== color) {
					moves.push({ row: newRow, col: newCol });
				}
			}
		}

		return moves;
	}

	private getBishopMoves(row: number, col: number, color: Color): Position[] {
		return this.getDirectionalMoves(row, col, color, [[-1, -1], [-1, 1], [1, -1], [1, 1]]);
	}

	private getRookMoves(row: number, col: number, color: Color): Position[] {
		return this.getDirectionalMoves(row, col, color, [[-1, 0], [1, 0], [0, -1], [0, 1]]);
	}

	private getQueenMoves(row: number, col: number, color: Color): Position[] {
		return this.getDirectionalMoves(row, col, color, [
			[-1, -1],
			[-1, 0],
			[-1, 1],
			[0, -1],
			[0, 1],
			[1, -1],
			[1, 0],
			[1, 1],
		]);
	}

	private getKingMoves(row: number, col: number, color: Color): Position[] {
		const moves: Position[] = [];
		for (let rowOffset = -1; rowOffset <= 1; rowOffset++) {
			for (let colOffset = -1; colOffset <= 1; colOffset++) {
				if (rowOffset === 0 && colOffset === 0) continue;
				const newRow = row + rowOffset;
				const newCol = col + colOffset;
				if (newRow >= 0 && newRow <= 7 && newCol >= 0 && newCol <= 7) {
					const target = this.board[newRow][newCol];
					if (!target || target.color !== color) {
						moves.push({ row: newRow, col: newCol });
					}
				}
			}
		}
		return moves;
	}

	private getDirectionalMoves(
		row: number,
		col: number,
		color: Color,
		directions: number[][]
	): Position[] {
		const moves: Position[] = [];
		for (const dir of directions) {
			const rowDir = dir[0];
			const colDir = dir[1];
			let newRow = row + rowDir;
			let newCol = col + colDir;
			while (newRow >= 0 && newRow <= 7 && newCol >= 0 && newCol <= 7) {
				const target = this.board[newRow][newCol];
				if (!target) {
					moves.push({ row: newRow, col: newCol });
				} else if (target.color !== color) {
					moves.push({ row: newRow, col: newCol });
					break;
				} else {
					break;
				}
				newRow += rowDir;
				newCol += colDir;
			}
		}
		return moves;
	}

	private makeMove(fromRow: number, fromCol: number, toRow: number, toCol: number): void {
		const piece = this.board[fromRow][fromCol];
		if (!piece) return;

		const move: Move = {
			from: { row: fromRow, col: fromCol },
			to: { row: toRow, col: toCol },
		};

		const target = this.board[toRow][toCol];
		if (target) {
			move.capturedPiece = target;
			// Track captured pieces
			if (piece.color === "white") {
				this.gameState.capturedByWhite.push(target);
			} else {
				this.gameState.capturedByBlack.push(target);
			}
		}

		this.board[toRow][toCol] = piece;
		this.board[fromRow][fromCol] = undefined;

		this.gameState.moveHistory.push(move);
		this.gameState.currentPlayer = this.gameState.currentPlayer === "white" ? "black" : "white";
		this.gameState.enPassantTarget = undefined;
	}

	isLegalMove(fromRow: number, fromCol: number, toRow: number, toCol: number): boolean {
		const piece = this.board[fromRow][fromCol];
		if (!piece || piece.color !== this.gameState.currentPlayer) return false;

		const validMoves = this.getValidMoves(fromRow, fromCol);
		for (const move of validMoves) {
			if (move.row === toRow && move.col === toCol) return true;
		}
		return false;
	}

	getPossibleMovesForColor(color: Color): Move[] {
		const moves: Move[] = [];
		for (let row = 0; row < BOARD_ROWS; row++) {
			for (let col = 0; col < BOARD_COLS; col++) {
				const piece = this.board[row][col];
				if (piece && piece.color === color) {
					const validMoves = this.getValidMoves(row, col);
					for (const move of validMoves) {
						moves.push({
							from: { row, col },
							to: move,
						});
					}
				}
			}
		}
		return moves;
	}

	private findKing(color: Color): Position | undefined {
		for (let row = 0; row < BOARD_ROWS; row++) {
			for (let col = 0; col < BOARD_COLS; col++) {
				const piece = this.board[row][col];
				if (piece && piece.color === color && piece.type === "king") {
					return { row, col };
				}
			}
		}
		return undefined;
	}

	private isSquareAttackedByColor(row: number, col: number, attackingColor: Color): boolean {
		// Check all pieces of attacking color to see if they can attack this square
		for (let r = 0; r < BOARD_ROWS; r++) {
			for (let c = 0; c < BOARD_COLS; c++) {
				const piece = this.board[r][c];
				if (piece && piece.color === attackingColor) {
					const moves = this.getValidMovesForPiece(r, c, piece);
					for (const move of moves) {
						if (move.row === row && move.col === col) {
							return true;
						}
					}
				}
			}
		}
		return false;
	}

	private getValidMovesForPiece(row: number, col: number, piece: Piece): Position[] {
		if (piece.type === "pawn") {
			return this.getPawnMoves(row, col, piece.color);
		} else if (piece.type === "knight") {
			return this.getKnightMoves(row, col, piece.color);
		} else if (piece.type === "bishop") {
			return this.getBishopMoves(row, col, piece.color);
		} else if (piece.type === "rook") {
			return this.getRookMoves(row, col, piece.color);
		} else if (piece.type === "queen") {
			return this.getQueenMoves(row, col, piece.color);
		} else if (piece.type === "king") {
			return this.getKingMoves(row, col, piece.color);
		}
		return [];
	}

	isInCheck(color: Color): boolean {
		const kingPos = this.findKing(color);
		if (!kingPos) return false;

		const opponentColor = color === "white" ? "black" : "white";
		return this.isSquareAttackedByColor(kingPos.row, kingPos.col, opponentColor);
	}

	isInCheckmate(color: Color): boolean {
		// Must be in check first
		if (!this.isInCheck(color)) return false;

		// Check if there are any legal moves that get out of check
		const moves = this.getPossibleMovesForColor(color);
		for (const move of moves) {
			// Try the move
			const boardCopy = this.copyBoardForSimulation();
			const piece = boardCopy[move.from.row][move.from.col];
			if (!piece) continue;

			boardCopy[move.to.row][move.to.col] = piece;
			boardCopy[move.from.row][move.from.col] = undefined;

			// Check if still in check
			const opponentColor = color === "white" ? "black" : "white";
			const kingPos = this.findKingInBoard(boardCopy, color);
			if (kingPos && !this.isSquareAttackedByColorInBoard(boardCopy, kingPos.row, kingPos.col, opponentColor)) {
				// Found a legal move that escapes check
				return false;
			}
		}

		// No legal moves to escape check = checkmate
		return true;
	}

	private copyBoardForSimulation(): (Piece | undefined)[][] {
		const newBoard: (Piece | undefined)[][] = [];
		for (let row = 0; row < BOARD_ROWS; row++) {
			newBoard[row] = [];
			for (let col = 0; col < BOARD_COLS; col++) {
				const piece = this.board[row][col];
				if (piece) {
					newBoard[row][col] = { ...piece };
				} else {
					newBoard[row][col] = undefined;
				}
			}
		}
		return newBoard;
	}

	private findKingInBoard(board: (Piece | undefined)[][], color: Color): Position | undefined {
		for (let row = 0; row < BOARD_ROWS; row++) {
			for (let col = 0; col < BOARD_COLS; col++) {
				const piece = board[row][col];
				if (piece && piece.color === color && piece.type === "king") {
					return { row, col };
				}
			}
		}
		return undefined;
	}

	private isSquareAttackedByColorInBoard(board: (Piece | undefined)[][], row: number, col: number, attackingColor: Color): boolean {
		for (let r = 0; r < BOARD_ROWS; r++) {
			for (let c = 0; c < BOARD_COLS; c++) {
				const piece = board[r][c];
				if (piece && piece.color === attackingColor) {
					const moves = this.getValidMovesForPieceInBoard(board, r, c, piece);
					for (const move of moves) {
						if (move.row === row && move.col === col) {
							return true;
						}
					}
				}
			}
		}
		return false;
	}

	private getValidMovesForPieceInBoard(board: (Piece | undefined)[][], row: number, col: number, piece: Piece): Position[] {
		// Helper for checkmate detection - uses provided board instead of this.board
		if (piece.type === "pawn") {
			return this.getPawnMovesInBoard(board, row, col, piece.color);
		} else if (piece.type === "knight") {
			return this.getKnightMovesInBoard(board, row, col, piece.color);
		} else if (piece.type === "bishop") {
			return this.getBishopMovesInBoard(board, row, col, piece.color);
		} else if (piece.type === "rook") {
			return this.getRookMovesInBoard(board, row, col, piece.color);
		} else if (piece.type === "queen") {
			return this.getQueenMovesInBoard(board, row, col, piece.color);
		} else if (piece.type === "king") {
			return this.getKingMovesInBoard(board, row, col, piece.color);
		}
		return [];
	}

	private getPawnMovesInBoard(board: (Piece | undefined)[][], row: number, col: number, color: Color): Position[] {
		const moves: Position[] = [];
		const direction = color === "white" ? -1 : 1;
		const startRow = color === "white" ? 6 : 1;

		const nextRow = row + direction;
		if (nextRow >= 0 && nextRow <= 7 && !board[nextRow][col]) {
			moves.push({ row: nextRow, col });

			if (row === startRow && !board[row + 2 * direction][col]) {
				moves.push({ row: row + 2 * direction, col });
			}
		}

		for (let colOffset = -1; colOffset <= 1; colOffset += 2) {
			const captureCol = col + colOffset;
			const captureRow = row + direction;
			if (captureCol >= 0 && captureCol <= 7 && captureRow >= 0 && captureRow <= 7) {
				const target = board[captureRow][captureCol];
				if (target && target.color !== color) {
					moves.push({ row: captureRow, col: captureCol });
				}
			}
		}

		return moves;
	}

	private getKnightMovesInBoard(board: (Piece | undefined)[][], row: number, col: number, color: Color): Position[] {
		const moves: Position[] = [];
		const offsets: number[][] = [[-2, -1], [-2, 1], [-1, -2], [-1, 2], [1, -2], [1, 2], [2, -1], [2, 1]];

		for (const offset of offsets) {
			const newRow = row + offset[0];
			const newCol = col + offset[1];
			if (newRow >= 0 && newRow <= 7 && newCol >= 0 && newCol <= 7) {
				const target = board[newRow][newCol];
				if (!target || target.color !== color) {
					moves.push({ row: newRow, col: newCol });
				}
			}
		}

		return moves;
	}

	private getBishopMovesInBoard(board: (Piece | undefined)[][], row: number, col: number, color: Color): Position[] {
		return this.getDirectionalMovesInBoard(board, row, col, color, [[-1, -1], [-1, 1], [1, -1], [1, 1]]);
	}

	private getRookMovesInBoard(board: (Piece | undefined)[][], row: number, col: number, color: Color): Position[] {
		return this.getDirectionalMovesInBoard(board, row, col, color, [[-1, 0], [1, 0], [0, -1], [0, 1]]);
	}

	private getQueenMovesInBoard(board: (Piece | undefined)[][], row: number, col: number, color: Color): Position[] {
		return this.getDirectionalMovesInBoard(board, row, col, color, [
			[-1, -1], [-1, 0], [-1, 1],
			[0, -1], [0, 1],
			[1, -1], [1, 0], [1, 1],
		]);
	}

	private getKingMovesInBoard(board: (Piece | undefined)[][], row: number, col: number, color: Color): Position[] {
		const moves: Position[] = [];
		for (let rowOffset = -1; rowOffset <= 1; rowOffset++) {
			for (let colOffset = -1; colOffset <= 1; colOffset++) {
				if (rowOffset === 0 && colOffset === 0) continue;
				const newRow = row + rowOffset;
				const newCol = col + colOffset;
				if (newRow >= 0 && newRow <= 7 && newCol >= 0 && newCol <= 7) {
					const target = board[newRow][newCol];
					if (!target || target.color !== color) {
						moves.push({ row: newRow, col: newCol });
					}
				}
			}
		}
		return moves;
	}

	private getDirectionalMovesInBoard(board: (Piece | undefined)[][], row: number, col: number, color: Color, directions: number[][]): Position[] {
		const moves: Position[] = [];
		for (const dir of directions) {
			const rowDir = dir[0];
			const colDir = dir[1];
			let newRow = row + rowDir;
			let newCol = col + colDir;
			while (newRow >= 0 && newRow <= 7 && newCol >= 0 && newCol <= 7) {
				const target = board[newRow][newCol];
				if (!target) {
					moves.push({ row: newRow, col: newCol });
				} else if (target.color !== color) {
					moves.push({ row: newRow, col: newCol });
					break;
				} else {
					break;
				}
				newRow += rowDir;
				newCol += colDir;
			}
		}
		return moves;
	}
}
