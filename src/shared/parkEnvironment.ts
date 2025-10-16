declare const workspace: Workspace;

const GRASS_Y_POSITION = 0; // Ground level for grass - flush with table legs

export class ParkEnvironment {
	private parkContainer: Folder;

	constructor() {
		this.parkContainer = new Instance("Folder") as Folder;
		this.parkContainer.Name = "ParkEnvironment";
		this.parkContainer.Parent = workspace;

		this.createGrassTerrain();
		this.createTrees();
		this.createPaths();
		this.createDecorations();
	}

	private createGrassTerrain(): void {
		// Create an enormous grass base - the scale of a massive park
		const grassBase = new Instance("Part") as Part;
		grassBase.Name = "GrassBase";
		grassBase.Size = new Vector3(500, 2, 500); // Enormous park area
		grassBase.Position = new Vector3(7, GRASS_Y_POSITION, 7); // Centered on chess table
		grassBase.Anchored = true;
		grassBase.Color = Color3.fromRGB(34, 139, 34); // Forest green
		grassBase.Material = Enum.Material.Grass;
		grassBase.TopSurface = Enum.SurfaceType.Smooth;
		grassBase.BottomSurface = Enum.SurfaceType.Smooth;
		grassBase.Parent = this.parkContainer;

		// Add some texture variation with massive grass patches
		for (let i = 0; i < 20; i++) {
			const grassPatch = new Instance("Part") as Part;
			grassPatch.Name = `GrassPatch_${i}`;
			const patchSize = math.random(60, 100);
			grassPatch.Size = new Vector3(patchSize, 0.5, patchSize);

			// Random position around the main area
			const angle = (math.pi * 2 * i) / 20;
			const distance = math.random(120, 200);
			const x = 7 + math.cos(angle) * distance;
			const z = 7 + math.sin(angle) * distance;

			grassPatch.Position = new Vector3(x, GRASS_Y_POSITION + 0.25, z);
			grassPatch.Anchored = true;
			grassPatch.Color = Color3.fromRGB(
				math.random(30, 50),
				math.random(120, 160),
				math.random(30, 50)
			); // Slight color variation
			grassPatch.Material = Enum.Material.Grass;
			grassPatch.TopSurface = Enum.SurfaceType.Smooth;
			grassPatch.BottomSurface = Enum.SurfaceType.Smooth;
			grassPatch.Parent = this.parkContainer;
		}
	}

	private createTrees(): void {
		// Create massive trees very far away - like giant redwoods in the distance
		const treePositions = [
			{ x: -150, z: 7 },    // West
			{ x: 164, z: 7 },     // East
			{ x: 7, z: -150 },    // North
			{ x: 7, z: 164 },     // South
			{ x: -120, z: -120 }, // Northwest
			{ x: 134, z: -120 },  // Northeast
			{ x: -120, z: 134 },  // Southwest
			{ x: 134, z: 134 },   // Southeast
			{ x: -80, z: 200 },   // Far north
			{ x: 94, z: 200 },    // Far north
			{ x: -80, z: -186 },  // Far south
			{ x: 94, z: -186 },   // Far south
			{ x: 200, z: 7 },     // Far east
			{ x: -186, z: 7 },    // Far west
			{ x: 150, z: 150 },   // Far northeast
			{ x: -136, z: -136 }, // Far southwest
		];

		for (let i = 0; i < treePositions.size(); i++) {
			this.createTree(treePositions[i].x, treePositions[i].z, i);
		}
	}

	private createTree(x: number, z: number, index: number): void {
		const treeContainer = new Instance("Model") as Model;
		treeContainer.Name = `Tree_${index}`;
		treeContainer.Parent = this.parkContainer;

		// Massive tree trunk - giant redwood scale
		const trunkHeight = math.random(80, 120);
		const trunkWidth = math.random(12, 20);
		const trunk = new Instance("Part") as Part;
		trunk.Name = "Trunk";
		trunk.Size = new Vector3(trunkWidth, trunkHeight, trunkWidth);
		trunk.Position = new Vector3(x, GRASS_Y_POSITION + trunkHeight / 2, z);
		trunk.Anchored = true;
		trunk.Color = Color3.fromRGB(101, 67, 33); // Brown
		trunk.Material = Enum.Material.Wood;
		trunk.Parent = treeContainer;

		// Tree leaves - multiple massive spheres for fuller look
		const leafColors = [Color3.fromRGB(34, 139, 34), Color3.fromRGB(0, 100, 0)];
		const leafColor = leafColors[math.random(0, leafColors.size() - 1)];

		// Main canopy - absolutely massive
		const mainCanopySize = math.random(60, 80);
		const canopy1 = new Instance("Part") as Part;
		canopy1.Name = "Canopy1";
		canopy1.Shape = Enum.PartType.Ball;
		canopy1.Size = new Vector3(mainCanopySize, mainCanopySize, mainCanopySize);
		canopy1.Position = new Vector3(x, GRASS_Y_POSITION + trunkHeight + 10, z);
		canopy1.Anchored = true;
		canopy1.Color = leafColor;
		canopy1.Material = Enum.Material.LeafyGrass;
		canopy1.Parent = treeContainer;

		// Secondary canopies for fuller tree - also massive
		const secondaryCanopySize = mainCanopySize * 0.7;
		const canopy2 = new Instance("Part") as Part;
		canopy2.Name = "Canopy2";
		canopy2.Shape = Enum.PartType.Ball;
		canopy2.Size = new Vector3(secondaryCanopySize, secondaryCanopySize, secondaryCanopySize);
		canopy2.Position = new Vector3(x - 20, GRASS_Y_POSITION + trunkHeight + 5, z - 20);
		canopy2.Anchored = true;
		canopy2.Color = leafColor;
		canopy2.Material = Enum.Material.LeafyGrass;
		canopy2.Parent = treeContainer;

		const canopy3 = new Instance("Part") as Part;
		canopy3.Name = "Canopy3";
		canopy3.Shape = Enum.PartType.Ball;
		canopy3.Size = new Vector3(secondaryCanopySize, secondaryCanopySize, secondaryCanopySize);
		canopy3.Position = new Vector3(x + 20, GRASS_Y_POSITION + trunkHeight + 5, z + 20);
		canopy3.Anchored = true;
		canopy3.Color = leafColor;
		canopy3.Material = Enum.Material.LeafyGrass;
		canopy3.Parent = treeContainer;

		const canopy4 = new Instance("Part") as Part;
		canopy4.Name = "Canopy4";
		canopy4.Shape = Enum.PartType.Ball;
		canopy4.Size = new Vector3(secondaryCanopySize * 0.8, secondaryCanopySize * 0.8, secondaryCanopySize * 0.8);
		canopy4.Position = new Vector3(x - 15, GRASS_Y_POSITION + trunkHeight + 15, z + 15);
		canopy4.Anchored = true;
		canopy4.Color = leafColor;
		canopy4.Material = Enum.Material.LeafyGrass;
		canopy4.Parent = treeContainer;
	}

	private createBenches(): void {
		// Create benches facing the chess table
		const benchPositions = [
			{ x: 7, z: -8, rotation: 0 },      // North bench
			{ x: 7, z: 22, rotation: math.pi }, // South bench
			{ x: -8, z: 7, rotation: math.pi / 2 },  // West bench
			{ x: 22, z: 7, rotation: -math.pi / 2 }, // East bench
		];

		for (let i = 0; i < benchPositions.size(); i++) {
			this.createBench(benchPositions[i].x, benchPositions[i].z, benchPositions[i].rotation, i);
		}
	}

	private createBench(x: number, z: number, rotation: number, index: number): void {
		const benchContainer = new Instance("Model") as Model;
		benchContainer.Name = `Bench_${index}`;
		benchContainer.Parent = this.parkContainer;

		// Bench seat
		const seat = new Instance("Part") as Part;
		seat.Name = "Seat";
		seat.Size = new Vector3(4, 0.5, 1.5);
		seat.Position = new Vector3(x, GRASS_Y_POSITION + 1.5, z);
		seat.Anchored = true;
		seat.Color = Color3.fromRGB(139, 69, 19); // Saddle brown
		seat.Material = Enum.Material.Wood;
		seat.TopSurface = Enum.SurfaceType.Smooth;
		seat.Parent = benchContainer;

		// Bench back
		const back = new Instance("Part") as Part;
		back.Name = "Back";
		back.Size = new Vector3(4, 2, 0.3);
		back.Position = new Vector3(x, GRASS_Y_POSITION + 2.5, z - 0.6);
		back.Anchored = true;
		back.Color = Color3.fromRGB(139, 69, 19);
		back.Material = Enum.Material.Wood;
		back.Parent = benchContainer;

		// Bench legs
		const legPositions = [
			new Vector3(x - 1.5, GRASS_Y_POSITION + 0.75, z + 0.5),
			new Vector3(x + 1.5, GRASS_Y_POSITION + 0.75, z + 0.5),
			new Vector3(x - 1.5, GRASS_Y_POSITION + 0.75, z - 0.5),
			new Vector3(x + 1.5, GRASS_Y_POSITION + 0.75, z - 0.5),
		];

		for (let i = 0; i < legPositions.size(); i++) {
			const leg = new Instance("Part") as Part;
			leg.Name = `Leg_${i}`;
			leg.Size = new Vector3(0.3, 1.5, 0.3);
			leg.Position = legPositions[i];
			leg.Anchored = true;
			leg.Color = Color3.fromRGB(101, 67, 33);
			leg.Material = Enum.Material.Wood;
			leg.Parent = benchContainer;
		}

		// Rotate the entire bench to face the chess table
		const benchCFrame = seat.CFrame.mul(CFrame.Angles(0, rotation, 0));
		for (const child of benchContainer.GetChildren()) {
			if (child.IsA("Part")) {
				const part = child as Part;
				const offset = part.Position.sub(seat.Position);
				const rotatedOffset = CFrame.fromEulerAnglesYXZ(0, rotation, 0).PointToWorldSpace(offset);
				part.Position = seat.Position.add(rotatedOffset);
			}
		}
	}

	private createPaths(): void {
		// Create longer stone paths leading to the chess table
		const pathConfigurations = [
			{ startX: -60, startZ: 7, endX: -5, endZ: 7 },  // West path
			{ startX: 19, startZ: 7, endX: 74, endZ: 7 },   // East path
			{ startX: 7, startZ: -60, endX: 7, endZ: -5 },  // North path
			{ startX: 7, startZ: 19, endX: 7, endZ: 74 },   // South path
		];

		for (let i = 0; i < pathConfigurations.size(); i++) {
			this.createPath(pathConfigurations[i], i);
		}
	}

	private createPath(config: { startX: number; startZ: number; endX: number; endZ: number }, index: number): void {
		const pathContainer = new Instance("Folder") as Folder;
		pathContainer.Name = `Path_${index}`;
		pathContainer.Parent = this.parkContainer;

		// Calculate path length and create stepping stones
		const deltaX = config.endX - config.startX;
		const deltaZ = config.endZ - config.startZ;
		const distance = math.sqrt(deltaX * deltaX + deltaZ * deltaZ);
		const numStones = math.floor(distance / 2);

		for (let i = 0; i < numStones; i++) {
			const t = i / numStones;
			const x = config.startX + deltaX * t;
			const z = config.startZ + deltaZ * t;

			const stone = new Instance("Part") as Part;
			stone.Name = `Stone_${i}`;
			stone.Size = new Vector3(2, 0.3, 2);
			stone.Position = new Vector3(x, GRASS_Y_POSITION + 0.15, z);
			stone.Anchored = true;
			stone.Color = Color3.fromRGB(128, 128, 128); // Gray stone
			stone.Material = Enum.Material.Slate;
			stone.TopSurface = Enum.SurfaceType.Smooth;
			stone.BottomSurface = Enum.SurfaceType.Smooth;
			stone.Parent = pathContainer;

			// Add slight random rotation for variety
			const randomRotation = math.random(-math.pi / 8, math.pi / 8);
			stone.CFrame = stone.CFrame.mul(CFrame.Angles(0, randomRotation, 0));
		}
	}

	private createDecorations(): void {
		// Add some decorative elements like flowers and bushes
		this.createFlowerBeds();
		this.createBushes();
	}

	private createFlowerBeds(): void {
		const flowerBedPositions = [
			{ x: -25, z: -25 },
			{ x: 39, z: -25 },
			{ x: -25, z: 39 },
			{ x: 39, z: 39 },
		];

		for (let i = 0; i < flowerBedPositions.size(); i++) {
			this.createFlowerBed(flowerBedPositions[i].x, flowerBedPositions[i].z, i);
		}
	}

	private createFlowerBed(x: number, z: number, index: number): void {
		const flowerBedContainer = new Instance("Folder") as Folder;
		flowerBedContainer.Name = `FlowerBed_${index}`;
		flowerBedContainer.Parent = this.parkContainer;

		// Create the flower bed base
		const bedBase = new Instance("Part") as Part;
		bedBase.Name = "BedBase";
		bedBase.Size = new Vector3(6, 0.2, 6);
		bedBase.Position = new Vector3(x, GRASS_Y_POSITION + 0.1, z);
		bedBase.Anchored = true;
		bedBase.Color = Color3.fromRGB(101, 67, 33); // Dark brown soil
		bedBase.Material = Enum.Material.Mud;
		bedBase.Parent = flowerBedContainer;

		// Add flowers
		const flowerColors = [
			Color3.fromRGB(255, 0, 0),    // Red
			Color3.fromRGB(255, 255, 0),  // Yellow
			Color3.fromRGB(255, 0, 255),  // Magenta
			Color3.fromRGB(0, 0, 255),    // Blue
			Color3.fromRGB(255, 165, 0),  // Orange
		];

		for (let i = 0; i < 12; i++) {
			const flower = new Instance("Part") as Part;
			flower.Name = `Flower_${i}`;
			flower.Shape = Enum.PartType.Ball;
			flower.Size = new Vector3(0.3, 0.3, 0.3);

			// Random position within the flower bed
			const offsetX = (math.random() - 0.5) * 4;
			const offsetZ = (math.random() - 0.5) * 4;
			flower.Position = new Vector3(x + offsetX, GRASS_Y_POSITION + 0.3, z + offsetZ);
			flower.Anchored = true;
			flower.Color = flowerColors[math.random(0, flowerColors.size() - 1)];
			flower.Material = Enum.Material.Neon;
			flower.Parent = flowerBedContainer;

			// Add flower stem
			const stem = new Instance("Part") as Part;
			stem.Name = `Stem_${i}`;
			stem.Size = new Vector3(0.1, 0.4, 0.1);
			stem.Position = new Vector3(x + offsetX, GRASS_Y_POSITION + 0.2, z + offsetZ);
			stem.Anchored = true;
			stem.Color = Color3.fromRGB(0, 100, 0); // Green
			stem.Material = Enum.Material.Plastic;
			stem.Parent = flowerBedContainer;
		}
	}

	private createBushes(): void {
		const bushPositions = [
			{ x: -80, z: 7 },
			{ x: 94, z: 7 },
			{ x: 7, z: -80 },
			{ x: 7, z: 94 },
			{ x: -60, z: 60 },
			{ x: 74, z: 60 },
			{ x: -60, z: -46 },
			{ x: 74, z: -46 },
			{ x: 120, z: 120 },
			{ x: -106, z: 120 },
			{ x: 120, z: -106 },
			{ x: -106, z: -106 },
		];

		for (let i = 0; i < bushPositions.size(); i++) {
			this.createBush(bushPositions[i].x, bushPositions[i].z, i);
		}
	}

	private createBush(x: number, z: number, index: number): void {
		const bush = new Instance("Part") as Part;
		bush.Name = `Bush_${index}`;
		bush.Shape = Enum.PartType.Ball;
		bush.Size = new Vector3(20, 12, 20); // Massive bushes
		bush.Position = new Vector3(x, GRASS_Y_POSITION + 6, z);
		bush.Anchored = true;
		bush.Color = Color3.fromRGB(0, 100, 0); // Dark green
		bush.Material = Enum.Material.LeafyGrass;
		bush.Parent = this.parkContainer;
	}

	private createLampPosts(): void {
		const lampPostPositions = [
			{ x: -15, z: -15 },
			{ x: 29, z: -15 },
			{ x: -15, z: 29 },
			{ x: 29, z: 29 },
			{ x: 50, z: 7 },
			{ x: -36, z: 7 },
			{ x: 7, z: 50 },
			{ x: 7, z: -36 },
		];

		for (let i = 0; i < lampPostPositions.size(); i++) {
			this.createLampPost(lampPostPositions[i].x, lampPostPositions[i].z, i);
		}
	}

	private createLampPost(x: number, z: number, index: number): void {
		const lampPostContainer = new Instance("Model") as Model;
		lampPostContainer.Name = `LampPost_${index}`;
		lampPostContainer.Parent = this.parkContainer;

		// Lamp post pole
		const pole = new Instance("Part") as Part;
		pole.Name = "Pole";
		pole.Size = new Vector3(0.3, 6, 0.3);
		pole.Position = new Vector3(x, GRASS_Y_POSITION + 3, z);
		pole.Anchored = true;
		pole.Color = Color3.fromRGB(64, 64, 64); // Dark gray
		pole.Material = Enum.Material.Metal;
		pole.Parent = lampPostContainer;

		// Lamp light
		const lampLight = new Instance("Part") as Part;
		lampLight.Name = "Light";
		lampLight.Shape = Enum.PartType.Cylinder;
		lampLight.Size = new Vector3(1.5, 0.5, 1.5);
		lampLight.Position = new Vector3(x, GRASS_Y_POSITION + 6, z);
		lampLight.Anchored = true;
		lampLight.Color = Color3.fromRGB(255, 255, 200); // Warm light
		lampLight.Material = Enum.Material.Neon;
		lampLight.Parent = lampPostContainer;

		// Add a PointLight for actual illumination
		const light = new Instance("PointLight") as PointLight;
		light.Color = Color3.fromRGB(255, 255, 200);
		light.Brightness = 2;
		light.Range = 15;
		light.Parent = lampLight;
	}

	public destroy(): void {
		this.parkContainer.Destroy();
	}
}