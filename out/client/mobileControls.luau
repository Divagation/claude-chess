-- Compiled with roblox-ts v3.0.0
local MobileControls
do
	MobileControls = setmetatable({}, {
		__tostring = function()
			return "MobileControls"
		end,
	})
	MobileControls.__index = MobileControls
	function MobileControls.new(...)
		local self = setmetatable({}, MobileControls)
		return self:constructor(...) or self
	end
	function MobileControls:constructor(controls)
		print("🔧 Creating MobileControls...")
		self.controls = controls
		self.UserInputService = game:GetService("UserInputService")
		self:setupTouchInteractions()
		print("✅ MobileControls created successfully (swipe & pinch gestures)")
	end
	function MobileControls:setupTouchInteractions()
		local lastTouchPosition
		local isSingleTouch = false
		self.UserInputService.InputBegan:Connect(function(input, gameProcessedEvent)
			if gameProcessedEvent then
				return nil
			end
			if input.UserInputType == Enum.UserInputType.Touch then
				-- Start tracking single touch drag
				if not isSingleTouch then
					isSingleTouch = true
					lastTouchPosition = Vector2.new(input.Position.X, input.Position.Y)
				end
			end
		end)
		self.UserInputService.InputChanged:Connect(function(input, gameProcessedEvent)
			if gameProcessedEvent then
				return nil
			end
			if input.UserInputType == Enum.UserInputType.Touch and isSingleTouch and lastTouchPosition then
				local currentPos = Vector2.new(input.Position.X, input.Position.Y)
				local _lastTouchPosition = lastTouchPosition
				local delta = currentPos - _lastTouchPosition
				-- Horizontal swipe rotates camera
				if self.controls.onRotateDelta then
					local rotationSpeed = 0.3
					self.controls.onRotateDelta(delta.X * rotationSpeed)
				end
				lastTouchPosition = currentPos
			end
		end)
		self.UserInputService.InputEnded:Connect(function(input, gameProcessedEvent)
			if input.UserInputType == Enum.UserInputType.Touch then
				isSingleTouch = false
				lastTouchPosition = nil
			end
		end)
		-- Pinch to zoom using TouchPinch
		self.UserInputService.TouchPinch:Connect(function(touchPositions, scale, velocity, state, gameProcessedEvent)
			if gameProcessedEvent then
				return nil
			end
			if self.controls.onZoomDelta and state == Enum.UserInputState.Change then
				-- Scale > 1 means zooming out, scale < 1 means zooming in
				local zoomDelta = (1 - scale) * 2
				self.controls.onZoomDelta(zoomDelta)
			end
		end)
		print("✓ Touch swipe and pinch gestures configured")
	end
end
return {
	MobileControls = MobileControls,
}
