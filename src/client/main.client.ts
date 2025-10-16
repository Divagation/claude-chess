import { ParkEnvironment } from "../shared/parkEnvironment";

declare const workspace: Workspace;

// Remove player character
const players = game.GetService("Players");
const player = players.LocalPlayer;

if (player && player.Character) {
	player.Character.Destroy();
}

// Disable character spawning
player.CharacterAdded.Connect((character: Model) => {
	character.Destroy();
});

// Create park environment
const parkEnvironment = new ParkEnvironment();

// Set up camera focused on chess board
const camera = workspace.CurrentCamera as Camera;
const UserInputService = game.GetService("UserInputService");
const RunService = game.GetService("RunService");

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
	// Handle camera rotation
	if (isRotatingRight) {
		cameraAngle += 2;
	}
	if (isRotatingLeft) {
		cameraAngle -= 2;
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

print("✓ Character removed");
print("✓ Camera setup complete");
print("✓ Use A/D to rotate camera");
print("✓ Use W/S to zoom in/out");
