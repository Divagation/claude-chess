import { ChessBoard } from "./board";
import { Color, Move, PieceType } from "./types";

const MAX_VALUE = 999999;
const MIN_VALUE = -999999;

export class ChessAI {
	private maxDepth = 3; // Increased to 3 for better lookahead

	findBestMove(board: ChessBoard): Move | undefined {
		const moves = board.getPossibleMovesForColor("black");
		let isEmpty = true;
		for (const _m of moves) {
			isEmpty = false;
			break;
		}
		if (isEmpty) return undefined;

		let bestMoves: Move[] = [];
		let bestScore = MIN_VALUE;

		for (const move of moves) {
			const boardCopy = this.copyBoard(board);
			const boardArrayBefore = board.getBoard();
			const targetPiece = boardArrayBefore[move.to.row][move.to.col];

			this.makeMove(boardCopy, move);

			// Immediate capture bonus - if we're taking material, add it directly
			let captureBonus = 0;
			if (targetPiece) {
				const captureValues: Record<string, number> = {
					"pawn": 100,
					"knight": 300,
					"bishop": 300,
					"rook": 500,
					"queen": 900,
					"king": 10000,
				};
				captureBonus = (captureValues[targetPiece.type] || 0) * 0.5; // 50% of piece value as immediate bonus
			}

			// After black moves, it's white's turn (minimizing = false in the next layer means white is playing)
			const score = this.minimax(boardCopy, this.maxDepth - 1, MIN_VALUE, MAX_VALUE, false) + captureBonus + math.random() * 0.1;

			if (score > bestScore) {
				bestScore = score;
				bestMoves = [move];
			} else if (score === bestScore) {
				bestMoves.push(move);
			}
		}

		// Pick randomly from equally good moves
		let moveCount = 0;
		for (const _ of bestMoves) moveCount++;

		if (moveCount > 0) {
			const randomIndex = math.floor(math.random() * moveCount);
			let currentIndex = 0;
			for (const move of bestMoves) {
				if (currentIndex === randomIndex) {
					return move;
				}
				currentIndex++;
			}
		}

		return undefined;
	}

	private minimax(board: ChessBoard, depth: number, alpha: number, beta: number, isMaximizing: boolean): number {
		if (depth === 0) {
			const score = this.evaluatePosition(board);
			return score;
		}

		// isMaximizing = true means it's BLACK's turn (AI maximizes)
		// isMaximizing = false means it's WHITE's turn (player minimizes)
		const moves = board.getPossibleMovesForColor(isMaximizing ? "black" : "white");

		// Check if no moves available
		let hasMoves = false;
		for (const _ of moves) {
			hasMoves = true;
			break;
		}
		if (!hasMoves) {
			// No moves = game over, return evaluation
			return this.evaluatePosition(board);
		}

		if (isMaximizing) {
			// BLACK's turn - maximize score
			let maxEval = MIN_VALUE;
			for (const move of moves) {
				const boardCopy = this.copyBoard(board);
				this.makeMove(boardCopy, move);

				// After black moves, it's white's turn (false)
				const evaluation = this.minimax(boardCopy, depth - 1, alpha, beta, false);
				maxEval = math.max(maxEval, evaluation);
				alpha = math.max(alpha, evaluation);

				if (beta <= alpha) {
					break; // Alpha-beta pruning
				}
			}
			return maxEval;
		} else {
			// WHITE's turn - minimize score
			let minEval = MAX_VALUE;
			for (const move of moves) {
				const boardCopy = this.copyBoard(board);
				this.makeMove(boardCopy, move);

				// After white moves, it's black's turn (true)
				const evaluation = this.minimax(boardCopy, depth - 1, alpha, beta, true);
				minEval = math.min(minEval, evaluation);
				beta = math.min(beta, evaluation);

				if (beta <= alpha) {
					break; // Alpha-beta pruning
				}
			}
			return minEval;
		}
	}

	private makeMove(board: ChessBoard, move: Move): void {
		board.selectSquare(move.from.row, move.from.col);
		board.selectSquare(move.to.row, move.to.col);
	}

	private evaluatePosition(board: ChessBoard): number {
		const boardArray = board.getBoard();
		let score = 0;

		const pieceValues: Record<PieceType, number> = {
			"pawn": 100,
			"knight": 300,
			"bishop": 325, // Slightly higher than knight
			"rook": 500,
			"queen": 900,
			"king": 10000,
		};

		for (let row = 0; row < 8; row++) {
			for (let col = 0; col < 8; col++) {
				const piece = boardArray[row][col];
				if (piece) {
					let value = pieceValues[piece.type];

					// Add positional bonuses
					if (piece.type === "pawn") {
						// Pawns are better when advanced
						if (piece.color === "black") {
							value += row * 3; // Black pawns move down (higher row = more advanced)
						} else {
							value += (7 - row) * 3; // White pawns move up (lower row = more advanced)
						}
					} else if (piece.type === "knight" || piece.type === "bishop") {
						// Knights and bishops better in center and developed
						const centerDistance = math.abs(3.5 - row) + math.abs(3.5 - col);
						value += (7 - centerDistance) * 3;

						// Bonus for development
						if (piece.color === "black" && row > 1) {
							value += 20; // Bonus for black developing (moving away from row 0)
						} else if (piece.color === "white" && row < 6) {
							value += 20; // Bonus for white developing (moving away from row 7)
						}
					} else if (piece.type === "rook") {
						// Rooks on open files are good
						let pawnCount = 0;
						for (let r = 0; r < 8; r++) {
							const p = boardArray[r][col];
							if (p && p.type === "pawn") {
								pawnCount++;
							}
						}
						if (pawnCount === 0) {
							value += 30; // Bonus for open file
						}
					}

					// BLACK is maximizing (positive is good for black)
					// WHITE is minimizing (negative is bad for black)
					if (piece.color === "black") {
						score += value;
					} else {
						score -= value;
					}
				}
			}
		}

		return score;
	}

	private copyBoard(board: ChessBoard): ChessBoard {
		const newBoard = new ChessBoard();
		const originalBoard = board.getBoard();
		const newBoardArray = newBoard.getBoard();

		for (let row = 0; row < 8; row++) {
			for (let col = 0; col < 8; col++) {
				const piece = originalBoard[row][col];
				if (piece) {
					newBoardArray[row][col] = { ...piece };
				} else {
					newBoardArray[row][col] = undefined;
				}
			}
		}

		return newBoard;
	}
}
