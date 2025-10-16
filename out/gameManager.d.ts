import { GameUI } from "./gameUI";
export declare function selectSquareGlobal(row: number, col: number): void;
export declare class GameManager {
    private board;
    private renderer;
    private ai;
    private ui;
    private gameRunning;
    private lastMoveFrom;
    private lastMoveTo;
    constructor();
    getUI(): GameUI;
    private updateDisplay;
    selectSquare(row: number, col: number): void;
    private coordinatesToNotation;
    private makeAIMove;
    startGame(): void;
    stopGame(): void;
}
