import { GameManager } from "../gameManager";

// Remove baseplate and spawn locations
const workspace = game.GetService("Workspace");

// Remove baseplate
const baseplate = workspace.FindFirstChild("Baseplate");
if (baseplate) {
	baseplate.Destroy();
}

// Remove spawn location
const spawnLocation = workspace.FindFirstChild("SpawnLocation");
if (spawnLocation) {
	spawnLocation.Destroy();
}

// Remove any other default parts
const parts = workspace.FindFirstChildOfClass("Part");
if (parts) {
	const allParts = workspace.GetDescendants();
	for (const part of allParts) {
		if (part.IsA("Part") && (part.Name === "Baseplate" || part.Name === "SpawnLocation")) {
			part.Destroy();
		}
	}
}

// Remove any existing ChessBoard folders from previous runs
const existingChessBoards = workspace.GetChildren();
for (const child of existingChessBoards) {
	if (child.Name === "ChessBoard") {
		child.Destroy();
	}
}

// Start the game
const gameManager = new GameManager();
gameManager.startGame();

print("✓ Baseplate and spawn location removed");
print("✓ Chess game started");
