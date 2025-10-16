export class GameUI {
	private screenGui: ScreenGui;
	private moveHistoryFrame: Frame;
	private moveHistoryLabel: TextLabel;
	private gameStateLabel: TextLabel;
	private moveHistory: string[] = [];
	private onGameEndCallback?: () => void;
	private onBackToMenuCallback?: () => void;

	constructor() {
		const players = game.GetService("Players") as Players;
		const player = players.LocalPlayer;
		const playerGui = player.WaitForChild("PlayerGui") as PlayerGui;

		// Create main ScreenGui
		this.screenGui = new Instance("ScreenGui") as ScreenGui;
		this.screenGui.Name = "ChessGameUI";
		this.screenGui.ResetOnSpawn = false;
		this.screenGui.Parent = playerGui;

		// Create minimalist move history display (top left)
		this.moveHistoryFrame = new Instance("Frame") as Frame;
		this.moveHistoryFrame.Name = "MoveHistory";
		this.moveHistoryFrame.Size = UDim2.fromScale(0.15, 0.2);
		this.moveHistoryFrame.Position = UDim2.fromScale(0.02, 0.15);
		this.moveHistoryFrame.BackgroundTransparency = 1;
		this.moveHistoryFrame.BorderSizePixel = 0;
		this.moveHistoryFrame.Parent = this.screenGui;

		// Move history text - minimalist
		this.moveHistoryLabel = new Instance("TextLabel") as TextLabel;
		this.moveHistoryLabel.Name = "MovesText";
		this.moveHistoryLabel.Size = UDim2.fromScale(1, 1);
		this.moveHistoryLabel.Position = UDim2.fromScale(0, 0);
		this.moveHistoryLabel.BackgroundTransparency = 1;
		this.moveHistoryLabel.Text = "";
		this.moveHistoryLabel.TextColor3 = Color3.fromRGB(255, 255, 255);
		this.moveHistoryLabel.TextScaled = false;
		this.moveHistoryLabel.TextSize = 12;
		this.moveHistoryLabel.Font = Enum.Font.Gotham;
		this.moveHistoryLabel.TextXAlignment = Enum.TextXAlignment.Left;
		this.moveHistoryLabel.TextYAlignment = Enum.TextYAlignment.Top;
		this.moveHistoryLabel.TextWrapped = true;
		this.moveHistoryLabel.Parent = this.moveHistoryFrame;

		// Create game state message label (Check/Checkmate) - centered, minimalist
		this.gameStateLabel = new Instance("TextLabel") as TextLabel;
		this.gameStateLabel.Name = "GameState";
		this.gameStateLabel.Size = UDim2.fromScale(0.4, 0.1);
		this.gameStateLabel.Position = UDim2.fromScale(0.3, 0.45);
		this.gameStateLabel.AnchorPoint = new Vector2(0.5, 0.5);
		this.gameStateLabel.BackgroundTransparency = 1;
		this.gameStateLabel.BorderSizePixel = 0;
		this.gameStateLabel.Text = "";
		this.gameStateLabel.TextColor3 = Color3.fromRGB(255, 255, 255);
		this.gameStateLabel.TextScaled = true;
		this.gameStateLabel.Font = Enum.Font.GothamBold;
		this.gameStateLabel.Visible = false;
		this.gameStateLabel.Parent = this.screenGui;

		// Create back button - top left corner (door emoji) - positioned below Roblox top bar
		const backButton = new Instance("TextButton") as TextButton;
		backButton.Name = "BackButton";
		backButton.Size = UDim2.fromScale(0.08, 0.08);
		backButton.Position = UDim2.fromScale(0.02, 0.06);
		backButton.BackgroundTransparency = 1;
		backButton.BorderSizePixel = 0;
		backButton.Text = "🚪";
		backButton.TextColor3 = Color3.fromRGB(255, 255, 255);
		backButton.TextScaled = true;
		backButton.Font = Enum.Font.GothamBold;
		backButton.AutoButtonColor = false;
		backButton.Parent = this.screenGui;

		// Hover effect for back button
		backButton.MouseEnter.Connect(() => {
			backButton.TextColor3 = Color3.fromRGB(200, 200, 200);
		});

		backButton.MouseLeave.Connect(() => {
			backButton.TextColor3 = Color3.fromRGB(255, 255, 255);
		});

		// Back button click - show confirmation
		backButton.MouseButton1Click.Connect(() => {
			this.showConfirmationDialog();
		});
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
		this.gameStateLabel.Visible = true;

		// Hide after 1.5 seconds
		task.delay(1.5, () => {
			this.gameStateLabel.Visible = false;
		});
	}

	showCheckmate(winner: "white" | "black", isPlayerWinner: boolean): void {
		if (isPlayerWinner) {
			this.gameStateLabel.Text = "YOU WIN";
			this.gameStateLabel.TextColor3 = Color3.fromRGB(0, 255, 100);
		} else {
			this.gameStateLabel.Text = "YOU LOSE";
			this.gameStateLabel.TextColor3 = Color3.fromRGB(255, 50, 50);
		}
		this.gameStateLabel.Visible = true;

		// Return to menu after 2 seconds
		task.delay(2, () => {
			if (this.onGameEndCallback) {
				this.onGameEndCallback();
			}
		});
	}

	setOnGameEndCallback(callback: () => void): void {
		this.onGameEndCallback = callback;
	}

	setOnBackToMenuCallback(callback: () => void): void {
		this.onBackToMenuCallback = callback;
	}

	private showConfirmationDialog(): void {
		const players = game.GetService("Players") as Players;
		const player = players.LocalPlayer;
		const playerGui = player.WaitForChild("PlayerGui") as PlayerGui;

		// Create confirmation dialog GUI
		const dialogGui = new Instance("ScreenGui") as ScreenGui;
		dialogGui.Name = "ConfirmationDialog";
		dialogGui.ResetOnSpawn = false;
		dialogGui.Parent = playerGui;

		// Semi-transparent overlay
		const overlay = new Instance("Frame") as Frame;
		overlay.Name = "Overlay";
		overlay.Size = UDim2.fromScale(1, 1);
		overlay.BackgroundColor3 = Color3.fromRGB(0, 0, 0);
		overlay.BackgroundTransparency = 0.7;
		overlay.BorderSizePixel = 0;
		overlay.Parent = dialogGui;

		// Dialog box - minimalist
		const dialog = new Instance("Frame") as Frame;
		dialog.Name = "Dialog";
		dialog.Size = UDim2.fromScale(0.4, 0.25);
		dialog.Position = UDim2.fromScale(0.5, 0.5);
		dialog.AnchorPoint = new Vector2(0.5, 0.5);
		dialog.BackgroundColor3 = Color3.fromRGB(240, 235, 220);
		dialog.BackgroundTransparency = 0;
		dialog.BorderSizePixel = 0;
		dialog.Parent = dialogGui;

		// Title
		const title = new Instance("TextLabel") as TextLabel;
		title.Name = "Title";
		title.Size = UDim2.fromScale(1, 0.4);
		title.Position = UDim2.fromScale(0, 0.05);
		title.BackgroundTransparency = 1;
		title.Text = "Leave game?";
		title.TextColor3 = Color3.fromRGB(40, 40, 40);
		title.TextScaled = true;
		title.Font = Enum.Font.GothamBold;
		title.Parent = dialog;

		// Warning message
		const message = new Instance("TextLabel") as TextLabel;
		message.Name = "Message";
		message.Size = UDim2.fromScale(0.9, 0.3);
		message.Position = UDim2.fromScale(0.05, 0.35);
		message.BackgroundTransparency = 1;
		message.Text = "Board will be cleared";
		message.TextColor3 = Color3.fromRGB(100, 100, 100);
		message.TextScaled = false;
		message.TextSize = 14;
		message.Font = Enum.Font.Gotham;
		message.TextWrapped = true;
		message.Parent = dialog;

		// Yes button
		const yesButton = new Instance("TextButton") as TextButton;
		yesButton.Name = "YesButton";
		yesButton.Size = UDim2.fromScale(0.35, 0.18);
		yesButton.Position = UDim2.fromScale(0.08, 0.75);
		yesButton.BackgroundTransparency = 1;
		yesButton.BorderSizePixel = 1;
		yesButton.BorderColor3 = Color3.fromRGB(40, 40, 40);
		yesButton.Text = "YES";
		yesButton.TextColor3 = Color3.fromRGB(40, 40, 40);
		yesButton.TextScaled = true;
		yesButton.Font = Enum.Font.GothamBold;
		yesButton.AutoButtonColor = false;
		yesButton.Parent = dialog;

		// No button
		const noButton = new Instance("TextButton") as TextButton;
		noButton.Name = "NoButton";
		noButton.Size = UDim2.fromScale(0.35, 0.18);
		noButton.Position = UDim2.fromScale(0.57, 0.75);
		noButton.BackgroundTransparency = 1;
		noButton.BorderSizePixel = 1;
		noButton.BorderColor3 = Color3.fromRGB(40, 40, 40);
		noButton.Text = "NO";
		noButton.TextColor3 = Color3.fromRGB(40, 40, 40);
		noButton.TextScaled = true;
		noButton.Font = Enum.Font.GothamBold;
		noButton.AutoButtonColor = false;
		noButton.Parent = dialog;

		// Yes button action
		yesButton.MouseButton1Click.Connect(() => {
			dialogGui.Destroy();
			if (this.onBackToMenuCallback) {
				this.onBackToMenuCallback();
			}
		});

		// No button action
		noButton.MouseButton1Click.Connect(() => {
			dialogGui.Destroy();
		});

		// Hover effects
		yesButton.MouseEnter.Connect(() => {
			yesButton.BorderColor3 = Color3.fromRGB(0, 0, 0);
			yesButton.TextColor3 = Color3.fromRGB(0, 0, 0);
		});

		yesButton.MouseLeave.Connect(() => {
			yesButton.BorderColor3 = Color3.fromRGB(40, 40, 40);
			yesButton.TextColor3 = Color3.fromRGB(40, 40, 40);
		});

		noButton.MouseEnter.Connect(() => {
			noButton.BorderColor3 = Color3.fromRGB(0, 0, 0);
			noButton.TextColor3 = Color3.fromRGB(0, 0, 0);
		});

		noButton.MouseLeave.Connect(() => {
			noButton.BorderColor3 = Color3.fromRGB(40, 40, 40);
			noButton.TextColor3 = Color3.fromRGB(40, 40, 40);
		});
	}

	clearGameState(): void {
		this.gameStateLabel.Visible = false;
	}

	destroy(): void {
		this.screenGui.Destroy();
	}
}
