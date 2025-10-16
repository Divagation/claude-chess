import { ChessBoard } from "./board";
import { BoardRenderer } from "./renderer";
import { ChessAI } from "./ai";
import { GameUI } from "./gameUI";

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
	private ui: GameUI;
	private gameRunning: boolean = true;
	private lastMoveFrom: { row: number; col: number } | undefined;
	private lastMoveTo: { row: number; col: number } | undefined;

	constructor() {
		this.board = new ChessBoard();
		this.renderer = new BoardRenderer(this.board, (row: number, col: number) => {
			this.selectSquare(row, col);
		});
		this.ai = new ChessAI();
		this.ui = new GameUI();
		currentGameManager = this;
		this.updateDisplay();
	}

	private updateDisplay(): void {
		const gameState = this.board.getGameState();

		// Check for checkmate
		if (this.board.isInCheckmate(gameState.currentPlayer)) {
			const winner = gameState.currentPlayer === "white" ? "black" : "white";
			const isPlayerWinner = winner === "white"; // Player is white, AI is black
			print(`CHECKMATE! ${winner === "white" ? "White" : "Black"} wins!`);
			this.ui.showCheckmate(winner, isPlayerWinner);
			this.gameRunning = false;
		}
		// Check for check
		else if (this.board.isInCheck(gameState.currentPlayer)) {
			print(`${gameState.currentPlayer === "white" ? "White" : "Black"} is in CHECK!`);
			this.ui.showCheck(gameState.currentPlayer);
		}

		this.renderer.renderBoard(this.board, gameState.selectedSquare);
		this.renderer.highlightValidMoves(gameState.validMoves);
	}

	selectSquare(row: number, col: number): void {
		const gameState = this.board.getGameState();

		// Track if this is a piece selection or a move
		if (gameState.selectedSquare) {
			// This is a move attempt
			this.lastMoveFrom = { row: gameState.selectedSquare.row, col: gameState.selectedSquare.col };
			this.lastMoveTo = { row, col };
		}

		const previousPlayer = gameState.currentPlayer;
		this.board.selectSquare(row, col);
		const newGameState = this.board.getGameState();

		// If the player changed, a move was made
		if (newGameState.currentPlayer !== previousPlayer && this.lastMoveFrom && this.lastMoveTo) {
			const piece = this.board.getBoard()[this.lastMoveTo.row][this.lastMoveTo.col];
			if (piece) {
				// Convert board coordinates to chess notation
				const fromNotation = this.coordinatesToNotation(this.lastMoveFrom.row, this.lastMoveFrom.col);
				const toNotation = this.coordinatesToNotation(this.lastMoveTo.row, this.lastMoveTo.col);
				this.ui.addMove(fromNotation, toNotation, piece.type, previousPlayer);
			}
		}

		this.updateDisplay();
	}

	private coordinatesToNotation(row: number, col: number): string {
		const files = ["a", "b", "c", "d", "e", "f", "g", "h"];
		const ranks = ["8", "7", "6", "5", "4", "3", "2", "1"];
		return `${files[col]}${ranks[row]}`;
	}

	private makeAIMove(): void {
		const currentPlayer = this.board.getGameState().currentPlayer;

		if (currentPlayer !== "black") {
			return;
		}

		const move = this.ai.findBestMove(this.board);

		if (move) {
			print(`AI moved from [${move.from.row},${move.from.col}] to [${move.to.row},${move.to.col}]`);

			// selectSquare will automatically track and add the move to UI
			this.selectSquare(move.from.row, move.from.col);
			this.selectSquare(move.to.row, move.to.col);
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
		this.ui.destroy();
	}
}
