export class AboutMenu {
	private screenGui: ScreenGui;
	private onBackCallback?: () => void;

	constructor(onBack: () => void) {
		this.onBackCallback = onBack;

		const players = game.GetService("Players") as Players;
		const player = players.LocalPlayer;
		const playerGui = player.WaitForChild("PlayerGui") as PlayerGui;

		// Create main ScreenGui
		this.screenGui = new Instance("ScreenGui") as ScreenGui;
		this.screenGui.Name = "AboutMenu";
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
		titleLabel.Size = UDim2.fromScale(1, 0.15);
		titleLabel.Position = UDim2.fromScale(0, 0.15);
		titleLabel.BackgroundTransparency = 1;
		titleLabel.Text = "about";
		titleLabel.TextColor3 = Color3.fromRGB(40, 40, 40);
		titleLabel.TextScaled = true;
		titleLabel.Font = Enum.Font.GothamBold;
		titleLabel.Parent = contentContainer;

		// About text
		const aboutText = new Instance("TextLabel") as TextLabel;
		aboutText.Name = "AboutText";
		aboutText.Size = UDim2.fromScale(0.8, 0.4);
		aboutText.Position = UDim2.fromScale(0.1, 0.28);
		aboutText.BackgroundTransparency = 1;
		aboutText.Text = "hello! this chess game is made by f4II and claude code as an example of how powerful claude can be for use in roblox development. thanks for checking it out, and enjoy the game!";
		aboutText.TextColor3 = Color3.fromRGB(40, 40, 40);
		aboutText.TextScaled = false;
		aboutText.TextSize = 18;
		aboutText.Font = Enum.Font.Gotham;
		aboutText.TextWrapped = true;
		aboutText.TextYAlignment = Enum.TextYAlignment.Top;
		aboutText.Parent = contentContainer;

		// Cool emoji at bottom
		const emojiLabel = new Instance("TextLabel") as TextLabel;
		emojiLabel.Name = "EmojiLabel";
		emojiLabel.Size = UDim2.fromScale(1, 0.2);
		emojiLabel.Position = UDim2.fromScale(0, 0.65);
		emojiLabel.BackgroundTransparency = 1;
		emojiLabel.Text = "♟️";
		emojiLabel.TextColor3 = Color3.fromRGB(40, 40, 40);
		emojiLabel.TextScaled = true;
		emojiLabel.Font = Enum.Font.GothamBold;
		emojiLabel.Parent = contentContainer;

		print("About menu created");
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
