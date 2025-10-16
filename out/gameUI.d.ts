export declare class GameUI {
    private screenGui;
    private moveHistoryFrame;
    private moveHistoryLabel;
    private gameStateLabel;
    private moveHistory;
    constructor();
    addMove(from: string, to: string, piece: string, color: "white" | "black"): void;
    showCheck(playerColor: "white" | "black"): void;
    showCheckmate(winner: "white" | "black", isPlayerWinner: boolean): void;
    clearGameState(): void;
    destroy(): void;
}
