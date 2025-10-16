import { ChessBoard } from "./board";
import { BoardRenderer } from "./renderer";
import { ChessAI } from "./ai";

// Global reference for click handlers
let currentGameManager: GameManager | undefined;

export function selectSquareGlobal(row: number, col: number): void {
	if (currentGameManager) {
		currentGameManager.selectSquare(row, col);
	}
}

export class GameManager {
	private board: ChessBoard;
	private renderer: BoardRenderer;
	private ai: ChessAI;
	private gameRunning: boolean = true;

	constructor() {
		this.board = new ChessBoard();
		this.renderer = new BoardRenderer(this.board, (row: number, col: number) => {
			this.selectSquare(row, col);
		});
		this.ai = new ChessAI();
		currentGameManager = this;
		this.updateDisplay();
	}

	private updateDisplay(): void {
		const gameState = this.board.getGameState();

		// Check for checkmate
		if (this.board.isInCheckmate(gameState.currentPlayer)) {
			const winner = gameState.currentPlayer === "white" ? "Black" : "White";
			print(`CHECKMATE! ${winner} wins!`);
			this.gameRunning = false;
		}
		// Check for check
		else if (this.board.isInCheck(gameState.currentPlayer)) {
			print(`${gameState.currentPlayer === "white" ? "White" : "Black"} is in CHECK!`);
		}

		this.renderer.renderBoard(this.board, gameState.selectedSquare);
		this.renderer.highlightValidMoves(gameState.validMoves);
	}

	selectSquare(row: number, col: number): void {
		this.board.selectSquare(row, col);
		this.updateDisplay();
	}

	private makeAIMove(): void {
		const currentPlayer = this.board.getGameState().currentPlayer;

		if (currentPlayer !== "black") {
			return;
		}

		const move = this.ai.findBestMove(this.board);

		if (move) {
			print(`AI moved from [${move.from.row},${move.from.col}] to [${move.to.row},${move.to.col}]`);
			this.board.selectSquare(move.from.row, move.from.col);
			this.board.selectSquare(move.to.row, move.to.col);
			this.updateDisplay();
		}
	}

	startGame(): void {
		print("Chess game started! Player is White, AI is Black.");
		print("Click on pieces to select them and on highlighted squares to move.");

		let lastPlayer: "white" | "black" = "white";
		let aiThinking = false;

		const connection = game
			.GetService("RunService")
			.Heartbeat.Connect(() => {
				if (!this.gameRunning) {
					connection.Disconnect();
					return;
				}

				const gameState = this.board.getGameState();

				// Check if it's AI's turn and we haven't processed this turn yet
				if (gameState.currentPlayer === "black" && !aiThinking && lastPlayer === "white") {
					aiThinking = true;
					lastPlayer = "black";

					// Delay AI move slightly so the board updates
					task.wait(0.5);
					this.makeAIMove();
					aiThinking = false;
				} else if (gameState.currentPlayer === "white" && lastPlayer === "black") {
					lastPlayer = "white";
				}

			});
	}

	stopGame(): void {
		this.gameRunning = false;
		this.renderer.destroy();
	}
}
