export class GameUI {
	private screenGui: ScreenGui;
	private moveHistoryFrame: Frame;
	private moveHistoryLabel: TextLabel;
	private gameStateLabel: TextLabel;
	private moveHistory: string[] = [];

	constructor() {
		const players = game.GetService("Players") as Players;
		const player = players.LocalPlayer;
		const playerGui = player.WaitForChild("PlayerGui") as PlayerGui;

		// Create main ScreenGui
		this.screenGui = new Instance("ScreenGui") as ScreenGui;
		this.screenGui.Name = "ChessGameUI";
		this.screenGui.ResetOnSpawn = false;
		this.screenGui.Parent = playerGui;

		// Create move history display
		this.moveHistoryFrame = new Instance("Frame") as Frame;
		this.moveHistoryFrame.Name = "MoveHistory";
		this.moveHistoryFrame.Size = UDim2.fromScale(0.3, 0.15);
		this.moveHistoryFrame.Position = UDim2.fromScale(0.35, 0.02);
		this.moveHistoryFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 30);
		this.moveHistoryFrame.BackgroundTransparency = 0.3;
		this.moveHistoryFrame.BorderSizePixel = 2;
		this.moveHistoryFrame.BorderColor3 = Color3.fromRGB(200, 200, 200);
		this.moveHistoryFrame.Parent = this.screenGui;

		// Add rounded corners to move history
		const moveHistoryCorner = new Instance("UICorner") as UICorner;
		moveHistoryCorner.CornerRadius = new UDim(0, 8);
		moveHistoryCorner.Parent = this.moveHistoryFrame;

		// Title for move history
		const moveHistoryTitle = new Instance("TextLabel") as TextLabel;
		moveHistoryTitle.Name = "Title";
		moveHistoryTitle.Size = UDim2.fromScale(1, 0.25);
		moveHistoryTitle.Position = UDim2.fromScale(0, 0);
		moveHistoryTitle.BackgroundTransparency = 1;
		moveHistoryTitle.Text = "Recent Moves";
		moveHistoryTitle.TextColor3 = Color3.fromRGB(255, 255, 255);
		moveHistoryTitle.TextScaled = true;
		moveHistoryTitle.Font = Enum.Font.GothamBold;
		moveHistoryTitle.Parent = this.moveHistoryFrame;

		// Move history text
		this.moveHistoryLabel = new Instance("TextLabel") as TextLabel;
		this.moveHistoryLabel.Name = "MovesText";
		this.moveHistoryLabel.Size = UDim2.fromScale(0.95, 0.7);
		this.moveHistoryLabel.Position = UDim2.fromScale(0.025, 0.28);
		this.moveHistoryLabel.BackgroundTransparency = 1;
		this.moveHistoryLabel.Text = "No moves yet";
		this.moveHistoryLabel.TextColor3 = Color3.fromRGB(220, 220, 220);
		this.moveHistoryLabel.TextScaled = false;
		this.moveHistoryLabel.TextSize = 16;
		this.moveHistoryLabel.Font = Enum.Font.Gotham;
		this.moveHistoryLabel.TextXAlignment = Enum.TextXAlignment.Left;
		this.moveHistoryLabel.TextYAlignment = Enum.TextYAlignment.Top;
		this.moveHistoryLabel.TextWrapped = true;
		this.moveHistoryLabel.Parent = this.moveHistoryFrame;

		// Create game state message label (Check/Checkmate)
		this.gameStateLabel = new Instance("TextLabel") as TextLabel;
		this.gameStateLabel.Name = "GameState";
		this.gameStateLabel.Size = UDim2.fromScale(0.5, 0.12);
		this.gameStateLabel.Position = UDim2.fromScale(0.25, 0.4);
		this.gameStateLabel.BackgroundColor3 = Color3.fromRGB(0, 0, 0);
		this.gameStateLabel.BackgroundTransparency = 0.2;
		this.gameStateLabel.BorderSizePixel = 3;
		this.gameStateLabel.Text = "";
		this.gameStateLabel.TextColor3 = Color3.fromRGB(255, 255, 255);
		this.gameStateLabel.TextScaled = true;
		this.gameStateLabel.Font = Enum.Font.GothamBold;
		this.gameStateLabel.Visible = false;
		this.gameStateLabel.Parent = this.screenGui;

		// Add rounded corners to game state
		const gameStateCorner = new Instance("UICorner") as UICorner;
		gameStateCorner.CornerRadius = new UDim(0, 12);
		gameStateCorner.Parent = this.gameStateLabel;

		// Add padding
		const padding = new Instance("UIPadding") as UIPadding;
		padding.PaddingLeft = new UDim(0, 20);
		padding.PaddingRight = new UDim(0, 20);
		padding.PaddingTop = new UDim(0, 10);
		padding.PaddingBottom = new UDim(0, 10);
		padding.Parent = this.gameStateLabel;
	}

	addMove(from: string, to: string, piece: string, color: "white" | "black"): void {
		const moveNotation = `${color === "white" ? "White" : "Black"} ${piece}: ${from} → ${to}`;
		this.moveHistory.push(moveNotation);

		// Keep only last 3 moves
		if (this.moveHistory.size() > 3) {
			this.moveHistory.shift();
		}

		// Update display
		this.moveHistoryLabel.Text = this.moveHistory.join("\n");
	}

	showCheck(playerColor: "white" | "black"): void {
		this.gameStateLabel.Text = "Check!";
		this.gameStateLabel.TextColor3 = Color3.fromRGB(255, 200, 0);
		this.gameStateLabel.BorderColor3 = Color3.fromRGB(255, 200, 0);
		this.gameStateLabel.Visible = true;

		// Hide after 2 seconds
		task.delay(2, () => {
			this.gameStateLabel.Visible = false;
		});
	}

	showCheckmate(winner: "white" | "black", isPlayerWinner: boolean): void {
		if (isPlayerWinner) {
			this.gameStateLabel.Text = "Checkmate! You Win!";
			this.gameStateLabel.TextColor3 = Color3.fromRGB(0, 255, 100);
			this.gameStateLabel.BorderColor3 = Color3.fromRGB(0, 255, 100);
		} else {
			this.gameStateLabel.Text = "Checkmate! You Lose!";
			this.gameStateLabel.TextColor3 = Color3.fromRGB(255, 50, 50);
			this.gameStateLabel.BorderColor3 = Color3.fromRGB(255, 50, 50);
		}
		this.gameStateLabel.Visible = true;
		// Don't hide checkmate message
	}

	clearGameState(): void {
		this.gameStateLabel.Visible = false;
	}

	destroy(): void {
		this.screenGui.Destroy();
	}
}
