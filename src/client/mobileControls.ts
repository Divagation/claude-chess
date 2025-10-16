declare const workspace: Workspace;
declare const players: Players;

export interface CameraControls {
	onRotateLeft: () => void;
	onRotateRight: () => void;
	onZoomIn: () => void;
	onZoomOut: () => void;
}

export class MobileControls {
	private screenGui: ScreenGui;
	private controls: CameraControls;
	private GuiService: GuiService;
	private UserInputService: UserInputService;
	private RunService: RunService;

	// Button state tracking
	private isRotatingLeft = false;
	private isRotatingRight = false;
	private isZoomingIn = false;
	private isZoomingOut = false;

	constructor(controls: CameraControls) {
		print("🔧 Creating MobileControls...");
		this.controls = controls;
		this.GuiService = game.GetService("GuiService");
		this.UserInputService = game.GetService("UserInputService");
		this.RunService = game.GetService("RunService");

		// Create main ScreenGui
		this.screenGui = new Instance("ScreenGui") as ScreenGui;
		this.screenGui.Name = "MobileCameraControls";
		this.screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling;
		this.screenGui.ResetOnSpawn = false;

		// Get the player service and wait for LocalPlayer
		const playersService = game.GetService("Players") as Players;
		const localPlayer = playersService.LocalPlayer;

		if (!localPlayer) {
			print("❌ LocalPlayer not found, cannot create mobile controls");
			return;
		}

		print("📱 Waiting for PlayerGui...");
		const playerGui = localPlayer.WaitForChild("PlayerGui") as PlayerGui;
		this.screenGui.Parent = playerGui;
		print("✅ ScreenGui parented to PlayerGui");

		this.createControls();
		this.setupTouchInteractions();
		this.setupContinuousRotation();
		print("✅ MobileControls created successfully");
	}

	private createControls(): void {
		// Calculate button size based on screen size
		const camera = workspace.CurrentCamera as Camera;
		const viewportSize = camera.ViewportSize;
		const buttonSize = math.min(viewportSize.X, viewportSize.Y) * 0.12; // 12% of smaller screen dimension
		const padding = buttonSize * 0.3;

		// Left rotation button (bottom left)
		this.createButton(
			"RotateLeft",
			"←",
			new UDim2(0, padding, 1, -(buttonSize + padding)),
			new UDim2(0, buttonSize, 0, buttonSize),
			() => this.controls.onRotateLeft(),
			() => { this.isRotatingLeft = true; },
			() => { this.isRotatingLeft = false; }
		);

		// Right rotation button (bottom right)
		this.createButton(
			"RotateRight",
			"→",
			new UDim2(1, -(buttonSize + padding), 1, -(buttonSize + padding)),
			new UDim2(0, buttonSize, 0, buttonSize),
			() => this.controls.onRotateRight(),
			() => { this.isRotatingRight = true; },
			() => { this.isRotatingRight = false; }
		);

		// Zoom in button (right side, above rotation)
		this.createButton(
			"ZoomIn",
			"+",
			new UDim2(1, -(buttonSize + padding), 1, -(buttonSize * 2 + padding * 2)),
			new UDim2(0, buttonSize, 0, buttonSize),
			() => this.controls.onZoomIn(),
			() => { this.isZoomingIn = true; },
			() => { this.isZoomingIn = false; }
		);

		// Zoom out button (right side, above zoom in)
		this.createButton(
			"ZoomOut",
			"-",
			new UDim2(1, -(buttonSize + padding), 1, -(buttonSize * 3 + padding * 3)),
			new UDim2(0, buttonSize, 0, buttonSize),
			() => this.controls.onZoomOut(),
			() => { this.isZoomingOut = true; },
			() => { this.isZoomingOut = false; }
		);

		}

	private createButton(
		name: string,
		text: string,
		position: UDim2,
		size: UDim2,
		onClick: () => void,
		onHoldStart?: () => void,
		onHoldEnd?: () => void
	): void {
		// Create button frame
		const button = new Instance("TextButton") as TextButton;
		button.Name = name;
		button.Size = size;
		button.Position = position;
		button.BackgroundColor3 = Color3.fromRGB(40, 40, 40);
		button.BackgroundTransparency = 0.3;
		button.BorderSizePixel = 0;
		button.Font = Enum.Font.SourceSansBold;
		button.Text = text;
		button.TextColor3 = Color3.fromRGB(255, 255, 255);
		button.TextScaled = true;
		button.Parent = this.screenGui;

		// Add corner rounding
		const corner = new Instance("UICorner");
		corner.CornerRadius = new UDim(0, 8);
		corner.Parent = button;

		// Add shadow effect
		const shadow = new Instance("ImageLabel");
		shadow.Name = "Shadow";
		shadow.Size = new UDim2(1, 4, 1, 4);
		shadow.Position = new UDim2(0, -2, 0, -2);
		shadow.BackgroundTransparency = 1;
		shadow.Image = "rbxasset://textures/ui/Controls/dropdown_shadow.png";
		shadow.ImageColor3 = Color3.fromRGB(0, 0, 0);
		shadow.ImageTransparency = 0.7;
		shadow.ScaleType = Enum.ScaleType.Slice;
		shadow.SliceCenter = new Rect(2, 2, 6, 6);
		shadow.ZIndex = button.ZIndex - 1;
		shadow.Parent = button;

		// Button interaction handling
		let isPressed = false;

		button.MouseEnter.Connect(() => {
			if (!this.UserInputService.TouchEnabled) {
				button.BackgroundColor3 = Color3.fromRGB(60, 60, 60);
				button.BackgroundTransparency = 0.2;
			}
		});

		button.MouseLeave.Connect(() => {
			if (!isPressed) {
				button.BackgroundColor3 = Color3.fromRGB(40, 40, 40);
				button.BackgroundTransparency = 0.3;
			}
		});

		button.MouseButton1Down.Connect(() => {
			isPressed = true;
			button.BackgroundColor3 = Color3.fromRGB(80, 80, 80);
			button.BackgroundTransparency = 0.1;
			onClick();
			if (onHoldStart) {
				onHoldStart();
			}
		});

		button.MouseButton1Up.Connect(() => {
			isPressed = false;
			button.BackgroundColor3 = Color3.fromRGB(40, 40, 40);
			button.BackgroundTransparency = 0.3;
			if (onHoldEnd) {
				onHoldEnd();
			}
		});

		// Touch support
		button.InputBegan.Connect((input: InputObject) => {
			if (input.UserInputType === Enum.UserInputType.Touch) {
				isPressed = true;
				button.BackgroundColor3 = Color3.fromRGB(80, 80, 80);
				button.BackgroundTransparency = 0.1;
				onClick();
				if (onHoldStart) {
					onHoldStart();
				}
			}
		});

		button.InputEnded.Connect((input: InputObject) => {
			if (input.UserInputType === Enum.UserInputType.Touch) {
				isPressed = false;
				button.BackgroundColor3 = Color3.fromRGB(40, 40, 40);
				button.BackgroundTransparency = 0.3;
				if (onHoldEnd) {
					onHoldEnd();
				}
			}
		});
	}

	private setupContinuousRotation(): void {
		this.RunService.RenderStepped.Connect(() => {
			// Continuous rotation while buttons are held
			if (this.isRotatingLeft) {
				this.controls.onRotateLeft();
			}
			if (this.isRotatingRight) {
				this.controls.onRotateRight();
			}
			if (this.isZoomingIn) {
				this.controls.onZoomIn();
			}
			if (this.isZoomingOut) {
				this.controls.onZoomOut();
			}
		});
	}

	private setupTouchInteractions(): void {
		// Touch interactions are handled by the button Touch events in createButton
		// Future enhancement: Add swipe gestures and pinch-to-zoom
		print("✓ Touch interactions configured");
	}

	
	public destroy(): void {
		if (this.screenGui) {
			this.screenGui.Destroy();
		}
	}

	public setVisible(visible: boolean): void {
		this.screenGui.Enabled = visible;
	}

	public isVisible(): boolean {
		return this.screenGui.Enabled;
	}
}