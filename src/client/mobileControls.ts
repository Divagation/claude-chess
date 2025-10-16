declare const workspace: Workspace;
declare const players: Players;

export interface CameraControls {
	onRotateLeft: () => void;
	onRotateRight: () => void;
	onZoomIn: () => void;
	onZoomOut: () => void;
	onRotateDelta?: (delta: number) => void;
	onZoomDelta?: (delta: number) => void;
}

export class MobileControls {
	private controls: CameraControls;
	private UserInputService: UserInputService;

	constructor(controls: CameraControls) {
		print("🔧 Creating MobileControls...");
		this.controls = controls;
		this.UserInputService = game.GetService("UserInputService");

		this.setupTouchInteractions();
		print("✅ MobileControls created successfully (swipe & pinch gestures)");
	}


	private setupTouchInteractions(): void {
		let lastTouchPosition: Vector2 | undefined;
		let isSingleTouch = false;

		this.UserInputService.InputBegan.Connect((input: InputObject, gameProcessedEvent: boolean) => {
			if (gameProcessedEvent) return;

			if (input.UserInputType === Enum.UserInputType.Touch) {
				// Start tracking single touch drag
				if (!isSingleTouch) {
					isSingleTouch = true;
					lastTouchPosition = new Vector2(input.Position.X, input.Position.Y);
				}
			}
		});

		this.UserInputService.InputChanged.Connect((input: InputObject, gameProcessedEvent: boolean) => {
			if (gameProcessedEvent) return;

			if (input.UserInputType === Enum.UserInputType.Touch && isSingleTouch && lastTouchPosition) {
				const currentPos = new Vector2(input.Position.X, input.Position.Y);
				const delta = currentPos.sub(lastTouchPosition);

				// Horizontal swipe rotates camera
				if (this.controls.onRotateDelta) {
					const rotationSpeed = 0.3;
					this.controls.onRotateDelta(delta.X * rotationSpeed);
				}

				lastTouchPosition = currentPos;
			}
		});

		this.UserInputService.InputEnded.Connect((input: InputObject, gameProcessedEvent: boolean) => {
			if (input.UserInputType === Enum.UserInputType.Touch) {
				isSingleTouch = false;
				lastTouchPosition = undefined;
			}
		});

		// Pinch to zoom using TouchPinch
		this.UserInputService.TouchPinch.Connect((touchPositions: Vector2[], scale: number, velocity: number, state: Enum.UserInputState, gameProcessedEvent: boolean) => {
			if (gameProcessedEvent) return;

			if (this.controls.onZoomDelta && state === Enum.UserInputState.Change) {
				// Scale > 1 means zooming out, scale < 1 means zooming in
				const zoomDelta = (1 - scale) * 2;
				this.controls.onZoomDelta(zoomDelta);
			}
		});

		print("✓ Touch swipe and pinch gestures configured");
	}
}