import { ChessBoard } from "./board";
export declare class BoardRenderer {
    private boardParts;
    private pieceParts;
    private workspace;
    private boardContainer;
    private highlightParts;
    private board;
    private capturedPieceParts;
    private onSquareSelect;
    constructor(board: ChessBoard, onSquareSelect: (row: number, col: number) => void);
    private createTable;
    renderBoard(board: ChessBoard, selectedSquare: {
        row: number;
        col: number;
    } | undefined): void;
    private renderPiece;
    highlightValidMoves(validMoves: {
        row: number;
        col: number;
    }[]): void;
    private renderCapturedPieces;
    destroy(): void;
}
