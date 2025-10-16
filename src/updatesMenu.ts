export class UpdatesMenu {
	private screenGui: ScreenGui;
	private onBackCallback?: () => void;

	constructor(onBack: () => void) {
		this.onBackCallback = onBack;

		const players = game.GetService("Players") as Players;
		const player = players.LocalPlayer;
		const playerGui = player.WaitForChild("PlayerGui") as PlayerGui;

		// Create main ScreenGui
		this.screenGui = new Instance("ScreenGui") as ScreenGui;
		this.screenGui.Name = "UpdatesMenu";
		this.screenGui.ResetOnSpawn = false;
		this.screenGui.IgnoreGuiInset = true;
		this.screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling;
		this.screenGui.Parent = playerGui;

		// Full-screen background
		const background = new Instance("Frame") as Frame;
		background.Name = "Background";
		background.Size = UDim2.fromScale(1, 1);
		background.BackgroundColor3 = Color3.fromRGB(240, 235, 220);
		background.BorderSizePixel = 0;
		background.Parent = this.screenGui;

		// Content container
		const contentContainer = new Instance("Frame") as Frame;
		contentContainer.Name = "ContentContainer";
		contentContainer.Size = UDim2.fromScale(1, 1);
		contentContainer.BackgroundTransparency = 1;
		contentContainer.BorderSizePixel = 0;
		contentContainer.Parent = this.screenGui;

		// Back button (door emoji) - positioned below Roblox top bar
		const backButton = new Instance("TextButton") as TextButton;
		backButton.Name = "BackButton";
		backButton.Size = UDim2.fromScale(0.1, 0.1);
		backButton.Position = UDim2.fromScale(0.02, 0.12);
		backButton.BackgroundTransparency = 1;
		backButton.BorderSizePixel = 0;
		backButton.Text = "🚪";
		backButton.TextColor3 = Color3.fromRGB(40, 40, 40);
		backButton.TextScaled = true;
		backButton.Font = Enum.Font.GothamBold;
		backButton.AutoButtonColor = false;
		backButton.Parent = contentContainer;

		backButton.MouseEnter.Connect(() => {
			backButton.TextColor3 = Color3.fromRGB(100, 100, 100);
		});

		backButton.MouseLeave.Connect(() => {
			backButton.TextColor3 = Color3.fromRGB(40, 40, 40);
		});

		backButton.MouseButton1Click.Connect(() => {
			this.hide();
			if (this.onBackCallback) {
				this.onBackCallback();
			}
		});

		// Title
		const titleLabel = new Instance("TextLabel") as TextLabel;
		titleLabel.Name = "Title";
		titleLabel.Size = UDim2.fromScale(1, 0.12);
		titleLabel.Position = UDim2.fromScale(0, 0.12);
		titleLabel.BackgroundTransparency = 1;
		titleLabel.Text = "updates";
		titleLabel.TextColor3 = Color3.fromRGB(40, 40, 40);
		titleLabel.TextScaled = true;
		titleLabel.Font = Enum.Font.GothamBold;
		titleLabel.Parent = contentContainer;

		// Updates text
		const updatesText = new Instance("TextLabel") as TextLabel;
		updatesText.Name = "UpdatesText";
		updatesText.Size = UDim2.fromScale(0.85, 0.7);
		updatesText.Position = UDim2.fromScale(0.075, 0.28);
		updatesText.BackgroundTransparency = 1;
		updatesText.Text = "v1.1 alpha\n\n• full-screen main menu with minimalist ivory design\n• emoji-enhanced buttons (🎮 play, 📋 updates, ℹ️ about)\n• back to main menu button with confirmation dialog\n• move history relocated to left side\n• minimalist game ui throughout\n• mobile landscape orientation detection\n• about and updates menus\n• lowercase ui consistency\n• large pawn emoji on about page\n• back button positioned below roblox top bar";
		updatesText.TextColor3 = Color3.fromRGB(40, 40, 40);
		updatesText.TextScaled = false;
		updatesText.TextSize = 16;
		updatesText.Font = Enum.Font.Gotham;
		updatesText.TextWrapped = true;
		updatesText.TextYAlignment = Enum.TextYAlignment.Top;
		updatesText.TextXAlignment = Enum.TextXAlignment.Left;
		updatesText.Parent = contentContainer;

		print("Updates menu created");
	}

	show(): void {
		this.screenGui.Enabled = true;
	}

	hide(): void {
		this.screenGui.Enabled = false;
	}

	destroy(): void {
		this.screenGui.Destroy();
	}
}
