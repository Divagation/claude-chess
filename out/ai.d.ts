import { ChessBoard } from "./board";
import { Move } from "./types";
export declare class ChessAI {
    private maxDepth;
    findBestMove(board: ChessBoard): Move | undefined;
    private minimax;
    private makeMove;
    private evaluatePosition;
    private copyBoard;
}
