import { AboutMenu } from "./aboutMenu";
import { UpdatesMenu } from "./updatesMenu";

export class MainMenu {
	private screenGui: ScreenGui;
	private onPlayCallback?: () => void;
	private aboutMenu: AboutMenu | undefined;
	private updatesMenu: UpdatesMenu | undefined;

	constructor(onPlay: () => void) {
		this.onPlayCallback = onPlay;

		const players = game.GetService("Players") as Players;
		const player = players.LocalPlayer;
		const playerGui = player.WaitForChild("PlayerGui") as PlayerGui;

		// Create main ScreenGui - full screen including under top bar
		this.screenGui = new Instance("ScreenGui") as ScreenGui;
		this.screenGui.Name = "ChessMainMenu";
		this.screenGui.ResetOnSpawn = false;
		this.screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling;
		this.screenGui.IgnoreGuiInset = true;
		this.screenGui.Parent = playerGui;

		// Create full-screen background - light ivory
		const background = new Instance("Frame") as Frame;
		background.Name = "Background";
		background.Size = UDim2.fromScale(1, 1);
		background.Position = UDim2.fromScale(0, 0);
		background.BackgroundColor3 = Color3.fromRGB(240, 235, 220);
		background.BackgroundTransparency = 0;
		background.BorderSizePixel = 0;
		background.Parent = this.screenGui;

		// Create centered content container
		const contentContainer = new Instance("Frame") as Frame;
		contentContainer.Name = "ContentContainer";
		contentContainer.Size = UDim2.fromScale(1, 1);
		contentContainer.Position = UDim2.fromScale(0, 0);
		contentContainer.BackgroundTransparency = 1;
		contentContainer.BorderSizePixel = 0;
		contentContainer.Parent = this.screenGui;

		// Title - Large and centered with pawn emoji
		const titleLabel = new Instance("TextLabel") as TextLabel;
		titleLabel.Name = "Title";
		titleLabel.Size = UDim2.fromScale(1, 0.25);
		titleLabel.Position = UDim2.fromScale(0, 0.2);
		titleLabel.BackgroundTransparency = 1;
		titleLabel.Text = "claude ♟️";
		titleLabel.TextColor3 = Color3.fromRGB(40, 40, 40);
		titleLabel.TextScaled = true;
		titleLabel.Font = Enum.Font.GothamBold;
		titleLabel.Parent = contentContainer;

		// Play vs AI Button - Side by side layout
		const playButton = this.createButton(
			"PlayButton",
			"🎮 play",
			UDim2.fromScale(0.15, 0.08),
			UDim2.fromScale(0.25, 0.52),
			Color3.fromRGB(40, 40, 40),
			Color3.fromRGB(100, 100, 100)
		);
		playButton.Parent = contentContainer;

		// Connect play button
		playButton.MouseButton1Click.Connect(() => {
			this.hide();
			if (this.onPlayCallback) {
				this.onPlayCallback();
			}
		});

		// Updates Button
		const updatesButton = this.createButton(
			"UpdatesButton",
			"📋 updates",
			UDim2.fromScale(0.15, 0.08),
			UDim2.fromScale(0.5, 0.52),
			Color3.fromRGB(40, 40, 40),
			Color3.fromRGB(100, 100, 100)
		);
		updatesButton.Parent = contentContainer;

		updatesButton.MouseButton1Click.Connect(() => {
			this.showUpdates();
		});

		// About Button
		const aboutButton = this.createButton(
			"AboutButton",
			"ℹ️ about",
			UDim2.fromScale(0.15, 0.08),
			UDim2.fromScale(0.75, 0.52),
			Color3.fromRGB(40, 40, 40),
			Color3.fromRGB(100, 100, 100)
		);
		aboutButton.Parent = contentContainer;

		aboutButton.MouseButton1Click.Connect(() => {
			this.showAbout();
		});

		print("Main menu created - full screen");
	}

	private createButton(
		name: string,
		text: string,
		size: UDim2,
		position: UDim2,
		normalColor: Color3,
		hoverColor: Color3
	): TextButton {
		const button = new Instance("TextButton") as TextButton;
		button.Name = name;
		button.Size = size;
		button.Position = position;
		button.AnchorPoint = new Vector2(0.5, 0);
		button.BackgroundColor3 = normalColor;
		button.BackgroundTransparency = 1;
		button.BorderSizePixel = 2;
		button.BorderColor3 = normalColor;
		button.Text = text;
		button.TextColor3 = normalColor;
		button.TextScaled = false;
		button.TextSize = 20;
		button.Font = Enum.Font.GothamBold;
		button.AutoButtonColor = false;

		// Hover effects - minimalist style with border only
		button.MouseEnter.Connect(() => {
			button.TextColor3 = hoverColor;
			button.BorderColor3 = hoverColor;
		});

		button.MouseLeave.Connect(() => {
			button.TextColor3 = normalColor;
			button.BorderColor3 = normalColor;
		});

		return button;
	}

	private showAbout(): void {
		this.hide();
		if (!this.aboutMenu) {
			this.aboutMenu = new AboutMenu(() => {
				this.aboutMenu?.hide();
				this.show();
			});
		}
		this.aboutMenu.show();
	}

	private showUpdates(): void {
		this.hide();
		if (!this.updatesMenu) {
			this.updatesMenu = new UpdatesMenu(() => {
				this.updatesMenu?.hide();
				this.show();
			});
		}
		this.updatesMenu.show();
	}

	show(): void {
		this.screenGui.Enabled = true;
	}

	hide(): void {
		this.screenGui.Enabled = false;
	}

	destroy(): void {
		this.screenGui.Destroy();
		if (this.aboutMenu) {
			this.aboutMenu.destroy();
		}
		if (this.updatesMenu) {
			this.updatesMenu.destroy();
		}
	}
}
