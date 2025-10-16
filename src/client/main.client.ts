import { ParkEnvironment } from "../shared/parkEnvironment";
import { MobileControls } from "./mobileControls";

declare const workspace: Workspace;

// Remove player character
const players = game.GetService("Players") as Players;
const player = players.LocalPlayer;

if (player && player.Character) {
	player.Character.Destroy();
}

// Disable character spawning
if (player) {
	player.CharacterAdded.Connect((character: Model) => {
		character.Destroy();
	});
}

// Create park environment
const parkEnvironment = new ParkEnvironment();

// Set up camera focused on chess board
const camera = workspace.CurrentCamera as Camera;
const UserInputService = game.GetService("UserInputService");
const RunService = game.GetService("RunService");

// Mobile controls instance
let mobileControls: MobileControls | undefined;

// Board parameters
const boardCenterX = 8;
const boardCenterZ = 8;
const boardCenterY = 5;
let cameraDistance = 20;
let cameraHeight = 12;
let cameraAngle = 0;

// Update camera position based on input
let isRotatingRight = false;
let isRotatingLeft = false;
let isZoomingIn = false;
let isZoomingOut = false;

UserInputService.InputBegan.Connect((input: InputObject) => {
	if (input.KeyCode === Enum.KeyCode.D) {
		isRotatingRight = true;
	} else if (input.KeyCode === Enum.KeyCode.A) {
		isRotatingLeft = true;
	} else if (input.KeyCode === Enum.KeyCode.W) {
		isZoomingIn = true;
	} else if (input.KeyCode === Enum.KeyCode.S) {
		isZoomingOut = true;
	}
});

UserInputService.InputEnded.Connect((input: InputObject) => {
	if (input.KeyCode === Enum.KeyCode.D) {
		isRotatingRight = false;
	} else if (input.KeyCode === Enum.KeyCode.A) {
		isRotatingLeft = false;
	} else if (input.KeyCode === Enum.KeyCode.W) {
		isZoomingIn = false;
	} else if (input.KeyCode === Enum.KeyCode.S) {
		isZoomingOut = false;
	}
});

RunService.RenderStepped.Connect(() => {
	// Handle camera rotation (faster speed)
	if (isRotatingRight) {
		cameraAngle += 4;
	}
	if (isRotatingLeft) {
		cameraAngle -= 4;
	}

	// Handle zoom
	if (isZoomingIn) {
		cameraDistance = math.max(10, cameraDistance - 0.5);
	}
	if (isZoomingOut) {
		cameraDistance = math.min(30, cameraDistance + 0.5);
	}

	// Convert angle to radians
	const angleRad = math.rad(cameraAngle);
	const cameraX = boardCenterX + math.cos(angleRad) * cameraDistance;
	const cameraZ = boardCenterZ - math.sin(angleRad) * cameraDistance;
	const cameraY = cameraHeight;

	const cameraPosition = new Vector3(cameraX, cameraY, cameraZ);
	const lookAtPosition = new Vector3(boardCenterX, boardCenterY, boardCenterZ);

	camera.CFrame = new CFrame(cameraPosition, lookAtPosition);
});

// Platform detection and mobile controls setup
function setupMobileControls(): void {
	// Debug logging
	print("🔍 Platform Detection Debug:");
	print(`TouchEnabled: ${UserInputService.TouchEnabled}`);
	print(`KeyboardEnabled: ${UserInputService.KeyboardEnabled}`);
	print(`MouseEnabled: ${UserInputService.MouseEnabled}`);

	// Check if user is on a mobile device
	const isMobileDevice = UserInputService.TouchEnabled &&
						  !UserInputService.KeyboardEnabled &&
						  !UserInputService.MouseEnabled;

	// Also check for tablets (touch enabled but may have keyboard/mouse)
	const isTablet = UserInputService.TouchEnabled &&
						(UserInputService.KeyboardEnabled || UserInputService.MouseEnabled);

	print(`isMobileDevice: ${isMobileDevice}`);
	print(`isTablet: ${isTablet}`);

	// Only show mobile controls on touch-enabled devices
	if (UserInputService.TouchEnabled) {
		mobileControls = new MobileControls({
			onRotateLeft: () => {
				cameraAngle -= 4;
			},
			onRotateRight: () => {
				cameraAngle += 4;
			},
			onZoomIn: () => {
				cameraDistance = math.max(10, cameraDistance - 0.5);
			},
			onZoomOut: () => {
				cameraDistance = math.min(30, cameraDistance + 0.5);
			}
		});

		print("✓ Mobile controls enabled");
	}
}

// Wait for player to be fully loaded before setting up controls
if (player) {
	player.CharacterAdded.Wait();
}
setupMobileControls();

print("✓ Character removed");
print("✓ Camera setup complete");
print("✓ Desktop: Use A/D to rotate camera, W/S to zoom");
print("✓ Mobile: Use on-screen buttons or touch gestures");