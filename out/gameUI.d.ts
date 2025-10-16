export declare class GameUI {
    private screenGui;
    private moveHistoryFrame;
    private moveHistoryLabel;
    private gameStateLabel;
    private moveHistory;
    private onGameEndCallback?;
    private onBackToMenuCallback?;
    constructor();
    addMove(from: string, to: string, piece: string, color: "white" | "black"): void;
    showCheck(playerColor: "white" | "black"): void;
    showCheckmate(winner: "white" | "black", isPlayerWinner: boolean): void;
    setOnGameEndCallback(callback: () => void): void;
    setOnBackToMenuCallback(callback: () => void): void;
    private showConfirmationDialog;
    clearGameState(): void;
    destroy(): void;
}
