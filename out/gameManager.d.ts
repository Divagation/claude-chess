export declare function selectSquareGlobal(row: number, col: number): void;
export declare class GameManager {
    private board;
    private renderer;
    private ai;
    private gameRunning;
    constructor();
    private updateDisplay;
    selectSquare(row: number, col: number): void;
    private makeAIMove;
    startGame(): void;
    stopGame(): void;
}
