export type PieceType = "pawn" | "rook" | "knight" | "bishop" | "queen" | "king";
export type Color = "white" | "black";

export interface Piece {
	type: PieceType;
	color: Color;
	hasMoved?: boolean;
}

export interface Square {
	piece: Piece | undefined;
	row: number;
	col: number;
}

export interface Position {
	row: number;
	col: number;
}

export interface Move {
	from: Position;
	to: Position;
	capturedPiece?: Piece;
	isEnPassant?: boolean;
	isCastling?: boolean;
	promotionPiece?: PieceType;
}

export interface GameState {
	board: (Piece | undefined)[][];
	currentPlayer: Color;
	selectedSquare: Position | undefined;
	validMoves: Position[];
	moveHistory: Move[];
	isCheckmate: boolean;
	isStalemate: boolean;
	isCheck: boolean;
	enPassantTarget: Position | undefined;
	capturedByWhite: Piece[];
	capturedByBlack: Piece[];
}
