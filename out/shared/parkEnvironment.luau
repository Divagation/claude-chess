-- Compiled with roblox-ts v3.0.0
local GRASS_Y_POSITION = 0
local ParkEnvironment
do
	ParkEnvironment = setmetatable({}, {
		__tostring = function()
			return "ParkEnvironment"
		end,
	})
	ParkEnvironment.__index = ParkEnvironment
	function ParkEnvironment.new(...)
		local self = setmetatable({}, ParkEnvironment)
		return self:constructor(...) or self
	end
	function ParkEnvironment:constructor()
		self.parkContainer = Instance.new("Folder")
		self.parkContainer.Name = "ParkEnvironment"
		self.parkContainer.Parent = workspace
		self:createGrassTerrain()
		self:createTrees()
		self:createPaths()
		self:createDecorations()
	end
	function ParkEnvironment:createGrassTerrain()
		-- Create an enormous grass base - the scale of a massive park
		local grassBase = Instance.new("Part")
		grassBase.Name = "GrassBase"
		grassBase.Size = Vector3.new(500, 2, 500)
		grassBase.Position = Vector3.new(7, GRASS_Y_POSITION, 7)
		grassBase.Anchored = true
		grassBase.Color = Color3.fromRGB(34, 139, 34)
		grassBase.Material = Enum.Material.Grass
		grassBase.TopSurface = Enum.SurfaceType.Smooth
		grassBase.BottomSurface = Enum.SurfaceType.Smooth
		grassBase.Parent = self.parkContainer
		-- Add some texture variation with massive grass patches
		for i = 0, 19 do
			local grassPatch = Instance.new("Part")
			grassPatch.Name = `GrassPatch_{i}`
			local patchSize = math.random(60, 100)
			grassPatch.Size = Vector3.new(patchSize, 0.5, patchSize)
			-- Random position around the main area
			local angle = (math.pi * 2 * i) / 20
			local distance = math.random(120, 200)
			local x = 7 + math.cos(angle) * distance
			local z = 7 + math.sin(angle) * distance
			grassPatch.Position = Vector3.new(x, GRASS_Y_POSITION + 0.25, z)
			grassPatch.Anchored = true
			grassPatch.Color = Color3.fromRGB(math.random(30, 50), math.random(120, 160), math.random(30, 50))
			grassPatch.Material = Enum.Material.Grass
			grassPatch.TopSurface = Enum.SurfaceType.Smooth
			grassPatch.BottomSurface = Enum.SurfaceType.Smooth
			grassPatch.Parent = self.parkContainer
		end
	end
	function ParkEnvironment:createTrees()
		-- Create massive trees very far away - like giant redwoods in the distance
		local treePositions = { {
			x = -150,
			z = 7,
		}, {
			x = 164,
			z = 7,
		}, {
			x = 7,
			z = -150,
		}, {
			x = 7,
			z = 164,
		}, {
			x = -120,
			z = -120,
		}, {
			x = 134,
			z = -120,
		}, {
			x = -120,
			z = 134,
		}, {
			x = 134,
			z = 134,
		}, {
			x = -80,
			z = 200,
		}, {
			x = 94,
			z = 200,
		}, {
			x = -80,
			z = -186,
		}, {
			x = 94,
			z = -186,
		}, {
			x = 200,
			z = 7,
		}, {
			x = -186,
			z = 7,
		}, {
			x = 150,
			z = 150,
		}, {
			x = -136,
			z = -136,
		} }
		for i = 0, #treePositions - 1 do
			self:createTree(treePositions[i + 1].x, treePositions[i + 1].z, i)
		end
	end
	function ParkEnvironment:createTree(x, z, index)
		local treeContainer = Instance.new("Model")
		treeContainer.Name = `Tree_{index}`
		treeContainer.Parent = self.parkContainer
		-- Massive tree trunk - giant redwood scale
		local trunkHeight = math.random(80, 120)
		local trunkWidth = math.random(12, 20)
		local trunk = Instance.new("Part")
		trunk.Name = "Trunk"
		trunk.Size = Vector3.new(trunkWidth, trunkHeight, trunkWidth)
		trunk.Position = Vector3.new(x, GRASS_Y_POSITION + trunkHeight / 2, z)
		trunk.Anchored = true
		trunk.Color = Color3.fromRGB(101, 67, 33)
		trunk.Material = Enum.Material.Wood
		trunk.Parent = treeContainer
		-- Tree leaves - multiple massive spheres for fuller look
		local leafColors = { Color3.fromRGB(34, 139, 34), Color3.fromRGB(0, 100, 0) }
		local leafColor = leafColors[math.random(0, #leafColors - 1) + 1]
		-- Main canopy - absolutely massive
		local mainCanopySize = math.random(60, 80)
		local canopy1 = Instance.new("Part")
		canopy1.Name = "Canopy1"
		canopy1.Shape = Enum.PartType.Ball
		canopy1.Size = Vector3.new(mainCanopySize, mainCanopySize, mainCanopySize)
		canopy1.Position = Vector3.new(x, GRASS_Y_POSITION + trunkHeight + 10, z)
		canopy1.Anchored = true
		canopy1.Color = leafColor
		canopy1.Material = Enum.Material.LeafyGrass
		canopy1.Parent = treeContainer
		-- Secondary canopies for fuller tree - also massive
		local secondaryCanopySize = mainCanopySize * 0.7
		local canopy2 = Instance.new("Part")
		canopy2.Name = "Canopy2"
		canopy2.Shape = Enum.PartType.Ball
		canopy2.Size = Vector3.new(secondaryCanopySize, secondaryCanopySize, secondaryCanopySize)
		canopy2.Position = Vector3.new(x - 20, GRASS_Y_POSITION + trunkHeight + 5, z - 20)
		canopy2.Anchored = true
		canopy2.Color = leafColor
		canopy2.Material = Enum.Material.LeafyGrass
		canopy2.Parent = treeContainer
		local canopy3 = Instance.new("Part")
		canopy3.Name = "Canopy3"
		canopy3.Shape = Enum.PartType.Ball
		canopy3.Size = Vector3.new(secondaryCanopySize, secondaryCanopySize, secondaryCanopySize)
		canopy3.Position = Vector3.new(x + 20, GRASS_Y_POSITION + trunkHeight + 5, z + 20)
		canopy3.Anchored = true
		canopy3.Color = leafColor
		canopy3.Material = Enum.Material.LeafyGrass
		canopy3.Parent = treeContainer
		local canopy4 = Instance.new("Part")
		canopy4.Name = "Canopy4"
		canopy4.Shape = Enum.PartType.Ball
		canopy4.Size = Vector3.new(secondaryCanopySize * 0.8, secondaryCanopySize * 0.8, secondaryCanopySize * 0.8)
		canopy4.Position = Vector3.new(x - 15, GRASS_Y_POSITION + trunkHeight + 15, z + 15)
		canopy4.Anchored = true
		canopy4.Color = leafColor
		canopy4.Material = Enum.Material.LeafyGrass
		canopy4.Parent = treeContainer
	end
	function ParkEnvironment:createBenches()
		-- Create benches facing the chess table
		local benchPositions = { {
			x = 7,
			z = -8,
			rotation = 0,
		}, {
			x = 7,
			z = 22,
			rotation = math.pi,
		}, {
			x = -8,
			z = 7,
			rotation = math.pi / 2,
		}, {
			x = 22,
			z = 7,
			rotation = -math.pi / 2,
		} }
		for i = 0, #benchPositions - 1 do
			self:createBench(benchPositions[i + 1].x, benchPositions[i + 1].z, benchPositions[i + 1].rotation, i)
		end
	end
	function ParkEnvironment:createBench(x, z, rotation, index)
		local benchContainer = Instance.new("Model")
		benchContainer.Name = `Bench_{index}`
		benchContainer.Parent = self.parkContainer
		-- Bench seat
		local seat = Instance.new("Part")
		seat.Name = "Seat"
		seat.Size = Vector3.new(4, 0.5, 1.5)
		seat.Position = Vector3.new(x, GRASS_Y_POSITION + 1.5, z)
		seat.Anchored = true
		seat.Color = Color3.fromRGB(139, 69, 19)
		seat.Material = Enum.Material.Wood
		seat.TopSurface = Enum.SurfaceType.Smooth
		seat.Parent = benchContainer
		-- Bench back
		local back = Instance.new("Part")
		back.Name = "Back"
		back.Size = Vector3.new(4, 2, 0.3)
		back.Position = Vector3.new(x, GRASS_Y_POSITION + 2.5, z - 0.6)
		back.Anchored = true
		back.Color = Color3.fromRGB(139, 69, 19)
		back.Material = Enum.Material.Wood
		back.Parent = benchContainer
		-- Bench legs
		local legPositions = { Vector3.new(x - 1.5, GRASS_Y_POSITION + 0.75, z + 0.5), Vector3.new(x + 1.5, GRASS_Y_POSITION + 0.75, z + 0.5), Vector3.new(x - 1.5, GRASS_Y_POSITION + 0.75, z - 0.5), Vector3.new(x + 1.5, GRASS_Y_POSITION + 0.75, z - 0.5) }
		for i = 0, #legPositions - 1 do
			local leg = Instance.new("Part")
			leg.Name = `Leg_{i}`
			leg.Size = Vector3.new(0.3, 1.5, 0.3)
			leg.Position = legPositions[i + 1]
			leg.Anchored = true
			leg.Color = Color3.fromRGB(101, 67, 33)
			leg.Material = Enum.Material.Wood
			leg.Parent = benchContainer
		end
		-- Rotate the entire bench to face the chess table
		local _cFrame = seat.CFrame
		local _arg0 = CFrame.Angles(0, rotation, 0)
		local benchCFrame = _cFrame * _arg0
		for _, child in benchContainer:GetChildren() do
			if child:IsA("Part") then
				local part = child
				local _position = part.Position
				local _position_1 = seat.Position
				local offset = _position - _position_1
				local rotatedOffset = CFrame.fromEulerAnglesYXZ(0, rotation, 0):PointToWorldSpace(offset)
				part.Position = seat.Position + rotatedOffset
			end
		end
	end
	function ParkEnvironment:createPaths()
		-- Create longer stone paths leading to the chess table
		local pathConfigurations = { {
			startX = -60,
			startZ = 7,
			endX = -5,
			endZ = 7,
		}, {
			startX = 19,
			startZ = 7,
			endX = 74,
			endZ = 7,
		}, {
			startX = 7,
			startZ = -60,
			endX = 7,
			endZ = -5,
		}, {
			startX = 7,
			startZ = 19,
			endX = 7,
			endZ = 74,
		} }
		for i = 0, #pathConfigurations - 1 do
			self:createPath(pathConfigurations[i + 1], i)
		end
	end
	function ParkEnvironment:createPath(config, index)
		local pathContainer = Instance.new("Folder")
		pathContainer.Name = `Path_{index}`
		pathContainer.Parent = self.parkContainer
		-- Calculate path length and create stepping stones
		local deltaX = config.endX - config.startX
		local deltaZ = config.endZ - config.startZ
		local distance = math.sqrt(deltaX * deltaX + deltaZ * deltaZ)
		local numStones = math.floor(distance / 2)
		do
			local i = 0
			local _shouldIncrement = false
			while true do
				if _shouldIncrement then
					i += 1
				else
					_shouldIncrement = true
				end
				if not (i < numStones) then
					break
				end
				local t = i / numStones
				local x = config.startX + deltaX * t
				local z = config.startZ + deltaZ * t
				local stone = Instance.new("Part")
				stone.Name = `Stone_{i}`
				stone.Size = Vector3.new(2, 0.3, 2)
				stone.Position = Vector3.new(x, GRASS_Y_POSITION + 0.15, z)
				stone.Anchored = true
				stone.Color = Color3.fromRGB(128, 128, 128)
				stone.Material = Enum.Material.Slate
				stone.TopSurface = Enum.SurfaceType.Smooth
				stone.BottomSurface = Enum.SurfaceType.Smooth
				stone.Parent = pathContainer
				-- Add slight random rotation for variety
				local randomRotation = math.random(-math.pi / 8, math.pi / 8)
				local _cFrame = stone.CFrame
				local _arg0 = CFrame.Angles(0, randomRotation, 0)
				stone.CFrame = _cFrame * _arg0
			end
		end
	end
	function ParkEnvironment:createDecorations()
		-- Add some decorative elements like flowers and bushes
		self:createFlowerBeds()
		self:createBushes()
	end
	function ParkEnvironment:createFlowerBeds()
		local flowerBedPositions = { {
			x = -25,
			z = -25,
		}, {
			x = 39,
			z = -25,
		}, {
			x = -25,
			z = 39,
		}, {
			x = 39,
			z = 39,
		} }
		for i = 0, #flowerBedPositions - 1 do
			self:createFlowerBed(flowerBedPositions[i + 1].x, flowerBedPositions[i + 1].z, i)
		end
	end
	function ParkEnvironment:createFlowerBed(x, z, index)
		local flowerBedContainer = Instance.new("Folder")
		flowerBedContainer.Name = `FlowerBed_{index}`
		flowerBedContainer.Parent = self.parkContainer
		-- Create the flower bed base
		local bedBase = Instance.new("Part")
		bedBase.Name = "BedBase"
		bedBase.Size = Vector3.new(6, 0.2, 6)
		bedBase.Position = Vector3.new(x, GRASS_Y_POSITION + 0.1, z)
		bedBase.Anchored = true
		bedBase.Color = Color3.fromRGB(101, 67, 33)
		bedBase.Material = Enum.Material.Mud
		bedBase.Parent = flowerBedContainer
		-- Add flowers
		local flowerColors = { Color3.fromRGB(255, 0, 0), Color3.fromRGB(255, 255, 0), Color3.fromRGB(255, 0, 255), Color3.fromRGB(0, 0, 255), Color3.fromRGB(255, 165, 0) }
		for i = 0, 11 do
			local flower = Instance.new("Part")
			flower.Name = `Flower_{i}`
			flower.Shape = Enum.PartType.Ball
			flower.Size = Vector3.new(0.3, 0.3, 0.3)
			-- Random position within the flower bed
			local offsetX = (math.random() - 0.5) * 4
			local offsetZ = (math.random() - 0.5) * 4
			flower.Position = Vector3.new(x + offsetX, GRASS_Y_POSITION + 0.3, z + offsetZ)
			flower.Anchored = true
			flower.Color = flowerColors[math.random(0, #flowerColors - 1) + 1]
			flower.Material = Enum.Material.Neon
			flower.Parent = flowerBedContainer
			-- Add flower stem
			local stem = Instance.new("Part")
			stem.Name = `Stem_{i}`
			stem.Size = Vector3.new(0.1, 0.4, 0.1)
			stem.Position = Vector3.new(x + offsetX, GRASS_Y_POSITION + 0.2, z + offsetZ)
			stem.Anchored = true
			stem.Color = Color3.fromRGB(0, 100, 0)
			stem.Material = Enum.Material.Plastic
			stem.Parent = flowerBedContainer
		end
	end
	function ParkEnvironment:createBushes()
		local bushPositions = { {
			x = -80,
			z = 7,
		}, {
			x = 94,
			z = 7,
		}, {
			x = 7,
			z = -80,
		}, {
			x = 7,
			z = 94,
		}, {
			x = -60,
			z = 60,
		}, {
			x = 74,
			z = 60,
		}, {
			x = -60,
			z = -46,
		}, {
			x = 74,
			z = -46,
		}, {
			x = 120,
			z = 120,
		}, {
			x = -106,
			z = 120,
		}, {
			x = 120,
			z = -106,
		}, {
			x = -106,
			z = -106,
		} }
		for i = 0, #bushPositions - 1 do
			self:createBush(bushPositions[i + 1].x, bushPositions[i + 1].z, i)
		end
	end
	function ParkEnvironment:createBush(x, z, index)
		local bush = Instance.new("Part")
		bush.Name = `Bush_{index}`
		bush.Shape = Enum.PartType.Ball
		bush.Size = Vector3.new(20, 12, 20)
		bush.Position = Vector3.new(x, GRASS_Y_POSITION + 6, z)
		bush.Anchored = true
		bush.Color = Color3.fromRGB(0, 100, 0)
		bush.Material = Enum.Material.LeafyGrass
		bush.Parent = self.parkContainer
	end
	function ParkEnvironment:createLampPosts()
		local lampPostPositions = { {
			x = -15,
			z = -15,
		}, {
			x = 29,
			z = -15,
		}, {
			x = -15,
			z = 29,
		}, {
			x = 29,
			z = 29,
		}, {
			x = 50,
			z = 7,
		}, {
			x = -36,
			z = 7,
		}, {
			x = 7,
			z = 50,
		}, {
			x = 7,
			z = -36,
		} }
		for i = 0, #lampPostPositions - 1 do
			self:createLampPost(lampPostPositions[i + 1].x, lampPostPositions[i + 1].z, i)
		end
	end
	function ParkEnvironment:createLampPost(x, z, index)
		local lampPostContainer = Instance.new("Model")
		lampPostContainer.Name = `LampPost_{index}`
		lampPostContainer.Parent = self.parkContainer
		-- Lamp post pole
		local pole = Instance.new("Part")
		pole.Name = "Pole"
		pole.Size = Vector3.new(0.3, 6, 0.3)
		pole.Position = Vector3.new(x, GRASS_Y_POSITION + 3, z)
		pole.Anchored = true
		pole.Color = Color3.fromRGB(64, 64, 64)
		pole.Material = Enum.Material.Metal
		pole.Parent = lampPostContainer
		-- Lamp light
		local lampLight = Instance.new("Part")
		lampLight.Name = "Light"
		lampLight.Shape = Enum.PartType.Cylinder
		lampLight.Size = Vector3.new(1.5, 0.5, 1.5)
		lampLight.Position = Vector3.new(x, GRASS_Y_POSITION + 6, z)
		lampLight.Anchored = true
		lampLight.Color = Color3.fromRGB(255, 255, 200)
		lampLight.Material = Enum.Material.Neon
		lampLight.Parent = lampPostContainer
		-- Add a PointLight for actual illumination
		local light = Instance.new("PointLight")
		light.Color = Color3.fromRGB(255, 255, 200)
		light.Brightness = 2
		light.Range = 15
		light.Parent = lampLight
	end
	function ParkEnvironment:destroy()
		self.parkContainer:Destroy()
	end
end
return {
	ParkEnvironment = ParkEnvironment,
}
