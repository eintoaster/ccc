-- Runtime module

---@class Module
---@field fn function
---@field isLoaded boolean
---@field value any

---@type table<string, Instance>
local instanceFromId = {}

---@type table<Instance, string>
local idFromInstance = {}

---@type table<Instance, Module>
local modules = {}

---Stores currently loading modules.
---@type table<LocalScript | ModuleScript, ModuleScript>
local currentlyLoading = {}

-- Module resolution

---@param module LocalScript | ModuleScript
---@param caller? LocalScript | ModuleScript
---@return function | nil cleanup
local function validateRequire(module, caller)
	currentlyLoading[caller] = module

	local currentModule = module
	local depth = 0

	-- If the module is loaded, requiring it will not cause a circular dependency.
	if not modules[module] then
		while currentModule do
			depth = depth + 1
			currentModule = currentlyLoading[currentModule]

			if currentModule == module then
				local str = currentModule.Name -- Get the string traceback

				for _ = 1, depth do
					currentModule = currentlyLoading[currentModule]
					str = str .. "  ⇒ " .. currentModule.Name
				end

				error("Failed to load '" .. module.Name .. "'; Detected a circular dependency chain: " .. str, 2)
			end
		end
	end

	return function ()
		if currentlyLoading[caller] == module then -- Thread-safe cleanup!
			currentlyLoading[caller] = nil
		end
	end
end

---@param obj LocalScript | ModuleScript
---@param this? LocalScript | ModuleScript
---@return any
local function loadModule(obj, this)
	local cleanup = this and validateRequire(obj, this)
	local module = modules[obj]

	if module.isLoaded then
		if cleanup then
			cleanup()
		end
		return module.value
	else
		local data = module.fn()
		module.value = data
		module.isLoaded = true
		if cleanup then
			cleanup()
		end
		return data
	end
end

---@param target ModuleScript
---@param this? LocalScript | ModuleScript
---@return any
local function requireModuleInternal(target, this)
	if modules[target] and target:IsA("ModuleScript") then
		return loadModule(target, this)
	else
		return require(target)
	end
end

-- Instance creation

---@param id string
---@return table<string, any> environment
local function newEnv(id)
	return setmetatable({
		VERSION = "1.1.0-dbg",
		script = instanceFromId[id],
		require = function (module)
			return requireModuleInternal(module, instanceFromId[id])
		end,
	}, {
		__index = getfenv(0),
		__metatable = "This metatable is locked",
	})
end

---@param name string
---@param className string
---@param path string
---@param parent string | nil
---@param fn function
local function newModule(name, className, path, parent, fn)
	local instance = Instance.new(className)
	instance.Name = name
	instance.Parent = instanceFromId[parent]

	instanceFromId[path] = instance
	idFromInstance[instance] = path

	modules[instance] = {
		fn = fn,
		isLoaded = false,
		value = nil,
	}
end

---@param name string
---@param className string
---@param path string
---@param parent string | nil
local function newInstance(name, className, path, parent)
	local instance = Instance.new(className)
	instance.Name = name
	instance.Parent = instanceFromId[parent]

	instanceFromId[path] = instance
	idFromInstance[instance] = path
end

-- Runtime

local function init()
	if not game:IsLoaded() then
		game.Loaded:Wait()
	end
	for object in pairs(modules) do
		if object:IsA("LocalScript") and not object.Disabled then
			task.spawn(loadModule, object)
		end
	end
end


newInstance("Orca", "Folder", "Orca", nil)

newModule("App", "ModuleScript", "Orca.App", "Orca", function () local fn = assert(loadstring("-- Compiled with roblox-ts v1.2.7\
local TS = require(script.Parent.include.RuntimeLib)\
local Roact = TS.import(script, TS.getModule(script, \"@rbxts\", \"roact\").src)\
local Dashboard = TS.import(script, script.Parent, \"views\", \"Dashboard\").default\
local DISPLAY_ORDER = 7\
local function App()\
\9return Roact.createElement(\"ScreenGui\", {\
\9\9IgnoreGuiInset = true,\
\9\9ResetOnSpawn = false,\
\9\9ZIndexBehavior = \"Sibling\",\
\9\9DisplayOrder = DISPLAY_ORDER,\
\9}, {\
\9\9Roact.createElement(Dashboard),\
\9})\
end\
local default = App\
return {\
\9default = default,\
}\
", '@'.."Orca.App")) setfenv(fn, newEnv("Orca.App")) return fn() end)

newInstance("components", "Folder", "Orca.components", "Orca")

newModule("Acrylic", "ModuleScript", "Orca.components.Acrylic", "Orca.components", function () local fn = assert(loadstring("-- Compiled with roblox-ts v1.2.7\
local TS = require(script.Parent.Parent.include.RuntimeLib)\
local exports = {}\
exports.default = TS.import(script, script, \"Acrylic\").default\
return exports\
", '@'.."Orca.components.Acrylic")) setfenv(fn, newEnv("Orca.components.Acrylic")) return fn() end)

newModule("Acrylic", "ModuleScript", "Orca.components.Acrylic.Acrylic", "Orca.components.Acrylic", function () local fn = assert(loadstring("-- Compiled with roblox-ts v1.2.7\
local TS = require(script.Parent.Parent.Parent.include.RuntimeLib)\
local Roact = TS.import(script, TS.getModule(script, \"@rbxts\", \"roact\").src)\
local _roact_hooked = TS.import(script, TS.getModule(script, \"@rbxts\", \"roact-hooked\").out)\
local hooked = _roact_hooked.hooked\
local useCallback = _roact_hooked.useCallback\
local useEffect = _roact_hooked.useEffect\
local useMemo = _roact_hooked.useMemo\
local useMutable = _roact_hooked.useMutable\
local Workspace = TS.import(script, TS.getModule(script, \"@rbxts\", \"services\")).Workspace\
local acrylicInstance = TS.import(script, script.Parent, \"acrylic-instance\").acrylicInstance\
local useAppSelector = TS.import(script, script.Parent.Parent.Parent, \"hooks\", \"common\", \"rodux-hooks\").useAppSelector\
local map = TS.import(script, script.Parent.Parent.Parent, \"utils\", \"number-util\").map\
local scale = TS.import(script, script.Parent.Parent.Parent, \"utils\", \"udim2\").scale\
local cylinderAngleOffset = CFrame.Angles(0, math.rad(90), 0)\
local function viewportPointToWorld(location, distance)\
\9local unitRay = Workspace.CurrentCamera:ScreenPointToRay(location.X, location.Y)\
\9local _origin = unitRay.Origin\
\9local _arg0 = unitRay.Direction * distance\
\9return _origin + _arg0\
end\
local function getOffset()\
\9return map(Workspace.CurrentCamera.ViewportSize.Y, 0, 2560, 8, 56)\
end\
local AcrylicBlur\
local function Acrylic(_param)\
\9local radius = _param.radius\
\9local distance = _param.distance\
\9local isAcrylicBlurEnabled = useAppSelector(function(state)\
\9\9return state.options.config.acrylicBlur\
\9end)\
\9return isAcrylicBlurEnabled and (Roact.createElement(AcrylicBlur, {\
\9\9radius = radius,\
\9\9distance = distance,\
\9})) or (Roact.createElement(\"Frame\", {\
\9\9BackgroundTransparency = 1,\
\9}))\
end\
local default = hooked(Acrylic)\
local function AcrylicBlurComponent(_param)\
\9local radius = _param.radius\
\9if radius == nil then\
\9\9radius = 0\
\9end\
\9local distance = _param.distance\
\9if distance == nil then\
\9\9distance = 0.001\
\9end\
\9local frameInfo = useMutable({\
\9\9topleft2d = Vector2.new(),\
\9\9topright2d = Vector2.new(),\
\9\9bottomright2d = Vector2.new(),\
\9\9topleftradius2d = Vector2.new(),\
\9})\
\9local acrylic = useMemo(function()\
\9\9local clone = acrylicInstance:Clone()\
\9\9clone.Parent = Workspace\
\9\9return clone\
\9end, {})\
\9useEffect(function()\
\9\9return function()\
\9\9\9return acrylic:Destroy()\
\9\9end\
\9end, {})\
\9local updateFrameInfo = useCallback(function(size, position)\
\9\9local _arg0 = size / 2\
\9\9local topleftRaw = position - _arg0\
\9\9local info = frameInfo.current\
\9\9info.topleft2d = Vector2.new(math.ceil(topleftRaw.X), math.ceil(topleftRaw.Y))\
\9\9local _topleft2d = info.topleft2d\
\9\9local _vector2 = Vector2.new(size.X, 0)\
\9\9info.topright2d = _topleft2d + _vector2\
\9\9info.bottomright2d = info.topleft2d + size\
\9\9local _topleft2d_1 = info.topleft2d\
\9\9local _vector2_1 = Vector2.new(radius, 0)\
\9\9info.topleftradius2d = _topleft2d_1 + _vector2_1\
\9end, { distance, radius })\
\9local updateInstance = useCallback(function()\
\9\9local _binding = frameInfo.current\
\9\9local topleft2d = _binding.topleft2d\
\9\9local topright2d = _binding.topright2d\
\9\9local bottomright2d = _binding.bottomright2d\
\9\9local topleftradius2d = _binding.topleftradius2d\
\9\9local topleft = viewportPointToWorld(topleft2d, distance)\
\9\9local topright = viewportPointToWorld(topright2d, distance)\
\9\9local bottomright = viewportPointToWorld(bottomright2d, distance)\
\9\9local topleftradius = viewportPointToWorld(topleftradius2d, distance)\
\9\9local cornerRadius = (topleftradius - topleft).Magnitude\
\9\9local width = (topright - topleft).Magnitude\
\9\9local height = (topright - bottomright).Magnitude\
\9\9local center = CFrame.fromMatrix((topleft + bottomright) / 2, Workspace.CurrentCamera.CFrame.XVector, Workspace.CurrentCamera.CFrame.YVector, Workspace.CurrentCamera.CFrame.ZVector)\
\9\9if radius ~= nil and radius > 0 then\
\9\9\9acrylic.Horizontal.CFrame = center\
\9\9\9acrylic.Horizontal.Mesh.Scale = Vector3.new(width - cornerRadius * 2, height, 0)\
\9\9\9acrylic.Vertical.CFrame = center\
\9\9\9acrylic.Vertical.Mesh.Scale = Vector3.new(width, height - cornerRadius * 2, 0)\
\9\9else\
\9\9\9acrylic.Horizontal.CFrame = center\
\9\9\9acrylic.Horizontal.Mesh.Scale = Vector3.new(width, height, 0)\
\9\9end\
\9\9if radius ~= nil and radius > 0 then\
\9\9\9local _cFrame = CFrame.new(-width / 2 + cornerRadius, height / 2 - cornerRadius, 0)\
\9\9\9acrylic.TopLeft.CFrame = center * _cFrame * cylinderAngleOffset\
\9\9\9acrylic.TopLeft.Mesh.Scale = Vector3.new(0, cornerRadius * 2, cornerRadius * 2)\
\9\9\9local _cFrame_1 = CFrame.new(width / 2 - cornerRadius, height / 2 - cornerRadius, 0)\
\9\9\9acrylic.TopRight.CFrame = center * _cFrame_1 * cylinderAngleOffset\
\9\9\9acrylic.TopRight.Mesh.Scale = Vector3.new(0, cornerRadius * 2, cornerRadius * 2)\
\9\9\9local _cFrame_2 = CFrame.new(-width / 2 + cornerRadius, -height / 2 + cornerRadius, 0)\
\9\9\9acrylic.BottomLeft.CFrame = center * _cFrame_2 * cylinderAngleOffset\
\9\9\9acrylic.BottomLeft.Mesh.Scale = Vector3.new(0, cornerRadius * 2, cornerRadius * 2)\
\9\9\9local _cFrame_3 = CFrame.new(width / 2 - cornerRadius, -height / 2 + cornerRadius, 0)\
\9\9\9acrylic.BottomRight.CFrame = center * _cFrame_3 * cylinderAngleOffset\
\9\9\9acrylic.BottomRight.Mesh.Scale = Vector3.new(0, cornerRadius * 2, cornerRadius * 2)\
\9\9end\
\9end, { radius, distance })\
\9useEffect(function()\
\9\9updateInstance()\
\9\9local posHandle = Workspace.CurrentCamera:GetPropertyChangedSignal(\"CFrame\"):Connect(updateInstance)\
\9\9local fovHandle = Workspace.CurrentCamera:GetPropertyChangedSignal(\"FieldOfView\"):Connect(updateInstance)\
\9\9local viewportHandle = Workspace.CurrentCamera:GetPropertyChangedSignal(\"ViewportSize\"):Connect(updateInstance)\
\9\9return function()\
\9\9\9posHandle:Disconnect()\
\9\9\9fovHandle:Disconnect()\
\9\9\9viewportHandle:Disconnect()\
\9\9end\
\9end, { updateInstance })\
\9return Roact.createElement(\"Frame\", {\
\9\9[Roact.Change.AbsoluteSize] = function(rbx)\
\9\9\9local blurOffset = getOffset()\
\9\9\9local _absoluteSize = rbx.AbsoluteSize\
\9\9\9local _vector2 = Vector2.new(blurOffset, blurOffset)\
\9\9\9local size = _absoluteSize - _vector2\
\9\9\9local _absolutePosition = rbx.AbsolutePosition\
\9\9\9local _arg0 = rbx.AbsoluteSize / 2\
\9\9\9local position = _absolutePosition + _arg0\
\9\9\9updateFrameInfo(size, position)\
\9\9\9task.spawn(updateInstance)\
\9\9end,\
\9\9[Roact.Change.AbsolutePosition] = function(rbx)\
\9\9\9local blurOffset = getOffset()\
\9\9\9local _absoluteSize = rbx.AbsoluteSize\
\9\9\9local _vector2 = Vector2.new(blurOffset, blurOffset)\
\9\9\9local size = _absoluteSize - _vector2\
\9\9\9local _absolutePosition = rbx.AbsolutePosition\
\9\9\9local _arg0 = rbx.AbsoluteSize / 2\
\9\9\9local position = _absolutePosition + _arg0\
\9\9\9updateFrameInfo(size, position)\
\9\9\9task.spawn(updateInstance)\
\9\9end,\
\9\9Size = scale(1, 1),\
\9\9BackgroundTransparency = 1,\
\9})\
end\
AcrylicBlur = hooked(AcrylicBlurComponent)\
return {\
\9default = default,\
}\
", '@'.."Orca.components.Acrylic.Acrylic")) setfenv(fn, newEnv("Orca.components.Acrylic.Acrylic")) return fn() end)

newModule("Acrylic.story", "ModuleScript", "Orca.components.Acrylic.Acrylic.story", "Orca.components.Acrylic", function () local fn = assert(loadstring("-- Compiled with roblox-ts v1.2.7\
local TS = require(script.Parent.Parent.Parent.include.RuntimeLib)\
local Roact = TS.import(script, TS.getModule(script, \"@rbxts\", \"roact\").src)\
local Provider = TS.import(script, TS.getModule(script, \"@rbxts\", \"roact-rodux-hooked\").out).Provider\
local Acrylic = TS.import(script, script.Parent, \"Acrylic\").default\
local DashboardPage = TS.import(script, script.Parent.Parent.Parent, \"store\", \"models\", \"dashboard.model\").DashboardPage\
local configureStore = TS.import(script, script.Parent.Parent.Parent, \"store\", \"store\").configureStore\
local hex = TS.import(script, script.Parent.Parent.Parent, \"utils\", \"color3\").hex\
local _udim2 = TS.import(script, script.Parent.Parent.Parent, \"utils\", \"udim2\")\
local px = _udim2.px\
local scale = _udim2.scale\
return function(target)\
\9local handle = Roact.mount(Roact.createElement(Provider, {\
\9\9store = configureStore({\
\9\9\9dashboard = {\
\9\9\9\9isOpen = true,\
\9\9\9\9page = DashboardPage.Apps,\
\9\9\9\9hint = nil,\
\9\9\9\9apps = {},\
\9\9\9},\
\9\9}),\
\9}, {\
\9\9Roact.createElement(\"Frame\", {\
\9\9\9AnchorPoint = Vector2.new(0.5, 0.5),\
\9\9\9Position = scale(0.3, 0.7),\
\9\9\9Size = px(250, 350),\
\9\9\9BackgroundColor3 = hex(\"#000000\"),\
\9\9\9BackgroundTransparency = 0.5,\
\9\9\9BorderSizePixel = 0,\
\9\9}, {\
\9\9\9Roact.createElement(\"UICorner\", {\
\9\9\9\9CornerRadius = UDim.new(0, 64),\
\9\9\9}),\
\9\9\9Roact.createElement(Acrylic, {\
\9\9\9\9radius = 52,\
\9\9\9}),\
\9\9}),\
\9}), target, \"Acrylic\")\
\9return function()\
\9\9return Roact.unmount(handle)\
\9end\
end\
", '@'.."Orca.components.Acrylic.Acrylic.story")) setfenv(fn, newEnv("Orca.components.Acrylic.Acrylic.story")) return fn() end)

newModule("acrylic-instance", "ModuleScript", "Orca.components.Acrylic.acrylic-instance", "Orca.components.Acrylic", function () local fn = assert(loadstring("-- Compiled with roblox-ts v1.2.7\
local TS = require(script.Parent.Parent.Parent.include.RuntimeLib)\
local Make = TS.import(script, TS.getModule(script, \"@rbxts\", \"make\"))\
local fill = {\
\9Color = Color3.new(0, 0, 0),\
\9Material = Enum.Material.Glass,\
\9Size = Vector3.new(1, 1, 0),\
\9Anchored = true,\
\9CanCollide = false,\
\9Locked = true,\
\9CastShadow = false,\
\9Transparency = 0.999,\
}\
local corner = {\
\9Color = Color3.new(0, 0, 0),\
\9Material = Enum.Material.Glass,\
\9Size = Vector3.new(0, 1, 1),\
\9Anchored = true,\
\9CanCollide = false,\
\9Locked = true,\
\9CastShadow = false,\
\9Transparency = 0.999,\
}\
local _object = {}\
local _left = \"Children\"\
local _object_1 = {\
\9Name = \"Horizontal\",\
\9Children = { Make(\"SpecialMesh\", {\
\9\9MeshType = Enum.MeshType.Brick,\
\9\9Offset = Vector3.new(0, 0, -0.000001),\
\9}) },\
}\
for _k, _v in pairs(fill) do\
\9_object_1[_k] = _v\
end\
local _exp = Make(\"Part\", _object_1)\
local _object_2 = {\
\9Name = \"Vertical\",\
\9Children = { Make(\"SpecialMesh\", {\
\9\9MeshType = Enum.MeshType.Brick,\
\9\9Offset = Vector3.new(0, 0, 0.000001),\
\9}) },\
}\
for _k, _v in pairs(fill) do\
\9_object_2[_k] = _v\
end\
local _exp_1 = Make(\"Part\", _object_2)\
local _object_3 = {\
\9Name = \"TopRight\",\
\9Children = { Make(\"SpecialMesh\", {\
\9\9MeshType = Enum.MeshType.Cylinder,\
\9}) },\
}\
for _k, _v in pairs(corner) do\
\9_object_3[_k] = _v\
end\
local _exp_2 = Make(\"Part\", _object_3)\
local _object_4 = {\
\9Name = \"TopLeft\",\
\9Children = { Make(\"SpecialMesh\", {\
\9\9MeshType = Enum.MeshType.Cylinder,\
\9}) },\
}\
for _k, _v in pairs(corner) do\
\9_object_4[_k] = _v\
end\
local _exp_3 = Make(\"Part\", _object_4)\
local _object_5 = {\
\9Name = \"BottomRight\",\
\9Children = { Make(\"SpecialMesh\", {\
\9\9MeshType = Enum.MeshType.Cylinder,\
\9}) },\
}\
for _k, _v in pairs(corner) do\
\9_object_5[_k] = _v\
end\
local _exp_4 = Make(\"Part\", _object_5)\
local _object_6 = {\
\9Name = \"BottomLeft\",\
\9Children = { Make(\"SpecialMesh\", {\
\9\9MeshType = Enum.MeshType.Cylinder,\
\9}) },\
}\
for _k, _v in pairs(corner) do\
\9_object_6[_k] = _v\
end\
_object[_left] = { _exp, _exp_1, _exp_2, _exp_3, _exp_4, Make(\"Part\", _object_6) }\
local acrylicInstance = Make(\"Model\", _object)\
return {\
\9acrylicInstance = acrylicInstance,\
}\
", '@'.."Orca.components.Acrylic.acrylic-instance")) setfenv(fn, newEnv("Orca.components.Acrylic.acrylic-instance")) return fn() end)

newModule("ActionButton", "ModuleScript", "Orca.components.ActionButton", "Orca.components", function () local fn = assert(loadstring("-- Compiled with roblox-ts v1.2.7\
local TS = require(script.Parent.Parent.include.RuntimeLib)\
local Roact = TS.import(script, TS.getModule(script, \"@rbxts\", \"roact\").src)\
local _roact_hooked = TS.import(script, TS.getModule(script, \"@rbxts\", \"roact-hooked\").out)\
local hooked = _roact_hooked.hooked\
local useState = _roact_hooked.useState\
local BrightButton = TS.import(script, script.Parent, \"BrightButton\").default\
local _rodux_hooks = TS.import(script, script.Parent.Parent, \"hooks\", \"common\", \"rodux-hooks\")\
local useAppDispatch = _rodux_hooks.useAppDispatch\
local useAppSelector = _rodux_hooks.useAppSelector\
local useSpring = TS.import(script, script.Parent.Parent, \"hooks\", \"common\", \"use-spring\").useSpring\
local _dashboard_action = TS.import(script, script.Parent.Parent, \"store\", \"actions\", \"dashboard.action\")\
local clearHint = _dashboard_action.clearHint\
local setHint = _dashboard_action.setHint\
local setJobActive = TS.import(script, script.Parent.Parent, \"store\", \"actions\", \"jobs.action\").setJobActive\
local px = TS.import(script, script.Parent.Parent, \"utils\", \"udim2\").px\
local function ActionButton(_param)\
\9local action = _param.action\
\9local hint = _param.hint\
\9local theme = _param.theme\
\9local image = _param.image\
\9local position = _param.position\
\9local canDeactivate = _param.canDeactivate\
\9local dispatch = useAppDispatch()\
\9local active = useAppSelector(function(state)\
\9\9return state.jobs[action].active\
\9end)\
\9local _binding = useState(false)\
\9local hovered = _binding[1]\
\9local setHovered = _binding[2]\
\9local accent = theme.highlight[action] ~= nil and theme.highlight[action] or theme.background\
\9if not (theme.highlight[action] ~= nil) then\
\9\9warn(\"ActionButton: \" .. (action .. \" is not in theme.highlight\"))\
\9end\
\9local _result\
\9if active then\
\9\9_result = accent\
\9else\
\9\9local _result_1\
\9\9if hovered then\
\9\9\9local _condition = theme.button.backgroundHovered\
\9\9\9if _condition == nil then\
\9\9\9\9_condition = theme.button.background:Lerp(accent, 0.1)\
\9\9\9end\
\9\9\9_result_1 = _condition\
\9\9else\
\9\9\9_result_1 = theme.button.background\
\9\9end\
\9\9_result = _result_1\
\9end\
\9local background = useSpring(_result, {})\
\9local foreground = useSpring(active and theme.button.foregroundAccent and theme.button.foregroundAccent or theme.button.foreground, {})\
\9return Roact.createElement(BrightButton, {\
\9\9onActivate = function()\
\9\9\9if active and canDeactivate then\
\9\9\9\9dispatch(setJobActive(action, false))\
\9\9\9elseif not active then\
\9\9\9\9dispatch(setJobActive(action, true))\
\9\9\9end\
\9\9end,\
\9\9onHover = function(hovered)\
\9\9\9if hovered then\
\9\9\9\9setHovered(true)\
\9\9\9\9dispatch(setHint(hint))\
\9\9\9else\
\9\9\9\9setHovered(false)\
\9\9\9\9dispatch(clearHint())\
\9\9\9end\
\9\9end,\
\9\9size = px(61, 49),\
\9\9position = position,\
\9\9radius = 8,\
\9\9color = background,\
\9\9borderEnabled = theme.button.outlined,\
\9\9borderColor = foreground,\
\9\9transparency = theme.button.backgroundTransparency,\
\9}, {\
\9\9Roact.createElement(\"ImageLabel\", {\
\9\9\9Image = image,\
\9\9\9ImageColor3 = foreground,\
\9\9\9ImageTransparency = useSpring(active and 0 or (hovered and theme.button.foregroundTransparency - 0.25 or theme.button.foregroundTransparency), {}),\
\9\9\9Size = px(36, 36),\
\9\9\9Position = px(12, 6),\
\9\9\9BackgroundTransparency = 1,\
\9\9}),\
\9})\
end\
local default = hooked(ActionButton)\
return {\
\9default = default,\
}\
", '@'.."Orca.components.ActionButton")) setfenv(fn, newEnv("Orca.components.ActionButton")) return fn() end)

newModule("Border", "ModuleScript", "Orca.components.Border", "Orca.components", function () local fn = assert(loadstring("-- Compiled with roblox-ts v1.2.7\
local TS = require(script.Parent.Parent.include.RuntimeLib)\
local Roact = TS.import(script, TS.getModule(script, \"@rbxts\", \"roact\").src)\
local hooked = TS.import(script, TS.getModule(script, \"@rbxts\", \"roact-hooked\").out).hooked\
local _binding_util = TS.import(script, script.Parent.Parent, \"utils\", \"binding-util\")\
local asBinding = _binding_util.asBinding\
local mapBinding = _binding_util.mapBinding\
local hex = TS.import(script, script.Parent.Parent, \"utils\", \"color3\").hex\
local px = TS.import(script, script.Parent.Parent, \"utils\", \"udim2\").px\
local function Border(_param)\
\9local size = _param.size\
\9if size == nil then\
\9\9size = 1\
\9end\
\9local radius = _param.radius\
\9if radius == nil then\
\9\9radius = 0\
\9end\
\9local color = _param.color\
\9if color == nil then\
\9\9color = hex(\"#ffffff\")\
\9end\
\9local transparency = _param.transparency\
\9if transparency == nil then\
\9\9transparency = 0\
\9end\
\9local children = _param[Roact.Children]\
\9local _attributes = {\
\9\9Size = mapBinding(size, function(s)\
\9\9\9return UDim2.new(1, -s * 2, 1, -s * 2)\
\9\9end),\
\9\9Position = mapBinding(size, function(s)\
\9\9\9return px(s, s)\
\9\9end),\
\9\9BackgroundTransparency = 1,\
\9}\
\9local _children = {}\
\9local _length = #_children\
\9local _attributes_1 = {\
\9\9Thickness = size,\
\9\9Color = color,\
\9\9Transparency = transparency,\
\9}\
\9local _children_1 = {}\
\9local _length_1 = #_children_1\
\9if children then\
\9\9for _k, _v in pairs(children) do\
\9\9\9if type(_k) == \"number\" then\
\9\9\9\9_children_1[_length_1 + _k] = _v\
\9\9\9else\
\9\9\9\9_children_1[_k] = _v\
\9\9\9end\
\9\9end\
\9end\
\9_children[_length + 1] = Roact.createElement(\"UIStroke\", _attributes_1, _children_1)\
\9_children[_length + 2] = Roact.createElement(\"UICorner\", {\
\9\9CornerRadius = Roact.joinBindings({\
\9\9\9radius = asBinding(radius),\
\9\9\9size = asBinding(size),\
\9\9}):map(function(_param_1)\
\9\9\9local radius = _param_1.radius\
\9\9\9local size = _param_1.size\
\9\9\9return radius == \"circular\" and UDim.new(1, 0) or UDim.new(0, radius - size * 2)\
\9\9end),\
\9})\
\9return Roact.createElement(\"Frame\", _attributes, _children)\
end\
local default = hooked(Border)\
return {\
\9default = default,\
}\
", '@'.."Orca.components.Border")) setfenv(fn, newEnv("Orca.components.Border")) return fn() end)

newModule("BrightButton", "ModuleScript", "Orca.components.BrightButton", "Orca.components", function () local fn = assert(loadstring("-- Compiled with roblox-ts v1.2.7\
local TS = require(script.Parent.Parent.include.RuntimeLib)\
local Roact = TS.import(script, TS.getModule(script, \"@rbxts\", \"roact\").src)\
local hooked = TS.import(script, TS.getModule(script, \"@rbxts\", \"roact-hooked\").out).hooked\
local Border = TS.import(script, script.Parent, \"Border\").default\
local Canvas = TS.import(script, script.Parent, \"Canvas\").default\
local Fill = TS.import(script, script.Parent, \"Fill\").default\
local _Glow = TS.import(script, script.Parent, \"Glow\")\
local Glow = _Glow.default\
local GlowRadius = _Glow.GlowRadius\
local hex = TS.import(script, script.Parent.Parent, \"utils\", \"color3\").hex\
local _udim2 = TS.import(script, script.Parent.Parent, \"utils\", \"udim2\")\
local px = _udim2.px\
local scale = _udim2.scale\
local function BrightButton(_param)\
\9local size = _param.size\
\9if size == nil then\
\9\9size = px(100, 100)\
\9end\
\9local position = _param.position\
\9if position == nil then\
\9\9position = px(0, 0)\
\9end\
\9local radius = _param.radius\
\9if radius == nil then\
\9\9radius = 8\
\9end\
\9local color = _param.color\
\9if color == nil then\
\9\9color = hex(\"#FFFFFF\")\
\9end\
\9local borderEnabled = _param.borderEnabled\
\9local borderColor = _param.borderColor\
\9if borderColor == nil then\
\9\9borderColor = hex(\"#FFFFFF\")\
\9end\
\9local transparency = _param.transparency\
\9if transparency == nil then\
\9\9transparency = 0\
\9end\
\9local onActivate = _param.onActivate\
\9local onPress = _param.onPress\
\9local onRelease = _param.onRelease\
\9local onHover = _param.onHover\
\9local children = _param[Roact.Children]\
\9local _attributes = {\
\9\9size = size,\
\9\9position = position,\
\9}\
\9local _children = {\
\9\9Roact.createElement(Glow, {\
\9\9\9radius = GlowRadius.Size70,\
\9\9\9color = color,\
\9\9\9size = UDim2.new(1, 36, 1, 36),\
\9\9\9position = px(-18, 5 - 18),\
\9\9\9transparency = transparency,\
\9\9}),\
\9\9Roact.createElement(Fill, {\
\9\9\9color = color,\
\9\9\9radius = radius,\
\9\9\9transparency = transparency,\
\9\9}),\
\9}\
\9local _length = #_children\
\9local _child = borderEnabled and Roact.createElement(Border, {\
\9\9color = borderColor,\
\9\9radius = radius,\
\9\9transparency = 0.8,\
\9})\
\9if _child then\
\9\9if _child.elements ~= nil or _child.props ~= nil and _child.component ~= nil then\
\9\9\9_children[_length + 1] = _child\
\9\9else\
\9\9\9for _k, _v in ipairs(_child) do\
\9\9\9\9_children[_length + _k] = _v\
\9\9\9end\
\9\9end\
\9end\
\9_length = #_children\
\9_children[_length + 1] = Roact.createElement(\"TextButton\", {\
\9\9Text = \"\",\
\9\9AutoButtonColor = false,\
\9\9Size = scale(1, 1),\
\9\9BackgroundTransparency = 1,\
\9\9[Roact.Event.Activated] = function()\
\9\9\9local _result = onActivate\
\9\9\9if _result ~= nil then\
\9\9\9\9_result = _result()\
\9\9\9end\
\9\9\9return _result\
\9\9end,\
\9\9[Roact.Event.MouseButton1Down] = function()\
\9\9\9local _result = onPress\
\9\9\9if _result ~= nil then\
\9\9\9\9_result = _result()\
\9\9\9end\
\9\9\9return _result\
\9\9end,\
\9\9[Roact.Event.MouseButton1Up] = function()\
\9\9\9local _result = onRelease\
\9\9\9if _result ~= nil then\
\9\9\9\9_result = _result()\
\9\9\9end\
\9\9\9return _result\
\9\9end,\
\9\9[Roact.Event.MouseEnter] = function()\
\9\9\9local _result = onHover\
\9\9\9if _result ~= nil then\
\9\9\9\9_result = _result(true)\
\9\9\9end\
\9\9\9return _result\
\9\9end,\
\9\9[Roact.Event.MouseLeave] = function()\
\9\9\9local _result = onHover\
\9\9\9if _result ~= nil then\
\9\9\9\9_result = _result(false)\
\9\9\9end\
\9\9\9return _result\
\9\9end,\
\9})\
\9if children then\
\9\9for _k, _v in pairs(children) do\
\9\9\9if type(_k) == \"number\" then\
\9\9\9\9_children[_length + 1 + _k] = _v\
\9\9\9else\
\9\9\9\9_children[_k] = _v\
\9\9\9end\
\9\9end\
\9end\
\9return Roact.createElement(Canvas, _attributes, _children)\
end\
local default = hooked(BrightButton)\
return {\
\9default = default,\
}\
", '@'.."Orca.components.BrightButton")) setfenv(fn, newEnv("Orca.components.BrightButton")) return fn() end)

newModule("BrightSlider", "ModuleScript", "Orca.components.BrightSlider", "Orca.components", function () local fn = assert(loadstring("-- Compiled with roblox-ts v1.2.7\
local TS = require(script.Parent.Parent.include.RuntimeLib)\
local Spring = TS.import(script, TS.getModule(script, \"@rbxts\", \"flipper\").src).Spring\
local Roact = TS.import(script, TS.getModule(script, \"@rbxts\", \"roact\").src)\
local _roact_hooked = TS.import(script, TS.getModule(script, \"@rbxts\", \"roact-hooked\").out)\
local hooked = _roact_hooked.hooked\
local useCallback = _roact_hooked.useCallback\
local useEffect = _roact_hooked.useEffect\
local useState = _roact_hooked.useState\
local UserInputService = TS.import(script, TS.getModule(script, \"@rbxts\", \"services\")).UserInputService\
local _flipper_hooks = TS.import(script, script.Parent.Parent, \"hooks\", \"common\", \"flipper-hooks\")\
local getBinding = _flipper_hooks.getBinding\
local useMotor = _flipper_hooks.useMotor\
local _udim2 = TS.import(script, script.Parent.Parent, \"utils\", \"udim2\")\
local px = _udim2.px\
local scale = _udim2.scale\
local Border = TS.import(script, script.Parent, \"Border\").default\
local Canvas = TS.import(script, script.Parent, \"Canvas\").default\
local Fill = TS.import(script, script.Parent, \"Fill\").default\
local _Glow = TS.import(script, script.Parent, \"Glow\")\
local Glow = _Glow.default\
local GlowRadius = _Glow.GlowRadius\
local SPRING_OPTIONS = {\
\9frequency = 8,\
}\
local Drag\
local function BrightSlider(_param)\
\9local min = _param.min\
\9local max = _param.max\
\9local initialValue = _param.initialValue\
\9local size = _param.size\
\9local position = _param.position\
\9local radius = _param.radius\
\9local color = _param.color\
\9local accentColor = _param.accentColor\
\9local borderEnabled = _param.borderEnabled\
\9local borderColor = _param.borderColor\
\9local transparency = _param.transparency\
\9local indicatorTransparency = _param.indicatorTransparency\
\9local onValueChanged = _param.onValueChanged\
\9local onRelease = _param.onRelease\
\9local children = _param[Roact.Children]\
\9local valueMotor = useMotor(initialValue)\
\9local valueBinding = getBinding(valueMotor)\
\9useEffect(function()\
\9\9local _result = onValueChanged\
\9\9if _result ~= nil then\
\9\9\9_result(initialValue)\
\9\9end\
\9end, {})\
\9useEffect(function()\
\9\9return function()\
\9\9\9return valueMotor:destroy()\
\9\9end\
\9end, {})\
\9local _attributes = {\
\9\9size = size,\
\9\9position = position,\
\9}\
\9local _children = {\
\9\9Roact.createElement(Glow, {\
\9\9\9radius = GlowRadius.Size70,\
\9\9\9color = accentColor,\
\9\9\9size = valueBinding:map(function(v)\
\9\9\9\9return UDim2.new((v - min) / (max - min), 36, 1, 36)\
\9\9\9end),\
\9\9\9position = px(-18, 5 - 18),\
\9\9\9transparency = 0,\
\9\9\9maintainCornerRadius = true,\
\9\9}),\
\9\9Roact.createElement(Fill, {\
\9\9\9color = color,\
\9\9\9radius = radius,\
\9\9\9transparency = transparency,\
\9\9}),\
\9\9Roact.createElement(Canvas, {\
\9\9\9size = valueBinding:map(function(v)\
\9\9\9\9return scale((v - min) / (max - min), 1)\
\9\9\9end),\
\9\9\9clipsDescendants = true,\
\9\9}, {\
\9\9\9Roact.createElement(\"Frame\", {\
\9\9\9\9Size = size,\
\9\9\9\9BackgroundColor3 = accentColor,\
\9\9\9\9BackgroundTransparency = indicatorTransparency,\
\9\9\9}, {\
\9\9\9\9Roact.createElement(\"UICorner\", {\
\9\9\9\9\9CornerRadius = UDim.new(0, radius),\
\9\9\9\9}),\
\9\9\9}),\
\9\9}),\
\9}\
\9local _length = #_children\
\9local _child = borderEnabled and Roact.createElement(Border, {\
\9\9color = borderColor,\
\9\9radius = radius,\
\9\9transparency = 0.8,\
\9})\
\9if _child then\
\9\9if _child.elements ~= nil or _child.props ~= nil and _child.component ~= nil then\
\9\9\9_children[_length + 1] = _child\
\9\9else\
\9\9\9for _k, _v in ipairs(_child) do\
\9\9\9\9_children[_length + _k] = _v\
\9\9\9end\
\9\9end\
\9end\
\9_length = #_children\
\9_children[_length + 1] = Roact.createElement(Drag, {\
\9\9onChange = function(alpha)\
\9\9\9valueMotor:setGoal(Spring.new(alpha * (max - min) + min, SPRING_OPTIONS))\
\9\9\9local _result = onValueChanged\
\9\9\9if _result ~= nil then\
\9\9\9\9_result(alpha * (max - min) + min)\
\9\9\9end\
\9\9end,\
\9\9onRelease = function(alpha)\
\9\9\9local _result = onRelease\
\9\9\9if _result ~= nil then\
\9\9\9\9_result = _result(alpha * (max - min) + min)\
\9\9\9end\
\9\9\9return _result\
\9\9end,\
\9})\
\9if children then\
\9\9for _k, _v in pairs(children) do\
\9\9\9if type(_k) == \"number\" then\
\9\9\9\9_children[_length + 1 + _k] = _v\
\9\9\9else\
\9\9\9\9_children[_k] = _v\
\9\9\9end\
\9\9end\
\9end\
\9return Roact.createElement(Canvas, _attributes, _children)\
end\
local default = hooked(BrightSlider)\
local function DragComponent(_param)\
\9local onChange = _param.onChange\
\9local onRelease = _param.onRelease\
\9local _binding = useState()\
\9local inputHandle = _binding[1]\
\9local setHandle = _binding[2]\
\9local updateValue = useCallback(function(alpha)\
\9\9alpha = math.clamp(alpha, 0, 1)\
\9\9onChange(alpha)\
\9end, {})\
\9local getValueFromPosition = useCallback(function(x, rbx)\
\9\9return (x - rbx.AbsolutePosition.X) / rbx.AbsoluteSize.X\
\9end, {})\
\9useEffect(function()\
\9\9return function()\
\9\9\9local _result = inputHandle\
\9\9\9if _result ~= nil then\
\9\9\9\9_result:Disconnect()\
\9\9\9end\
\9\9end\
\9end, {})\
\9return Roact.createElement(\"Frame\", {\
\9\9Active = true,\
\9\9Size = scale(1, 1),\
\9\9BackgroundTransparency = 1,\
\9\9[Roact.Event.InputBegan] = function(rbx, input)\
\9\9\9if input.UserInputType == Enum.UserInputType.MouseButton1 then\
\9\9\9\9local _result = inputHandle\
\9\9\9\9if _result ~= nil then\
\9\9\9\9\9_result:Disconnect()\
\9\9\9\9end\
\9\9\9\9local handle = UserInputService.InputChanged:Connect(function(input)\
\9\9\9\9\9if input.UserInputType == Enum.UserInputType.MouseMovement then\
\9\9\9\9\9\9updateValue(getValueFromPosition(input.Position.X, rbx))\
\9\9\9\9\9end\
\9\9\9\9end)\
\9\9\9\9setHandle(handle)\
\9\9\9\9updateValue(getValueFromPosition(input.Position.X, rbx))\
\9\9\9end\
\9\9end,\
\9\9[Roact.Event.InputEnded] = function(rbx, input)\
\9\9\9if input.UserInputType == Enum.UserInputType.MouseButton1 then\
\9\9\9\9local _result = inputHandle\
\9\9\9\9if _result ~= nil then\
\9\9\9\9\9_result:Disconnect()\
\9\9\9\9end\
\9\9\9\9setHandle(nil)\
\9\9\9\9onRelease(getValueFromPosition(input.Position.X, rbx))\
\9\9\9end\
\9\9end,\
\9})\
end\
Drag = hooked(DragComponent)\
return {\
\9default = default,\
}\
", '@'.."Orca.components.BrightSlider")) setfenv(fn, newEnv("Orca.components.BrightSlider")) return fn() end)

newModule("Canvas", "ModuleScript", "Orca.components.Canvas", "Orca.components", function () local fn = assert(loadstring("-- Compiled with roblox-ts v1.2.7\
local TS = require(script.Parent.Parent.include.RuntimeLib)\
local Roact = TS.import(script, TS.getModule(script, \"@rbxts\", \"roact\").src)\
local hooked = TS.import(script, TS.getModule(script, \"@rbxts\", \"roact-hooked\").out).hooked\
local mapBinding = TS.import(script, script.Parent.Parent, \"utils\", \"binding-util\").mapBinding\
local scale = TS.import(script, script.Parent.Parent, \"utils\", \"udim2\").scale\
local function Canvas(_param)\
\9local size = _param.size\
\9if size == nil then\
\9\9size = scale(1, 1)\
\9end\
\9local position = _param.position\
\9if position == nil then\
\9\9position = scale(0, 0)\
\9end\
\9local anchor = _param.anchor\
\9local padding = _param.padding\
\9local clipsDescendants = _param.clipsDescendants\
\9local zIndex = _param.zIndex\
\9local onChange = _param.onChange\
\9if onChange == nil then\
\9\9onChange = {}\
\9end\
\9local children = _param[Roact.Children]\
\9local _attributes = {\
\9\9Size = size,\
\9\9Position = position,\
\9\9AnchorPoint = anchor,\
\9\9ClipsDescendants = clipsDescendants,\
\9\9BackgroundTransparency = 1,\
\9\9ZIndex = zIndex,\
\9}\
\9for _k, _v in pairs(onChange) do\
\9\9_attributes[Roact.Change[_k]] = _v\
\9end\
\9local _children = {}\
\9local _length = #_children\
\9local _child = padding ~= nil and (Roact.createElement(\"UIPadding\", {\
\9\9PaddingTop = mapBinding(padding.top, function(px)\
\9\9\9return UDim.new(0, px)\
\9\9end),\
\9\9PaddingRight = mapBinding(padding.right, function(px)\
\9\9\9return UDim.new(0, px)\
\9\9end),\
\9\9PaddingBottom = mapBinding(padding.bottom, function(px)\
\9\9\9return UDim.new(0, px)\
\9\9end),\
\9\9PaddingLeft = mapBinding(padding.left, function(px)\
\9\9\9return UDim.new(0, px)\
\9\9end),\
\9})) or nil\
\9if _child then\
\9\9if _child.elements ~= nil or _child.props ~= nil and _child.component ~= nil then\
\9\9\9_children[_length + 1] = _child\
\9\9else\
\9\9\9for _k, _v in ipairs(_child) do\
\9\9\9\9_children[_length + _k] = _v\
\9\9\9end\
\9\9end\
\9end\
\9_length = #_children\
\9if children then\
\9\9for _k, _v in pairs(children) do\
\9\9\9if type(_k) == \"number\" then\
\9\9\9\9_children[_length + _k] = _v\
\9\9\9else\
\9\9\9\9_children[_k] = _v\
\9\9\9end\
\9\9end\
\9end\
\9return Roact.createElement(\"Frame\", _attributes, _children)\
end\
local default = hooked(Canvas)\
return {\
\9default = default,\
}\
", '@'.."Orca.components.Canvas")) setfenv(fn, newEnv("Orca.components.Canvas")) return fn() end)

newModule("Card", "ModuleScript", "Orca.components.Card", "Orca.components", function () local fn = assert(loadstring("-- Compiled with roblox-ts v1.2.7\
local TS = require(script.Parent.Parent.include.RuntimeLib)\
local Roact = TS.import(script, TS.getModule(script, \"@rbxts\", \"roact\").src)\
local hooked = TS.import(script, TS.getModule(script, \"@rbxts\", \"roact-hooked\").out).hooked\
local Acrylic = TS.import(script, script.Parent, \"Acrylic\").default\
local Border = TS.import(script, script.Parent, \"Border\").default\
local Canvas = TS.import(script, script.Parent, \"Canvas\").default\
local Fill = TS.import(script, script.Parent, \"Fill\").default\
local _Glow = TS.import(script, script.Parent, \"Glow\")\
local Glow = _Glow.default\
local GlowRadius = _Glow.GlowRadius\
local useDelayedUpdate = TS.import(script, script.Parent.Parent, \"hooks\", \"common\", \"use-delayed-update\").useDelayedUpdate\
local useSpring = TS.import(script, script.Parent.Parent, \"hooks\", \"common\", \"use-spring\").useSpring\
local useIsPageOpen = TS.import(script, script.Parent.Parent, \"hooks\", \"use-current-page\").useIsPageOpen\
local px = TS.import(script, script.Parent.Parent, \"utils\", \"udim2\").px\
local function Card(_param)\
\9local index = _param.index\
\9local page = _param.page\
\9local theme = _param.theme\
\9local size = _param.size\
\9local position = _param.position\
\9local children = _param[Roact.Children]\
\9local isOpen = useIsPageOpen(page)\
\9local isActive = useDelayedUpdate(isOpen, index * 40)\
\9local _uDim2 = UDim2.new(UDim.new(), position.Y)\
\9local _arg0 = px((size.X.Offset + 48) * 2 - position.X.Offset, 0)\
\9local _arg0_1 = px(size.X.Offset + 48 * 2, 0)\
\9local positionWhenHidden = _uDim2 - _arg0 - _arg0_1\
\9local _attributes = {\
\9\9anchor = Vector2.new(0, 1),\
\9\9size = size,\
\9\9position = useSpring(isActive and position or positionWhenHidden, {\
\9\9\9frequency = 2,\
\9\9\9dampingRatio = 0.8,\
\9\9}),\
\9}\
\9local _children = {\
\9\9Roact.createElement(Glow, {\
\9\9\9radius = GlowRadius.Size198,\
\9\9\9size = UDim2.new(1, 100, 1, 96),\
\9\9\9position = px(-50, -28),\
\9\9\9color = theme.dropshadow,\
\9\9\9gradient = theme.dropshadowGradient,\
\9\9\9transparency = theme.dropshadowTransparency,\
\9\9}),\
\9\9Roact.createElement(Fill, {\
\9\9\9color = theme.background,\
\9\9\9gradient = theme.backgroundGradient,\
\9\9\9transparency = theme.transparency,\
\9\9\9radius = 16,\
\9\9}),\
\9}\
\9local _length = #_children\
\9if children then\
\9\9for _k, _v in pairs(children) do\
\9\9\9if type(_k) == \"number\" then\
\9\9\9\9_children[_length + _k] = _v\
\9\9\9else\
\9\9\9\9_children[_k] = _v\
\9\9\9end\
\9\9end\
\9end\
\9_length = #_children\
\9local _child = theme.acrylic and Roact.createFragment({\
\9\9acrylic = Roact.createElement(Acrylic),\
\9}) or nil\
\9if _child then\
\9\9if _child.elements ~= nil or _child.props ~= nil and _child.component ~= nil then\
\9\9\9_children[_length + 1] = _child\
\9\9else\
\9\9\9for _k, _v in ipairs(_child) do\
\9\9\9\9_children[_length + _k] = _v\
\9\9\9end\
\9\9end\
\9end\
\9_length = #_children\
\9local _child_1 = theme.outlined and Roact.createElement(Border, {\
\9\9color = theme.foreground,\
\9\9radius = 16,\
\9\9transparency = 0.8,\
\9})\
\9if _child_1 then\
\9\9if _child_1.elements ~= nil or _child_1.props ~= nil and _child_1.component ~= nil then\
\9\9\9_children[_length + 1] = _child_1\
\9\9else\
\9\9\9for _k, _v in ipairs(_child_1) do\
\9\9\9\9_children[_length + _k] = _v\
\9\9\9end\
\9\9end\
\9end\
\9return Roact.createElement(Canvas, _attributes, _children)\
end\
local default = hooked(Card)\
return {\
\9default = default,\
}\
", '@'.."Orca.components.Card")) setfenv(fn, newEnv("Orca.components.Card")) return fn() end)

newModule("Fill", "ModuleScript", "Orca.components.Fill", "Orca.components", function () local fn = assert(loadstring("-- Compiled with roblox-ts v1.2.7\
local TS = require(script.Parent.Parent.include.RuntimeLib)\
local Roact = TS.import(script, TS.getModule(script, \"@rbxts\", \"roact\").src)\
local hooked = TS.import(script, TS.getModule(script, \"@rbxts\", \"roact-hooked\").out).hooked\
local mapBinding = TS.import(script, script.Parent.Parent, \"utils\", \"binding-util\").mapBinding\
local hex = TS.import(script, script.Parent.Parent, \"utils\", \"color3\").hex\
local scale = TS.import(script, script.Parent.Parent, \"utils\", \"udim2\").scale\
local function Fill(_param)\
\9local color = _param.color\
\9if color == nil then\
\9\9color = hex(\"#ffffff\")\
\9end\
\9local gradient = _param.gradient\
\9local transparency = _param.transparency\
\9if transparency == nil then\
\9\9transparency = 0\
\9end\
\9local radius = _param.radius\
\9if radius == nil then\
\9\9radius = 0\
\9end\
\9local children = _param[Roact.Children]\
\9local _attributes = {\
\9\9Size = scale(1, 1),\
\9\9BackgroundColor3 = color,\
\9\9BackgroundTransparency = transparency,\
\9}\
\9local _children = {}\
\9local _length = #_children\
\9local _child = gradient and (Roact.createFragment({\
\9\9gradient = Roact.createElement(\"UIGradient\", {\
\9\9\9Color = gradient.color,\
\9\9\9Transparency = gradient.transparency,\
\9\9\9Rotation = gradient.rotation,\
\9\9}),\
\9})) or nil\
\9if _child then\
\9\9if _child.elements ~= nil or _child.props ~= nil and _child.component ~= nil then\
\9\9\9_children[_length + 1] = _child\
\9\9else\
\9\9\9for _k, _v in ipairs(_child) do\
\9\9\9\9_children[_length + _k] = _v\
\9\9\9end\
\9\9end\
\9end\
\9_length = #_children\
\9local _child_1 = radius ~= nil and (Roact.createFragment({\
\9\9corner = Roact.createElement(\"UICorner\", {\
\9\9\9CornerRadius = mapBinding(radius, function(r)\
\9\9\9\9return r == \"circular\" and UDim.new(1, 0) or UDim.new(0, r)\
\9\9\9end),\
\9\9}),\
\9})) or nil\
\9if _child_1 then\
\9\9if _child_1.elements ~= nil or _child_1.props ~= nil and _child_1.component ~= nil then\
\9\9\9_children[_length + 1] = _child_1\
\9\9else\
\9\9\9for _k, _v in ipairs(_child_1) do\
\9\9\9\9_children[_length + _k] = _v\
\9\9\9end\
\9\9end\
\9end\
\9_length = #_children\
\9if children then\
\9\9for _k, _v in pairs(children) do\
\9\9\9if type(_k) == \"number\" then\
\9\9\9\9_children[_length + _k] = _v\
\9\9\9else\
\9\9\9\9_children[_k] = _v\
\9\9\9end\
\9\9end\
\9end\
\9return Roact.createElement(\"Frame\", _attributes, _children)\
end\
local default = hooked(Fill)\
return {\
\9default = default,\
}\
", '@'.."Orca.components.Fill")) setfenv(fn, newEnv("Orca.components.Fill")) return fn() end)

newModule("Glow", "ModuleScript", "Orca.components.Glow", "Orca.components", function () local fn = assert(loadstring("-- Compiled with roblox-ts v1.2.7\
local TS = require(script.Parent.Parent.include.RuntimeLib)\
local Roact = TS.import(script, TS.getModule(script, \"@rbxts\", \"roact\").src)\
local _roact_hooked = TS.import(script, TS.getModule(script, \"@rbxts\", \"roact-hooked\").out)\
local hooked = _roact_hooked.hooked\
local useBinding = _roact_hooked.useBinding\
local useScale = TS.import(script, script.Parent.Parent, \"hooks\", \"use-scale\").useScale\
local asBinding = TS.import(script, script.Parent.Parent, \"utils\", \"binding-util\").asBinding\
local map = TS.import(script, script.Parent.Parent, \"utils\", \"number-util\").map\
local _udim2 = TS.import(script, script.Parent.Parent, \"utils\", \"udim2\")\
local applyUDim2 = _udim2.applyUDim2\
local px = _udim2.px\
local Canvas = TS.import(script, script.Parent, \"Canvas\").default\
local GlowRadius\
do\
\9local _inverse = {}\
\9GlowRadius = setmetatable({}, {\
\9\9__index = _inverse,\
\9})\
\9GlowRadius.Size70 = \"rbxassetid://8992230903\"\
\9_inverse[\"rbxassetid://8992230903\"] = \"Size70\"\
\9GlowRadius.Size146 = \"rbxassetid://8992584561\"\
\9_inverse[\"rbxassetid://8992584561\"] = \"Size146\"\
\9GlowRadius.Size198 = \"rbxassetid://8992230677\"\
\9_inverse[\"rbxassetid://8992230677\"] = \"Size198\"\
end\
local RADIUS_TO_CENTER_OFFSET = {\
\9[GlowRadius.Size70] = 70 / 2,\
\9[GlowRadius.Size146] = 146 / 2,\
\9[GlowRadius.Size198] = 198 / 2,\
}\
local function Glow(_param)\
\9local radius = _param.radius\
\9local size = _param.size\
\9local position = _param.position\
\9local color = _param.color\
\9local gradient = _param.gradient\
\9local transparency = _param.transparency\
\9if transparency == nil then\
\9\9transparency = 0\
\9end\
\9local maintainCornerRadius = _param.maintainCornerRadius\
\9local children = _param[Roact.Children]\
\9local _binding = useBinding(Vector2.new())\
\9local absoluteSize = _binding[1]\
\9local setAbsoluteSize = _binding[2]\
\9local scaleFactor = useScale()\
\9local centerOffset = RADIUS_TO_CENTER_OFFSET[radius]\
\9local sizeModifier = maintainCornerRadius and Roact.joinBindings({\
\9\9absoluteSize = absoluteSize,\
\9\9scaleFactor = scaleFactor,\
\9\9size = asBinding(size),\
\9}):map(function(_param_1)\
\9\9local absoluteSize = _param_1.absoluteSize\
\9\9local size = _param_1.size\
\9\9local scaleFactor = _param_1.scaleFactor\
\9\9local currentSize = applyUDim2(absoluteSize, size, scaleFactor)\
\9\9return px(math.max(currentSize.X, centerOffset * 2), math.max(currentSize.Y, centerOffset * 2))\
\9end) or size\
\9local transparencyModifier = maintainCornerRadius and Roact.joinBindings({\
\9\9absoluteSize = absoluteSize,\
\9\9scaleFactor = scaleFactor,\
\9\9size = asBinding(size),\
\9\9transparency = asBinding(transparency),\
\9}):map(function(_param_1)\
\9\9local absoluteSize = _param_1.absoluteSize\
\9\9local size = _param_1.size\
\9\9local transparency = _param_1.transparency\
\9\9local scaleFactor = _param_1.scaleFactor\
\9\9local minSize = centerOffset * 2\
\9\9local currentSize = applyUDim2(absoluteSize, UDim2.fromScale(size.X.Scale, size.Y.Scale), scaleFactor).X\
\9\9if currentSize < minSize then\
\9\9\9return 1 - (1 - transparency) * map(currentSize, 0, minSize, 0, 1)\
\9\9else\
\9\9\9return transparency\
\9\9end\
\9end) or transparency\
\9local _attributes = {\
\9\9onChange = {\
\9\9\9AbsoluteSize = maintainCornerRadius and function(rbx)\
\9\9\9\9return setAbsoluteSize(rbx.AbsoluteSize)\
\9\9\9end or nil,\
\9\9},\
\9}\
\9local _children = {}\
\9local _length = #_children\
\9local _attributes_1 = {\
\9\9Image = radius,\
\9\9ImageColor3 = color,\
\9\9ImageTransparency = transparencyModifier,\
\9\9ScaleType = \"Slice\",\
\9\9SliceCenter = Rect.new(Vector2.new(centerOffset, centerOffset), Vector2.new(centerOffset, centerOffset)),\
\9\9SliceScale = scaleFactor:map(function(factor)\
\9\9\9return factor * 0.1 + 0.9\
\9\9end),\
\9\9Size = sizeModifier,\
\9\9Position = position,\
\9\9BackgroundTransparency = 1,\
\9}\
\9local _children_1 = {}\
\9local _length_1 = #_children_1\
\9local _child = gradient and (Roact.createElement(\"UIGradient\", {\
\9\9Color = gradient.color,\
\9\9Transparency = gradient.transparency,\
\9\9Rotation = gradient.rotation,\
\9})) or nil\
\9if _child then\
\9\9if _child.elements ~= nil or _child.props ~= nil and _child.component ~= nil then\
\9\9\9_children_1[_length_1 + 1] = _child\
\9\9else\
\9\9\9for _k, _v in ipairs(_child) do\
\9\9\9\9_children_1[_length_1 + _k] = _v\
\9\9\9end\
\9\9end\
\9end\
\9_length_1 = #_children_1\
\9if children then\
\9\9for _k, _v in pairs(children) do\
\9\9\9if type(_k) == \"number\" then\
\9\9\9\9_children_1[_length_1 + _k] = _v\
\9\9\9else\
\9\9\9\9_children_1[_k] = _v\
\9\9\9end\
\9\9end\
\9end\
\9_children[_length + 1] = Roact.createElement(\"ImageLabel\", _attributes_1, _children_1)\
\9return Roact.createElement(Canvas, _attributes, _children)\
end\
local default = hooked(Glow)\
return {\
\9GlowRadius = GlowRadius,\
\9RADIUS_TO_CENTER_OFFSET = RADIUS_TO_CENTER_OFFSET,\
\9default = default,\
}\
", '@'.."Orca.components.Glow")) setfenv(fn, newEnv("Orca.components.Glow")) return fn() end)

newModule("ParallaxImage", "ModuleScript", "Orca.components.ParallaxImage", "Orca.components", function () local fn = assert(loadstring("-- Compiled with roblox-ts v1.2.7\
local TS = require(script.Parent.Parent.include.RuntimeLib)\
local Roact = TS.import(script, TS.getModule(script, \"@rbxts\", \"roact\").src)\
local mapBinding = TS.import(script, script.Parent.Parent, \"utils\", \"binding-util\").mapBinding\
local scale = TS.import(script, script.Parent.Parent, \"utils\", \"udim2\").scale\
local function ParallaxImage(_param)\
\9local image = _param.image\
\9local imageSize = _param.imageSize\
\9local offset = _param.offset\
\9local padding = _param.padding\
\9local children = _param[Roact.Children]\
\9local _attributes = {\
\9\9Image = image,\
\9}\
\9local _arg0 = padding * 2\
\9_attributes.ImageRectSize = imageSize - _arg0\
\9_attributes.ImageRectOffset = mapBinding(offset, function(o)\
\9\9local _arg0_1 = o * padding\
\9\9return padding + _arg0_1\
\9end)\
\9_attributes.ScaleType = \"Crop\"\
\9_attributes.Size = scale(1, 1)\
\9_attributes.BackgroundTransparency = 1\
\9local _children = {}\
\9local _length = #_children\
\9if children then\
\9\9for _k, _v in pairs(children) do\
\9\9\9if type(_k) == \"number\" then\
\9\9\9\9_children[_length + _k] = _v\
\9\9\9else\
\9\9\9\9_children[_k] = _v\
\9\9\9end\
\9\9end\
\9end\
\9return Roact.createElement(\"ImageLabel\", _attributes, _children)\
end\
local default = ParallaxImage\
return {\
\9default = default,\
}\
", '@'.."Orca.components.ParallaxImage")) setfenv(fn, newEnv("Orca.components.ParallaxImage")) return fn() end)

newModule("constants", "ModuleScript", "Orca.constants", "Orca", function () local fn = assert(loadstring("-- Compiled with roblox-ts v1.2.7\
local IS_DEV = getgenv == nil\
local _condition = VERSION\
if _condition == nil then\
\9_condition = \"studio\"\
end\
local VERSION_TAG = _condition\
return {\
\9IS_DEV = IS_DEV,\
\9VERSION_TAG = VERSION_TAG,\
}\
", '@'.."Orca.constants")) setfenv(fn, newEnv("Orca.constants")) return fn() end)

newInstance("context", "Folder", "Orca.context", "Orca")

newModule("scale-context", "ModuleScript", "Orca.context.scale-context", "Orca.context", function () local fn = assert(loadstring("-- Compiled with roblox-ts v1.2.7\
local TS = require(script.Parent.Parent.include.RuntimeLib)\
local Roact = TS.import(script, TS.getModule(script, \"@rbxts\", \"roact\").src)\
local ScaleContext = Roact.createContext((Roact.createBinding(1)))\
return {\
\9ScaleContext = ScaleContext,\
}\
", '@'.."Orca.context.scale-context")) setfenv(fn, newEnv("Orca.context.scale-context")) return fn() end)

newInstance("hooks", "Folder", "Orca.hooks", "Orca")

newInstance("common", "Folder", "Orca.hooks.common", "Orca.hooks")

newModule("flipper-hooks", "ModuleScript", "Orca.hooks.common.flipper-hooks", "Orca.hooks.common", function () local fn = assert(loadstring("-- Compiled with roblox-ts v1.2.7\
local TS = require(script.Parent.Parent.Parent.include.RuntimeLib)\
local exports = {}\
exports.getBinding = TS.import(script, script, \"get-binding\").getBinding\
exports.useGoal = TS.import(script, script, \"use-goal\").useGoal\
exports.useInstant = TS.import(script, script, \"use-instant\").useInstant\
exports.useLinear = TS.import(script, script, \"use-linear\").useLinear\
exports.useMotor = TS.import(script, script, \"use-motor\").useMotor\
exports.useSpring = TS.import(script, script, \"use-spring\").useSpring\
return exports\
", '@'.."Orca.hooks.common.flipper-hooks")) setfenv(fn, newEnv("Orca.hooks.common.flipper-hooks")) return fn() end)

newModule("get-binding", "ModuleScript", "Orca.hooks.common.flipper-hooks.get-binding", "Orca.hooks.common.flipper-hooks", function () local fn = assert(loadstring("-- Compiled with roblox-ts v1.2.7\
local TS = require(script.Parent.Parent.Parent.Parent.include.RuntimeLib)\
local isMotor = TS.import(script, TS.getModule(script, \"@rbxts\", \"flipper\").src).isMotor\
local createBinding = TS.import(script, TS.getModule(script, \"@rbxts\", \"roact\").src).createBinding\
local AssignedBinding = setmetatable({}, {\
\9__tostring = function()\
\9\9return \"AssignedBinding\"\
\9end,\
})\
local function getBinding(motor)\
\9assert(motor, \"Missing argument #1: motor\")\
\9local _arg0 = isMotor(motor)\
\9assert(_arg0, \"Provided value is not a motor\")\
\9if motor[AssignedBinding] ~= nil then\
\9\9return motor[AssignedBinding]\
\9end\
\9local binding, setBindingValue = createBinding(motor:getValue())\
\9motor:onStep(setBindingValue)\
\9motor[AssignedBinding] = binding\
\9return binding\
end\
return {\
\9getBinding = getBinding,\
}\
", '@'.."Orca.hooks.common.flipper-hooks.get-binding")) setfenv(fn, newEnv("Orca.hooks.common.flipper-hooks.get-binding")) return fn() end)

newModule("use-goal", "ModuleScript", "Orca.hooks.common.flipper-hooks.use-goal", "Orca.hooks.common.flipper-hooks", function () local fn = assert(loadstring("-- Compiled with roblox-ts v1.2.7\
local TS = require(script.Parent.Parent.Parent.Parent.include.RuntimeLib)\
local getBinding = TS.import(script, script.Parent, \"get-binding\").getBinding\
local useMotor = TS.import(script, script.Parent, \"use-motor\").useMotor\
local function useGoal(goal)\
\9local motor = useMotor(goal._targetValue)\
\9motor:setGoal(goal)\
\9return getBinding(motor)\
end\
return {\
\9useGoal = useGoal,\
}\
", '@'.."Orca.hooks.common.flipper-hooks.use-goal")) setfenv(fn, newEnv("Orca.hooks.common.flipper-hooks.use-goal")) return fn() end)

newModule("use-instant", "ModuleScript", "Orca.hooks.common.flipper-hooks.use-instant", "Orca.hooks.common.flipper-hooks", function () local fn = assert(loadstring("-- Compiled with roblox-ts v1.2.7\
local TS = require(script.Parent.Parent.Parent.Parent.include.RuntimeLib)\
local Instant = TS.import(script, TS.getModule(script, \"@rbxts\", \"flipper\").src).Instant\
local useGoal = TS.import(script, script.Parent, \"use-goal\").useGoal\
local function useInstant(targetValue)\
\9return useGoal(Instant.new(targetValue))\
end\
return {\
\9useInstant = useInstant,\
}\
", '@'.."Orca.hooks.common.flipper-hooks.use-instant")) setfenv(fn, newEnv("Orca.hooks.common.flipper-hooks.use-instant")) return fn() end)

newModule("use-linear", "ModuleScript", "Orca.hooks.common.flipper-hooks.use-linear", "Orca.hooks.common.flipper-hooks", function () local fn = assert(loadstring("-- Compiled with roblox-ts v1.2.7\
local TS = require(script.Parent.Parent.Parent.Parent.include.RuntimeLib)\
local Linear = TS.import(script, TS.getModule(script, \"@rbxts\", \"flipper\").src).Linear\
local useGoal = TS.import(script, script.Parent, \"use-goal\").useGoal\
local function useLinear(targetValue, options)\
\9return useGoal(Linear.new(targetValue, options))\
end\
return {\
\9useLinear = useLinear,\
}\
", '@'.."Orca.hooks.common.flipper-hooks.use-linear")) setfenv(fn, newEnv("Orca.hooks.common.flipper-hooks.use-linear")) return fn() end)

newModule("use-motor", "ModuleScript", "Orca.hooks.common.flipper-hooks.use-motor", "Orca.hooks.common.flipper-hooks", function () local fn = assert(loadstring("-- Compiled with roblox-ts v1.2.7\
local TS = require(script.Parent.Parent.Parent.Parent.include.RuntimeLib)\
local _flipper = TS.import(script, TS.getModule(script, \"@rbxts\", \"flipper\").src)\
local GroupMotor = _flipper.GroupMotor\
local SingleMotor = _flipper.SingleMotor\
local useMutable = TS.import(script, TS.getModule(script, \"@rbxts\", \"roact-hooked\").out.hooks).useMutable\
local function createMotor(initialValue)\
\9if type(initialValue) == \"number\" then\
\9\9return SingleMotor.new(initialValue)\
\9elseif type(initialValue) == \"table\" then\
\9\9return GroupMotor.new(initialValue)\
\9else\
\9\9error(\"Invalid type for initialValue. Expected 'number' or 'table', got '\" .. (tostring(initialValue) .. \"'\"))\
\9end\
end\
local function useMotor(initialValue)\
\9return useMutable(createMotor(initialValue)).current\
end\
return {\
\9useMotor = useMotor,\
}\
", '@'.."Orca.hooks.common.flipper-hooks.use-motor")) setfenv(fn, newEnv("Orca.hooks.common.flipper-hooks.use-motor")) return fn() end)

newModule("use-spring", "ModuleScript", "Orca.hooks.common.flipper-hooks.use-spring", "Orca.hooks.common.flipper-hooks", function () local fn = assert(loadstring("-- Compiled with roblox-ts v1.2.7\
local TS = require(script.Parent.Parent.Parent.Parent.include.RuntimeLib)\
local Spring = TS.import(script, TS.getModule(script, \"@rbxts\", \"flipper\").src).Spring\
local useGoal = TS.import(script, script.Parent, \"use-goal\").useGoal\
local function useSpring(targetValue, options)\
\9return useGoal(Spring.new(targetValue, options))\
end\
return {\
\9useSpring = useSpring,\
}\
", '@'.."Orca.hooks.common.flipper-hooks.use-spring")) setfenv(fn, newEnv("Orca.hooks.common.flipper-hooks.use-spring")) return fn() end)

newModule("rodux-hooks", "ModuleScript", "Orca.hooks.common.rodux-hooks", "Orca.hooks.common", function () local fn = assert(loadstring("-- Compiled with roblox-ts v1.2.7\
local TS = require(script.Parent.Parent.Parent.include.RuntimeLib)\
local _roact_rodux_hooked = TS.import(script, TS.getModule(script, \"@rbxts\", \"roact-rodux-hooked\").out)\
local useDispatch = _roact_rodux_hooked.useDispatch\
local useSelector = _roact_rodux_hooked.useSelector\
local useStore = _roact_rodux_hooked.useStore\
local useAppSelector = useSelector\
local useAppDispatch = function()\
\9return useDispatch()\
end\
local useAppStore = function()\
\9return useStore()\
end\
return {\
\9useAppSelector = useAppSelector,\
\9useAppDispatch = useAppDispatch,\
\9useAppStore = useAppStore,\
}\
", '@'.."Orca.hooks.common.rodux-hooks")) setfenv(fn, newEnv("Orca.hooks.common.rodux-hooks")) return fn() end)

newModule("use-delayed-update", "ModuleScript", "Orca.hooks.common.use-delayed-update", "Orca.hooks.common", function () local fn = assert(loadstring("-- Compiled with roblox-ts v1.2.7\
local TS = require(script.Parent.Parent.Parent.include.RuntimeLib)\
local _roact_hooked = TS.import(script, TS.getModule(script, \"@rbxts\", \"roact-hooked\").out)\
local useEffect = _roact_hooked.useEffect\
local useMutable = _roact_hooked.useMutable\
local useState = _roact_hooked.useState\
local _timeout = TS.import(script, script.Parent.Parent.Parent, \"utils\", \"timeout\")\
local clearTimeout = _timeout.clearTimeout\
local setTimeout = _timeout.setTimeout\
local nextId = 0\
local function clearUpdates(updates, laterThan)\
\9for id, update in pairs(updates) do\
\9\9if laterThan == nil or update.resolveTime >= laterThan then\
\9\9\9-- ▼ Map.delete ▼\
\9\9\9updates[id] = nil\
\9\9\9-- ▲ Map.delete ▲\
\9\9\9clearTimeout(update.timeout)\
\9\9end\
\9end\
end\
local function useDelayedUpdate(value, delay, isImmediate)\
\9local _binding = useState(value)\
\9local delayedValue = _binding[1]\
\9local setDelayedValue = _binding[2]\
\9local updates = useMutable({})\
\9useEffect(function()\
\9\9local _result = isImmediate\
\9\9if _result ~= nil then\
\9\9\9_result = _result(value)\
\9\9end\
\9\9if _result then\
\9\9\9clearUpdates(updates.current)\
\9\9\9setDelayedValue(value)\
\9\9\9return nil\
\9\9end\
\9\9local _original = nextId\
\9\9nextId += 1\
\9\9local id = _original\
\9\9local update = {\
\9\9\9timeout = setTimeout(function()\
\9\9\9\9setDelayedValue(value)\
\9\9\9\9-- ▼ Map.delete ▼\
\9\9\9\9updates.current[id] = nil\
\9\9\9\9-- ▲ Map.delete ▲\
\9\9\9end, delay),\
\9\9\9resolveTime = os.clock() + delay,\
\9\9}\
\9\9clearUpdates(updates.current, update.resolveTime)\
\9\9-- ▼ Map.set ▼\
\9\9updates.current[id] = update\
\9\9-- ▲ Map.set ▲\
\9end, { value })\
\9useEffect(function()\
\9\9return function()\
\9\9\9return clearUpdates(updates.current)\
\9\9end\
\9end, {})\
\9return delayedValue\
end\
return {\
\9useDelayedUpdate = useDelayedUpdate,\
}\
", '@'.."Orca.hooks.common.use-delayed-update")) setfenv(fn, newEnv("Orca.hooks.common.use-delayed-update")) return fn() end)

newModule("use-did-mount", "ModuleScript", "Orca.hooks.common.use-did-mount", "Orca.hooks.common", function () local fn = assert(loadstring("-- Compiled with roblox-ts v1.2.7\
local TS = require(script.Parent.Parent.Parent.include.RuntimeLib)\
local _roact_hooked = TS.import(script, TS.getModule(script, \"@rbxts\", \"roact-hooked\").out)\
local useEffect = _roact_hooked.useEffect\
local useMutable = _roact_hooked.useMutable\
local function useDidMount(callback)\
\9local ref = useMutable(callback)\
\9useEffect(function()\
\9\9if ref.current then\
\9\9\9ref.current()\
\9\9end\
\9end, {})\
\9return ref\
end\
local function useIsMount()\
\9local ref = useMutable(true)\
\9useEffect(function()\
\9\9ref.current = false\
\9end, {})\
\9return ref.current\
end\
return {\
\9useDidMount = useDidMount,\
\9useIsMount = useIsMount,\
}\
", '@'.."Orca.hooks.common.use-did-mount")) setfenv(fn, newEnv("Orca.hooks.common.use-did-mount")) return fn() end)

newModule("use-forced-update", "ModuleScript", "Orca.hooks.common.use-forced-update", "Orca.hooks.common", function () local fn = assert(loadstring("-- Compiled with roblox-ts v1.2.7\
local TS = require(script.Parent.Parent.Parent.include.RuntimeLib)\
local _roact_hooked = TS.import(script, TS.getModule(script, \"@rbxts\", \"roact-hooked\").out)\
local useCallback = _roact_hooked.useCallback\
local useState = _roact_hooked.useState\
local function useForcedUpdate()\
\9local _binding = useState(0)\
\9local setState = _binding[2]\
\9return useCallback(function()\
\9\9return setState(function(state)\
\9\9\9return state + 1\
\9\9end)\
\9end, {})\
end\
return {\
\9useForcedUpdate = useForcedUpdate,\
}\
", '@'.."Orca.hooks.common.use-forced-update")) setfenv(fn, newEnv("Orca.hooks.common.use-forced-update")) return fn() end)

newModule("use-interval", "ModuleScript", "Orca.hooks.common.use-interval", "Orca.hooks.common", function () local fn = assert(loadstring("-- Compiled with roblox-ts v1.2.7\
local TS = require(script.Parent.Parent.Parent.include.RuntimeLib)\
local useEffect = TS.import(script, TS.getModule(script, \"@rbxts\", \"roact-hooked\").out).useEffect\
local _timeout = TS.import(script, script.Parent.Parent.Parent, \"utils\", \"timeout\")\
local clearInterval = _timeout.clearInterval\
local setInterval = _timeout.setInterval\
local function useInterval(callback, delay, deps)\
\9if deps == nil then\
\9\9deps = {}\
\9end\
\9local _exp = function()\
\9\9if delay ~= nil then\
\9\9\9local interval = setInterval(callback, delay)\
\9\9\9return function()\
\9\9\9\9return clearInterval(interval)\
\9\9\9end\
\9\9end\
\9end\
\9local _array = { callback, delay }\
\9local _length = #_array\
\9table.move(deps, 1, #deps, _length + 1, _array)\
\9useEffect(_exp, _array)\
\9return setInterval\
end\
return {\
\9useInterval = useInterval,\
}\
", '@'.."Orca.hooks.common.use-interval")) setfenv(fn, newEnv("Orca.hooks.common.use-interval")) return fn() end)

newModule("use-mouse-location", "ModuleScript", "Orca.hooks.common.use-mouse-location", "Orca.hooks.common", function () local fn = assert(loadstring("-- Compiled with roblox-ts v1.2.7\
local TS = require(script.Parent.Parent.Parent.include.RuntimeLib)\
local _roact_hooked = TS.import(script, TS.getModule(script, \"@rbxts\", \"roact-hooked\").out)\
local useBinding = _roact_hooked.useBinding\
local useEffect = _roact_hooked.useEffect\
local UserInputService = TS.import(script, TS.getModule(script, \"@rbxts\", \"services\")).UserInputService\
local function useMouseLocation(onChange)\
\9local _binding = useBinding(UserInputService:GetMouseLocation())\
\9local location = _binding[1]\
\9local setLocation = _binding[2]\
\9useEffect(function()\
\9\9local handle = UserInputService.InputChanged:Connect(function(input)\
\9\9\9if input.UserInputType == Enum.UserInputType.MouseMovement then\
\9\9\9\9setLocation(Vector2.new(input.Position.X, input.Position.Y))\
\9\9\9\9local _result = onChange\
\9\9\9\9if _result ~= nil then\
\9\9\9\9\9_result(Vector2.new(input.Position.X, input.Position.Y))\
\9\9\9\9end\
\9\9\9end\
\9\9end)\
\9\9return function()\
\9\9\9handle:Disconnect()\
\9\9end\
\9end, {})\
\9return location\
end\
return {\
\9useMouseLocation = useMouseLocation,\
}\
", '@'.."Orca.hooks.common.use-mouse-location")) setfenv(fn, newEnv("Orca.hooks.common.use-mouse-location")) return fn() end)

newModule("use-promise", "ModuleScript", "Orca.hooks.common.use-promise", "Orca.hooks.common", function () local fn = assert(loadstring("-- Compiled with roblox-ts v1.2.7\
local TS = require(script.Parent.Parent.Parent.include.RuntimeLib)\
local _roact_hooked = TS.import(script, TS.getModule(script, \"@rbxts\", \"roact-hooked\").out)\
local useEffect = _roact_hooked.useEffect\
local useReducer = _roact_hooked.useReducer\
local function resolvePromise(promise)\
\9if type(promise) == \"function\" then\
\9\9return promise()\
\9end\
\9return promise\
end\
local states = {\
\9pending = \"pending\",\
\9rejected = \"rejected\",\
\9resolved = \"resolved\",\
}\
local defaultState = {\
\9err = nil,\
\9result = nil,\
\9state = states.pending,\
}\
local function reducer(state, action)\
\9local _exp = action.type\
\9repeat\
\9\9if _exp == (states.pending) then\
\9\9\9return defaultState\
\9\9end\
\9\9if _exp == (states.resolved) then\
\9\9\9return {\
\9\9\9\9err = nil,\
\9\9\9\9result = action.payload,\
\9\9\9\9state = states.resolved,\
\9\9\9}\
\9\9end\
\9\9if _exp == (states.rejected) then\
\9\9\9return {\
\9\9\9\9err = action.payload,\
\9\9\9\9result = nil,\
\9\9\9\9state = states.rejected,\
\9\9\9}\
\9\9end\
\9\9return state\
\9until true\
end\
local function usePromise(promise, deps)\
\9if deps == nil then\
\9\9deps = {}\
\9end\
\9local _binding = useReducer(reducer, defaultState)\
\9local _binding_1 = _binding[1]\
\9local err = _binding_1.err\
\9local result = _binding_1.result\
\9local state = _binding_1.state\
\9local dispatch = _binding[2]\
\9useEffect(function()\
\9\9promise = resolvePromise(promise)\
\9\9if not promise then\
\9\9\9return nil\
\9\9end\
\9\9local canceled = false\
\9\9dispatch({\
\9\9\9type = states.pending,\
\9\9})\
\9\9local _arg0 = function(result)\
\9\9\9return not canceled and dispatch({\
\9\9\9\9payload = result,\
\9\9\9\9type = states.resolved,\
\9\9\9})\
\9\9end\
\9\9local _arg1 = function(err)\
\9\9\9return not canceled and dispatch({\
\9\9\9\9payload = err,\
\9\9\9\9type = states.rejected,\
\9\9\9})\
\9\9end\
\9\9promise:andThen(_arg0, _arg1)\
\9\9return function()\
\9\9\9canceled = true\
\9\9end\
\9end, deps)\
\9return { result, err, state }\
end\
return {\
\9usePromise = usePromise,\
}\
", '@'.."Orca.hooks.common.use-promise")) setfenv(fn, newEnv("Orca.hooks.common.use-promise")) return fn() end)

newModule("use-set-state", "ModuleScript", "Orca.hooks.common.use-set-state", "Orca.hooks.common", function () local fn = assert(loadstring("-- Compiled with roblox-ts v1.2.7\
local TS = require(script.Parent.Parent.Parent.include.RuntimeLib)\
local useState = TS.import(script, TS.getModule(script, \"@rbxts\", \"roact-hooked\").out).useState\
local function useSetState(initialState)\
\9local _binding = useState(initialState)\
\9local state = _binding[1]\
\9local setState = _binding[2]\
\9local merge = function(action)\
\9\9return setState(function(s)\
\9\9\9local _object = {}\
\9\9\9if type(s) == \"table\" then\
\9\9\9\9for _k, _v in pairs(s) do\
\9\9\9\9\9_object[_k] = _v\
\9\9\9\9end\
\9\9\9end\
\9\9\9local _result\
\9\9\9if type(action) == \"function\" then\
\9\9\9\9_result = action(s)\
\9\9\9else\
\9\9\9\9_result = action\
\9\9\9end\
\9\9\9if type(_result) == \"table\" then\
\9\9\9\9for _k, _v in pairs(_result) do\
\9\9\9\9\9_object[_k] = _v\
\9\9\9\9end\
\9\9\9end\
\9\9\9return _object\
\9\9end)\
\9end\
\9return { state, merge }\
end\
return {\
\9default = useSetState,\
}\
", '@'.."Orca.hooks.common.use-set-state")) setfenv(fn, newEnv("Orca.hooks.common.use-set-state")) return fn() end)

newModule("use-spring", "ModuleScript", "Orca.hooks.common.use-spring", "Orca.hooks.common", function () local fn = assert(loadstring("-- Compiled with roblox-ts v1.2.7\
local TS = require(script.Parent.Parent.Parent.include.RuntimeLib)\
local Spring = TS.import(script, TS.getModule(script, \"@rbxts\", \"flipper\").src).Spring\
local Roact = TS.import(script, TS.getModule(script, \"@rbxts\", \"roact\").src)\
local _flipper_hooks = TS.import(script, script.Parent, \"flipper-hooks\")\
local getBinding = _flipper_hooks.getBinding\
local useMotor = _flipper_hooks.useMotor\
local useNumberSpring = _flipper_hooks.useSpring\
local supportedTypes = {\
\9number = useNumberSpring,\
\9Color3 = function(color, options)\
\9\9local motor = useMotor({ color.R, color.G, color.B })\
\9\9motor:setGoal({ Spring.new(color.R, options), Spring.new(color.G, options), Spring.new(color.B, options) })\
\9\9return getBinding(motor):map(function(_param)\
\9\9\9local r = _param[1]\
\9\9\9local g = _param[2]\
\9\9\9local b = _param[3]\
\9\9\9return Color3.new(r, g, b)\
\9\9end)\
\9end,\
\9UDim = function(udim, options)\
\9\9local motor = useMotor({ udim.Scale, udim.Offset })\
\9\9motor:setGoal({ Spring.new(udim.Scale, options), Spring.new(udim.Offset, options) })\
\9\9return getBinding(motor):map(function(_param)\
\9\9\9local s = _param[1]\
\9\9\9local o = _param[2]\
\9\9\9return UDim.new(s, o)\
\9\9end)\
\9end,\
\9UDim2 = function(udim2, options)\
\9\9local motor = useMotor({ udim2.X.Scale, udim2.X.Offset, udim2.Y.Scale, udim2.Y.Offset })\
\9\9motor:setGoal({ Spring.new(udim2.X.Scale, options), Spring.new(udim2.X.Offset, options), Spring.new(udim2.Y.Scale, options), Spring.new(udim2.Y.Offset, options) })\
\9\9return getBinding(motor):map(function(_param)\
\9\9\9local xS = _param[1]\
\9\9\9local xO = _param[2]\
\9\9\9local yS = _param[3]\
\9\9\9local yO = _param[4]\
\9\9\9return UDim2.new(xS, math.round(xO), yS, math.round(yO))\
\9\9end)\
\9end,\
\9Vector2 = function(vector2, options)\
\9\9local motor = useMotor({ vector2.X, vector2.Y })\
\9\9motor:setGoal({ Spring.new(vector2.X, options), Spring.new(vector2.Y, options) })\
\9\9return getBinding(motor):map(function(_param)\
\9\9\9local X = _param[1]\
\9\9\9local Y = _param[2]\
\9\9\9return Vector2.new(X, Y)\
\9\9end)\
\9end,\
}\
local function useSpring(value, options)\
\9if not options then\
\9\9return (Roact.createBinding(value))\
\9end\
\9local useSpring = supportedTypes[typeof(value)]\
\9local _arg1 = \"useAnySpring: \" .. (typeof(value) .. \" is not supported\")\
\9assert(useSpring, _arg1)\
\9return useSpring(value, options)\
end\
return {\
\9useSpring = useSpring,\
}\
", '@'.."Orca.hooks.common.use-spring")) setfenv(fn, newEnv("Orca.hooks.common.use-spring")) return fn() end)

newModule("use-viewport-size", "ModuleScript", "Orca.hooks.common.use-viewport-size", "Orca.hooks.common", function () local fn = assert(loadstring("-- Compiled with roblox-ts v1.2.7\
local TS = require(script.Parent.Parent.Parent.include.RuntimeLib)\
local _roact_hooked = TS.import(script, TS.getModule(script, \"@rbxts\", \"roact-hooked\").out)\
local useBinding = _roact_hooked.useBinding\
local useEffect = _roact_hooked.useEffect\
local useState = _roact_hooked.useState\
local Workspace = TS.import(script, TS.getModule(script, \"@rbxts\", \"services\")).Workspace\
local function useViewportSize(onChange)\
\9local _binding = useState(Workspace.CurrentCamera)\
\9local camera = _binding[1]\
\9local setCamera = _binding[2]\
\9local _binding_1 = useBinding(camera.ViewportSize)\
\9local size = _binding_1[1]\
\9local setSize = _binding_1[2]\
\9useEffect(function()\
\9\9local handle = Workspace:GetPropertyChangedSignal(\"CurrentCamera\"):Connect(function()\
\9\9\9if Workspace.CurrentCamera then\
\9\9\9\9setCamera(Workspace.CurrentCamera)\
\9\9\9\9setSize(Workspace.CurrentCamera.ViewportSize)\
\9\9\9\9local _result = onChange\
\9\9\9\9if _result ~= nil then\
\9\9\9\9\9_result(Workspace.CurrentCamera.ViewportSize)\
\9\9\9\9end\
\9\9\9end\
\9\9end)\
\9\9return function()\
\9\9\9handle:Disconnect()\
\9\9end\
\9end, {})\
\9useEffect(function()\
\9\9local handle = camera:GetPropertyChangedSignal(\"ViewportSize\"):Connect(function()\
\9\9\9setSize(camera.ViewportSize)\
\9\9\9local _result = onChange\
\9\9\9if _result ~= nil then\
\9\9\9\9_result(camera.ViewportSize)\
\9\9\9end\
\9\9end)\
\9\9return function()\
\9\9\9handle:Disconnect()\
\9\9end\
\9end, { camera })\
\9return size\
end\
return {\
\9useViewportSize = useViewportSize,\
}\
", '@'.."Orca.hooks.common.use-viewport-size")) setfenv(fn, newEnv("Orca.hooks.common.use-viewport-size")) return fn() end)

newModule("use-current-page", "ModuleScript", "Orca.hooks.use-current-page", "Orca.hooks", function () local fn = assert(loadstring("-- Compiled with roblox-ts v1.2.7\
local TS = require(script.Parent.Parent.include.RuntimeLib)\
local useAppSelector = TS.import(script, script.Parent, \"common\", \"rodux-hooks\").useAppSelector\
local function useCurrentPage()\
\9return useAppSelector(function(state)\
\9\9return state.dashboard.page\
\9end)\
end\
local function useIsPageOpen(page)\
\9return useAppSelector(function(state)\
\9\9return state.dashboard.isOpen and state.dashboard.page == page\
\9end)\
end\
return {\
\9useCurrentPage = useCurrentPage,\
\9useIsPageOpen = useIsPageOpen,\
}\
", '@'.."Orca.hooks.use-current-page")) setfenv(fn, newEnv("Orca.hooks.use-current-page")) return fn() end)

newModule("use-friends", "ModuleScript", "Orca.hooks.use-friends", "Orca.hooks", function () local fn = assert(loadstring("-- Compiled with roblox-ts v1.2.7\
local TS = require(script.Parent.Parent.include.RuntimeLib)\
local useMemo = TS.import(script, TS.getModule(script, \"@rbxts\", \"roact-hooked\").out).useMemo\
local Players = TS.import(script, TS.getModule(script, \"@rbxts\", \"services\")).Players\
local usePromise = TS.import(script, script.Parent, \"common\", \"use-promise\").usePromise\
local function useFriends(deps)\
\9return usePromise(TS.async(function()\
\9\9return Players.LocalPlayer:GetFriendsOnline()\
\9end), deps)\
end\
local function useFriendsPlaying(deps)\
\9local _binding = useFriends(deps)\
\9local friends = _binding[1]\
\9local err = _binding[2]\
\9local status = _binding[3]\
\9local _friendsPlaying = friends\
\9if _friendsPlaying ~= nil then\
\9\9local _arg0 = function(friend)\
\9\9\9return friend.PlaceId ~= nil and friend.GameId ~= nil\
\9\9end\
\9\9-- ▼ ReadonlyArray.filter ▼\
\9\9local _newValue = {}\
\9\9local _length = 0\
\9\9for _k, _v in ipairs(_friendsPlaying) do\
\9\9\9if _arg0(_v, _k - 1, _friendsPlaying) == true then\
\9\9\9\9_length += 1\
\9\9\9\9_newValue[_length] = _v\
\9\9\9end\
\9\9end\
\9\9-- ▲ ReadonlyArray.filter ▲\
\9\9_friendsPlaying = _newValue\
\9end\
\9local friendsPlaying = _friendsPlaying\
\9return { friendsPlaying, err, status }\
end\
local function useFriendActivity(deps)\
\9local _binding = useFriendsPlaying(deps)\
\9local friends = _binding[1]\
\9local err = _binding[2]\
\9local status = _binding[3]\
\9local games = useMemo(function()\
\9\9return {}\
\9end, deps)\
\9if not friends or #games > 0 then\
\9\9return { games, err, status }\
\9end\
\9local _arg0 = function(friend)\
\9\9local _arg0_1 = function(g)\
\9\9\9return g.placeId == friend.PlaceId\
\9\9end\
\9\9-- ▼ ReadonlyArray.find ▼\
\9\9local _result = nil\
\9\9for _i, _v in ipairs(games) do\
\9\9\9if _arg0_1(_v, _i - 1, games) == true then\
\9\9\9\9_result = _v\
\9\9\9\9break\
\9\9\9end\
\9\9end\
\9\9-- ▲ ReadonlyArray.find ▲\
\9\9local gameActivity = _result\
\9\9if not gameActivity then\
\9\9\9gameActivity = {\
\9\9\9\9friends = { friend },\
\9\9\9\9placeId = friend.PlaceId,\
\9\9\9\9thumbnail = \"https://www.roblox.com/asset-thumbnail/image?assetId=\" .. (tostring(friend.PlaceId) .. \"&width=768&height=432&format=png\"),\
\9\9\9}\
\9\9\9local _gameActivity = gameActivity\
\9\9\9-- ▼ Array.push ▼\
\9\9\9games[#games + 1] = _gameActivity\
\9\9\9-- ▲ Array.push ▲\
\9\9else\
\9\9\9local _friends = gameActivity.friends\
\9\9\9-- ▼ Array.push ▼\
\9\9\9_friends[#_friends + 1] = friend\
\9\9\9-- ▲ Array.push ▲\
\9\9end\
\9end\
\9-- ▼ ReadonlyArray.forEach ▼\
\9for _k, _v in ipairs(friends) do\
\9\9_arg0(_v, _k - 1, friends)\
\9end\
\9-- ▲ ReadonlyArray.forEach ▲\
\9return { games, err, status }\
end\
return {\
\9useFriends = useFriends,\
\9useFriendsPlaying = useFriendsPlaying,\
\9useFriendActivity = useFriendActivity,\
}\
", '@'.."Orca.hooks.use-friends")) setfenv(fn, newEnv("Orca.hooks.use-friends")) return fn() end)

newModule("use-parallax-offset", "ModuleScript", "Orca.hooks.use-parallax-offset", "Orca.hooks", function () local fn = assert(loadstring("-- Compiled with roblox-ts v1.2.7\
local TS = require(script.Parent.Parent.include.RuntimeLib)\
local Spring = TS.import(script, TS.getModule(script, \"@rbxts\", \"flipper\").src).Spring\
local Roact = TS.import(script, TS.getModule(script, \"@rbxts\", \"roact\").src)\
local _flipper_hooks = TS.import(script, script.Parent, \"common\", \"flipper-hooks\")\
local getBinding = _flipper_hooks.getBinding\
local useMotor = _flipper_hooks.useMotor\
local useMouseLocation = TS.import(script, script.Parent, \"common\", \"use-mouse-location\").useMouseLocation\
local useViewportSize = TS.import(script, script.Parent, \"common\", \"use-viewport-size\").useViewportSize\
local function useParallaxOffset()\
\9local mouseLocationMotor = useMotor({ 0, 0 })\
\9local mouseLocation = getBinding(mouseLocationMotor)\
\9local viewportSize = useViewportSize()\
\9local offset = Roact.joinBindings({\
\9\9viewportSize = viewportSize,\
\9\9mouseLocation = mouseLocation,\
\9}):map(function(_param)\
\9\9local viewportSize = _param.viewportSize\
\9\9local _binding = _param.mouseLocation\
\9\9local x = _binding[1]\
\9\9local y = _binding[2]\
\9\9return Vector2.new((x - viewportSize.X / 2) / viewportSize.X, (y - viewportSize.Y / 2) / viewportSize.Y)\
\9end)\
\9useMouseLocation(function(location)\
\9\9mouseLocationMotor:setGoal({ Spring.new(location.X, {\
\9\9\9dampingRatio = 5,\
\9\9}), Spring.new(location.Y, {\
\9\9\9dampingRatio = 5,\
\9\9}) })\
\9end)\
\9return offset\
end\
return {\
\9useParallaxOffset = useParallaxOffset,\
}\
", '@'.."Orca.hooks.use-parallax-offset")) setfenv(fn, newEnv("Orca.hooks.use-parallax-offset")) return fn() end)

newModule("use-scale", "ModuleScript", "Orca.hooks.use-scale", "Orca.hooks", function () local fn = assert(loadstring("-- Compiled with roblox-ts v1.2.7\
local TS = require(script.Parent.Parent.include.RuntimeLib)\
local Roact = TS.import(script, TS.getModule(script, \"@rbxts\", \"roact\").src)\
local useContext = TS.import(script, TS.getModule(script, \"@rbxts\", \"roact-hooked\").out).useContext\
local ScaleContext = TS.import(script, script.Parent.Parent, \"context\", \"scale-context\").ScaleContext\
local defaultScale = Roact.createBinding(1)\
local function useScale()\
\9local _condition = useContext(ScaleContext)\
\9if _condition == nil then\
\9\9_condition = defaultScale\
\9end\
\9return _condition\
end\
return {\
\9useScale = useScale,\
}\
", '@'.."Orca.hooks.use-scale")) setfenv(fn, newEnv("Orca.hooks.use-scale")) return fn() end)

newModule("use-theme", "ModuleScript", "Orca.hooks.use-theme", "Orca.hooks", function () local fn = assert(loadstring("-- Compiled with roblox-ts v1.2.7\
local TS = require(script.Parent.Parent.include.RuntimeLib)\
local useAppSelector = TS.import(script, script.Parent, \"common\", \"rodux-hooks\").useAppSelector\
local getThemes = TS.import(script, script.Parent.Parent, \"themes\").getThemes\
local darkTheme = TS.import(script, script.Parent.Parent, \"themes\", \"dark-theme\").darkTheme\
local function useTheme(key)\
\9return useAppSelector(function(state)\
\9\9local _exp = getThemes()\
\9\9local _arg0 = function(t)\
\9\9\9return t.name == state.options.currentTheme\
\9\9end\
\9\9-- ▼ ReadonlyArray.find ▼\
\9\9local _result = nil\
\9\9for _i, _v in ipairs(_exp) do\
\9\9\9if _arg0(_v, _i - 1, _exp) == true then\
\9\9\9\9_result = _v\
\9\9\9\9break\
\9\9\9end\
\9\9end\
\9\9-- ▲ ReadonlyArray.find ▲\
\9\9local theme = _result\
\9\9return theme and theme[key] or darkTheme[key]\
\9end)\
end\
return {\
\9useTheme = useTheme,\
}\
", '@'.."Orca.hooks.use-theme")) setfenv(fn, newEnv("Orca.hooks.use-theme")) return fn() end)

newModule("jobs", "ModuleScript", "Orca.jobs", "Orca", function () local fn = assert(loadstring("-- Compiled with roblox-ts v1.2.7\
local TS = require(script.Parent.include.RuntimeLib)\
local exports = {}\
exports.setStore = TS.import(script, script, \"helpers\", \"job-store\").setStore\
return exports\
", '@'.."Orca.jobs")) setfenv(fn, newEnv("Orca.jobs")) return fn() end)

newModule("acrylic", "LocalScript", "Orca.jobs.acrylic", "Orca.jobs", function () local fn = assert(loadstring("-- Compiled with roblox-ts v1.2.7\
local TS = require(script.Parent.Parent.include.RuntimeLib)\
local Make = TS.import(script, TS.getModule(script, \"@rbxts\", \"make\"))\
local Lighting = TS.import(script, TS.getModule(script, \"@rbxts\", \"services\")).Lighting\
local getStore = TS.import(script, script.Parent, \"helpers\", \"job-store\").getStore\
local setTimeout = TS.import(script, script.Parent.Parent, \"utils\", \"timeout\").setTimeout\
local baseEffect = Make(\"DepthOfFieldEffect\", {\
\9FarIntensity = 0,\
\9InFocusRadius = 0.1,\
\9NearIntensity = 1,\
})\
local depthOfFieldDefaults = {}\
local function enableAcrylic()\
\9for effect in pairs(depthOfFieldDefaults) do\
\9\9effect.Enabled = false\
\9end\
\9baseEffect.Parent = Lighting\
end\
local function disableAcrylic()\
\9for effect, defaults in pairs(depthOfFieldDefaults) do\
\9\9effect.Enabled = defaults.enabled\
\9end\
\9baseEffect.Parent = nil\
end\
local main = TS.async(function()\
\9local store = TS.await(getStore())\
\9for _, effect in ipairs(Lighting:GetChildren()) do\
\9\9if effect:IsA(\"DepthOfFieldEffect\") then\
\9\9\9local _arg1 = {\
\9\9\9\9enabled = effect.Enabled,\
\9\9\9}\
\9\9\9-- ▼ Map.set ▼\
\9\9\9depthOfFieldDefaults[effect] = _arg1\
\9\9\9-- ▲ Map.set ▲\
\9\9end\
\9end\
\9local timeout\
\9store.changed:connect(function(newState)\
\9\9local _result = timeout\
\9\9if _result ~= nil then\
\9\9\9_result:clear()\
\9\9end\
\9\9timeout = nil\
\9\9if not newState.dashboard.isOpen then\
\9\9\9timeout = setTimeout(disableAcrylic, 500)\
\9\9\9return nil\
\9\9end\
\9\9if newState.options.config.acrylicBlur then\
\9\9\9enableAcrylic()\
\9\9else\
\9\9\9disableAcrylic()\
\9\9end\
\9end)\
end)\
main():catch(function(err)\
\9warn(\"[acrylic-worker] \" .. tostring(err))\
end)\
", '@'.."Orca.jobs.acrylic")) setfenv(fn, newEnv("Orca.jobs.acrylic")) return fn() end)

newInstance("character", "Folder", "Orca.jobs.character", "Orca.jobs")

newModule("flight", "LocalScript", "Orca.jobs.character.flight", "Orca.jobs.character", function () local fn = assert(loadstring("-- Compiled with roblox-ts v1.2.7\
local TS = require(script.Parent.Parent.Parent.include.RuntimeLib)\
local _flipper = TS.import(script, TS.getModule(script, \"@rbxts\", \"flipper\").src)\
local GroupMotor = _flipper.GroupMotor\
local Spring = _flipper.Spring\
local _services = TS.import(script, TS.getModule(script, \"@rbxts\", \"services\"))\
local Players = _services.Players\
local RunService = _services.RunService\
local UserInputService = _services.UserInputService\
local Workspace = _services.Workspace\
local onJobChange = TS.import(script, script.Parent.Parent, \"helpers\", \"job-store\").onJobChange\
local player = Players.LocalPlayer\
local moveDirection = {\
\9forward = Vector3.new(),\
\9backward = Vector3.new(),\
\9left = Vector3.new(),\
\9right = Vector3.new(),\
\9up = Vector3.new(),\
\9down = Vector3.new(),\
}\
local enabled = false\
local speed = 16\
local humanoidRoot\
local coordinate\
local coordinateSpring = GroupMotor.new({ 0, 0, 0 }, false)\
local resetCoordinate, resetSpring, updateDirection, updateCoordinate\
local main = TS.async(function()\
\9TS.await(onJobChange(\"flight\", function(job)\
\9\9enabled = job.active\
\9\9speed = job.value\
\9\9if enabled then\
\9\9\9resetCoordinate()\
\9\9\9resetSpring()\
\9\9end\
\9end))\
\9UserInputService.InputBegan:Connect(function(input, gameProcessed)\
\9\9if gameProcessed then\
\9\9\9return nil\
\9\9end\
\9\9updateDirection(input.KeyCode, true)\
\9end)\
\9UserInputService.InputEnded:Connect(function(input)\
\9\9updateDirection(input.KeyCode, false)\
\9end)\
\9RunService.Heartbeat:Connect(function(deltaTime)\
\9\9if enabled and (humanoidRoot and coordinate) then\
\9\9\9updateCoordinate(deltaTime)\
\9\9\9coordinateSpring:setGoal({ Spring.new(coordinate.X), Spring.new(coordinate.Y), Spring.new(coordinate.Z) })\
\9\9\9coordinateSpring:step(deltaTime)\
\9\9\9local _binding = coordinateSpring:getValue()\
\9\9\9local x = _binding[1]\
\9\9\9local y = _binding[2]\
\9\9\9local z = _binding[3]\
\9\9\9humanoidRoot.AssemblyLinearVelocity = Vector3.new()\
\9\9\9local _rotation = Workspace.CurrentCamera.CFrame.Rotation\
\9\9\9local _vector3 = Vector3.new(x, y, z)\
\9\9\9humanoidRoot.CFrame = _rotation + _vector3\
\9\9end\
\9end)\
\9RunService.RenderStepped:Connect(function()\
\9\9if enabled and (humanoidRoot and coordinate) then\
\9\9\9local _rotation = Workspace.CurrentCamera.CFrame.Rotation\
\9\9\9local _position = humanoidRoot.CFrame.Position\
\9\9\9humanoidRoot.CFrame = _rotation + _position\
\9\9end\
\9end)\
\9player.CharacterAdded:Connect(function(character)\
\9\9local newHumanoidRoot = character:WaitForChild(\"HumanoidRootPart\", 5)\
\9\9if newHumanoidRoot and newHumanoidRoot:IsA(\"BasePart\") then\
\9\9\9humanoidRoot = newHumanoidRoot\
\9\9end\
\9\9resetCoordinate()\
\9\9resetSpring()\
\9end)\
\9local _currentHumanoidRoot = player.Character\
\9if _currentHumanoidRoot ~= nil then\
\9\9_currentHumanoidRoot = _currentHumanoidRoot:FindFirstChild(\"HumanoidRootPart\")\
\9end\
\9local currentHumanoidRoot = _currentHumanoidRoot\
\9if currentHumanoidRoot and currentHumanoidRoot:IsA(\"BasePart\") then\
\9\9humanoidRoot = currentHumanoidRoot\
\9\9resetCoordinate()\
\9end\
end)\
local function getUnitDirection()\
\9local sum = Vector3.new()\
\9for _, v3 in pairs(moveDirection) do\
\9\9sum = sum + v3\
\9end\
\9return sum.Magnitude > 0 and sum.Unit or sum\
end\
function resetCoordinate()\
\9if not humanoidRoot then\
\9\9return nil\
\9end\
\9local _binding = Workspace.CurrentCamera.CFrame\
\9local XVector = _binding.XVector\
\9local YVector = _binding.YVector\
\9local ZVector = _binding.ZVector\
\9coordinate = CFrame.fromMatrix(humanoidRoot.Position, XVector, YVector, ZVector)\
end\
function resetSpring()\
\9if not coordinate then\
\9\9return nil\
\9end\
\9coordinateSpring = GroupMotor.new({ coordinate.X, coordinate.Y, coordinate.Z }, false)\
end\
function updateCoordinate(deltaTime)\
\9if not coordinate then\
\9\9return nil\
\9end\
\9local _binding = Workspace.CurrentCamera.CFrame\
\9local XVector = _binding.XVector\
\9local YVector = _binding.YVector\
\9local ZVector = _binding.ZVector\
\9local direction = getUnitDirection()\
\9if direction.Magnitude > 0 then\
\9\9local _arg0 = speed * deltaTime\
\9\9local _binding_1 = direction * _arg0\
\9\9local X = _binding_1.X\
\9\9local Y = _binding_1.Y\
\9\9local Z = _binding_1.Z\
\9\9local _exp = CFrame.fromMatrix(coordinate.Position, XVector, YVector, ZVector)\
\9\9local _cFrame = CFrame.new(X, Y, Z)\
\9\9coordinate = _exp * _cFrame\
\9else\
\9\9coordinate = CFrame.fromMatrix(coordinate.Position, XVector, YVector, ZVector)\
\9end\
end\
function updateDirection(code, begin)\
\9repeat\
\9\9if code == (Enum.KeyCode.W) then\
\9\9\9moveDirection.forward = begin and Vector3.new(0, 0, -1) or Vector3.new()\
\9\9\9break\
\9\9end\
\9\9if code == (Enum.KeyCode.S) then\
\9\9\9moveDirection.backward = begin and Vector3.new(0, 0, 1) or Vector3.new()\
\9\9\9break\
\9\9end\
\9\9if code == (Enum.KeyCode.A) then\
\9\9\9moveDirection.left = begin and Vector3.new(-1, 0, 0) or Vector3.new()\
\9\9\9break\
\9\9end\
\9\9if code == (Enum.KeyCode.D) then\
\9\9\9moveDirection.right = begin and Vector3.new(1, 0, 0) or Vector3.new()\
\9\9\9break\
\9\9end\
\9\9if code == (Enum.KeyCode.Q) then\
\9\9\9moveDirection.up = begin and Vector3.new(0, -1, 0) or Vector3.new()\
\9\9\9break\
\9\9end\
\9\9if code == (Enum.KeyCode.E) then\
\9\9\9moveDirection.down = begin and Vector3.new(0, 1, 0) or Vector3.new()\
\9\9\9break\
\9\9end\
\9until true\
end\
main():catch(function(err)\
\9warn(\"[flight-worker] \" .. tostring(err))\
end)\
", '@'.."Orca.jobs.character.flight")) setfenv(fn, newEnv("Orca.jobs.character.flight")) return fn() end)

newModule("ghost", "LocalScript", "Orca.jobs.character.ghost", "Orca.jobs.character", function () local fn = assert(loadstring("-- Compiled with roblox-ts v1.2.7\
local TS = require(script.Parent.Parent.Parent.include.RuntimeLib)\
local _services = TS.import(script, TS.getModule(script, \"@rbxts\", \"services\"))\
local Players = _services.Players\
local Workspace = _services.Workspace\
local _job_store = TS.import(script, script.Parent.Parent, \"helpers\", \"job-store\")\
local getStore = _job_store.getStore\
local onJobChange = _job_store.onJobChange\
local player = Players.LocalPlayer\
local originalCharacter\
local ghostCharacter\
local lastPosition\
local deactivate, activateGhost, deactivateOnCharacterAdded, deactivateGhost\
local main = TS.async(function()\
\9TS.await(onJobChange(\"ghost\", function(job, state)\
\9\9if state.jobs.refresh.active and job.active then\
\9\9\9deactivate()\
\9\9elseif job.active then\
\9\9\9activateGhost():andThen(deactivateOnCharacterAdded):catch(function(err)\
\9\9\9\9warn(\"[ghost-worker-active] \" .. tostring(err))\
\9\9\9\9deactivate()\
\9\9\9end)\
\9\9elseif not state.jobs.refresh.active then\
\9\9\9deactivateGhost():catch(function(err)\
\9\9\9\9warn(\"[ghost-worker-inactive] \" .. tostring(err))\
\9\9\9end)\
\9\9end\
\9end))\
end)\
deactivate = TS.async(function()\
\9local store = TS.await(getStore())\
\9store:dispatch({\
\9\9type = \"jobs/setJobActive\",\
\9\9jobName = \"ghost\",\
\9\9active = false,\
\9})\
end)\
deactivateOnCharacterAdded = TS.async(function()\
\9TS.await(TS.Promise.fromEvent(player.CharacterAdded, function(character)\
\9\9return character ~= originalCharacter and character ~= ghostCharacter\
\9end))\
\9TS.await(deactivate())\
end)\
activateGhost = TS.async(function()\
\9local character = player.Character\
\9local _humanoid = character\
\9if _humanoid ~= nil then\
\9\9_humanoid = _humanoid:FindFirstChildWhichIsA(\"Humanoid\")\
\9end\
\9local humanoid = _humanoid\
\9if not character or not humanoid then\
\9\9error(\"Character or Humanoid is null\")\
\9end\
\9character.Archivable = true\
\9ghostCharacter = character:Clone()\
\9character.Archivable = false\
\9local rootPart = character:FindFirstChild(\"HumanoidRootPart\")\
\9local _result = rootPart\
\9if _result ~= nil then\
\9\9_result = _result:IsA(\"BasePart\")\
\9end\
\9lastPosition = _result and rootPart.CFrame or nil\
\9originalCharacter = character\
\9local ghostHumanoid = ghostCharacter:FindFirstChildWhichIsA(\"Humanoid\")\
\9for _, child in ipairs(ghostCharacter:GetDescendants()) do\
\9\9if child:IsA(\"BasePart\") then\
\9\9\9child.Transparency = 1 - (1 - child.Transparency) * 0.5\
\9\9end\
\9end\
\9if ghostHumanoid then\
\9\9ghostHumanoid.DisplayName = utf8.char(128123)\
\9end\
\9local _result_1 = ghostCharacter:FindFirstChild(\"Animate\")\
\9if _result_1 ~= nil then\
\9\9_result_1:Destroy()\
\9end\
\9local animation = originalCharacter:FindFirstChild(\"Animate\")\
\9if animation then\
\9\9animation.Disabled = true\
\9\9animation.Parent = ghostCharacter\
\9end\
\9ghostCharacter.Parent = character.Parent\
\9player.Character = ghostCharacter\
\9Workspace.CurrentCamera.CameraSubject = ghostHumanoid\
\9if animation then\
\9\9animation.Disabled = false\
\9end\
\9local handle\
\9handle = humanoid.Died:Connect(function()\
\9\9handle:Disconnect()\
\9\9deactivate()\
\9end)\
end)\
deactivateGhost = TS.async(function()\
\9if not originalCharacter or not ghostCharacter then\
\9\9return nil\
\9end\
\9local rootPart = originalCharacter:FindFirstChild(\"HumanoidRootPart\")\
\9local ghostRootPart = ghostCharacter:FindFirstChild(\"HumanoidRootPart\")\
\9local _result = ghostRootPart\
\9if _result ~= nil then\
\9\9_result = _result:IsA(\"BasePart\")\
\9end\
\9local currentPosition = _result and ghostRootPart.CFrame or nil\
\9local animation = ghostCharacter:FindFirstChild(\"Animate\")\
\9if animation then\
\9\9animation.Disabled = true\
\9\9animation.Parent = nil\
\9end\
\9ghostCharacter:Destroy()\
\9local humanoid = originalCharacter:FindFirstChildWhichIsA(\"Humanoid\")\
\9local _result_1 = humanoid\
\9if _result_1 ~= nil then\
\9\9local _exp = _result_1:GetPlayingAnimationTracks()\
\9\9local _arg0 = function(track)\
\9\9\9return track:Stop()\
\9\9end\
\9\9-- ▼ ReadonlyArray.forEach ▼\
\9\9for _k, _v in ipairs(_exp) do\
\9\9\9_arg0(_v, _k - 1, _exp)\
\9\9end\
\9\9-- ▲ ReadonlyArray.forEach ▲\
\9end\
\9local position = currentPosition or lastPosition\
\9local _result_2 = rootPart\
\9if _result_2 ~= nil then\
\9\9_result_2 = _result_2:IsA(\"BasePart\")\
\9end\
\9local _condition = _result_2\
\9if _condition then\
\9\9_condition = position\
\9end\
\9if _condition then\
\9\9rootPart.CFrame = position\
\9end\
\9player.Character = originalCharacter\
\9Workspace.CurrentCamera.CameraSubject = humanoid\
\9if animation then\
\9\9animation.Parent = originalCharacter\
\9\9animation.Disabled = false\
\9end\
\9originalCharacter = nil\
\9ghostCharacter = nil\
\9lastPosition = nil\
end)\
main():catch(function(err)\
\9warn(\"[ghost-worker] \" .. tostring(err))\
end)\
", '@'.."Orca.jobs.character.ghost")) setfenv(fn, newEnv("Orca.jobs.character.ghost")) return fn() end)

newModule("godmode", "LocalScript", "Orca.jobs.character.godmode", "Orca.jobs.character", function () local fn = assert(loadstring("-- Compiled with roblox-ts v1.2.7\
local TS = require(script.Parent.Parent.Parent.include.RuntimeLib)\
local _services = TS.import(script, TS.getModule(script, \"@rbxts\", \"services\"))\
local Players = _services.Players\
local Workspace = _services.Workspace\
local _job_store = TS.import(script, script.Parent.Parent, \"helpers\", \"job-store\")\
local getStore = _job_store.getStore\
local onJobChange = _job_store.onJobChange\
local player = Players.LocalPlayer\
local currentCharacter\
local deactivate, activateGodmode, deactivateOnCharacterAdded\
local main = TS.async(function()\
\9local function errorHandler(err)\
\9\9warn(\"[godmode-worker] \" .. tostring(err))\
\9\9deactivate()\
\9end\
\9TS.await(onJobChange(\"godmode\", function(job, state)\
\9\9if state.jobs.ghost.active and job.active then\
\9\9\9deactivate()\
\9\9elseif job.active then\
\9\9\9activateGodmode():andThen(deactivateOnCharacterAdded):catch(errorHandler)\
\9\9end\
\9end))\
end)\
deactivate = TS.async(function()\
\9local store = TS.await(getStore())\
\9store:dispatch({\
\9\9type = \"jobs/setJobActive\",\
\9\9jobName = \"godmode\",\
\9\9active = false,\
\9})\
end)\
deactivateOnCharacterAdded = TS.async(function()\
\9local store = TS.await(getStore())\
\9TS.await(TS.Promise.fromEvent(player.CharacterAdded, function(character)\
\9\9local jobs = store:getState().jobs\
\9\9return not jobs.ghost.active and character ~= currentCharacter\
\9end))\
\9TS.await(deactivate())\
end)\
activateGodmode = TS.async(function()\
\9local cameraCFrame = Workspace.CurrentCamera.CFrame\
\9local character = player.Character\
\9if not character then\
\9\9error(\"Character is null\")\
\9end\
\9local humanoid = character:FindFirstChildWhichIsA(\"Humanoid\")\
\9if not humanoid then\
\9\9error(\"No humanoid found\")\
\9end\
\9local mockHumanoid = humanoid:Clone()\
\9mockHumanoid.Parent = character\
\9currentCharacter = character\
\9player.Character = nil\
\9mockHumanoid:SetStateEnabled(Enum.HumanoidStateType.Dead, false)\
\9mockHumanoid:SetStateEnabled(Enum.HumanoidStateType.Ragdoll, false)\
\9mockHumanoid:SetStateEnabled(Enum.HumanoidStateType.FallingDown, false)\
\9mockHumanoid.BreakJointsOnDeath = true\
\9mockHumanoid.DisplayDistanceType = Enum.HumanoidDisplayDistanceType.None\
\9humanoid:Destroy()\
\9player.Character = character\
\9Workspace.CurrentCamera.CameraSubject = mockHumanoid\
\9task.defer(function()\
\9\9Workspace.CurrentCamera.CFrame = cameraCFrame\
\9end)\
\9local animation = character:FindFirstChild(\"Animate\")\
\9if animation then\
\9\9animation.Disabled = true\
\9\9animation.Disabled = false\
\9end\
\9mockHumanoid.MaxHealth = math.huge\
\9mockHumanoid.Health = mockHumanoid.MaxHealth\
end)\
main():catch(function(err)\
\9warn(\"[godmode-worker] \" .. tostring(err))\
end)\
", '@'.."Orca.jobs.character.godmode")) setfenv(fn, newEnv("Orca.jobs.character.godmode")) return fn() end)

newModule("humanoid", "LocalScript", "Orca.jobs.character.humanoid", "Orca.jobs.character", function () local fn = assert(loadstring("-- Compiled with roblox-ts v1.2.7\
local TS = require(script.Parent.Parent.Parent.include.RuntimeLib)\
local Players = TS.import(script, TS.getModule(script, \"@rbxts\", \"services\")).Players\
local _job_store = TS.import(script, script.Parent.Parent, \"helpers\", \"job-store\")\
local getStore = _job_store.getStore\
local onJobChange = _job_store.onJobChange\
local JUMP_POWER_CONSTANT = 349.24\
local player = Players.LocalPlayer\
local defaults = {\
\9walkSpeed = 16,\
\9jumpHeight = 7.2,\
}\
local setDefaultWalkSpeed, updateWalkSpeed, setDefaultJumpHeight, updateJumpHeight\
local main = TS.async(function()\
\9local store = TS.await(getStore())\
\9local _humanoid = player.Character\
\9if _humanoid ~= nil then\
\9\9_humanoid = _humanoid:FindFirstChildWhichIsA(\"Humanoid\")\
\9end\
\9local humanoid = _humanoid\
\9local state = store:getState()\
\9local walkSpeedJob = state.jobs.walkSpeed\
\9local jumpHeightJob = state.jobs.jumpHeight\
\9TS.await(onJobChange(\"walkSpeed\", function(job)\
\9\9if job.active and not walkSpeedJob.active then\
\9\9\9setDefaultWalkSpeed(humanoid)\
\9\9end\
\9\9walkSpeedJob = job\
\9\9updateWalkSpeed(humanoid, walkSpeedJob)\
\9end))\
\9TS.await(onJobChange(\"jumpHeight\", function(job)\
\9\9if job.active and not jumpHeightJob.active then\
\9\9\9setDefaultJumpHeight(humanoid)\
\9\9end\
\9\9jumpHeightJob = job\
\9\9updateJumpHeight(humanoid, jumpHeightJob)\
\9end))\
\9player.CharacterAdded:Connect(function(character)\
\9\9local newHumanoid = character:WaitForChild(\"Humanoid\", 5)\
\9\9if newHumanoid and newHumanoid:IsA(\"Humanoid\") then\
\9\9\9humanoid = newHumanoid\
\9\9\9setDefaultWalkSpeed(newHumanoid)\
\9\9\9updateWalkSpeed(newHumanoid, walkSpeedJob)\
\9\9\9setDefaultJumpHeight(newHumanoid)\
\9\9\9updateJumpHeight(newHumanoid, jumpHeightJob)\
\9\9end\
\9end)\
\9setDefaultWalkSpeed(humanoid)\
\9setDefaultJumpHeight(humanoid)\
end)\
function setDefaultWalkSpeed(humanoid)\
\9if humanoid then\
\9\9defaults.walkSpeed = humanoid.WalkSpeed\
\9end\
end\
function setDefaultJumpHeight(humanoid)\
\9if humanoid then\
\9\9defaults.jumpHeight = humanoid.JumpHeight\
\9end\
end\
function updateWalkSpeed(humanoid, walkSpeedJob)\
\9if not humanoid then\
\9\9return nil\
\9end\
\9if walkSpeedJob.active then\
\9\9humanoid.WalkSpeed = walkSpeedJob.value\
\9else\
\9\9humanoid.WalkSpeed = defaults.walkSpeed\
\9end\
end\
function updateJumpHeight(humanoid, jumpHeightJob)\
\9if not humanoid then\
\9\9return nil\
\9end\
\9if jumpHeightJob.active then\
\9\9humanoid.JumpHeight = jumpHeightJob.value\
\9\9if humanoid.UseJumpPower then\
\9\9\9humanoid.JumpPower = math.sqrt(JUMP_POWER_CONSTANT * jumpHeightJob.value)\
\9\9end\
\9else\
\9\9humanoid.JumpHeight = defaults.jumpHeight\
\9\9if humanoid.UseJumpPower then\
\9\9\9humanoid.JumpPower = math.sqrt(JUMP_POWER_CONSTANT * defaults.jumpHeight)\
\9\9end\
\9end\
end\
main():catch(function(err)\
\9warn(\"[humanoid-worker] \" .. tostring(err))\
end)\
", '@'.."Orca.jobs.character.humanoid")) setfenv(fn, newEnv("Orca.jobs.character.humanoid")) return fn() end)

newModule("refresh", "LocalScript", "Orca.jobs.character.refresh", "Orca.jobs.character", function () local fn = assert(loadstring("-- Compiled with roblox-ts v1.2.7\
local TS = require(script.Parent.Parent.Parent.include.RuntimeLib)\
local _services = TS.import(script, TS.getModule(script, \"@rbxts\", \"services\"))\
local Players = _services.Players\
local Workspace = _services.Workspace\
local _job_store = TS.import(script, script.Parent.Parent, \"helpers\", \"job-store\")\
local getStore = _job_store.getStore\
local onJobChange = _job_store.onJobChange\
local MAX_RESPAWN_TIME = 10\
local player = Players.LocalPlayer\
local respawn\
local main = TS.async(function()\
\9local store = TS.await(getStore())\
\9local function deactivate()\
\9\9store:dispatch({\
\9\9\9type = \"jobs/setJobActive\",\
\9\9\9jobName = \"refresh\",\
\9\9\9active = false,\
\9\9})\
\9end\
\9TS.await(onJobChange(\"refresh\", function(job, state)\
\9\9if state.jobs.ghost.active and job.active then\
\9\9\9deactivate()\
\9\9elseif job.active then\
\9\9\9respawn():catch(function(err)\
\9\9\9\9return warn(\"[refresh-worker-respawn] \" .. tostring(err))\
\9\9\9end):finally(function()\
\9\9\9\9return deactivate()\
\9\9\9end)\
\9\9end\
\9end))\
end)\
respawn = TS.async(function()\
\9local character = player.Character\
\9if not character then\
\9\9error(\"Character is null\")\
\9end\
\9local _respawnLocation = (character:FindFirstChild(\"HumanoidRootPart\"))\
\9if _respawnLocation ~= nil then\
\9\9_respawnLocation = _respawnLocation.CFrame\
\9end\
\9local respawnLocation = _respawnLocation\
\9local humanoid = character:FindFirstAncestorWhichIsA(\"Humanoid\")\
\9local _result = humanoid\
\9if _result ~= nil then\
\9\9_result:ChangeState(Enum.HumanoidStateType.Dead)\
\9end\
\9character:ClearAllChildren()\
\9local mockCharacter = Instance.new(\"Model\", Workspace)\
\9player.Character = mockCharacter\
\9player.Character = character\
\9mockCharacter:Destroy()\
\9if not respawnLocation then\
\9\9return nil\
\9end\
\9local newCharacter = TS.await(TS.Promise.fromEvent(player.CharacterAdded):timeout(MAX_RESPAWN_TIME, \"CharacterAdded event timed out\"))\
\9local humanoidRoot = newCharacter:WaitForChild(\"HumanoidRootPart\", 5)\
\9if humanoidRoot and (humanoidRoot:IsA(\"BasePart\") and respawnLocation) then\
\9\9task.delay(0.1, function()\
\9\9\9humanoidRoot.CFrame = respawnLocation\
\9\9end)\
\9end\
end)\
main():catch(function(err)\
\9warn(\"[refresh-worker] \" .. tostring(err))\
end)\
", '@'.."Orca.jobs.character.refresh")) setfenv(fn, newEnv("Orca.jobs.character.refresh")) return fn() end)

newModule("freecam", "LocalScript", "Orca.jobs.freecam", "Orca.jobs", function () local fn = assert(loadstring("-- Compiled with roblox-ts v1.2.7\
local TS = require(script.Parent.Parent.include.RuntimeLib)\
local _freecam = TS.import(script, script.Parent, \"helpers\", \"freecam\")\
local DisableFreecam = _freecam.DisableFreecam\
local EnableFreecam = _freecam.EnableFreecam\
local onJobChange = TS.import(script, script.Parent, \"helpers\", \"job-store\").onJobChange\
local main = TS.async(function()\
\9TS.await(onJobChange(\"freecam\", function(job)\
\9\9if job.active then\
\9\9\9EnableFreecam()\
\9\9else\
\9\9\9DisableFreecam()\
\9\9end\
\9end))\
end)\
main():catch(function(err)\
\9warn(\"[freecam-worker] \" .. tostring(err))\
end)\
", '@'.."Orca.jobs.freecam")) setfenv(fn, newEnv("Orca.jobs.freecam")) return fn() end)

newInstance("helpers", "Folder", "Orca.jobs.helpers", "Orca.jobs")

newModule("freecam", "ModuleScript", "Orca.jobs.helpers.freecam", "Orca.jobs.helpers", function () local fn = assert(loadstring("------------------------------------------------------------------------\
-- Freecam\
-- Cinematic free camera for spectating and video production.\
------------------------------------------------------------------------\
\
local pi    = math.pi\
local abs   = math.abs\
local clamp = math.clamp\
local exp   = math.exp\
local rad   = math.rad\
local sign  = math.sign\
local sqrt  = math.sqrt\
local tan   = math.tan\
\
local ContextActionService = game:GetService(\"ContextActionService\")\
local Players = game:GetService(\"Players\")\
local RunService = game:GetService(\"RunService\")\
local StarterGui = game:GetService(\"StarterGui\")\
local UserInputService = game:GetService(\"UserInputService\")\
local Workspace = game:GetService(\"Workspace\")\
\
local LocalPlayer = Players.LocalPlayer\
if not LocalPlayer then\
\9Players:GetPropertyChangedSignal(\"LocalPlayer\"):Wait()\
\9LocalPlayer = Players.LocalPlayer\
end\
\
local Camera = Workspace.CurrentCamera\
Workspace:GetPropertyChangedSignal(\"CurrentCamera\"):Connect(function()\
\9local newCamera = Workspace.CurrentCamera\
\9if newCamera then\
\9\9Camera = newCamera\
\9end\
end)\
\
------------------------------------------------------------------------\
\
local TOGGLE_INPUT_PRIORITY = Enum.ContextActionPriority.Low.Value\
local INPUT_PRIORITY = Enum.ContextActionPriority.High.Value\
local FREECAM_MACRO_KB = {Enum.KeyCode.LeftShift, Enum.KeyCode.P}\
\
local FREECAM_RENDER_ID = game:GetService(\"HttpService\"):GenerateGUID(false)\
\
local NAV_GAIN = Vector3.new(1, 1, 1)*64\
local PAN_GAIN = Vector2.new(0.75, 1)*8\
local FOV_GAIN = 300\
\
local PITCH_LIMIT = rad(90)\
\
local VEL_STIFFNESS = 2.0\
local PAN_STIFFNESS = 3.0\
local FOV_STIFFNESS = 4.0\
\
------------------------------------------------------------------------\
\
local Spring = {} do\
\9Spring.__index = Spring\
\
\9function Spring.new(freq, pos)\
\9\9local self = setmetatable({}, Spring)\
\9\9self.f = freq\
\9\9self.p = pos\
\9\9self.v = pos*0\
\9\9return self\
\9end\
\
\9function Spring:Update(dt, goal)\
\9\9local f = self.f*2*pi\
\9\9local p0 = self.p\
\9\9local v0 = self.v\
\
\9\9local offset = goal - p0\
\9\9local decay = exp(-f*dt)\
\
\9\9local p1 = goal + (v0*dt - offset*(f*dt + 1))*decay\
\9\9local v1 = (f*dt*(offset*f - v0) + v0)*decay\
\
\9\9self.p = p1\
\9\9self.v = v1\
\
\9\9return p1\
\9end\
\
\9function Spring:Reset(pos)\
\9\9self.p = pos\
\9\9self.v = pos*0\
\9end\
end\
\
------------------------------------------------------------------------\
\
local cameraPos = Vector3.new()\
local cameraRot = Vector2.new()\
local cameraFov = 0\
\
local velSpring = Spring.new(VEL_STIFFNESS, Vector3.new())\
local panSpring = Spring.new(PAN_STIFFNESS, Vector2.new())\
local fovSpring = Spring.new(FOV_STIFFNESS, 0)\
\
------------------------------------------------------------------------\
\
local Input = {} do\
\9local thumbstickCurve do\
\9\9local K_CURVATURE = 2.0\
\9\9local K_DEADZONE = 0.15\
\
\9\9local function fCurve(x)\
\9\9\9return (exp(K_CURVATURE*x) - 1)/(exp(K_CURVATURE) - 1)\
\9\9end\
\
\9\9local function fDeadzone(x)\
\9\9\9return fCurve((x - K_DEADZONE)/(1 - K_DEADZONE))\
\9\9end\
\
\9\9function thumbstickCurve(x)\
\9\9\9return sign(x)*clamp(fDeadzone(abs(x)), 0, 1)\
\9\9end\
\9end\
\
\9local gamepad = {\
\9\9ButtonX = 0,\
\9\9ButtonY = 0,\
\9\9DPadDown = 0,\
\9\9DPadUp = 0,\
\9\9ButtonL2 = 0,\
\9\9ButtonR2 = 0,\
\9\9Thumbstick1 = Vector2.new(),\
\9\9Thumbstick2 = Vector2.new(),\
\9}\
\
\9local keyboard = {\
\9\9W = 0,\
\9\9A = 0,\
\9\9S = 0,\
\9\9D = 0,\
\9\9E = 0,\
\9\9Q = 0,\
\9\9U = 0,\
\9\9H = 0,\
\9\9J = 0,\
\9\9K = 0,\
\9\9I = 0,\
\9\9Y = 0,\
\9\9Up = 0,\
\9\9Down = 0,\
\9\9LeftShift = 0,\
\9\9RightShift = 0,\
\9}\
\
\9local mouse = {\
\9\9Delta = Vector2.new(),\
\9\9MouseWheel = 0,\
\9}\
\
\9local NAV_GAMEPAD_SPEED  = Vector3.new(1, 1, 1)\
\9local NAV_KEYBOARD_SPEED = Vector3.new(1, 1, 1)\
\9local PAN_MOUSE_SPEED    = Vector2.new(1, 1)*(pi/64)\
\9local PAN_GAMEPAD_SPEED  = Vector2.new(1, 1)*(pi/8)\
\9local FOV_WHEEL_SPEED    = 1.0\
\9local FOV_GAMEPAD_SPEED  = 0.25\
\9local NAV_ADJ_SPEED      = 0.75\
\9local NAV_SHIFT_MUL      = 0.25\
\
\9local navSpeed = 1\
\
\9function Input.Vel(dt)\
\9\9navSpeed = clamp(navSpeed + dt*(keyboard.Up - keyboard.Down)*NAV_ADJ_SPEED, 0.01, 4)\
\
\9\9local kGamepad = Vector3.new(\
\9\9\9thumbstickCurve(gamepad.Thumbstick1.X),\
\9\9\9thumbstickCurve(gamepad.ButtonR2) - thumbstickCurve(gamepad.ButtonL2),\
\9\9\9thumbstickCurve(-gamepad.Thumbstick1.Y)\
\9\9)*NAV_GAMEPAD_SPEED\
\
\9\9local kKeyboard = Vector3.new(\
\9\9\9keyboard.D - keyboard.A + keyboard.K - keyboard.H,\
\9\9\9keyboard.E - keyboard.Q + keyboard.I - keyboard.Y,\
\9\9\9keyboard.S - keyboard.W + keyboard.J - keyboard.U\
\9\9)*NAV_KEYBOARD_SPEED\
\
\9\9local shift = UserInputService:IsKeyDown(Enum.KeyCode.LeftShift) or UserInputService:IsKeyDown(Enum.KeyCode.RightShift)\
\
\9\9return (kGamepad + kKeyboard)*(navSpeed*(shift and NAV_SHIFT_MUL or 1))\
\9end\
\
\9function Input.Pan(dt)\
\9\9local kGamepad = Vector2.new(\
\9\9\9thumbstickCurve(gamepad.Thumbstick2.Y),\
\9\9\9thumbstickCurve(-gamepad.Thumbstick2.X)\
\9\9)*PAN_GAMEPAD_SPEED\
\9\9local kMouse = mouse.Delta*PAN_MOUSE_SPEED/(dt*60)\
\9\9mouse.Delta = Vector2.new()\
\9\9return kGamepad + kMouse\
\9end\
\
\9function Input.Fov(dt)\
\9\9local kGamepad = (gamepad.ButtonX - gamepad.ButtonY)*FOV_GAMEPAD_SPEED\
\9\9local kMouse = mouse.MouseWheel*FOV_WHEEL_SPEED\
\9\9mouse.MouseWheel = 0\
\9\9return kGamepad + kMouse\
\9end\
\
\9do\
\9\9local function Keypress(action, state, input)\
\9\9\9keyboard[input.KeyCode.Name] = state == Enum.UserInputState.Begin and 1 or 0\
\9\9\9return Enum.ContextActionResult.Sink\
\9\9end\
\
\9\9local function GpButton(action, state, input)\
\9\9\9gamepad[input.KeyCode.Name] = state == Enum.UserInputState.Begin and 1 or 0\
\9\9\9return Enum.ContextActionResult.Sink\
\9\9end\
\
\9\9local function MousePan(action, state, input)\
\9\9\9local delta = input.Delta\
\9\9\9mouse.Delta = Vector2.new(-delta.y, -delta.x)\
\9\9\9return Enum.ContextActionResult.Sink\
\9\9end\
\
\9\9local function Thumb(action, state, input)\
\9\9\9gamepad[input.KeyCode.Name] = input.Position\
\9\9\9return Enum.ContextActionResult.Sink\
\9\9end\
\
\9\9local function Trigger(action, state, input)\
\9\9\9gamepad[input.KeyCode.Name] = input.Position.z\
\9\9\9return Enum.ContextActionResult.Sink\
\9\9end\
\
\9\9local function MouseWheel(action, state, input)\
\9\9\9mouse[input.UserInputType.Name] = -input.Position.z\
\9\9\9return Enum.ContextActionResult.Sink\
\9\9end\
\
\9\9local function Zero(t)\
\9\9\9for k, v in pairs(t) do\
\9\9\9\9t[k] = v*0\
\9\9\9end\
\9\9end\
\
\9\9function Input.StartCapture()\
\9\9\9ContextActionService:BindActionAtPriority(FREECAM_RENDER_ID .. \"FreecamKeyboard\", Keypress, false, INPUT_PRIORITY,\
\9\9\9\9Enum.KeyCode.W, -- Enum.KeyCode.U,\
\9\9\9\9Enum.KeyCode.A, -- Enum.KeyCode.H,\
\9\9\9\9Enum.KeyCode.S, -- Enum.KeyCode.J,\
\9\9\9\9Enum.KeyCode.D, -- Enum.KeyCode.K,\
\9\9\9\9Enum.KeyCode.E, -- Enum.KeyCode.I,\
\9\9\9\9Enum.KeyCode.Q, -- Enum.KeyCode.Y,\
\9\9\9\9Enum.KeyCode.Up, Enum.KeyCode.Down\
\9\9\9)\
\9\9\9ContextActionService:BindActionAtPriority(FREECAM_RENDER_ID .. \"FreecamMousePan\",          MousePan,   false, INPUT_PRIORITY, Enum.UserInputType.MouseMovement)\
\9\9\9ContextActionService:BindActionAtPriority(FREECAM_RENDER_ID .. \"FreecamMouseWheel\",        MouseWheel, false, INPUT_PRIORITY, Enum.UserInputType.MouseWheel)\
\9\9\9ContextActionService:BindActionAtPriority(FREECAM_RENDER_ID .. \"FreecamGamepadButton\",     GpButton,   false, INPUT_PRIORITY, Enum.KeyCode.ButtonX, Enum.KeyCode.ButtonY)\
\9\9\9ContextActionService:BindActionAtPriority(FREECAM_RENDER_ID .. \"FreecamGamepadTrigger\",    Trigger,    false, INPUT_PRIORITY, Enum.KeyCode.ButtonR2, Enum.KeyCode.ButtonL2)\
\9\9\9ContextActionService:BindActionAtPriority(FREECAM_RENDER_ID .. \"FreecamGamepadThumbstick\", Thumb,      false, INPUT_PRIORITY, Enum.KeyCode.Thumbstick1, Enum.KeyCode.Thumbstick2)\
\9\9end\
\
\9\9function Input.StopCapture()\
\9\9\9navSpeed = 1\
\9\9\9Zero(gamepad)\
\9\9\9Zero(keyboard)\
\9\9\9Zero(mouse)\
\9\9\9ContextActionService:UnbindAction(FREECAM_RENDER_ID .. \"FreecamKeyboard\")\
\9\9\9ContextActionService:UnbindAction(FREECAM_RENDER_ID .. \"FreecamMousePan\")\
\9\9\9ContextActionService:UnbindAction(FREECAM_RENDER_ID .. \"FreecamMouseWheel\")\
\9\9\9ContextActionService:UnbindAction(FREECAM_RENDER_ID .. \"FreecamGamepadButton\")\
\9\9\9ContextActionService:UnbindAction(FREECAM_RENDER_ID .. \"FreecamGamepadTrigger\")\
\9\9\9ContextActionService:UnbindAction(FREECAM_RENDER_ID .. \"FreecamGamepadThumbstick\")\
\9\9end\
\9end\
end\
\
local function GetFocusDistance(cameraFrame)\
\9local znear = 0.1\
\9local viewport = Camera.ViewportSize\
\9local projy = 2*tan(cameraFov/2)\
\9local projx = viewport.x/viewport.y*projy\
\9local fx = cameraFrame.rightVector\
\9local fy = cameraFrame.upVector\
\9local fz = cameraFrame.lookVector\
\
\9local minVect = Vector3.new()\
\9local minDist = 512\
\
\9for x = 0, 1, 0.5 do\
\9\9for y = 0, 1, 0.5 do\
\9\9\9local cx = (x - 0.5)*projx\
\9\9\9local cy = (y - 0.5)*projy\
\9\9\9local offset = fx*cx - fy*cy + fz\
\9\9\9local origin = cameraFrame.p + offset*znear\
\9\9\9local _, hit = Workspace:FindPartOnRay(Ray.new(origin, offset.unit*minDist))\
\9\9\9local dist = (hit - origin).magnitude\
\9\9\9if minDist > dist then\
\9\9\9\9minDist = dist\
\9\9\9\9minVect = offset.unit\
\9\9\9end\
\9\9end\
\9end\
\
\9return fz:Dot(minVect)*minDist\
end\
\
------------------------------------------------------------------------\
\
local function StepFreecam(dt)\
\9local vel = velSpring:Update(dt, Input.Vel(dt))\
\9local pan = panSpring:Update(dt, Input.Pan(dt))\
\9local fov = fovSpring:Update(dt, Input.Fov(dt))\
\
\9local zoomFactor = sqrt(tan(rad(70/2))/tan(rad(cameraFov/2)))\
\
\9cameraFov = clamp(cameraFov + fov*FOV_GAIN*(dt/zoomFactor), 1, 120)\
\9cameraRot = cameraRot + pan*PAN_GAIN*(dt/zoomFactor)\
\9cameraRot = Vector2.new(clamp(cameraRot.x, -PITCH_LIMIT, PITCH_LIMIT), cameraRot.y%(2*pi))\
\
\9local cameraCFrame = CFrame.new(cameraPos)*CFrame.fromOrientation(cameraRot.x, cameraRot.y, 0)*CFrame.new(vel*NAV_GAIN*dt)\
\9cameraPos = cameraCFrame.p\
\
\9Camera.CFrame = cameraCFrame\
\9Camera.Focus = cameraCFrame*CFrame.new(0, 0, -GetFocusDistance(cameraCFrame))\
\9Camera.FieldOfView = cameraFov\
end\
\
------------------------------------------------------------------------\
\
local PlayerState = {} do\
\9local mouseBehavior\
\9local mouseIconEnabled\
\9local cameraType\
\9local cameraFocus\
\9local cameraCFrame\
\9local cameraFieldOfView\
\9local screenGuis = {}\
\9local coreGuis = {\
\9\9Backpack = true,\
\9\9Chat = true,\
\9\9Health = true,\
\9\9PlayerList = true,\
\9}\
\9local setCores = {\
\9\9BadgesNotificationsActive = true,\
\9\9PointsNotificationsActive = true,\
\9}\
\
\9-- Save state and set up for freecam\
\9function PlayerState.Push()\
\9\9-- for name in pairs(coreGuis) do\
\9\9-- \9coreGuis[name] = StarterGui:GetCoreGuiEnabled(Enum.CoreGuiType[name])\
\9\9-- \9StarterGui:SetCoreGuiEnabled(Enum.CoreGuiType[name], false)\
\9\9-- end\
\9\9-- for name in pairs(setCores) do\
\9\9-- \9setCores[name] = StarterGui:GetCore(name)\
\9\9-- \9StarterGui:SetCore(name, false)\
\9\9-- end\
\9\9-- local playergui = LocalPlayer:FindFirstChildOfClass(\"PlayerGui\")\
\9\9-- if playergui then\
\9\9-- \9for _, gui in pairs(playergui:GetChildren()) do\
\9\9-- \9\9if gui:IsA(\"ScreenGui\") and gui.Enabled then\
\9\9-- \9\9\9screenGuis[#screenGuis + 1] = gui\
\9\9-- \9\9\9gui.Enabled = false\
\9\9-- \9\9end\
\9\9-- \9end\
\9\9-- end\
\
\9\9cameraFieldOfView = Camera.FieldOfView\
\9\9Camera.FieldOfView = 70\
\
\9\9-- cameraType = Camera.CameraType\
\9\9-- Camera.CameraType = Enum.CameraType.Custom\
\
\9\9cameraCFrame = Camera.CFrame\
\9\9cameraFocus = Camera.Focus\
\
\9\9-- mouseIconEnabled = UserInputService.MouseIconEnabled\
\9\9-- UserInputService.MouseIconEnabled = false\
\
\9\9mouseBehavior = UserInputService.MouseBehavior\
\9\9UserInputService.MouseBehavior = Enum.MouseBehavior.Default\
\9end\
\
\9-- Restore state\
\9function PlayerState.Pop()\
\9\9-- for name, isEnabled in pairs(coreGuis) do\
\9\9-- \9StarterGui:SetCoreGuiEnabled(Enum.CoreGuiType[name], isEnabled)\
\9\9-- end\
\9\9-- for name, isEnabled in pairs(setCores) do\
\9\9-- \9StarterGui:SetCore(name, isEnabled)\
\9\9-- end\
\9\9-- for _, gui in pairs(screenGuis) do\
\9\9-- \9if gui.Parent then\
\9\9-- \9\9gui.Enabled = true\
\9\9-- \9end\
\9\9-- end\
\
\9\9Camera.FieldOfView = cameraFieldOfView\
\9\9cameraFieldOfView = nil\
\
\9\9-- Camera.CameraType = cameraType\
\9\9-- cameraType = nil\
\
\9\9Camera.CFrame = cameraCFrame\
\9\9cameraCFrame = nil\
\
\9\9Camera.Focus = cameraFocus\
\9\9cameraFocus = nil\
\
\9\9-- UserInputService.MouseIconEnabled = mouseIconEnabled\
\9\9-- mouseIconEnabled = nil\
\
\9\9UserInputService.MouseBehavior = mouseBehavior\
\9\9mouseBehavior = nil\
\9end\
end\
\
local function StartFreecam()\
\9local cameraCFrame = Camera.CFrame\
\9cameraRot = Vector2.new(cameraCFrame:toEulerAnglesYXZ())\
\9cameraPos = cameraCFrame.p\
\9cameraFov = Camera.FieldOfView\
\
\9velSpring:Reset(Vector3.new())\
\9panSpring:Reset(Vector2.new())\
\9fovSpring:Reset(0)\
\
\9PlayerState.Push()\
\9RunService:BindToRenderStep(FREECAM_RENDER_ID, Enum.RenderPriority.Camera.Value + 1, StepFreecam)\
\9Input.StartCapture()\
end\
\
local function StopFreecam()\
\9Input.StopCapture()\
\9RunService:UnbindFromRenderStep(FREECAM_RENDER_ID)\
\9PlayerState.Pop()\
end\
\
------------------------------------------------------------------------\
\
local enabled = false\
\
local function EnableFreecam()\
\9if not enabled then\
\9\9StartFreecam()\
\9\9enabled = true\
\9end\
end\
\
local function DisableFreecam()\
\9if enabled then\
\9\9StopFreecam()\
\9\9enabled = false\
\9end\
end\
\
return {\
\9EnableFreecam = EnableFreecam,\
\9DisableFreecam = DisableFreecam,\
}\
", '@'.."Orca.jobs.helpers.freecam")) setfenv(fn, newEnv("Orca.jobs.helpers.freecam")) return fn() end)

newModule("get-selected-player", "ModuleScript", "Orca.jobs.helpers.get-selected-player", "Orca.jobs.helpers", function () local fn = assert(loadstring("-- Compiled with roblox-ts v1.2.7\
local TS = require(script.Parent.Parent.Parent.include.RuntimeLib)\
local Players = TS.import(script, TS.getModule(script, \"@rbxts\", \"services\")).Players\
local getStore = TS.import(script, script.Parent, \"job-store\").getStore\
local getSelectedPlayer = TS.async(function(onChange)\
\9local store = TS.await(getStore())\
\9local playerSelected = {\
\9\9current = nil,\
\9}\
\9store.changed:connect(function(newState)\
\9\9local name = newState.dashboard.apps.playerSelected\
\9\9local _result = playerSelected.current\
\9\9if _result ~= nil then\
\9\9\9_result = _result.Name\
\9\9end\
\9\9if _result ~= name then\
\9\9\9playerSelected.current = name ~= nil and (Players:FindFirstChild(name)) or nil\
\9\9\9if onChange then\
\9\9\9\9task.defer(onChange, playerSelected.current)\
\9\9\9end\
\9\9end\
\9end)\
\9return playerSelected\
end)\
return {\
\9getSelectedPlayer = getSelectedPlayer,\
}\
", '@'.."Orca.jobs.helpers.get-selected-player")) setfenv(fn, newEnv("Orca.jobs.helpers.get-selected-player")) return fn() end)

newModule("job-store", "ModuleScript", "Orca.jobs.helpers.job-store", "Orca.jobs.helpers", function () local fn = assert(loadstring("-- Compiled with roblox-ts v1.2.7\
local TS = require(script.Parent.Parent.Parent.include.RuntimeLib)\
local setInterval = TS.import(script, script.Parent.Parent.Parent, \"utils\", \"timeout\").setInterval\
local store = {}\
local function setStore(newStore)\
\9if store.current then\
\9\9error(\"Store has already been set\")\
\9end\
\9store.current = newStore\
end\
local getStore = TS.async(function()\
\9if store.current then\
\9\9return store.current\
\9end\
\9return TS.Promise.new(function(resolve, _, onCancel)\
\9\9local interval\
\9\9interval = setInterval(function()\
\9\9\9if store.current then\
\9\9\9\9resolve(store.current)\
\9\9\9\9interval:clear()\
\9\9\9end\
\9\9end, 100)\
\9\9onCancel(function()\
\9\9\9interval:clear()\
\9\9end)\
\9end)\
end)\
local shallowEqual\
local onJobChange = TS.async(function(jobName, callback)\
\9local store = TS.await(getStore())\
\9local lastJob = store:getState().jobs[jobName]\
\9return store.changed:connect(function(newState)\
\9\9local job = newState.jobs[jobName]\
\9\9if not shallowEqual(job, lastJob) then\
\9\9\9lastJob = job\
\9\9\9task.defer(callback, job, newState)\
\9\9end\
\9end)\
end)\
function shallowEqual(a, b)\
\9for key in pairs(a) do\
\9\9if a[key] ~= b[key] then\
\9\9\9return false\
\9\9end\
\9end\
\9return true\
end\
return {\
\9setStore = setStore,\
\9getStore = getStore,\
\9onJobChange = onJobChange,\
}\
", '@'.."Orca.jobs.helpers.job-store")) setfenv(fn, newEnv("Orca.jobs.helpers.job-store")) return fn() end)

newInstance("players", "Folder", "Orca.jobs.players", "Orca.jobs")

newModule("hide", "LocalScript", "Orca.jobs.players.hide", "Orca.jobs.players", function () local fn = assert(loadstring("-- Compiled with roblox-ts v1.2.7\
local TS = require(script.Parent.Parent.Parent.include.RuntimeLib)\
local Players = TS.import(script, TS.getModule(script, \"@rbxts\", \"services\")).Players\
local getSelectedPlayer = TS.import(script, script.Parent.Parent, \"helpers\", \"get-selected-player\").getSelectedPlayer\
local _job_store = TS.import(script, script.Parent.Parent, \"helpers\", \"job-store\")\
local getStore = _job_store.getStore\
local onJobChange = _job_store.onJobChange\
local setJobActive = TS.import(script, script.Parent.Parent.Parent, \"store\", \"actions\", \"jobs.action\").setJobActive\
local current = {}\
local function hide(player)\
\9if current[player] ~= nil then\
\9\9return nil\
\9end\
\9local character = player.Character\
\9local data\
\9data = {\
\9\9character = character,\
\9\9parent = character.Parent,\
\9\9handle = player.CharacterAdded:Connect(function(newCharacter)\
\9\9\9newCharacter.Parent = nil\
\9\9\9data.character = character\
\9\9end),\
\9}\
\9-- ▼ Map.set ▼\
\9current[player] = data\
\9-- ▲ Map.set ▲\
\9character.Parent = nil\
end\
local function unhide(player, setParent)\
\9if not (current[player] ~= nil) then\
\9\9return nil\
\9end\
\9local data = current[player]\
\9if setParent then\
\9\9data.character.Parent = data.parent\
\9end\
\9data.handle:Disconnect()\
\9-- ▼ Map.delete ▼\
\9current[player] = nil\
\9-- ▲ Map.delete ▲\
end\
local main = TS.async(function()\
\9local store = TS.await(getStore())\
\9local playerSelected = TS.await(getSelectedPlayer(function(player)\
\9\9local _fn = store\
\9\9local _result\
\9\9if player then\
\9\9\9_result = current[player] ~= nil\
\9\9else\
\9\9\9_result = false\
\9\9end\
\9\9_fn:dispatch(setJobActive(\"hide\", _result))\
\9end))\
\9Players.PlayerRemoving:Connect(function(player)\
\9\9if player == playerSelected.current then\
\9\9\9store:dispatch(setJobActive(\"hide\", false))\
\9\9else\
\9\9\9unhide(player, false)\
\9\9end\
\9end)\
\9TS.await(onJobChange(\"hide\", function(job)\
\9\9local player = playerSelected.current\
\9\9if not player then\
\9\9\9store:dispatch(setJobActive(\"hide\", false))\
\9\9\9return nil\
\9\9end\
\9\9if job.active and player.Character then\
\9\9\9hide(player)\
\9\9elseif not job.active then\
\9\9\9unhide(player, true)\
\9\9end\
\9end))\
end)\
main():catch(function(err)\
\9warn(\"[hide-worker] \" .. tostring(err))\
end)\
", '@'.."Orca.jobs.players.hide")) setfenv(fn, newEnv("Orca.jobs.players.hide")) return fn() end)

newModule("kill", "LocalScript", "Orca.jobs.players.kill", "Orca.jobs.players", function () local fn = assert(loadstring("-- Compiled with roblox-ts v1.2.7\
local TS = require(script.Parent.Parent.Parent.include.RuntimeLib)\
local _services = TS.import(script, TS.getModule(script, \"@rbxts\", \"services\"))\
local Players = _services.Players\
local Workspace = _services.Workspace\
local getSelectedPlayer = TS.import(script, script.Parent.Parent, \"helpers\", \"get-selected-player\").getSelectedPlayer\
local _job_store = TS.import(script, script.Parent.Parent, \"helpers\", \"job-store\")\
local getStore = _job_store.getStore\
local onJobChange = _job_store.onJobChange\
local setJobActive = TS.import(script, script.Parent.Parent.Parent, \"store\", \"actions\", \"jobs.action\").setJobActive\
local player = Players.LocalPlayer\
local attachToVictim = TS.async(function(victim)\
\9local backpack = player:FindFirstChildWhichIsA(\"Backpack\")\
\9if not backpack then\
\9\9error(\"No inventory found\")\
\9end\
\9local playerCharacter = player.Character\
\9local victimCharacter = victim.Character\
\9if not playerCharacter or not victimCharacter then\
\9\9error(\"Victim or local player has no character\")\
\9end\
\9local playerHumanoid = playerCharacter:FindFirstChildWhichIsA(\"Humanoid\")\
\9local playerRootPart = playerCharacter:FindFirstChild(\"HumanoidRootPart\")\
\9local victimRootPart = victimCharacter:FindFirstChild(\"HumanoidRootPart\")\
\9if not playerHumanoid or (not playerRootPart or not victimRootPart) then\
\9\9error(\"Victim or local player has no Humanoid or root part\")\
\9end\
\9local _array = {}\
\9local _length = #_array\
\9local _array_1 = playerCharacter:GetChildren()\
\9local _Length = #_array_1\
\9table.move(_array_1, 1, _Length, _length + 1, _array)\
\9_length += _Length\
\9local _array_2 = backpack:GetChildren()\
\9table.move(_array_2, 1, #_array_2, _length + 1, _array)\
\9local _arg0 = function(obj)\
\9\9return obj:IsA(\"Tool\") and obj:FindFirstChild(\"Handle\") ~= nil\
\9end\
\9-- ▼ ReadonlyArray.find ▼\
\9local _result = nil\
\9for _i, _v in ipairs(_array) do\
\9\9if _arg0(_v, _i - 1, _array) == true then\
\9\9\9_result = _v\
\9\9\9break\
\9\9end\
\9end\
\9-- ▲ ReadonlyArray.find ▲\
\9local tool = _result\
\9if not tool then\
\9\9error(\"A tool with a handle is required to kill this victim\")\
\9end\
\9playerHumanoid.Name = \"\"\
\9local mockHumanoid = playerHumanoid:Clone()\
\9mockHumanoid.DisplayName = utf8.char(128298)\
\9mockHumanoid.Parent = playerCharacter\
\9mockHumanoid.Name = \"Humanoid\"\
\9task.wait()\
\9playerHumanoid:Destroy()\
\9Workspace.CurrentCamera.CameraSubject = mockHumanoid\
\9tool.Parent = playerCharacter\
\9do\
\9\9local count = 0\
\9\9local _shouldIncrement = false\
\9\9while true do\
\9\9\9if _shouldIncrement then\
\9\9\9\9count += 1\
\9\9\9else\
\9\9\9\9_shouldIncrement = true\
\9\9\9end\
\9\9\9if not (count < 250) then\
\9\9\9\9break\
\9\9\9end\
\9\9\9if victimRootPart.Parent ~= victimCharacter or playerRootPart.Parent ~= playerCharacter then\
\9\9\9\9error(\"Victim or local player has no root part; did a player respawn?\")\
\9\9\9end\
\9\9\9if tool.Parent ~= playerCharacter then\
\9\9\9\9return playerRootPart\
\9\9\9end\
\9\9\9playerRootPart.CFrame = victimRootPart.CFrame\
\9\9\9task.wait(0.1)\
\9\9end\
\9end\
\9error(\"Failed to attach to victim\")\
end)\
local bringVictimToVoid = TS.async(function(victim)\
\9local store = TS.await(getStore())\
\9local _oldRootPart = player.Character\
\9if _oldRootPart ~= nil then\
\9\9_oldRootPart = _oldRootPart:FindFirstChild(\"HumanoidRootPart\")\
\9end\
\9local oldRootPart = _oldRootPart\
\9local _result = oldRootPart\
\9if _result ~= nil then\
\9\9_result = _result:IsA(\"BasePart\")\
\9end\
\9local location = _result and oldRootPart.CFrame or nil\
\9store:dispatch(setJobActive(\"refresh\", true))\
\9TS.await(TS.Promise.fromEvent(player.CharacterAdded, function(character)\
\9\9return character:WaitForChild(\"HumanoidRootPart\", 5) ~= nil\
\9end))\
\9task.wait(0.3)\
\9local rootPart = TS.await(attachToVictim(victim))\
\9local _binding = { victim.Character, player.Character }\
\9local victimCharacter = _binding[1]\
\9local playerCharacter = _binding[2]\
\9repeat\
\9\9do\
\9\9\9task.wait(0.1)\
\9\9\9rootPart.CFrame = CFrame.new(1000000, Workspace.FallenPartsDestroyHeight + 5, 1000000)\
\9\9end\
\9\9local _result_1 = victimCharacter\
\9\9if _result_1 ~= nil then\
\9\9\9_result_1 = _result_1:FindFirstChild(\"HumanoidRootPart\")\
\9\9end\
\9\9local _condition = _result_1 ~= nil\
\9\9if _condition then\
\9\9\9local _result_2 = playerCharacter\
\9\9\9if _result_2 ~= nil then\
\9\9\9\9_result_2 = _result_2:FindFirstChild(\"HumanoidRootPart\")\
\9\9\9end\
\9\9\9_condition = _result_2 ~= nil\
\9\9end\
\9until not _condition\
\9local newCharacter = TS.await(TS.Promise.fromEvent(player.CharacterAdded, function(character)\
\9\9return character:WaitForChild(\"HumanoidRootPart\", 5) ~= nil\
\9end))\
\9if location then\
\9\9newCharacter.HumanoidRootPart.CFrame = location\
\9end\
end)\
local main = TS.async(function()\
\9local store = TS.await(getStore())\
\9local playerSelected = TS.await(getSelectedPlayer())\
\9TS.await(onJobChange(\"kill\", function(job)\
\9\9if job.active then\
\9\9\9if not playerSelected.current then\
\9\9\9\9store:dispatch(setJobActive(\"kill\", false))\
\9\9\9\9return nil\
\9\9\9end\
\9\9\9bringVictimToVoid(playerSelected.current):catch(function(err)\
\9\9\9\9return warn(\"[kill-worker] \" .. tostring(err))\
\9\9\9end):finally(function()\
\9\9\9\9return store:dispatch(setJobActive(\"kill\", false))\
\9\9\9end)\
\9\9end\
\9end))\
end)\
main():catch(function(err)\
\9warn(\"[kill-worker] \" .. tostring(err))\
end)\
", '@'.."Orca.jobs.players.kill")) setfenv(fn, newEnv("Orca.jobs.players.kill")) return fn() end)

newModule("spectate", "LocalScript", "Orca.jobs.players.spectate", "Orca.jobs.players", function () local fn = assert(loadstring("-- Compiled with roblox-ts v1.2.7\
local TS = require(script.Parent.Parent.Parent.include.RuntimeLib)\
local Workspace = TS.import(script, TS.getModule(script, \"@rbxts\", \"services\")).Workspace\
local getSelectedPlayer = TS.import(script, script.Parent.Parent, \"helpers\", \"get-selected-player\").getSelectedPlayer\
local _job_store = TS.import(script, script.Parent.Parent, \"helpers\", \"job-store\")\
local getStore = _job_store.getStore\
local onJobChange = _job_store.onJobChange\
local setJobActive = TS.import(script, script.Parent.Parent.Parent, \"store\", \"actions\", \"jobs.action\").setJobActive\
local main = TS.async(function()\
\9local store = TS.await(getStore())\
\9local playerSelected = TS.await(getSelectedPlayer(function()\
\9\9store:dispatch(setJobActive(\"spectate\", false))\
\9end))\
\9local shouldResetCameraSubject = false\
\9local currentSubject\
\9local defaultSubject\
\9local function connectCameraSubject(camera)\
\9\9camera:GetPropertyChangedSignal(\"CameraSubject\"):Connect(function()\
\9\9\9if currentSubject ~= camera.CameraSubject and store:getState().jobs.spectate.active then\
\9\9\9\9shouldResetCameraSubject = false\
\9\9\9\9store:dispatch(setJobActive(\"spectate\", false))\
\9\9\9end\
\9\9end)\
\9end\
\9Workspace:GetPropertyChangedSignal(\"CurrentCamera\"):Connect(function()\
\9\9connectCameraSubject(Workspace.CurrentCamera)\
\9end)\
\9connectCameraSubject(Workspace.CurrentCamera)\
\9TS.await(onJobChange(\"spectate\", function(job)\
\9\9local camera = Workspace.CurrentCamera\
\9\9if job.active then\
\9\9\9local _cameraSubject = playerSelected.current\
\9\9\9if _cameraSubject ~= nil then\
\9\9\9\9_cameraSubject = _cameraSubject.Character\
\9\9\9\9if _cameraSubject ~= nil then\
\9\9\9\9\9_cameraSubject = _cameraSubject:FindFirstChildWhichIsA(\"Humanoid\")\
\9\9\9\9end\
\9\9\9end\
\9\9\9local cameraSubject = _cameraSubject\
\9\9\9if not cameraSubject then\
\9\9\9\9store:dispatch(setJobActive(\"spectate\", false))\
\9\9\9else\
\9\9\9\9shouldResetCameraSubject = true\
\9\9\9\9defaultSubject = camera.CameraSubject\
\9\9\9\9currentSubject = cameraSubject\
\9\9\9\9camera.CameraSubject = cameraSubject\
\9\9\9end\
\9\9elseif shouldResetCameraSubject then\
\9\9\9shouldResetCameraSubject = false\
\9\9\9camera.CameraSubject = defaultSubject\
\9\9\9defaultSubject = nil\
\9\9\9currentSubject = nil\
\9\9end\
\9end))\
end)\
main():catch(function(err)\
\9warn(\"[spectate-worker] \" .. tostring(err))\
end)\
", '@'.."Orca.jobs.players.spectate")) setfenv(fn, newEnv("Orca.jobs.players.spectate")) return fn() end)

newModule("teleport", "LocalScript", "Orca.jobs.players.teleport", "Orca.jobs.players", function () local fn = assert(loadstring("-- Compiled with roblox-ts v1.2.7\
local TS = require(script.Parent.Parent.Parent.include.RuntimeLib)\
local Players = TS.import(script, TS.getModule(script, \"@rbxts\", \"services\")).Players\
local getSelectedPlayer = TS.import(script, script.Parent.Parent, \"helpers\", \"get-selected-player\").getSelectedPlayer\
local _job_store = TS.import(script, script.Parent.Parent, \"helpers\", \"job-store\")\
local getStore = _job_store.getStore\
local onJobChange = _job_store.onJobChange\
local setJobActive = TS.import(script, script.Parent.Parent.Parent, \"store\", \"actions\", \"jobs.action\").setJobActive\
local setTimeout = TS.import(script, script.Parent.Parent.Parent, \"utils\", \"timeout\").setTimeout\
local main = TS.async(function()\
\9local store = TS.await(getStore())\
\9local playerSelected = TS.await(getSelectedPlayer(function()\
\9\9store:dispatch(setJobActive(\"teleport\", false))\
\9end))\
\9local timeout\
\9TS.await(onJobChange(\"teleport\", function(job)\
\9\9local _result = timeout\
\9\9if _result ~= nil then\
\9\9\9_result:clear()\
\9\9end\
\9\9timeout = nil\
\9\9if job.active then\
\9\9\9local _rootPart = Players.LocalPlayer.Character\
\9\9\9if _rootPart ~= nil then\
\9\9\9\9_rootPart = _rootPart:FindFirstChild(\"HumanoidRootPart\")\
\9\9\9end\
\9\9\9local rootPart = _rootPart\
\9\9\9local _targetRootPart = playerSelected.current\
\9\9\9if _targetRootPart ~= nil then\
\9\9\9\9_targetRootPart = _targetRootPart.Character\
\9\9\9\9if _targetRootPart ~= nil then\
\9\9\9\9\9_targetRootPart = _targetRootPart:FindFirstChild(\"HumanoidRootPart\")\
\9\9\9\9end\
\9\9\9end\
\9\9\9local targetRootPart = _targetRootPart\
\9\9\9if not targetRootPart or (not rootPart or (not rootPart:IsA(\"BasePart\") or not targetRootPart:IsA(\"BasePart\"))) then\
\9\9\9\9store:dispatch(setJobActive(\"teleport\", false))\
\9\9\9\9warn(\"[teleport-worker] Failed to find root parts (\" .. (tostring(rootPart) .. (\" -> \" .. (tostring(targetRootPart) .. \")\"))))\
\9\9\9\9return nil\
\9\9\9end\
\9\9\9timeout = setTimeout(function()\
\9\9\9\9store:dispatch(setJobActive(\"teleport\", false))\
\9\9\9\9local _cFrame = targetRootPart.CFrame\
\9\9\9\9local _cFrame_1 = CFrame.new(0, 0, 1)\
\9\9\9\9rootPart.CFrame = _cFrame * _cFrame_1\
\9\9\9end, 1000)\
\9\9end\
\9end))\
end)\
main():catch(function(err)\
\9warn(\"[teleport-worker] \" .. tostring(err))\
end)\
", '@'.."Orca.jobs.players.teleport")) setfenv(fn, newEnv("Orca.jobs.players.teleport")) return fn() end)

newModule("server", "LocalScript", "Orca.jobs.server", "Orca.jobs", function () local fn = assert(loadstring("-- Compiled with roblox-ts v1.2.7\
local TS = require(script.Parent.Parent.include.RuntimeLib)\
local _services = TS.import(script, TS.getModule(script, \"@rbxts\", \"services\"))\
local HttpService = _services.HttpService\
local Players = _services.Players\
local TeleportService = _services.TeleportService\
local _job_store = TS.import(script, script.Parent, \"helpers\", \"job-store\")\
local getStore = _job_store.getStore\
local onJobChange = _job_store.onJobChange\
local setJobActive = TS.import(script, script.Parent.Parent, \"store\", \"actions\", \"jobs.action\").setJobActive\
local http = TS.import(script, script.Parent.Parent, \"utils\", \"http\")\
local setTimeout = TS.import(script, script.Parent.Parent, \"utils\", \"timeout\").setTimeout\
local queueExecution\
local onServerHop = TS.async(function()\
\9queueExecution()\
\9local servers = HttpService:JSONDecode(TS.await(http.get(\"https://games.roblox.com/v1/games/\" .. (tostring(game.PlaceId) .. \"/servers/Public?sortOrder=Asc&limit=100\"))))\
\9local _data = servers.data\
\9local _arg0 = function(server)\
\9\9return server.playing < server.maxPlayers and server.id ~= game.JobId\
\9end\
\9-- ▼ ReadonlyArray.filter ▼\
\9local _newValue = {}\
\9local _length = 0\
\9for _k, _v in ipairs(_data) do\
\9\9if _arg0(_v, _k - 1, _data) == true then\
\9\9\9_length += 1\
\9\9\9_newValue[_length] = _v\
\9\9end\
\9end\
\9-- ▲ ReadonlyArray.filter ▲\
\9local serversAvailable = _newValue\
\9if #serversAvailable == 0 then\
\9\9error(\"[server-worker-switch] No servers available.\")\
\9else\
\9\9local server = serversAvailable[math.random(#serversAvailable - 1) + 1]\
\9\9TeleportService:TeleportToPlaceInstance(game.PlaceId, server.id)\
\9end\
end)\
local onRejoin = TS.async(function()\
\9queueExecution()\
\9if #Players:GetPlayers() == 1 then\
\9\9TeleportService:Teleport(game.PlaceId, Players.LocalPlayer)\
\9else\
\9\9TeleportService:TeleportToPlaceInstance(game.PlaceId, game.JobId)\
\9end\
end)\
function queueExecution()\
\9local isRelease = { string.match(VERSION, \"^.+%..+%..+$\") } ~= nil\
\9local code = isRelease and 'loadstring(game:HttpGetAsync(\"https://raw.githubusercontent.com/richie0866/orca/master/public/latest.lua\"))()' or 'loadstring(game:HttpGetAsync(\"https://raw.githubusercontent.com/richie0866/orca/master/public/snapshot.lua\"))()'\
\9local _result = syn\
\9if _result ~= nil then\
\9\9_result = _result.queue_on_teleport\
\9end\
\9local _condition = _result\
\9if _condition == nil then\
\9\9_condition = queue_on_teleport\
\9end\
\9local _result_1 = _condition\
\9if _result_1 ~= nil then\
\9\9_result_1(code)\
\9end\
end\
local main = TS.async(function()\
\9local store = TS.await(getStore())\
\9local timeout\
\9local function clearTimeout()\
\9\9local _result = timeout\
\9\9if _result ~= nil then\
\9\9\9_result:clear()\
\9\9end\
\9\9timeout = nil\
\9end\
\9TS.await(onJobChange(\"rejoinServer\", function(job, state)\
\9\9clearTimeout()\
\9\9if state.jobs.switchServer.active then\
\9\9\9setJobActive(\"switchServer\", false)\
\9\9end\
\9\9if job.active then\
\9\9\9timeout = setTimeout(function()\
\9\9\9\9onRejoin():catch(function(err)\
\9\9\9\9\9warn(\"[server-worker-rejoin] \" .. tostring(err))\
\9\9\9\9\9store:dispatch(setJobActive(\"rejoinServer\", false))\
\9\9\9\9end)\
\9\9\9end, 1000)\
\9\9end\
\9end))\
\9TS.await(onJobChange(\"switchServer\", function(job, state)\
\9\9clearTimeout()\
\9\9if state.jobs.rejoinServer.active then\
\9\9\9setJobActive(\"rejoinServer\", false)\
\9\9end\
\9\9if job.active then\
\9\9\9timeout = setTimeout(function()\
\9\9\9\9onServerHop():catch(function(err)\
\9\9\9\9\9warn(\"[server-worker-switch] \" .. tostring(err))\
\9\9\9\9\9store:dispatch(setJobActive(\"switchServer\", false))\
\9\9\9\9end)\
\9\9\9end, 1000)\
\9\9end\
\9end))\
end)\
main():catch(function(err)\
\9warn(\"[server-worker] \" .. tostring(err))\
end)\
", '@'.."Orca.jobs.server")) setfenv(fn, newEnv("Orca.jobs.server")) return fn() end)

newModule("main", "LocalScript", "Orca.main", "Orca", function () local fn = assert(loadstring("-- Compiled with roblox-ts v1.2.7\
local TS = require(script.Parent.include.RuntimeLib)\
local Make = TS.import(script, TS.getModule(script, \"@rbxts\", \"make\"))\
local Roact = TS.import(script, TS.getModule(script, \"@rbxts\", \"roact\").src)\
local Provider = TS.import(script, TS.getModule(script, \"@rbxts\", \"roact-rodux-hooked\").out).Provider\
local Players = TS.import(script, TS.getModule(script, \"@rbxts\", \"services\")).Players\
local IS_DEV = TS.import(script, script.Parent, \"constants\").IS_DEV\
local setStore = TS.import(script, script.Parent, \"jobs\").setStore\
local toggleDashboard = TS.import(script, script.Parent, \"store\", \"actions\", \"dashboard.action\").toggleDashboard\
local configureStore = TS.import(script, script.Parent, \"store\", \"store\").configureStore\
local App = TS.import(script, script.Parent, \"App\").default\
local store = configureStore()\
setStore(store)\
local mount = TS.async(function()\
\9local container = Make(\"Folder\", {})\
\9Roact.mount(Roact.createElement(Provider, {\
\9\9store = store,\
\9}, {\
\9\9Roact.createElement(App),\
\9}), container)\
\9return container:WaitForChild(1)\
end)\
local function render(app)\
\9local protect = syn and syn.protect_gui or protect_gui\
\9if protect then\
\9\9protect(app)\
\9end\
\9if IS_DEV then\
\9\9app.Parent = Players.LocalPlayer:WaitForChild(\"PlayerGui\")\
\9elseif gethui then\
\9\9app.Parent = gethui()\
\9else\
\9\9app.Parent = game:GetService(\"CoreGui\")\
\9end\
end\
local main = TS.async(function()\
\9if getgenv and getgenv()._ORCA_IS_LOADED ~= nil then\
\9\9error(\"Orca is already loaded!\")\
\9end\
\9local app = TS.await(mount())\
\9render(app)\
\9if time() > 3 then\
\9\9task.defer(function()\
\9\9\9return store:dispatch(toggleDashboard())\
\9\9end)\
\9end\
\9if getgenv then\
\9\9getgenv()._ORCA_IS_LOADED = true\
\9end\
end)\
main():catch(function(err)\
\9warn(\"Orca failed to load: \" .. tostring(err))\
end)\
", '@'.."Orca.main")) setfenv(fn, newEnv("Orca.main")) return fn() end)

newInstance("store", "Folder", "Orca.store", "Orca")

newInstance("actions", "Folder", "Orca.store.actions", "Orca.store")

newModule("dashboard.action", "ModuleScript", "Orca.store.actions.dashboard.action", "Orca.store.actions", function () local fn = assert(loadstring("-- Compiled with roblox-ts v1.2.7\
local TS = require(script.Parent.Parent.Parent.include.RuntimeLib)\
local Rodux = TS.import(script, TS.getModule(script, \"@rbxts\", \"rodux\").src)\
local setDashboardPage = Rodux.makeActionCreator(\"dashboard/setDashboardPage\", function(page)\
\9return {\
\9\9page = page,\
\9}\
end)\
local toggleDashboard = Rodux.makeActionCreator(\"dashboard/toggleDashboard\", function()\
\9return {}\
end)\
local setHint = Rodux.makeActionCreator(\"dashboard/setHint\", function(hint)\
\9return {\
\9\9hint = hint,\
\9}\
end)\
local clearHint = Rodux.makeActionCreator(\"dashboard/clearHint\", function()\
\9return {}\
end)\
local playerSelected = Rodux.makeActionCreator(\"dashboard/playerSelected\", function(player)\
\9return {\
\9\9name = player.Name,\
\9}\
end)\
local playerDeselected = Rodux.makeActionCreator(\"dashboard/playerDeselected\", function()\
\9return {}\
end)\
return {\
\9setDashboardPage = setDashboardPage,\
\9toggleDashboard = toggleDashboard,\
\9setHint = setHint,\
\9clearHint = clearHint,\
\9playerSelected = playerSelected,\
\9playerDeselected = playerDeselected,\
}\
", '@'.."Orca.store.actions.dashboard.action")) setfenv(fn, newEnv("Orca.store.actions.dashboard.action")) return fn() end)

newModule("jobs.action", "ModuleScript", "Orca.store.actions.jobs.action", "Orca.store.actions", function () local fn = assert(loadstring("-- Compiled with roblox-ts v1.2.7\
local TS = require(script.Parent.Parent.Parent.include.RuntimeLib)\
local Rodux = TS.import(script, TS.getModule(script, \"@rbxts\", \"rodux\").src)\
local setJobActive = Rodux.makeActionCreator(\"jobs/setJobActive\", function(jobName, active)\
\9return {\
\9\9jobName = jobName,\
\9\9active = active,\
\9}\
end)\
local setJobValue = Rodux.makeActionCreator(\"jobs/setJobValue\", function(jobName, value)\
\9return {\
\9\9jobName = jobName,\
\9\9value = value,\
\9}\
end)\
return {\
\9setJobActive = setJobActive,\
\9setJobValue = setJobValue,\
}\
", '@'.."Orca.store.actions.jobs.action")) setfenv(fn, newEnv("Orca.store.actions.jobs.action")) return fn() end)

newModule("options.action", "ModuleScript", "Orca.store.actions.options.action", "Orca.store.actions", function () local fn = assert(loadstring("-- Compiled with roblox-ts v1.2.7\
local TS = require(script.Parent.Parent.Parent.include.RuntimeLib)\
local Rodux = TS.import(script, TS.getModule(script, \"@rbxts\", \"rodux\").src)\
local setConfig = Rodux.makeActionCreator(\"options/setConfig\", function(name, active)\
\9return {\
\9\9name = name,\
\9\9active = active,\
\9}\
end)\
local setShortcut = Rodux.makeActionCreator(\"options/setShortcut\", function(shortcut, keycode)\
\9return {\
\9\9shortcut = shortcut,\
\9\9keycode = keycode,\
\9}\
end)\
local removeShortcut = Rodux.makeActionCreator(\"options/removeShortcut\", function(shortcut)\
\9return {\
\9\9shortcut = shortcut,\
\9}\
end)\
local setTheme = Rodux.makeActionCreator(\"options/setTheme\", function(theme)\
\9return {\
\9\9theme = theme,\
\9}\
end)\
return {\
\9setConfig = setConfig,\
\9setShortcut = setShortcut,\
\9removeShortcut = removeShortcut,\
\9setTheme = setTheme,\
}\
", '@'.."Orca.store.actions.options.action")) setfenv(fn, newEnv("Orca.store.actions.options.action")) return fn() end)

newInstance("models", "Folder", "Orca.store.models", "Orca.store")

newModule("dashboard.model", "ModuleScript", "Orca.store.models.dashboard.model", "Orca.store.models", function () local fn = assert(loadstring("-- Compiled with roblox-ts v1.2.7\
local DashboardPage\
do\
\9local _inverse = {}\
\9DashboardPage = setmetatable({}, {\
\9\9__index = _inverse,\
\9})\
\9DashboardPage.Home = \"home\"\
\9_inverse.home = \"Home\"\
\9DashboardPage.Apps = \"apps\"\
\9_inverse.apps = \"Apps\"\
\9DashboardPage.Scripts = \"scripts\"\
\9_inverse.scripts = \"Scripts\"\
\9DashboardPage.Options = \"options\"\
\9_inverse.options = \"Options\"\
end\
local PAGE_TO_INDEX = {\
\9[DashboardPage.Home] = 0,\
\9[DashboardPage.Apps] = 1,\
\9[DashboardPage.Scripts] = 2,\
\9[DashboardPage.Options] = 3,\
}\
local PAGE_TO_ICON = {\
\9[DashboardPage.Home] = \"rbxassetid://8992031167\",\
\9[DashboardPage.Apps] = \"rbxassetid://8992031246\",\
\9[DashboardPage.Scripts] = \"rbxassetid://8992030918\",\
\9[DashboardPage.Options] = \"rbxassetid://8992031056\",\
}\
return {\
\9DashboardPage = DashboardPage,\
\9PAGE_TO_INDEX = PAGE_TO_INDEX,\
\9PAGE_TO_ICON = PAGE_TO_ICON,\
}\
", '@'.."Orca.store.models.dashboard.model")) setfenv(fn, newEnv("Orca.store.models.dashboard.model")) return fn() end)

newModule("jobs.model", "ModuleScript", "Orca.store.models.jobs.model", "Orca.store.models", function () local fn = assert(loadstring("-- Compiled with roblox-ts v1.2.7\
", '@'.."Orca.store.models.jobs.model")) setfenv(fn, newEnv("Orca.store.models.jobs.model")) return fn() end)

newModule("options.model", "ModuleScript", "Orca.store.models.options.model", "Orca.store.models", function () local fn = assert(loadstring("-- Compiled with roblox-ts v1.2.7\
", '@'.."Orca.store.models.options.model")) setfenv(fn, newEnv("Orca.store.models.options.model")) return fn() end)

newModule("persistent-state", "ModuleScript", "Orca.store.persistent-state", "Orca.store", function () local fn = assert(loadstring("-- Compiled with roblox-ts v1.2.7\
local TS = require(script.Parent.Parent.include.RuntimeLib)\
local _services = TS.import(script, TS.getModule(script, \"@rbxts\", \"services\"))\
local HttpService = _services.HttpService\
local Players = _services.Players\
local getStore = TS.import(script, script.Parent.Parent, \"jobs\", \"helpers\", \"job-store\").getStore\
local setInterval = TS.import(script, script.Parent.Parent, \"utils\", \"timeout\").setInterval\
if makefolder and not isfolder(\"_orca\") then\
\9makefolder(\"_orca\")\
end\
local function read(file)\
\9if readfile then\
\9\9return isfile(file) and readfile(file) or nil\
\9else\
\9\9print(\"READ   \" .. file)\
\9\9return nil\
\9end\
end\
local function write(file, content)\
\9if writefile then\
\9\9return writefile(file, content)\
\9else\
\9\9print(\"WRITE  \" .. (file .. (\" => \\n\" .. content)))\
\9\9return nil\
\9end\
end\
local autosave\
local function persistentState(name, selector, defaultValue)\
\9local _exitType, _returns = TS.try(function()\
\9\9local serializedState = read(\"_orca/\" .. (name .. \".json\"))\
\9\9if serializedState == nil then\
\9\9\9write(\"_orca/\" .. (name .. \".json\"), HttpService:JSONEncode(defaultValue))\
\9\9\9return TS.TRY_RETURN, { defaultValue }\
\9\9end\
\9\9local value = HttpService:JSONDecode(serializedState)\
\9\9autosave(name, selector):catch(function()\
\9\9\9warn(\"Autosave failed\")\
\9\9end)\
\9\9return TS.TRY_RETURN, { value }\
\9end, function(err)\
\9\9warn(\"Failed to load \" .. (name .. (\".json: \" .. tostring(err))))\
\9\9return TS.TRY_RETURN, { defaultValue }\
\9end)\
\9if _exitType then\
\9\9return unpack(_returns)\
\9end\
end\
autosave = TS.async(function(name, selector)\
\9local store = TS.await(getStore())\
\9local function save()\
\9\9local state = selector(store:getState())\
\9\9write(\"_orca/\" .. (name .. \".json\"), HttpService:JSONEncode(state))\
\9end\
\9setInterval(function()\
\9\9return save\
\9end, 60000)\
\9Players.PlayerRemoving:Connect(function(player)\
\9\9if player == Players.LocalPlayer then\
\9\9\9save()\
\9\9end\
\9end)\
end)\
return {\
\9persistentState = persistentState,\
}\
", '@'.."Orca.store.persistent-state")) setfenv(fn, newEnv("Orca.store.persistent-state")) return fn() end)

newInstance("reducers", "Folder", "Orca.store.reducers", "Orca.store")

newModule("dashboard.reducer", "ModuleScript", "Orca.store.reducers.dashboard.reducer", "Orca.store.reducers", function () local fn = assert(loadstring("-- Compiled with roblox-ts v1.2.7\
local TS = require(script.Parent.Parent.Parent.include.RuntimeLib)\
local Rodux = TS.import(script, TS.getModule(script, \"@rbxts\", \"rodux\").src)\
local DashboardPage = TS.import(script, script.Parent.Parent, \"models\", \"dashboard.model\").DashboardPage\
local initialState = {\
\9page = DashboardPage.Home,\
\9isOpen = false,\
\9hint = nil,\
\9apps = {\
\9\9playerSelected = nil,\
\9},\
}\
local dashboardReducer = Rodux.createReducer(initialState, {\
\9[\"dashboard/setDashboardPage\"] = function(state, action)\
\9\9local _object = {}\
\9\9for _k, _v in pairs(state) do\
\9\9\9_object[_k] = _v\
\9\9end\
\9\9_object.page = action.page\
\9\9return _object\
\9end,\
\9[\"dashboard/toggleDashboard\"] = function(state)\
\9\9local _object = {}\
\9\9for _k, _v in pairs(state) do\
\9\9\9_object[_k] = _v\
\9\9end\
\9\9_object.isOpen = not state.isOpen\
\9\9return _object\
\9end,\
\9[\"dashboard/setHint\"] = function(state, action)\
\9\9local _object = {}\
\9\9for _k, _v in pairs(state) do\
\9\9\9_object[_k] = _v\
\9\9end\
\9\9_object.hint = action.hint\
\9\9return _object\
\9end,\
\9[\"dashboard/clearHint\"] = function(state)\
\9\9local _object = {}\
\9\9for _k, _v in pairs(state) do\
\9\9\9_object[_k] = _v\
\9\9end\
\9\9_object.hint = nil\
\9\9return _object\
\9end,\
\9[\"dashboard/playerSelected\"] = function(state, action)\
\9\9local _object = {}\
\9\9for _k, _v in pairs(state) do\
\9\9\9_object[_k] = _v\
\9\9end\
\9\9local _left = \"apps\"\
\9\9local _object_1 = {}\
\9\9for _k, _v in pairs(state.apps) do\
\9\9\9_object_1[_k] = _v\
\9\9end\
\9\9_object_1.playerSelected = action.name\
\9\9_object[_left] = _object_1\
\9\9return _object\
\9end,\
\9[\"dashboard/playerDeselected\"] = function(state)\
\9\9local _object = {}\
\9\9for _k, _v in pairs(state) do\
\9\9\9_object[_k] = _v\
\9\9end\
\9\9local _left = \"apps\"\
\9\9local _object_1 = {}\
\9\9for _k, _v in pairs(state.apps) do\
\9\9\9_object_1[_k] = _v\
\9\9end\
\9\9_object_1.playerSelected = nil\
\9\9_object[_left] = _object_1\
\9\9return _object\
\9end,\
})\
return {\
\9dashboardReducer = dashboardReducer,\
}\
", '@'.."Orca.store.reducers.dashboard.reducer")) setfenv(fn, newEnv("Orca.store.reducers.dashboard.reducer")) return fn() end)

newModule("jobs.reducer", "ModuleScript", "Orca.store.reducers.jobs.reducer", "Orca.store.reducers", function () local fn = assert(loadstring("-- Compiled with roblox-ts v1.2.7\
local TS = require(script.Parent.Parent.Parent.include.RuntimeLib)\
local Rodux = TS.import(script, TS.getModule(script, \"@rbxts\", \"rodux\").src)\
local initialState = {\
\9flight = {\
\9\9value = 60,\
\9\9active = false,\
\9},\
\9walkSpeed = {\
\9\9value = 80,\
\9\9active = false,\
\9},\
\9jumpHeight = {\
\9\9value = 200,\
\9\9active = false,\
\9},\
\9refresh = {\
\9\9active = false,\
\9},\
\9ghost = {\
\9\9active = false,\
\9},\
\9godmode = {\
\9\9active = false,\
\9},\
\9freecam = {\
\9\9active = false,\
\9},\
\9teleport = {\
\9\9active = false,\
\9},\
\9hide = {\
\9\9active = false,\
\9},\
\9kill = {\
\9\9active = false,\
\9},\
\9spectate = {\
\9\9active = false,\
\9},\
\9rejoinServer = {\
\9\9active = false,\
\9},\
\9switchServer = {\
\9\9active = false,\
\9},\
}\
local jobsReducer = Rodux.createReducer(initialState, {\
\9[\"jobs/setJobActive\"] = function(state, action)\
\9\9local _object = {}\
\9\9for _k, _v in pairs(state) do\
\9\9\9_object[_k] = _v\
\9\9end\
\9\9local _left = action.jobName\
\9\9local _object_1 = {}\
\9\9for _k, _v in pairs(state[action.jobName]) do\
\9\9\9_object_1[_k] = _v\
\9\9end\
\9\9_object_1.active = action.active\
\9\9_object[_left] = _object_1\
\9\9return _object\
\9end,\
\9[\"jobs/setJobValue\"] = function(state, action)\
\9\9local _object = {}\
\9\9for _k, _v in pairs(state) do\
\9\9\9_object[_k] = _v\
\9\9end\
\9\9local _left = action.jobName\
\9\9local _object_1 = {}\
\9\9for _k, _v in pairs(state[action.jobName]) do\
\9\9\9_object_1[_k] = _v\
\9\9end\
\9\9_object_1.value = action.value\
\9\9_object[_left] = _object_1\
\9\9return _object\
\9end,\
})\
return {\
\9jobsReducer = jobsReducer,\
}\
", '@'.."Orca.store.reducers.jobs.reducer")) setfenv(fn, newEnv("Orca.store.reducers.jobs.reducer")) return fn() end)

newModule("options.reducer", "ModuleScript", "Orca.store.reducers.options.reducer", "Orca.store.reducers", function () local fn = assert(loadstring("-- Compiled with roblox-ts v1.2.7\
local TS = require(script.Parent.Parent.Parent.include.RuntimeLib)\
local Rodux = TS.import(script, TS.getModule(script, \"@rbxts\", \"rodux\").src)\
local persistentState = TS.import(script, script.Parent.Parent, \"persistent-state\").persistentState\
local initialState = persistentState(\"options\", function(state)\
\9return state.options\
end, {\
\9currentTheme = \"Sorbet\",\
\9config = {\
\9\9acrylicBlur = true,\
\9},\
\9shortcuts = {\
\9\9toggleDashboard = Enum.KeyCode.K.Value,\
\9},\
})\
local optionsReducer = Rodux.createReducer(initialState, {\
\9[\"options/setConfig\"] = function(state, action)\
\9\9local _object = {}\
\9\9for _k, _v in pairs(state) do\
\9\9\9_object[_k] = _v\
\9\9end\
\9\9local _left = \"config\"\
\9\9local _object_1 = {}\
\9\9for _k, _v in pairs(state.config) do\
\9\9\9_object_1[_k] = _v\
\9\9end\
\9\9_object_1[action.name] = action.active\
\9\9_object[_left] = _object_1\
\9\9return _object\
\9end,\
\9[\"options/setTheme\"] = function(state, action)\
\9\9local _object = {}\
\9\9for _k, _v in pairs(state) do\
\9\9\9_object[_k] = _v\
\9\9end\
\9\9_object.currentTheme = action.theme\
\9\9return _object\
\9end,\
\9[\"options/setShortcut\"] = function(state, action)\
\9\9local _object = {}\
\9\9for _k, _v in pairs(state) do\
\9\9\9_object[_k] = _v\
\9\9end\
\9\9local _left = \"shortcuts\"\
\9\9local _object_1 = {}\
\9\9for _k, _v in pairs(state.shortcuts) do\
\9\9\9_object_1[_k] = _v\
\9\9end\
\9\9_object_1[action.shortcut] = action.keycode\
\9\9_object[_left] = _object_1\
\9\9return _object\
\9end,\
\9[\"options/removeShortcut\"] = function(state, action)\
\9\9local _object = {}\
\9\9for _k, _v in pairs(state) do\
\9\9\9_object[_k] = _v\
\9\9end\
\9\9local _left = \"shortcuts\"\
\9\9local _object_1 = {}\
\9\9for _k, _v in pairs(state.shortcuts) do\
\9\9\9_object_1[_k] = _v\
\9\9end\
\9\9_object_1[action.shortcut] = nil\
\9\9_object[_left] = _object_1\
\9\9return _object\
\9end,\
})\
return {\
\9optionsReducer = optionsReducer,\
}\
", '@'.."Orca.store.reducers.options.reducer")) setfenv(fn, newEnv("Orca.store.reducers.options.reducer")) return fn() end)

newModule("store", "ModuleScript", "Orca.store.store", "Orca.store", function () local fn = assert(loadstring("-- Compiled with roblox-ts v1.2.7\
local TS = require(script.Parent.Parent.include.RuntimeLib)\
local Rodux = TS.import(script, TS.getModule(script, \"@rbxts\", \"rodux\").src)\
local dashboardReducer = TS.import(script, script.Parent, \"reducers\", \"dashboard.reducer\").dashboardReducer\
local jobsReducer = TS.import(script, script.Parent, \"reducers\", \"jobs.reducer\").jobsReducer\
local optionsReducer = TS.import(script, script.Parent, \"reducers\", \"options.reducer\").optionsReducer\
local rootReducer = Rodux.combineReducers({\
\9dashboard = dashboardReducer,\
\9jobs = jobsReducer,\
\9options = optionsReducer,\
})\
local function configureStore(initialState)\
\9return Rodux.Store.new(rootReducer, initialState)\
end\
return {\
\9configureStore = configureStore,\
}\
", '@'.."Orca.store.store")) setfenv(fn, newEnv("Orca.store.store")) return fn() end)

newModule("themes", "ModuleScript", "Orca.themes", "Orca", function () local fn = assert(loadstring("-- Compiled with roblox-ts v1.2.7\
local TS = require(script.Parent.include.RuntimeLib)\
local darkTheme = TS.import(script, script, \"dark-theme\").darkTheme\
local frostedGlass = TS.import(script, script, \"frosted-glass\").frostedGlass\
local highContrast = TS.import(script, script, \"high-contrast\").highContrast\
local lightTheme = TS.import(script, script, \"light-theme\").lightTheme\
local obsidian = TS.import(script, script, \"obsidian\").obsidian\
local sorbet = TS.import(script, script, \"sorbet\").sorbet\
local themes = { sorbet, darkTheme, lightTheme, frostedGlass, obsidian, highContrast }\
local function getThemes()\
\9return themes\
end\
return {\
\9getThemes = getThemes,\
}\
", '@'.."Orca.themes")) setfenv(fn, newEnv("Orca.themes")) return fn() end)

newModule("dark-theme", "ModuleScript", "Orca.themes.dark-theme", "Orca.themes", function () local fn = assert(loadstring("-- Compiled with roblox-ts v1.2.7\
local TS = require(script.Parent.Parent.include.RuntimeLib)\
local hex = TS.import(script, script.Parent.Parent, \"utils\", \"color3\").hex\
local darkTheme = {\
\9name = \"Dark theme\",\
\9preview = {\
\9\9foreground = {\
\9\9\9color = ColorSequence.new(hex(\"#ffffff\")),\
\9\9},\
\9\9background = {\
\9\9\9color = ColorSequence.new(hex(\"#232428\")),\
\9\9},\
\9\9accent = {\
\9\9\9color = ColorSequence.new({ ColorSequenceKeypoint.new(0, hex(\"#F6BD29\")), ColorSequenceKeypoint.new(0.5, hex(\"#F64229\")), ColorSequenceKeypoint.new(1, hex(\"#9029F6\")) }),\
\9\9\9rotation = 25,\
\9\9},\
\9},\
\9navbar = {\
\9\9outlined = true,\
\9\9acrylic = false,\
\9\9foreground = hex(\"#ffffff\"),\
\9\9background = hex(\"#232428\"),\
\9\9transparency = 0,\
\9\9accentGradient = {\
\9\9\9color = ColorSequence.new({ ColorSequenceKeypoint.new(0, hex(\"#f629c6\")), ColorSequenceKeypoint.new(0.25, hex(\"#F64229\")), ColorSequenceKeypoint.new(0.5, hex(\"#ffd42a\")), ColorSequenceKeypoint.new(0.75, hex(\"#37CC95\")), ColorSequenceKeypoint.new(1, hex(\"#3789cc\")) }),\
\9\9},\
\9\9dropshadow = hex(\"#232428\"),\
\9\9dropshadowTransparency = 0.3,\
\9\9glowTransparency = 0,\
\9},\
\9clock = {\
\9\9outlined = true,\
\9\9acrylic = false,\
\9\9foreground = hex(\"#ffffff\"),\
\9\9background = hex(\"#232428\"),\
\9\9transparency = 0,\
\9\9dropshadow = hex(\"#232428\"),\
\9\9dropshadowTransparency = 0.3,\
\9},\
\9home = {\
\9\9title = {\
\9\9\9outlined = true,\
\9\9\9acrylic = false,\
\9\9\9foreground = hex(\"#ffffff\"),\
\9\9\9background = hex(\"#ffffff\"),\
\9\9\9backgroundGradient = {\
\9\9\9\9color = ColorSequence.new({ ColorSequenceKeypoint.new(0, hex(\"#F6BD29\")), ColorSequenceKeypoint.new(0.5, hex(\"#F64229\")), ColorSequenceKeypoint.new(1, hex(\"#9029F6\")) }),\
\9\9\9\9rotation = 25,\
\9\9\9},\
\9\9\9transparency = 0,\
\9\9\9dropshadow = hex(\"#ffffff\"),\
\9\9\9dropshadowGradient = {\
\9\9\9\9color = ColorSequence.new({ ColorSequenceKeypoint.new(0, hex(\"#F6BD29\")), ColorSequenceKeypoint.new(0.5, hex(\"#F64229\")), ColorSequenceKeypoint.new(1, hex(\"#9029F6\")) }),\
\9\9\9\9rotation = 25,\
\9\9\9},\
\9\9\9dropshadowTransparency = 0.3,\
\9\9},\
\9\9profile = {\
\9\9\9outlined = true,\
\9\9\9acrylic = false,\
\9\9\9foreground = hex(\"#ffffff\"),\
\9\9\9background = hex(\"#232428\"),\
\9\9\9transparency = 0,\
\9\9\9dropshadow = hex(\"#232428\"),\
\9\9\9dropshadowTransparency = 0.3,\
\9\9\9avatar = {\
\9\9\9\9background = hex(\"#1B1C20\"),\
\9\9\9\9gradient = {\
\9\9\9\9\9color = ColorSequence.new({ ColorSequenceKeypoint.new(0, hex(\"#F6BD29\")), ColorSequenceKeypoint.new(0.5, hex(\"#F64229\")), ColorSequenceKeypoint.new(1, hex(\"#9029F6\")) }),\
\9\9\9\9\9rotation = 25,\
\9\9\9\9},\
\9\9\9\9transparency = 0,\
\9\9\9},\
\9\9\9button = {\
\9\9\9\9outlined = true,\
\9\9\9\9foreground = hex(\"#ffffff\"),\
\9\9\9\9foregroundTransparency = 0.5,\
\9\9\9\9background = hex(\"#1B1C20\"),\
\9\9\9\9backgroundTransparency = 0,\
\9\9\9},\
\9\9\9slider = {\
\9\9\9\9outlined = true,\
\9\9\9\9foreground = hex(\"#ffffff\"),\
\9\9\9\9foregroundTransparency = 0,\
\9\9\9\9background = hex(\"#1B1C20\"),\
\9\9\9\9backgroundTransparency = 0,\
\9\9\9},\
\9\9\9highlight = {\
\9\9\9\9flight = hex(\"#a22df0\"),\
\9\9\9\9walkSpeed = hex(\"#EC423D\"),\
\9\9\9\9jumpHeight = hex(\"#37CC95\"),\
\9\9\9\9refresh = hex(\"#a22df0\"),\
\9\9\9\9ghost = hex(\"#FF4040\"),\
\9\9\9\9godmode = hex(\"#f09c2d\"),\
\9\9\9\9freecam = hex(\"#37CC95\"),\
\9\9\9},\
\9\9},\
\9\9server = {\
\9\9\9outlined = true,\
\9\9\9acrylic = false,\
\9\9\9foreground = hex(\"#ffffff\"),\
\9\9\9background = hex(\"#37CC95\"),\
\9\9\9transparency = 0,\
\9\9\9dropshadow = hex(\"#37CC95\"),\
\9\9\9dropshadowTransparency = 0.3,\
\9\9\9rejoinButton = {\
\9\9\9\9outlined = true,\
\9\9\9\9foreground = hex(\"#ffffff\"),\
\9\9\9\9background = hex(\"#37CC95\"),\
\9\9\9\9accent = hex(\"#232428\"),\
\9\9\9\9foregroundTransparency = 0,\
\9\9\9\9backgroundTransparency = 0,\
\9\9\9},\
\9\9\9switchButton = {\
\9\9\9\9outlined = true,\
\9\9\9\9foreground = hex(\"#ffffff\"),\
\9\9\9\9background = hex(\"#37CC95\"),\
\9\9\9\9accent = hex(\"#232428\"),\
\9\9\9\9foregroundTransparency = 0,\
\9\9\9\9backgroundTransparency = 0,\
\9\9\9},\
\9\9},\
\9\9friendActivity = {\
\9\9\9outlined = true,\
\9\9\9acrylic = false,\
\9\9\9foreground = hex(\"#ffffff\"),\
\9\9\9background = hex(\"#232428\"),\
\9\9\9transparency = 0,\
\9\9\9dropshadow = hex(\"#232428\"),\
\9\9\9dropshadowTransparency = 0.3,\
\9\9\9friendButton = {\
\9\9\9\9outlined = true,\
\9\9\9\9accent = hex(\"#37CC95\"),\
\9\9\9\9foreground = hex(\"#ffffff\"),\
\9\9\9\9foregroundTransparency = 0,\
\9\9\9\9background = hex(\"#1B1C20\"),\
\9\9\9\9backgroundTransparency = 0,\
\9\9\9\9dropshadow = hex(\"#000000\"),\
\9\9\9\9dropshadowTransparency = 0.4,\
\9\9\9\9glowTransparency = 0.6,\
\9\9\9},\
\9\9},\
\9},\
\9apps = {\
\9\9players = {\
\9\9\9outlined = true,\
\9\9\9acrylic = false,\
\9\9\9foreground = hex(\"#ffffff\"),\
\9\9\9background = hex(\"#232428\"),\
\9\9\9transparency = 0,\
\9\9\9dropshadow = hex(\"#232428\"),\
\9\9\9dropshadowTransparency = 0.3,\
\9\9\9avatar = {\
\9\9\9\9background = hex(\"#1B1C20\"),\
\9\9\9\9gradient = {\
\9\9\9\9\9color = ColorSequence.new({ ColorSequenceKeypoint.new(0, hex(\"#37CC95\")), ColorSequenceKeypoint.new(1, hex(\"#37CC95\")) }),\
\9\9\9\9\9rotation = 25,\
\9\9\9\9},\
\9\9\9\9transparency = 0,\
\9\9\9},\
\9\9\9button = {\
\9\9\9\9outlined = true,\
\9\9\9\9foreground = hex(\"#ffffff\"),\
\9\9\9\9foregroundTransparency = 0.5,\
\9\9\9\9background = hex(\"#1B1C20\"),\
\9\9\9\9backgroundTransparency = 0,\
\9\9\9},\
\9\9\9highlight = {\
\9\9\9\9teleport = hex(\"#37CC95\"),\
\9\9\9\9hide = hex(\"#f09c2d\"),\
\9\9\9\9kill = hex(\"#EC423D\"),\
\9\9\9\9spectate = hex(\"#a22df0\"),\
\9\9\9},\
\9\9\9playerButton = {\
\9\9\9\9outlined = true,\
\9\9\9\9accent = hex(\"#37CC95\"),\
\9\9\9\9foreground = hex(\"#ffffff\"),\
\9\9\9\9foregroundTransparency = 0.5,\
\9\9\9\9background = hex(\"#1B1C20\"),\
\9\9\9\9backgroundTransparency = 0,\
\9\9\9\9dropshadow = hex(\"#000000\"),\
\9\9\9\9dropshadowTransparency = 0.5,\
\9\9\9\9glowTransparency = 0.2,\
\9\9\9},\
\9\9},\
\9},\
\9options = {\
\9\9themes = {\
\9\9\9outlined = true,\
\9\9\9acrylic = false,\
\9\9\9foreground = hex(\"#ffffff\"),\
\9\9\9background = hex(\"#232428\"),\
\9\9\9transparency = 0,\
\9\9\9dropshadow = hex(\"#232428\"),\
\9\9\9dropshadowTransparency = 0.3,\
\9\9\9themeButton = {\
\9\9\9\9outlined = true,\
\9\9\9\9accent = hex(\"#37a4cc\"),\
\9\9\9\9foreground = hex(\"#ffffff\"),\
\9\9\9\9foregroundTransparency = 0.5,\
\9\9\9\9background = hex(\"#1B1C20\"),\
\9\9\9\9backgroundTransparency = 0,\
\9\9\9\9dropshadow = hex(\"#000000\"),\
\9\9\9\9dropshadowTransparency = 0.5,\
\9\9\9\9glowTransparency = 0.2,\
\9\9\9},\
\9\9},\
\9\9shortcuts = {\
\9\9\9outlined = true,\
\9\9\9acrylic = false,\
\9\9\9foreground = hex(\"#ffffff\"),\
\9\9\9background = hex(\"#232428\"),\
\9\9\9transparency = 0,\
\9\9\9dropshadow = hex(\"#232428\"),\
\9\9\9dropshadowTransparency = 0.3,\
\9\9\9shortcutButton = {\
\9\9\9\9outlined = true,\
\9\9\9\9accent = hex(\"#37CC95\"),\
\9\9\9\9foreground = hex(\"#ffffff\"),\
\9\9\9\9foregroundTransparency = 0.5,\
\9\9\9\9background = hex(\"#1B1C20\"),\
\9\9\9\9backgroundTransparency = 0,\
\9\9\9\9dropshadow = hex(\"#000000\"),\
\9\9\9\9dropshadowTransparency = 0.5,\
\9\9\9\9glowTransparency = 0.2,\
\9\9\9},\
\9\9},\
\9\9config = {\
\9\9\9outlined = true,\
\9\9\9acrylic = false,\
\9\9\9foreground = hex(\"#ffffff\"),\
\9\9\9background = hex(\"#232428\"),\
\9\9\9transparency = 0,\
\9\9\9dropshadow = hex(\"#232428\"),\
\9\9\9dropshadowTransparency = 0.3,\
\9\9\9configButton = {\
\9\9\9\9outlined = true,\
\9\9\9\9accent = hex(\"#37CC95\"),\
\9\9\9\9foreground = hex(\"#ffffff\"),\
\9\9\9\9foregroundTransparency = 0.5,\
\9\9\9\9background = hex(\"#1B1C20\"),\
\9\9\9\9backgroundTransparency = 0,\
\9\9\9\9dropshadow = hex(\"#000000\"),\
\9\9\9\9dropshadowTransparency = 0.5,\
\9\9\9\9glowTransparency = 0.2,\
\9\9\9},\
\9\9},\
\9},\
}\
return {\
\9darkTheme = darkTheme,\
}\
", '@'.."Orca.themes.dark-theme")) setfenv(fn, newEnv("Orca.themes.dark-theme")) return fn() end)

newModule("frosted-glass", "ModuleScript", "Orca.themes.frosted-glass", "Orca.themes", function () local fn = assert(loadstring("-- Compiled with roblox-ts v1.2.7\
local TS = require(script.Parent.Parent.include.RuntimeLib)\
local darkTheme = TS.import(script, script.Parent, \"dark-theme\").darkTheme\
local hex = TS.import(script, script.Parent.Parent, \"utils\", \"color3\").hex\
local accent = hex(\"#000000\")\
local accentSequence = ColorSequence.new(hex(\"#000000\"))\
local view = {\
\9acrylic = true,\
\9outlined = true,\
\9foreground = hex(\"#ffffff\"),\
\9background = hex(\"#ffffff\"),\
\9backgroundGradient = nil,\
\9transparency = 0.9,\
\9dropshadow = hex(\"#ffffff\"),\
\9dropshadowTransparency = 0,\
\9dropshadowGradient = {\
\9\9color = ColorSequence.new(hex(\"#000000\")),\
\9\9transparency = NumberSequence.new(1, 0.8),\
\9\9rotation = 90,\
\9},\
}\
local _object = {}\
for _k, _v in pairs(darkTheme) do\
\9_object[_k] = _v\
end\
_object.name = \"Frosted glass\"\
_object.preview = {\
\9foreground = {\
\9\9color = ColorSequence.new(hex(\"#ffffff\")),\
\9},\
\9background = {\
\9\9color = ColorSequence.new(hex(\"#ffffff\")),\
\9},\
\9accent = {\
\9\9color = accentSequence,\
\9},\
}\
local _left = \"navbar\"\
local _object_1 = {}\
for _k, _v in pairs(darkTheme.navbar) do\
\9_object_1[_k] = _v\
end\
_object_1.outlined = true\
_object_1.acrylic = true\
_object_1.foreground = hex(\"#ffffff\")\
_object_1.background = hex(\"#ffffff\")\
_object_1.backgroundGradient = nil\
_object_1.transparency = 0.9\
_object_1.dropshadow = hex(\"#000000\")\
_object_1.dropshadowTransparency = 0.2\
_object_1.accentGradient = {\
\9color = ColorSequence.new(hex(\"#ffffff\")),\
\9transparency = NumberSequence.new(0.8),\
\9rotation = 90,\
}\
_object_1.glowTransparency = 0.5\
_object[_left] = _object_1\
_object.clock = {\
\9outlined = true,\
\9acrylic = true,\
\9foreground = hex(\"#ffffff\"),\
\9background = hex(\"#ffffff\"),\
\9backgroundGradient = nil,\
\9transparency = 0.9,\
\9dropshadow = hex(\"#000000\"),\
\9dropshadowTransparency = 0.2,\
}\
local _left_1 = \"home\"\
local _object_2 = {}\
local _left_2 = \"title\"\
local _object_3 = {}\
for _k, _v in pairs(view) do\
\9_object_3[_k] = _v\
end\
_object_2[_left_2] = _object_3\
local _left_3 = \"profile\"\
local _object_4 = {}\
for _k, _v in pairs(view) do\
\9_object_4[_k] = _v\
end\
local _left_4 = \"avatar\"\
local _object_5 = {}\
for _k, _v in pairs(darkTheme.home.profile.avatar) do\
\9_object_5[_k] = _v\
end\
_object_5.background = hex(\"#ffffff\")\
_object_5.transparency = 0.7\
_object_5.gradient = {\
\9color = ColorSequence.new(hex(\"#ffffff\"), hex(\"#ffffff\")),\
\9transparency = NumberSequence.new(0.5, 1),\
\9rotation = 45,\
}\
_object_4[_left_4] = _object_5\
_object_4.highlight = {\
\9flight = accent,\
\9walkSpeed = accent,\
\9jumpHeight = accent,\
\9refresh = accent,\
\9ghost = accent,\
\9godmode = accent,\
\9freecam = accent,\
}\
local _left_5 = \"slider\"\
local _object_6 = {}\
for _k, _v in pairs(darkTheme.home.profile.slider) do\
\9_object_6[_k] = _v\
end\
_object_6.outlined = false\
_object_6.foreground = hex(\"#ffffff\")\
_object_6.background = hex(\"#ffffff\")\
_object_6.backgroundTransparency = 0.8\
_object_6.indicatorTransparency = 0.3\
_object_4[_left_5] = _object_6\
local _left_6 = \"button\"\
local _object_7 = {}\
for _k, _v in pairs(darkTheme.home.profile.button) do\
\9_object_7[_k] = _v\
end\
_object_7.outlined = false\
_object_7.foreground = hex(\"#ffffff\")\
_object_7.background = hex(\"#ffffff\")\
_object_7.backgroundTransparency = 0.8\
_object_4[_left_6] = _object_7\
_object_2[_left_3] = _object_4\
local _left_7 = \"server\"\
local _object_8 = {}\
for _k, _v in pairs(view) do\
\9_object_8[_k] = _v\
end\
local _left_8 = \"rejoinButton\"\
local _object_9 = {}\
for _k, _v in pairs(darkTheme.home.server.rejoinButton) do\
\9_object_9[_k] = _v\
end\
_object_9.outlined = false\
_object_9.foreground = hex(\"#ffffff\")\
_object_9.background = hex(\"#ffffff\")\
_object_9.foregroundTransparency = 0.5\
_object_9.backgroundTransparency = 0.8\
_object_9.accent = accent\
_object_8[_left_8] = _object_9\
local _left_9 = \"switchButton\"\
local _object_10 = {}\
for _k, _v in pairs(darkTheme.home.server.switchButton) do\
\9_object_10[_k] = _v\
end\
_object_10.outlined = false\
_object_10.foreground = hex(\"#ffffff\")\
_object_10.background = hex(\"#ffffff\")\
_object_10.foregroundTransparency = 0.5\
_object_10.backgroundTransparency = 0.8\
_object_10.accent = accent\
_object_8[_left_9] = _object_10\
_object_2[_left_7] = _object_8\
local _left_10 = \"friendActivity\"\
local _object_11 = {}\
for _k, _v in pairs(view) do\
\9_object_11[_k] = _v\
end\
local _left_11 = \"friendButton\"\
local _object_12 = {}\
for _k, _v in pairs(darkTheme.home.friendActivity.friendButton) do\
\9_object_12[_k] = _v\
end\
_object_12.outlined = false\
_object_12.foreground = hex(\"#ffffff\")\
_object_12.background = hex(\"#ffffff\")\
_object_12.dropshadow = hex(\"#ffffff\")\
_object_12.backgroundTransparency = 0.7\
_object_11[_left_11] = _object_12\
_object_2[_left_10] = _object_11\
_object[_left_1] = _object_2\
local _left_12 = \"apps\"\
local _object_13 = {}\
local _left_13 = \"players\"\
local _object_14 = {}\
for _k, _v in pairs(view) do\
\9_object_14[_k] = _v\
end\
_object_14.highlight = {\
\9teleport = accent,\
\9hide = accent,\
\9kill = accent,\
\9spectate = accent,\
}\
local _left_14 = \"avatar\"\
local _object_15 = {}\
for _k, _v in pairs(darkTheme.apps.players.avatar) do\
\9_object_15[_k] = _v\
end\
_object_15.background = hex(\"#ffffff\")\
_object_15.transparency = 0.7\
_object_15.gradient = {\
\9color = ColorSequence.new(hex(\"#ffffff\"), hex(\"#ffffff\")),\
\9transparency = NumberSequence.new(0.5, 1),\
\9rotation = 45,\
}\
_object_14[_left_14] = _object_15\
local _left_15 = \"button\"\
local _object_16 = {}\
for _k, _v in pairs(darkTheme.apps.players.button) do\
\9_object_16[_k] = _v\
end\
_object_16.outlined = false\
_object_16.foreground = hex(\"#ffffff\")\
_object_16.background = hex(\"#ffffff\")\
_object_16.backgroundTransparency = 0.8\
_object_14[_left_15] = _object_16\
local _left_16 = \"playerButton\"\
local _object_17 = {}\
for _k, _v in pairs(darkTheme.apps.players.playerButton) do\
\9_object_17[_k] = _v\
end\
_object_17.outlined = false\
_object_17.foreground = hex(\"#ffffff\")\
_object_17.background = hex(\"#ffffff\")\
_object_17.dropshadow = hex(\"#ffffff\")\
_object_17.accent = accent\
_object_17.backgroundTransparency = 0.8\
_object_17.dropshadowTransparency = 0.7\
_object_14[_left_16] = _object_17\
_object_13[_left_13] = _object_14\
_object[_left_12] = _object_13\
local _left_17 = \"options\"\
local _object_18 = {}\
local _left_18 = \"config\"\
local _object_19 = {}\
for _k, _v in pairs(view) do\
\9_object_19[_k] = _v\
end\
local _left_19 = \"configButton\"\
local _object_20 = {}\
for _k, _v in pairs(darkTheme.options.config.configButton) do\
\9_object_20[_k] = _v\
end\
_object_20.outlined = false\
_object_20.foreground = hex(\"#ffffff\")\
_object_20.background = hex(\"#ffffff\")\
_object_20.dropshadow = hex(\"#ffffff\")\
_object_20.accent = accent\
_object_20.backgroundTransparency = 0.8\
_object_20.dropshadowTransparency = 0.7\
_object_19[_left_19] = _object_20\
_object_18[_left_18] = _object_19\
local _left_20 = \"shortcuts\"\
local _object_21 = {}\
for _k, _v in pairs(view) do\
\9_object_21[_k] = _v\
end\
local _left_21 = \"shortcutButton\"\
local _object_22 = {}\
for _k, _v in pairs(darkTheme.options.shortcuts.shortcutButton) do\
\9_object_22[_k] = _v\
end\
_object_22.outlined = false\
_object_22.foreground = hex(\"#ffffff\")\
_object_22.background = hex(\"#ffffff\")\
_object_22.dropshadow = hex(\"#ffffff\")\
_object_22.accent = accent\
_object_22.backgroundTransparency = 0.8\
_object_22.dropshadowTransparency = 0.7\
_object_21[_left_21] = _object_22\
_object_18[_left_20] = _object_21\
local _left_22 = \"themes\"\
local _object_23 = {}\
for _k, _v in pairs(view) do\
\9_object_23[_k] = _v\
end\
local _left_23 = \"themeButton\"\
local _object_24 = {}\
for _k, _v in pairs(darkTheme.options.themes.themeButton) do\
\9_object_24[_k] = _v\
end\
_object_24.outlined = false\
_object_24.foreground = hex(\"#ffffff\")\
_object_24.background = hex(\"#ffffff\")\
_object_24.dropshadow = hex(\"#ffffff\")\
_object_24.accent = accent\
_object_24.backgroundTransparency = 0.8\
_object_24.dropshadowTransparency = 0.7\
_object_23[_left_23] = _object_24\
_object_18[_left_22] = _object_23\
_object[_left_17] = _object_18\
local frostedGlass = _object\
return {\
\9frostedGlass = frostedGlass,\
}\
", '@'.."Orca.themes.frosted-glass")) setfenv(fn, newEnv("Orca.themes.frosted-glass")) return fn() end)

newModule("high-contrast", "ModuleScript", "Orca.themes.high-contrast", "Orca.themes", function () local fn = assert(loadstring("-- Compiled with roblox-ts v1.2.7\
local TS = require(script.Parent.Parent.include.RuntimeLib)\
local darkTheme = TS.import(script, script.Parent, \"dark-theme\").darkTheme\
local hex = TS.import(script, script.Parent.Parent, \"utils\", \"color3\").hex\
local _object = {}\
for _k, _v in pairs(darkTheme) do\
\9_object[_k] = _v\
end\
_object.name = \"High contrast\"\
_object.preview = {\
\9foreground = {\
\9\9color = ColorSequence.new(hex(\"#ffffff\")),\
\9},\
\9background = {\
\9\9color = ColorSequence.new(hex(\"#000000\")),\
\9},\
\9accent = {\
\9\9color = ColorSequence.new({ ColorSequenceKeypoint.new(0, hex(\"#F6BD29\")), ColorSequenceKeypoint.new(0.5, hex(\"#F64229\")), ColorSequenceKeypoint.new(1, hex(\"#9029F6\")) }),\
\9\9rotation = 25,\
\9},\
}\
local _left = \"navbar\"\
local _object_1 = {}\
for _k, _v in pairs(darkTheme.navbar) do\
\9_object_1[_k] = _v\
end\
_object_1.foreground = hex(\"#ffffff\")\
_object_1.background = hex(\"#000000\")\
_object_1.dropshadow = hex(\"#000000\")\
_object[_left] = _object_1\
local _left_1 = \"clock\"\
local _object_2 = {}\
for _k, _v in pairs(darkTheme.clock) do\
\9_object_2[_k] = _v\
end\
_object_2.foreground = hex(\"#ffffff\")\
_object_2.background = hex(\"#000000\")\
_object_2.dropshadow = hex(\"#000000\")\
_object[_left_1] = _object_2\
local _left_2 = \"home\"\
local _object_3 = {}\
local _left_3 = \"title\"\
local _object_4 = {}\
for _k, _v in pairs(darkTheme.home.title) do\
\9_object_4[_k] = _v\
end\
_object_4.foreground = hex(\"#ffffff\")\
_object_4.background = hex(\"#000000\")\
_object_4.dropshadow = hex(\"#000000\")\
_object_3[_left_3] = _object_4\
local _left_4 = \"profile\"\
local _object_5 = {}\
for _k, _v in pairs(darkTheme.home.profile) do\
\9_object_5[_k] = _v\
end\
_object_5.foreground = hex(\"#ffffff\")\
_object_5.background = hex(\"#000000\")\
_object_5.dropshadow = hex(\"#000000\")\
local _left_5 = \"avatar\"\
local _object_6 = {}\
for _k, _v in pairs(darkTheme.home.profile.avatar) do\
\9_object_6[_k] = _v\
end\
_object_6.background = hex(\"#ffffff\")\
_object_6.transparency = 0.9\
_object_6.gradient = {\
\9color = ColorSequence.new({ ColorSequenceKeypoint.new(0, hex(\"#F6BD29\")), ColorSequenceKeypoint.new(0.5, hex(\"#F64229\")), ColorSequenceKeypoint.new(1, hex(\"#9029F6\")) }),\
}\
_object_5[_left_5] = _object_6\
local _left_6 = \"slider\"\
local _object_7 = {}\
for _k, _v in pairs(darkTheme.home.profile.slider) do\
\9_object_7[_k] = _v\
end\
_object_7.foreground = hex(\"#ffffff\")\
_object_7.background = hex(\"#000000\")\
_object_5[_left_6] = _object_7\
local _left_7 = \"button\"\
local _object_8 = {}\
for _k, _v in pairs(darkTheme.home.profile.button) do\
\9_object_8[_k] = _v\
end\
_object_8.foreground = hex(\"#ffffff\")\
_object_8.background = hex(\"#000000\")\
_object_5[_left_7] = _object_8\
_object_3[_left_4] = _object_5\
local _left_8 = \"server\"\
local _object_9 = {}\
for _k, _v in pairs(darkTheme.home.server) do\
\9_object_9[_k] = _v\
end\
_object_9.foreground = hex(\"#ffffff\")\
_object_9.background = hex(\"#000000\")\
_object_9.dropshadow = hex(\"#000000\")\
local _left_9 = \"rejoinButton\"\
local _object_10 = {}\
for _k, _v in pairs(darkTheme.home.server.rejoinButton) do\
\9_object_10[_k] = _v\
end\
_object_10.foreground = hex(\"#ffffff\")\
_object_10.background = hex(\"#000000\")\
_object_10.foregroundTransparency = 0.5\
_object_10.accent = hex(\"#ff3f6c\")\
_object_9[_left_9] = _object_10\
local _left_10 = \"switchButton\"\
local _object_11 = {}\
for _k, _v in pairs(darkTheme.home.server.switchButton) do\
\9_object_11[_k] = _v\
end\
_object_11.foreground = hex(\"#ffffff\")\
_object_11.background = hex(\"#000000\")\
_object_11.foregroundTransparency = 0.5\
_object_11.accent = hex(\"#ff3f6c\")\
_object_9[_left_10] = _object_11\
_object_3[_left_8] = _object_9\
local _left_11 = \"friendActivity\"\
local _object_12 = {}\
for _k, _v in pairs(darkTheme.home.friendActivity) do\
\9_object_12[_k] = _v\
end\
_object_12.foreground = hex(\"#ffffff\")\
_object_12.background = hex(\"#000000\")\
_object_12.dropshadow = hex(\"#000000\")\
local _left_12 = \"friendButton\"\
local _object_13 = {}\
for _k, _v in pairs(darkTheme.home.friendActivity.friendButton) do\
\9_object_13[_k] = _v\
end\
_object_13.foreground = hex(\"#ffffff\")\
_object_13.background = hex(\"#000000\")\
_object_12[_left_12] = _object_13\
_object_3[_left_11] = _object_12\
_object[_left_2] = _object_3\
local _left_13 = \"apps\"\
local _object_14 = {}\
local _left_14 = \"players\"\
local _object_15 = {}\
for _k, _v in pairs(darkTheme.apps.players) do\
\9_object_15[_k] = _v\
end\
_object_15.foreground = hex(\"#ffffff\")\
_object_15.background = hex(\"#000000\")\
_object_15.dropshadow = hex(\"#000000\")\
local _left_15 = \"avatar\"\
local _object_16 = {}\
for _k, _v in pairs(darkTheme.apps.players.avatar) do\
\9_object_16[_k] = _v\
end\
_object_16.background = hex(\"#ffffff\")\
_object_16.transparency = 0.9\
_object_16.gradient = {\
\9color = ColorSequence.new({ ColorSequenceKeypoint.new(0, hex(\"#F6BD29\")), ColorSequenceKeypoint.new(0.5, hex(\"#F64229\")), ColorSequenceKeypoint.new(1, hex(\"#9029F6\")) }),\
}\
_object_15[_left_15] = _object_16\
local _left_16 = \"button\"\
local _object_17 = {}\
for _k, _v in pairs(darkTheme.apps.players.button) do\
\9_object_17[_k] = _v\
end\
_object_17.foreground = hex(\"#ffffff\")\
_object_17.background = hex(\"#000000\")\
_object_15[_left_16] = _object_17\
local _left_17 = \"playerButton\"\
local _object_18 = {}\
for _k, _v in pairs(darkTheme.apps.players.playerButton) do\
\9_object_18[_k] = _v\
end\
_object_18.foreground = hex(\"#ffffff\")\
_object_18.background = hex(\"#000000\")\
_object_18.accent = hex(\"#ff3f6c\")\
_object_18.dropshadowTransparency = 0.7\
_object_15[_left_17] = _object_18\
_object_14[_left_14] = _object_15\
_object[_left_13] = _object_14\
local _left_18 = \"options\"\
local _object_19 = {}\
local _left_19 = \"config\"\
local _object_20 = {}\
for _k, _v in pairs(darkTheme.options.config) do\
\9_object_20[_k] = _v\
end\
_object_20.foreground = hex(\"#ffffff\")\
_object_20.background = hex(\"#000000\")\
_object_20.dropshadow = hex(\"#000000\")\
local _left_20 = \"configButton\"\
local _object_21 = {}\
for _k, _v in pairs(darkTheme.options.config.configButton) do\
\9_object_21[_k] = _v\
end\
_object_21.foreground = hex(\"#ffffff\")\
_object_21.background = hex(\"#000000\")\
_object_21.accent = hex(\"#ff3f6c\")\
_object_21.dropshadowTransparency = 0.7\
_object_20[_left_20] = _object_21\
_object_19[_left_19] = _object_20\
local _left_21 = \"shortcuts\"\
local _object_22 = {}\
for _k, _v in pairs(darkTheme.options.shortcuts) do\
\9_object_22[_k] = _v\
end\
_object_22.foreground = hex(\"#ffffff\")\
_object_22.background = hex(\"#000000\")\
_object_22.dropshadow = hex(\"#000000\")\
local _left_22 = \"shortcutButton\"\
local _object_23 = {}\
for _k, _v in pairs(darkTheme.options.shortcuts.shortcutButton) do\
\9_object_23[_k] = _v\
end\
_object_23.foreground = hex(\"#ffffff\")\
_object_23.background = hex(\"#000000\")\
_object_23.accent = hex(\"#ff3f6c\")\
_object_23.dropshadowTransparency = 0.7\
_object_22[_left_22] = _object_23\
_object_19[_left_21] = _object_22\
local _left_23 = \"themes\"\
local _object_24 = {}\
for _k, _v in pairs(darkTheme.options.themes) do\
\9_object_24[_k] = _v\
end\
_object_24.foreground = hex(\"#ffffff\")\
_object_24.background = hex(\"#000000\")\
_object_24.dropshadow = hex(\"#000000\")\
local _left_24 = \"themeButton\"\
local _object_25 = {}\
for _k, _v in pairs(darkTheme.options.themes.themeButton) do\
\9_object_25[_k] = _v\
end\
_object_25.foreground = hex(\"#ffffff\")\
_object_25.background = hex(\"#000000\")\
_object_25.accent = hex(\"#ff3f6c\")\
_object_25.dropshadowTransparency = 0.7\
_object_24[_left_24] = _object_25\
_object_19[_left_23] = _object_24\
_object[_left_18] = _object_19\
local highContrast = _object\
return {\
\9highContrast = highContrast,\
}\
", '@'.."Orca.themes.high-contrast")) setfenv(fn, newEnv("Orca.themes.high-contrast")) return fn() end)

newModule("light-theme", "ModuleScript", "Orca.themes.light-theme", "Orca.themes", function () local fn = assert(loadstring("-- Compiled with roblox-ts v1.2.7\
local TS = require(script.Parent.Parent.include.RuntimeLib)\
local darkTheme = TS.import(script, script.Parent, \"dark-theme\").darkTheme\
local hex = TS.import(script, script.Parent.Parent, \"utils\", \"color3\").hex\
local _object = {}\
for _k, _v in pairs(darkTheme) do\
\9_object[_k] = _v\
end\
_object.name = \"Light theme\"\
_object.preview = {\
\9foreground = {\
\9\9color = ColorSequence.new(hex(\"#000000\")),\
\9},\
\9background = {\
\9\9color = ColorSequence.new(hex(\"#ffffff\")),\
\9},\
\9accent = {\
\9\9color = ColorSequence.new({ ColorSequenceKeypoint.new(0, hex(\"#F6BD29\")), ColorSequenceKeypoint.new(0.5, hex(\"#F64229\")), ColorSequenceKeypoint.new(1, hex(\"#9029F6\")) }),\
\9\9rotation = 25,\
\9},\
}\
local _left = \"navbar\"\
local _object_1 = {}\
for _k, _v in pairs(darkTheme.navbar) do\
\9_object_1[_k] = _v\
end\
_object_1.foreground = hex(\"#000000\")\
_object_1.background = hex(\"#ffffff\")\
_object[_left] = _object_1\
local _left_1 = \"clock\"\
local _object_2 = {}\
for _k, _v in pairs(darkTheme.clock) do\
\9_object_2[_k] = _v\
end\
_object_2.foreground = hex(\"#000000\")\
_object_2.background = hex(\"#ffffff\")\
_object[_left_1] = _object_2\
local _left_2 = \"home\"\
local _object_3 = {}\
local _left_3 = \"title\"\
local _object_4 = {}\
for _k, _v in pairs(darkTheme.home.title) do\
\9_object_4[_k] = _v\
end\
_object_4.foreground = hex(\"#000000\")\
_object_4.background = hex(\"#ffffff\")\
_object_3[_left_3] = _object_4\
local _left_4 = \"profile\"\
local _object_5 = {}\
for _k, _v in pairs(darkTheme.home.profile) do\
\9_object_5[_k] = _v\
end\
_object_5.foreground = hex(\"#000000\")\
_object_5.background = hex(\"#ffffff\")\
local _left_5 = \"avatar\"\
local _object_6 = {}\
for _k, _v in pairs(darkTheme.home.profile.avatar) do\
\9_object_6[_k] = _v\
end\
_object_6.background = hex(\"#000000\")\
_object_6.transparency = 0.9\
_object_6.gradient = {\
\9color = ColorSequence.new(hex(\"#3ce09b\")),\
}\
_object_5[_left_5] = _object_6\
local _left_6 = \"slider\"\
local _object_7 = {}\
for _k, _v in pairs(darkTheme.home.profile.slider) do\
\9_object_7[_k] = _v\
end\
_object_7.foreground = hex(\"#000000\")\
_object_7.background = hex(\"#ffffff\")\
_object_5[_left_6] = _object_7\
local _left_7 = \"button\"\
local _object_8 = {}\
for _k, _v in pairs(darkTheme.home.profile.button) do\
\9_object_8[_k] = _v\
end\
_object_8.foreground = hex(\"#000000\")\
_object_8.background = hex(\"#ffffff\")\
_object_5[_left_7] = _object_8\
_object_3[_left_4] = _object_5\
local _left_8 = \"server\"\
local _object_9 = {}\
for _k, _v in pairs(darkTheme.home.server) do\
\9_object_9[_k] = _v\
end\
_object_9.foreground = hex(\"#000000\")\
_object_9.background = hex(\"#ff3f6c\")\
_object_9.dropshadow = hex(\"#ff3f6c\")\
local _left_9 = \"rejoinButton\"\
local _object_10 = {}\
for _k, _v in pairs(darkTheme.home.server.rejoinButton) do\
\9_object_10[_k] = _v\
end\
_object_10.foreground = hex(\"#000000\")\
_object_10.background = hex(\"#ff3f6c\")\
_object_10.accent = hex(\"#ffffff\")\
_object_9[_left_9] = _object_10\
local _left_10 = \"switchButton\"\
local _object_11 = {}\
for _k, _v in pairs(darkTheme.home.server.switchButton) do\
\9_object_11[_k] = _v\
end\
_object_11.foreground = hex(\"#000000\")\
_object_11.background = hex(\"#ff3f6c\")\
_object_11.accent = hex(\"#ffffff\")\
_object_9[_left_10] = _object_11\
_object_3[_left_8] = _object_9\
local _left_11 = \"friendActivity\"\
local _object_12 = {}\
for _k, _v in pairs(darkTheme.home.friendActivity) do\
\9_object_12[_k] = _v\
end\
_object_12.foreground = hex(\"#000000\")\
_object_12.background = hex(\"#ffffff\")\
local _left_12 = \"friendButton\"\
local _object_13 = {}\
for _k, _v in pairs(darkTheme.home.friendActivity.friendButton) do\
\9_object_13[_k] = _v\
end\
_object_13.foreground = hex(\"#ffffff\")\
_object_13.background = hex(\"#ffffff\")\
_object_12[_left_12] = _object_13\
_object_3[_left_11] = _object_12\
_object[_left_2] = _object_3\
local _left_13 = \"apps\"\
local _object_14 = {}\
local _left_14 = \"players\"\
local _object_15 = {}\
for _k, _v in pairs(darkTheme.apps.players) do\
\9_object_15[_k] = _v\
end\
_object_15.foreground = hex(\"#000000\")\
_object_15.background = hex(\"#ffffff\")\
local _left_15 = \"avatar\"\
local _object_16 = {}\
for _k, _v in pairs(darkTheme.apps.players.avatar) do\
\9_object_16[_k] = _v\
end\
_object_16.background = hex(\"#000000\")\
_object_16.transparency = 0.9\
_object_16.gradient = {\
\9color = ColorSequence.new(hex(\"#3ce09b\")),\
}\
_object_15[_left_15] = _object_16\
local _left_16 = \"button\"\
local _object_17 = {}\
for _k, _v in pairs(darkTheme.apps.players.button) do\
\9_object_17[_k] = _v\
end\
_object_17.foreground = hex(\"#000000\")\
_object_17.background = hex(\"#ffffff\")\
_object_15[_left_16] = _object_17\
local _left_17 = \"playerButton\"\
local _object_18 = {}\
for _k, _v in pairs(darkTheme.apps.players.playerButton) do\
\9_object_18[_k] = _v\
end\
_object_18.foreground = hex(\"#000000\")\
_object_18.background = hex(\"#ffffff\")\
_object_18.backgroundHovered = hex(\"#eeeeee\")\
_object_18.accent = hex(\"#3ce09b\")\
_object_18.dropshadowTransparency = 0.7\
_object_15[_left_17] = _object_18\
_object_14[_left_14] = _object_15\
_object[_left_13] = _object_14\
local _left_18 = \"options\"\
local _object_19 = {}\
local _left_19 = \"config\"\
local _object_20 = {}\
for _k, _v in pairs(darkTheme.options.config) do\
\9_object_20[_k] = _v\
end\
_object_20.foreground = hex(\"#000000\")\
_object_20.background = hex(\"#ffffff\")\
local _left_20 = \"configButton\"\
local _object_21 = {}\
for _k, _v in pairs(darkTheme.options.config.configButton) do\
\9_object_21[_k] = _v\
end\
_object_21.foreground = hex(\"#000000\")\
_object_21.background = hex(\"#ffffff\")\
_object_21.backgroundHovered = hex(\"#eeeeee\")\
_object_21.accent = hex(\"#3ce09b\")\
_object_21.dropshadowTransparency = 0.7\
_object_20[_left_20] = _object_21\
_object_19[_left_19] = _object_20\
local _left_21 = \"shortcuts\"\
local _object_22 = {}\
for _k, _v in pairs(darkTheme.options.shortcuts) do\
\9_object_22[_k] = _v\
end\
_object_22.foreground = hex(\"#000000\")\
_object_22.background = hex(\"#ffffff\")\
local _left_22 = \"shortcutButton\"\
local _object_23 = {}\
for _k, _v in pairs(darkTheme.options.shortcuts.shortcutButton) do\
\9_object_23[_k] = _v\
end\
_object_23.foreground = hex(\"#000000\")\
_object_23.background = hex(\"#ffffff\")\
_object_23.backgroundHovered = hex(\"#eeeeee\")\
_object_23.accent = hex(\"#3ce09b\")\
_object_23.dropshadowTransparency = 0.7\
_object_22[_left_22] = _object_23\
_object_19[_left_21] = _object_22\
local _left_23 = \"themes\"\
local _object_24 = {}\
for _k, _v in pairs(darkTheme.options.themes) do\
\9_object_24[_k] = _v\
end\
_object_24.foreground = hex(\"#000000\")\
_object_24.background = hex(\"#ffffff\")\
local _left_24 = \"themeButton\"\
local _object_25 = {}\
for _k, _v in pairs(darkTheme.options.themes.themeButton) do\
\9_object_25[_k] = _v\
end\
_object_25.foreground = hex(\"#000000\")\
_object_25.background = hex(\"#ffffff\")\
_object_25.backgroundHovered = hex(\"#eeeeee\")\
_object_25.accent = hex(\"#3ce09b\")\
_object_25.dropshadowTransparency = 0.7\
_object_24[_left_24] = _object_25\
_object_19[_left_23] = _object_24\
_object[_left_18] = _object_19\
local lightTheme = _object\
return {\
\9lightTheme = lightTheme,\
}\
", '@'.."Orca.themes.light-theme")) setfenv(fn, newEnv("Orca.themes.light-theme")) return fn() end)

newModule("obsidian", "ModuleScript", "Orca.themes.obsidian", "Orca.themes", function () local fn = assert(loadstring("-- Compiled with roblox-ts v1.2.7\
local TS = require(script.Parent.Parent.include.RuntimeLib)\
local darkTheme = TS.import(script, script.Parent, \"dark-theme\").darkTheme\
local hex = TS.import(script, script.Parent.Parent, \"utils\", \"color3\").hex\
local accent = hex(\"#9029F6\")\
local accentSequence = ColorSequence.new(hex(\"#9029F6\"))\
local _object = {}\
for _k, _v in pairs(darkTheme) do\
\9_object[_k] = _v\
end\
_object.name = \"Obsidian\"\
_object.preview = {\
\9foreground = {\
\9\9color = ColorSequence.new(hex(\"#ffffff\")),\
\9},\
\9background = {\
\9\9color = ColorSequence.new(hex(\"#000000\")),\
\9},\
\9accent = {\
\9\9color = accentSequence,\
\9},\
}\
local _left = \"navbar\"\
local _object_1 = {}\
for _k, _v in pairs(darkTheme.navbar) do\
\9_object_1[_k] = _v\
end\
_object_1.acrylic = true\
_object_1.outlined = false\
_object_1.foreground = hex(\"#ffffff\")\
_object_1.background = hex(\"#000000\")\
_object_1.dropshadow = hex(\"#000000\")\
_object_1.transparency = 0.7\
_object_1.accentGradient = {\
\9color = accentSequence,\
\9transparency = NumberSequence.new(0.5),\
}\
_object[_left] = _object_1\
local _left_1 = \"clock\"\
local _object_2 = {}\
for _k, _v in pairs(darkTheme.clock) do\
\9_object_2[_k] = _v\
end\
_object_2.acrylic = true\
_object_2.outlined = false\
_object_2.foreground = hex(\"#ffffff\")\
_object_2.background = hex(\"#000000\")\
_object_2.dropshadow = hex(\"#000000\")\
_object_2.transparency = 0.7\
_object[_left_1] = _object_2\
local _left_2 = \"home\"\
local _object_3 = {}\
local _left_3 = \"title\"\
local _object_4 = {}\
for _k, _v in pairs(darkTheme.home.title) do\
\9_object_4[_k] = _v\
end\
_object_4.acrylic = true\
_object_4.outlined = false\
_object_4.foreground = hex(\"#ffffff\")\
_object_4.background = hex(\"#000000\")\
_object_4.dropshadow = hex(\"#000000\")\
_object_4.transparency = 0.7\
_object_4.dropshadowTransparency = 0.65\
_object_3[_left_3] = _object_4\
local _left_4 = \"profile\"\
local _object_5 = {}\
for _k, _v in pairs(darkTheme.home.profile) do\
\9_object_5[_k] = _v\
end\
_object_5.acrylic = true\
_object_5.outlined = false\
_object_5.foreground = hex(\"#ffffff\")\
_object_5.background = hex(\"#000000\")\
_object_5.dropshadow = hex(\"#000000\")\
_object_5.transparency = 0.7\
_object_5.dropshadowTransparency = 0.65\
local _left_5 = \"avatar\"\
local _object_6 = {}\
for _k, _v in pairs(darkTheme.home.profile.avatar) do\
\9_object_6[_k] = _v\
end\
_object_6.background = hex(\"#000000\")\
_object_6.transparency = 0.7\
_object_6.gradient = {\
\9color = accentSequence,\
}\
_object_5[_left_5] = _object_6\
_object_5.highlight = {\
\9flight = accent,\
\9walkSpeed = accent,\
\9jumpHeight = accent,\
\9refresh = accent,\
\9ghost = accent,\
\9godmode = accent,\
\9freecam = accent,\
}\
local _left_6 = \"slider\"\
local _object_7 = {}\
for _k, _v in pairs(darkTheme.home.profile.slider) do\
\9_object_7[_k] = _v\
end\
_object_7.outlined = false\
_object_7.foreground = hex(\"#ffffff\")\
_object_7.background = hex(\"#000000\")\
_object_7.backgroundTransparency = 0.5\
_object_7.indicatorTransparency = 0.5\
_object_5[_left_6] = _object_7\
local _left_7 = \"button\"\
local _object_8 = {}\
for _k, _v in pairs(darkTheme.home.profile.button) do\
\9_object_8[_k] = _v\
end\
_object_8.outlined = false\
_object_8.foreground = hex(\"#ffffff\")\
_object_8.background = hex(\"#000000\")\
_object_8.backgroundTransparency = 0.5\
_object_5[_left_7] = _object_8\
_object_3[_left_4] = _object_5\
local _left_8 = \"server\"\
local _object_9 = {}\
for _k, _v in pairs(darkTheme.home.server) do\
\9_object_9[_k] = _v\
end\
_object_9.acrylic = true\
_object_9.outlined = false\
_object_9.foreground = hex(\"#ffffff\")\
_object_9.background = hex(\"#000000\")\
_object_9.dropshadow = hex(\"#000000\")\
_object_9.transparency = 0.7\
_object_9.dropshadowTransparency = 0.65\
local _left_9 = \"rejoinButton\"\
local _object_10 = {}\
for _k, _v in pairs(darkTheme.home.server.rejoinButton) do\
\9_object_10[_k] = _v\
end\
_object_10.outlined = false\
_object_10.foreground = hex(\"#ffffff\")\
_object_10.background = hex(\"#000000\")\
_object_10.backgroundTransparency = 0.5\
_object_10.foregroundTransparency = 0.5\
_object_10.accent = accent\
_object_9[_left_9] = _object_10\
local _left_10 = \"switchButton\"\
local _object_11 = {}\
for _k, _v in pairs(darkTheme.home.server.switchButton) do\
\9_object_11[_k] = _v\
end\
_object_11.outlined = false\
_object_11.foreground = hex(\"#ffffff\")\
_object_11.background = hex(\"#000000\")\
_object_11.backgroundTransparency = 0.5\
_object_11.foregroundTransparency = 0.5\
_object_11.accent = accent\
_object_9[_left_10] = _object_11\
_object_3[_left_8] = _object_9\
local _left_11 = \"friendActivity\"\
local _object_12 = {}\
for _k, _v in pairs(darkTheme.home.friendActivity) do\
\9_object_12[_k] = _v\
end\
_object_12.acrylic = true\
_object_12.outlined = false\
_object_12.foreground = hex(\"#ffffff\")\
_object_12.background = hex(\"#000000\")\
_object_12.dropshadow = hex(\"#000000\")\
_object_12.transparency = 0.7\
_object_12.dropshadowTransparency = 0.65\
local _left_12 = \"friendButton\"\
local _object_13 = {}\
for _k, _v in pairs(darkTheme.home.friendActivity.friendButton) do\
\9_object_13[_k] = _v\
end\
_object_13.outlined = false\
_object_13.foreground = hex(\"#ffffff\")\
_object_13.background = hex(\"#000000\")\
_object_13.dropshadow = hex(\"#000000\")\
_object_13.backgroundTransparency = 0.7\
_object_12[_left_12] = _object_13\
_object_3[_left_11] = _object_12\
_object[_left_2] = _object_3\
local _left_13 = \"apps\"\
local _object_14 = {}\
local _left_14 = \"players\"\
local _object_15 = {}\
for _k, _v in pairs(darkTheme.apps.players) do\
\9_object_15[_k] = _v\
end\
_object_15.acrylic = true\
_object_15.outlined = false\
_object_15.foreground = hex(\"#ffffff\")\
_object_15.background = hex(\"#000000\")\
_object_15.dropshadow = hex(\"#000000\")\
_object_15.transparency = 0.7\
_object_15.dropshadowTransparency = 0.65\
_object_15.highlight = {\
\9teleport = accent,\
\9hide = accent,\
\9kill = accent,\
\9spectate = accent,\
}\
local _left_15 = \"avatar\"\
local _object_16 = {}\
for _k, _v in pairs(darkTheme.apps.players.avatar) do\
\9_object_16[_k] = _v\
end\
_object_16.background = hex(\"#000000\")\
_object_16.transparency = 0.7\
_object_16.gradient = {\
\9color = accentSequence,\
}\
_object_15[_left_15] = _object_16\
local _left_16 = \"button\"\
local _object_17 = {}\
for _k, _v in pairs(darkTheme.apps.players.button) do\
\9_object_17[_k] = _v\
end\
_object_17.outlined = false\
_object_17.foreground = hex(\"#ffffff\")\
_object_17.background = hex(\"#000000\")\
_object_17.backgroundTransparency = 0.5\
_object_15[_left_16] = _object_17\
local _left_17 = \"playerButton\"\
local _object_18 = {}\
for _k, _v in pairs(darkTheme.apps.players.playerButton) do\
\9_object_18[_k] = _v\
end\
_object_18.outlined = false\
_object_18.foreground = hex(\"#ffffff\")\
_object_18.background = hex(\"#000000\")\
_object_18.accent = accent\
_object_18.backgroundTransparency = 0.5\
_object_18.dropshadowTransparency = 0.7\
_object_15[_left_17] = _object_18\
_object_14[_left_14] = _object_15\
_object[_left_13] = _object_14\
local _left_18 = \"options\"\
local _object_19 = {}\
local _left_19 = \"config\"\
local _object_20 = {}\
for _k, _v in pairs(darkTheme.options.config) do\
\9_object_20[_k] = _v\
end\
_object_20.acrylic = true\
_object_20.outlined = false\
_object_20.foreground = hex(\"#ffffff\")\
_object_20.background = hex(\"#000000\")\
_object_20.dropshadow = hex(\"#000000\")\
_object_20.transparency = 0.7\
_object_20.dropshadowTransparency = 0.65\
local _left_20 = \"configButton\"\
local _object_21 = {}\
for _k, _v in pairs(darkTheme.options.config.configButton) do\
\9_object_21[_k] = _v\
end\
_object_21.outlined = false\
_object_21.foreground = hex(\"#ffffff\")\
_object_21.background = hex(\"#000000\")\
_object_21.accent = accent\
_object_21.backgroundTransparency = 0.5\
_object_21.dropshadowTransparency = 0.7\
_object_20[_left_20] = _object_21\
_object_19[_left_19] = _object_20\
local _left_21 = \"shortcuts\"\
local _object_22 = {}\
for _k, _v in pairs(darkTheme.options.shortcuts) do\
\9_object_22[_k] = _v\
end\
_object_22.acrylic = true\
_object_22.outlined = false\
_object_22.foreground = hex(\"#ffffff\")\
_object_22.background = hex(\"#000000\")\
_object_22.dropshadow = hex(\"#000000\")\
_object_22.transparency = 0.7\
_object_22.dropshadowTransparency = 0.65\
local _left_22 = \"shortcutButton\"\
local _object_23 = {}\
for _k, _v in pairs(darkTheme.options.shortcuts.shortcutButton) do\
\9_object_23[_k] = _v\
end\
_object_23.outlined = false\
_object_23.foreground = hex(\"#ffffff\")\
_object_23.background = hex(\"#000000\")\
_object_23.accent = accent\
_object_23.backgroundTransparency = 0.5\
_object_23.dropshadowTransparency = 0.7\
_object_22[_left_22] = _object_23\
_object_19[_left_21] = _object_22\
local _left_23 = \"themes\"\
local _object_24 = {}\
for _k, _v in pairs(darkTheme.options.themes) do\
\9_object_24[_k] = _v\
end\
_object_24.acrylic = true\
_object_24.outlined = false\
_object_24.foreground = hex(\"#ffffff\")\
_object_24.background = hex(\"#000000\")\
_object_24.dropshadow = hex(\"#000000\")\
_object_24.transparency = 0.7\
_object_24.dropshadowTransparency = 0.65\
local _left_24 = \"themeButton\"\
local _object_25 = {}\
for _k, _v in pairs(darkTheme.options.themes.themeButton) do\
\9_object_25[_k] = _v\
end\
_object_25.outlined = false\
_object_25.foreground = hex(\"#ffffff\")\
_object_25.background = hex(\"#000000\")\
_object_25.accent = accent\
_object_25.backgroundTransparency = 0.5\
_object_25.dropshadowTransparency = 0.7\
_object_24[_left_24] = _object_25\
_object_19[_left_23] = _object_24\
_object[_left_18] = _object_19\
local obsidian = _object\
return {\
\9obsidian = obsidian,\
}\
", '@'.."Orca.themes.obsidian")) setfenv(fn, newEnv("Orca.themes.obsidian")) return fn() end)

newModule("sorbet", "ModuleScript", "Orca.themes.sorbet", "Orca.themes", function () local fn = assert(loadstring("-- Compiled with roblox-ts v1.2.7\
local TS = require(script.Parent.Parent.include.RuntimeLib)\
local darkTheme = TS.import(script, script.Parent, \"dark-theme\").darkTheme\
local hex = TS.import(script, script.Parent.Parent, \"utils\", \"color3\").hex\
local redAccent = hex(\"#C6428E\")\
local blueAccent = hex(\"#484fd7\")\
local mixedAccent = hex(\"#9a3fe5\")\
local accentSequence = ColorSequence.new({ ColorSequenceKeypoint.new(0, redAccent), ColorSequenceKeypoint.new(0.5, mixedAccent), ColorSequenceKeypoint.new(1, blueAccent) })\
local background = hex(\"#181818\")\
local backgroundDark = hex(\"#242424\")\
local view = {\
\9acrylic = false,\
\9outlined = false,\
\9foreground = hex(\"#ffffff\"),\
\9background = background,\
\9backgroundGradient = nil,\
\9transparency = 0,\
\9dropshadow = background,\
\9dropshadowTransparency = 0.3,\
}\
local _object = {}\
for _k, _v in pairs(darkTheme) do\
\9_object[_k] = _v\
end\
_object.name = \"Sorbet\"\
_object.preview = {\
\9foreground = {\
\9\9color = ColorSequence.new(hex(\"#ffffff\")),\
\9},\
\9background = {\
\9\9color = ColorSequence.new(background),\
\9},\
\9accent = {\
\9\9color = accentSequence,\
\9},\
}\
local _left = \"navbar\"\
local _object_1 = {}\
for _k, _v in pairs(darkTheme.navbar) do\
\9_object_1[_k] = _v\
end\
_object_1.outlined = false\
_object_1.background = background\
_object_1.dropshadow = background\
_object_1.accentGradient = {\
\9color = accentSequence,\
}\
_object[_left] = _object_1\
local _left_1 = \"clock\"\
local _object_2 = {}\
for _k, _v in pairs(darkTheme.clock) do\
\9_object_2[_k] = _v\
end\
_object_2.outlined = false\
_object_2.background = background\
_object_2.dropshadow = background\
_object[_left_1] = _object_2\
local _left_2 = \"home\"\
local _object_3 = {}\
local _left_3 = \"title\"\
local _object_4 = {}\
for _k, _v in pairs(view) do\
\9_object_4[_k] = _v\
end\
_object_4.background = hex(\"#ffffff\")\
_object_4.backgroundGradient = {\
\9color = accentSequence,\
\9rotation = 30,\
}\
_object_4.dropshadow = hex(\"#ffffff\")\
_object_4.dropshadowGradient = {\
\9color = accentSequence,\
\9rotation = 30,\
}\
_object_3[_left_3] = _object_4\
local _left_4 = \"profile\"\
local _object_5 = {}\
for _k, _v in pairs(view) do\
\9_object_5[_k] = _v\
end\
local _left_5 = \"avatar\"\
local _object_6 = {}\
for _k, _v in pairs(darkTheme.home.profile.avatar) do\
\9_object_6[_k] = _v\
end\
_object_6.background = backgroundDark\
_object_6.transparency = 0\
_object_6.gradient = {\
\9color = accentSequence,\
\9rotation = 45,\
}\
_object_5[_left_5] = _object_6\
_object_5.highlight = {\
\9flight = redAccent,\
\9walkSpeed = mixedAccent,\
\9jumpHeight = blueAccent,\
\9refresh = redAccent,\
\9ghost = blueAccent,\
\9godmode = redAccent,\
\9freecam = blueAccent,\
}\
local _left_6 = \"slider\"\
local _object_7 = {}\
for _k, _v in pairs(darkTheme.home.profile.slider) do\
\9_object_7[_k] = _v\
end\
_object_7.outlined = false\
_object_7.foreground = hex(\"#ffffff\")\
_object_7.background = backgroundDark\
_object_5[_left_6] = _object_7\
local _left_7 = \"button\"\
local _object_8 = {}\
for _k, _v in pairs(darkTheme.home.profile.button) do\
\9_object_8[_k] = _v\
end\
_object_8.outlined = false\
_object_8.foreground = hex(\"#ffffff\")\
_object_8.background = backgroundDark\
_object_5[_left_7] = _object_8\
_object_3[_left_4] = _object_5\
local _left_8 = \"server\"\
local _object_9 = {}\
for _k, _v in pairs(view) do\
\9_object_9[_k] = _v\
end\
local _left_9 = \"rejoinButton\"\
local _object_10 = {}\
for _k, _v in pairs(darkTheme.home.server.rejoinButton) do\
\9_object_10[_k] = _v\
end\
_object_10.outlined = false\
_object_10.foreground = hex(\"#ffffff\")\
_object_10.background = backgroundDark\
_object_10.foregroundTransparency = 0.5\
_object_10.accent = redAccent\
_object_9[_left_9] = _object_10\
local _left_10 = \"switchButton\"\
local _object_11 = {}\
for _k, _v in pairs(darkTheme.home.server.switchButton) do\
\9_object_11[_k] = _v\
end\
_object_11.outlined = false\
_object_11.foreground = hex(\"#ffffff\")\
_object_11.background = backgroundDark\
_object_11.foregroundTransparency = 0.5\
_object_11.accent = blueAccent\
_object_9[_left_10] = _object_11\
_object_3[_left_8] = _object_9\
local _left_11 = \"friendActivity\"\
local _object_12 = {}\
for _k, _v in pairs(view) do\
\9_object_12[_k] = _v\
end\
local _left_12 = \"friendButton\"\
local _object_13 = {}\
for _k, _v in pairs(darkTheme.home.friendActivity.friendButton) do\
\9_object_13[_k] = _v\
end\
_object_13.outlined = false\
_object_13.foreground = hex(\"#ffffff\")\
_object_13.background = backgroundDark\
_object_12[_left_12] = _object_13\
_object_3[_left_11] = _object_12\
_object[_left_2] = _object_3\
local _left_13 = \"apps\"\
local _object_14 = {}\
local _left_14 = \"players\"\
local _object_15 = {}\
for _k, _v in pairs(view) do\
\9_object_15[_k] = _v\
end\
_object_15.highlight = {\
\9teleport = redAccent,\
\9hide = blueAccent,\
\9kill = redAccent,\
\9spectate = blueAccent,\
}\
local _left_15 = \"avatar\"\
local _object_16 = {}\
for _k, _v in pairs(darkTheme.apps.players.avatar) do\
\9_object_16[_k] = _v\
end\
_object_16.background = backgroundDark\
_object_16.transparency = 0\
_object_16.gradient = {\
\9color = accentSequence,\
\9rotation = 45,\
}\
_object_15[_left_15] = _object_16\
local _left_16 = \"button\"\
local _object_17 = {}\
for _k, _v in pairs(darkTheme.apps.players.button) do\
\9_object_17[_k] = _v\
end\
_object_17.outlined = false\
_object_17.foreground = hex(\"#ffffff\")\
_object_17.background = backgroundDark\
_object_15[_left_16] = _object_17\
local _left_17 = \"playerButton\"\
local _object_18 = {}\
for _k, _v in pairs(darkTheme.apps.players.playerButton) do\
\9_object_18[_k] = _v\
end\
_object_18.outlined = false\
_object_18.foreground = hex(\"#ffffff\")\
_object_18.background = backgroundDark\
_object_18.dropshadow = backgroundDark\
_object_18.accent = blueAccent\
_object_15[_left_17] = _object_18\
_object_14[_left_14] = _object_15\
_object[_left_13] = _object_14\
local _left_18 = \"options\"\
local _object_19 = {}\
local _left_19 = \"config\"\
local _object_20 = {}\
for _k, _v in pairs(view) do\
\9_object_20[_k] = _v\
end\
local _left_20 = \"configButton\"\
local _object_21 = {}\
for _k, _v in pairs(darkTheme.options.config.configButton) do\
\9_object_21[_k] = _v\
end\
_object_21.outlined = false\
_object_21.foreground = hex(\"#ffffff\")\
_object_21.background = backgroundDark\
_object_21.dropshadow = backgroundDark\
_object_21.accent = redAccent\
_object_20[_left_20] = _object_21\
_object_19[_left_19] = _object_20\
local _left_21 = \"shortcuts\"\
local _object_22 = {}\
for _k, _v in pairs(view) do\
\9_object_22[_k] = _v\
end\
local _left_22 = \"shortcutButton\"\
local _object_23 = {}\
for _k, _v in pairs(darkTheme.options.shortcuts.shortcutButton) do\
\9_object_23[_k] = _v\
end\
_object_23.outlined = false\
_object_23.foreground = hex(\"#ffffff\")\
_object_23.background = backgroundDark\
_object_23.dropshadow = backgroundDark\
_object_23.accent = mixedAccent\
_object_22[_left_22] = _object_23\
_object_19[_left_21] = _object_22\
local _left_23 = \"themes\"\
local _object_24 = {}\
for _k, _v in pairs(view) do\
\9_object_24[_k] = _v\
end\
local _left_24 = \"themeButton\"\
local _object_25 = {}\
for _k, _v in pairs(darkTheme.options.themes.themeButton) do\
\9_object_25[_k] = _v\
end\
_object_25.outlined = false\
_object_25.foreground = hex(\"#ffffff\")\
_object_25.background = backgroundDark\
_object_25.dropshadow = backgroundDark\
_object_25.accent = blueAccent\
_object_24[_left_24] = _object_25\
_object_19[_left_23] = _object_24\
_object[_left_18] = _object_19\
local sorbet = _object\
return {\
\9sorbet = sorbet,\
}\
", '@'.."Orca.themes.sorbet")) setfenv(fn, newEnv("Orca.themes.sorbet")) return fn() end)

newModule("theme.interface", "ModuleScript", "Orca.themes.theme.interface", "Orca.themes", function () local fn = assert(loadstring("-- Compiled with roblox-ts v1.2.7\
", '@'.."Orca.themes.theme.interface")) setfenv(fn, newEnv("Orca.themes.theme.interface")) return fn() end)

newInstance("utils", "Folder", "Orca.utils", "Orca")

newModule("array-util", "ModuleScript", "Orca.utils.array-util", "Orca.utils", function () local fn = assert(loadstring("-- Compiled with roblox-ts v1.2.7\
local function arrayToMap(arr, mapper)\
\9-- ▼ ReadonlyArray.map ▼\
\9local _newValue = table.create(#arr)\
\9for _k, _v in ipairs(arr) do\
\9\9_newValue[_k] = mapper(_v, _k - 1, arr)\
\9end\
\9-- ▲ ReadonlyArray.map ▲\
\9local _map = {}\
\9for _, _v in ipairs(_newValue) do\
\9\9_map[_v[1]] = _v[2]\
\9end\
\9return _map\
end\
return {\
\9arrayToMap = arrayToMap,\
}\
", '@'.."Orca.utils.array-util")) setfenv(fn, newEnv("Orca.utils.array-util")) return fn() end)

newModule("binding-util", "ModuleScript", "Orca.utils.binding-util", "Orca.utils", function () local fn = assert(loadstring("-- Compiled with roblox-ts v1.2.7\
local TS = require(script.Parent.Parent.include.RuntimeLib)\
local Roact = TS.import(script, TS.getModule(script, \"@rbxts\", \"roact\").src)\
local function isBinding(binding)\
\9return type(binding) == \"table\" and binding.getValue ~= nil\
end\
local function mapBinding(value, transform)\
\9return isBinding(value) and value:map(transform) or (Roact.createBinding(transform(value)))\
end\
local function asBinding(value)\
\9return isBinding(value) and value or (Roact.createBinding(value))\
end\
return {\
\9isBinding = isBinding,\
\9mapBinding = mapBinding,\
\9asBinding = asBinding,\
}\
", '@'.."Orca.utils.binding-util")) setfenv(fn, newEnv("Orca.utils.binding-util")) return fn() end)

newModule("color3", "ModuleScript", "Orca.utils.color3", "Orca.utils", function () local fn = assert(loadstring("-- Compiled with roblox-ts v1.2.7\
local function getLuminance(color)\
\9if typeof(color) == \"ColorSequence\" then\
\9\9color = color.Keypoints[1].Value\
\9end\
\9return color.R * 0.2126 + color.G * 0.7152 + color.B * 0.0722\
end\
local function getColorInSequence(sequence, alpha)\
\9local index = math.floor(alpha * (#sequence.Keypoints - 1))\
\9local nextIndex = math.min(index + 1, #sequence.Keypoints - 1)\
\9local _condition = sequence.Keypoints[index + 1]\
\9if _condition == nil then\
\9\9_condition = sequence.Keypoints[1]\
\9end\
\9local keypoint = _condition\
\9local _condition_1 = sequence.Keypoints[nextIndex + 1]\
\9if _condition_1 == nil then\
\9\9_condition_1 = keypoint\
\9end\
\9local nextKeypoint = _condition_1\
\9return keypoint.Value:Lerp(nextKeypoint.Value, alpha * (#sequence.Keypoints - 1) - index)\
end\
local hexStringToInt = function(hex)\
\9local newHex = string.gsub(hex, \"#\", \"0x\", 1)\
\9local _condition = tonumber(newHex)\
\9if _condition == nil then\
\9\9_condition = 0\
\9end\
\9return _condition\
end\
local intToColor3 = function(i)\
\9return Color3.fromRGB(math.floor(i / 65536) % 256, math.floor(i / 256) % 256, i % 256)\
end\
local hex = function(hex)\
\9return intToColor3(hexStringToInt(hex))\
end\
local rgb = function(r, g, b)\
\9return Color3.fromRGB(r, g, b)\
end\
local hsv = function(h, s, v)\
\9return Color3.fromHSV(h / 360, s / 100, v / 100)\
end\
local hsl = function(h, s, l)\
\9local hsv1 = (s * (l < 50 and l or 100 - l)) / 100\
\9local hsvS = hsv1 == 0 and 0 or ((2 * hsv1) / (l + hsv1)) * 100\
\9local hsvV = l + hsv1\
\9return Color3.fromHSV(h / 255, hsvS / 100, hsvV / 100)\
end\
return {\
\9getLuminance = getLuminance,\
\9getColorInSequence = getColorInSequence,\
\9hex = hex,\
\9rgb = rgb,\
\9hsv = hsv,\
\9hsl = hsl,\
}\
", '@'.."Orca.utils.color3")) setfenv(fn, newEnv("Orca.utils.color3")) return fn() end)

newModule("debug", "ModuleScript", "Orca.utils.debug", "Orca.utils", function () local fn = assert(loadstring("-- Compiled with roblox-ts v1.2.7\
local clock = os.clock()\
local clockName = \"clock\"\
local debugCounter = {}\
local function startTimer(name)\
\9local _condition = debugCounter[name]\
\9if _condition == nil then\
\9\9_condition = 0\
\9end\
\9debugCounter[name] = _condition + 1\
\9clockName = name\
\9clock = os.clock()\
end\
local function endTimer()\
\9local diff = os.clock() - clock\
\9local _condition = debugCounter[clockName]\
\9if _condition == nil then\
\9\9_condition = 0\
\9end\
\9local count = _condition\
\9print(\"\\n[\" .. (clockName .. (\" \" .. (tostring(count) .. (\"]\\n\" .. (tostring(diff * 1000) .. \" ms\\n\\n\"))))))\
end\
return {\
\9startTimer = startTimer,\
\9endTimer = endTimer,\
}\
", '@'.."Orca.utils.debug")) setfenv(fn, newEnv("Orca.utils.debug")) return fn() end)

newModule("http", "ModuleScript", "Orca.utils.http", "Orca.utils", function () local fn = assert(loadstring("-- Compiled with roblox-ts v1.2.7\
local TS = require(script.Parent.Parent.include.RuntimeLib)\
local HttpService = TS.import(script, TS.getModule(script, \"@rbxts\", \"services\")).HttpService\
local IS_DEV = TS.import(script, script.Parent.Parent, \"constants\").IS_DEV\
local request\
request = TS.async(function(requestOptions)\
\9if IS_DEV then\
\9\9return HttpService:RequestAsync(requestOptions)\
\9else\
\9\9local fn = syn and syn.request or request\
\9\9if not fn then\
\9\9\9error(\"request/syn.request is not available\")\
\9\9end\
\9\9return fn(requestOptions)\
\9end\
end)\
local get = TS.async(function(url, requestType)\
\9return game:HttpGetAsync(url, requestType)\
end)\
local post = TS.async(function(url, data, contentType, requestType)\
\9return game:HttpPostAsync(url, data, contentType, requestType)\
end)\
return {\
\9request = request,\
\9get = get,\
\9post = post,\
}\
", '@'.."Orca.utils.http")) setfenv(fn, newEnv("Orca.utils.http")) return fn() end)

newModule("number-util", "ModuleScript", "Orca.utils.number-util", "Orca.utils", function () local fn = assert(loadstring("-- Compiled with roblox-ts v1.2.7\
local function map(n, min0, max0, min1, max1)\
\9return min1 + ((n - min0) * (max1 - min1)) / (max0 - min0)\
end\
local function lerp(a, b, t)\
\9return a + (b - a) * t\
end\
return {\
\9map = map,\
\9lerp = lerp,\
}\
", '@'.."Orca.utils.number-util")) setfenv(fn, newEnv("Orca.utils.number-util")) return fn() end)

newModule("timeout", "ModuleScript", "Orca.utils.timeout", "Orca.utils", function () local fn = assert(loadstring("-- Compiled with roblox-ts v1.2.7\
local TS = require(script.Parent.Parent.include.RuntimeLib)\
local RunService = TS.import(script, TS.getModule(script, \"@rbxts\", \"services\")).RunService\
local Timeout\
do\
\9Timeout = setmetatable({}, {\
\9\9__tostring = function()\
\9\9\9return \"Timeout\"\
\9\9end,\
\9})\
\9Timeout.__index = Timeout\
\9function Timeout.new(...)\
\9\9local self = setmetatable({}, Timeout)\
\9\9return self:constructor(...) or self\
\9end\
\9function Timeout:constructor(callback, milliseconds, ...)\
\9\9local args = { ... }\
\9\9self.running = true\
\9\9task.delay(milliseconds / 1000, function()\
\9\9\9if self.running then\
\9\9\9\9callback(unpack(args))\
\9\9\9end\
\9\9end)\
\9end\
\9function Timeout:clear()\
\9\9self.running = false\
\9end\
end\
local function setTimeout(callback, milliseconds, ...)\
\9local args = { ... }\
\9return Timeout.new(callback, milliseconds, unpack(args))\
end\
local function clearTimeout(timeout)\
\9timeout:clear()\
end\
local Interval\
do\
\9Interval = setmetatable({}, {\
\9\9__tostring = function()\
\9\9\9return \"Interval\"\
\9\9end,\
\9})\
\9Interval.__index = Interval\
\9function Interval.new(...)\
\9\9local self = setmetatable({}, Interval)\
\9\9return self:constructor(...) or self\
\9end\
\9function Interval:constructor(callback, milliseconds, ...)\
\9\9local args = { ... }\
\9\9self.running = true\
\9\9task.defer(function()\
\9\9\9local clock = 0\
\9\9\9local hb\
\9\9\9hb = RunService.Heartbeat:Connect(function(step)\
\9\9\9\9clock += step\
\9\9\9\9if not self.running then\
\9\9\9\9\9hb:Disconnect()\
\9\9\9\9elseif clock >= milliseconds / 1000 then\
\9\9\9\9\9clock -= milliseconds / 1000\
\9\9\9\9\9callback(unpack(args))\
\9\9\9\9end\
\9\9\9end)\
\9\9end)\
\9end\
\9function Interval:clear()\
\9\9self.running = false\
\9end\
end\
local function setInterval(callback, milliseconds, ...)\
\9local args = { ... }\
\9return Interval.new(callback, milliseconds, unpack(args))\
end\
local function clearInterval(interval)\
\9interval:clear()\
end\
return {\
\9setTimeout = setTimeout,\
\9clearTimeout = clearTimeout,\
\9setInterval = setInterval,\
\9clearInterval = clearInterval,\
\9Timeout = Timeout,\
\9Interval = Interval,\
}\
", '@'.."Orca.utils.timeout")) setfenv(fn, newEnv("Orca.utils.timeout")) return fn() end)

newModule("udim2", "ModuleScript", "Orca.utils.udim2", "Orca.utils", function () local fn = assert(loadstring("-- Compiled with roblox-ts v1.2.7\
local function px(x, y)\
\9return UDim2.new(0, x, 0, y)\
end\
local function scale(x, y)\
\9return UDim2.new(x, 0, y, 0)\
end\
local function applyUDim2(size, udim2, scaleFactor)\
\9if scaleFactor == nil then\
\9\9scaleFactor = 1\
\9end\
\9return Vector2.new(udim2.X.Offset + (udim2.X.Scale / scaleFactor) * size.X, udim2.Y.Offset + (udim2.Y.Scale / scaleFactor) * size.Y)\
end\
return {\
\9px = px,\
\9scale = scale,\
\9applyUDim2 = applyUDim2,\
}\
", '@'.."Orca.utils.udim2")) setfenv(fn, newEnv("Orca.utils.udim2")) return fn() end)

newInstance("views", "Folder", "Orca.views", "Orca")

newModule("Clock", "ModuleScript", "Orca.views.Clock", "Orca.views", function () local fn = assert(loadstring("-- Compiled with roblox-ts v1.2.7\
local TS = require(script.Parent.Parent.include.RuntimeLib)\
local exports = {}\
exports.default = TS.import(script, script, \"Clock\").default\
return exports\
", '@'.."Orca.views.Clock")) setfenv(fn, newEnv("Orca.views.Clock")) return fn() end)

newModule("Clock", "ModuleScript", "Orca.views.Clock.Clock", "Orca.views.Clock", function () local fn = assert(loadstring("-- Compiled with roblox-ts v1.2.7\
local TS = require(script.Parent.Parent.Parent.include.RuntimeLib)\
local Roact = TS.import(script, TS.getModule(script, \"@rbxts\", \"roact\").src)\
local _roact_hooked = TS.import(script, TS.getModule(script, \"@rbxts\", \"roact-hooked\").out)\
local hooked = _roact_hooked.hooked\
local useEffect = _roact_hooked.useEffect\
local useMemo = _roact_hooked.useMemo\
local useState = _roact_hooked.useState\
local TextService = TS.import(script, TS.getModule(script, \"@rbxts\", \"services\")).TextService\
local Acrylic = TS.import(script, script.Parent.Parent.Parent, \"components\", \"Acrylic\").default\
local Border = TS.import(script, script.Parent.Parent.Parent, \"components\", \"Border\").default\
local Fill = TS.import(script, script.Parent.Parent.Parent, \"components\", \"Fill\").default\
local _Glow = TS.import(script, script.Parent.Parent.Parent, \"components\", \"Glow\")\
local Glow = _Glow.default\
local GlowRadius = _Glow.GlowRadius\
local useAppSelector = TS.import(script, script.Parent.Parent.Parent, \"hooks\", \"common\", \"rodux-hooks\").useAppSelector\
local useSpring = TS.import(script, script.Parent.Parent.Parent, \"hooks\", \"common\", \"use-spring\").useSpring\
local useTheme = TS.import(script, script.Parent.Parent.Parent, \"hooks\", \"use-theme\").useTheme\
local setInterval = TS.import(script, script.Parent.Parent.Parent, \"utils\", \"timeout\").setInterval\
local px = TS.import(script, script.Parent.Parent.Parent, \"utils\", \"udim2\").px\
local MIN_CLOCK_SIZE = px(56, 56)\
local CLOCK_PADDING = 14\
local function getTime()\
\9return (string.gsub(os.date(\"%I:%M %p\"), \"^0([0-9])\", \"%1\"))\
end\
local function Clock()\
\9local isOpen = useAppSelector(function(state)\
\9\9return state.dashboard.isOpen\
\9end)\
\9local theme = useTheme(\"clock\")\
\9local _binding = useState(getTime())\
\9local currentTime = _binding[1]\
\9local setTime = _binding[2]\
\9local textWidth = useMemo(function()\
\9\9return TextService:GetTextSize(currentTime, 20, \"GothamBold\", Vector2.new(200, 56))\
\9end, { currentTime })\
\9useEffect(function()\
\9\9local interval = setInterval(function()\
\9\9\9return setTime(getTime())\
\9\9end, 1000)\
\9\9return function()\
\9\9\9return interval:clear()\
\9\9end\
\9end, {})\
\9local _attributes = {}\
\9local _arg0 = px(textWidth.X + CLOCK_PADDING, 0)\
\9_attributes.Size = MIN_CLOCK_SIZE + _arg0\
\9_attributes.Position = useSpring(isOpen and UDim2.new(0, 0, 1, 0) or UDim2.new(0, 0, 1, 48 + 56 + 20), {})\
\9_attributes.AnchorPoint = Vector2.new(0, 1)\
\9_attributes.BackgroundTransparency = 1\
\9local _children = {\
\9\9Roact.createElement(Glow, {\
\9\9\9radius = GlowRadius.Size146,\
\9\9\9size = UDim2.new(1, 80, 0, 146),\
\9\9\9position = px(-40, -20),\
\9\9\9color = theme.dropshadow,\
\9\9\9gradient = theme.dropshadowGradient,\
\9\9\9transparency = theme.transparency,\
\9\9}),\
\9\9Roact.createElement(Fill, {\
\9\9\9color = theme.background,\
\9\9\9gradient = theme.backgroundGradient,\
\9\9\9transparency = theme.transparency,\
\9\9\9radius = 8,\
\9\9}),\
\9}\
\9local _length = #_children\
\9local _child = theme.outlined and Roact.createFragment({\
\9\9border = Roact.createElement(Border, {\
\9\9\9color = theme.foreground,\
\9\9\9radius = 8,\
\9\9\9transparency = 0.8,\
\9\9}),\
\9})\
\9if _child then\
\9\9if _child.elements ~= nil or _child.props ~= nil and _child.component ~= nil then\
\9\9\9_children[_length + 1] = _child\
\9\9else\
\9\9\9for _k, _v in ipairs(_child) do\
\9\9\9\9_children[_length + _k] = _v\
\9\9\9end\
\9\9end\
\9end\
\9_length = #_children\
\9_children[_length + 1] = Roact.createElement(\"ImageLabel\", {\
\9\9Image = \"rbxassetid://8992234911\",\
\9\9ImageColor3 = theme.foreground,\
\9\9Size = px(36, 36),\
\9\9Position = px(10, 10),\
\9\9BackgroundTransparency = 1,\
\9})\
\9_children[_length + 2] = Roact.createElement(\"TextLabel\", {\
\9\9Text = currentTime,\
\9\9Font = \"GothamBold\",\
\9\9TextColor3 = theme.foreground,\
\9\9TextSize = 20,\
\9\9TextXAlignment = \"Left\",\
\9\9TextYAlignment = \"Center\",\
\9\9Size = px(0, 0),\
\9\9Position = px(51, 27),\
\9\9BackgroundTransparency = 1,\
\9})\
\9local _child_1 = theme.acrylic and Roact.createElement(Acrylic) or nil\
\9if _child_1 then\
\9\9if _child_1.elements ~= nil or _child_1.props ~= nil and _child_1.component ~= nil then\
\9\9\9_children[_length + 3] = _child_1\
\9\9else\
\9\9\9for _k, _v in ipairs(_child_1) do\
\9\9\9\9_children[_length + 2 + _k] = _v\
\9\9\9end\
\9\9end\
\9end\
\9return Roact.createElement(\"Frame\", _attributes, _children)\
end\
local default = hooked(Clock)\
return {\
\9default = default,\
}\
", '@'.."Orca.views.Clock.Clock")) setfenv(fn, newEnv("Orca.views.Clock.Clock")) return fn() end)

newModule("Dashboard", "ModuleScript", "Orca.views.Dashboard", "Orca.views", function () local fn = assert(loadstring("-- Compiled with roblox-ts v1.2.7\
local TS = require(script.Parent.Parent.include.RuntimeLib)\
local exports = {}\
exports.default = TS.import(script, script, \"Dashboard\").default\
return exports\
", '@'.."Orca.views.Dashboard")) setfenv(fn, newEnv("Orca.views.Dashboard")) return fn() end)

newModule("Dashboard", "ModuleScript", "Orca.views.Dashboard.Dashboard", "Orca.views.Dashboard", function () local fn = assert(loadstring("-- Compiled with roblox-ts v1.2.7\
local TS = require(script.Parent.Parent.Parent.include.RuntimeLib)\
local Roact = TS.import(script, TS.getModule(script, \"@rbxts\", \"roact\").src)\
local _roact_hooked = TS.import(script, TS.getModule(script, \"@rbxts\", \"roact-hooked\").out)\
local hooked = _roact_hooked.hooked\
local useMemo = _roact_hooked.useMemo\
local Canvas = TS.import(script, script.Parent.Parent.Parent, \"components\", \"Canvas\").default\
local ScaleContext = TS.import(script, script.Parent.Parent.Parent, \"context\", \"scale-context\").ScaleContext\
local useAppSelector = TS.import(script, script.Parent.Parent.Parent, \"hooks\", \"common\", \"rodux-hooks\").useAppSelector\
local useSpring = TS.import(script, script.Parent.Parent.Parent, \"hooks\", \"common\", \"use-spring\").useSpring\
local useViewportSize = TS.import(script, script.Parent.Parent.Parent, \"hooks\", \"common\", \"use-viewport-size\").useViewportSize\
local hex = TS.import(script, script.Parent.Parent.Parent, \"utils\", \"color3\").hex\
local map = TS.import(script, script.Parent.Parent.Parent, \"utils\", \"number-util\").map\
local scale = TS.import(script, script.Parent.Parent.Parent, \"utils\", \"udim2\").scale\
local Hint = TS.import(script, script.Parent.Parent, \"Hint\").default\
local Clock = TS.import(script, script.Parent.Parent, \"Clock\").default\
local Navbar = TS.import(script, script.Parent.Parent, \"Navbar\").default\
local Pages = TS.import(script, script.Parent.Parent, \"Pages\").default\
local PADDING_MIN_HEIGHT = 980\
local PADDING_MAX_HEIGHT = 1080\
local MIN_PADDING_Y = 14\
local MAX_PADDING_Y = 48\
local function getPaddingY(height)\
\9if height < PADDING_MAX_HEIGHT and height >= PADDING_MIN_HEIGHT then\
\9\9return map(height, PADDING_MIN_HEIGHT, PADDING_MAX_HEIGHT, MIN_PADDING_Y, MAX_PADDING_Y)\
\9elseif height < PADDING_MIN_HEIGHT then\
\9\9return MIN_PADDING_Y\
\9else\
\9\9return MAX_PADDING_Y\
\9end\
end\
local function getScale(height)\
\9if height < PADDING_MIN_HEIGHT then\
\9\9return map(height, PADDING_MIN_HEIGHT, 130, 1, 0)\
\9else\
\9\9return 1\
\9end\
end\
local function Dashboard()\
\9local viewportSize = useViewportSize()\
\9local isOpen = useAppSelector(function(state)\
\9\9return state.dashboard.isOpen\
\9end)\
\9local _binding = useMemo(function()\
\9\9return { viewportSize:map(function(s)\
\9\9\9return getScale(s.Y)\
\9\9end), viewportSize:map(function(s)\
\9\9\9return getPaddingY(s.Y)\
\9\9end) }\
\9end, { viewportSize })\
\9local scaleFactor = _binding[1]\
\9local padding = _binding[2]\
\9return Roact.createElement(ScaleContext.Provider, {\
\9\9value = scaleFactor,\
\9}, {\
\9\9Roact.createElement(\"Frame\", {\
\9\9\9Size = scale(1, 1),\
\9\9\9BackgroundColor3 = hex(\"#000000\"),\
\9\9\9BackgroundTransparency = useSpring(isOpen and 0 or 1, {}),\
\9\9\9BorderSizePixel = 0,\
\9\9}, {\
\9\9\9Roact.createElement(\"UIGradient\", {\
\9\9\9\9Transparency = NumberSequence.new(1, 0.25),\
\9\9\9\9Rotation = 90,\
\9\9\9}),\
\9\9}),\
\9\9Roact.createElement(Canvas, {\
\9\9\9padding = {\
\9\9\9\9top = 48,\
\9\9\9\9bottom = padding,\
\9\9\9\9left = 48,\
\9\9\9\9right = 48,\
\9\9\9},\
\9\9}, {\
\9\9\9Roact.createElement(Canvas, {\
\9\9\9\9padding = {\
\9\9\9\9\9bottom = padding:map(function(p)\
\9\9\9\9\9\9return 56 + p\
\9\9\9\9\9end),\
\9\9\9\9},\
\9\9\9}, {\
\9\9\9\9Roact.createElement(Pages),\
\9\9\9\9Roact.createElement(Hint),\
\9\9\9}),\
\9\9\9Roact.createElement(Navbar),\
\9\9\9Roact.createElement(Clock),\
\9\9}),\
\9})\
end\
local default = hooked(Dashboard)\
return {\
\9default = default,\
}\
", '@'.."Orca.views.Dashboard.Dashboard")) setfenv(fn, newEnv("Orca.views.Dashboard.Dashboard")) return fn() end)

newModule("Dashboard.story", "ModuleScript", "Orca.views.Dashboard.Dashboard.story", "Orca.views.Dashboard", function () local fn = assert(loadstring("-- Compiled with roblox-ts v1.2.7\
local TS = require(script.Parent.Parent.Parent.include.RuntimeLib)\
local Roact = TS.import(script, TS.getModule(script, \"@rbxts\", \"roact\").src)\
local Provider = TS.import(script, TS.getModule(script, \"@rbxts\", \"roact-rodux-hooked\").out).Provider\
local DashboardPage = TS.import(script, script.Parent.Parent.Parent, \"store\", \"models\", \"dashboard.model\").DashboardPage\
local configureStore = TS.import(script, script.Parent.Parent.Parent, \"store\", \"store\").configureStore\
local Dashboard = TS.import(script, script.Parent, \"Dashboard\").default\
return function(target)\
\9local handle = Roact.mount(Roact.createElement(Provider, {\
\9\9store = configureStore({\
\9\9\9dashboard = {\
\9\9\9\9isOpen = true,\
\9\9\9\9page = DashboardPage.Home,\
\9\9\9\9hint = nil,\
\9\9\9\9apps = {},\
\9\9\9},\
\9\9}),\
\9}, {\
\9\9Roact.createElement(Dashboard),\
\9}), target, \"Dashboard\")\
\9return function()\
\9\9return Roact.unmount(handle)\
\9end\
end\
", '@'.."Orca.views.Dashboard.Dashboard.story")) setfenv(fn, newEnv("Orca.views.Dashboard.Dashboard.story")) return fn() end)

newModule("Hint", "ModuleScript", "Orca.views.Hint", "Orca.views", function () local fn = assert(loadstring("-- Compiled with roblox-ts v1.2.7\
local TS = require(script.Parent.Parent.include.RuntimeLib)\
local exports = {}\
exports.default = TS.import(script, script, \"Hint\").default\
return exports\
", '@'.."Orca.views.Hint")) setfenv(fn, newEnv("Orca.views.Hint")) return fn() end)

newModule("Hint", "ModuleScript", "Orca.views.Hint.Hint", "Orca.views.Hint", function () local fn = assert(loadstring("-- Compiled with roblox-ts v1.2.7\
local TS = require(script.Parent.Parent.Parent.include.RuntimeLib)\
local Roact = TS.import(script, TS.getModule(script, \"@rbxts\", \"roact\").src)\
local _roact_hooked = TS.import(script, TS.getModule(script, \"@rbxts\", \"roact-hooked\").out)\
local hooked = _roact_hooked.hooked\
local useEffect = _roact_hooked.useEffect\
local useState = _roact_hooked.useState\
local useAppSelector = TS.import(script, script.Parent.Parent.Parent, \"hooks\", \"common\", \"rodux-hooks\").useAppSelector\
local useDelayedUpdate = TS.import(script, script.Parent.Parent.Parent, \"hooks\", \"common\", \"use-delayed-update\").useDelayedUpdate\
local useSpring = TS.import(script, script.Parent.Parent.Parent, \"hooks\", \"common\", \"use-spring\").useSpring\
local useScale = TS.import(script, script.Parent.Parent.Parent, \"hooks\", \"use-scale\").useScale\
local hex = TS.import(script, script.Parent.Parent.Parent, \"utils\", \"color3\").hex\
local scale = TS.import(script, script.Parent.Parent.Parent, \"utils\", \"udim2\").scale\
local function Hint()\
\9local scaleFactor = useScale()\
\9local hint = useAppSelector(function(state)\
\9\9return state.dashboard.hint\
\9end)\
\9local isDashboardOpen = useAppSelector(function(state)\
\9\9return state.dashboard.isOpen\
\9end)\
\9local _condition = hint\
\9if _condition == nil then\
\9\9_condition = \"\"\
\9end\
\9local _binding = useState(_condition)\
\9local hintDisplay = _binding[1]\
\9local setHintDisplay = _binding[2]\
\9local isHintVisible = useDelayedUpdate(hint ~= nil and isDashboardOpen, 500, function(visible)\
\9\9return not visible\
\9end)\
\9useEffect(function()\
\9\9if isHintVisible and hint ~= nil then\
\9\9\9setHintDisplay(hint)\
\9\9end\
\9end, { hint, isHintVisible })\
\9return Roact.createElement(\"TextLabel\", {\
\9\9RichText = true,\
\9\9Text = hintDisplay,\
\9\9TextXAlignment = \"Right\",\
\9\9TextYAlignment = \"Bottom\",\
\9\9TextColor3 = hex(\"#FFFFFF\"),\
\9\9TextTransparency = useSpring(isHintVisible and 0.4 or 1, {}),\
\9\9Font = \"GothamSemibold\",\
\9\9TextSize = 18,\
\9\9BackgroundTransparency = 1,\
\9\9Position = useSpring(isHintVisible and scale(1, 1) or UDim2.new(1, 0, 1, 48), {}),\
\9}, {\
\9\9Roact.createElement(\"UIScale\", {\
\9\9\9Scale = scaleFactor,\
\9\9}),\
\9})\
end\
local default = hooked(Hint)\
return {\
\9default = default,\
}\
", '@'.."Orca.views.Hint.Hint")) setfenv(fn, newEnv("Orca.views.Hint.Hint")) return fn() end)

newModule("Navbar", "ModuleScript", "Orca.views.Navbar", "Orca.views", function () local fn = assert(loadstring("-- Compiled with roblox-ts v1.2.7\
local TS = require(script.Parent.Parent.include.RuntimeLib)\
local exports = {}\
exports.default = TS.import(script, script, \"Navbar\").default\
return exports\
", '@'.."Orca.views.Navbar")) setfenv(fn, newEnv("Orca.views.Navbar")) return fn() end)

newModule("Navbar", "ModuleScript", "Orca.views.Navbar.Navbar", "Orca.views.Navbar", function () local fn = assert(loadstring("-- Compiled with roblox-ts v1.2.7\
local TS = require(script.Parent.Parent.Parent.include.RuntimeLib)\
local Roact = TS.import(script, TS.getModule(script, \"@rbxts\", \"roact\").src)\
local hooked = TS.import(script, TS.getModule(script, \"@rbxts\", \"roact-hooked\").out).hooked\
local Acrylic = TS.import(script, script.Parent.Parent.Parent, \"components\", \"Acrylic\").default\
local Border = TS.import(script, script.Parent.Parent.Parent, \"components\", \"Border\").default\
local Canvas = TS.import(script, script.Parent.Parent.Parent, \"components\", \"Canvas\").default\
local Fill = TS.import(script, script.Parent.Parent.Parent, \"components\", \"Fill\").default\
local _Glow = TS.import(script, script.Parent.Parent.Parent, \"components\", \"Glow\")\
local Glow = _Glow.default\
local GlowRadius = _Glow.GlowRadius\
local useAppSelector = TS.import(script, script.Parent.Parent.Parent, \"hooks\", \"common\", \"rodux-hooks\").useAppSelector\
local useSpring = TS.import(script, script.Parent.Parent.Parent, \"hooks\", \"common\", \"use-spring\").useSpring\
local useCurrentPage = TS.import(script, script.Parent.Parent.Parent, \"hooks\", \"use-current-page\").useCurrentPage\
local useTheme = TS.import(script, script.Parent.Parent.Parent, \"hooks\", \"use-theme\").useTheme\
local _dashboard_model = TS.import(script, script.Parent.Parent.Parent, \"store\", \"models\", \"dashboard.model\")\
local DashboardPage = _dashboard_model.DashboardPage\
local PAGE_TO_INDEX = _dashboard_model.PAGE_TO_INDEX\
local _color3 = TS.import(script, script.Parent.Parent.Parent, \"utils\", \"color3\")\
local getColorInSequence = _color3.getColorInSequence\
local hex = _color3.hex\
local _udim2 = TS.import(script, script.Parent.Parent.Parent, \"utils\", \"udim2\")\
local px = _udim2.px\
local scale = _udim2.scale\
local NavbarTab = TS.import(script, script.Parent, \"NavbarTab\").default\
local NAVBAR_SIZE = px(400, 56)\
local Underglow\
local function Navbar()\
\9local theme = useTheme(\"navbar\")\
\9local page = useCurrentPage()\
\9local isOpen = useAppSelector(function(state)\
\9\9return state.dashboard.isOpen\
\9end)\
\9local alpha = useSpring(PAGE_TO_INDEX[page] / 4, {\
\9\9frequency = 3.9,\
\9\9dampingRatio = 0.76,\
\9})\
\9local _attributes = {\
\9\9Size = NAVBAR_SIZE,\
\9\9Position = useSpring(isOpen and UDim2.new(0.5, 0, 1, 0) or UDim2.new(0.5, 0, 1, 48 + 56 + 20), {}),\
\9\9AnchorPoint = Vector2.new(0.5, 1),\
\9\9BackgroundTransparency = 1,\
\9}\
\9local _children = {\
\9\9Roact.createElement(Glow, {\
\9\9\9radius = GlowRadius.Size146,\
\9\9\9size = UDim2.new(1, 80, 0, 146),\
\9\9\9position = px(-40, -20),\
\9\9\9color = theme.dropshadow,\
\9\9\9gradient = theme.dropshadowGradient,\
\9\9\9transparency = theme.transparency,\
\9\9}),\
\9\9Roact.createElement(Underglow, {\
\9\9\9transparency = theme.glowTransparency,\
\9\9\9position = alpha:map(function(a)\
\9\9\9\9return a + 0.125\
\9\9\9end),\
\9\9\9sequenceColor = alpha:map(function(a)\
\9\9\9\9return getColorInSequence(theme.accentGradient.color, a + 0.125)\
\9\9\9end),\
\9\9}),\
\9\9Roact.createElement(Fill, {\
\9\9\9color = theme.background,\
\9\9\9gradient = theme.backgroundGradient,\
\9\9\9radius = 8,\
\9\9\9transparency = theme.transparency,\
\9\9}),\
\9\9Roact.createElement(Canvas, {\
\9\9\9size = px(100, 56),\
\9\9\9position = alpha:map(function(a)\
\9\9\9\9return scale(math.round(a * 800) / 800, 0)\
\9\9\9end),\
\9\9\9clipsDescendants = true,\
\9\9}, {\
\9\9\9Roact.createElement(\"Frame\", {\
\9\9\9\9Size = NAVBAR_SIZE,\
\9\9\9\9Position = alpha:map(function(a)\
\9\9\9\9\9return scale(-4 * (math.round(a * 800) / 800), 0)\
\9\9\9\9end),\
\9\9\9\9BackgroundColor3 = hex(\"#FFFFFF\"),\
\9\9\9\9BorderSizePixel = 0,\
\9\9\9}, {\
\9\9\9\9Roact.createElement(\"UIGradient\", {\
\9\9\9\9\9Color = theme.accentGradient.color,\
\9\9\9\9\9Transparency = theme.accentGradient.transparency,\
\9\9\9\9\9Rotation = theme.accentGradient.rotation,\
\9\9\9\9}),\
\9\9\9\9Roact.createElement(\"UICorner\", {\
\9\9\9\9\9CornerRadius = UDim.new(0, 8),\
\9\9\9\9}),\
\9\9\9}),\
\9\9}),\
\9}\
\9local _length = #_children\
\9local _child = theme.outlined and Roact.createFragment({\
\9\9border = Roact.createElement(Border, {\
\9\9\9color = theme.foreground,\
\9\9\9radius = 8,\
\9\9\9transparency = 0.8,\
\9\9}),\
\9})\
\9if _child then\
\9\9if _child.elements ~= nil or _child.props ~= nil and _child.component ~= nil then\
\9\9\9_children[_length + 1] = _child\
\9\9else\
\9\9\9for _k, _v in ipairs(_child) do\
\9\9\9\9_children[_length + _k] = _v\
\9\9\9end\
\9\9end\
\9end\
\9_length = #_children\
\9_children[_length + 1] = Roact.createElement(NavbarTab, {\
\9\9page = DashboardPage.Home,\
\9})\
\9_children[_length + 2] = Roact.createElement(NavbarTab, {\
\9\9page = DashboardPage.Apps,\
\9})\
\9_children[_length + 3] = Roact.createElement(NavbarTab, {\
\9\9page = DashboardPage.Scripts,\
\9})\
\9_children[_length + 4] = Roact.createElement(NavbarTab, {\
\9\9page = DashboardPage.Options,\
\9})\
\9local _child_1 = theme.acrylic and Roact.createElement(Acrylic) or nil\
\9if _child_1 then\
\9\9if _child_1.elements ~= nil or _child_1.props ~= nil and _child_1.component ~= nil then\
\9\9\9_children[_length + 5] = _child_1\
\9\9else\
\9\9\9for _k, _v in ipairs(_child_1) do\
\9\9\9\9_children[_length + 4 + _k] = _v\
\9\9\9end\
\9\9end\
\9end\
\9return Roact.createElement(\"Frame\", _attributes, _children)\
end\
local default = hooked(Navbar)\
function Underglow(props)\
\9return Roact.createElement(\"ImageLabel\", {\
\9\9Image = \"rbxassetid://8992238178\",\
\9\9ImageColor3 = props.sequenceColor,\
\9\9ImageTransparency = props.transparency,\
\9\9Size = px(148, 104),\
\9\9Position = props.position:map(function(a)\
\9\9\9return UDim2.new(a, 0, 0, -18)\
\9\9end),\
\9\9AnchorPoint = Vector2.new(0.5, 0),\
\9\9BackgroundTransparency = 1,\
\9})\
end\
return {\
\9default = default,\
}\
", '@'.."Orca.views.Navbar.Navbar")) setfenv(fn, newEnv("Orca.views.Navbar.Navbar")) return fn() end)

newModule("Navbar.story", "ModuleScript", "Orca.views.Navbar.Navbar.story", "Orca.views.Navbar", function () local fn = assert(loadstring("-- Compiled with roblox-ts v1.2.7\
local TS = require(script.Parent.Parent.Parent.include.RuntimeLib)\
local Roact = TS.import(script, TS.getModule(script, \"@rbxts\", \"roact\").src)\
local Provider = TS.import(script, TS.getModule(script, \"@rbxts\", \"roact-rodux-hooked\").out).Provider\
local DashboardPage = TS.import(script, script.Parent.Parent.Parent, \"store\", \"models\", \"dashboard.model\").DashboardPage\
local configureStore = TS.import(script, script.Parent.Parent.Parent, \"store\", \"store\").configureStore\
local Navbar = TS.import(script, script.Parent, \"Navbar\").default\
return function(target)\
\9local handle = Roact.mount(Roact.createElement(Provider, {\
\9\9store = configureStore({\
\9\9\9dashboard = {\
\9\9\9\9isOpen = true,\
\9\9\9\9page = DashboardPage.Home,\
\9\9\9\9hint = nil,\
\9\9\9\9apps = {},\
\9\9\9},\
\9\9}),\
\9}, {\
\9\9Roact.createElement(Navbar),\
\9}), target, \"Navbar\")\
\9return function()\
\9\9return Roact.unmount(handle)\
\9end\
end\
", '@'.."Orca.views.Navbar.Navbar.story")) setfenv(fn, newEnv("Orca.views.Navbar.Navbar.story")) return fn() end)

newModule("NavbarTab", "ModuleScript", "Orca.views.Navbar.NavbarTab", "Orca.views.Navbar", function () local fn = assert(loadstring("-- Compiled with roblox-ts v1.2.7\
local TS = require(script.Parent.Parent.Parent.include.RuntimeLib)\
local Roact = TS.import(script, TS.getModule(script, \"@rbxts\", \"roact\").src)\
local _roact_hooked = TS.import(script, TS.getModule(script, \"@rbxts\", \"roact-hooked\").out)\
local hooked = _roact_hooked.hooked\
local useState = _roact_hooked.useState\
local useAppDispatch = TS.import(script, script.Parent.Parent.Parent, \"hooks\", \"common\", \"rodux-hooks\").useAppDispatch\
local useSpring = TS.import(script, script.Parent.Parent.Parent, \"hooks\", \"common\", \"use-spring\").useSpring\
local useIsPageOpen = TS.import(script, script.Parent.Parent.Parent, \"hooks\", \"use-current-page\").useIsPageOpen\
local useTheme = TS.import(script, script.Parent.Parent.Parent, \"hooks\", \"use-theme\").useTheme\
local setDashboardPage = TS.import(script, script.Parent.Parent.Parent, \"store\", \"actions\", \"dashboard.action\").setDashboardPage\
local _dashboard_model = TS.import(script, script.Parent.Parent.Parent, \"store\", \"models\", \"dashboard.model\")\
local PAGE_TO_ICON = _dashboard_model.PAGE_TO_ICON\
local PAGE_TO_INDEX = _dashboard_model.PAGE_TO_INDEX\
local _udim2 = TS.import(script, script.Parent.Parent.Parent, \"utils\", \"udim2\")\
local px = _udim2.px\
local scale = _udim2.scale\
local TAB_SIZE = px(100, 56)\
local function NavbarTab(_param)\
\9local page = _param.page\
\9local theme = useTheme(\"navbar\")\
\9local isActive = useIsPageOpen(page)\
\9local dispatch = useAppDispatch()\
\9local _binding = useState(false)\
\9local isHovered = _binding[1]\
\9local setHovered = _binding[2]\
\9return Roact.createElement(\"TextButton\", {\
\9\9Text = \"\",\
\9\9AutoButtonColor = false,\
\9\9Active = not isActive,\
\9\9Size = TAB_SIZE,\
\9\9Position = scale(PAGE_TO_INDEX[page] / 4, 0),\
\9\9BackgroundTransparency = 1,\
\9\9[Roact.Event.Activated] = function()\
\9\9\9return dispatch(setDashboardPage(page))\
\9\9end,\
\9\9[Roact.Event.MouseEnter] = function()\
\9\9\9return setHovered(true)\
\9\9end,\
\9\9[Roact.Event.MouseLeave] = function()\
\9\9\9return setHovered(false)\
\9\9end,\
\9}, {\
\9\9Roact.createElement(\"ImageLabel\", {\
\9\9\9Image = PAGE_TO_ICON[page],\
\9\9\9ImageColor3 = theme.foreground,\
\9\9\9ImageTransparency = useSpring(isActive and 0 or (isHovered and 0.5 or 0.75), {}),\
\9\9\9Size = px(36, 36),\
\9\9\9Position = scale(0.5, 0.5),\
\9\9\9AnchorPoint = Vector2.new(0.5, 0.5),\
\9\9\9BackgroundTransparency = 1,\
\9\9}),\
\9})\
end\
local default = hooked(NavbarTab)\
return {\
\9default = default,\
}\
", '@'.."Orca.views.Navbar.NavbarTab")) setfenv(fn, newEnv("Orca.views.Navbar.NavbarTab")) return fn() end)

newModule("Pages", "ModuleScript", "Orca.views.Pages", "Orca.views", function () local fn = assert(loadstring("-- Compiled with roblox-ts v1.2.7\
local TS = require(script.Parent.Parent.include.RuntimeLib)\
local exports = {}\
exports.default = TS.import(script, script, \"Pages\").default\
return exports\
", '@'.."Orca.views.Pages")) setfenv(fn, newEnv("Orca.views.Pages")) return fn() end)

newModule("Apps", "ModuleScript", "Orca.views.Pages.Apps", "Orca.views.Pages", function () local fn = assert(loadstring("-- Compiled with roblox-ts v1.2.7\
local TS = require(script.Parent.Parent.Parent.include.RuntimeLib)\
local exports = {}\
exports.default = TS.import(script, script, \"Apps\").default\
return exports\
", '@'.."Orca.views.Pages.Apps")) setfenv(fn, newEnv("Orca.views.Pages.Apps")) return fn() end)

newModule("Apps", "ModuleScript", "Orca.views.Pages.Apps.Apps", "Orca.views.Pages.Apps", function () local fn = assert(loadstring("-- Compiled with roblox-ts v1.2.7\
local TS = require(script.Parent.Parent.Parent.Parent.include.RuntimeLib)\
local Roact = TS.import(script, TS.getModule(script, \"@rbxts\", \"roact\").src)\
local pure = TS.import(script, TS.getModule(script, \"@rbxts\", \"roact-hooked\").out).pure\
local Canvas = TS.import(script, script.Parent.Parent.Parent.Parent, \"components\", \"Canvas\").default\
local useScale = TS.import(script, script.Parent.Parent.Parent.Parent, \"hooks\", \"use-scale\").useScale\
local scale = TS.import(script, script.Parent.Parent.Parent.Parent, \"utils\", \"udim2\").scale\
local Players = TS.import(script, script.Parent, \"Players\").default\
local function Apps()\
\9local scaleFactor = useScale()\
\9return Roact.createElement(Canvas, {\
\9\9position = scale(0, 1),\
\9\9anchor = Vector2.new(0, 1),\
\9}, {\
\9\9Roact.createElement(\"UIScale\", {\
\9\9\9Scale = scaleFactor,\
\9\9}),\
\9\9Roact.createElement(Players),\
\9})\
end\
local default = pure(Apps)\
return {\
\9default = default,\
}\
", '@'.."Orca.views.Pages.Apps.Apps")) setfenv(fn, newEnv("Orca.views.Pages.Apps.Apps")) return fn() end)

newModule("Players", "ModuleScript", "Orca.views.Pages.Apps.Players", "Orca.views.Pages.Apps", function () local fn = assert(loadstring("-- Compiled with roblox-ts v1.2.7\
local TS = require(script.Parent.Parent.Parent.Parent.include.RuntimeLib)\
local exports = {}\
exports.default = TS.import(script, script, \"Players\").default\
return exports\
", '@'.."Orca.views.Pages.Apps.Players")) setfenv(fn, newEnv("Orca.views.Pages.Apps.Players")) return fn() end)

newModule("Actions", "ModuleScript", "Orca.views.Pages.Apps.Players.Actions", "Orca.views.Pages.Apps.Players", function () local fn = assert(loadstring("-- Compiled with roblox-ts v1.2.7\
local TS = require(script.Parent.Parent.Parent.Parent.Parent.include.RuntimeLib)\
local Roact = TS.import(script, TS.getModule(script, \"@rbxts\", \"roact\").src)\
local hooked = TS.import(script, TS.getModule(script, \"@rbxts\", \"roact-hooked\").out).hooked\
local ActionButton = TS.import(script, script.Parent.Parent.Parent.Parent.Parent, \"components\", \"ActionButton\").default\
local Canvas = TS.import(script, script.Parent.Parent.Parent.Parent.Parent, \"components\", \"Canvas\").default\
local useTheme = TS.import(script, script.Parent.Parent.Parent.Parent.Parent, \"hooks\", \"use-theme\").useTheme\
local px = TS.import(script, script.Parent.Parent.Parent.Parent.Parent, \"utils\", \"udim2\").px\
local function Actions()\
\9local theme = useTheme(\"apps\").players\
\9return Roact.createElement(Canvas, {\
\9\9anchor = Vector2.new(0.5, 0),\
\9\9size = px(278, 49),\
\9\9position = UDim2.new(0.5, 0, 0, 304),\
\9}, {\
\9\9Roact.createElement(ActionButton, {\
\9\9\9action = \"teleport\",\
\9\9\9hint = \"<font face='GothamBlack'>Teleport to</font> this player, tap again to cancel\",\
\9\9\9theme = theme,\
\9\9\9image = \"rbxassetid://8992042585\",\
\9\9\9position = px(0, 0),\
\9\9\9canDeactivate = true,\
\9\9}),\
\9\9Roact.createElement(ActionButton, {\
\9\9\9action = \"hide\",\
\9\9\9hint = \"<font face='GothamBlack'>Hide</font> this player's character; persists between players\",\
\9\9\9theme = theme,\
\9\9\9image = \"rbxassetid://8992042653\",\
\9\9\9position = px(72, 0),\
\9\9\9canDeactivate = true,\
\9\9}),\
\9\9Roact.createElement(ActionButton, {\
\9\9\9action = \"kill\",\
\9\9\9hint = \"<font face='GothamBlack'>Kill</font> this player with a tool handle\",\
\9\9\9theme = theme,\
\9\9\9image = \"rbxassetid://8992042471\",\
\9\9\9position = px(145, 0),\
\9\9}),\
\9\9Roact.createElement(ActionButton, {\
\9\9\9action = \"spectate\",\
\9\9\9hint = \"<font face='GothamBlack'>Spectate</font> this player\",\
\9\9\9theme = theme,\
\9\9\9image = \"rbxassetid://8992042721\",\
\9\9\9position = px(217, 0),\
\9\9\9canDeactivate = true,\
\9\9}),\
\9})\
end\
local default = hooked(Actions)\
return {\
\9default = default,\
}\
", '@'.."Orca.views.Pages.Apps.Players.Actions")) setfenv(fn, newEnv("Orca.views.Pages.Apps.Players.Actions")) return fn() end)

newModule("Avatar", "ModuleScript", "Orca.views.Pages.Apps.Players.Avatar", "Orca.views.Pages.Apps.Players", function () local fn = assert(loadstring("-- Compiled with roblox-ts v1.2.7\
local TS = require(script.Parent.Parent.Parent.Parent.Parent.include.RuntimeLib)\
local Roact = TS.import(script, TS.getModule(script, \"@rbxts\", \"roact\").src)\
local hooked = TS.import(script, TS.getModule(script, \"@rbxts\", \"roact-hooked\").out).hooked\
local Players = TS.import(script, TS.getModule(script, \"@rbxts\", \"services\")).Players\
local Border = TS.import(script, script.Parent.Parent.Parent.Parent.Parent, \"components\", \"Border\").default\
local Canvas = TS.import(script, script.Parent.Parent.Parent.Parent.Parent, \"components\", \"Canvas\").default\
local useAppSelector = TS.import(script, script.Parent.Parent.Parent.Parent.Parent, \"hooks\", \"common\", \"rodux-hooks\").useAppSelector\
local useTheme = TS.import(script, script.Parent.Parent.Parent.Parent.Parent, \"hooks\", \"use-theme\").useTheme\
local px = TS.import(script, script.Parent.Parent.Parent.Parent.Parent, \"utils\", \"udim2\").px\
local function Avatar()\
\9local theme = useTheme(\"apps\").players\
\9local playerSelected = useAppSelector(function(state)\
\9\9local _result\
\9\9if state.dashboard.apps.playerSelected ~= nil then\
\9\9\9_result = (Players:FindFirstChild(state.dashboard.apps.playerSelected))\
\9\9else\
\9\9\9_result = nil\
\9\9end\
\9\9return _result\
\9end)\
\9return Roact.createElement(Canvas, {\
\9\9anchor = Vector2.new(0.5, 0),\
\9\9size = px(186, 186),\
\9\9position = UDim2.new(0.5, 0, 0, 24),\
\9}, {\
\9\9Roact.createElement(\"ImageLabel\", {\
\9\9\9Image = \"https://www.roblox.com/headshot-thumbnail/image?userId=\" .. (tostring(playerSelected and playerSelected.UserId or Players.LocalPlayer.UserId) .. \"&width=150&height=150&format=png\"),\
\9\9\9Size = px(150, 150),\
\9\9\9Position = px(18, 18),\
\9\9\9BackgroundColor3 = theme.avatar.background,\
\9\9\9BackgroundTransparency = theme.avatar.transparency,\
\9\9}, {\
\9\9\9Roact.createElement(\"UICorner\", {\
\9\9\9\9CornerRadius = UDim.new(1, 0),\
\9\9\9}),\
\9\9}),\
\9\9Roact.createElement(Border, {\
\9\9\9size = 4,\
\9\9\9radius = \"circular\",\
\9\9}, {\
\9\9\9Roact.createElement(\"UIGradient\", {\
\9\9\9\9Color = theme.avatar.gradient.color,\
\9\9\9\9Transparency = theme.avatar.gradient.transparency,\
\9\9\9\9Rotation = theme.avatar.gradient.rotation,\
\9\9\9}),\
\9\9}),\
\9})\
end\
local default = hooked(Avatar)\
return {\
\9default = default,\
}\
", '@'.."Orca.views.Pages.Apps.Players.Avatar")) setfenv(fn, newEnv("Orca.views.Pages.Apps.Players.Avatar")) return fn() end)

newModule("Players", "ModuleScript", "Orca.views.Pages.Apps.Players.Players", "Orca.views.Pages.Apps.Players", function () local fn = assert(loadstring("-- Compiled with roblox-ts v1.2.7\
local TS = require(script.Parent.Parent.Parent.Parent.Parent.include.RuntimeLib)\
local Roact = TS.import(script, TS.getModule(script, \"@rbxts\", \"roact\").src)\
local hooked = TS.import(script, TS.getModule(script, \"@rbxts\", \"roact-hooked\").out).hooked\
local Card = TS.import(script, script.Parent.Parent.Parent.Parent.Parent, \"components\", \"Card\").default\
local useTheme = TS.import(script, script.Parent.Parent.Parent.Parent.Parent, \"hooks\", \"use-theme\").useTheme\
local DashboardPage = TS.import(script, script.Parent.Parent.Parent.Parent.Parent, \"store\", \"models\", \"dashboard.model\").DashboardPage\
local px = TS.import(script, script.Parent.Parent.Parent.Parent.Parent, \"utils\", \"udim2\").px\
local Actions = TS.import(script, script.Parent, \"Actions\").default\
local Avatar = TS.import(script, script.Parent, \"Avatar\").default\
local Selection = TS.import(script, script.Parent, \"Selection\").default\
local Username = TS.import(script, script.Parent, \"Username\").default\
local function Players()\
\9local theme = useTheme(\"apps\").players\
\9return Roact.createElement(Card, {\
\9\9index = 1,\
\9\9page = DashboardPage.Apps,\
\9\9theme = theme,\
\9\9size = px(326, 648),\
\9\9position = UDim2.new(0, 0, 1, 0),\
\9}, {\
\9\9Roact.createElement(Avatar),\
\9\9Roact.createElement(Username),\
\9\9Roact.createElement(Actions),\
\9\9Roact.createElement(Selection),\
\9})\
end\
local default = hooked(Players)\
return {\
\9default = default,\
}\
", '@'.."Orca.views.Pages.Apps.Players.Players")) setfenv(fn, newEnv("Orca.views.Pages.Apps.Players.Players")) return fn() end)

newModule("Selection", "ModuleScript", "Orca.views.Pages.Apps.Players.Selection", "Orca.views.Pages.Apps.Players", function () local fn = assert(loadstring("-- Compiled with roblox-ts v1.2.7\
local TS = require(script.Parent.Parent.Parent.Parent.Parent.include.RuntimeLib)\
local Roact = TS.import(script, TS.getModule(script, \"@rbxts\", \"roact\").src)\
local _roact_hooked = TS.import(script, TS.getModule(script, \"@rbxts\", \"roact-hooked\").out)\
local hooked = _roact_hooked.hooked\
local useEffect = _roact_hooked.useEffect\
local useMemo = _roact_hooked.useMemo\
local useState = _roact_hooked.useState\
local _services = TS.import(script, TS.getModule(script, \"@rbxts\", \"services\"))\
local Players = _services.Players\
local TextService = _services.TextService\
local Border = TS.import(script, script.Parent.Parent.Parent.Parent.Parent, \"components\", \"Border\").default\
local Canvas = TS.import(script, script.Parent.Parent.Parent.Parent.Parent, \"components\", \"Canvas\").default\
local Fill = TS.import(script, script.Parent.Parent.Parent.Parent.Parent, \"components\", \"Fill\").default\
local _Glow = TS.import(script, script.Parent.Parent.Parent.Parent.Parent, \"components\", \"Glow\")\
local Glow = _Glow.default\
local GlowRadius = _Glow.GlowRadius\
local IS_DEV = TS.import(script, script.Parent.Parent.Parent.Parent.Parent, \"constants\").IS_DEV\
local useLinear = TS.import(script, script.Parent.Parent.Parent.Parent.Parent, \"hooks\", \"common\", \"flipper-hooks\").useLinear\
local _rodux_hooks = TS.import(script, script.Parent.Parent.Parent.Parent.Parent, \"hooks\", \"common\", \"rodux-hooks\")\
local useAppDispatch = _rodux_hooks.useAppDispatch\
local useAppSelector = _rodux_hooks.useAppSelector\
local useDelayedUpdate = TS.import(script, script.Parent.Parent.Parent.Parent.Parent, \"hooks\", \"common\", \"use-delayed-update\").useDelayedUpdate\
local useSpring = TS.import(script, script.Parent.Parent.Parent.Parent.Parent, \"hooks\", \"common\", \"use-spring\").useSpring\
local useIsPageOpen = TS.import(script, script.Parent.Parent.Parent.Parent.Parent, \"hooks\", \"use-current-page\").useIsPageOpen\
local useTheme = TS.import(script, script.Parent.Parent.Parent.Parent.Parent, \"hooks\", \"use-theme\").useTheme\
local _dashboard_action = TS.import(script, script.Parent.Parent.Parent.Parent.Parent, \"store\", \"actions\", \"dashboard.action\")\
local playerDeselected = _dashboard_action.playerDeselected\
local playerSelected = _dashboard_action.playerSelected\
local DashboardPage = TS.import(script, script.Parent.Parent.Parent.Parent.Parent, \"store\", \"models\", \"dashboard.model\").DashboardPage\
local arrayToMap = TS.import(script, script.Parent.Parent.Parent.Parent.Parent, \"utils\", \"array-util\").arrayToMap\
local lerp = TS.import(script, script.Parent.Parent.Parent.Parent.Parent, \"utils\", \"number-util\").lerp\
local _udim2 = TS.import(script, script.Parent.Parent.Parent.Parent.Parent, \"utils\", \"udim2\")\
local px = _udim2.px\
local scale = _udim2.scale\
local PADDING = 20\
local ENTRY_HEIGHT = 60\
local ENTRY_WIDTH = 326 - 24 * 2\
local ENTRY_TEXT_PADDING = 60\
local textFadeSequence = NumberSequence.new({ NumberSequenceKeypoint.new(0, 1), NumberSequenceKeypoint.new(0.05, 0), NumberSequenceKeypoint.new(0.9, 0), NumberSequenceKeypoint.new(0.95, 1), NumberSequenceKeypoint.new(1, 1) })\
local function usePlayers()\
\9local _binding = useState(Players:GetPlayers())\
\9local players = _binding[1]\
\9local setPlayers = _binding[2]\
\9useEffect(function()\
\9\9local addedHandle = Players.PlayerAdded:Connect(function()\
\9\9\9setPlayers(Players:GetPlayers())\
\9\9end)\
\9\9local removingHandle = Players.PlayerRemoving:Connect(function()\
\9\9\9setPlayers(Players:GetPlayers())\
\9\9end)\
\9\9return function()\
\9\9\9addedHandle:Disconnect()\
\9\9\9removingHandle:Disconnect()\
\9\9end\
\9end, {})\
\9return players\
end\
local PlayerEntry\
local function Selection()\
\9local dispatch = useAppDispatch()\
\9local players = usePlayers()\
\9local playerSelected = useAppSelector(function(state)\
\9\9return state.dashboard.apps.playerSelected\
\9end)\
\9local sortedPlayers = useMemo(function()\
\9\9local _arg0 = function(p)\
\9\9\9return p.Name == playerSelected\
\9\9end\
\9\9-- ▼ ReadonlyArray.find ▼\
\9\9local _result = nil\
\9\9for _i, _v in ipairs(players) do\
\9\9\9if _arg0(_v, _i - 1, players) == true then\
\9\9\9\9_result = _v\
\9\9\9\9break\
\9\9\9end\
\9\9end\
\9\9-- ▲ ReadonlyArray.find ▲\
\9\9local selected = _result\
\9\9local _arg0_1 = function(p)\
\9\9\9return p.Name ~= playerSelected and (p ~= Players.LocalPlayer or IS_DEV)\
\9\9end\
\9\9-- ▼ ReadonlyArray.filter ▼\
\9\9local _newValue = {}\
\9\9local _length = 0\
\9\9for _k, _v in ipairs(players) do\
\9\9\9if _arg0_1(_v, _k - 1, players) == true then\
\9\9\9\9_length += 1\
\9\9\9\9_newValue[_length] = _v\
\9\9\9end\
\9\9end\
\9\9-- ▲ ReadonlyArray.filter ▲\
\9\9local _arg0_2 = function(a, b)\
\9\9\9return string.lower(a.Name) < string.lower(b.Name)\
\9\9end\
\9\9-- ▼ Array.sort ▼\
\9\9table.sort(_newValue, _arg0_2)\
\9\9-- ▲ Array.sort ▲\
\9\9local sorted = _newValue\
\9\9local _result_1\
\9\9if selected then\
\9\9\9local _array = { selected }\
\9\9\9local _length_1 = #_array\
\9\9\9table.move(sorted, 1, #sorted, _length_1 + 1, _array)\
\9\9\9_result_1 = _array\
\9\9else\
\9\9\9_result_1 = sorted\
\9\9end\
\9\9return _result_1\
\9end, { players, playerSelected })\
\9useEffect(function()\
\9\9local _condition = playerSelected ~= nil\
\9\9if _condition then\
\9\9\9local _arg0 = function(player)\
\9\9\9\9return player.Name == playerSelected\
\9\9\9end\
\9\9\9-- ▼ ReadonlyArray.find ▼\
\9\9\9local _result = nil\
\9\9\9for _i, _v in ipairs(sortedPlayers) do\
\9\9\9\9if _arg0(_v, _i - 1, sortedPlayers) == true then\
\9\9\9\9\9_result = _v\
\9\9\9\9\9break\
\9\9\9\9end\
\9\9\9end\
\9\9\9-- ▲ ReadonlyArray.find ▲\
\9\9\9_condition = not _result\
\9\9end\
\9\9if _condition then\
\9\9\9dispatch(playerDeselected())\
\9\9end\
\9end, { players, playerSelected })\
\9local _attributes = {\
\9\9size = px(326, 280),\
\9\9position = px(0, 368),\
\9\9padding = {\
\9\9\9left = 24,\
\9\9\9right = 24,\
\9\9\9top = 8,\
\9\9},\
\9\9clipsDescendants = true,\
\9}\
\9local _children = {}\
\9local _length = #_children\
\9local _attributes_1 = {\
\9\9Size = scale(1, 1),\
\9\9CanvasSize = px(0, #sortedPlayers * (ENTRY_HEIGHT + PADDING) + PADDING),\
\9\9BackgroundTransparency = 1,\
\9\9BorderSizePixel = 0,\
\9\9ScrollBarImageTransparency = 1,\
\9\9ScrollBarThickness = 0,\
\9\9ClipsDescendants = false,\
\9}\
\9local _children_1 = {}\
\9local _length_1 = #_children_1\
\9for _k, _v in pairs(arrayToMap(sortedPlayers, function(player, index)\
\9\9return { player.Name, Roact.createElement(PlayerEntry, {\
\9\9\9name = player.Name,\
\9\9\9displayName = player.DisplayName,\
\9\9\9userId = player.UserId,\
\9\9\9index = index,\
\9\9}) }\
\9end)) do\
\9\9_children_1[_k] = _v\
\9end\
\9_children[_length + 1] = Roact.createElement(\"ScrollingFrame\", _attributes_1, _children_1)\
\9return Roact.createElement(Canvas, _attributes, _children)\
end\
local default = hooked(Selection)\
local function PlayerEntryComponent(_param)\
\9local name = _param.name\
\9local userId = _param.userId\
\9local displayName = _param.displayName\
\9local index = _param.index\
\9local dispatch = useAppDispatch()\
\9local theme = useTheme(\"apps\").players.playerButton\
\9local isOpen = useIsPageOpen(DashboardPage.Apps)\
\9local isVisible = useDelayedUpdate(isOpen, isOpen and 170 + index * 40 or 150)\
\9local isSelected = useAppSelector(function(state)\
\9\9return state.dashboard.apps.playerSelected == name\
\9end)\
\9local _binding = useState(false)\
\9local hovered = _binding[1]\
\9local setHovered = _binding[2]\
\9local text = \"  \" .. (displayName .. (\" (@\" .. (name .. \")\")))\
\9local textSize = useMemo(function()\
\9\9return TextService:GetTextSize(text, 14, Enum.Font.GothamBold, Vector2.new(1000, ENTRY_HEIGHT))\
\9end, { text })\
\9local textScrollOffset = useLinear(hovered and ENTRY_WIDTH - ENTRY_TEXT_PADDING - 20 - textSize.X or 0, {\
\9\9velocity = hovered and 40 or 150,\
\9}):map(function(x)\
\9\9return UDim.new(0, math.min(x, 0))\
\9end)\
\9local _result\
\9if isSelected then\
\9\9_result = theme.accent\
\9else\
\9\9local _result_1\
\9\9if hovered then\
\9\9\9local _condition = theme.backgroundHovered\
\9\9\9if _condition == nil then\
\9\9\9\9_condition = theme.background:Lerp(theme.accent, 0.1)\
\9\9\9end\
\9\9\9_result_1 = _condition\
\9\9else\
\9\9\9_result_1 = theme.background\
\9\9end\
\9\9_result = _result_1\
\9end\
\9local background = useSpring(_result, {})\
\9local _result_1\
\9if isSelected then\
\9\9_result_1 = theme.accent\
\9else\
\9\9local _result_2\
\9\9if hovered then\
\9\9\9local _condition = theme.backgroundHovered\
\9\9\9if _condition == nil then\
\9\9\9\9_condition = theme.dropshadow:Lerp(theme.accent, 0.5)\
\9\9\9end\
\9\9\9_result_2 = _condition\
\9\9else\
\9\9\9_result_2 = theme.dropshadow\
\9\9end\
\9\9_result_1 = _result_2\
\9end\
\9local dropshadow = useSpring(_result_1, {})\
\9local foreground = useSpring(isSelected and theme.foregroundAccent and theme.foregroundAccent or theme.foreground, {})\
\9local _attributes = {\
\9\9size = px(ENTRY_WIDTH, ENTRY_HEIGHT),\
\9\9position = useSpring(isVisible and px(0, (PADDING + ENTRY_HEIGHT) * index) or px(-ENTRY_WIDTH - 24, (PADDING + ENTRY_HEIGHT) * index), {}),\
\9\9zIndex = index,\
\9}\
\9local _children = {\
\9\9Roact.createElement(Glow, {\
\9\9\9radius = GlowRadius.Size70,\
\9\9\9color = dropshadow,\
\9\9\9size = UDim2.new(1, 36, 1, 36),\
\9\9\9position = px(-18, 5 - 18),\
\9\9\9transparency = useSpring(isSelected and theme.glowTransparency or (hovered and lerp(theme.dropshadowTransparency, theme.glowTransparency, 0.5) or theme.dropshadowTransparency), {}),\
\9\9}),\
\9\9Roact.createElement(Fill, {\
\9\9\9color = background,\
\9\9\9transparency = useSpring(theme.backgroundTransparency, {}),\
\9\9\9radius = 8,\
\9\9}),\
\9\9Roact.createElement(\"TextLabel\", {\
\9\9\9Text = text,\
\9\9\9Font = \"GothamBold\",\
\9\9\9TextSize = 14,\
\9\9\9TextColor3 = foreground,\
\9\9\9TextXAlignment = Enum.TextXAlignment.Left,\
\9\9\9TextYAlignment = Enum.TextYAlignment.Center,\
\9\9\9TextTransparency = useSpring(isSelected and 0 or (hovered and theme.foregroundTransparency / 2 or theme.foregroundTransparency), {}),\
\9\9\9BackgroundTransparency = 1,\
\9\9\9Position = px(ENTRY_TEXT_PADDING, 1),\
\9\9\9Size = UDim2.new(1, -ENTRY_TEXT_PADDING, 1, -1),\
\9\9\9ClipsDescendants = true,\
\9\9}, {\
\9\9\9Roact.createElement(\"UIPadding\", {\
\9\9\9\9PaddingLeft = textScrollOffset,\
\9\9\9}),\
\9\9\9Roact.createElement(\"UIGradient\", {\
\9\9\9\9Transparency = textFadeSequence,\
\9\9\9}),\
\9\9}),\
\9\9Roact.createElement(\"ImageLabel\", {\
\9\9\9Image = \"https://www.roblox.com/headshot-thumbnail/image?userId=\" .. (tostring(userId) .. \"&width=60&height=60&format=png\"),\
\9\9\9Size = UDim2.new(0, ENTRY_HEIGHT, 0, ENTRY_HEIGHT),\
\9\9\9BackgroundTransparency = 1,\
\9\9}, {\
\9\9\9Roact.createElement(\"UICorner\", {\
\9\9\9\9CornerRadius = UDim.new(0, 8),\
\9\9\9}),\
\9\9}),\
\9}\
\9local _length = #_children\
\9local _child = theme.outlined and Roact.createElement(Border, {\
\9\9color = foreground,\
\9\9transparency = 0.8,\
\9\9radius = 8,\
\9})\
\9if _child then\
\9\9if _child.elements ~= nil or _child.props ~= nil and _child.component ~= nil then\
\9\9\9_children[_length + 1] = _child\
\9\9else\
\9\9\9for _k, _v in ipairs(_child) do\
\9\9\9\9_children[_length + _k] = _v\
\9\9\9end\
\9\9end\
\9end\
\9_length = #_children\
\9_children[_length + 1] = Roact.createElement(\"TextButton\", {\
\9\9[Roact.Event.Activated] = function()\
\9\9\9local player = Players:FindFirstChild(name)\
\9\9\9local _condition = not isSelected\
\9\9\9if _condition then\
\9\9\9\9local _result_2 = player\
\9\9\9\9if _result_2 ~= nil then\
\9\9\9\9\9_result_2 = _result_2:IsA(\"Player\")\
\9\9\9\9end\
\9\9\9\9_condition = _result_2\
\9\9\9end\
\9\9\9if _condition then\
\9\9\9\9dispatch(playerSelected(player))\
\9\9\9else\
\9\9\9\9dispatch(playerDeselected())\
\9\9\9end\
\9\9end,\
\9\9[Roact.Event.MouseEnter] = function()\
\9\9\9return setHovered(true)\
\9\9end,\
\9\9[Roact.Event.MouseLeave] = function()\
\9\9\9return setHovered(false)\
\9\9end,\
\9\9Text = \"\",\
\9\9Transparency = 1,\
\9\9Size = scale(1, 1),\
\9})\
\9return Roact.createElement(Canvas, _attributes, _children)\
end\
PlayerEntry = hooked(PlayerEntryComponent)\
return {\
\9default = default,\
}\
", '@'.."Orca.views.Pages.Apps.Players.Selection")) setfenv(fn, newEnv("Orca.views.Pages.Apps.Players.Selection")) return fn() end)

newModule("Username", "ModuleScript", "Orca.views.Pages.Apps.Players.Username", "Orca.views.Pages.Apps.Players", function () local fn = assert(loadstring("-- Compiled with roblox-ts v1.2.7\
local TS = require(script.Parent.Parent.Parent.Parent.Parent.include.RuntimeLib)\
local Roact = TS.import(script, TS.getModule(script, \"@rbxts\", \"roact\").src)\
local hooked = TS.import(script, TS.getModule(script, \"@rbxts\", \"roact-hooked\").out).hooked\
local Players = TS.import(script, TS.getModule(script, \"@rbxts\", \"services\")).Players\
local Canvas = TS.import(script, script.Parent.Parent.Parent.Parent.Parent, \"components\", \"Canvas\").default\
local useAppSelector = TS.import(script, script.Parent.Parent.Parent.Parent.Parent, \"hooks\", \"common\", \"rodux-hooks\").useAppSelector\
local useTheme = TS.import(script, script.Parent.Parent.Parent.Parent.Parent, \"hooks\", \"use-theme\").useTheme\
local _udim2 = TS.import(script, script.Parent.Parent.Parent.Parent.Parent, \"utils\", \"udim2\")\
local px = _udim2.px\
local scale = _udim2.scale\
local function Username()\
\9local theme = useTheme(\"apps\").players\
\9local playerSelected = useAppSelector(function(state)\
\9\9local _result\
\9\9if state.dashboard.apps.playerSelected ~= nil then\
\9\9\9_result = (Players:FindFirstChild(state.dashboard.apps.playerSelected))\
\9\9else\
\9\9\9_result = nil\
\9\9end\
\9\9return _result\
\9end)\
\9return Roact.createElement(Canvas, {\
\9\9anchor = Vector2.new(0.5, 0),\
\9\9size = px(278, 49),\
\9\9position = UDim2.new(0.5, 0, 0, 231),\
\9}, {\
\9\9Roact.createElement(\"TextLabel\", {\
\9\9\9Font = \"GothamBlack\",\
\9\9\9Text = playerSelected and playerSelected.DisplayName or \"N/A\",\
\9\9\9TextSize = 20,\
\9\9\9TextColor3 = theme.foreground,\
\9\9\9TextXAlignment = \"Center\",\
\9\9\9TextYAlignment = \"Top\",\
\9\9\9Size = scale(1, 1),\
\9\9\9BackgroundTransparency = 1,\
\9\9}),\
\9\9Roact.createElement(\"TextLabel\", {\
\9\9\9Font = \"GothamBold\",\
\9\9\9Text = playerSelected and playerSelected.Name or \"Select a player\",\
\9\9\9TextSize = 16,\
\9\9\9TextColor3 = theme.foreground,\
\9\9\9TextXAlignment = \"Center\",\
\9\9\9TextYAlignment = \"Bottom\",\
\9\9\9TextTransparency = 0.7,\
\9\9\9Size = scale(1, 1),\
\9\9\9BackgroundTransparency = 1,\
\9\9}),\
\9})\
end\
local default = hooked(Username)\
return {\
\9default = default,\
}\
", '@'.."Orca.views.Pages.Apps.Players.Username")) setfenv(fn, newEnv("Orca.views.Pages.Apps.Players.Username")) return fn() end)

newModule("Home", "ModuleScript", "Orca.views.Pages.Home", "Orca.views.Pages", function () local fn = assert(loadstring("-- Compiled with roblox-ts v1.2.7\
local TS = require(script.Parent.Parent.Parent.include.RuntimeLib)\
local exports = {}\
exports.default = TS.import(script, script, \"Home\").default\
return exports\
", '@'.."Orca.views.Pages.Home")) setfenv(fn, newEnv("Orca.views.Pages.Home")) return fn() end)

newModule("FriendActivity", "ModuleScript", "Orca.views.Pages.Home.FriendActivity", "Orca.views.Pages.Home", function () local fn = assert(loadstring("-- Compiled with roblox-ts v1.2.7\
local TS = require(script.Parent.Parent.Parent.Parent.include.RuntimeLib)\
local exports = {}\
exports.default = TS.import(script, script, \"FriendActivity\").default\
return exports\
", '@'.."Orca.views.Pages.Home.FriendActivity")) setfenv(fn, newEnv("Orca.views.Pages.Home.FriendActivity")) return fn() end)

newModule("FriendActivity", "ModuleScript", "Orca.views.Pages.Home.FriendActivity.FriendActivity", "Orca.views.Pages.Home.FriendActivity", function () local fn = assert(loadstring("-- Compiled with roblox-ts v1.2.7\
local TS = require(script.Parent.Parent.Parent.Parent.Parent.include.RuntimeLib)\
local Roact = TS.import(script, TS.getModule(script, \"@rbxts\", \"roact\").src)\
local _roact_hooked = TS.import(script, TS.getModule(script, \"@rbxts\", \"roact-hooked\").out)\
local hooked = _roact_hooked.hooked\
local useEffect = _roact_hooked.useEffect\
local useReducer = _roact_hooked.useReducer\
local useState = _roact_hooked.useState\
local Canvas = TS.import(script, script.Parent.Parent.Parent.Parent.Parent, \"components\", \"Canvas\").default\
local Card = TS.import(script, script.Parent.Parent.Parent.Parent.Parent, \"components\", \"Card\").default\
local useInterval = TS.import(script, script.Parent.Parent.Parent.Parent.Parent, \"hooks\", \"common\", \"use-interval\").useInterval\
local useSpring = TS.import(script, script.Parent.Parent.Parent.Parent.Parent, \"hooks\", \"common\", \"use-spring\").useSpring\
local useFriendActivity = TS.import(script, script.Parent.Parent.Parent.Parent.Parent, \"hooks\", \"use-friends\").useFriendActivity\
local useTheme = TS.import(script, script.Parent.Parent.Parent.Parent.Parent, \"hooks\", \"use-theme\").useTheme\
local DashboardPage = TS.import(script, script.Parent.Parent.Parent.Parent.Parent, \"store\", \"models\", \"dashboard.model\").DashboardPage\
local arrayToMap = TS.import(script, script.Parent.Parent.Parent.Parent.Parent, \"utils\", \"array-util\").arrayToMap\
local _udim2 = TS.import(script, script.Parent.Parent.Parent.Parent.Parent, \"utils\", \"udim2\")\
local px = _udim2.px\
local scale = _udim2.scale\
local _GameItem = TS.import(script, script.Parent, \"GameItem\")\
local GameItem = _GameItem.default\
local GAME_PADDING = _GameItem.GAME_PADDING\
local function FriendActivity()\
\9local theme = useTheme(\"home\").friendActivity\
\9local _binding = useReducer(function(state)\
\9\9return state + 1\
\9end, 0)\
\9local update = _binding[1]\
\9local forceUpdate = _binding[2]\
\9local _binding_1 = useFriendActivity({ update })\
\9local currentGames = _binding_1[1]\
\9local status = _binding_1[3]\
\9local _binding_2 = useState(currentGames)\
\9local games = _binding_2[1]\
\9local setGames = _binding_2[2]\
\9useEffect(function()\
\9\9if #currentGames > 0 then\
\9\9\9local _arg0 = function(a, b)\
\9\9\9\9return #a.friends > #b.friends\
\9\9\9end\
\9\9\9-- ▼ Array.sort ▼\
\9\9\9table.sort(currentGames, _arg0)\
\9\9\9-- ▲ Array.sort ▲\
\9\9\9setGames(currentGames)\
\9\9end\
\9end, { currentGames })\
\9useInterval(function()\
\9\9return forceUpdate()\
\9end, #currentGames == 0 and status ~= \"pending\" and 5000 or 30000)\
\9local _attributes = {\
\9\9index = 3,\
\9\9page = DashboardPage.Home,\
\9\9theme = theme,\
\9\9size = px(326, 416),\
\9\9position = UDim2.new(0, 374, 1, 0),\
\9}\
\9local _children = {\
\9\9Roact.createElement(\"TextLabel\", {\
\9\9\9Text = \"Friend Activity\",\
\9\9\9Font = \"GothamBlack\",\
\9\9\9TextSize = 20,\
\9\9\9TextColor3 = theme.foreground,\
\9\9\9TextXAlignment = \"Left\",\
\9\9\9TextYAlignment = \"Top\",\
\9\9\9Position = px(24, 24),\
\9\9\9BackgroundTransparency = 1,\
\9\9}),\
\9}\
\9local _length = #_children\
\9local _attributes_1 = {\
\9\9anchor = Vector2.new(0, 1),\
\9\9size = useSpring(#games > 0 and UDim2.new(1, 0, 0, 344) or UDim2.new(1, 0, 0, 0), {}),\
\9\9position = scale(0, 1),\
\9}\
\9local _children_1 = {}\
\9local _length_1 = #_children_1\
\9local _attributes_2 = {\
\9\9Size = scale(1, 1),\
\9\9ScrollBarThickness = 0,\
\9\9ScrollBarImageTransparency = 1,\
\9\9ScrollingDirection = \"Y\",\
\9\9CanvasSize = px(0, #games * (GAME_PADDING + 156) + GAME_PADDING),\
\9\9BackgroundTransparency = 1,\
\9\9BorderSizePixel = 0,\
\9}\
\9local _children_2 = {}\
\9local _length_2 = #_children_2\
\9for _k, _v in pairs(arrayToMap(games, function(gameActivity, index)\
\9\9return { tostring(gameActivity.placeId), Roact.createElement(GameItem, {\
\9\9\9gameActivity = gameActivity,\
\9\9\9index = index,\
\9\9}) }\
\9end)) do\
\9\9_children_2[_k] = _v\
\9end\
\9_children_1[_length_1 + 1] = Roact.createElement(\"ScrollingFrame\", _attributes_2, _children_2)\
\9_children[_length + 1] = Roact.createElement(Canvas, _attributes_1, _children_1)\
\9return Roact.createElement(Card, _attributes, _children)\
end\
local default = hooked(FriendActivity)\
return {\
\9default = default,\
}\
", '@'.."Orca.views.Pages.Home.FriendActivity.FriendActivity")) setfenv(fn, newEnv("Orca.views.Pages.Home.FriendActivity.FriendActivity")) return fn() end)

newModule("FriendItem", "ModuleScript", "Orca.views.Pages.Home.FriendActivity.FriendItem", "Orca.views.Pages.Home.FriendActivity", function () local fn = assert(loadstring("-- Compiled with roblox-ts v1.2.7\
local TS = require(script.Parent.Parent.Parent.Parent.Parent.include.RuntimeLib)\
local Roact = TS.import(script, TS.getModule(script, \"@rbxts\", \"roact\").src)\
local _roact_hooked = TS.import(script, TS.getModule(script, \"@rbxts\", \"roact-hooked\").out)\
local hooked = _roact_hooked.hooked\
local useState = _roact_hooked.useState\
local _services = TS.import(script, TS.getModule(script, \"@rbxts\", \"services\"))\
local Players = _services.Players\
local TeleportService = _services.TeleportService\
local Border = TS.import(script, script.Parent.Parent.Parent.Parent.Parent, \"components\", \"Border\").default\
local Canvas = TS.import(script, script.Parent.Parent.Parent.Parent.Parent, \"components\", \"Canvas\").default\
local Fill = TS.import(script, script.Parent.Parent.Parent.Parent.Parent, \"components\", \"Fill\").default\
local useSpring = TS.import(script, script.Parent.Parent.Parent.Parent.Parent, \"hooks\", \"common\", \"use-spring\").useSpring\
local useTheme = TS.import(script, script.Parent.Parent.Parent.Parent.Parent, \"hooks\", \"use-theme\").useTheme\
local _udim2 = TS.import(script, script.Parent.Parent.Parent.Parent.Parent, \"utils\", \"udim2\")\
local px = _udim2.px\
local scale = _udim2.scale\
local FRIEND_SPRING_OPTIONS = {\
\9frequency = 6,\
}\
local function FriendItem(_param)\
\9local friend = _param.friend\
\9local index = _param.index\
\9local theme = useTheme(\"home\").friendActivity.friendButton\
\9local _binding = useState(false)\
\9local isHovered = _binding[1]\
\9local setHovered = _binding[2]\
\9local avatar = \"https://www.roblox.com/headshot-thumbnail/image?userId=\" .. (tostring(friend.VisitorId) .. \"&width=48&height=48&format=png\")\
\9local _attributes = {\
\9\9size = useSpring(isHovered and px(96, 48) or px(48, 48), FRIEND_SPRING_OPTIONS),\
\9}\
\9local _children = {\
\9\9Roact.createElement(\"ImageLabel\", {\
\9\9\9Image = \"rbxassetid://8992244272\",\
\9\9\9ImageColor3 = useSpring(isHovered and theme.accent or theme.dropshadow, FRIEND_SPRING_OPTIONS),\
\9\9\9ImageTransparency = useSpring(isHovered and theme.glowTransparency or theme.dropshadowTransparency, FRIEND_SPRING_OPTIONS),\
\9\9\9Size = useSpring(isHovered and px(88 + 36, 74) or px(76, 74), FRIEND_SPRING_OPTIONS),\
\9\9\9Position = px(-14, -10),\
\9\9\9ScaleType = \"Slice\",\
\9\9\9SliceCenter = Rect.new(Vector2.new(42, 42), Vector2.new(42, 42)),\
\9\9\9BackgroundTransparency = 1,\
\9\9}),\
\9\9Roact.createElement(Fill, {\
\9\9\9radius = 24,\
\9\9\9color = useSpring(isHovered and theme.accent or theme.background, FRIEND_SPRING_OPTIONS),\
\9\9\9transparency = theme.backgroundTransparency,\
\9\9}),\
\9}\
\9local _length = #_children\
\9local _child = theme.outlined and (Roact.createFragment({\
\9\9border = Roact.createElement(Border, {\
\9\9\9radius = 23,\
\9\9\9color = isHovered and theme.foregroundAccent and theme.foregroundAccent or theme.foreground,\
\9\9\9transparency = 0.7,\
\9\9}),\
\9}))\
\9if _child then\
\9\9if _child.elements ~= nil or _child.props ~= nil and _child.component ~= nil then\
\9\9\9_children[_length + 1] = _child\
\9\9else\
\9\9\9for _k, _v in ipairs(_child) do\
\9\9\9\9_children[_length + _k] = _v\
\9\9\9end\
\9\9end\
\9end\
\9_length = #_children\
\9_children[_length + 1] = Roact.createElement(\"ImageLabel\", {\
\9\9Image = avatar,\
\9\9ScaleType = \"Crop\",\
\9\9Size = px(48, 48),\
\9\9LayoutOrder = index,\
\9\9BackgroundTransparency = 1,\
\9}, {\
\9\9Roact.createElement(\"UICorner\", {\
\9\9\9CornerRadius = UDim.new(1, 0),\
\9\9}),\
\9})\
\9_children[_length + 2] = Roact.createElement(Canvas, {\
\9\9clipsDescendants = true,\
\9}, {\
\9\9Roact.createElement(\"ImageLabel\", {\
\9\9\9Image = \"rbxassetid://8992244380\",\
\9\9\9ImageColor3 = isHovered and theme.foregroundAccent and theme.foregroundAccent or theme.foreground,\
\9\9\9ImageTransparency = theme.foregroundTransparency,\
\9\9\9Size = px(36, 36),\
\9\9\9Position = px(48, 6),\
\9\9\9BackgroundTransparency = 1,\
\9\9}),\
\9})\
\9_children[_length + 3] = Roact.createElement(\"TextButton\", {\
\9\9Text = \"\",\
\9\9AutoButtonColor = false,\
\9\9Size = scale(1, 1),\
\9\9BackgroundTransparency = 1,\
\9\9[Roact.Event.Activated] = function()\
\9\9\9pcall(function()\
\9\9\9\9TeleportService:TeleportToPlaceInstance(friend.PlaceId, friend.GameId, Players.LocalPlayer)\
\9\9\9end)\
\9\9end,\
\9\9[Roact.Event.MouseEnter] = function()\
\9\9\9return setHovered(true)\
\9\9end,\
\9\9[Roact.Event.MouseLeave] = function()\
\9\9\9return setHovered(false)\
\9\9end,\
\9})\
\9return Roact.createElement(Canvas, _attributes, _children)\
end\
local default = hooked(FriendItem)\
return {\
\9default = default,\
}\
", '@'.."Orca.views.Pages.Home.FriendActivity.FriendItem")) setfenv(fn, newEnv("Orca.views.Pages.Home.FriendActivity.FriendItem")) return fn() end)

newModule("GameItem", "ModuleScript", "Orca.views.Pages.Home.FriendActivity.GameItem", "Orca.views.Pages.Home.FriendActivity", function () local fn = assert(loadstring("-- Compiled with roblox-ts v1.2.7\
local TS = require(script.Parent.Parent.Parent.Parent.Parent.include.RuntimeLib)\
local Roact = TS.import(script, TS.getModule(script, \"@rbxts\", \"roact\").src)\
local _roact_hooked = TS.import(script, TS.getModule(script, \"@rbxts\", \"roact-hooked\").out)\
local pure = _roact_hooked.pure\
local useMemo = _roact_hooked.useMemo\
local Border = TS.import(script, script.Parent.Parent.Parent.Parent.Parent, \"components\", \"Border\").default\
local useDelayedUpdate = TS.import(script, script.Parent.Parent.Parent.Parent.Parent, \"hooks\", \"common\", \"use-delayed-update\").useDelayedUpdate\
local useSpring = TS.import(script, script.Parent.Parent.Parent.Parent.Parent, \"hooks\", \"common\", \"use-spring\").useSpring\
local useIsPageOpen = TS.import(script, script.Parent.Parent.Parent.Parent.Parent, \"hooks\", \"use-current-page\").useIsPageOpen\
local useTheme = TS.import(script, script.Parent.Parent.Parent.Parent.Parent, \"hooks\", \"use-theme\").useTheme\
local DashboardPage = TS.import(script, script.Parent.Parent.Parent.Parent.Parent, \"store\", \"models\", \"dashboard.model\").DashboardPage\
local px = TS.import(script, script.Parent.Parent.Parent.Parent.Parent, \"utils\", \"udim2\").px\
local FriendItem = TS.import(script, script.Parent, \"FriendItem\").default\
local GAME_PADDING = 48\
local function GameItem(_param)\
\9local gameActivity = _param.gameActivity\
\9local index = _param.index\
\9local theme = useTheme(\"home\").friendActivity\
\9local isOpen = useIsPageOpen(DashboardPage.Home)\
\9local isVisible = useDelayedUpdate(isOpen, isOpen and 330 + index * 100 or 300)\
\9local canvasLength = useMemo(function()\
\9\9return #gameActivity.friends * (48 + 10) + 96\
\9end, { #gameActivity.friends })\
\9local _attributes = {\
\9\9Image = gameActivity.thumbnail,\
\9\9ScaleType = \"Crop\",\
\9\9Size = px(278, 156),\
\9\9Position = useSpring(isVisible and px(24, index * (GAME_PADDING + 156)) or px(-278, index * (GAME_PADDING + 156)), {}),\
\9\9BackgroundTransparency = 1,\
\9}\
\9local _children = {\
\9\9Roact.createElement(Border, {\
\9\9\9color = theme.foreground,\
\9\9\9radius = 8,\
\9\9\9transparency = 0.8,\
\9\9}),\
\9\9Roact.createElement(\"UICorner\", {\
\9\9\9CornerRadius = UDim.new(0, 8),\
\9\9}),\
\9}\
\9local _length = #_children\
\9local _friends = gameActivity.friends\
\9local _arg0 = function(friend, index)\
\9\9return { tostring(friend.VisitorId), Roact.createElement(FriendItem, {\
\9\9\9friend = friend,\
\9\9\9index = index,\
\9\9}) }\
\9end\
\9-- ▼ ReadonlyArray.map ▼\
\9local _newValue = table.create(#_friends)\
\9for _k, _v in ipairs(_friends) do\
\9\9_newValue[_k] = _arg0(_v, _k - 1, _friends)\
\9end\
\9-- ▲ ReadonlyArray.map ▲\
\9local _map = {}\
\9for _, _v in ipairs(_newValue) do\
\9\9_map[_v[1]] = _v[2]\
\9end\
\9local _attributes_1 = {\
\9\9Size = UDim2.new(1, 0, 0, 64),\
\9\9Position = UDim2.new(0, 0, 1, -24),\
\9\9CanvasSize = px(canvasLength, 0),\
\9\9ScrollingDirection = \"X\",\
\9\9ScrollBarThickness = 0,\
\9\9ScrollBarImageTransparency = 1,\
\9\9BackgroundTransparency = 1,\
\9\9BorderSizePixel = 0,\
\9\9ClipsDescendants = false,\
\9}\
\9local _children_1 = {\
\9\9Roact.createElement(\"UIListLayout\", {\
\9\9\9SortOrder = \"LayoutOrder\",\
\9\9\9FillDirection = \"Horizontal\",\
\9\9\9HorizontalAlignment = \"Left\",\
\9\9\9VerticalAlignment = \"Top\",\
\9\9\9Padding = UDim.new(0, 10),\
\9\9}),\
\9\9Roact.createElement(\"UIPadding\", {\
\9\9\9PaddingLeft = UDim.new(0, 10),\
\9\9}),\
\9}\
\9local _length_1 = #_children_1\
\9for _k, _v in pairs(_map) do\
\9\9_children_1[_k] = _v\
\9end\
\9_children[_length + 1] = Roact.createElement(\"ScrollingFrame\", _attributes_1, _children_1)\
\9return Roact.createElement(\"ImageLabel\", _attributes, _children)\
end\
local default = pure(GameItem)\
return {\
\9GAME_PADDING = GAME_PADDING,\
\9default = default,\
}\
", '@'.."Orca.views.Pages.Home.FriendActivity.GameItem")) setfenv(fn, newEnv("Orca.views.Pages.Home.FriendActivity.GameItem")) return fn() end)

newModule("Home", "ModuleScript", "Orca.views.Pages.Home.Home", "Orca.views.Pages.Home", function () local fn = assert(loadstring("-- Compiled with roblox-ts v1.2.7\
local TS = require(script.Parent.Parent.Parent.Parent.include.RuntimeLib)\
local Roact = TS.import(script, TS.getModule(script, \"@rbxts\", \"roact\").src)\
local pure = TS.import(script, TS.getModule(script, \"@rbxts\", \"roact-hooked\").out).pure\
local Canvas = TS.import(script, script.Parent.Parent.Parent.Parent, \"components\", \"Canvas\").default\
local useScale = TS.import(script, script.Parent.Parent.Parent.Parent, \"hooks\", \"use-scale\").useScale\
local scale = TS.import(script, script.Parent.Parent.Parent.Parent, \"utils\", \"udim2\").scale\
local FriendActivity = TS.import(script, script.Parent, \"FriendActivity\").default\
local Profile = TS.import(script, script.Parent, \"Profile\").default\
local Server = TS.import(script, script.Parent, \"Server\").default\
local Title = TS.import(script, script.Parent, \"Title\").default\
local function Home()\
\9local scaleFactor = useScale()\
\9return Roact.createElement(Canvas, {\
\9\9position = scale(0, 1),\
\9\9anchor = Vector2.new(0, 1),\
\9}, {\
\9\9Roact.createElement(\"UIScale\", {\
\9\9\9Scale = scaleFactor,\
\9\9}),\
\9\9Roact.createElement(Title),\
\9\9Roact.createElement(Server),\
\9\9Roact.createElement(FriendActivity),\
\9\9Roact.createElement(Profile),\
\9})\
end\
local default = pure(Home)\
return {\
\9default = default,\
}\
", '@'.."Orca.views.Pages.Home.Home")) setfenv(fn, newEnv("Orca.views.Pages.Home.Home")) return fn() end)

newModule("Profile", "ModuleScript", "Orca.views.Pages.Home.Profile", "Orca.views.Pages.Home", function () local fn = assert(loadstring("-- Compiled with roblox-ts v1.2.7\
local TS = require(script.Parent.Parent.Parent.Parent.include.RuntimeLib)\
local exports = {}\
exports.default = TS.import(script, script, \"Profile\").default\
return exports\
", '@'.."Orca.views.Pages.Home.Profile")) setfenv(fn, newEnv("Orca.views.Pages.Home.Profile")) return fn() end)

newModule("Actions", "ModuleScript", "Orca.views.Pages.Home.Profile.Actions", "Orca.views.Pages.Home.Profile", function () local fn = assert(loadstring("-- Compiled with roblox-ts v1.2.7\
local TS = require(script.Parent.Parent.Parent.Parent.Parent.include.RuntimeLib)\
local Roact = TS.import(script, TS.getModule(script, \"@rbxts\", \"roact\").src)\
local hooked = TS.import(script, TS.getModule(script, \"@rbxts\", \"roact-hooked\").out).hooked\
local ActionButton = TS.import(script, script.Parent.Parent.Parent.Parent.Parent, \"components\", \"ActionButton\").default\
local Canvas = TS.import(script, script.Parent.Parent.Parent.Parent.Parent, \"components\", \"Canvas\").default\
local useTheme = TS.import(script, script.Parent.Parent.Parent.Parent.Parent, \"hooks\", \"use-theme\").useTheme\
local px = TS.import(script, script.Parent.Parent.Parent.Parent.Parent, \"utils\", \"udim2\").px\
local function Actions()\
\9local theme = useTheme(\"home\").profile\
\9return Roact.createElement(Canvas, {\
\9\9anchor = Vector2.new(0.5, 0),\
\9\9size = px(278, 49),\
\9\9position = UDim2.new(0.5, 0, 0, 575),\
\9}, {\
\9\9Roact.createElement(ActionButton, {\
\9\9\9action = \"refresh\",\
\9\9\9hint = \"<font face='GothamBlack'>Refresh</font> your character at this location\",\
\9\9\9theme = theme,\
\9\9\9image = \"rbxassetid://8992253511\",\
\9\9\9position = px(0, 0),\
\9\9}),\
\9\9Roact.createElement(ActionButton, {\
\9\9\9action = \"ghost\",\
\9\9\9hint = \"<font face='GothamBlack'>Spawn a ghost</font> and go to it when disabled\",\
\9\9\9theme = theme,\
\9\9\9image = \"rbxassetid://8992253792\",\
\9\9\9position = px(72, 0),\
\9\9\9canDeactivate = true,\
\9\9}),\
\9\9Roact.createElement(ActionButton, {\
\9\9\9action = \"godmode\",\
\9\9\9hint = \"<font face='GothamBlack'>Set godmode</font>, may break respawn\",\
\9\9\9theme = theme,\
\9\9\9image = \"rbxassetid://8992253678\",\
\9\9\9position = px(145, 0),\
\9\9}),\
\9\9Roact.createElement(ActionButton, {\
\9\9\9action = \"freecam\",\
\9\9\9hint = \"<font face='GothamBlack'>Set freecam</font>, use Q & E to move vertically\",\
\9\9\9theme = theme,\
\9\9\9image = \"rbxassetid://8992253933\",\
\9\9\9position = px(217, 0),\
\9\9\9canDeactivate = true,\
\9\9}),\
\9})\
end\
local default = hooked(Actions)\
return {\
\9default = default,\
}\
", '@'.."Orca.views.Pages.Home.Profile.Actions")) setfenv(fn, newEnv("Orca.views.Pages.Home.Profile.Actions")) return fn() end)

newModule("Avatar", "ModuleScript", "Orca.views.Pages.Home.Profile.Avatar", "Orca.views.Pages.Home.Profile", function () local fn = assert(loadstring("-- Compiled with roblox-ts v1.2.7\
local TS = require(script.Parent.Parent.Parent.Parent.Parent.include.RuntimeLib)\
local Roact = TS.import(script, TS.getModule(script, \"@rbxts\", \"roact\").src)\
local hooked = TS.import(script, TS.getModule(script, \"@rbxts\", \"roact-hooked\").out).hooked\
local Players = TS.import(script, TS.getModule(script, \"@rbxts\", \"services\")).Players\
local Border = TS.import(script, script.Parent.Parent.Parent.Parent.Parent, \"components\", \"Border\").default\
local Canvas = TS.import(script, script.Parent.Parent.Parent.Parent.Parent, \"components\", \"Canvas\").default\
local useTheme = TS.import(script, script.Parent.Parent.Parent.Parent.Parent, \"hooks\", \"use-theme\").useTheme\
local px = TS.import(script, script.Parent.Parent.Parent.Parent.Parent, \"utils\", \"udim2\").px\
local AVATAR = \"https://www.roblox.com/headshot-thumbnail/image?userId=\" .. (tostring(Players.LocalPlayer.UserId) .. \"&width=150&height=150&format=png\")\
local function Avatar()\
\9local theme = useTheme(\"home\").profile\
\9return Roact.createElement(Canvas, {\
\9\9anchor = Vector2.new(0.5, 0),\
\9\9size = px(186, 186),\
\9\9position = UDim2.new(0.5, 0, 0, 24),\
\9}, {\
\9\9Roact.createElement(\"ImageLabel\", {\
\9\9\9Image = AVATAR,\
\9\9\9Size = px(150, 150),\
\9\9\9Position = px(18, 18),\
\9\9\9BackgroundColor3 = theme.avatar.background,\
\9\9\9BackgroundTransparency = theme.avatar.transparency,\
\9\9}, {\
\9\9\9Roact.createElement(\"UICorner\", {\
\9\9\9\9CornerRadius = UDim.new(1, 0),\
\9\9\9}),\
\9\9}),\
\9\9Roact.createElement(Border, {\
\9\9\9size = 4,\
\9\9\9radius = \"circular\",\
\9\9}, {\
\9\9\9Roact.createElement(\"UIGradient\", {\
\9\9\9\9Color = theme.avatar.gradient.color,\
\9\9\9\9Transparency = theme.avatar.gradient.transparency,\
\9\9\9\9Rotation = theme.avatar.gradient.rotation,\
\9\9\9}),\
\9\9}),\
\9})\
end\
local default = hooked(Avatar)\
return {\
\9default = default,\
}\
", '@'.."Orca.views.Pages.Home.Profile.Avatar")) setfenv(fn, newEnv("Orca.views.Pages.Home.Profile.Avatar")) return fn() end)

newModule("Info", "ModuleScript", "Orca.views.Pages.Home.Profile.Info", "Orca.views.Pages.Home.Profile", function () local fn = assert(loadstring("-- Compiled with roblox-ts v1.2.7\
local TS = require(script.Parent.Parent.Parent.Parent.Parent.include.RuntimeLib)\
local Roact = TS.import(script, TS.getModule(script, \"@rbxts\", \"roact\").src)\
local hooked = TS.import(script, TS.getModule(script, \"@rbxts\", \"roact-hooked\").out).hooked\
local Players = TS.import(script, TS.getModule(script, \"@rbxts\", \"services\")).Players\
local Canvas = TS.import(script, script.Parent.Parent.Parent.Parent.Parent, \"components\", \"Canvas\").default\
local useDelayedUpdate = TS.import(script, script.Parent.Parent.Parent.Parent.Parent, \"hooks\", \"common\", \"use-delayed-update\").useDelayedUpdate\
local useSpring = TS.import(script, script.Parent.Parent.Parent.Parent.Parent, \"hooks\", \"common\", \"use-spring\").useSpring\
local useIsPageOpen = TS.import(script, script.Parent.Parent.Parent.Parent.Parent, \"hooks\", \"use-current-page\").useIsPageOpen\
local useFriends = TS.import(script, script.Parent.Parent.Parent.Parent.Parent, \"hooks\", \"use-friends\").useFriends\
local useTheme = TS.import(script, script.Parent.Parent.Parent.Parent.Parent, \"hooks\", \"use-theme\").useTheme\
local DashboardPage = TS.import(script, script.Parent.Parent.Parent.Parent.Parent, \"store\", \"models\", \"dashboard.model\").DashboardPage\
local px = TS.import(script, script.Parent.Parent.Parent.Parent.Parent, \"utils\", \"udim2\").px\
local function Info()\
\9local theme = useTheme(\"home\").profile\
\9local isOpen = useIsPageOpen(DashboardPage.Home)\
\9local _binding = useFriends()\
\9local friends = _binding[1]\
\9if friends == nil then\
\9\9friends = {}\
\9end\
\9local status = _binding[3]\
\9local friendsOnline = #friends\
\9local _arg0 = function(friend)\
\9\9return friend.PlaceId ~= nil and friend.PlaceId == game.PlaceId\
\9end\
\9-- ▼ ReadonlyArray.filter ▼\
\9local _newValue = {}\
\9local _length = 0\
\9for _k, _v in ipairs(friends) do\
\9\9if _arg0(_v, _k - 1, friends) == true then\
\9\9\9_length += 1\
\9\9\9_newValue[_length] = _v\
\9\9end\
\9end\
\9-- ▲ ReadonlyArray.filter ▲\
\9local friendsJoined = #_newValue\
\9local showJoinDate = useDelayedUpdate(isOpen, 400, function(open)\
\9\9return not open\
\9end)\
\9local showFriendsJoined = useDelayedUpdate(isOpen and status ~= \"pending\", 500, function(open)\
\9\9return not open\
\9end)\
\9local showFriendsOnline = useDelayedUpdate(isOpen and status ~= \"pending\", 600, function(open)\
\9\9return not open\
\9end)\
\9return Roact.createElement(Canvas, {\
\9\9anchor = Vector2.new(0.5, 0),\
\9\9size = px(278, 48),\
\9\9position = UDim2.new(0.5, 0, 0, 300),\
\9}, {\
\9\9Roact.createElement(\"Frame\", {\
\9\9\9Size = px(0, 26),\
\9\9\9Position = px(90, 11),\
\9\9\9BackgroundTransparency = 1,\
\9\9}, {\
\9\9\9Roact.createElement(\"UIStroke\", {\
\9\9\9\9Thickness = 0.5,\
\9\9\9\9Color = theme.foreground,\
\9\9\9\9Transparency = 0.7,\
\9\9\9}),\
\9\9}),\
\9\9Roact.createElement(\"Frame\", {\
\9\9\9Size = px(0, 26),\
\9\9\9Position = px(187, 11),\
\9\9\9BackgroundTransparency = 1,\
\9\9}, {\
\9\9\9Roact.createElement(\"UIStroke\", {\
\9\9\9\9Thickness = 0.5,\
\9\9\9\9Color = theme.foreground,\
\9\9\9\9Transparency = 0.7,\
\9\9\9}),\
\9\9}),\
\9\9Roact.createElement(\"TextLabel\", {\
\9\9\9Font = \"GothamBold\",\
\9\9\9Text = \"Joined\\n\" .. tostring((os.date(\"%m/%d/%Y\", os.time() - Players.LocalPlayer.AccountAge * 24 * 60 * 60))),\
\9\9\9TextSize = 13,\
\9\9\9TextColor3 = theme.foreground,\
\9\9\9TextXAlignment = \"Center\",\
\9\9\9TextYAlignment = \"Center\",\
\9\9\9TextTransparency = useSpring(showJoinDate and 0.2 or 1, {}),\
\9\9\9Size = px(85, 48),\
\9\9\9Position = useSpring(showJoinDate and px(0, 0) or px(-20, 0), {}),\
\9\9\9BackgroundTransparency = 1,\
\9\9}),\
\9\9Roact.createElement(\"TextLabel\", {\
\9\9\9Font = \"GothamBold\",\
\9\9\9Text = friendsJoined == 1 and \"1 friend\\njoined\" or tostring(friendsJoined) .. \" friends\\njoined\",\
\9\9\9TextSize = 13,\
\9\9\9TextColor3 = theme.foreground,\
\9\9\9TextXAlignment = \"Center\",\
\9\9\9TextYAlignment = \"Center\",\
\9\9\9TextTransparency = useSpring(showFriendsJoined and 0.2 or 1, {}),\
\9\9\9Size = px(85, 48),\
\9\9\9Position = useSpring(showFriendsJoined and px(97, 0) or px(97 - 20, 0), {}),\
\9\9\9BackgroundTransparency = 1,\
\9\9}),\
\9\9Roact.createElement(\"TextLabel\", {\
\9\9\9Font = \"GothamBold\",\
\9\9\9Text = friendsOnline == 1 and \"1 friend\\nonline\" or tostring(friendsOnline) .. \" friends\\nonline\",\
\9\9\9TextSize = 13,\
\9\9\9TextColor3 = theme.foreground,\
\9\9\9TextXAlignment = \"Center\",\
\9\9\9TextYAlignment = \"Center\",\
\9\9\9TextTransparency = useSpring(showFriendsOnline and 0.2 or 1, {}),\
\9\9\9Size = px(85, 48),\
\9\9\9Position = useSpring(showFriendsOnline and px(193, 0) or px(193 - 20, 0), {}),\
\9\9\9BackgroundTransparency = 1,\
\9\9}),\
\9})\
end\
local default = hooked(Info)\
return {\
\9default = default,\
}\
", '@'.."Orca.views.Pages.Home.Profile.Info")) setfenv(fn, newEnv("Orca.views.Pages.Home.Profile.Info")) return fn() end)

newModule("Profile", "ModuleScript", "Orca.views.Pages.Home.Profile.Profile", "Orca.views.Pages.Home.Profile", function () local fn = assert(loadstring("-- Compiled with roblox-ts v1.2.7\
local TS = require(script.Parent.Parent.Parent.Parent.Parent.include.RuntimeLib)\
local Roact = TS.import(script, TS.getModule(script, \"@rbxts\", \"roact\").src)\
local hooked = TS.import(script, TS.getModule(script, \"@rbxts\", \"roact-hooked\").out).hooked\
local Canvas = TS.import(script, script.Parent.Parent.Parent.Parent.Parent, \"components\", \"Canvas\").default\
local Card = TS.import(script, script.Parent.Parent.Parent.Parent.Parent, \"components\", \"Card\").default\
local useTheme = TS.import(script, script.Parent.Parent.Parent.Parent.Parent, \"hooks\", \"use-theme\").useTheme\
local DashboardPage = TS.import(script, script.Parent.Parent.Parent.Parent.Parent, \"store\", \"models\", \"dashboard.model\").DashboardPage\
local px = TS.import(script, script.Parent.Parent.Parent.Parent.Parent, \"utils\", \"udim2\").px\
local Actions = TS.import(script, script.Parent, \"Actions\").default\
local Avatar = TS.import(script, script.Parent, \"Avatar\").default\
local Info = TS.import(script, script.Parent, \"Info\").default\
local Sliders = TS.import(script, script.Parent, \"Sliders\").default\
local Username = TS.import(script, script.Parent, \"Username\").default\
local function Profile()\
\9local theme = useTheme(\"home\").profile\
\9return Roact.createElement(Card, {\
\9\9index = 1,\
\9\9page = DashboardPage.Home,\
\9\9theme = theme,\
\9\9size = px(326, 648),\
\9\9position = UDim2.new(0, 0, 1, 0),\
\9}, {\
\9\9Roact.createElement(Canvas, {\
\9\9\9padding = {\
\9\9\9\9left = 24,\
\9\9\9\9right = 24,\
\9\9\9},\
\9\9}, {\
\9\9\9Roact.createElement(Avatar),\
\9\9\9Roact.createElement(Username),\
\9\9\9Roact.createElement(Info),\
\9\9\9Roact.createElement(Sliders),\
\9\9\9Roact.createElement(Actions),\
\9\9}),\
\9})\
end\
local default = hooked(Profile)\
return {\
\9default = default,\
}\
", '@'.."Orca.views.Pages.Home.Profile.Profile")) setfenv(fn, newEnv("Orca.views.Pages.Home.Profile.Profile")) return fn() end)

newModule("Sliders", "ModuleScript", "Orca.views.Pages.Home.Profile.Sliders", "Orca.views.Pages.Home.Profile", function () local fn = assert(loadstring("-- Compiled with roblox-ts v1.2.7\
local TS = require(script.Parent.Parent.Parent.Parent.Parent.include.RuntimeLib)\
local Roact = TS.import(script, TS.getModule(script, \"@rbxts\", \"roact\").src)\
local _roact_hooked = TS.import(script, TS.getModule(script, \"@rbxts\", \"roact-hooked\").out)\
local hooked = _roact_hooked.hooked\
local useBinding = _roact_hooked.useBinding\
local useState = _roact_hooked.useState\
local BrightButton = TS.import(script, script.Parent.Parent.Parent.Parent.Parent, \"components\", \"BrightButton\").default\
local BrightSlider = TS.import(script, script.Parent.Parent.Parent.Parent.Parent, \"components\", \"BrightSlider\").default\
local Canvas = TS.import(script, script.Parent.Parent.Parent.Parent.Parent, \"components\", \"Canvas\").default\
local _rodux_hooks = TS.import(script, script.Parent.Parent.Parent.Parent.Parent, \"hooks\", \"common\", \"rodux-hooks\")\
local useAppDispatch = _rodux_hooks.useAppDispatch\
local useAppSelector = _rodux_hooks.useAppSelector\
local useSpring = TS.import(script, script.Parent.Parent.Parent.Parent.Parent, \"hooks\", \"common\", \"use-spring\").useSpring\
local useTheme = TS.import(script, script.Parent.Parent.Parent.Parent.Parent, \"hooks\", \"use-theme\").useTheme\
local _dashboard_action = TS.import(script, script.Parent.Parent.Parent.Parent.Parent, \"store\", \"actions\", \"dashboard.action\")\
local clearHint = _dashboard_action.clearHint\
local setHint = _dashboard_action.setHint\
local _jobs_action = TS.import(script, script.Parent.Parent.Parent.Parent.Parent, \"store\", \"actions\", \"jobs.action\")\
local setJobActive = _jobs_action.setJobActive\
local setJobValue = _jobs_action.setJobValue\
local _udim2 = TS.import(script, script.Parent.Parent.Parent.Parent.Parent, \"utils\", \"udim2\")\
local px = _udim2.px\
local scale = _udim2.scale\
local SPRING_OPTIONS = {\
\9frequency = 5,\
}\
local Slider\
local function Sliders()\
\9return Roact.createElement(Canvas, {\
\9\9size = px(278, 187),\
\9\9position = px(0, 368),\
\9}, {\
\9\9Roact.createElement(Slider, {\
\9\9\9display = \"Flight\",\
\9\9\9hint = \"<font face='GothamBlack'>Configure flight</font> in studs per second\",\
\9\9\9jobName = \"flight\",\
\9\9\9units = \"studs/s\",\
\9\9\9min = 10,\
\9\9\9max = 100,\
\9\9\9position = 0,\
\9\9}),\
\9\9Roact.createElement(Slider, {\
\9\9\9display = \"Speed\",\
\9\9\9hint = \"<font face='GothamBlack'>Configure speed</font> in studs per second\",\
\9\9\9jobName = \"walkSpeed\",\
\9\9\9units = \"studs/s\",\
\9\9\9min = 0,\
\9\9\9max = 100,\
\9\9\9position = 69,\
\9\9}),\
\9\9Roact.createElement(Slider, {\
\9\9\9display = \"Jump\",\
\9\9\9hint = \"<font face='GothamBlack'>Configure height</font> in studs\",\
\9\9\9jobName = \"jumpHeight\",\
\9\9\9units = \"studs\",\
\9\9\9min = 0,\
\9\9\9max = 500,\
\9\9\9position = 138,\
\9\9}),\
\9})\
end\
local default = Sliders\
local function SliderComponent(props)\
\9local theme = useTheme(\"home\").profile\
\9local dispatch = useAppDispatch()\
\9local job = useAppSelector(function(state)\
\9\9return state.jobs[props.jobName]\
\9end)\
\9local _binding = useBinding(job.value)\
\9local value = _binding[1]\
\9local setValue = _binding[2]\
\9local _binding_1 = useState(false)\
\9local hovered = _binding_1[1]\
\9local setHovered = _binding_1[2]\
\9local accent = theme.highlight[props.jobName]\
\9local _result\
\9if job.active then\
\9\9_result = accent\
\9else\
\9\9local _result_1\
\9\9if hovered then\
\9\9\9local _condition = theme.button.backgroundHovered\
\9\9\9if _condition == nil then\
\9\9\9\9_condition = theme.button.background:Lerp(accent, 0.1)\
\9\9\9end\
\9\9\9_result_1 = _condition\
\9\9else\
\9\9\9_result_1 = theme.button.background\
\9\9end\
\9\9_result = _result_1\
\9end\
\9local buttonBackground = useSpring(_result, {})\
\9local buttonForeground = useSpring(job.active and theme.button.foregroundAccent and theme.button.foregroundAccent or theme.foreground, {})\
\9return Roact.createElement(Canvas, {\
\9\9size = px(278, 49),\
\9\9position = px(0, props.position),\
\9}, {\
\9\9Roact.createElement(BrightSlider, {\
\9\9\9onValueChanged = setValue,\
\9\9\9onRelease = function()\
\9\9\9\9return dispatch(setJobValue(props.jobName, math.round(value:getValue())))\
\9\9\9end,\
\9\9\9min = props.min,\
\9\9\9max = props.max,\
\9\9\9initialValue = job.value,\
\9\9\9size = px(181, 49),\
\9\9\9position = px(0, 0),\
\9\9\9radius = 8,\
\9\9\9color = theme.slider.background,\
\9\9\9accentColor = accent,\
\9\9\9borderEnabled = theme.slider.outlined,\
\9\9\9borderColor = theme.slider.foreground,\
\9\9\9transparency = theme.slider.backgroundTransparency,\
\9\9\9indicatorTransparency = theme.slider.indicatorTransparency,\
\9\9}, {\
\9\9\9Roact.createElement(\"TextLabel\", {\
\9\9\9\9Font = \"GothamBold\",\
\9\9\9\9Text = value:map(function(value)\
\9\9\9\9\9return tostring(math.round(value)) .. (\" \" .. props.units)\
\9\9\9\9end),\
\9\9\9\9TextSize = 15,\
\9\9\9\9TextColor3 = theme.slider.foreground,\
\9\9\9\9TextXAlignment = \"Center\",\
\9\9\9\9TextYAlignment = \"Center\",\
\9\9\9\9TextTransparency = theme.slider.foregroundTransparency,\
\9\9\9\9Size = scale(1, 1),\
\9\9\9\9BackgroundTransparency = 1,\
\9\9\9}),\
\9\9}),\
\9\9Roact.createElement(BrightButton, {\
\9\9\9onActivate = function()\
\9\9\9\9return dispatch(setJobActive(props.jobName, not job.active))\
\9\9\9end,\
\9\9\9onHover = function(hovered)\
\9\9\9\9if hovered then\
\9\9\9\9\9setHovered(true)\
\9\9\9\9\9dispatch(setHint(props.hint))\
\9\9\9\9else\
\9\9\9\9\9setHovered(false)\
\9\9\9\9\9dispatch(clearHint())\
\9\9\9\9end\
\9\9\9end,\
\9\9\9size = px(85, 49),\
\9\9\9position = px(193, 0),\
\9\9\9radius = 8,\
\9\9\9color = buttonBackground,\
\9\9\9borderEnabled = theme.button.outlined,\
\9\9\9borderColor = buttonForeground,\
\9\9\9transparency = theme.button.backgroundTransparency,\
\9\9}, {\
\9\9\9Roact.createElement(\"TextLabel\", {\
\9\9\9\9Font = \"GothamBold\",\
\9\9\9\9Text = props.display,\
\9\9\9\9TextSize = 15,\
\9\9\9\9TextColor3 = buttonForeground,\
\9\9\9\9TextXAlignment = \"Center\",\
\9\9\9\9TextYAlignment = \"Center\",\
\9\9\9\9TextTransparency = useSpring(job.active and 0 or (hovered and theme.button.foregroundTransparency - 0.25 or theme.button.foregroundTransparency), {}),\
\9\9\9\9Size = scale(1, 1),\
\9\9\9\9BackgroundTransparency = 1,\
\9\9\9}),\
\9\9}),\
\9})\
end\
Slider = hooked(SliderComponent)\
return {\
\9default = default,\
}\
", '@'.."Orca.views.Pages.Home.Profile.Sliders")) setfenv(fn, newEnv("Orca.views.Pages.Home.Profile.Sliders")) return fn() end)

newModule("Username", "ModuleScript", "Orca.views.Pages.Home.Profile.Username", "Orca.views.Pages.Home.Profile", function () local fn = assert(loadstring("-- Compiled with roblox-ts v1.2.7\
local TS = require(script.Parent.Parent.Parent.Parent.Parent.include.RuntimeLib)\
local Roact = TS.import(script, TS.getModule(script, \"@rbxts\", \"roact\").src)\
local hooked = TS.import(script, TS.getModule(script, \"@rbxts\", \"roact-hooked\").out).hooked\
local Players = TS.import(script, TS.getModule(script, \"@rbxts\", \"services\")).Players\
local Canvas = TS.import(script, script.Parent.Parent.Parent.Parent.Parent, \"components\", \"Canvas\").default\
local useTheme = TS.import(script, script.Parent.Parent.Parent.Parent.Parent, \"hooks\", \"use-theme\").useTheme\
local _udim2 = TS.import(script, script.Parent.Parent.Parent.Parent.Parent, \"utils\", \"udim2\")\
local px = _udim2.px\
local scale = _udim2.scale\
local function Username()\
\9local theme = useTheme(\"home\").profile\
\9return Roact.createElement(Canvas, {\
\9\9anchor = Vector2.new(0.5, 0),\
\9\9size = px(278, 49),\
\9\9position = UDim2.new(0.5, 0, 0, 231),\
\9}, {\
\9\9Roact.createElement(\"TextLabel\", {\
\9\9\9Font = \"GothamBlack\",\
\9\9\9Text = Players.LocalPlayer.DisplayName,\
\9\9\9TextSize = 20,\
\9\9\9TextColor3 = theme.foreground,\
\9\9\9TextXAlignment = \"Center\",\
\9\9\9TextYAlignment = \"Top\",\
\9\9\9Size = scale(1, 1),\
\9\9\9BackgroundTransparency = 1,\
\9\9}),\
\9\9Roact.createElement(\"TextLabel\", {\
\9\9\9Font = \"GothamBold\",\
\9\9\9Text = Players.LocalPlayer.Name,\
\9\9\9TextSize = 16,\
\9\9\9TextColor3 = theme.foreground,\
\9\9\9TextXAlignment = \"Center\",\
\9\9\9TextYAlignment = \"Bottom\",\
\9\9\9TextTransparency = 0.7,\
\9\9\9Size = scale(1, 1),\
\9\9\9BackgroundTransparency = 1,\
\9\9}),\
\9})\
end\
local default = hooked(Username)\
return {\
\9default = default,\
}\
", '@'.."Orca.views.Pages.Home.Profile.Username")) setfenv(fn, newEnv("Orca.views.Pages.Home.Profile.Username")) return fn() end)

newModule("Server", "ModuleScript", "Orca.views.Pages.Home.Server", "Orca.views.Pages.Home", function () local fn = assert(loadstring("-- Compiled with roblox-ts v1.2.7\
local TS = require(script.Parent.Parent.Parent.Parent.include.RuntimeLib)\
local exports = {}\
exports.default = TS.import(script, script, \"Server\").default\
return exports\
", '@'.."Orca.views.Pages.Home.Server")) setfenv(fn, newEnv("Orca.views.Pages.Home.Server")) return fn() end)

newModule("Server", "ModuleScript", "Orca.views.Pages.Home.Server.Server", "Orca.views.Pages.Home.Server", function () local fn = assert(loadstring("-- Compiled with roblox-ts v1.2.7\
local TS = require(script.Parent.Parent.Parent.Parent.Parent.include.RuntimeLib)\
local Roact = TS.import(script, TS.getModule(script, \"@rbxts\", \"roact\").src)\
local hooked = TS.import(script, TS.getModule(script, \"@rbxts\", \"roact-hooked\").out).hooked\
local Players = TS.import(script, TS.getModule(script, \"@rbxts\", \"services\")).Players\
local Card = TS.import(script, script.Parent.Parent.Parent.Parent.Parent, \"components\", \"Card\").default\
local IS_DEV = TS.import(script, script.Parent.Parent.Parent.Parent.Parent, \"constants\").IS_DEV\
local useTheme = TS.import(script, script.Parent.Parent.Parent.Parent.Parent, \"hooks\", \"use-theme\").useTheme\
local DashboardPage = TS.import(script, script.Parent.Parent.Parent.Parent.Parent, \"store\", \"models\", \"dashboard.model\").DashboardPage\
local px = TS.import(script, script.Parent.Parent.Parent.Parent.Parent, \"utils\", \"udim2\").px\
local ServerAction = TS.import(script, script.Parent, \"ServerAction\").default\
local StatusLabel = TS.import(script, script.Parent, \"StatusLabel\").default\
local function Server()\
\9local theme = useTheme(\"home\").server\
\9return Roact.createElement(Card, {\
\9\9index = 2,\
\9\9page = DashboardPage.Home,\
\9\9theme = theme,\
\9\9size = px(326, 184),\
\9\9position = UDim2.new(0, 374, 1, -416 - 48),\
\9}, {\
\9\9Roact.createElement(\"TextLabel\", {\
\9\9\9Text = \"Server\",\
\9\9\9Font = \"GothamBlack\",\
\9\9\9TextSize = 20,\
\9\9\9TextColor3 = theme.foreground,\
\9\9\9TextXAlignment = \"Left\",\
\9\9\9TextYAlignment = \"Top\",\
\9\9\9Position = px(24, 24),\
\9\9\9BackgroundTransparency = 1,\
\9\9}),\
\9\9Roact.createElement(StatusLabel, {\
\9\9\9index = 0,\
\9\9\9offset = 69,\
\9\9\9units = \"players\",\
\9\9\9getValue = function()\
\9\9\9\9return tostring(#Players:GetPlayers()) .. (\" / \" .. tostring(Players.MaxPlayers))\
\9\9\9end,\
\9\9}),\
\9\9Roact.createElement(StatusLabel, {\
\9\9\9index = 1,\
\9\9\9offset = 108,\
\9\9\9units = \"elapsed\",\
\9\9\9getValue = function()\
\9\9\9\9local uptime = IS_DEV and os.clock() or time()\
\9\9\9\9local days = math.floor(uptime / 86400)\
\9\9\9\9local hours = math.floor((uptime - days * 86400) / 3600)\
\9\9\9\9local minutes = math.floor((uptime - days * 86400 - hours * 3600) / 60)\
\9\9\9\9local seconds = math.floor(uptime - days * 86400 - hours * 3600 - minutes * 60)\
\9\9\9\9return days > 0 and tostring(days) .. \" days\" or (hours > 0 and tostring(hours) .. \" hours\" or (minutes > 0 and tostring(minutes) .. \" minutes\" or tostring(seconds) .. \" seconds\"))\
\9\9\9end,\
\9\9}),\
\9\9Roact.createElement(StatusLabel, {\
\9\9\9index = 2,\
\9\9\9offset = 147,\
\9\9\9units = \"ping\",\
\9\9\9getValue = function()\
\9\9\9\9return tostring(math.round(Players.LocalPlayer:GetNetworkPing() * 1000)) .. \" ms\"\
\9\9\9end,\
\9\9}),\
\9\9Roact.createElement(ServerAction, {\
\9\9\9action = \"switchServer\",\
\9\9\9hint = \"<font face='GothamBlack'>Switch</font> to a different server\",\
\9\9\9icon = \"rbxassetid://8992259774\",\
\9\9\9size = px(66, 50),\
\9\9\9position = UDim2.new(1, -66 - 24, 1, -100 - 16 - 12),\
\9\9}),\
\9\9Roact.createElement(ServerAction, {\
\9\9\9action = \"rejoinServer\",\
\9\9\9hint = \"<font face='GothamBlack'>Rejoin</font> this server\",\
\9\9\9icon = \"rbxassetid://8992259894\",\
\9\9\9size = px(66, 50),\
\9\9\9position = UDim2.new(1, -66 - 24, 1, -50 - 16),\
\9\9}),\
\9})\
end\
local default = hooked(Server)\
return {\
\9default = default,\
}\
", '@'.."Orca.views.Pages.Home.Server.Server")) setfenv(fn, newEnv("Orca.views.Pages.Home.Server.Server")) return fn() end)

newModule("ServerAction", "ModuleScript", "Orca.views.Pages.Home.Server.ServerAction", "Orca.views.Pages.Home.Server", function () local fn = assert(loadstring("-- Compiled with roblox-ts v1.2.7\
local TS = require(script.Parent.Parent.Parent.Parent.Parent.include.RuntimeLib)\
local Roact = TS.import(script, TS.getModule(script, \"@rbxts\", \"roact\").src)\
local _roact_hooked = TS.import(script, TS.getModule(script, \"@rbxts\", \"roact-hooked\").out)\
local hooked = _roact_hooked.hooked\
local useState = _roact_hooked.useState\
local BrightButton = TS.import(script, script.Parent.Parent.Parent.Parent.Parent, \"components\", \"BrightButton\").default\
local _rodux_hooks = TS.import(script, script.Parent.Parent.Parent.Parent.Parent, \"hooks\", \"common\", \"rodux-hooks\")\
local useAppDispatch = _rodux_hooks.useAppDispatch\
local useAppSelector = _rodux_hooks.useAppSelector\
local useSpring = TS.import(script, script.Parent.Parent.Parent.Parent.Parent, \"hooks\", \"common\", \"use-spring\").useSpring\
local useTheme = TS.import(script, script.Parent.Parent.Parent.Parent.Parent, \"hooks\", \"use-theme\").useTheme\
local _dashboard_action = TS.import(script, script.Parent.Parent.Parent.Parent.Parent, \"store\", \"actions\", \"dashboard.action\")\
local clearHint = _dashboard_action.clearHint\
local setHint = _dashboard_action.setHint\
local setJobActive = TS.import(script, script.Parent.Parent.Parent.Parent.Parent, \"store\", \"actions\", \"jobs.action\").setJobActive\
local _udim2 = TS.import(script, script.Parent.Parent.Parent.Parent.Parent, \"utils\", \"udim2\")\
local px = _udim2.px\
local scale = _udim2.scale\
local function ServerAction(_param)\
\9local action = _param.action\
\9local hint = _param.hint\
\9local icon = _param.icon\
\9local size = _param.size\
\9local position = _param.position\
\9local dispatch = useAppDispatch()\
\9local theme = useTheme(\"home\").server[action == \"switchServer\" and \"switchButton\" or \"rejoinButton\"]\
\9local active = useAppSelector(function(state)\
\9\9return state.jobs[action].active\
\9end)\
\9local _binding = useState(false)\
\9local hovered = _binding[1]\
\9local setHovered = _binding[2]\
\9local _result\
\9if active then\
\9\9_result = theme.accent\
\9else\
\9\9local _result_1\
\9\9if hovered then\
\9\9\9local _condition = theme.backgroundHovered\
\9\9\9if _condition == nil then\
\9\9\9\9_condition = theme.background:Lerp(theme.accent, 0.1)\
\9\9\9end\
\9\9\9_result_1 = _condition\
\9\9else\
\9\9\9_result_1 = theme.background\
\9\9end\
\9\9_result = _result_1\
\9end\
\9local background = useSpring(_result, {})\
\9local foreground = useSpring(active and theme.foregroundAccent and theme.foregroundAccent or theme.foreground, {})\
\9return Roact.createElement(BrightButton, {\
\9\9onActivate = function()\
\9\9\9return dispatch(setJobActive(action, not active))\
\9\9end,\
\9\9onHover = function(hovered)\
\9\9\9if hovered then\
\9\9\9\9setHovered(true)\
\9\9\9\9dispatch(setHint(hint))\
\9\9\9else\
\9\9\9\9setHovered(false)\
\9\9\9\9dispatch(clearHint())\
\9\9\9end\
\9\9end,\
\9\9size = size,\
\9\9position = position,\
\9\9radius = 8,\
\9\9color = background,\
\9\9borderEnabled = theme.outlined,\
\9\9borderColor = foreground,\
\9\9transparency = theme.backgroundTransparency,\
\9}, {\
\9\9Roact.createElement(\"ImageLabel\", {\
\9\9\9Image = icon,\
\9\9\9ImageColor3 = foreground,\
\9\9\9ImageTransparency = useSpring(active and 0 or (hovered and theme.foregroundTransparency - 0.25 or theme.foregroundTransparency), {}),\
\9\9\9AnchorPoint = Vector2.new(0.5, 0.5),\
\9\9\9Size = px(36, 36),\
\9\9\9Position = scale(0.5, 0.5),\
\9\9\9BackgroundTransparency = 1,\
\9\9}),\
\9})\
end\
local default = hooked(ServerAction)\
return {\
\9default = default,\
}\
", '@'.."Orca.views.Pages.Home.Server.ServerAction")) setfenv(fn, newEnv("Orca.views.Pages.Home.Server.ServerAction")) return fn() end)

newModule("StatusLabel", "ModuleScript", "Orca.views.Pages.Home.Server.StatusLabel", "Orca.views.Pages.Home.Server", function () local fn = assert(loadstring("-- Compiled with roblox-ts v1.2.7\
local TS = require(script.Parent.Parent.Parent.Parent.Parent.include.RuntimeLib)\
local Roact = TS.import(script, TS.getModule(script, \"@rbxts\", \"roact\").src)\
local _roact_hooked = TS.import(script, TS.getModule(script, \"@rbxts\", \"roact-hooked\").out)\
local hooked = _roact_hooked.hooked\
local useMemo = _roact_hooked.useMemo\
local useState = _roact_hooked.useState\
local TextService = TS.import(script, TS.getModule(script, \"@rbxts\", \"services\")).TextService\
local useDelayedUpdate = TS.import(script, script.Parent.Parent.Parent.Parent.Parent, \"hooks\", \"common\", \"use-delayed-update\").useDelayedUpdate\
local useInterval = TS.import(script, script.Parent.Parent.Parent.Parent.Parent, \"hooks\", \"common\", \"use-interval\").useInterval\
local useSpring = TS.import(script, script.Parent.Parent.Parent.Parent.Parent, \"hooks\", \"common\", \"use-spring\").useSpring\
local useIsPageOpen = TS.import(script, script.Parent.Parent.Parent.Parent.Parent, \"hooks\", \"use-current-page\").useIsPageOpen\
local useTheme = TS.import(script, script.Parent.Parent.Parent.Parent.Parent, \"hooks\", \"use-theme\").useTheme\
local DashboardPage = TS.import(script, script.Parent.Parent.Parent.Parent.Parent, \"store\", \"models\", \"dashboard.model\").DashboardPage\
local px = TS.import(script, script.Parent.Parent.Parent.Parent.Parent, \"utils\", \"udim2\").px\
local function StatusLabel(_param)\
\9local offset = _param.offset\
\9local index = _param.index\
\9local units = _param.units\
\9local getValue = _param.getValue\
\9local theme = useTheme(\"home\").server\
\9local _binding = useState(getValue)\
\9local value = _binding[1]\
\9local setValue = _binding[2]\
\9local isOpen = useIsPageOpen(DashboardPage.Home)\
\9local isVisible = useDelayedUpdate(isOpen, isOpen and 330 + index * 100 or 300)\
\9local valueLength = useMemo(function()\
\9\9return TextService:GetTextSize(value .. \" \", 16, \"GothamBold\", Vector2.new()).X\
\9end, { value })\
\9useInterval(function()\
\9\9setValue(getValue())\
\9end, 1000)\
\9return Roact.createFragment({\
\9\9Roact.createElement(\"TextLabel\", {\
\9\9\9Text = value,\
\9\9\9RichText = true,\
\9\9\9Font = \"GothamBold\",\
\9\9\9TextSize = 16,\
\9\9\9TextColor3 = theme.foreground,\
\9\9\9TextTransparency = useSpring(isVisible and 0 or 1, {\
\9\9\9\9frequency = 2,\
\9\9\9}),\
\9\9\9TextXAlignment = \"Left\",\
\9\9\9TextYAlignment = \"Top\",\
\9\9\9Position = useSpring(isVisible and px(24, offset) or px(0, offset), {}),\
\9\9\9BackgroundTransparency = 1,\
\9\9}),\
\9\9Roact.createElement(\"TextLabel\", {\
\9\9\9Text = units,\
\9\9\9RichText = true,\
\9\9\9Font = \"GothamBold\",\
\9\9\9TextSize = 16,\
\9\9\9TextColor3 = theme.foreground,\
\9\9\9TextTransparency = useSpring(isVisible and 0.4 or 1, {}),\
\9\9\9TextXAlignment = \"Left\",\
\9\9\9TextYAlignment = \"Top\",\
\9\9\9Position = useSpring(isVisible and px(24 + valueLength, offset) or px(0 + valueLength, offset), {}),\
\9\9\9BackgroundTransparency = 1,\
\9\9}),\
\9})\
end\
local default = hooked(StatusLabel)\
return {\
\9default = default,\
}\
", '@'.."Orca.views.Pages.Home.Server.StatusLabel")) setfenv(fn, newEnv("Orca.views.Pages.Home.Server.StatusLabel")) return fn() end)

newModule("Title", "ModuleScript", "Orca.views.Pages.Home.Title", "Orca.views.Pages.Home", function () local fn = assert(loadstring("-- Compiled with roblox-ts v1.2.7\
local TS = require(script.Parent.Parent.Parent.Parent.include.RuntimeLib)\
local Roact = TS.import(script, TS.getModule(script, \"@rbxts\", \"roact\").src)\
local hooked = TS.import(script, TS.getModule(script, \"@rbxts\", \"roact-hooked\").out).hooked\
local Canvas = TS.import(script, script.Parent.Parent.Parent.Parent, \"components\", \"Canvas\").default\
local Card = TS.import(script, script.Parent.Parent.Parent.Parent, \"components\", \"Card\").default\
local ParallaxImage = TS.import(script, script.Parent.Parent.Parent.Parent, \"components\", \"ParallaxImage\").default\
local VERSION_TAG = TS.import(script, script.Parent.Parent.Parent.Parent, \"constants\").VERSION_TAG\
local useDelayedUpdate = TS.import(script, script.Parent.Parent.Parent.Parent, \"hooks\", \"common\", \"use-delayed-update\").useDelayedUpdate\
local useSpring = TS.import(script, script.Parent.Parent.Parent.Parent, \"hooks\", \"common\", \"use-spring\").useSpring\
local useIsPageOpen = TS.import(script, script.Parent.Parent.Parent.Parent, \"hooks\", \"use-current-page\").useIsPageOpen\
local useParallaxOffset = TS.import(script, script.Parent.Parent.Parent.Parent, \"hooks\", \"use-parallax-offset\").useParallaxOffset\
local useTheme = TS.import(script, script.Parent.Parent.Parent.Parent, \"hooks\", \"use-theme\").useTheme\
local DashboardPage = TS.import(script, script.Parent.Parent.Parent.Parent, \"store\", \"models\", \"dashboard.model\").DashboardPage\
local _udim2 = TS.import(script, script.Parent.Parent.Parent.Parent, \"utils\", \"udim2\")\
local px = _udim2.px\
local scale = _udim2.scale\
local Label\
local function Title()\
\9local theme = useTheme(\"home\").title\
\9local offset = useParallaxOffset()\
\9return Roact.createElement(Card, {\
\9\9index = 0,\
\9\9page = DashboardPage.Home,\
\9\9theme = theme,\
\9\9size = px(326, 184),\
\9\9position = UDim2.new(0, 0, 1, -648 - 48),\
\9}, {\
\9\9Roact.createElement(ParallaxImage, {\
\9\9\9image = \"rbxassetid://9049308243\",\
\9\9\9imageSize = Vector2.new(652, 368),\
\9\9\9padding = Vector2.new(30, 30),\
\9\9\9offset = offset,\
\9\9}, {\
\9\9\9Roact.createElement(\"UICorner\", {\
\9\9\9\9CornerRadius = UDim.new(0, 12),\
\9\9\9}),\
\9\9}),\
\9\9Roact.createElement(\"ImageLabel\", {\
\9\9\9Image = \"rbxassetid://9048947177\",\
\9\9\9Size = scale(1, 1),\
\9\9\9ImageTransparency = 0.3,\
\9\9\9BackgroundTransparency = 1,\
\9\9}, {\
\9\9\9Roact.createElement(\"UICorner\", {\
\9\9\9\9CornerRadius = UDim.new(0, 12),\
\9\9\9}),\
\9\9}),\
\9\9Roact.createElement(Canvas, {\
\9\9\9padding = {\
\9\9\9\9top = 24,\
\9\9\9\9left = 24,\
\9\9\9},\
\9\9}, {\
\9\9\9Roact.createElement(Label, {\
\9\9\9\9index = 0,\
\9\9\9\9text = \"Orca\",\
\9\9\9\9font = Enum.Font.GothamBlack,\
\9\9\9\9size = 20,\
\9\9\9\9position = px(0, 0),\
\9\9\9}),\
\9\9\9Roact.createElement(Label, {\
\9\9\9\9index = 1,\
\9\9\9\9text = VERSION_TAG,\
\9\9\9\9position = px(0, 40),\
\9\9\9}),\
\9\9\9Roact.createElement(Label, {\
\9\9\9\9index = 2,\
\9\9\9\9text = \"By Cola\",\
\9\9\9\9position = px(0, 63),\
\9\9\9\9transparency = 0.15,\
\9\9\9}),\
\9\9\9Roact.createElement(Label, {\
\9\9\9\9index = 3,\
\9\9\9\9text = \"Pls star repo\",\
\9\9\9\9position = px(0, 86),\
\9\9\9\9transparency = 0.3,\
\9\9\9}),\
\9\9\9Roact.createElement(Label, {\
\9\9\9\9index = 4,\
\9\9\9\9text = \"Cola/orca\",\
\9\9\9\9position = UDim2.new(0, 0, 1, -40),\
\9\9\9\9transparency = 0.45,\
\9\9\9}),\
\9\9}),\
\9})\
end\
local default = hooked(Title)\
local function LabelComponent(props)\
\9local _binding = props\
\9local index = _binding.index\
\9local text = _binding.text\
\9local font = _binding.font\
\9if font == nil then\
\9\9font = Enum.Font.GothamBold\
\9end\
\9local size = _binding.size\
\9if size == nil then\
\9\9size = 16\
\9end\
\9local position = _binding.position\
\9local transparency = _binding.transparency\
\9if transparency == nil then\
\9\9transparency = 0\
\9end\
\9local theme = useTheme(\"home\").title\
\9local isOpen = useIsPageOpen(DashboardPage.Home)\
\9local isActive = useDelayedUpdate(isOpen, index * 100 + 300, function(current)\
\9\9return not current\
\9end)\
\9local _attributes = {\
\9\9Text = text,\
\9\9Font = font,\
\9\9TextColor3 = theme.foreground,\
\9\9TextSize = size,\
\9\9TextTransparency = useSpring(isActive and transparency or 1, {\
\9\9\9frequency = 2,\
\9\9}),\
\9\9TextXAlignment = \"Left\",\
\9\9TextYAlignment = \"Top\",\
\9\9Size = px(200, 24),\
\9}\
\9local _result\
\9if isActive then\
\9\9_result = position\
\9else\
\9\9local _arg0 = px(24, 0)\
\9\9_result = position - _arg0\
\9end\
\9_attributes.Position = useSpring(_result, {})\
\9_attributes.BackgroundTransparency = 1\
\9return Roact.createElement(\"TextLabel\", _attributes)\
end\
Label = hooked(LabelComponent)\
return {\
\9default = default,\
}\
", '@'.."Orca.views.Pages.Home.Title")) setfenv(fn, newEnv("Orca.views.Pages.Home.Title")) return fn() end)

newModule("Options", "ModuleScript", "Orca.views.Pages.Options", "Orca.views.Pages", function () local fn = assert(loadstring("-- Compiled with roblox-ts v1.2.7\
local TS = require(script.Parent.Parent.Parent.include.RuntimeLib)\
local exports = {}\
exports.default = TS.import(script, script, \"Options\").default\
return exports\
", '@'.."Orca.views.Pages.Options")) setfenv(fn, newEnv("Orca.views.Pages.Options")) return fn() end)

newModule("Config", "ModuleScript", "Orca.views.Pages.Options.Config", "Orca.views.Pages.Options", function () local fn = assert(loadstring("-- Compiled with roblox-ts v1.2.7\
local TS = require(script.Parent.Parent.Parent.Parent.include.RuntimeLib)\
local exports = {}\
exports.default = TS.import(script, script, \"Config\").default\
return exports\
", '@'.."Orca.views.Pages.Options.Config")) setfenv(fn, newEnv("Orca.views.Pages.Options.Config")) return fn() end)

newModule("Config", "ModuleScript", "Orca.views.Pages.Options.Config.Config", "Orca.views.Pages.Options.Config", function () local fn = assert(loadstring("-- Compiled with roblox-ts v1.2.7\
local TS = require(script.Parent.Parent.Parent.Parent.Parent.include.RuntimeLib)\
local Roact = TS.import(script, TS.getModule(script, \"@rbxts\", \"roact\").src)\
local hooked = TS.import(script, TS.getModule(script, \"@rbxts\", \"roact-hooked\").out).hooked\
local Canvas = TS.import(script, script.Parent.Parent.Parent.Parent.Parent, \"components\", \"Canvas\").default\
local Card = TS.import(script, script.Parent.Parent.Parent.Parent.Parent, \"components\", \"Card\").default\
local useTheme = TS.import(script, script.Parent.Parent.Parent.Parent.Parent, \"hooks\", \"use-theme\").useTheme\
local DashboardPage = TS.import(script, script.Parent.Parent.Parent.Parent.Parent, \"store\", \"models\", \"dashboard.model\").DashboardPage\
local _udim2 = TS.import(script, script.Parent.Parent.Parent.Parent.Parent, \"utils\", \"udim2\")\
local px = _udim2.px\
local scale = _udim2.scale\
local _ConfigItem = TS.import(script, script.Parent, \"ConfigItem\")\
local ConfigItem = _ConfigItem.default\
local ENTRY_HEIGHT = _ConfigItem.ENTRY_HEIGHT\
local PADDING = _ConfigItem.PADDING\
local ENTRY_COUNT = 1\
local function Config()\
\9local theme = useTheme(\"options\").config\
\9return Roact.createElement(Card, {\
\9\9index = 0,\
\9\9page = DashboardPage.Options,\
\9\9theme = theme,\
\9\9size = px(326, 184),\
\9\9position = UDim2.new(0, 0, 1, -416 - 48),\
\9}, {\
\9\9Roact.createElement(\"TextLabel\", {\
\9\9\9Text = \"Options\",\
\9\9\9Font = \"GothamBlack\",\
\9\9\9TextSize = 20,\
\9\9\9TextColor3 = theme.foreground,\
\9\9\9TextXAlignment = \"Left\",\
\9\9\9TextYAlignment = \"Top\",\
\9\9\9Position = px(24, 24),\
\9\9\9BackgroundTransparency = 1,\
\9\9}),\
\9\9Roact.createElement(Canvas, {\
\9\9\9size = px(326, 348),\
\9\9\9position = px(0, 68),\
\9\9\9padding = {\
\9\9\9\9left = 24,\
\9\9\9\9right = 24,\
\9\9\9\9top = 8,\
\9\9\9},\
\9\9\9clipsDescendants = true,\
\9\9}, {\
\9\9\9Roact.createElement(\"ScrollingFrame\", {\
\9\9\9\9Size = scale(1, 1),\
\9\9\9\9CanvasSize = px(0, ENTRY_COUNT * (ENTRY_HEIGHT + PADDING) + PADDING),\
\9\9\9\9BackgroundTransparency = 1,\
\9\9\9\9BorderSizePixel = 0,\
\9\9\9\9ScrollBarImageTransparency = 1,\
\9\9\9\9ScrollBarThickness = 0,\
\9\9\9\9ClipsDescendants = false,\
\9\9\9}, {\
\9\9\9\9Roact.createElement(ConfigItem, {\
\9\9\9\9\9action = \"acrylicBlur\",\
\9\9\9\9\9description = \"Acrylic background blurring\",\
\9\9\9\9\9hint = \"<font face='GothamBlack'>Toggle BG blur</font> in some themes. May be detectable when enabled.\",\
\9\9\9\9\9index = 0,\
\9\9\9\9}),\
\9\9\9}),\
\9\9}),\
\9})\
end\
local default = hooked(Config)\
return {\
\9default = default,\
}\
", '@'.."Orca.views.Pages.Options.Config.Config")) setfenv(fn, newEnv("Orca.views.Pages.Options.Config.Config")) return fn() end)

newModule("ConfigItem", "ModuleScript", "Orca.views.Pages.Options.Config.ConfigItem", "Orca.views.Pages.Options.Config", function () local fn = assert(loadstring("-- Compiled with roblox-ts v1.2.7\
local TS = require(script.Parent.Parent.Parent.Parent.Parent.include.RuntimeLib)\
local Roact = TS.import(script, TS.getModule(script, \"@rbxts\", \"roact\").src)\
local _roact_hooked = TS.import(script, TS.getModule(script, \"@rbxts\", \"roact-hooked\").out)\
local pure = _roact_hooked.pure\
local useState = _roact_hooked.useState\
local Border = TS.import(script, script.Parent.Parent.Parent.Parent.Parent, \"components\", \"Border\").default\
local Canvas = TS.import(script, script.Parent.Parent.Parent.Parent.Parent, \"components\", \"Canvas\").default\
local Fill = TS.import(script, script.Parent.Parent.Parent.Parent.Parent, \"components\", \"Fill\").default\
local _Glow = TS.import(script, script.Parent.Parent.Parent.Parent.Parent, \"components\", \"Glow\")\
local Glow = _Glow.default\
local GlowRadius = _Glow.GlowRadius\
local _rodux_hooks = TS.import(script, script.Parent.Parent.Parent.Parent.Parent, \"hooks\", \"common\", \"rodux-hooks\")\
local useAppDispatch = _rodux_hooks.useAppDispatch\
local useAppSelector = _rodux_hooks.useAppSelector\
local useSpring = TS.import(script, script.Parent.Parent.Parent.Parent.Parent, \"hooks\", \"common\", \"use-spring\").useSpring\
local useTheme = TS.import(script, script.Parent.Parent.Parent.Parent.Parent, \"hooks\", \"use-theme\").useTheme\
local _dashboard_action = TS.import(script, script.Parent.Parent.Parent.Parent.Parent, \"store\", \"actions\", \"dashboard.action\")\
local clearHint = _dashboard_action.clearHint\
local setHint = _dashboard_action.setHint\
local setConfig = TS.import(script, script.Parent.Parent.Parent.Parent.Parent, \"store\", \"actions\", \"options.action\").setConfig\
local lerp = TS.import(script, script.Parent.Parent.Parent.Parent.Parent, \"utils\", \"number-util\").lerp\
local _udim2 = TS.import(script, script.Parent.Parent.Parent.Parent.Parent, \"utils\", \"udim2\")\
local px = _udim2.px\
local scale = _udim2.scale\
local PADDING = 20\
local ENTRY_HEIGHT = 60\
local ENTRY_WIDTH = 326 - 24 * 2\
local ENTRY_TEXT_PADDING = 16\
local function ConfigItem(_param)\
\9local action = _param.action\
\9local description = _param.description\
\9local hint = _param.hint\
\9local index = _param.index\
\9local dispatch = useAppDispatch()\
\9local buttonTheme = useTheme(\"options\").config.configButton\
\9local active = useAppSelector(function(state)\
\9\9return state.options.config[action]\
\9end)\
\9local _binding = useState(false)\
\9local hovered = _binding[1]\
\9local setHovered = _binding[2]\
\9local _result\
\9if active then\
\9\9_result = buttonTheme.accent\
\9else\
\9\9local _result_1\
\9\9if hovered then\
\9\9\9local _condition = buttonTheme.backgroundHovered\
\9\9\9if _condition == nil then\
\9\9\9\9_condition = buttonTheme.background:Lerp(buttonTheme.accent, 0.1)\
\9\9\9end\
\9\9\9_result_1 = _condition\
\9\9else\
\9\9\9_result_1 = buttonTheme.background\
\9\9end\
\9\9_result = _result_1\
\9end\
\9local background = useSpring(_result, {})\
\9local _result_1\
\9if active then\
\9\9_result_1 = buttonTheme.accent\
\9else\
\9\9local _result_2\
\9\9if hovered then\
\9\9\9local _condition = buttonTheme.backgroundHovered\
\9\9\9if _condition == nil then\
\9\9\9\9_condition = buttonTheme.dropshadow:Lerp(buttonTheme.accent, 0.5)\
\9\9\9end\
\9\9\9_result_2 = _condition\
\9\9else\
\9\9\9_result_2 = buttonTheme.dropshadow\
\9\9end\
\9\9_result_1 = _result_2\
\9end\
\9local dropshadow = useSpring(_result_1, {})\
\9local foreground = useSpring(active and buttonTheme.foregroundAccent and buttonTheme.foregroundAccent or buttonTheme.foreground, {})\
\9local _attributes = {\
\9\9size = px(ENTRY_WIDTH, ENTRY_HEIGHT),\
\9\9position = px(0, (PADDING + ENTRY_HEIGHT) * index),\
\9\9zIndex = index,\
\9}\
\9local _children = {\
\9\9Roact.createElement(Glow, {\
\9\9\9radius = GlowRadius.Size70,\
\9\9\9color = dropshadow,\
\9\9\9size = UDim2.new(1, 36, 1, 36),\
\9\9\9position = px(-18, 5 - 18),\
\9\9\9transparency = useSpring(active and buttonTheme.glowTransparency or (hovered and lerp(buttonTheme.dropshadowTransparency, buttonTheme.glowTransparency, 0.5) or buttonTheme.dropshadowTransparency), {}),\
\9\9}),\
\9\9Roact.createElement(Fill, {\
\9\9\9color = background,\
\9\9\9transparency = buttonTheme.backgroundTransparency,\
\9\9\9radius = 8,\
\9\9}),\
\9\9Roact.createElement(\"TextLabel\", {\
\9\9\9Text = description,\
\9\9\9Font = \"GothamBold\",\
\9\9\9TextSize = 16,\
\9\9\9TextColor3 = foreground,\
\9\9\9TextXAlignment = \"Left\",\
\9\9\9TextYAlignment = \"Center\",\
\9\9\9TextTransparency = useSpring(active and 0 or (hovered and buttonTheme.foregroundTransparency / 2 or buttonTheme.foregroundTransparency), {}),\
\9\9\9Position = px(ENTRY_TEXT_PADDING, 1),\
\9\9\9Size = UDim2.new(1, -ENTRY_TEXT_PADDING, 1, -1),\
\9\9\9BackgroundTransparency = 1,\
\9\9\9ClipsDescendants = true,\
\9\9}),\
\9}\
\9local _length = #_children\
\9local _child = buttonTheme.outlined and Roact.createElement(Border, {\
\9\9color = foreground,\
\9\9transparency = 0.8,\
\9\9radius = 8,\
\9})\
\9if _child then\
\9\9if _child.elements ~= nil or _child.props ~= nil and _child.component ~= nil then\
\9\9\9_children[_length + 1] = _child\
\9\9else\
\9\9\9for _k, _v in ipairs(_child) do\
\9\9\9\9_children[_length + _k] = _v\
\9\9\9end\
\9\9end\
\9end\
\9_length = #_children\
\9_children[_length + 1] = Roact.createElement(\"TextButton\", {\
\9\9[Roact.Event.Activated] = function()\
\9\9\9return dispatch(setConfig(action, not active))\
\9\9end,\
\9\9[Roact.Event.MouseEnter] = function()\
\9\9\9setHovered(true)\
\9\9\9dispatch(setHint(hint))\
\9\9end,\
\9\9[Roact.Event.MouseLeave] = function()\
\9\9\9setHovered(false)\
\9\9\9dispatch(clearHint())\
\9\9end,\
\9\9Text = \"\",\
\9\9Size = scale(1, 1),\
\9\9Transparency = 1,\
\9})\
\9return Roact.createElement(Canvas, _attributes, _children)\
end\
local default = pure(ConfigItem)\
return {\
\9PADDING = PADDING,\
\9ENTRY_HEIGHT = ENTRY_HEIGHT,\
\9ENTRY_WIDTH = ENTRY_WIDTH,\
\9ENTRY_TEXT_PADDING = ENTRY_TEXT_PADDING,\
\9default = default,\
}\
", '@'.."Orca.views.Pages.Options.Config.ConfigItem")) setfenv(fn, newEnv("Orca.views.Pages.Options.Config.ConfigItem")) return fn() end)

newModule("Options", "ModuleScript", "Orca.views.Pages.Options.Options", "Orca.views.Pages.Options", function () local fn = assert(loadstring("-- Compiled with roblox-ts v1.2.7\
local TS = require(script.Parent.Parent.Parent.Parent.include.RuntimeLib)\
local Roact = TS.import(script, TS.getModule(script, \"@rbxts\", \"roact\").src)\
local pure = TS.import(script, TS.getModule(script, \"@rbxts\", \"roact-hooked\").out).pure\
local Canvas = TS.import(script, script.Parent.Parent.Parent.Parent, \"components\", \"Canvas\").default\
local useScale = TS.import(script, script.Parent.Parent.Parent.Parent, \"hooks\", \"use-scale\").useScale\
local scale = TS.import(script, script.Parent.Parent.Parent.Parent, \"utils\", \"udim2\").scale\
local Config = TS.import(script, script.Parent, \"Config\").default\
local Shortcuts = TS.import(script, script.Parent, \"Shortcuts\").default\
local Themes = TS.import(script, script.Parent, \"Themes\").default\
local function Options()\
\9local scaleFactor = useScale()\
\9return Roact.createElement(Canvas, {\
\9\9position = scale(0, 1),\
\9\9anchor = Vector2.new(0, 1),\
\9}, {\
\9\9Roact.createElement(\"UIScale\", {\
\9\9\9Scale = scaleFactor,\
\9\9}),\
\9\9Roact.createElement(Config),\
\9\9Roact.createElement(Themes),\
\9\9Roact.createElement(Shortcuts),\
\9})\
end\
local default = pure(Options)\
return {\
\9default = default,\
}\
", '@'.."Orca.views.Pages.Options.Options")) setfenv(fn, newEnv("Orca.views.Pages.Options.Options")) return fn() end)

newModule("Shortcuts", "ModuleScript", "Orca.views.Pages.Options.Shortcuts", "Orca.views.Pages.Options", function () local fn = assert(loadstring("-- Compiled with roblox-ts v1.2.7\
local TS = require(script.Parent.Parent.Parent.Parent.include.RuntimeLib)\
local exports = {}\
exports.default = TS.import(script, script, \"Shortcuts\").default\
return exports\
", '@'.."Orca.views.Pages.Options.Shortcuts")) setfenv(fn, newEnv("Orca.views.Pages.Options.Shortcuts")) return fn() end)

newModule("ShortcutItem", "ModuleScript", "Orca.views.Pages.Options.Shortcuts.ShortcutItem", "Orca.views.Pages.Options.Shortcuts", function () local fn = assert(loadstring("-- Compiled with roblox-ts v1.2.7\
local TS = require(script.Parent.Parent.Parent.Parent.Parent.include.RuntimeLib)\
local Roact = TS.import(script, TS.getModule(script, \"@rbxts\", \"roact\").src)\
local _roact_hooked = TS.import(script, TS.getModule(script, \"@rbxts\", \"roact-hooked\").out)\
local pure = _roact_hooked.pure\
local useEffect = _roact_hooked.useEffect\
local useState = _roact_hooked.useState\
local UserInputService = TS.import(script, TS.getModule(script, \"@rbxts\", \"services\")).UserInputService\
local Border = TS.import(script, script.Parent.Parent.Parent.Parent.Parent, \"components\", \"Border\").default\
local Canvas = TS.import(script, script.Parent.Parent.Parent.Parent.Parent, \"components\", \"Canvas\").default\
local Fill = TS.import(script, script.Parent.Parent.Parent.Parent.Parent, \"components\", \"Fill\").default\
local _Glow = TS.import(script, script.Parent.Parent.Parent.Parent.Parent, \"components\", \"Glow\")\
local Glow = _Glow.default\
local GlowRadius = _Glow.GlowRadius\
local _rodux_hooks = TS.import(script, script.Parent.Parent.Parent.Parent.Parent, \"hooks\", \"common\", \"rodux-hooks\")\
local useAppDispatch = _rodux_hooks.useAppDispatch\
local useAppSelector = _rodux_hooks.useAppSelector\
local useDelayedUpdate = TS.import(script, script.Parent.Parent.Parent.Parent.Parent, \"hooks\", \"common\", \"use-delayed-update\").useDelayedUpdate\
local useSpring = TS.import(script, script.Parent.Parent.Parent.Parent.Parent, \"hooks\", \"common\", \"use-spring\").useSpring\
local useIsPageOpen = TS.import(script, script.Parent.Parent.Parent.Parent.Parent, \"hooks\", \"use-current-page\").useIsPageOpen\
local useTheme = TS.import(script, script.Parent.Parent.Parent.Parent.Parent, \"hooks\", \"use-theme\").useTheme\
local _options_action = TS.import(script, script.Parent.Parent.Parent.Parent.Parent, \"store\", \"actions\", \"options.action\")\
local removeShortcut = _options_action.removeShortcut\
local setShortcut = _options_action.setShortcut\
local DashboardPage = TS.import(script, script.Parent.Parent.Parent.Parent.Parent, \"store\", \"models\", \"dashboard.model\").DashboardPage\
local lerp = TS.import(script, script.Parent.Parent.Parent.Parent.Parent, \"utils\", \"number-util\").lerp\
local _udim2 = TS.import(script, script.Parent.Parent.Parent.Parent.Parent, \"utils\", \"udim2\")\
local px = _udim2.px\
local scale = _udim2.scale\
local PADDING = 20\
local ENTRY_HEIGHT = 60\
local ENTRY_WIDTH = 326 - 24 * 2\
local ENTRY_TEXT_PADDING = 16\
local function ShortcutItem(_param)\
\9local onActivate = _param.onActivate\
\9local onSelect = _param.onSelect\
\9local selectedItem = _param.selectedItem\
\9local action = _param.action\
\9local description = _param.description\
\9local index = _param.index\
\9local dispatch = useAppDispatch()\
\9local buttonTheme = useTheme(\"options\").shortcuts.shortcutButton\
\9local isOpen = useIsPageOpen(DashboardPage.Options)\
\9local isVisible = useDelayedUpdate(isOpen, isOpen and 250 + index * 40 or 230)\
\9local shortcut = useAppSelector(function(state)\
\9\9return state.options.shortcuts[action]\
\9end)\
\9local _exp = Enum.KeyCode:GetEnumItems()\
\9local _arg0 = function(item)\
\9\9return item.Value == shortcut\
\9end\
\9-- ▼ ReadonlyArray.find ▼\
\9local _result = nil\
\9for _i, _v in ipairs(_exp) do\
\9\9if _arg0(_v, _i - 1, _exp) == true then\
\9\9\9_result = _v\
\9\9\9break\
\9\9end\
\9end\
\9-- ▲ ReadonlyArray.find ▲\
\9local shortcutEnum = _result\
\9local selected = selectedItem == action\
\9local _binding = useState(false)\
\9local hovered = _binding[1]\
\9local setHovered = _binding[2]\
\9useEffect(function()\
\9\9if selectedItem ~= nil then\
\9\9\9return nil\
\9\9end\
\9\9local handle = UserInputService.InputBegan:Connect(function(input, gameProcessed)\
\9\9\9if not gameProcessed and input.KeyCode.Value == shortcut then\
\9\9\9\9onActivate()\
\9\9\9end\
\9\9end)\
\9\9return function()\
\9\9\9handle:Disconnect()\
\9\9end\
\9end, { selectedItem, shortcut })\
\9useEffect(function()\
\9\9if not selected then\
\9\9\9return nil\
\9\9end\
\9\9local handle = UserInputService.InputBegan:Connect(function(input, gameProcessed)\
\9\9\9if gameProcessed then\
\9\9\9\9return nil\
\9\9\9end\
\9\9\9if input.UserInputType == Enum.UserInputType.MouseButton1 then\
\9\9\9\9onSelect(nil)\
\9\9\9\9return nil\
\9\9\9end\
\9\9\9local _exp_1 = input.KeyCode\
\9\9\9repeat\
\9\9\9\9if _exp_1 == (Enum.KeyCode.Unknown) then\
\9\9\9\9\9break\
\9\9\9\9end\
\9\9\9\9if _exp_1 == (Enum.KeyCode.Escape) then\
\9\9\9\9\9dispatch(removeShortcut(action))\
\9\9\9\9\9onSelect(nil)\
\9\9\9\9\9break\
\9\9\9\9end\
\9\9\9\9if _exp_1 == (Enum.KeyCode.Backspace) then\
\9\9\9\9\9dispatch(removeShortcut(action))\
\9\9\9\9\9onSelect(nil)\
\9\9\9\9\9break\
\9\9\9\9end\
\9\9\9\9if _exp_1 == (Enum.KeyCode.Return) then\
\9\9\9\9\9onSelect(nil)\
\9\9\9\9\9break\
\9\9\9\9end\
\9\9\9\9dispatch(setShortcut(action, input.KeyCode.Value))\
\9\9\9\9onSelect(nil)\
\9\9\9\9break\
\9\9\9until true\
\9\9end)\
\9\9return function()\
\9\9\9handle:Disconnect()\
\9\9end\
\9end, { selected })\
\9local _result_1\
\9if selected then\
\9\9_result_1 = buttonTheme.accent\
\9else\
\9\9local _result_2\
\9\9if hovered then\
\9\9\9local _condition = buttonTheme.backgroundHovered\
\9\9\9if _condition == nil then\
\9\9\9\9_condition = buttonTheme.background:Lerp(buttonTheme.accent, 0.1)\
\9\9\9end\
\9\9\9_result_2 = _condition\
\9\9else\
\9\9\9_result_2 = buttonTheme.background\
\9\9end\
\9\9_result_1 = _result_2\
\9end\
\9local background = useSpring(_result_1, {})\
\9local _result_2\
\9if selected then\
\9\9_result_2 = buttonTheme.accent\
\9else\
\9\9local _result_3\
\9\9if hovered then\
\9\9\9local _condition = buttonTheme.backgroundHovered\
\9\9\9if _condition == nil then\
\9\9\9\9_condition = buttonTheme.dropshadow:Lerp(buttonTheme.accent, 0.5)\
\9\9\9end\
\9\9\9_result_3 = _condition\
\9\9else\
\9\9\9_result_3 = buttonTheme.dropshadow\
\9\9end\
\9\9_result_2 = _result_3\
\9end\
\9local dropshadow = useSpring(_result_2, {})\
\9local foreground = useSpring(selected and buttonTheme.foregroundAccent and buttonTheme.foregroundAccent or buttonTheme.foreground, {})\
\9local _attributes = {\
\9\9size = px(ENTRY_WIDTH, ENTRY_HEIGHT),\
\9\9position = useSpring(isVisible and px(0, (PADDING + ENTRY_HEIGHT) * index) or px(-ENTRY_WIDTH - 24, (PADDING + ENTRY_HEIGHT) * index), {}),\
\9\9zIndex = index,\
\9}\
\9local _children = {\
\9\9Roact.createElement(Glow, {\
\9\9\9radius = GlowRadius.Size70,\
\9\9\9color = dropshadow,\
\9\9\9size = UDim2.new(1, 36, 1, 36),\
\9\9\9position = px(-18, 5 - 18),\
\9\9\9transparency = useSpring(selected and buttonTheme.glowTransparency or (hovered and lerp(buttonTheme.dropshadowTransparency, buttonTheme.glowTransparency, 0.5) or buttonTheme.dropshadowTransparency), {}),\
\9\9}),\
\9\9Roact.createElement(Fill, {\
\9\9\9color = background,\
\9\9\9transparency = buttonTheme.backgroundTransparency,\
\9\9\9radius = 8,\
\9\9}),\
\9\9Roact.createElement(\"TextLabel\", {\
\9\9\9Text = description,\
\9\9\9Font = \"GothamBold\",\
\9\9\9TextSize = 16,\
\9\9\9TextColor3 = foreground,\
\9\9\9TextXAlignment = \"Left\",\
\9\9\9TextYAlignment = \"Center\",\
\9\9\9TextTransparency = useSpring(selected and 0 or (hovered and buttonTheme.foregroundTransparency / 2 or buttonTheme.foregroundTransparency), {}),\
\9\9\9Position = px(ENTRY_TEXT_PADDING, 1),\
\9\9\9Size = UDim2.new(1, -ENTRY_TEXT_PADDING, 1, -1),\
\9\9\9BackgroundTransparency = 1,\
\9\9\9ClipsDescendants = true,\
\9\9}),\
\9\9Roact.createElement(\"TextLabel\", {\
\9\9\9Text = shortcutEnum and shortcutEnum.Name or \"Not bound\",\
\9\9\9Font = \"GothamBold\",\
\9\9\9TextSize = 16,\
\9\9\9TextColor3 = foreground,\
\9\9\9TextXAlignment = \"Center\",\
\9\9\9TextYAlignment = \"Center\",\
\9\9\9TextTransparency = useSpring(selected and 0 or (hovered and buttonTheme.foregroundTransparency / 2 or buttonTheme.foregroundTransparency), {}),\
\9\9\9TextTruncate = \"AtEnd\",\
\9\9\9AnchorPoint = Vector2.new(1, 0),\
\9\9\9Position = UDim2.new(1, 0, 0, 1),\
\9\9\9Size = UDim2.new(0, 124, 1, -1),\
\9\9\9BackgroundTransparency = 1,\
\9\9\9ClipsDescendants = true,\
\9\9}),\
\9\9Roact.createElement(\"Frame\", {\
\9\9\9Size = buttonTheme.outlined and UDim2.new(0, 1, 1, -2) or UDim2.new(0, 1, 1, -36),\
\9\9\9Position = buttonTheme.outlined and UDim2.new(1, -124, 0, 1) or UDim2.new(1, -124, 0, 18),\
\9\9\9BackgroundColor3 = foreground,\
\9\9\9BackgroundTransparency = 0.8,\
\9\9\9BorderSizePixel = 0,\
\9\9}),\
\9}\
\9local _length = #_children\
\9local _child = buttonTheme.outlined and Roact.createElement(Border, {\
\9\9color = foreground,\
\9\9transparency = 0.8,\
\9\9radius = 8,\
\9})\
\9if _child then\
\9\9if _child.elements ~= nil or _child.props ~= nil and _child.component ~= nil then\
\9\9\9_children[_length + 1] = _child\
\9\9else\
\9\9\9for _k, _v in ipairs(_child) do\
\9\9\9\9_children[_length + _k] = _v\
\9\9\9end\
\9\9end\
\9end\
\9_length = #_children\
\9_children[_length + 1] = Roact.createElement(\"TextButton\", {\
\9\9[Roact.Event.Activated] = function()\
\9\9\9return onSelect(action)\
\9\9end,\
\9\9[Roact.Event.MouseEnter] = function()\
\9\9\9return setHovered(true)\
\9\9end,\
\9\9[Roact.Event.MouseLeave] = function()\
\9\9\9return setHovered(false)\
\9\9end,\
\9\9Text = \"\",\
\9\9Size = scale(1, 1),\
\9\9Transparency = 1,\
\9})\
\9return Roact.createElement(Canvas, _attributes, _children)\
end\
local default = pure(ShortcutItem)\
return {\
\9PADDING = PADDING,\
\9ENTRY_HEIGHT = ENTRY_HEIGHT,\
\9ENTRY_WIDTH = ENTRY_WIDTH,\
\9ENTRY_TEXT_PADDING = ENTRY_TEXT_PADDING,\
\9default = default,\
}\
", '@'.."Orca.views.Pages.Options.Shortcuts.ShortcutItem")) setfenv(fn, newEnv("Orca.views.Pages.Options.Shortcuts.ShortcutItem")) return fn() end)

newModule("Shortcuts", "ModuleScript", "Orca.views.Pages.Options.Shortcuts.Shortcuts", "Orca.views.Pages.Options.Shortcuts", function () local fn = assert(loadstring("-- Compiled with roblox-ts v1.2.7\
local TS = require(script.Parent.Parent.Parent.Parent.Parent.include.RuntimeLib)\
local Roact = TS.import(script, TS.getModule(script, \"@rbxts\", \"roact\").src)\
local _roact_hooked = TS.import(script, TS.getModule(script, \"@rbxts\", \"roact-hooked\").out)\
local hooked = _roact_hooked.hooked\
local useState = _roact_hooked.useState\
local Canvas = TS.import(script, script.Parent.Parent.Parent.Parent.Parent, \"components\", \"Canvas\").default\
local Card = TS.import(script, script.Parent.Parent.Parent.Parent.Parent, \"components\", \"Card\").default\
local _rodux_hooks = TS.import(script, script.Parent.Parent.Parent.Parent.Parent, \"hooks\", \"common\", \"rodux-hooks\")\
local useAppDispatch = _rodux_hooks.useAppDispatch\
local useAppStore = _rodux_hooks.useAppStore\
local useTheme = TS.import(script, script.Parent.Parent.Parent.Parent.Parent, \"hooks\", \"use-theme\").useTheme\
local toggleDashboard = TS.import(script, script.Parent.Parent.Parent.Parent.Parent, \"store\", \"actions\", \"dashboard.action\").toggleDashboard\
local setJobActive = TS.import(script, script.Parent.Parent.Parent.Parent.Parent, \"store\", \"actions\", \"jobs.action\").setJobActive\
local DashboardPage = TS.import(script, script.Parent.Parent.Parent.Parent.Parent, \"store\", \"models\", \"dashboard.model\").DashboardPage\
local _udim2 = TS.import(script, script.Parent.Parent.Parent.Parent.Parent, \"utils\", \"udim2\")\
local px = _udim2.px\
local scale = _udim2.scale\
local _ShortcutItem = TS.import(script, script.Parent, \"ShortcutItem\")\
local ShortcutItem = _ShortcutItem.default\
local ENTRY_HEIGHT = _ShortcutItem.ENTRY_HEIGHT\
local PADDING = _ShortcutItem.PADDING\
local ENTRY_COUNT = 5\
local function Shortcuts()\
\9local store = useAppStore()\
\9local dispatch = useAppDispatch()\
\9local theme = useTheme(\"options\").shortcuts\
\9local _binding = useState(nil)\
\9local selectedItem = _binding[1]\
\9local setSelectedItem = _binding[2]\
\9return Roact.createElement(Card, {\
\9\9index = 1,\
\9\9page = DashboardPage.Options,\
\9\9theme = theme,\
\9\9size = px(326, 416),\
\9\9position = UDim2.new(0, 0, 1, 0),\
\9}, {\
\9\9Roact.createElement(\"TextLabel\", {\
\9\9\9Text = \"Shortcuts\",\
\9\9\9Font = \"GothamBlack\",\
\9\9\9TextSize = 20,\
\9\9\9TextColor3 = theme.foreground,\
\9\9\9TextXAlignment = \"Left\",\
\9\9\9TextYAlignment = \"Top\",\
\9\9\9Position = px(24, 24),\
\9\9\9BackgroundTransparency = 1,\
\9\9}),\
\9\9Roact.createElement(Canvas, {\
\9\9\9size = px(326, 348),\
\9\9\9position = px(0, 68),\
\9\9\9padding = {\
\9\9\9\9left = 24,\
\9\9\9\9right = 24,\
\9\9\9\9top = 8,\
\9\9\9},\
\9\9\9clipsDescendants = true,\
\9\9}, {\
\9\9\9Roact.createElement(\"ScrollingFrame\", {\
\9\9\9\9Size = scale(1, 1),\
\9\9\9\9CanvasSize = px(0, ENTRY_COUNT * (ENTRY_HEIGHT + PADDING) + PADDING),\
\9\9\9\9BackgroundTransparency = 1,\
\9\9\9\9BorderSizePixel = 0,\
\9\9\9\9ScrollBarImageTransparency = 1,\
\9\9\9\9ScrollBarThickness = 0,\
\9\9\9\9ClipsDescendants = false,\
\9\9\9}, {\
\9\9\9\9Roact.createElement(ShortcutItem, {\
\9\9\9\9\9onActivate = function()\
\9\9\9\9\9\9dispatch(toggleDashboard())\
\9\9\9\9\9end,\
\9\9\9\9\9onSelect = setSelectedItem,\
\9\9\9\9\9selectedItem = selectedItem,\
\9\9\9\9\9action = \"toggleDashboard\",\
\9\9\9\9\9description = \"Open Orca\",\
\9\9\9\9\9index = 0,\
\9\9\9\9}),\
\9\9\9\9Roact.createElement(ShortcutItem, {\
\9\9\9\9\9onActivate = function()\
\9\9\9\9\9\9dispatch(setJobActive(\"flight\", not store:getState().jobs.flight.active))\
\9\9\9\9\9end,\
\9\9\9\9\9onSelect = setSelectedItem,\
\9\9\9\9\9selectedItem = selectedItem,\
\9\9\9\9\9action = \"toggleFlight\",\
\9\9\9\9\9description = \"Toggle flight\",\
\9\9\9\9\9index = 1,\
\9\9\9\9}),\
\9\9\9\9Roact.createElement(ShortcutItem, {\
\9\9\9\9\9onActivate = function()\
\9\9\9\9\9\9dispatch(setJobActive(\"ghost\", not store:getState().jobs.ghost.active))\
\9\9\9\9\9end,\
\9\9\9\9\9onSelect = setSelectedItem,\
\9\9\9\9\9selectedItem = selectedItem,\
\9\9\9\9\9action = \"setGhost\",\
\9\9\9\9\9description = \"Set ghost mode\",\
\9\9\9\9\9index = 2,\
\9\9\9\9}),\
\9\9\9\9Roact.createElement(ShortcutItem, {\
\9\9\9\9\9onActivate = function()\
\9\9\9\9\9\9dispatch(setJobActive(\"walkSpeed\", not store:getState().jobs.walkSpeed.active))\
\9\9\9\9\9end,\
\9\9\9\9\9onSelect = setSelectedItem,\
\9\9\9\9\9selectedItem = selectedItem,\
\9\9\9\9\9action = \"setSpeed\",\
\9\9\9\9\9description = \"Set walk speed\",\
\9\9\9\9\9index = 3,\
\9\9\9\9}),\
\9\9\9\9Roact.createElement(ShortcutItem, {\
\9\9\9\9\9onActivate = function()\
\9\9\9\9\9\9dispatch(setJobActive(\"jumpHeight\", not store:getState().jobs.jumpHeight.active))\
\9\9\9\9\9end,\
\9\9\9\9\9onSelect = setSelectedItem,\
\9\9\9\9\9selectedItem = selectedItem,\
\9\9\9\9\9action = \"setJumpHeight\",\
\9\9\9\9\9description = \"Set jump height\",\
\9\9\9\9\9index = 4,\
\9\9\9\9}),\
\9\9\9}),\
\9\9}),\
\9})\
end\
local default = hooked(Shortcuts)\
return {\
\9default = default,\
}\
", '@'.."Orca.views.Pages.Options.Shortcuts.Shortcuts")) setfenv(fn, newEnv("Orca.views.Pages.Options.Shortcuts.Shortcuts")) return fn() end)

newModule("Themes", "ModuleScript", "Orca.views.Pages.Options.Themes", "Orca.views.Pages.Options", function () local fn = assert(loadstring("-- Compiled with roblox-ts v1.2.7\
local TS = require(script.Parent.Parent.Parent.Parent.include.RuntimeLib)\
local exports = {}\
exports.default = TS.import(script, script, \"Themes\").default\
return exports\
", '@'.."Orca.views.Pages.Options.Themes")) setfenv(fn, newEnv("Orca.views.Pages.Options.Themes")) return fn() end)

newModule("ThemeItem", "ModuleScript", "Orca.views.Pages.Options.Themes.ThemeItem", "Orca.views.Pages.Options.Themes", function () local fn = assert(loadstring("-- Compiled with roblox-ts v1.2.7\
local TS = require(script.Parent.Parent.Parent.Parent.Parent.include.RuntimeLib)\
local Roact = TS.import(script, TS.getModule(script, \"@rbxts\", \"roact\").src)\
local _roact_hooked = TS.import(script, TS.getModule(script, \"@rbxts\", \"roact-hooked\").out)\
local hooked = _roact_hooked.hooked\
local useState = _roact_hooked.useState\
local Border = TS.import(script, script.Parent.Parent.Parent.Parent.Parent, \"components\", \"Border\").default\
local Canvas = TS.import(script, script.Parent.Parent.Parent.Parent.Parent, \"components\", \"Canvas\").default\
local Fill = TS.import(script, script.Parent.Parent.Parent.Parent.Parent, \"components\", \"Fill\").default\
local _Glow = TS.import(script, script.Parent.Parent.Parent.Parent.Parent, \"components\", \"Glow\")\
local Glow = _Glow.default\
local GlowRadius = _Glow.GlowRadius\
local _rodux_hooks = TS.import(script, script.Parent.Parent.Parent.Parent.Parent, \"hooks\", \"common\", \"rodux-hooks\")\
local useAppDispatch = _rodux_hooks.useAppDispatch\
local useAppSelector = _rodux_hooks.useAppSelector\
local useDelayedUpdate = TS.import(script, script.Parent.Parent.Parent.Parent.Parent, \"hooks\", \"common\", \"use-delayed-update\").useDelayedUpdate\
local useSpring = TS.import(script, script.Parent.Parent.Parent.Parent.Parent, \"hooks\", \"common\", \"use-spring\").useSpring\
local useIsPageOpen = TS.import(script, script.Parent.Parent.Parent.Parent.Parent, \"hooks\", \"use-current-page\").useIsPageOpen\
local useTheme = TS.import(script, script.Parent.Parent.Parent.Parent.Parent, \"hooks\", \"use-theme\").useTheme\
local setTheme = TS.import(script, script.Parent.Parent.Parent.Parent.Parent, \"store\", \"actions\", \"options.action\").setTheme\
local DashboardPage = TS.import(script, script.Parent.Parent.Parent.Parent.Parent, \"store\", \"models\", \"dashboard.model\").DashboardPage\
local _color3 = TS.import(script, script.Parent.Parent.Parent.Parent.Parent, \"utils\", \"color3\")\
local getLuminance = _color3.getLuminance\
local hex = _color3.hex\
local lerp = TS.import(script, script.Parent.Parent.Parent.Parent.Parent, \"utils\", \"number-util\").lerp\
local _udim2 = TS.import(script, script.Parent.Parent.Parent.Parent.Parent, \"utils\", \"udim2\")\
local px = _udim2.px\
local scale = _udim2.scale\
local PADDING = 20\
local ENTRY_HEIGHT = 60\
local ENTRY_WIDTH = 326 - 24 * 2\
local ENTRY_TEXT_PADDING = 16\
local ThemePreview\
local function ThemeItem(_param)\
\9local theme = _param.theme\
\9local index = _param.index\
\9local dispatch = useAppDispatch()\
\9local buttonTheme = useTheme(\"options\").themes.themeButton\
\9local isOpen = useIsPageOpen(DashboardPage.Options)\
\9local isVisible = useDelayedUpdate(isOpen, isOpen and 300 + index * 40 or 280)\
\9local isSelected = useAppSelector(function(state)\
\9\9return state.options.currentTheme == theme.name\
\9end)\
\9local _binding = useState(false)\
\9local hovered = _binding[1]\
\9local setHovered = _binding[2]\
\9local _result\
\9if isSelected then\
\9\9_result = buttonTheme.accent\
\9else\
\9\9local _result_1\
\9\9if hovered then\
\9\9\9local _condition = buttonTheme.backgroundHovered\
\9\9\9if _condition == nil then\
\9\9\9\9_condition = buttonTheme.background:Lerp(buttonTheme.accent, 0.1)\
\9\9\9end\
\9\9\9_result_1 = _condition\
\9\9else\
\9\9\9_result_1 = buttonTheme.background\
\9\9end\
\9\9_result = _result_1\
\9end\
\9local background = useSpring(_result, {})\
\9local _result_1\
\9if isSelected then\
\9\9_result_1 = buttonTheme.accent\
\9else\
\9\9local _result_2\
\9\9if hovered then\
\9\9\9local _condition = buttonTheme.backgroundHovered\
\9\9\9if _condition == nil then\
\9\9\9\9_condition = buttonTheme.dropshadow:Lerp(buttonTheme.accent, 0.5)\
\9\9\9end\
\9\9\9_result_2 = _condition\
\9\9else\
\9\9\9_result_2 = buttonTheme.dropshadow\
\9\9end\
\9\9_result_1 = _result_2\
\9end\
\9local dropshadow = useSpring(_result_1, {})\
\9local foreground = useSpring(isSelected and buttonTheme.foregroundAccent and buttonTheme.foregroundAccent or buttonTheme.foreground, {})\
\9local _attributes = {\
\9\9size = px(ENTRY_WIDTH, ENTRY_HEIGHT),\
\9\9position = useSpring(isVisible and px(0, (PADDING + ENTRY_HEIGHT) * index) or px(-ENTRY_WIDTH - 24, (PADDING + ENTRY_HEIGHT) * index), {}),\
\9\9zIndex = index,\
\9}\
\9local _children = {\
\9\9Roact.createElement(Glow, {\
\9\9\9radius = GlowRadius.Size70,\
\9\9\9color = dropshadow,\
\9\9\9size = UDim2.new(1, 36, 1, 36),\
\9\9\9position = px(-18, 5 - 18),\
\9\9\9transparency = useSpring(isSelected and buttonTheme.glowTransparency or (hovered and lerp(buttonTheme.dropshadowTransparency, buttonTheme.glowTransparency, 0.5) or buttonTheme.dropshadowTransparency), {}),\
\9\9}),\
\9\9Roact.createElement(Fill, {\
\9\9\9color = background,\
\9\9\9transparency = buttonTheme.backgroundTransparency,\
\9\9\9radius = 8,\
\9\9}),\
\9\9Roact.createElement(\"TextLabel\", {\
\9\9\9Text = theme.name,\
\9\9\9Font = \"GothamBold\",\
\9\9\9TextSize = 16,\
\9\9\9TextColor3 = foreground,\
\9\9\9TextXAlignment = Enum.TextXAlignment.Left,\
\9\9\9TextYAlignment = Enum.TextYAlignment.Center,\
\9\9\9TextTransparency = useSpring(isSelected and 0 or (hovered and buttonTheme.foregroundTransparency / 2 or buttonTheme.foregroundTransparency), {}),\
\9\9\9BackgroundTransparency = 1,\
\9\9\9Position = px(ENTRY_TEXT_PADDING, 1),\
\9\9\9Size = UDim2.new(1, -ENTRY_TEXT_PADDING, 1, -1),\
\9\9\9ClipsDescendants = true,\
\9\9}),\
\9\9Roact.createElement(ThemePreview, {\
\9\9\9color = background,\
\9\9\9previewTheme = theme.preview,\
\9\9}),\
\9}\
\9local _length = #_children\
\9local _child = buttonTheme.outlined and Roact.createElement(Border, {\
\9\9color = foreground,\
\9\9transparency = 0.8,\
\9\9radius = 8,\
\9})\
\9if _child then\
\9\9if _child.elements ~= nil or _child.props ~= nil and _child.component ~= nil then\
\9\9\9_children[_length + 1] = _child\
\9\9else\
\9\9\9for _k, _v in ipairs(_child) do\
\9\9\9\9_children[_length + _k] = _v\
\9\9\9end\
\9\9end\
\9end\
\9_length = #_children\
\9_children[_length + 1] = Roact.createElement(\"TextButton\", {\
\9\9[Roact.Event.Activated] = function()\
\9\9\9return not isSelected and dispatch(setTheme(theme.name))\
\9\9end,\
\9\9[Roact.Event.MouseEnter] = function()\
\9\9\9return setHovered(true)\
\9\9end,\
\9\9[Roact.Event.MouseLeave] = function()\
\9\9\9return setHovered(false)\
\9\9end,\
\9\9Text = \"\",\
\9\9Transparency = 1,\
\9\9Size = scale(1, 1),\
\9})\
\9return Roact.createElement(Canvas, _attributes, _children)\
end\
local default = hooked(ThemeItem)\
function ThemePreview(_param)\
\9local color = _param.color\
\9local previewTheme = _param.previewTheme\
\9return Roact.createElement(\"Frame\", {\
\9\9AnchorPoint = Vector2.new(1, 0),\
\9\9Size = UDim2.new(0, 114, 1, -4),\
\9\9Position = UDim2.new(1, -2, 0, 2),\
\9\9BackgroundColor3 = color,\
\9\9Transparency = 1,\
\9\9BorderSizePixel = 0,\
\9}, {\
\9\9Roact.createElement(\"UICorner\", {\
\9\9\9CornerRadius = UDim.new(0, 6),\
\9\9}),\
\9\9Roact.createElement(\"Frame\", {\
\9\9\9AnchorPoint = Vector2.new(0, 0.5),\
\9\9\9Size = px(25, 25),\
\9\9\9Position = UDim2.new(0, 12, 0.5, 0),\
\9\9\9BackgroundColor3 = hex(\"#ffffff\"),\
\9\9\9BorderSizePixel = 0,\
\9\9}, {\
\9\9\9Roact.createElement(\"UICorner\", {\
\9\9\9\9CornerRadius = UDim.new(1, 0),\
\9\9\9}),\
\9\9\9Roact.createElement(\"UIGradient\", {\
\9\9\9\9Color = previewTheme.foreground.color,\
\9\9\9\9Transparency = previewTheme.foreground.transparency,\
\9\9\9\9Rotation = previewTheme.foreground.rotation,\
\9\9\9}),\
\9\9\9Roact.createElement(\"UIStroke\", {\
\9\9\9\9Color = getLuminance(previewTheme.foreground.color) > 0.5 and hex(\"#000000\") or hex(\"#ffffff\"),\
\9\9\9\9Transparency = 0.5,\
\9\9\9\9Thickness = 2,\
\9\9\9}),\
\9\9}),\
\9\9Roact.createElement(\"Frame\", {\
\9\9\9AnchorPoint = Vector2.new(0.5, 0.5),\
\9\9\9Size = px(25, 25),\
\9\9\9Position = UDim2.new(0.5, 0, 0.5, 0),\
\9\9\9BackgroundColor3 = hex(\"#ffffff\"),\
\9\9\9BorderSizePixel = 0,\
\9\9}, {\
\9\9\9Roact.createElement(\"UICorner\", {\
\9\9\9\9CornerRadius = UDim.new(1, 0),\
\9\9\9}),\
\9\9\9Roact.createElement(\"UIGradient\", {\
\9\9\9\9Color = previewTheme.background.color,\
\9\9\9\9Transparency = previewTheme.background.transparency,\
\9\9\9\9Rotation = previewTheme.background.rotation,\
\9\9\9}),\
\9\9\9Roact.createElement(\"UIStroke\", {\
\9\9\9\9Color = getLuminance(previewTheme.background.color) > 0.5 and hex(\"#000000\") or hex(\"#ffffff\"),\
\9\9\9\9Transparency = 0.5,\
\9\9\9\9Thickness = 2,\
\9\9\9}),\
\9\9}),\
\9\9Roact.createElement(\"Frame\", {\
\9\9\9AnchorPoint = Vector2.new(1, 0.5),\
\9\9\9Size = px(25, 25),\
\9\9\9Position = UDim2.new(1, -12, 0.5, 0),\
\9\9\9BackgroundColor3 = hex(\"#ffffff\"),\
\9\9\9BorderSizePixel = 0,\
\9\9}, {\
\9\9\9Roact.createElement(\"UICorner\", {\
\9\9\9\9CornerRadius = UDim.new(1, 0),\
\9\9\9}),\
\9\9\9Roact.createElement(\"UIGradient\", {\
\9\9\9\9Color = previewTheme.accent.color,\
\9\9\9\9Transparency = previewTheme.accent.transparency,\
\9\9\9\9Rotation = previewTheme.accent.rotation,\
\9\9\9}),\
\9\9\9Roact.createElement(\"UIStroke\", {\
\9\9\9\9Color = getLuminance(previewTheme.accent.color) > 0.5 and hex(\"#000000\") or hex(\"#ffffff\"),\
\9\9\9\9Transparency = 0.5,\
\9\9\9\9Thickness = 2,\
\9\9\9}),\
\9\9}),\
\9})\
end\
return {\
\9PADDING = PADDING,\
\9ENTRY_HEIGHT = ENTRY_HEIGHT,\
\9ENTRY_WIDTH = ENTRY_WIDTH,\
\9ENTRY_TEXT_PADDING = ENTRY_TEXT_PADDING,\
\9default = default,\
}\
", '@'.."Orca.views.Pages.Options.Themes.ThemeItem")) setfenv(fn, newEnv("Orca.views.Pages.Options.Themes.ThemeItem")) return fn() end)

newModule("Themes", "ModuleScript", "Orca.views.Pages.Options.Themes.Themes", "Orca.views.Pages.Options.Themes", function () local fn = assert(loadstring("-- Compiled with roblox-ts v1.2.7\
local TS = require(script.Parent.Parent.Parent.Parent.Parent.include.RuntimeLib)\
local Roact = TS.import(script, TS.getModule(script, \"@rbxts\", \"roact\").src)\
local _roact_hooked = TS.import(script, TS.getModule(script, \"@rbxts\", \"roact-hooked\").out)\
local hooked = _roact_hooked.hooked\
local useMemo = _roact_hooked.useMemo\
local Canvas = TS.import(script, script.Parent.Parent.Parent.Parent.Parent, \"components\", \"Canvas\").default\
local Card = TS.import(script, script.Parent.Parent.Parent.Parent.Parent, \"components\", \"Card\").default\
local useTheme = TS.import(script, script.Parent.Parent.Parent.Parent.Parent, \"hooks\", \"use-theme\").useTheme\
local DashboardPage = TS.import(script, script.Parent.Parent.Parent.Parent.Parent, \"store\", \"models\", \"dashboard.model\").DashboardPage\
local getThemes = TS.import(script, script.Parent.Parent.Parent.Parent.Parent, \"themes\").getThemes\
local arrayToMap = TS.import(script, script.Parent.Parent.Parent.Parent.Parent, \"utils\", \"array-util\").arrayToMap\
local _udim2 = TS.import(script, script.Parent.Parent.Parent.Parent.Parent, \"utils\", \"udim2\")\
local px = _udim2.px\
local scale = _udim2.scale\
local _ThemeItem = TS.import(script, script.Parent, \"ThemeItem\")\
local ThemeItem = _ThemeItem.default\
local ENTRY_HEIGHT = _ThemeItem.ENTRY_HEIGHT\
local PADDING = _ThemeItem.PADDING\
local function Themes()\
\9local theme = useTheme(\"options\").themes\
\9local themes = useMemo(getThemes, {})\
\9local _attributes = {\
\9\9index = 2,\
\9\9page = DashboardPage.Options,\
\9\9theme = theme,\
\9\9size = px(326, 416),\
\9\9position = UDim2.new(0, 374, 1, 0),\
\9}\
\9local _children = {\
\9\9Roact.createElement(\"TextLabel\", {\
\9\9\9Text = \"Themes\",\
\9\9\9Font = \"GothamBlack\",\
\9\9\9TextSize = 20,\
\9\9\9TextColor3 = theme.foreground,\
\9\9\9TextXAlignment = \"Left\",\
\9\9\9TextYAlignment = \"Top\",\
\9\9\9Position = px(24, 24),\
\9\9\9BackgroundTransparency = 1,\
\9\9}),\
\9}\
\9local _length = #_children\
\9local _attributes_1 = {\
\9\9size = px(326, 348),\
\9\9position = px(0, 68),\
\9\9padding = {\
\9\9\9left = 24,\
\9\9\9right = 24,\
\9\9\9top = 8,\
\9\9},\
\9\9clipsDescendants = true,\
\9}\
\9local _children_1 = {}\
\9local _length_1 = #_children_1\
\9local _attributes_2 = {\
\9\9Size = scale(1, 1),\
\9\9CanvasSize = px(0, #themes * (ENTRY_HEIGHT + PADDING) + PADDING),\
\9\9BackgroundTransparency = 1,\
\9\9BorderSizePixel = 0,\
\9\9ScrollBarImageTransparency = 1,\
\9\9ScrollBarThickness = 0,\
\9\9ClipsDescendants = false,\
\9}\
\9local _children_2 = {}\
\9local _length_2 = #_children_2\
\9for _k, _v in pairs(arrayToMap(themes, function(theme, index)\
\9\9return { theme.name, Roact.createElement(ThemeItem, {\
\9\9\9theme = theme,\
\9\9\9index = index,\
\9\9}) }\
\9end)) do\
\9\9_children_2[_k] = _v\
\9end\
\9_children_1[_length_1 + 1] = Roact.createElement(\"ScrollingFrame\", _attributes_2, _children_2)\
\9_children[_length + 1] = Roact.createElement(Canvas, _attributes_1, _children_1)\
\9return Roact.createElement(Card, _attributes, _children)\
end\
local default = hooked(Themes)\
return {\
\9default = default,\
}\
", '@'.."Orca.views.Pages.Options.Themes.Themes")) setfenv(fn, newEnv("Orca.views.Pages.Options.Themes.Themes")) return fn() end)

newModule("Pages", "ModuleScript", "Orca.views.Pages.Pages", "Orca.views.Pages", function () local fn = assert(loadstring("-- Compiled with roblox-ts v1.2.7\
local TS = require(script.Parent.Parent.Parent.include.RuntimeLib)\
local Roact = TS.import(script, TS.getModule(script, \"@rbxts\", \"roact\").src)\
local hooked = TS.import(script, TS.getModule(script, \"@rbxts\", \"roact-hooked\").out).hooked\
local useDelayedUpdate = TS.import(script, script.Parent.Parent.Parent, \"hooks\", \"common\", \"use-delayed-update\").useDelayedUpdate\
local useCurrentPage = TS.import(script, script.Parent.Parent.Parent, \"hooks\", \"use-current-page\").useCurrentPage\
local DashboardPage = TS.import(script, script.Parent.Parent.Parent, \"store\", \"models\", \"dashboard.model\").DashboardPage\
local Apps = TS.import(script, script.Parent, \"Apps\").default\
local Home = TS.import(script, script.Parent, \"Home\").default\
local Options = TS.import(script, script.Parent, \"Options\").default\
local Scripts = TS.import(script, script.Parent, \"Scripts\").default\
local function Pages()\
\9local currentPage = useCurrentPage()\
\9local isScriptsVisible = useDelayedUpdate(currentPage == DashboardPage.Scripts, 2000, function(isVisible)\
\9\9return isVisible\
\9end)\
\9local _children = {\
\9\9home = Roact.createFragment({\
\9\9\9home = Roact.createElement(Home),\
\9\9}),\
\9\9apps = Roact.createFragment({\
\9\9\9apps = Roact.createElement(Apps),\
\9\9}),\
\9}\
\9local _length = #_children\
\9local _child = isScriptsVisible and Roact.createFragment({\
\9\9scripts = Roact.createElement(Scripts),\
\9})\
\9if _child then\
\9\9if _child.elements ~= nil or _child.props ~= nil and _child.component ~= nil then\
\9\9\9_children[_length + 1] = _child\
\9\9else\
\9\9\9for _k, _v in ipairs(_child) do\
\9\9\9\9_children[_length + _k] = _v\
\9\9\9end\
\9\9end\
\9end\
\9_length = #_children\
\9_children.options = Roact.createFragment({\
\9\9options = Roact.createElement(Options),\
\9})\
\9return Roact.createFragment(_children)\
end\
local default = hooked(Pages)\
return {\
\9default = default,\
}\
", '@'.."Orca.views.Pages.Pages")) setfenv(fn, newEnv("Orca.views.Pages.Pages")) return fn() end)

newModule("Scripts", "ModuleScript", "Orca.views.Pages.Scripts", "Orca.views.Pages", function () local fn = assert(loadstring("-- Compiled with roblox-ts v1.2.7\
local TS = require(script.Parent.Parent.Parent.include.RuntimeLib)\
local exports = {}\
exports.default = TS.import(script, script, \"Scripts\").default\
return exports\
", '@'.."Orca.views.Pages.Scripts")) setfenv(fn, newEnv("Orca.views.Pages.Scripts")) return fn() end)

newModule("Content", "ModuleScript", "Orca.views.Pages.Scripts.Content", "Orca.views.Pages.Scripts", function () local fn = assert(loadstring("-- Compiled with roblox-ts v1.2.7\
local TS = require(script.Parent.Parent.Parent.Parent.include.RuntimeLib)\
local Roact = TS.import(script, TS.getModule(script, \"@rbxts\", \"roact\").src)\
local hooked = TS.import(script, TS.getModule(script, \"@rbxts\", \"roact-hooked\").out).hooked\
local Canvas = TS.import(script, script.Parent.Parent.Parent.Parent, \"components\", \"Canvas\").default\
local useScale = TS.import(script, script.Parent.Parent.Parent.Parent, \"hooks\", \"use-scale\").useScale\
local hex = TS.import(script, script.Parent.Parent.Parent.Parent, \"utils\", \"color3\").hex\
local _udim2 = TS.import(script, script.Parent.Parent.Parent.Parent, \"utils\", \"udim2\")\
local px = _udim2.px\
local scale = _udim2.scale\
local HeaderTopLeft, HeaderCenter\
local function Content(_param)\
\9local header = _param.header\
\9local body = _param.body\
\9local footer = _param.footer\
\9local scaleFactor = useScale()\
\9local _attributes = {\
\9\9padding = {\
\9\9\9top = scaleFactor:map(function(s)\
\9\9\9\9return s * 48\
\9\9\9end),\
\9\9\9left = scaleFactor:map(function(s)\
\9\9\9\9return s * 48\
\9\9\9end),\
\9\9\9bottom = scaleFactor:map(function(s)\
\9\9\9\9return s * 48\
\9\9\9end),\
\9\9\9right = scaleFactor:map(function(s)\
\9\9\9\9return s * 48\
\9\9\9end),\
\9\9},\
\9}\
\9local _children = {\
\9\9body ~= nil and (Roact.createElement(HeaderTopLeft, {\
\9\9\9header = header,\
\9\9\9scaleFactor = scaleFactor,\
\9\9})) or (Roact.createElement(HeaderCenter, {\
\9\9\9header = header,\
\9\9\9scaleFactor = scaleFactor,\
\9\9})),\
\9}\
\9local _length = #_children\
\9local _child = body ~= nil and (Roact.createElement(\"TextLabel\", {\
\9\9Text = body,\
\9\9TextColor3 = hex(\"#FFFFFF\"),\
\9\9Font = \"GothamBlack\",\
\9\9TextSize = 36,\
\9\9TextXAlignment = \"Left\",\
\9\9TextYAlignment = \"Top\",\
\9\9Size = scale(1, 70 / 416),\
\9\9Position = scaleFactor:map(function(s)\
\9\9\9return px(0, 110 * s)\
\9\9end),\
\9\9BackgroundTransparency = 1,\
\9}, {\
\9\9Roact.createElement(\"UIScale\", {\
\9\9\9Scale = scaleFactor,\
\9\9}),\
\9}))\
\9if _child then\
\9\9if _child.elements ~= nil or _child.props ~= nil and _child.component ~= nil then\
\9\9\9_children[_length + 1] = _child\
\9\9else\
\9\9\9for _k, _v in ipairs(_child) do\
\9\9\9\9_children[_length + _k] = _v\
\9\9\9end\
\9\9end\
\9end\
\9_length = #_children\
\9_children[_length + 1] = Roact.createElement(\"TextLabel\", {\
\9\9Text = footer,\
\9\9TextColor3 = hex(\"#FFFFFF\"),\
\9\9Font = \"GothamBlack\",\
\9\9TextSize = 18,\
\9\9TextXAlignment = \"Center\",\
\9\9TextYAlignment = \"Bottom\",\
\9\9AnchorPoint = Vector2.new(0.5, 1),\
\9\9Size = scale(1, 20 / 416),\
\9\9Position = scale(0.5, 1),\
\9\9BackgroundTransparency = 1,\
\9}, {\
\9\9Roact.createElement(\"UIScale\", {\
\9\9\9Scale = scaleFactor,\
\9\9}),\
\9})\
\9return Roact.createElement(Canvas, _attributes, _children)\
end\
function HeaderTopLeft(props)\
\9return Roact.createElement(\"TextLabel\", {\
\9\9Text = props.header,\
\9\9TextColor3 = hex(\"#FFFFFF\"),\
\9\9Font = \"GothamBlack\",\
\9\9TextSize = 64,\
\9\9TextXAlignment = \"Left\",\
\9\9TextYAlignment = \"Top\",\
\9\9Size = scale(1, 70 / 416),\
\9\9BackgroundTransparency = 1,\
\9}, {\
\9\9Roact.createElement(\"UIScale\", {\
\9\9\9Scale = props.scaleFactor,\
\9\9}),\
\9})\
end\
function HeaderCenter(props)\
\9return Roact.createElement(\"TextLabel\", {\
\9\9Text = props.header,\
\9\9TextColor3 = hex(\"#FFFFFF\"),\
\9\9Font = \"GothamBlack\",\
\9\9TextSize = 48,\
\9\9TextXAlignment = \"Center\",\
\9\9TextYAlignment = \"Center\",\
\9\9AnchorPoint = Vector2.new(0.5, 0.5),\
\9\9Size = scale(1, 1),\
\9\9Position = scale(0.5, 0.5),\
\9\9BackgroundTransparency = 1,\
\9}, {\
\9\9Roact.createElement(\"UIScale\", {\
\9\9\9Scale = props.scaleFactor,\
\9\9}),\
\9})\
end\
local default = hooked(Content)\
return {\
\9default = default,\
}\
", '@'.."Orca.views.Pages.Scripts.Content")) setfenv(fn, newEnv("Orca.views.Pages.Scripts.Content")) return fn() end)

newModule("ScriptCard", "ModuleScript", "Orca.views.Pages.Scripts.ScriptCard", "Orca.views.Pages.Scripts", function () local fn = assert(loadstring("-- Compiled with roblox-ts v1.2.7\
local TS = require(script.Parent.Parent.Parent.Parent.include.RuntimeLib)\
local Roact = TS.import(script, TS.getModule(script, \"@rbxts\", \"roact\").src)\
local _roact_hooked = TS.import(script, TS.getModule(script, \"@rbxts\", \"roact-hooked\").out)\
local hooked = _roact_hooked.hooked\
local useEffect = _roact_hooked.useEffect\
local Border = TS.import(script, script.Parent.Parent.Parent.Parent, \"components\", \"Border\").default\
local Canvas = TS.import(script, script.Parent.Parent.Parent.Parent, \"components\", \"Canvas\").default\
local Fill = TS.import(script, script.Parent.Parent.Parent.Parent, \"components\", \"Fill\").default\
local ParallaxImage = TS.import(script, script.Parent.Parent.Parent.Parent, \"components\", \"ParallaxImage\").default\
local useDelayedUpdate = TS.import(script, script.Parent.Parent.Parent.Parent, \"hooks\", \"common\", \"use-delayed-update\").useDelayedUpdate\
local useIsMount = TS.import(script, script.Parent.Parent.Parent.Parent, \"hooks\", \"common\", \"use-did-mount\").useIsMount\
local useForcedUpdate = TS.import(script, script.Parent.Parent.Parent.Parent, \"hooks\", \"common\", \"use-forced-update\").useForcedUpdate\
local useSetState = TS.import(script, script.Parent.Parent.Parent.Parent, \"hooks\", \"common\", \"use-set-state\").default\
local useSpring = TS.import(script, script.Parent.Parent.Parent.Parent, \"hooks\", \"common\", \"use-spring\").useSpring\
local useIsPageOpen = TS.import(script, script.Parent.Parent.Parent.Parent, \"hooks\", \"use-current-page\").useIsPageOpen\
local useParallaxOffset = TS.import(script, script.Parent.Parent.Parent.Parent, \"hooks\", \"use-parallax-offset\").useParallaxOffset\
local DashboardPage = TS.import(script, script.Parent.Parent.Parent.Parent, \"store\", \"models\", \"dashboard.model\").DashboardPage\
local hex = TS.import(script, script.Parent.Parent.Parent.Parent, \"utils\", \"color3\").hex\
local scale = TS.import(script, script.Parent.Parent.Parent.Parent, \"utils\", \"udim2\").scale\
local shineSpringOptions = {\
\9dampingRatio = 3,\
\9frequency = 2,\
}\
local function ScriptCard(_param)\
\9local index = _param.index\
\9local backgroundImage = _param.backgroundImage\
\9local backgroundImageSize = _param.backgroundImageSize\
\9local dropshadow = _param.dropshadow\
\9local dropshadowSize = _param.dropshadowSize\
\9local dropshadowPosition = _param.dropshadowPosition\
\9local anchorPoint = _param.anchorPoint\
\9local size = _param.size\
\9local position = _param.position\
\9local onActivate = _param.onActivate\
\9local children = _param[Roact.Children]\
\9local rerender = useForcedUpdate()\
\9local isCurrentlyOpen = useIsPageOpen(DashboardPage.Scripts)\
\9local _result\
\9if useIsMount() then\
\9\9_result = false\
\9else\
\9\9_result = isCurrentlyOpen\
\9end\
\9local isOpen = _result\
\9local isTransitioning = useDelayedUpdate(isOpen, index * 30)\
\9useEffect(function()\
\9\9return rerender()\
\9end, {})\
\9local offset = useParallaxOffset()\
\9local _binding = useSetState({\
\9\9isHovered = false,\
\9\9isPressed = false,\
\9})\
\9local _binding_1 = _binding[1]\
\9local isHovered = _binding_1.isHovered\
\9local isPressed = _binding_1.isPressed\
\9local setButtonState = _binding[2]\
\9local _attributes = {\
\9\9anchor = anchorPoint,\
\9\9size = size,\
\9}\
\9local _result_1\
\9if isTransitioning then\
\9\9_result_1 = position\
\9else\
\9\9local _uDim2 = UDim2.new(0, 0, 1, 48 * 3 + 56)\
\9\9_result_1 = position + _uDim2\
\9end\
\9_attributes.position = useSpring(_result_1, {\
\9\9frequency = 2.2,\
\9\9dampingRatio = 0.75,\
\9})\
\9local _children = {}\
\9local _length = #_children\
\9local _attributes_1 = {\
\9\9anchor = Vector2.new(0.5, 0.5),\
\9\9size = useSpring(isHovered and not isPressed and UDim2.new(1, 48, 1, 48) or scale(1, 1), {\
\9\9\9frequency = 2,\
\9\9}),\
\9\9position = scale(0.5, 0.5),\
\9}\
\9local _children_1 = {\
\9\9Roact.createElement(\"ImageLabel\", {\
\9\9\9Image = dropshadow,\
\9\9\9AnchorPoint = Vector2.new(0.5, 0.5),\
\9\9\9Size = scale(dropshadowSize.X, dropshadowSize.Y),\
\9\9\9Position = scale(dropshadowPosition.X, dropshadowPosition.Y),\
\9\9\9BackgroundTransparency = 1,\
\9\9}),\
\9\9Roact.createElement(ParallaxImage, {\
\9\9\9image = backgroundImage,\
\9\9\9imageSize = backgroundImageSize,\
\9\9\9padding = Vector2.new(50, 50),\
\9\9\9offset = offset,\
\9\9}, {\
\9\9\9Roact.createElement(\"UICorner\", {\
\9\9\9\9CornerRadius = UDim.new(0, 16),\
\9\9\9}),\
\9\9}),\
\9}\
\9local _length_1 = #_children_1\
\9local _attributes_2 = {\
\9\9clipsDescendants = true,\
\9}\
\9local _children_2 = {}\
\9local _length_2 = #_children_2\
\9if children then\
\9\9for _k, _v in pairs(children) do\
\9\9\9if type(_k) == \"number\" then\
\9\9\9\9_children_2[_length_2 + _k] = _v\
\9\9\9else\
\9\9\9\9_children_2[_k] = _v\
\9\9\9end\
\9\9end\
\9end\
\9_children_1[_length_1 + 1] = Roact.createElement(Canvas, _attributes_2, _children_2)\
\9_children_1[_length_1 + 2] = Roact.createElement(Fill, {\
\9\9radius = 16,\
\9\9color = hex(\"#ffffff\"),\
\9\9transparency = useSpring(isHovered and 0 or 1, shineSpringOptions),\
\9}, {\
\9\9Roact.createElement(\"UIGradient\", {\
\9\9\9Transparency = NumberSequence.new(0.75, 1),\
\9\9\9Offset = useSpring(isHovered and Vector2.new(0, 0) or Vector2.new(-1, -1), shineSpringOptions),\
\9\9\9Rotation = 45,\
\9\9}),\
\9})\
\9_children_1[_length_1 + 3] = Roact.createElement(Border, {\
\9\9radius = 18,\
\9\9size = 3,\
\9\9color = hex(\"#ffffff\"),\
\9\9transparency = useSpring(isHovered and 0 or 1, shineSpringOptions),\
\9}, {\
\9\9Roact.createElement(\"UIGradient\", {\
\9\9\9Transparency = NumberSequence.new(0.7, 0.9),\
\9\9\9Offset = useSpring(isHovered and Vector2.new(0, 0) or Vector2.new(-1, -1), shineSpringOptions),\
\9\9\9Rotation = 45,\
\9\9}),\
\9})\
\9_children_1[_length_1 + 4] = Roact.createElement(Border, {\
\9\9color = hex(\"#ffffff\"),\
\9\9radius = 16,\
\9\9transparency = useSpring(isHovered and 1 or 0.8, {}),\
\9})\
\9_children[_length + 1] = Roact.createElement(Canvas, _attributes_1, _children_1)\
\9_children[_length + 2] = Roact.createElement(\"TextButton\", {\
\9\9[Roact.Event.Activated] = function()\
\9\9\9return onActivate()\
\9\9end,\
\9\9[Roact.Event.MouseEnter] = function()\
\9\9\9return setButtonState({\
\9\9\9\9isHovered = true,\
\9\9\9})\
\9\9end,\
\9\9[Roact.Event.MouseLeave] = function()\
\9\9\9return setButtonState({\
\9\9\9\9isHovered = false,\
\9\9\9\9isPressed = false,\
\9\9\9})\
\9\9end,\
\9\9[Roact.Event.MouseButton1Down] = function()\
\9\9\9return setButtonState({\
\9\9\9\9isPressed = true,\
\9\9\9})\
\9\9end,\
\9\9[Roact.Event.MouseButton1Up] = function()\
\9\9\9return setButtonState({\
\9\9\9\9isPressed = false,\
\9\9\9})\
\9\9end,\
\9\9Size = scale(1, 1),\
\9\9Text = \"\",\
\9\9Transparency = 1,\
\9})\
\9return Roact.createElement(Canvas, _attributes, _children)\
end\
local default = hooked(ScriptCard)\
return {\
\9default = default,\
}\
", '@'.."Orca.views.Pages.Scripts.ScriptCard")) setfenv(fn, newEnv("Orca.views.Pages.Scripts.ScriptCard")) return fn() end)

newModule("Scripts", "ModuleScript", "Orca.views.Pages.Scripts.Scripts", "Orca.views.Pages.Scripts", function () local fn = assert(loadstring("-- Compiled with roblox-ts v1.2.7\
local TS = require(script.Parent.Parent.Parent.Parent.include.RuntimeLib)\
local Roact = TS.import(script, TS.getModule(script, \"@rbxts\", \"roact\").src)\
local pure = TS.import(script, TS.getModule(script, \"@rbxts\", \"roact-hooked\").out).pure\
local Canvas = TS.import(script, script.Parent.Parent.Parent.Parent, \"components\", \"Canvas\").default\
local http = TS.import(script, script.Parent.Parent.Parent.Parent, \"utils\", \"http\")\
local scale = TS.import(script, script.Parent.Parent.Parent.Parent, \"utils\", \"udim2\").scale\
local _constants = TS.import(script, script.Parent, \"constants\")\
local BASE_PADDING = _constants.BASE_PADDING\
local BASE_WINDOW_HEIGHT = _constants.BASE_WINDOW_HEIGHT\
local Content = TS.import(script, script.Parent, \"Content\").default\
local ScriptCard = TS.import(script, script.Parent, \"ScriptCard\").default\
local runScriptFromUrl = TS.async(function(url, src)\
\9local _exitType, _returns = TS.try(function()\
\9\9local content = TS.await(http.get(url))\
\9\9local fn, err = loadstring(content, \"@\" .. src)\
\9\9local _arg1 = \"Failed to call loadstring on Lua script from '\" .. (url .. (\"': \" .. tostring(err)))\
\9\9assert(fn, _arg1)\
\9\9task.defer(fn)\
\9end, function(e)\
\9\9warn(\"Failed to run Lua script from '\" .. (url .. (\"': \" .. tostring(e))))\
\9\9return TS.TRY_RETURN, { \"\" }\
\9end)\
\9if _exitType then\
\9\9return unpack(_returns)\
\9end\
end)\
local function Scripts()\
\9return Roact.createElement(Canvas, {\
\9\9position = scale(0, 1),\
\9\9anchor = Vector2.new(0, 1),\
\9}, {\
\9\9Roact.createElement(ScriptCard, {\
\9\9\9onActivate = function()\
\9\9\9\9return runScriptFromUrl(\"https://solarishub.dev/script.lua\", \"Solaris\")\
\9\9\9end,\
\9\9\9index = 4,\
\9\9\9backgroundImage = \"rbxassetid://8992292705\",\
\9\9\9backgroundImageSize = Vector2.new(1023, 682),\
\9\9\9dropshadow = \"rbxassetid://8992292536\",\
\9\9\9dropshadowSize = Vector2.new(1.15, 1.25),\
\9\9\9dropshadowPosition = Vector2.new(0.5, 0.55),\
\9\9\9anchorPoint = Vector2.new(0, 0),\
\9\9\9size = UDim2.new(1 / 3, -BASE_PADDING * (2 / 3), (416 + BASE_PADDING / 2) / BASE_WINDOW_HEIGHT, -BASE_PADDING / 2),\
\9\9\9position = scale(0, 0),\
\9\9}, {\
\9\9\9Roact.createElement(Content, {\
\9\9\9\9header = \"Solaris\",\
\9\9\9\9body = \"A collection\\nof your favorite\\nscripts.\",\
\9\9\9\9footer = \"solarishub.dev\",\
\9\9\9}),\
\9\9}),\
\9\9Roact.createElement(ScriptCard, {\
\9\9\9onActivate = function()\
\9\9\9\9return runScriptFromUrl(\"https://raw.githubusercontent.com/1201for/V.G-Hub/main/V.Ghub\", \"V.G Hub\")\
\9\9\9end,\
\9\9\9index = 1,\
\9\9\9backgroundImage = \"rbxassetid://8992292381\",\
\9\9\9backgroundImageSize = Vector2.new(1021, 1023),\
\9\9\9dropshadow = \"rbxassetid://8992291993\",\
\9\9\9dropshadowSize = Vector2.new(1.15, 1.25),\
\9\9\9dropshadowPosition = Vector2.new(0.5, 0.55),\
\9\9\9anchorPoint = Vector2.new(0, 1),\
\9\9\9size = UDim2.new(1 / 3, -BASE_PADDING * (2 / 3), (416 + BASE_PADDING / 2) / BASE_WINDOW_HEIGHT, -BASE_PADDING / 2),\
\9\9\9position = scale(0, 1),\
\9\9}, {\
\9\9\9Roact.createElement(Content, {\
\9\9\9\9header = \"V.G Hub\",\
\9\9\9\9body = \"Featuring over\\n100 games.\",\
\9\9\9\9footer = \"github.com/1201for\",\
\9\9\9}),\
\9\9}),\
\9\9Roact.createElement(ScriptCard, {\
\9\9\9onActivate = function()\
\9\9\9\9return runScriptFromUrl(\"https://raw.githubusercontent.com/CMD-X/CMD-X/master/Source\", \"CMD-X\")\
\9\9\9end,\
\9\9\9index = 5,\
\9\9\9backgroundImage = \"rbxassetid://8992291779\",\
\9\9\9backgroundImageSize = Vector2.new(818, 1023),\
\9\9\9dropshadow = \"rbxassetid://8992291581\",\
\9\9\9dropshadowSize = Vector2.new(1.15, 1.4),\
\9\9\9dropshadowPosition = Vector2.new(0.5, 0.6),\
\9\9\9anchorPoint = Vector2.new(0.5, 0),\
\9\9\9size = UDim2.new(1 / 3, -BASE_PADDING * (2 / 3), (242 + BASE_PADDING / 2) / BASE_WINDOW_HEIGHT, -BASE_PADDING / 2),\
\9\9\9position = scale(0.5, 0),\
\9\9}, {\
\9\9\9Roact.createElement(Content, {\
\9\9\9\9header = \"CMD-X\",\
\9\9\9\9footer = \"github.com/CMD-X\",\
\9\9\9}),\
\9\9}),\
\9\9Roact.createElement(ScriptCard, {\
\9\9\9onActivate = function()\
\9\9\9\9return runScriptFromUrl(\"https://raw.githubusercontent.com/EdgeIY/infiniteyield/master/source\", \"Infinite Yield\")\
\9\9\9end,\
\9\9\9index = 3,\
\9\9\9backgroundImage = \"rbxassetid://8992291444\",\
\9\9\9backgroundImageSize = Vector2.new(1023, 682),\
\9\9\9dropshadow = \"rbxassetid://8992291268\",\
\9\9\9dropshadowSize = Vector2.new(1.15, 1.4),\
\9\9\9dropshadowPosition = Vector2.new(0.5, 0.6),\
\9\9\9anchorPoint = Vector2.new(0.5, 0),\
\9\9\9size = UDim2.new(1 / 3, -BASE_PADDING * (2 / 3), (242 + BASE_PADDING) / BASE_WINDOW_HEIGHT, -BASE_PADDING),\
\9\9\9position = UDim2.new(0.5, 0, 1 - (590 + BASE_PADDING / 2) / BASE_WINDOW_HEIGHT, BASE_PADDING / 2),\
\9\9}, {\
\9\9\9Roact.createElement(Content, {\
\9\9\9\9header = \"Infinite Yield\",\
\9\9\9\9footer = \"github.com/EdgeIY\",\
\9\9\9}),\
\9\9}),\
\9\9Roact.createElement(ScriptCard, {\
\9\9\9onActivate = function()\
\9\9\9\9return runScriptFromUrl(\"https://pastebin.com/raw/mMbsHWiQ\", \"Dex Explorer\")\
\9\9\9end,\
\9\9\9index = 1,\
\9\9\9backgroundImage = \"rbxassetid://8992290931\",\
\9\9\9backgroundImageSize = Vector2.new(818, 1023),\
\9\9\9dropshadow = \"rbxassetid://8992291101\",\
\9\9\9dropshadowSize = Vector2.new(1.15, 1.35),\
\9\9\9dropshadowPosition = Vector2.new(0.5, 0.55),\
\9\9\9anchorPoint = Vector2.new(0.5, 1),\
\9\9\9size = UDim2.new(1 / 3, -BASE_PADDING * (2 / 3), (300 + BASE_PADDING / 2) / BASE_WINDOW_HEIGHT, -BASE_PADDING / 2),\
\9\9\9position = scale(0.5, 1),\
\9\9}, {\
\9\9\9Roact.createElement(Content, {\
\9\9\9\9header = \"Dex Explorer\",\
\9\9\9\9footer = \"github.com/LorekeeperZinnia\",\
\9\9\9}),\
\9\9}),\
\9\9Roact.createElement(ScriptCard, {\
\9\9\9onActivate = function()\
\9\9\9\9return runScriptFromUrl(\"https://raw.githubusercontent.com/ic3w0lf22/Unnamed-ESP/master/UnnamedESP.lua\", \"Unnamed ESP\")\
\9\9\9end,\
\9\9\9index = 6,\
\9\9\9backgroundImage = \"rbxassetid://8992290714\",\
\9\9\9backgroundImageSize = Vector2.new(1023, 682),\
\9\9\9dropshadow = \"rbxassetid://8992290570\",\
\9\9\9dropshadowSize = Vector2.new(1.15, 1.35),\
\9\9\9dropshadowPosition = Vector2.new(0.5, 0.55),\
\9\9\9anchorPoint = Vector2.new(1, 0),\
\9\9\9size = UDim2.new(1 / 3, -BASE_PADDING * (2 / 3), (300 + BASE_PADDING / 2) / BASE_WINDOW_HEIGHT, -BASE_PADDING / 2),\
\9\9\9position = scale(1, 0),\
\9\9}, {\
\9\9\9Roact.createElement(Content, {\
\9\9\9\9header = \"Unnamed ESP\",\
\9\9\9\9footer = \"github.com/ic3w0lf22\",\
\9\9\9}),\
\9\9}),\
\9\9Roact.createElement(ScriptCard, {\
\9\9\9onActivate = function()\
\9\9\9\9return runScriptFromUrl(\"https://projectevo.xyz/script/loader.lua\", \"EvoV2\")\
\9\9\9end,\
\9\9\9index = 2,\
\9\9\9backgroundImage = \"rbxassetid://8992290314\",\
\9\9\9backgroundImageSize = Vector2.new(682, 1023),\
\9\9\9dropshadow = \"rbxassetid://8992290105\",\
\9\9\9dropshadowSize = Vector2.new(1.15, 1.22),\
\9\9\9dropshadowPosition = Vector2.new(0.5, 0.53),\
\9\9\9anchorPoint = Vector2.new(1, 1),\
\9\9\9size = UDim2.new(1 / 3, -BASE_PADDING * (2 / 3), (532 + BASE_PADDING / 2) / BASE_WINDOW_HEIGHT, -BASE_PADDING / 2),\
\9\9\9position = scale(1, 1),\
\9\9}, {\
\9\9\9Roact.createElement(Content, {\
\9\9\9\9header = \"EvoV2\",\
\9\9\9\9body = \"Reliable cheats for\\nRoblox's top shooter\\ngames, reimagined.\",\
\9\9\9\9footer = \"projectevo.xyz\",\
\9\9\9}),\
\9\9}),\
\9})\
end\
local default = pure(Scripts)\
return {\
\9default = default,\
}\
", '@'.."Orca.views.Pages.Scripts.Scripts")) setfenv(fn, newEnv("Orca.views.Pages.Scripts.Scripts")) return fn() end)

newModule("constants", "ModuleScript", "Orca.views.Pages.Scripts.constants", "Orca.views.Pages.Scripts", function () local fn = assert(loadstring("-- Compiled with roblox-ts v1.2.7\
local BASE_WINDOW_HEIGHT = 880\
local BASE_WINDOW_WIDTH = 1824\
local BASE_PADDING = 48\
return {\
\9BASE_WINDOW_HEIGHT = BASE_WINDOW_HEIGHT,\
\9BASE_WINDOW_WIDTH = BASE_WINDOW_WIDTH,\
\9BASE_PADDING = BASE_PADDING,\
}\
", '@'.."Orca.views.Pages.Scripts.constants")) setfenv(fn, newEnv("Orca.views.Pages.Scripts.constants")) return fn() end)

newInstance("include", "Folder", "Orca.include", "Orca")

newModule("Promise", "ModuleScript", "Orca.include.Promise", "Orca.include", function () local fn = assert(loadstring("--[[\
\9An implementation of Promises similar to Promise/A+.\
]]\
\
local ERROR_NON_PROMISE_IN_LIST = \"Non-promise value passed into %s at index %s\"\
local ERROR_NON_LIST = \"Please pass a list of promises to %s\"\
local ERROR_NON_FUNCTION = \"Please pass a handler function to %s!\"\
local MODE_KEY_METATABLE = {__mode = \"k\"}\
\
--[[\
\9Creates an enum dictionary with some metamethods to prevent common mistakes.\
]]\
local function makeEnum(enumName, members)\
\9local enum = {}\
\
\9for _, memberName in ipairs(members) do\
\9\9enum[memberName] = memberName\
\9end\
\
\9return setmetatable(enum, {\
\9\9__index = function(_, k)\
\9\9\9error(string.format(\"%s is not in %s!\", k, enumName), 2)\
\9\9end,\
\9\9__newindex = function()\
\9\9\9error(string.format(\"Creating new members in %s is not allowed!\", enumName), 2)\
\9\9end,\
\9})\
end\
\
--[[\
\9An object to represent runtime errors that occur during execution.\
\9Promises that experience an error like this will be rejected with\
\9an instance of this object.\
]]\
local Error do\
\9Error = {\
\9\9Kind = makeEnum(\"Promise.Error.Kind\", {\
\9\9\9\"ExecutionError\",\
\9\9\9\"AlreadyCancelled\",\
\9\9\9\"NotResolvedInTime\",\
\9\9\9\"TimedOut\",\
\9\9}),\
\9}\
\9Error.__index = Error\
\
\9function Error.new(options, parent)\
\9\9options = options or {}\
\9\9return setmetatable({\
\9\9\9error = tostring(options.error) or \"[This error has no error text.]\",\
\9\9\9trace = options.trace,\
\9\9\9context = options.context,\
\9\9\9kind = options.kind,\
\9\9\9parent = parent,\
\9\9\9createdTick = os.clock(),\
\9\9\9createdTrace = debug.traceback(),\
\9\9}, Error)\
\9end\
\
\9function Error.is(anything)\
\9\9if type(anything) == \"table\" then\
\9\9\9local metatable = getmetatable(anything)\
\
\9\9\9if type(metatable) == \"table\" then\
\9\9\9\9return rawget(anything, \"error\") ~= nil and type(rawget(metatable, \"extend\")) == \"function\"\
\9\9\9end\
\9\9end\
\
\9\9return false\
\9end\
\
\9function Error.isKind(anything, kind)\
\9\9assert(kind ~= nil, \"Argument #2 to Promise.Error.isKind must not be nil\")\
\
\9\9return Error.is(anything) and anything.kind == kind\
\9end\
\
\9function Error:extend(options)\
\9\9options = options or {}\
\
\9\9options.kind = options.kind or self.kind\
\
\9\9return Error.new(options, self)\
\9end\
\
\9function Error:getErrorChain()\
\9\9local runtimeErrors = { self }\
\
\9\9while runtimeErrors[#runtimeErrors].parent do\
\9\9\9table.insert(runtimeErrors, runtimeErrors[#runtimeErrors].parent)\
\9\9end\
\
\9\9return runtimeErrors\
\9end\
\
\9function Error:__tostring()\
\9\9local errorStrings = {\
\9\9\9string.format(\"-- Promise.Error(%s) --\", self.kind or \"?\"),\
\9\9}\
\
\9\9for _, runtimeError in ipairs(self:getErrorChain()) do\
\9\9\9table.insert(errorStrings, table.concat({\
\9\9\9\9runtimeError.trace or runtimeError.error,\
\9\9\9\9runtimeError.context,\
\9\9\9}, \"\\n\"))\
\9\9end\
\
\9\9return table.concat(errorStrings, \"\\n\")\
\9end\
end\
\
--[[\
\9Packs a number of arguments into a table and returns its length.\
\
\9Used to cajole varargs without dropping sparse values.\
]]\
local function pack(...)\
\9return select(\"#\", ...), { ... }\
end\
\
--[[\
\9Returns first value (success), and packs all following values.\
]]\
local function packResult(success, ...)\
\9return success, select(\"#\", ...), { ... }\
end\
\
\
local function makeErrorHandler(traceback)\
\9assert(traceback ~= nil)\
\
\9return function(err)\
\9\9-- If the error object is already a table, forward it directly.\
\9\9-- Should we extend the error here and add our own trace?\
\
\9\9if type(err) == \"table\" then\
\9\9\9return err\
\9\9end\
\
\9\9return Error.new({\
\9\9\9error = err,\
\9\9\9kind = Error.Kind.ExecutionError,\
\9\9\9trace = debug.traceback(tostring(err), 2),\
\9\9\9context = \"Promise created at:\\n\\n\" .. traceback,\
\9\9})\
\9end\
end\
\
--[[\
\9Calls a Promise executor with error handling.\
]]\
local function runExecutor(traceback, callback, ...)\
\9return packResult(xpcall(callback, makeErrorHandler(traceback), ...))\
end\
\
--[[\
\9Creates a function that invokes a callback with correct error handling and\
\9resolution mechanisms.\
]]\
local function createAdvancer(traceback, callback, resolve, reject)\
\9return function(...)\
\9\9local ok, resultLength, result = runExecutor(traceback, callback, ...)\
\
\9\9if ok then\
\9\9\9resolve(unpack(result, 1, resultLength))\
\9\9else\
\9\9\9reject(result[1])\
\9\9end\
\9end\
end\
\
local function isEmpty(t)\
\9return next(t) == nil\
end\
\
local Promise = {\
\9Error = Error,\
\9Status = makeEnum(\"Promise.Status\", {\"Started\", \"Resolved\", \"Rejected\", \"Cancelled\"}),\
\9_getTime = os.clock,\
\9_timeEvent = game:GetService(\"RunService\").Heartbeat,\
}\
Promise.prototype = {}\
Promise.__index = Promise.prototype\
\
--[[\
\9Constructs a new Promise with the given initializing callback.\
\
\9This is generally only called when directly wrapping a non-promise API into\
\9a promise-based version.\
\
\9The callback will receive 'resolve' and 'reject' methods, used to start\
\9invoking the promise chain.\
\
\9Second parameter, parent, is used internally for tracking the \"parent\" in a\
\9promise chain. External code shouldn't need to worry about this.\
]]\
function Promise._new(traceback, callback, parent)\
\9if parent ~= nil and not Promise.is(parent) then\
\9\9error(\"Argument #2 to Promise.new must be a promise or nil\", 2)\
\9end\
\
\9local self = {\
\9\9-- Used to locate where a promise was created\
\9\9_source = traceback,\
\
\9\9_status = Promise.Status.Started,\
\
\9\9-- A table containing a list of all results, whether success or failure.\
\9\9-- Only valid if _status is set to something besides Started\
\9\9_values = nil,\
\
\9\9-- Lua doesn't like sparse arrays very much, so we explicitly store the\
\9\9-- length of _values to handle middle nils.\
\9\9_valuesLength = -1,\
\
\9\9-- Tracks if this Promise has no error observers..\
\9\9_unhandledRejection = true,\
\
\9\9-- Queues representing functions we should invoke when we update!\
\9\9_queuedResolve = {},\
\9\9_queuedReject = {},\
\9\9_queuedFinally = {},\
\
\9\9-- The function to run when/if this promise is cancelled.\
\9\9_cancellationHook = nil,\
\
\9\9-- The \"parent\" of this promise in a promise chain. Required for\
\9\9-- cancellation propagation upstream.\
\9\9_parent = parent,\
\
\9\9-- Consumers are Promises that have chained onto this one.\
\9\9-- We track them for cancellation propagation downstream.\
\9\9_consumers = setmetatable({}, MODE_KEY_METATABLE),\
\9}\
\
\9if parent and parent._status == Promise.Status.Started then\
\9\9parent._consumers[self] = true\
\9end\
\
\9setmetatable(self, Promise)\
\
\9local function resolve(...)\
\9\9self:_resolve(...)\
\9end\
\
\9local function reject(...)\
\9\9self:_reject(...)\
\9end\
\
\9local function onCancel(cancellationHook)\
\9\9if cancellationHook then\
\9\9\9if self._status == Promise.Status.Cancelled then\
\9\9\9\9cancellationHook()\
\9\9\9else\
\9\9\9\9self._cancellationHook = cancellationHook\
\9\9\9end\
\9\9end\
\
\9\9return self._status == Promise.Status.Cancelled\
\9end\
\
\9coroutine.wrap(function()\
\9\9local ok, _, result = runExecutor(\
\9\9\9self._source,\
\9\9\9callback,\
\9\9\9resolve,\
\9\9\9reject,\
\9\9\9onCancel\
\9\9)\
\
\9\9if not ok then\
\9\9\9reject(result[1])\
\9\9end\
\9end)()\
\
\9return self\
end\
\
function Promise.new(executor)\
\9return Promise._new(debug.traceback(nil, 2), executor)\
end\
\
function Promise:__tostring()\
\9return string.format(\"Promise(%s)\", self:getStatus())\
end\
\
--[[\
\9Promise.new, except pcall on a new thread is automatic.\
]]\
function Promise.defer(callback)\
\9local traceback = debug.traceback(nil, 2)\
\9local promise\
\9promise = Promise._new(traceback, function(resolve, reject, onCancel)\
\9\9local connection\
\9\9connection = Promise._timeEvent:Connect(function()\
\9\9\9connection:Disconnect()\
\9\9\9local ok, _, result = runExecutor(traceback, callback, resolve, reject, onCancel)\
\
\9\9\9if not ok then\
\9\9\9\9reject(result[1])\
\9\9\9end\
\9\9end)\
\9end)\
\
\9return promise\
end\
\
-- Backwards compatibility\
Promise.async = Promise.defer\
\
--[[\
\9Create a promise that represents the immediately resolved value.\
]]\
function Promise.resolve(...)\
\9local length, values = pack(...)\
\9return Promise._new(debug.traceback(nil, 2), function(resolve)\
\9\9resolve(unpack(values, 1, length))\
\9end)\
end\
\
--[[\
\9Create a promise that represents the immediately rejected value.\
]]\
function Promise.reject(...)\
\9local length, values = pack(...)\
\9return Promise._new(debug.traceback(nil, 2), function(_, reject)\
\9\9reject(unpack(values, 1, length))\
\9end)\
end\
\
--[[\
\9Runs a non-promise-returning function as a Promise with the\
  given arguments.\
]]\
function Promise._try(traceback, callback, ...)\
\9local valuesLength, values = pack(...)\
\
\9return Promise._new(traceback, function(resolve)\
\9\9resolve(callback(unpack(values, 1, valuesLength)))\
\9end)\
end\
\
--[[\
\9Begins a Promise chain, turning synchronous errors into rejections.\
]]\
function Promise.try(...)\
\9return Promise._try(debug.traceback(nil, 2), ...)\
end\
\
--[[\
\9Returns a new promise that:\
\9\9* is resolved when all input promises resolve\
\9\9* is rejected if ANY input promises reject\
]]\
function Promise._all(traceback, promises, amount)\
\9if type(promises) ~= \"table\" then\
\9\9error(string.format(ERROR_NON_LIST, \"Promise.all\"), 3)\
\9end\
\
\9-- We need to check that each value is a promise here so that we can produce\
\9-- a proper error rather than a rejected promise with our error.\
\9for i, promise in pairs(promises) do\
\9\9if not Promise.is(promise) then\
\9\9\9error(string.format(ERROR_NON_PROMISE_IN_LIST, \"Promise.all\", tostring(i)), 3)\
\9\9end\
\9end\
\
\9-- If there are no values then return an already resolved promise.\
\9if #promises == 0 or amount == 0 then\
\9\9return Promise.resolve({})\
\9end\
\
\9return Promise._new(traceback, function(resolve, reject, onCancel)\
\9\9-- An array to contain our resolved values from the given promises.\
\9\9local resolvedValues = {}\
\9\9local newPromises = {}\
\
\9\9-- Keep a count of resolved promises because just checking the resolved\
\9\9-- values length wouldn't account for promises that resolve with nil.\
\9\9local resolvedCount = 0\
\9\9local rejectedCount = 0\
\9\9local done = false\
\
\9\9local function cancel()\
\9\9\9for _, promise in ipairs(newPromises) do\
\9\9\9\9promise:cancel()\
\9\9\9end\
\9\9end\
\
\9\9-- Called when a single value is resolved and resolves if all are done.\
\9\9local function resolveOne(i, ...)\
\9\9\9if done then\
\9\9\9\9return\
\9\9\9end\
\
\9\9\9resolvedCount = resolvedCount + 1\
\
\9\9\9if amount == nil then\
\9\9\9\9resolvedValues[i] = ...\
\9\9\9else\
\9\9\9\9resolvedValues[resolvedCount] = ...\
\9\9\9end\
\
\9\9\9if resolvedCount >= (amount or #promises) then\
\9\9\9\9done = true\
\9\9\9\9resolve(resolvedValues)\
\9\9\9\9cancel()\
\9\9\9end\
\9\9end\
\
\9\9onCancel(cancel)\
\
\9\9-- We can assume the values inside `promises` are all promises since we\
\9\9-- checked above.\
\9\9for i, promise in ipairs(promises) do\
\9\9\9newPromises[i] = promise:andThen(\
\9\9\9\9function(...)\
\9\9\9\9\9resolveOne(i, ...)\
\9\9\9\9end,\
\9\9\9\9function(...)\
\9\9\9\9\9rejectedCount = rejectedCount + 1\
\
\9\9\9\9\9if amount == nil or #promises - rejectedCount < amount then\
\9\9\9\9\9\9cancel()\
\9\9\9\9\9\9done = true\
\
\9\9\9\9\9\9reject(...)\
\9\9\9\9\9end\
\9\9\9\9end\
\9\9\9)\
\9\9end\
\
\9\9if done then\
\9\9\9cancel()\
\9\9end\
\9end)\
end\
\
function Promise.all(promises)\
\9return Promise._all(debug.traceback(nil, 2), promises)\
end\
\
function Promise.fold(list, callback, initialValue)\
\9assert(type(list) == \"table\", \"Bad argument #1 to Promise.fold: must be a table\")\
\9assert(type(callback) == \"function\", \"Bad argument #2 to Promise.fold: must be a function\")\
\
\9local accumulator = Promise.resolve(initialValue)\
\9return Promise.each(list, function(resolvedElement, i)\
\9\9accumulator = accumulator:andThen(function(previousValueResolved)\
\9\9\9return callback(previousValueResolved, resolvedElement, i)\
\9\9end)\
\9end):andThenReturn(accumulator)\
end\
\
function Promise.some(promises, amount)\
\9assert(type(amount) == \"number\", \"Bad argument #2 to Promise.some: must be a number\")\
\
\9return Promise._all(debug.traceback(nil, 2), promises, amount)\
end\
\
function Promise.any(promises)\
\9return Promise._all(debug.traceback(nil, 2), promises, 1):andThen(function(values)\
\9\9return values[1]\
\9end)\
end\
\
function Promise.allSettled(promises)\
\9if type(promises) ~= \"table\" then\
\9\9error(string.format(ERROR_NON_LIST, \"Promise.allSettled\"), 2)\
\9end\
\
\9-- We need to check that each value is a promise here so that we can produce\
\9-- a proper error rather than a rejected promise with our error.\
\9for i, promise in pairs(promises) do\
\9\9if not Promise.is(promise) then\
\9\9\9error(string.format(ERROR_NON_PROMISE_IN_LIST, \"Promise.allSettled\", tostring(i)), 2)\
\9\9end\
\9end\
\
\9-- If there are no values then return an already resolved promise.\
\9if #promises == 0 then\
\9\9return Promise.resolve({})\
\9end\
\
\9return Promise._new(debug.traceback(nil, 2), function(resolve, _, onCancel)\
\9\9-- An array to contain our resolved values from the given promises.\
\9\9local fates = {}\
\9\9local newPromises = {}\
\
\9\9-- Keep a count of resolved promises because just checking the resolved\
\9\9-- values length wouldn't account for promises that resolve with nil.\
\9\9local finishedCount = 0\
\
\9\9-- Called when a single value is resolved and resolves if all are done.\
\9\9local function resolveOne(i, ...)\
\9\9\9finishedCount = finishedCount + 1\
\
\9\9\9fates[i] = ...\
\
\9\9\9if finishedCount >= #promises then\
\9\9\9\9resolve(fates)\
\9\9\9end\
\9\9end\
\
\9\9onCancel(function()\
\9\9\9for _, promise in ipairs(newPromises) do\
\9\9\9\9promise:cancel()\
\9\9\9end\
\9\9end)\
\
\9\9-- We can assume the values inside `promises` are all promises since we\
\9\9-- checked above.\
\9\9for i, promise in ipairs(promises) do\
\9\9\9newPromises[i] = promise:finally(\
\9\9\9\9function(...)\
\9\9\9\9\9resolveOne(i, ...)\
\9\9\9\9end\
\9\9\9)\
\9\9end\
\9end)\
end\
\
--[[\
\9Races a set of Promises and returns the first one that resolves,\
\9cancelling the others.\
]]\
function Promise.race(promises)\
\9assert(type(promises) == \"table\", string.format(ERROR_NON_LIST, \"Promise.race\"))\
\
\9for i, promise in pairs(promises) do\
\9\9assert(Promise.is(promise), string.format(ERROR_NON_PROMISE_IN_LIST, \"Promise.race\", tostring(i)))\
\9end\
\
\9return Promise._new(debug.traceback(nil, 2), function(resolve, reject, onCancel)\
\9\9local newPromises = {}\
\9\9local finished = false\
\
\9\9local function cancel()\
\9\9\9for _, promise in ipairs(newPromises) do\
\9\9\9\9promise:cancel()\
\9\9\9end\
\9\9end\
\
\9\9local function finalize(callback)\
\9\9\9return function (...)\
\9\9\9\9cancel()\
\9\9\9\9finished = true\
\9\9\9\9return callback(...)\
\9\9\9end\
\9\9end\
\
\9\9if onCancel(finalize(reject)) then\
\9\9\9return\
\9\9end\
\
\9\9for i, promise in ipairs(promises) do\
\9\9\9newPromises[i] = promise:andThen(finalize(resolve), finalize(reject))\
\9\9end\
\
\9\9if finished then\
\9\9\9cancel()\
\9\9end\
\9end)\
end\
\
--[[\
\9Iterates serially over the given an array of values, calling the predicate callback on each before continuing.\
\9If the predicate returns a Promise, we wait for that Promise to resolve before continuing to the next item\
\9in the array. If the Promise the predicate returns rejects, the Promise from Promise.each is also rejected with\
\9the same value.\
\
\9Returns a Promise containing an array of the return values from the predicate for each item in the original list.\
]]\
function Promise.each(list, predicate)\
\9assert(type(list) == \"table\", string.format(ERROR_NON_LIST, \"Promise.each\"))\
\9assert(type(predicate) == \"function\", string.format(ERROR_NON_FUNCTION, \"Promise.each\"))\
\
\9return Promise._new(debug.traceback(nil, 2), function(resolve, reject, onCancel)\
\9\9local results = {}\
\9\9local promisesToCancel = {}\
\
\9\9local cancelled = false\
\
\9\9local function cancel()\
\9\9\9for _, promiseToCancel in ipairs(promisesToCancel) do\
\9\9\9\9promiseToCancel:cancel()\
\9\9\9end\
\9\9end\
\
\9\9onCancel(function()\
\9\9\9cancelled = true\
\
\9\9\9cancel()\
\9\9end)\
\
\9\9-- We need to preprocess the list of values and look for Promises.\
\9\9-- If we find some, we must register our andThen calls now, so that those Promises have a consumer\
\9\9-- from us registered. If we don't do this, those Promises might get cancelled by something else\
\9\9-- before we get to them in the series because it's not possible to tell that we plan to use it\
\9\9-- unless we indicate it here.\
\
\9\9local preprocessedList = {}\
\
\9\9for index, value in ipairs(list) do\
\9\9\9if Promise.is(value) then\
\9\9\9\9if value:getStatus() == Promise.Status.Cancelled then\
\9\9\9\9\9cancel()\
\9\9\9\9\9return reject(Error.new({\
\9\9\9\9\9\9error = \"Promise is cancelled\",\
\9\9\9\9\9\9kind = Error.Kind.AlreadyCancelled,\
\9\9\9\9\9\9context = string.format(\
\9\9\9\9\9\9\9\"The Promise that was part of the array at index %d passed into Promise.each was already cancelled when Promise.each began.\\n\\nThat Promise was created at:\\n\\n%s\",\
\9\9\9\9\9\9\9index,\
\9\9\9\9\9\9\9value._source\
\9\9\9\9\9\9),\
\9\9\9\9\9}))\
\9\9\9\9elseif value:getStatus() == Promise.Status.Rejected then\
\9\9\9\9\9cancel()\
\9\9\9\9\9return reject(select(2, value:await()))\
\9\9\9\9end\
\
\9\9\9\9-- Chain a new Promise from this one so we only cancel ours\
\9\9\9\9local ourPromise = value:andThen(function(...)\
\9\9\9\9\9return ...\
\9\9\9\9end)\
\
\9\9\9\9table.insert(promisesToCancel, ourPromise)\
\9\9\9\9preprocessedList[index] = ourPromise\
\9\9\9else\
\9\9\9\9preprocessedList[index] = value\
\9\9\9end\
\9\9end\
\
\9\9for index, value in ipairs(preprocessedList) do\
\9\9\9if Promise.is(value) then\
\9\9\9\9local success\
\9\9\9\9success, value = value:await()\
\
\9\9\9\9if not success then\
\9\9\9\9\9cancel()\
\9\9\9\9\9return reject(value)\
\9\9\9\9end\
\9\9\9end\
\
\9\9\9if cancelled then\
\9\9\9\9return\
\9\9\9end\
\
\9\9\9local predicatePromise = Promise.resolve(predicate(value, index))\
\
\9\9\9table.insert(promisesToCancel, predicatePromise)\
\
\9\9\9local success, result = predicatePromise:await()\
\
\9\9\9if not success then\
\9\9\9\9cancel()\
\9\9\9\9return reject(result)\
\9\9\9end\
\
\9\9\9results[index] = result\
\9\9end\
\
\9\9resolve(results)\
\9end)\
end\
\
--[[\
\9Is the given object a Promise instance?\
]]\
function Promise.is(object)\
\9if type(object) ~= \"table\" then\
\9\9return false\
\9end\
\
\9local objectMetatable = getmetatable(object)\
\
\9if objectMetatable == Promise then\
\9\9-- The Promise came from this library.\
\9\9return true\
\9elseif objectMetatable == nil then\
\9\9-- No metatable, but we should still chain onto tables with andThen methods\
\9\9return type(object.andThen) == \"function\"\
\9elseif\
\9\9type(objectMetatable) == \"table\"\
\9\9and type(rawget(objectMetatable, \"__index\")) == \"table\"\
\9\9and type(rawget(rawget(objectMetatable, \"__index\"), \"andThen\")) == \"function\"\
\9then\
\9\9-- Maybe this came from a different or older Promise library.\
\9\9return true\
\9end\
\
\9return false\
end\
\
--[[\
\9Converts a yielding function into a Promise-returning one.\
]]\
function Promise.promisify(callback)\
\9return function(...)\
\9\9return Promise._try(debug.traceback(nil, 2), callback, ...)\
\9end\
end\
\
--[[\
\9Creates a Promise that resolves after given number of seconds.\
]]\
do\
\9-- uses a sorted doubly linked list (queue) to achieve O(1) remove operations and O(n) for insert\
\
\9-- the initial node in the linked list\
\9local first\
\9local connection\
\
\9function Promise.delay(seconds)\
\9\9assert(type(seconds) == \"number\", \"Bad argument #1 to Promise.delay, must be a number.\")\
\9\9-- If seconds is -INF, INF, NaN, or less than 1 / 60, assume seconds is 1 / 60.\
\9\9-- This mirrors the behavior of wait()\
\9\9if not (seconds >= 1 / 60) or seconds == math.huge then\
\9\9\9seconds = 1 / 60\
\9\9end\
\
\9\9return Promise._new(debug.traceback(nil, 2), function(resolve, _, onCancel)\
\9\9\9local startTime = Promise._getTime()\
\9\9\9local endTime = startTime + seconds\
\
\9\9\9local node = {\
\9\9\9\9resolve = resolve,\
\9\9\9\9startTime = startTime,\
\9\9\9\9endTime = endTime,\
\9\9\9}\
\
\9\9\9if connection == nil then -- first is nil when connection is nil\
\9\9\9\9first = node\
\9\9\9\9connection = Promise._timeEvent:Connect(function()\
\9\9\9\9\9local threadStart = Promise._getTime()\
\
\9\9\9\9\9while first ~= nil and first.endTime < threadStart do\
\9\9\9\9\9\9local current = first\
\9\9\9\9\9\9first = current.next\
\
\9\9\9\9\9\9if first == nil then\
\9\9\9\9\9\9\9connection:Disconnect()\
\9\9\9\9\9\9\9connection = nil\
\9\9\9\9\9\9else\
\9\9\9\9\9\9\9first.previous = nil\
\9\9\9\9\9\9end\
\
\9\9\9\9\9\9current.resolve(Promise._getTime() - current.startTime)\
\9\9\9\9\9end\
\9\9\9\9end)\
\9\9\9else -- first is non-nil\
\9\9\9\9if first.endTime < endTime then -- if `node` should be placed after `first`\
\9\9\9\9\9-- we will insert `node` between `current` and `next`\
\9\9\9\9\9-- (i.e. after `current` if `next` is nil)\
\9\9\9\9\9local current = first\
\9\9\9\9\9local next = current.next\
\
\9\9\9\9\9while next ~= nil and next.endTime < endTime do\
\9\9\9\9\9\9current = next\
\9\9\9\9\9\9next = current.next\
\9\9\9\9\9end\
\
\9\9\9\9\9-- `current` must be non-nil, but `next` could be `nil` (i.e. last item in list)\
\9\9\9\9\9current.next = node\
\9\9\9\9\9node.previous = current\
\
\9\9\9\9\9if next ~= nil then\
\9\9\9\9\9\9node.next = next\
\9\9\9\9\9\9next.previous = node\
\9\9\9\9\9end\
\9\9\9\9else\
\9\9\9\9\9-- set `node` to `first`\
\9\9\9\9\9node.next = first\
\9\9\9\9\9first.previous = node\
\9\9\9\9\9first = node\
\9\9\9\9end\
\9\9\9end\
\
\9\9\9onCancel(function()\
\9\9\9\9-- remove node from queue\
\9\9\9\9local next = node.next\
\
\9\9\9\9if first == node then\
\9\9\9\9\9if next == nil then -- if `node` is the first and last\
\9\9\9\9\9\9connection:Disconnect()\
\9\9\9\9\9\9connection = nil\
\9\9\9\9\9else -- if `node` is `first` and not the last\
\9\9\9\9\9\9next.previous = nil\
\9\9\9\9\9end\
\9\9\9\9\9first = next\
\9\9\9\9else\
\9\9\9\9\9local previous = node.previous\
\9\9\9\9\9-- since `node` is not `first`, then we know `previous` is non-nil\
\9\9\9\9\9previous.next = next\
\
\9\9\9\9\9if next ~= nil then\
\9\9\9\9\9\9next.previous = previous\
\9\9\9\9\9end\
\9\9\9\9end\
\9\9\9end)\
\9\9end)\
\9end\
end\
\
--[[\
\9Rejects the promise after `seconds` seconds.\
]]\
function Promise.prototype:timeout(seconds, rejectionValue)\
\9local traceback = debug.traceback(nil, 2)\
\
\9return Promise.race({\
\9\9Promise.delay(seconds):andThen(function()\
\9\9\9return Promise.reject(rejectionValue == nil and Error.new({\
\9\9\9\9kind = Error.Kind.TimedOut,\
\9\9\9\9error = \"Timed out\",\
\9\9\9\9context = string.format(\
\9\9\9\9\9\"Timeout of %d seconds exceeded.\\n:timeout() called at:\\n\\n%s\",\
\9\9\9\9\9seconds,\
\9\9\9\9\9traceback\
\9\9\9\9),\
\9\9\9}) or rejectionValue)\
\9\9end),\
\9\9self,\
\9})\
end\
\
function Promise.prototype:getStatus()\
\9return self._status\
end\
\
--[[\
\9Creates a new promise that receives the result of this promise.\
\
\9The given callbacks are invoked depending on that result.\
]]\
function Promise.prototype:_andThen(traceback, successHandler, failureHandler)\
\9self._unhandledRejection = false\
\
\9-- Create a new promise to follow this part of the chain\
\9return Promise._new(traceback, function(resolve, reject)\
\9\9-- Our default callbacks just pass values onto the next promise.\
\9\9-- This lets success and failure cascade correctly!\
\
\9\9local successCallback = resolve\
\9\9if successHandler then\
\9\9\9successCallback = createAdvancer(\
\9\9\9\9traceback,\
\9\9\9\9successHandler,\
\9\9\9\9resolve,\
\9\9\9\9reject\
\9\9\9)\
\9\9end\
\
\9\9local failureCallback = reject\
\9\9if failureHandler then\
\9\9\9failureCallback = createAdvancer(\
\9\9\9\9traceback,\
\9\9\9\9failureHandler,\
\9\9\9\9resolve,\
\9\9\9\9reject\
\9\9\9)\
\9\9end\
\
\9\9if self._status == Promise.Status.Started then\
\9\9\9-- If we haven't resolved yet, put ourselves into the queue\
\9\9\9table.insert(self._queuedResolve, successCallback)\
\9\9\9table.insert(self._queuedReject, failureCallback)\
\9\9elseif self._status == Promise.Status.Resolved then\
\9\9\9-- This promise has already resolved! Trigger success immediately.\
\9\9\9successCallback(unpack(self._values, 1, self._valuesLength))\
\9\9elseif self._status == Promise.Status.Rejected then\
\9\9\9-- This promise died a terrible death! Trigger failure immediately.\
\9\9\9failureCallback(unpack(self._values, 1, self._valuesLength))\
\9\9elseif self._status == Promise.Status.Cancelled then\
\9\9\9-- We don't want to call the success handler or the failure handler,\
\9\9\9-- we just reject this promise outright.\
\9\9\9reject(Error.new({\
\9\9\9\9error = \"Promise is cancelled\",\
\9\9\9\9kind = Error.Kind.AlreadyCancelled,\
\9\9\9\9context = \"Promise created at\\n\\n\" .. traceback,\
\9\9\9}))\
\9\9end\
\9end, self)\
end\
\
function Promise.prototype:andThen(successHandler, failureHandler)\
\9assert(\
\9\9successHandler == nil or type(successHandler) == \"function\",\
\9\9string.format(ERROR_NON_FUNCTION, \"Promise:andThen\")\
\9)\
\9assert(\
\9\9failureHandler == nil or type(failureHandler) == \"function\",\
\9\9string.format(ERROR_NON_FUNCTION, \"Promise:andThen\")\
\9)\
\
\9return self:_andThen(debug.traceback(nil, 2), successHandler, failureHandler)\
end\
\
--[[\
\9Used to catch any errors that may have occurred in the promise.\
]]\
function Promise.prototype:catch(failureCallback)\
\9assert(\
\9\9failureCallback == nil or type(failureCallback) == \"function\",\
\9\9string.format(ERROR_NON_FUNCTION, \"Promise:catch\")\
\9)\
\9return self:_andThen(debug.traceback(nil, 2), nil, failureCallback)\
end\
\
--[[\
\9Like andThen, but the value passed into the handler is also the\
\9value returned from the handler.\
]]\
function Promise.prototype:tap(tapCallback)\
\9assert(type(tapCallback) == \"function\", string.format(ERROR_NON_FUNCTION, \"Promise:tap\"))\
\9return self:_andThen(debug.traceback(nil, 2), function(...)\
\9\9local callbackReturn = tapCallback(...)\
\
\9\9if Promise.is(callbackReturn) then\
\9\9\9local length, values = pack(...)\
\9\9\9return callbackReturn:andThen(function()\
\9\9\9\9return unpack(values, 1, length)\
\9\9\9end)\
\9\9end\
\
\9\9return ...\
\9end)\
end\
\
--[[\
\9Calls a callback on `andThen` with specific arguments.\
]]\
function Promise.prototype:andThenCall(callback, ...)\
\9assert(type(callback) == \"function\", string.format(ERROR_NON_FUNCTION, \"Promise:andThenCall\"))\
\9local length, values = pack(...)\
\9return self:_andThen(debug.traceback(nil, 2), function()\
\9\9return callback(unpack(values, 1, length))\
\9end)\
end\
\
--[[\
\9Shorthand for an andThen handler that returns the given value.\
]]\
function Promise.prototype:andThenReturn(...)\
\9local length, values = pack(...)\
\9return self:_andThen(debug.traceback(nil, 2), function()\
\9\9return unpack(values, 1, length)\
\9end)\
end\
\
--[[\
\9Cancels the promise, disallowing it from rejecting or resolving, and calls\
\9the cancellation hook if provided.\
]]\
function Promise.prototype:cancel()\
\9if self._status ~= Promise.Status.Started then\
\9\9return\
\9end\
\
\9self._status = Promise.Status.Cancelled\
\
\9if self._cancellationHook then\
\9\9self._cancellationHook()\
\9end\
\
\9if self._parent then\
\9\9self._parent:_consumerCancelled(self)\
\9end\
\
\9for child in pairs(self._consumers) do\
\9\9child:cancel()\
\9end\
\
\9self:_finalize()\
end\
\
--[[\
\9Used to decrease the number of consumers by 1, and if there are no more,\
\9cancel this promise.\
]]\
function Promise.prototype:_consumerCancelled(consumer)\
\9if self._status ~= Promise.Status.Started then\
\9\9return\
\9end\
\
\9self._consumers[consumer] = nil\
\
\9if next(self._consumers) == nil then\
\9\9self:cancel()\
\9end\
end\
\
--[[\
\9Used to set a handler for when the promise resolves, rejects, or is\
\9cancelled. Returns a new promise chained from this promise.\
]]\
function Promise.prototype:_finally(traceback, finallyHandler, onlyOk)\
\9if not onlyOk then\
\9\9self._unhandledRejection = false\
\9end\
\
\9-- Return a promise chained off of this promise\
\9return Promise._new(traceback, function(resolve, reject)\
\9\9local finallyCallback = resolve\
\9\9if finallyHandler then\
\9\9\9finallyCallback = createAdvancer(\
\9\9\9\9traceback,\
\9\9\9\9finallyHandler,\
\9\9\9\9resolve,\
\9\9\9\9reject\
\9\9\9)\
\9\9end\
\
\9\9if onlyOk then\
\9\9\9local callback = finallyCallback\
\9\9\9finallyCallback = function(...)\
\9\9\9\9if self._status == Promise.Status.Rejected then\
\9\9\9\9\9return resolve(self)\
\9\9\9\9end\
\
\9\9\9\9return callback(...)\
\9\9\9end\
\9\9end\
\
\9\9if self._status == Promise.Status.Started then\
\9\9\9-- The promise is not settled, so queue this.\
\9\9\9table.insert(self._queuedFinally, finallyCallback)\
\9\9else\
\9\9\9-- The promise already settled or was cancelled, run the callback now.\
\9\9\9finallyCallback(self._status)\
\9\9end\
\9end, self)\
end\
\
function Promise.prototype:finally(finallyHandler)\
\9assert(\
\9\9finallyHandler == nil or type(finallyHandler) == \"function\",\
\9\9string.format(ERROR_NON_FUNCTION, \"Promise:finally\")\
\9)\
\9return self:_finally(debug.traceback(nil, 2), finallyHandler)\
end\
\
--[[\
\9Calls a callback on `finally` with specific arguments.\
]]\
function Promise.prototype:finallyCall(callback, ...)\
\9assert(type(callback) == \"function\", string.format(ERROR_NON_FUNCTION, \"Promise:finallyCall\"))\
\9local length, values = pack(...)\
\9return self:_finally(debug.traceback(nil, 2), function()\
\9\9return callback(unpack(values, 1, length))\
\9end)\
end\
\
--[[\
\9Shorthand for a finally handler that returns the given value.\
]]\
function Promise.prototype:finallyReturn(...)\
\9local length, values = pack(...)\
\9return self:_finally(debug.traceback(nil, 2), function()\
\9\9return unpack(values, 1, length)\
\9end)\
end\
\
--[[\
\9Similar to finally, except rejections are propagated through it.\
]]\
function Promise.prototype:done(finallyHandler)\
\9assert(\
\9\9finallyHandler == nil or type(finallyHandler) == \"function\",\
\9\9string.format(ERROR_NON_FUNCTION, \"Promise:done\")\
\9)\
\9return self:_finally(debug.traceback(nil, 2), finallyHandler, true)\
end\
\
--[[\
\9Calls a callback on `done` with specific arguments.\
]]\
function Promise.prototype:doneCall(callback, ...)\
\9assert(type(callback) == \"function\", string.format(ERROR_NON_FUNCTION, \"Promise:doneCall\"))\
\9local length, values = pack(...)\
\9return self:_finally(debug.traceback(nil, 2), function()\
\9\9return callback(unpack(values, 1, length))\
\9end, true)\
end\
\
--[[\
\9Shorthand for a done handler that returns the given value.\
]]\
function Promise.prototype:doneReturn(...)\
\9local length, values = pack(...)\
\9return self:_finally(debug.traceback(nil, 2), function()\
\9\9return unpack(values, 1, length)\
\9end, true)\
end\
\
--[[\
\9Yield until the promise is completed.\
\
\9This matches the execution model of normal Roblox functions.\
]]\
function Promise.prototype:awaitStatus()\
\9self._unhandledRejection = false\
\
\9if self._status == Promise.Status.Started then\
\9\9local bindable = Instance.new(\"BindableEvent\")\
\
\9\9self:finally(function()\
\9\9\9bindable:Fire()\
\9\9end)\
\
\9\9bindable.Event:Wait()\
\9\9bindable:Destroy()\
\9end\
\
\9if self._status == Promise.Status.Resolved then\
\9\9return self._status, unpack(self._values, 1, self._valuesLength)\
\9elseif self._status == Promise.Status.Rejected then\
\9\9return self._status, unpack(self._values, 1, self._valuesLength)\
\9end\
\
\9return self._status\
end\
\
local function awaitHelper(status, ...)\
\9return status == Promise.Status.Resolved, ...\
end\
\
--[[\
\9Calls awaitStatus internally, returns (isResolved, values...)\
]]\
function Promise.prototype:await()\
\9return awaitHelper(self:awaitStatus())\
end\
\
local function expectHelper(status, ...)\
\9if status ~= Promise.Status.Resolved then\
\9\9error((...) == nil and \"Expected Promise rejected with no value.\" or (...), 3)\
\9end\
\
\9return ...\
end\
\
--[[\
\9Calls await and only returns if the Promise resolves.\
\9Throws if the Promise rejects or gets cancelled.\
]]\
function Promise.prototype:expect()\
\9return expectHelper(self:awaitStatus())\
end\
\
-- Backwards compatibility\
Promise.prototype.awaitValue = Promise.prototype.expect\
\
--[[\
\9Intended for use in tests.\
\
\9Similar to await(), but instead of yielding if the promise is unresolved,\
\9_unwrap will throw. This indicates an assumption that a promise has\
\9resolved.\
]]\
function Promise.prototype:_unwrap()\
\9if self._status == Promise.Status.Started then\
\9\9error(\"Promise has not resolved or rejected.\", 2)\
\9end\
\
\9local success = self._status == Promise.Status.Resolved\
\
\9return success, unpack(self._values, 1, self._valuesLength)\
end\
\
function Promise.prototype:_resolve(...)\
\9if self._status ~= Promise.Status.Started then\
\9\9if Promise.is((...)) then\
\9\9\9(...):_consumerCancelled(self)\
\9\9end\
\9\9return\
\9end\
\
\9-- If the resolved value was a Promise, we chain onto it!\
\9if Promise.is((...)) then\
\9\9-- Without this warning, arguments sometimes mysteriously disappear\
\9\9if select(\"#\", ...) > 1 then\
\9\9\9local message = string.format(\
\9\9\9\9\"When returning a Promise from andThen, extra arguments are \" ..\
\9\9\9\9\"discarded! See:\\n\\n%s\",\
\9\9\9\9self._source\
\9\9\9)\
\9\9\9warn(message)\
\9\9end\
\
\9\9local chainedPromise = ...\
\
\9\9local promise = chainedPromise:andThen(\
\9\9\9function(...)\
\9\9\9\9self:_resolve(...)\
\9\9\9end,\
\9\9\9function(...)\
\9\9\9\9local maybeRuntimeError = chainedPromise._values[1]\
\
\9\9\9\9-- Backwards compatibility < v2\
\9\9\9\9if chainedPromise._error then\
\9\9\9\9\9maybeRuntimeError = Error.new({\
\9\9\9\9\9\9error = chainedPromise._error,\
\9\9\9\9\9\9kind = Error.Kind.ExecutionError,\
\9\9\9\9\9\9context = \"[No stack trace available as this Promise originated from an older version of the Promise library (< v2)]\",\
\9\9\9\9\9})\
\9\9\9\9end\
\
\9\9\9\9if Error.isKind(maybeRuntimeError, Error.Kind.ExecutionError) then\
\9\9\9\9\9return self:_reject(maybeRuntimeError:extend({\
\9\9\9\9\9\9error = \"This Promise was chained to a Promise that errored.\",\
\9\9\9\9\9\9trace = \"\",\
\9\9\9\9\9\9context = string.format(\
\9\9\9\9\9\9\9\"The Promise at:\\n\\n%s\\n...Rejected because it was chained to the following Promise, which encountered an error:\\n\",\
\9\9\9\9\9\9\9self._source\
\9\9\9\9\9\9),\
\9\9\9\9\9}))\
\9\9\9\9end\
\
\9\9\9\9self:_reject(...)\
\9\9\9end\
\9\9)\
\
\9\9if promise._status == Promise.Status.Cancelled then\
\9\9\9self:cancel()\
\9\9elseif promise._status == Promise.Status.Started then\
\9\9\9-- Adopt ourselves into promise for cancellation propagation.\
\9\9\9self._parent = promise\
\9\9\9promise._consumers[self] = true\
\9\9end\
\
\9\9return\
\9end\
\
\9self._status = Promise.Status.Resolved\
\9self._valuesLength, self._values = pack(...)\
\
\9-- We assume that these callbacks will not throw errors.\
\9for _, callback in ipairs(self._queuedResolve) do\
\9\9coroutine.wrap(callback)(...)\
\9end\
\
\9self:_finalize()\
end\
\
function Promise.prototype:_reject(...)\
\9if self._status ~= Promise.Status.Started then\
\9\9return\
\9end\
\
\9self._status = Promise.Status.Rejected\
\9self._valuesLength, self._values = pack(...)\
\
\9-- If there are any rejection handlers, call those!\
\9if not isEmpty(self._queuedReject) then\
\9\9-- We assume that these callbacks will not throw errors.\
\9\9for _, callback in ipairs(self._queuedReject) do\
\9\9\9coroutine.wrap(callback)(...)\
\9\9end\
\9else\
\9\9-- At this point, no one was able to observe the error.\
\9\9-- An error handler might still be attached if the error occurred\
\9\9-- synchronously. We'll wait one tick, and if there are still no\
\9\9-- observers, then we should put a message in the console.\
\
\9\9local err = tostring((...))\
\
\9\9coroutine.wrap(function()\
\9\9\9Promise._timeEvent:Wait()\
\
\9\9\9-- Someone observed the error, hooray!\
\9\9\9if not self._unhandledRejection then\
\9\9\9\9return\
\9\9\9end\
\
\9\9\9-- Build a reasonable message\
\9\9\9local message = string.format(\
\9\9\9\9\"Unhandled Promise rejection:\\n\\n%s\\n\\n%s\",\
\9\9\9\9err,\
\9\9\9\9self._source\
\9\9\9)\
\
\9\9\9if Promise.TEST then\
\9\9\9\9-- Don't spam output when we're running tests.\
\9\9\9\9return\
\9\9\9end\
\
\9\9\9warn(message)\
\9\9end)()\
\9end\
\
\9self:_finalize()\
end\
\
--[[\
\9Calls any :finally handlers. We need this to be a separate method and\
\9queue because we must call all of the finally callbacks upon a success,\
\9failure, *and* cancellation.\
]]\
function Promise.prototype:_finalize()\
\9for _, callback in ipairs(self._queuedFinally) do\
\9\9-- Purposefully not passing values to callbacks here, as it could be the\
\9\9-- resolved values, or rejected errors. If the developer needs the values,\
\9\9-- they should use :andThen or :catch explicitly.\
\9\9coroutine.wrap(callback)(self._status)\
\9end\
\
\9self._queuedFinally = nil\
\9self._queuedReject = nil\
\9self._queuedResolve = nil\
\
\9-- Clear references to other Promises to allow gc\
\9if not Promise.TEST then\
\9\9self._parent = nil\
\9\9self._consumers = nil\
\9end\
end\
\
--[[\
\9Chains a Promise from this one that is resolved if this Promise is\
\9resolved, and rejected if it is not resolved.\
]]\
function Promise.prototype:now(rejectionValue)\
\9local traceback = debug.traceback(nil, 2)\
\9if self:getStatus() == Promise.Status.Resolved then\
\9\9return self:_andThen(traceback, function(...)\
\9\9\9return ...\
\9\9end)\
\9else\
\9\9return Promise.reject(rejectionValue == nil and Error.new({\
\9\9\9kind = Error.Kind.NotResolvedInTime,\
\9\9\9error = \"This Promise was not resolved in time for :now()\",\
\9\9\9context = \":now() was called at:\\n\\n\" .. traceback,\
\9\9}) or rejectionValue)\
\9end\
end\
\
--[[\
\9Retries a Promise-returning callback N times until it succeeds.\
]]\
function Promise.retry(callback, times, ...)\
\9assert(type(callback) == \"function\", \"Parameter #1 to Promise.retry must be a function\")\
\9assert(type(times) == \"number\", \"Parameter #2 to Promise.retry must be a number\")\
\
\9local args, length = {...}, select(\"#\", ...)\
\
\9return Promise.resolve(callback(...)):catch(function(...)\
\9\9if times > 0 then\
\9\9\9return Promise.retry(callback, times - 1, unpack(args, 1, length))\
\9\9else\
\9\9\9return Promise.reject(...)\
\9\9end\
\9end)\
end\
\
--[[\
\9Converts an event into a Promise with an optional predicate\
]]\
function Promise.fromEvent(event, predicate)\
\9predicate = predicate or function()\
\9\9return true\
\9end\
\
\9return Promise._new(debug.traceback(nil, 2), function(resolve, reject, onCancel)\
\9\9local connection\
\9\9local shouldDisconnect = false\
\
\9\9local function disconnect()\
\9\9\9connection:Disconnect()\
\9\9\9connection = nil\
\9\9end\
\
\9\9-- We use shouldDisconnect because if the callback given to Connect is called before\
\9\9-- Connect returns, connection will still be nil. This happens with events that queue up\
\9\9-- events when there's nothing connected, such as RemoteEvents\
\
\9\9connection = event:Connect(function(...)\
\9\9\9local callbackValue = predicate(...)\
\
\9\9\9if callbackValue == true then\
\9\9\9\9resolve(...)\
\
\9\9\9\9if connection then\
\9\9\9\9\9disconnect()\
\9\9\9\9else\
\9\9\9\9\9shouldDisconnect = true\
\9\9\9\9end\
\9\9\9elseif type(callbackValue) ~= \"boolean\" then\
\9\9\9\9error(\"Promise.fromEvent predicate should always return a boolean\")\
\9\9\9end\
\9\9end)\
\
\9\9if shouldDisconnect and connection then\
\9\9\9return disconnect()\
\9\9end\
\
\9\9onCancel(function()\
\9\9\9disconnect()\
\9\9end)\
\9end)\
end\
\
return Promise\
", '@'.."Orca.include.Promise")) setfenv(fn, newEnv("Orca.include.Promise")) return fn() end)

newModule("RuntimeLib", "ModuleScript", "Orca.include.RuntimeLib", "Orca.include", function () local fn = assert(loadstring("local Promise = require(script.Parent.Promise)\
\
local RunService = game:GetService(\"RunService\")\
local ReplicatedFirst = game:GetService(\"ReplicatedFirst\")\
\
local TS = {}\
\
TS.Promise = Promise\
\
local function isPlugin(object)\
\9return RunService:IsStudio() and object:FindFirstAncestorWhichIsA(\"Plugin\") ~= nil\
end\
\
function TS.getModule(object, scope, moduleName)\
\9if moduleName == nil then\
\9\9moduleName = scope\
\9\9scope = \"@rbxts\"\
\9end\
\
\9if RunService:IsRunning() and object:IsDescendantOf(ReplicatedFirst) then\
\9\9warn(\"roblox-ts packages should not be used from ReplicatedFirst!\")\
\9end\
\
\9-- ensure modules have fully replicated\
\9if RunService:IsRunning() and RunService:IsClient() and not isPlugin(object) and not game:IsLoaded() then\
\9\9game.Loaded:Wait()\
\9end\
\
\9local globalModules = script.Parent:FindFirstChild(\"node_modules\")\
\9if not globalModules then\
\9\9error(\"Could not find any modules!\", 2)\
\9end\
\
\9repeat\
\9\9local modules = object:FindFirstChild(\"node_modules\")\
\9\9if modules and modules ~= globalModules then\
\9\9\9modules = modules:FindFirstChild(\"@rbxts\")\
\9\9end\
\9\9if modules then\
\9\9\9local module = modules:FindFirstChild(moduleName)\
\9\9\9if module then\
\9\9\9\9return module\
\9\9\9end\
\9\9end\
\9\9object = object.Parent\
\9until object == nil or object == globalModules\
\
\9local scopedModules = globalModules:FindFirstChild(scope or \"@rbxts\");\
\9return (scopedModules or globalModules):FindFirstChild(moduleName) or error(\"Could not find module: \" .. moduleName, 2)\
end\
\
-- This is a hash which TS.import uses as a kind of linked-list-like history of [Script who Loaded] -> Library\
local currentlyLoading = {}\
local registeredLibraries = {}\
\
function TS.import(caller, module, ...)\
\9for i = 1, select(\"#\", ...) do\
\9\9module = module:WaitForChild((select(i, ...)))\
\9end\
\
\9if module.ClassName ~= \"ModuleScript\" then\
\9\9error(\"Failed to import! Expected ModuleScript, got \" .. module.ClassName, 2)\
\9end\
\
\9currentlyLoading[caller] = module\
\
\9-- Check to see if a case like this occurs:\
\9-- module -> Module1 -> Module2 -> module\
\
\9-- WHERE currentlyLoading[module] is Module1\
\9-- and currentlyLoading[Module1] is Module2\
\9-- and currentlyLoading[Module2] is module\
\
\9local currentModule = module\
\9local depth = 0\
\
\9while currentModule do\
\9\9depth = depth + 1\
\9\9currentModule = currentlyLoading[currentModule]\
\
\9\9if currentModule == module then\
\9\9\9local str = currentModule.Name -- Get the string traceback\
\
\9\9\9for _ = 1, depth do\
\9\9\9\9currentModule = currentlyLoading[currentModule]\
\9\9\9\9str = str .. \"  ⇒ \" .. currentModule.Name\
\9\9\9end\
\
\9\9\9error(\"Failed to import! Detected a circular dependency chain: \" .. str, 2)\
\9\9end\
\9end\
\
\9if not registeredLibraries[module] then\
\9\9if _G[module] then\
\9\9\9error(\
\9\9\9\9\"Invalid module access! Do you have two TS runtimes trying to import this? \" .. module:GetFullName(),\
\9\9\9\0092\
\9\9\9)\
\9\9end\
\
\9\9_G[module] = TS\
\9\9registeredLibraries[module] = true -- register as already loaded for subsequent calls\
\9end\
\
\9local data = require(module)\
\
\9if currentlyLoading[caller] == module then -- Thread-safe cleanup!\
\9\9currentlyLoading[caller] = nil\
\9end\
\
\9return data\
end\
\
function TS.instanceof(obj, class)\
\9-- custom Class.instanceof() check\
\9if type(class) == \"table\" and type(class.instanceof) == \"function\" then\
\9\9return class.instanceof(obj)\
\9end\
\
\9-- metatable check\
\9if type(obj) == \"table\" then\
\9\9obj = getmetatable(obj)\
\9\9while obj ~= nil do\
\9\9\9if obj == class then\
\9\9\9\9return true\
\9\9\9end\
\9\9\9local mt = getmetatable(obj)\
\9\9\9if mt then\
\9\9\9\9obj = mt.__index\
\9\9\9else\
\9\9\9\9obj = nil\
\9\9\9end\
\9\9end\
\9end\
\
\9return false\
end\
\
function TS.async(callback)\
\9return function(...)\
\9\9local n = select(\"#\", ...)\
\9\9local args = { ... }\
\9\9return Promise.new(function(resolve, reject)\
\9\9\9coroutine.wrap(function()\
\9\9\9\9local ok, result = pcall(callback, unpack(args, 1, n))\
\9\9\9\9if ok then\
\9\9\9\9\9resolve(result)\
\9\9\9\9else\
\9\9\9\9\9reject(result)\
\9\9\9\9end\
\9\9\9end)()\
\9\9end)\
\9end\
end\
\
function TS.await(promise)\
\9if not Promise.is(promise) then\
\9\9return promise\
\9end\
\
\9local status, value = promise:awaitStatus()\
\9if status == Promise.Status.Resolved then\
\9\9return value\
\9elseif status == Promise.Status.Rejected then\
\9\9error(value, 2)\
\9else\
\9\9error(\"The awaited Promise was cancelled\", 2)\
\9end\
end\
\
function TS.bit_lrsh(a, b)\
\9local absA = math.abs(a)\
\9local result = bit32.rshift(absA, b)\
\9if a == absA then\
\9\9return result\
\9else\
\9\9return -result - 1\
\9end\
end\
\
TS.TRY_RETURN = 1\
TS.TRY_BREAK = 2\
TS.TRY_CONTINUE = 3\
\
function TS.try(func, catch, finally)\
\9local err, traceback\
\9local success, exitType, returns = xpcall(\
\9\9func,\
\9\9function(errInner)\
\9\9\9err = errInner\
\9\9\9traceback = debug.traceback()\
\9\9end\
\9)\
\9if not success and catch then\
\9\9local newExitType, newReturns = catch(err, traceback)\
\9\9if newExitType then\
\9\9\9exitType, returns = newExitType, newReturns\
\9\9end\
\9end\
\9if finally then\
\9\9local newExitType, newReturns = finally()\
\9\9if newExitType then\
\9\9\9exitType, returns = newExitType, newReturns\
\9\9end\
\9end\
\9return exitType, returns\
end\
\
function TS.generator(callback)\
\9local co = coroutine.create(callback)\
\9return {\
\9\9next = function(...)\
\9\9\9if coroutine.status(co) == \"dead\" then\
\9\9\9\9return { done = true }\
\9\9\9else\
\9\9\9\9local success, value = coroutine.resume(co, ...)\
\9\9\9\9if success == false then\
\9\9\9\9\9error(value, 2)\
\9\9\9\9end\
\9\9\9\9return {\
\9\9\9\9\9value = value,\
\9\9\9\9\9done = coroutine.status(co) == \"dead\",\
\9\9\9\9}\
\9\9\9end\
\9\9end,\
\9}\
end\
\
return TS\
", '@'.."Orca.include.RuntimeLib")) setfenv(fn, newEnv("Orca.include.RuntimeLib")) return fn() end)

newInstance("node_modules", "Folder", "Orca.include.node_modules", "Orca.include")

newInstance("compiler-types", "Folder", "Orca.include.node_modules.compiler-types", "Orca.include.node_modules")

newInstance("types", "Folder", "Orca.include.node_modules.compiler-types.types", "Orca.include.node_modules.compiler-types")

newInstance("exploit-types", "Folder", "Orca.include.node_modules.exploit-types", "Orca.include.node_modules")

newInstance("types", "Folder", "Orca.include.node_modules.exploit-types.types", "Orca.include.node_modules.exploit-types")

newInstance("flipper", "Folder", "Orca.include.node_modules.flipper", "Orca.include.node_modules")

newModule("src", "ModuleScript", "Orca.include.node_modules.flipper.src", "Orca.include.node_modules.flipper", function () local fn = assert(loadstring("local Flipper = {\13\
\9SingleMotor = require(script.SingleMotor),\13\
\9GroupMotor = require(script.GroupMotor),\13\
\13\
\9Instant = require(script.Instant),\13\
\9Linear = require(script.Linear),\13\
\9Spring = require(script.Spring),\13\
\9\13\
\9isMotor = require(script.isMotor),\13\
}\13\
\13\
return Flipper", '@'.."Orca.include.node_modules.flipper.src")) setfenv(fn, newEnv("Orca.include.node_modules.flipper.src")) return fn() end)

newModule("BaseMotor", "ModuleScript", "Orca.include.node_modules.flipper.src.BaseMotor", "Orca.include.node_modules.flipper.src", function () local fn = assert(loadstring("local RunService = game:GetService(\"RunService\")\13\
\13\
local Signal = require(script.Parent.Signal)\13\
\13\
local noop = function() end\13\
\13\
local BaseMotor = {}\13\
BaseMotor.__index = BaseMotor\13\
\13\
function BaseMotor.new()\13\
\9return setmetatable({\13\
\9\9_onStep = Signal.new(),\13\
\9\9_onStart = Signal.new(),\13\
\9\9_onComplete = Signal.new(),\13\
\9}, BaseMotor)\13\
end\13\
\13\
function BaseMotor:onStep(handler)\13\
\9return self._onStep:connect(handler)\13\
end\13\
\13\
function BaseMotor:onStart(handler)\13\
\9return self._onStart:connect(handler)\13\
end\13\
\13\
function BaseMotor:onComplete(handler)\13\
\9return self._onComplete:connect(handler)\13\
end\13\
\13\
function BaseMotor:start()\13\
\9if not self._connection then\13\
\9\9self._connection = RunService.RenderStepped:Connect(function(deltaTime)\13\
\9\9\9self:step(deltaTime)\13\
\9\9end)\13\
\9end\13\
end\13\
\13\
function BaseMotor:stop()\13\
\9if self._connection then\13\
\9\9self._connection:Disconnect()\13\
\9\9self._connection = nil\13\
\9end\13\
end\13\
\13\
BaseMotor.destroy = BaseMotor.stop\13\
\13\
BaseMotor.step = noop\13\
BaseMotor.getValue = noop\13\
BaseMotor.setGoal = noop\13\
\13\
function BaseMotor:__tostring()\13\
\9return \"Motor\"\13\
end\13\
\13\
return BaseMotor\13\
", '@'.."Orca.include.node_modules.flipper.src.BaseMotor")) setfenv(fn, newEnv("Orca.include.node_modules.flipper.src.BaseMotor")) return fn() end)

newModule("GroupMotor", "ModuleScript", "Orca.include.node_modules.flipper.src.GroupMotor", "Orca.include.node_modules.flipper.src", function () local fn = assert(loadstring("local BaseMotor = require(script.Parent.BaseMotor)\13\
local SingleMotor = require(script.Parent.SingleMotor)\13\
\13\
local isMotor = require(script.Parent.isMotor)\13\
\13\
local GroupMotor = setmetatable({}, BaseMotor)\13\
GroupMotor.__index = GroupMotor\13\
\13\
local function toMotor(value)\13\
\9if isMotor(value) then\13\
\9\9return value\13\
\9end\13\
\13\
\9local valueType = typeof(value)\13\
\13\
\9if valueType == \"number\" then\13\
\9\9return SingleMotor.new(value, false)\13\
\9elseif valueType == \"table\" then\13\
\9\9return GroupMotor.new(value, false)\13\
\9end\13\
\13\
\9error((\"Unable to convert %q to motor; type %s is unsupported\"):format(value, valueType), 2)\13\
end\13\
\13\
function GroupMotor.new(initialValues, useImplicitConnections)\13\
\9assert(initialValues, \"Missing argument #1: initialValues\")\13\
\9assert(typeof(initialValues) == \"table\", \"initialValues must be a table!\")\13\
\9assert(not initialValues.step, \"initialValues contains disallowed property \\\"step\\\". Did you mean to put a table of values here?\")\13\
\13\
\9local self = setmetatable(BaseMotor.new(), GroupMotor)\13\
\13\
\9if useImplicitConnections ~= nil then\13\
\9\9self._useImplicitConnections = useImplicitConnections\13\
\9else\13\
\9\9self._useImplicitConnections = true\13\
\9end\13\
\13\
\9self._complete = true\13\
\9self._motors = {}\13\
\13\
\9for key, value in pairs(initialValues) do\13\
\9\9self._motors[key] = toMotor(value)\13\
\9end\13\
\13\
\9return self\13\
end\13\
\13\
function GroupMotor:step(deltaTime)\13\
\9if self._complete then\13\
\9\9return true\13\
\9end\13\
\13\
\9local allMotorsComplete = true\13\
\13\
\9for _, motor in pairs(self._motors) do\13\
\9\9local complete = motor:step(deltaTime)\13\
\9\9if not complete then\13\
\9\9\9-- If any of the sub-motors are incomplete, the group motor will not be complete either\13\
\9\9\9allMotorsComplete = false\13\
\9\9end\13\
\9end\13\
\13\
\9self._onStep:fire(self:getValue())\13\
\13\
\9if allMotorsComplete then\13\
\9\9if self._useImplicitConnections then\13\
\9\9\9self:stop()\13\
\9\9end\13\
\13\
\9\9self._complete = true\13\
\9\9self._onComplete:fire()\13\
\9end\13\
\13\
\9return allMotorsComplete\13\
end\13\
\13\
function GroupMotor:setGoal(goals)\13\
\9assert(not goals.step, \"goals contains disallowed property \\\"step\\\". Did you mean to put a table of goals here?\")\13\
\13\
\9self._complete = false\13\
\9self._onStart:fire()\13\
\13\
\9for key, goal in pairs(goals) do\13\
\9\9local motor = assert(self._motors[key], (\"Unknown motor for key %s\"):format(key))\13\
\9\9motor:setGoal(goal)\13\
\9end\13\
\13\
\9if self._useImplicitConnections then\13\
\9\9self:start()\13\
\9end\13\
end\13\
\13\
function GroupMotor:getValue()\13\
\9local values = {}\13\
\13\
\9for key, motor in pairs(self._motors) do\13\
\9\9values[key] = motor:getValue()\13\
\9end\13\
\13\
\9return values\13\
end\13\
\13\
function GroupMotor:__tostring()\13\
\9return \"Motor(Group)\"\13\
end\13\
\13\
return GroupMotor\13\
", '@'.."Orca.include.node_modules.flipper.src.GroupMotor")) setfenv(fn, newEnv("Orca.include.node_modules.flipper.src.GroupMotor")) return fn() end)

newModule("Instant", "ModuleScript", "Orca.include.node_modules.flipper.src.Instant", "Orca.include.node_modules.flipper.src", function () local fn = assert(loadstring("local Instant = {}\13\
Instant.__index = Instant\13\
\13\
function Instant.new(targetValue)\13\
\9return setmetatable({\13\
\9\9_targetValue = targetValue,\13\
\9}, Instant)\13\
end\13\
\13\
function Instant:step()\13\
\9return {\13\
\9\9complete = true,\13\
\9\9value = self._targetValue,\13\
\9}\13\
end\13\
\13\
return Instant", '@'.."Orca.include.node_modules.flipper.src.Instant")) setfenv(fn, newEnv("Orca.include.node_modules.flipper.src.Instant")) return fn() end)

newModule("Linear", "ModuleScript", "Orca.include.node_modules.flipper.src.Linear", "Orca.include.node_modules.flipper.src", function () local fn = assert(loadstring("local Linear = {}\13\
Linear.__index = Linear\13\
\13\
function Linear.new(targetValue, options)\13\
\9assert(targetValue, \"Missing argument #1: targetValue\")\13\
\9\13\
\9options = options or {}\13\
\13\
\9return setmetatable({\13\
\9\9_targetValue = targetValue,\13\
\9\9_velocity = options.velocity or 1,\13\
\9}, Linear)\13\
end\13\
\13\
function Linear:step(state, dt)\13\
\9local position = state.value\13\
\9local velocity = self._velocity -- Linear motion ignores the state's velocity\13\
\9local goal = self._targetValue\13\
\13\
\9local dPos = dt * velocity\13\
\13\
\9local complete = dPos >= math.abs(goal - position)\13\
\9position = position + dPos * (goal > position and 1 or -1)\13\
\9if complete then\13\
\9\9position = self._targetValue\13\
\9\9velocity = 0\13\
\9end\13\
\9\13\
\9return {\13\
\9\9complete = complete,\13\
\9\9value = position,\13\
\9\9velocity = velocity,\13\
\9}\13\
end\13\
\13\
return Linear", '@'.."Orca.include.node_modules.flipper.src.Linear")) setfenv(fn, newEnv("Orca.include.node_modules.flipper.src.Linear")) return fn() end)

newModule("Signal", "ModuleScript", "Orca.include.node_modules.flipper.src.Signal", "Orca.include.node_modules.flipper.src", function () local fn = assert(loadstring("local Connection = {}\13\
Connection.__index = Connection\13\
\13\
function Connection.new(signal, handler)\13\
\9return setmetatable({\13\
\9\9signal = signal,\13\
\9\9connected = true,\13\
\9\9_handler = handler,\13\
\9}, Connection)\13\
end\13\
\13\
function Connection:disconnect()\13\
\9if self.connected then\13\
\9\9self.connected = false\13\
\13\
\9\9for index, connection in pairs(self.signal._connections) do\13\
\9\9\9if connection == self then\13\
\9\9\9\9table.remove(self.signal._connections, index)\13\
\9\9\9\9return\13\
\9\9\9end\13\
\9\9end\13\
\9end\13\
end\13\
\13\
local Signal = {}\13\
Signal.__index = Signal\13\
\13\
function Signal.new()\13\
\9return setmetatable({\13\
\9\9_connections = {},\13\
\9\9_threads = {},\13\
\9}, Signal)\13\
end\13\
\13\
function Signal:fire(...)\13\
\9for _, connection in pairs(self._connections) do\13\
\9\9connection._handler(...)\13\
\9end\13\
\13\
\9for _, thread in pairs(self._threads) do\13\
\9\9coroutine.resume(thread, ...)\13\
\9end\13\
\9\13\
\9self._threads = {}\13\
end\13\
\13\
function Signal:connect(handler)\13\
\9local connection = Connection.new(self, handler)\13\
\9table.insert(self._connections, connection)\13\
\9return connection\13\
end\13\
\13\
function Signal:wait()\13\
\9table.insert(self._threads, coroutine.running())\13\
\9return coroutine.yield()\13\
end\13\
\13\
return Signal", '@'.."Orca.include.node_modules.flipper.src.Signal")) setfenv(fn, newEnv("Orca.include.node_modules.flipper.src.Signal")) return fn() end)

newModule("SingleMotor", "ModuleScript", "Orca.include.node_modules.flipper.src.SingleMotor", "Orca.include.node_modules.flipper.src", function () local fn = assert(loadstring("local BaseMotor = require(script.Parent.BaseMotor)\13\
\13\
local SingleMotor = setmetatable({}, BaseMotor)\13\
SingleMotor.__index = SingleMotor\13\
\13\
function SingleMotor.new(initialValue, useImplicitConnections)\13\
\9assert(initialValue, \"Missing argument #1: initialValue\")\13\
\9assert(typeof(initialValue) == \"number\", \"initialValue must be a number!\")\13\
\13\
\9local self = setmetatable(BaseMotor.new(), SingleMotor)\13\
\13\
\9if useImplicitConnections ~= nil then\13\
\9\9self._useImplicitConnections = useImplicitConnections\13\
\9else\13\
\9\9self._useImplicitConnections = true\13\
\9end\13\
\13\
\9self._goal = nil\13\
\9self._state = {\13\
\9\9complete = true,\13\
\9\9value = initialValue,\13\
\9}\13\
\13\
\9return self\13\
end\13\
\13\
function SingleMotor:step(deltaTime)\13\
\9if self._state.complete then\13\
\9\9return true\13\
\9end\13\
\13\
\9local newState = self._goal:step(self._state, deltaTime)\13\
\13\
\9self._state = newState\13\
\9self._onStep:fire(newState.value)\13\
\13\
\9if newState.complete then\13\
\9\9if self._useImplicitConnections then\13\
\9\9\9self:stop()\13\
\9\9end\13\
\13\
\9\9self._onComplete:fire()\13\
\9end\13\
\13\
\9return newState.complete\13\
end\13\
\13\
function SingleMotor:getValue()\13\
\9return self._state.value\13\
end\13\
\13\
function SingleMotor:setGoal(goal)\13\
\9self._state.complete = false\13\
\9self._goal = goal\13\
\13\
\9self._onStart:fire()\13\
\13\
\9if self._useImplicitConnections then\13\
\9\9self:start()\13\
\9end\13\
end\13\
\13\
function SingleMotor:__tostring()\13\
\9return \"Motor(Single)\"\13\
end\13\
\13\
return SingleMotor\13\
", '@'.."Orca.include.node_modules.flipper.src.SingleMotor")) setfenv(fn, newEnv("Orca.include.node_modules.flipper.src.SingleMotor")) return fn() end)

newModule("Spring", "ModuleScript", "Orca.include.node_modules.flipper.src.Spring", "Orca.include.node_modules.flipper.src", function () local fn = assert(loadstring("local VELOCITY_THRESHOLD = 0.001\13\
local POSITION_THRESHOLD = 0.001\13\
\13\
local EPS = 0.0001\13\
\13\
local Spring = {}\13\
Spring.__index = Spring\13\
\13\
function Spring.new(targetValue, options)\13\
\9assert(targetValue, \"Missing argument #1: targetValue\")\13\
\9options = options or {}\13\
\13\
\9return setmetatable({\13\
\9\9_targetValue = targetValue,\13\
\9\9_frequency = options.frequency or 4,\13\
\9\9_dampingRatio = options.dampingRatio or 1,\13\
\9}, Spring)\13\
end\13\
\13\
function Spring:step(state, dt)\13\
\9-- Copyright 2018 Parker Stebbins (parker@fractality.io)\13\
\9-- github.com/Fraktality/Spring\13\
\9-- Distributed under the MIT license\13\
\13\
\9local d = self._dampingRatio\13\
\9local f = self._frequency*2*math.pi\13\
\9local g = self._targetValue\13\
\9local p0 = state.value\13\
\9local v0 = state.velocity or 0\13\
\13\
\9local offset = p0 - g\13\
\9local decay = math.exp(-d*f*dt)\13\
\13\
\9local p1, v1\13\
\13\
\9if d == 1 then -- Critically damped\13\
\9\9p1 = (offset*(1 + f*dt) + v0*dt)*decay + g\13\
\9\9v1 = (v0*(1 - f*dt) - offset*(f*f*dt))*decay\13\
\9elseif d < 1 then -- Underdamped\13\
\9\9local c = math.sqrt(1 - d*d)\13\
\13\
\9\9local i = math.cos(f*c*dt)\13\
\9\9local j = math.sin(f*c*dt)\13\
\13\
\9\9-- Damping ratios approaching 1 can cause division by small numbers.\13\
\9\9-- To fix that, group terms around z=j/c and find an approximation for z.\13\
\9\9-- Start with the definition of z:\13\
\9\9--    z = sin(dt*f*c)/c\13\
\9\9-- Substitute a=dt*f:\13\
\9\9--    z = sin(a*c)/c\13\
\9\9-- Take the Maclaurin expansion of z with respect to c:\13\
\9\9--    z = a - (a^3*c^2)/6 + (a^5*c^4)/120 + O(c^6)\13\
\9\9--    z ≈ a - (a^3*c^2)/6 + (a^5*c^4)/120\13\
\9\9-- Rewrite in Horner form:\13\
\9\9--    z ≈ a + ((a*a)*(c*c)*(c*c)/20 - c*c)*(a*a*a)/6\13\
\13\
\9\9local z\13\
\9\9if c > EPS then\13\
\9\9\9z = j/c\13\
\9\9else\13\
\9\9\9local a = dt*f\13\
\9\9\9z = a + ((a*a)*(c*c)*(c*c)/20 - c*c)*(a*a*a)/6\13\
\9\9end\13\
\13\
\9\9-- Frequencies approaching 0 present a similar problem.\13\
\9\9-- We want an approximation for y as f approaches 0, where:\13\
\9\9--    y = sin(dt*f*c)/(f*c)\13\
\9\9-- Substitute b=dt*c:\13\
\9\9--    y = sin(b*c)/b\13\
\9\9-- Now reapply the process from z.\13\
\13\
\9\9local y\13\
\9\9if f*c > EPS then\13\
\9\9\9y = j/(f*c)\13\
\9\9else\13\
\9\9\9local b = f*c\13\
\9\9\9y = dt + ((dt*dt)*(b*b)*(b*b)/20 - b*b)*(dt*dt*dt)/6\13\
\9\9end\13\
\13\
\9\9p1 = (offset*(i + d*z) + v0*y)*decay + g\13\
\9\9v1 = (v0*(i - z*d) - offset*(z*f))*decay\13\
\13\
\9else -- Overdamped\13\
\9\9local c = math.sqrt(d*d - 1)\13\
\13\
\9\9local r1 = -f*(d - c)\13\
\9\9local r2 = -f*(d + c)\13\
\13\
\9\9local co2 = (v0 - offset*r1)/(2*f*c)\13\
\9\9local co1 = offset - co2\13\
\13\
\9\9local e1 = co1*math.exp(r1*dt)\13\
\9\9local e2 = co2*math.exp(r2*dt)\13\
\13\
\9\9p1 = e1 + e2 + g\13\
\9\9v1 = e1*r1 + e2*r2\13\
\9end\13\
\13\
\9local complete = math.abs(v1) < VELOCITY_THRESHOLD and math.abs(p1 - g) < POSITION_THRESHOLD\13\
\9\13\
\9return {\13\
\9\9complete = complete,\13\
\9\9value = complete and g or p1,\13\
\9\9velocity = v1,\13\
\9}\13\
end\13\
\13\
return Spring", '@'.."Orca.include.node_modules.flipper.src.Spring")) setfenv(fn, newEnv("Orca.include.node_modules.flipper.src.Spring")) return fn() end)

newModule("isMotor", "ModuleScript", "Orca.include.node_modules.flipper.src.isMotor", "Orca.include.node_modules.flipper.src", function () local fn = assert(loadstring("local function isMotor(value)\13\
\9local motorType = tostring(value):match(\"^Motor%((.+)%)$\")\13\
\13\
\9if motorType then\13\
\9\9return true, motorType\13\
\9else\13\
\9\9return false\13\
\9end\13\
end\13\
\13\
return isMotor", '@'.."Orca.include.node_modules.flipper.src.isMotor")) setfenv(fn, newEnv("Orca.include.node_modules.flipper.src.isMotor")) return fn() end)

newInstance("typings", "Folder", "Orca.include.node_modules.flipper.typings", "Orca.include.node_modules.flipper")

newModule("make", "ModuleScript", "Orca.include.node_modules.make", "Orca.include.node_modules", function () local fn = assert(loadstring("-- Compiled with roblox-ts v1.2.3\
--[[\
\9*\
\9* Returns a table wherein an object's writable properties can be specified,\
\9* while also allowing functions to be passed in which can be bound to a RBXScriptSignal.\
]]\
--[[\
\9*\
\9* Instantiates a new Instance of `className` with given `settings`,\
\9* where `settings` is an object of the form { [K: propertyName]: value }.\
\9*\
\9* `settings.Children` is an array of child objects to be parented to the generated Instance.\
\9*\
\9* Events can be set to a callback function, which will be connected.\
\9*\
\9* `settings.Parent` is always set last.\
]]\
local function Make(className, settings)\
\9local _binding = settings\
\9local children = _binding.Children\
\9local parent = _binding.Parent\
\9local instance = Instance.new(className)\
\9for setting, value in pairs(settings) do\
\9\9if setting ~= \"Children\" and setting ~= \"Parent\" then\
\9\9\9local _binding_1 = instance\
\9\9\9local prop = _binding_1[setting]\
\9\9\9if typeof(prop) == \"RBXScriptSignal\" then\
\9\9\9\9prop:Connect(value)\
\9\9\9else\
\9\9\9\9instance[setting] = value\
\9\9\9end\
\9\9end\
\9end\
\9if children then\
\9\9for _, child in ipairs(children) do\
\9\9\9child.Parent = instance\
\9\9end\
\9end\
\9instance.Parent = parent\
\9return instance\
end\
return Make\
", '@'.."Orca.include.node_modules.make")) setfenv(fn, newEnv("Orca.include.node_modules.make")) return fn() end)

newInstance("node_modules", "Folder", "Orca.include.node_modules.make.node_modules", "Orca.include.node_modules.make")

newInstance("@rbxts", "Folder", "Orca.include.node_modules.make.node_modules.@rbxts", "Orca.include.node_modules.make.node_modules")

newInstance("compiler-types", "Folder", "Orca.include.node_modules.make.node_modules.@rbxts.compiler-types", "Orca.include.node_modules.make.node_modules.@rbxts")

newInstance("types", "Folder", "Orca.include.node_modules.make.node_modules.@rbxts.compiler-types.types", "Orca.include.node_modules.make.node_modules.@rbxts.compiler-types")

newModule("object-utils", "ModuleScript", "Orca.include.node_modules.object-utils", "Orca.include.node_modules", function () local fn = assert(loadstring("local HttpService = game:GetService(\"HttpService\")\
\
local Object = {}\
\
function Object.keys(object)\
\9local result = table.create(#object)\
\9for key in pairs(object) do\
\9\9result[#result + 1] = key\
\9end\
\9return result\
end\
\
function Object.values(object)\
\9local result = table.create(#object)\
\9for _, value in pairs(object) do\
\9\9result[#result + 1] = value\
\9end\
\9return result\
end\
\
function Object.entries(object)\
\9local result = table.create(#object)\
\9for key, value in pairs(object) do\
\9\9result[#result + 1] = { key, value }\
\9end\
\9return result\
end\
\
function Object.assign(toObj, ...)\
\9for i = 1, select(\"#\", ...) do\
\9\9local arg = select(i, ...)\
\9\9if type(arg) == \"table\" then\
\9\9\9for key, value in pairs(arg) do\
\9\9\9\9toObj[key] = value\
\9\9\9end\
\9\9end\
\9end\
\9return toObj\
end\
\
function Object.copy(object)\
\9local result = table.create(#object)\
\9for k, v in pairs(object) do\
\9\9result[k] = v\
\9end\
\9return result\
end\
\
local function deepCopyHelper(object, encountered)\
\9local result = table.create(#object)\
\9encountered[object] = result\
\
\9for k, v in pairs(object) do\
\9\9if type(k) == \"table\" then\
\9\9\9k = encountered[k] or deepCopyHelper(k, encountered)\
\9\9end\
\
\9\9if type(v) == \"table\" then\
\9\9\9v = encountered[v] or deepCopyHelper(v, encountered)\
\9\9end\
\
\9\9result[k] = v\
\9end\
\
\9return result\
end\
\
function Object.deepCopy(object)\
\9return deepCopyHelper(object, {})\
end\
\
function Object.deepEquals(a, b)\
\9-- a[k] == b[k]\
\9for k in pairs(a) do\
\9\9local av = a[k]\
\9\9local bv = b[k]\
\9\9if type(av) == \"table\" and type(bv) == \"table\" then\
\9\9\9local result = Object.deepEquals(av, bv)\
\9\9\9if not result then\
\9\9\9\9return false\
\9\9\9end\
\9\9elseif av ~= bv then\
\9\9\9return false\
\9\9end\
\9end\
\
\9-- extra keys in b\
\9for k in pairs(b) do\
\9\9if a[k] == nil then\
\9\9\9return false\
\9\9end\
\9end\
\
\9return true\
end\
\
function Object.toString(data)\
\9return HttpService:JSONEncode(data)\
end\
\
function Object.isEmpty(object)\
\9return next(object) == nil\
end\
\
function Object.fromEntries(entries)\
\9local entriesLen = #entries\
\
\9local result = table.create(entriesLen)\
\9if entries then\
\9\9for i = 1, entriesLen do\
\9\9\9local pair = entries[i]\
\9\9\9result[pair[1]] = pair[2]\
\9\9end\
\9end\
\9return result\
end\
\
return Object\
", '@'.."Orca.include.node_modules.object-utils")) setfenv(fn, newEnv("Orca.include.node_modules.object-utils")) return fn() end)

newInstance("roact", "Folder", "Orca.include.node_modules.roact", "Orca.include.node_modules")

newModule("src", "ModuleScript", "Orca.include.node_modules.roact.src", "Orca.include.node_modules.roact", function () local fn = assert(loadstring("--[[\
\9Packages up the internals of Roact and exposes a public API for it.\
]]\
\
local GlobalConfig = require(script.GlobalConfig)\
local createReconciler = require(script.createReconciler)\
local createReconcilerCompat = require(script.createReconcilerCompat)\
local RobloxRenderer = require(script.RobloxRenderer)\
local strict = require(script.strict)\
local Binding = require(script.Binding)\
\
local robloxReconciler = createReconciler(RobloxRenderer)\
local reconcilerCompat = createReconcilerCompat(robloxReconciler)\
\
local Roact = strict {\
\9Component = require(script.Component),\
\9createElement = require(script.createElement),\
\9createFragment = require(script.createFragment),\
\9oneChild = require(script.oneChild),\
\9PureComponent = require(script.PureComponent),\
\9None = require(script.None),\
\9Portal = require(script.Portal),\
\9createRef = require(script.createRef),\
\9forwardRef = require(script.forwardRef),\
\9createBinding = Binding.create,\
\9joinBindings = Binding.join,\
\9createContext = require(script.createContext),\
\
\9Change = require(script.PropMarkers.Change),\
\9Children = require(script.PropMarkers.Children),\
\9Event = require(script.PropMarkers.Event),\
\9Ref = require(script.PropMarkers.Ref),\
\
\9mount = robloxReconciler.mountVirtualTree,\
\9unmount = robloxReconciler.unmountVirtualTree,\
\9update = robloxReconciler.updateVirtualTree,\
\
\9reify = reconcilerCompat.reify,\
\9teardown = reconcilerCompat.teardown,\
\9reconcile = reconcilerCompat.reconcile,\
\
\9setGlobalConfig = GlobalConfig.set,\
\
\9-- APIs that may change in the future without warning\
\9UNSTABLE = {\
\9},\
}\
\
return Roact", '@'.."Orca.include.node_modules.roact.src")) setfenv(fn, newEnv("Orca.include.node_modules.roact.src")) return fn() end)

newModule("Binding", "ModuleScript", "Orca.include.node_modules.roact.src.Binding", "Orca.include.node_modules.roact.src", function () local fn = assert(loadstring("local createSignal = require(script.Parent.createSignal)\
local Symbol = require(script.Parent.Symbol)\
local Type = require(script.Parent.Type)\
\
local config = require(script.Parent.GlobalConfig).get()\
\
local BindingImpl = Symbol.named(\"BindingImpl\")\
\
local BindingInternalApi = {}\
\
local bindingPrototype = {}\
\
function bindingPrototype:getValue()\
\9return BindingInternalApi.getValue(self)\
end\
\
function bindingPrototype:map(predicate)\
\9return BindingInternalApi.map(self, predicate)\
end\
\
local BindingPublicMeta = {\
\9__index = bindingPrototype,\
\9__tostring = function(self)\
\9\9return string.format(\"RoactBinding(%s)\", tostring(self:getValue()))\
\9end,\
}\
\
function BindingInternalApi.update(binding, newValue)\
\9return binding[BindingImpl].update(newValue)\
end\
\
function BindingInternalApi.subscribe(binding, callback)\
\9return binding[BindingImpl].subscribe(callback)\
end\
\
function BindingInternalApi.getValue(binding)\
\9return binding[BindingImpl].getValue()\
end\
\
function BindingInternalApi.create(initialValue)\
\9local impl = {\
\9\9value = initialValue,\
\9\9changeSignal = createSignal(),\
\9}\
\
\9function impl.subscribe(callback)\
\9\9return impl.changeSignal:subscribe(callback)\
\9end\
\
\9function impl.update(newValue)\
\9\9impl.value = newValue\
\9\9impl.changeSignal:fire(newValue)\
\9end\
\
\9function impl.getValue()\
\9\9return impl.value\
\9end\
\
\9return setmetatable({\
\9\9[Type] = Type.Binding,\
\9\9[BindingImpl] = impl,\
\9}, BindingPublicMeta), impl.update\
end\
\
function BindingInternalApi.map(upstreamBinding, predicate)\
\9if config.typeChecks then\
\9\9assert(Type.of(upstreamBinding) == Type.Binding, \"Expected arg #1 to be a binding\")\
\9\9assert(typeof(predicate) == \"function\", \"Expected arg #1 to be a function\")\
\9end\
\
\9local impl = {}\
\
\9function impl.subscribe(callback)\
\9\9return BindingInternalApi.subscribe(upstreamBinding, function(newValue)\
\9\9\9callback(predicate(newValue))\
\9\9end)\
\9end\
\
\9function impl.update(newValue)\
\9\9error(\"Bindings created by Binding:map(fn) cannot be updated directly\", 2)\
\9end\
\
\9function impl.getValue()\
\9\9return predicate(upstreamBinding:getValue())\
\9end\
\
\9return setmetatable({\
\9\9[Type] = Type.Binding,\
\9\9[BindingImpl] = impl,\
\9}, BindingPublicMeta)\
end\
\
function BindingInternalApi.join(upstreamBindings)\
\9if config.typeChecks then\
\9\9assert(typeof(upstreamBindings) == \"table\", \"Expected arg #1 to be of type table\")\
\
\9\9for key, value in pairs(upstreamBindings) do\
\9\9\9if Type.of(value) ~= Type.Binding then\
\9\9\9\9local message = (\
\9\9\9\9\9\"Expected arg #1 to contain only bindings, but key %q had a non-binding value\"\
\9\9\9\9):format(\
\9\9\9\9\9tostring(key)\
\9\9\9\9)\
\9\9\9\9error(message, 2)\
\9\9\9end\
\9\9end\
\9end\
\
\9local impl = {}\
\
\9local function getValue()\
\9\9local value = {}\
\
\9\9for key, upstream in pairs(upstreamBindings) do\
\9\9\9value[key] = upstream:getValue()\
\9\9end\
\
\9\9return value\
\9end\
\
\9function impl.subscribe(callback)\
\9\9local disconnects = {}\
\
\9\9for key, upstream in pairs(upstreamBindings) do\
\9\9\9disconnects[key] = BindingInternalApi.subscribe(upstream, function(newValue)\
\9\9\9\9callback(getValue())\
\9\9\9end)\
\9\9end\
\
\9\9return function()\
\9\9\9if disconnects == nil then\
\9\9\9\9return\
\9\9\9end\
\
\9\9\9for _, disconnect in pairs(disconnects) do\
\9\9\9\9disconnect()\
\9\9\9end\
\
\9\9\9disconnects = nil\
\9\9end\
\9end\
\
\9function impl.update(newValue)\
\9\9error(\"Bindings created by joinBindings(...) cannot be updated directly\", 2)\
\9end\
\
\9function impl.getValue()\
\9\9return getValue()\
\9end\
\
\9return setmetatable({\
\9\9[Type] = Type.Binding,\
\9\9[BindingImpl] = impl,\
\9}, BindingPublicMeta)\
end\
\
return BindingInternalApi", '@'.."Orca.include.node_modules.roact.src.Binding")) setfenv(fn, newEnv("Orca.include.node_modules.roact.src.Binding")) return fn() end)

newModule("Component", "ModuleScript", "Orca.include.node_modules.roact.src.Component", "Orca.include.node_modules.roact.src", function () local fn = assert(loadstring("local assign = require(script.Parent.assign)\
local ComponentLifecyclePhase = require(script.Parent.ComponentLifecyclePhase)\
local Type = require(script.Parent.Type)\
local Symbol = require(script.Parent.Symbol)\
local invalidSetStateMessages = require(script.Parent.invalidSetStateMessages)\
local internalAssert = require(script.Parent.internalAssert)\
\
local config = require(script.Parent.GlobalConfig).get()\
\
--[[\
\9Calling setState during certain lifecycle allowed methods has the potential\
\9to create an infinitely updating component. Rather than time out, we exit\
\9with an error if an unreasonable number of self-triggering updates occur\
]]\
local MAX_PENDING_UPDATES = 100\
\
local InternalData = Symbol.named(\"InternalData\")\
\
local componentMissingRenderMessage = [[\
The component %q is missing the `render` method.\
`render` must be defined when creating a Roact component!]]\
\
local tooManyUpdatesMessage = [[\
The component %q has reached the setState update recursion limit.\
When using `setState` in `didUpdate`, make sure that it won't repeat infinitely!]]\
\
local componentClassMetatable = {}\
\
function componentClassMetatable:__tostring()\
\9return self.__componentName\
end\
\
local Component = {}\
setmetatable(Component, componentClassMetatable)\
\
Component[Type] = Type.StatefulComponentClass\
Component.__index = Component\
Component.__componentName = \"Component\"\
\
--[[\
\9A method called by consumers of Roact to create a new component class.\
\9Components can not be extended beyond this point, with the exception of\
\9PureComponent.\
]]\
function Component:extend(name)\
\9if config.typeChecks then\
\9\9assert(Type.of(self) == Type.StatefulComponentClass, \"Invalid `self` argument to `extend`.\")\
\9\9assert(typeof(name) == \"string\", \"Component class name must be a string\")\
\9end\
\
\9local class = {}\
\
\9for key, value in pairs(self) do\
\9\9-- Roact opts to make consumers use composition over inheritance, which\
\9\9-- lines up with React.\
\9\9-- https://reactjs.org/docs/composition-vs-inheritance.html\
\9\9if key ~= \"extend\" then\
\9\9\9class[key] = value\
\9\9end\
\9end\
\
\9class[Type] = Type.StatefulComponentClass\
\9class.__index = class\
\9class.__componentName = name\
\
\9setmetatable(class, componentClassMetatable)\
\
\9return class\
end\
\
function Component:__getDerivedState(incomingProps, incomingState)\
\9if config.internalTypeChecks then\
\9\9internalAssert(Type.of(self) == Type.StatefulComponentInstance, \"Invalid use of `__getDerivedState`\")\
\9end\
\
\9local internalData = self[InternalData]\
\9local componentClass = internalData.componentClass\
\
\9if componentClass.getDerivedStateFromProps ~= nil then\
\9\9local derivedState = componentClass.getDerivedStateFromProps(incomingProps, incomingState)\
\
\9\9if derivedState ~= nil then\
\9\9\9if config.typeChecks then\
\9\9\9\9assert(typeof(derivedState) == \"table\", \"getDerivedStateFromProps must return a table!\")\
\9\9\9end\
\
\9\9\9return derivedState\
\9\9end\
\9end\
\
\9return nil\
end\
\
function Component:setState(mapState)\
\9if config.typeChecks then\
\9\9assert(Type.of(self) == Type.StatefulComponentInstance, \"Invalid `self` argument to `extend`.\")\
\9end\
\
\9local internalData = self[InternalData]\
\9local lifecyclePhase = internalData.lifecyclePhase\
\
\9--[[\
\9\9When preparing to update, rendering, or unmounting, it is not safe\
\9\9to call `setState` as it will interfere with in-flight updates. It's\
\9\9also disallowed during unmounting\
\9]]\
\9if lifecyclePhase == ComponentLifecyclePhase.ShouldUpdate or\
\9\9lifecyclePhase == ComponentLifecyclePhase.WillUpdate or\
\9\9lifecyclePhase == ComponentLifecyclePhase.Render or\
\9\9lifecyclePhase == ComponentLifecyclePhase.WillUnmount\
\9then\
\9\9local messageTemplate = invalidSetStateMessages[internalData.lifecyclePhase]\
\
\9\9local message = messageTemplate:format(tostring(internalData.componentClass))\
\
\9\9error(message, 2)\
\9end\
\
\9local pendingState = internalData.pendingState\
\
\9local partialState\
\9if typeof(mapState) == \"function\" then\
\9\9partialState = mapState(pendingState or self.state, self.props)\
\
\9\9-- Abort the state update if the given state updater function returns nil\
\9\9if partialState == nil then\
\9\9\9return\
\9\9end\
\9elseif typeof(mapState) == \"table\" then\
\9\9partialState = mapState\
\9else\
\9\9error(\"Invalid argument to setState, expected function or table\", 2)\
\9end\
\
\9local newState\
\9if pendingState ~= nil then\
\9\9newState = assign(pendingState, partialState)\
\9else\
\9\9newState = assign({}, self.state, partialState)\
\9end\
\
\9if lifecyclePhase == ComponentLifecyclePhase.Init then\
\9\9-- If `setState` is called in `init`, we can skip triggering an update!\
\9\9local derivedState = self:__getDerivedState(self.props, newState)\
\9\9self.state = assign(newState, derivedState)\
\
\9elseif lifecyclePhase == ComponentLifecyclePhase.DidMount or\
\9\9lifecyclePhase == ComponentLifecyclePhase.DidUpdate or\
\9\9lifecyclePhase == ComponentLifecyclePhase.ReconcileChildren\
\9then\
\9\9--[[\
\9\9\9During certain phases of the component lifecycle, it's acceptable to\
\9\9\9allow `setState` but defer the update until we're done with ones in flight.\
\9\9\9We do this by collapsing it into any pending updates we have.\
\9\9]]\
\9\9local derivedState = self:__getDerivedState(self.props, newState)\
\9\9internalData.pendingState = assign(newState, derivedState)\
\
\9elseif lifecyclePhase == ComponentLifecyclePhase.Idle then\
\9\9-- Pause parent events when we are updated outside of our lifecycle\
\9\9-- If these events are not paused, our setState can cause a component higher up the\
\9\9-- tree to rerender based on events caused by our component while this reconciliation is happening.\
\9\9-- This could cause the tree to become invalid.\
\9\9local virtualNode = internalData.virtualNode\
\9\9local reconciler = internalData.reconciler\
\9\9if config.tempFixUpdateChildrenReEntrancy then\
\9\9\9reconciler.suspendParentEvents(virtualNode)\
\9\9end\
\
\9\9-- Outside of our lifecycle, the state update is safe to make immediately\
\9\9self:__update(nil, newState)\
\
\9\9if config.tempFixUpdateChildrenReEntrancy then\
\9\9\9reconciler.resumeParentEvents(virtualNode)\
\9\9end\
\9else\
\9\9local messageTemplate = invalidSetStateMessages.default\
\
\9\9local message = messageTemplate:format(tostring(internalData.componentClass))\
\
\9\9error(message, 2)\
\9end\
end\
\
--[[\
\9Returns the stack trace of where the element was created that this component\
\9instance's properties are based on.\
\
\9Intended to be used primarily by diagnostic tools.\
]]\
function Component:getElementTraceback()\
\9return self[InternalData].virtualNode.currentElement.source\
end\
\
--[[\
\9Returns a snapshot of this component given the current props and state. Must\
\9be overridden by consumers of Roact and should be a pure function with\
\9regards to props and state.\
\
\9TODO (#199): Accept props and state as arguments.\
]]\
function Component:render()\
\9local internalData = self[InternalData]\
\
\9local message = componentMissingRenderMessage:format(\
\9\9tostring(internalData.componentClass)\
\9)\
\
\9error(message, 0)\
end\
\
--[[\
\9Retrieves the context value corresponding to the given key. Can return nil\
\9if a requested context key is not present\
]]\
function Component:__getContext(key)\
\9if config.internalTypeChecks then\
\9\9internalAssert(Type.of(self) == Type.StatefulComponentInstance, \"Invalid use of `__getContext`\")\
\9\9internalAssert(key ~= nil, \"Context key cannot be nil\")\
\9end\
\
\9local virtualNode = self[InternalData].virtualNode\
\9local context = virtualNode.context\
\
\9return context[key]\
end\
\
--[[\
\9Adds a new context entry to this component's context table (which will be\
\9passed down to child components).\
]]\
function Component:__addContext(key, value)\
\9if config.internalTypeChecks then\
\9\9internalAssert(Type.of(self) == Type.StatefulComponentInstance, \"Invalid use of `__addContext`\")\
\9end\
\9local virtualNode = self[InternalData].virtualNode\
\
\9-- Make sure we store a reference to the component's original, unmodified\
\9-- context the virtual node. In the reconciler, we'll restore the original\
\9-- context if we need to replace the node (this happens when a node gets\
\9-- re-rendered as a different component)\
\9if virtualNode.originalContext == nil then\
\9\9virtualNode.originalContext = virtualNode.context\
\9end\
\
\9-- Build a new context table on top of the existing one, then apply it to\
\9-- our virtualNode\
\9local existing = virtualNode.context\
\9virtualNode.context = assign({}, existing, { [key] = value })\
end\
\
--[[\
\9Performs property validation if the static method validateProps is declared.\
\9validateProps should follow assert's expected arguments:\
\9(false, message: string) | true. The function may return a message in the\
\9true case; it will be ignored. If this fails, the function will throw the\
\9error.\
]]\
function Component:__validateProps(props)\
\9if not config.propValidation then\
\9\9return\
\9end\
\
\9local validator = self[InternalData].componentClass.validateProps\
\
\9if validator == nil then\
\9\9return\
\9end\
\
\9if typeof(validator) ~= \"function\" then\
\9\9error((\"validateProps must be a function, but it is a %s.\\nCheck the definition of the component %q.\"):format(\
\9\9\9typeof(validator),\
\9\9\9self.__componentName\
\9\9))\
\9end\
\
\9local success, failureReason = validator(props)\
\
\9if not success then\
\9\9failureReason = failureReason or \"<Validator function did not supply a message>\"\
\9\9error((\"Property validation failed in %s: %s\\n\\n%s\"):format(\
\9\9\9self.__componentName,\
\9\9\9tostring(failureReason),\
\9\9\9self:getElementTraceback() or \"<enable element tracebacks>\"),\
\9\0090)\
\9end\
end\
\
--[[\
\9An internal method used by the reconciler to construct a new component\
\9instance and attach it to the given virtualNode.\
]]\
function Component:__mount(reconciler, virtualNode)\
\9if config.internalTypeChecks then\
\9\9internalAssert(Type.of(self) == Type.StatefulComponentClass, \"Invalid use of `__mount`\")\
\9\9internalAssert(Type.of(virtualNode) == Type.VirtualNode, \"Expected arg #2 to be of type VirtualNode\")\
\9end\
\
\9local currentElement = virtualNode.currentElement\
\9local hostParent = virtualNode.hostParent\
\
\9-- Contains all the information that we want to keep from consumers of\
\9-- Roact, or even other parts of the codebase like the reconciler.\
\9local internalData = {\
\9\9reconciler = reconciler,\
\9\9virtualNode = virtualNode,\
\9\9componentClass = self,\
\9\9lifecyclePhase = ComponentLifecyclePhase.Init,\
\9}\
\
\9local instance = {\
\9\9[Type] = Type.StatefulComponentInstance,\
\9\9[InternalData] = internalData,\
\9}\
\
\9setmetatable(instance, self)\
\
\9virtualNode.instance = instance\
\
\9local props = currentElement.props\
\
\9if self.defaultProps ~= nil then\
\9\9props = assign({}, self.defaultProps, props)\
\9end\
\
\9instance:__validateProps(props)\
\
\9instance.props = props\
\
\9local newContext = assign({}, virtualNode.legacyContext)\
\9instance._context = newContext\
\
\9instance.state = assign({}, instance:__getDerivedState(instance.props, {}))\
\
\9if instance.init ~= nil then\
\9\9instance:init(instance.props)\
\9\9assign(instance.state, instance:__getDerivedState(instance.props, instance.state))\
\9end\
\
\9-- It's possible for init() to redefine _context!\
\9virtualNode.legacyContext = instance._context\
\
\9internalData.lifecyclePhase = ComponentLifecyclePhase.Render\
\9local renderResult = instance:render()\
\
\9internalData.lifecyclePhase = ComponentLifecyclePhase.ReconcileChildren\
\9reconciler.updateVirtualNodeWithRenderResult(virtualNode, hostParent, renderResult)\
\
\9if instance.didMount ~= nil then\
\9\9internalData.lifecyclePhase = ComponentLifecyclePhase.DidMount\
\9\9instance:didMount()\
\9end\
\
\9if internalData.pendingState ~= nil then\
\9\9-- __update will handle pendingState, so we don't pass any new element or state\
\9\9instance:__update(nil, nil)\
\9end\
\
\9internalData.lifecyclePhase = ComponentLifecyclePhase.Idle\
end\
\
--[[\
\9Internal method used by the reconciler to clean up any resources held by\
\9this component instance.\
]]\
function Component:__unmount()\
\9if config.internalTypeChecks then\
\9\9internalAssert(Type.of(self) == Type.StatefulComponentInstance, \"Invalid use of `__unmount`\")\
\9end\
\
\9local internalData = self[InternalData]\
\9local virtualNode = internalData.virtualNode\
\9local reconciler = internalData.reconciler\
\
\9if self.willUnmount ~= nil then\
\9\9internalData.lifecyclePhase = ComponentLifecyclePhase.WillUnmount\
\9\9self:willUnmount()\
\9end\
\
\9for _, childNode in pairs(virtualNode.children) do\
\9\9reconciler.unmountVirtualNode(childNode)\
\9end\
end\
\
--[[\
\9Internal method used by setState (to trigger updates based on state) and by\
\9the reconciler (to trigger updates based on props)\
\
\9Returns true if the update was completed, false if it was cancelled by shouldUpdate\
]]\
function Component:__update(updatedElement, updatedState)\
\9if config.internalTypeChecks then\
\9\9internalAssert(Type.of(self) == Type.StatefulComponentInstance, \"Invalid use of `__update`\")\
\9\9internalAssert(\
\9\9\9Type.of(updatedElement) == Type.Element or updatedElement == nil,\
\9\9\9\"Expected arg #1 to be of type Element or nil\"\
\9\9)\
\9\9internalAssert(\
\9\9\9typeof(updatedState) == \"table\" or updatedState == nil,\
\9\9\9\"Expected arg #2 to be of type table or nil\"\
\9\9)\
\9end\
\
\9local internalData = self[InternalData]\
\9local componentClass = internalData.componentClass\
\
\9local newProps = self.props\
\9if updatedElement ~= nil then\
\9\9newProps = updatedElement.props\
\
\9\9if componentClass.defaultProps ~= nil then\
\9\9\9newProps = assign({}, componentClass.defaultProps, newProps)\
\9\9end\
\
\9\9self:__validateProps(newProps)\
\9end\
\
\9local updateCount = 0\
\9repeat\
\9\9local finalState\
\9\9local pendingState = nil\
\
\9\9-- Consume any pending state we might have\
\9\9if internalData.pendingState ~= nil then\
\9\9\9pendingState = internalData.pendingState\
\9\9\9internalData.pendingState = nil\
\9\9end\
\
\9\9-- Consume a standard update to state or props\
\9\9if updatedState ~= nil or newProps ~= self.props then\
\9\9\9if pendingState == nil then\
\9\9\9\9finalState = updatedState or self.state\
\9\9\9else\
\9\9\9\9finalState = assign(pendingState, updatedState)\
\9\9\9end\
\
\9\9\9local derivedState = self:__getDerivedState(newProps, finalState)\
\
\9\9\9if derivedState ~= nil then\
\9\9\9\9finalState = assign({}, finalState, derivedState)\
\9\9\9end\
\
\9\9\9updatedState = nil\
\9\9else\
\9\9\9finalState = pendingState\
\9\9end\
\
\9\9if not self:__resolveUpdate(newProps, finalState) then\
\9\9\9-- If the update was short-circuited, bubble the result up to the caller\
\9\9\9return false\
\9\9end\
\
\9\9updateCount = updateCount + 1\
\
\9\9if updateCount > MAX_PENDING_UPDATES then\
\9\9\9error(tooManyUpdatesMessage:format(tostring(internalData.componentClass)), 3)\
\9\9end\
\9until internalData.pendingState == nil\
\
\9return true\
end\
\
--[[\
\9Internal method used by __update to apply new props and state\
\
\9Returns true if the update was completed, false if it was cancelled by shouldUpdate\
]]\
function Component:__resolveUpdate(incomingProps, incomingState)\
\9if config.internalTypeChecks then\
\9\9internalAssert(Type.of(self) == Type.StatefulComponentInstance, \"Invalid use of `__resolveUpdate`\")\
\9end\
\
\9local internalData = self[InternalData]\
\9local virtualNode = internalData.virtualNode\
\9local reconciler = internalData.reconciler\
\
\9local oldProps = self.props\
\9local oldState = self.state\
\
\9if incomingProps == nil then\
\9\9incomingProps = oldProps\
\9end\
\9if incomingState == nil then\
\9\9incomingState = oldState\
\9end\
\
\9if self.shouldUpdate ~= nil then\
\9\9internalData.lifecyclePhase = ComponentLifecyclePhase.ShouldUpdate\
\9\9local continueWithUpdate = self:shouldUpdate(incomingProps, incomingState)\
\
\9\9if not continueWithUpdate then\
\9\9\9internalData.lifecyclePhase = ComponentLifecyclePhase.Idle\
\9\9\9return false\
\9\9end\
\9end\
\
\9if self.willUpdate ~= nil then\
\9\9internalData.lifecyclePhase = ComponentLifecyclePhase.WillUpdate\
\9\9self:willUpdate(incomingProps, incomingState)\
\9end\
\
\9internalData.lifecyclePhase = ComponentLifecyclePhase.Render\
\
\9self.props = incomingProps\
\9self.state = incomingState\
\
\9local renderResult = virtualNode.instance:render()\
\
\9internalData.lifecyclePhase = ComponentLifecyclePhase.ReconcileChildren\
\9reconciler.updateVirtualNodeWithRenderResult(virtualNode, virtualNode.hostParent, renderResult)\
\
\9if self.didUpdate ~= nil then\
\9\9internalData.lifecyclePhase = ComponentLifecyclePhase.DidUpdate\
\9\9self:didUpdate(oldProps, oldState)\
\9end\
\
\9internalData.lifecyclePhase = ComponentLifecyclePhase.Idle\
\9return true\
end\
\
return Component", '@'.."Orca.include.node_modules.roact.src.Component")) setfenv(fn, newEnv("Orca.include.node_modules.roact.src.Component")) return fn() end)

newModule("ComponentLifecyclePhase", "ModuleScript", "Orca.include.node_modules.roact.src.ComponentLifecyclePhase", "Orca.include.node_modules.roact.src", function () local fn = assert(loadstring("local Symbol = require(script.Parent.Symbol)\
local strict = require(script.Parent.strict)\
\
local ComponentLifecyclePhase = strict({\
\9-- Component methods\
\9Init = Symbol.named(\"init\"),\
\9Render = Symbol.named(\"render\"),\
\9ShouldUpdate = Symbol.named(\"shouldUpdate\"),\
\9WillUpdate = Symbol.named(\"willUpdate\"),\
\9DidMount = Symbol.named(\"didMount\"),\
\9DidUpdate = Symbol.named(\"didUpdate\"),\
\9WillUnmount = Symbol.named(\"willUnmount\"),\
\
\9-- Phases describing reconciliation status\
\9ReconcileChildren = Symbol.named(\"reconcileChildren\"),\
\9Idle = Symbol.named(\"idle\"),\
}, \"ComponentLifecyclePhase\")\
\
return ComponentLifecyclePhase", '@'.."Orca.include.node_modules.roact.src.ComponentLifecyclePhase")) setfenv(fn, newEnv("Orca.include.node_modules.roact.src.ComponentLifecyclePhase")) return fn() end)

newModule("Config", "ModuleScript", "Orca.include.node_modules.roact.src.Config", "Orca.include.node_modules.roact.src", function () local fn = assert(loadstring("--[[\
\9Exposes an interface to set global configuration values for Roact.\
\
\9Configuration can only occur once, and should only be done by an application\
\9using Roact, not a library.\
\
\9Any keys that aren't recognized will cause errors. Configuration is only\
\9intended for configuring Roact itself, not extensions or libraries.\
\
\9Configuration is expected to be set immediately after loading Roact. Setting\
\9configuration values after an application starts may produce unpredictable\
\9behavior.\
]]\
\
-- Every valid configuration value should be non-nil in this table.\
local defaultConfig = {\
\9-- Enables asserts for internal Roact APIs. Useful for debugging Roact itself.\
\9[\"internalTypeChecks\"] = false,\
\9-- Enables stricter type asserts for Roact's public API.\
\9[\"typeChecks\"] = false,\
\9-- Enables storage of `debug.traceback()` values on elements for debugging.\
\9[\"elementTracing\"] = false,\
\9-- Enables validation of component props in stateful components.\
\9[\"propValidation\"] = false,\
\
\9-- Temporary config for enabling a bug fix for processing events based on updates to child instances\
\9-- outside of the standard lifecycle.\
\9[\"tempFixUpdateChildrenReEntrancy\"] = false,\
}\
\
-- Build a list of valid configuration values up for debug messages.\
local defaultConfigKeys = {}\
for key in pairs(defaultConfig) do\
\9table.insert(defaultConfigKeys, key)\
end\
\
local Config = {}\
\
function Config.new()\
\9local self = {}\
\
\9self._currentConfig = setmetatable({}, {\
\9\9__index = function(_, key)\
\9\9\9local message = (\
\9\9\9\9\"Invalid global configuration key %q. Valid configuration keys are: %s\"\
\9\9\9):format(\
\9\9\9\9tostring(key),\
\9\9\9\9table.concat(defaultConfigKeys, \", \")\
\9\9\9)\
\
\9\9\9error(message, 3)\
\9\9end\
\9})\
\
\9-- We manually bind these methods here so that the Config's methods can be\
\9-- used without passing in self, since they eventually get exposed on the\
\9-- root Roact object.\
\9self.set = function(...)\
\9\9return Config.set(self, ...)\
\9end\
\
\9self.get = function(...)\
\9\9return Config.get(self, ...)\
\9end\
\
\9self.scoped = function(...)\
\9\9return Config.scoped(self, ...)\
\9end\
\
\9self.set(defaultConfig)\
\
\9return self\
end\
\
function Config:set(configValues)\
\9-- Validate values without changing any configuration.\
\9-- We only want to apply this configuration if it's valid!\
\9for key, value in pairs(configValues) do\
\9\9if defaultConfig[key] == nil then\
\9\9\9local message = (\
\9\9\9\9\"Invalid global configuration key %q (type %s). Valid configuration keys are: %s\"\
\9\9\9):format(\
\9\9\9\9tostring(key),\
\9\9\9\9typeof(key),\
\9\9\9\9table.concat(defaultConfigKeys, \", \")\
\9\9\9)\
\
\9\9\9error(message, 3)\
\9\9end\
\
\9\9-- Right now, all configuration values must be boolean.\
\9\9if typeof(value) ~= \"boolean\" then\
\9\9\9local message = (\
\9\9\9\9\"Invalid value %q (type %s) for global configuration key %q. Valid values are: true, false\"\
\9\9\9):format(\
\9\9\9\9tostring(value),\
\9\9\9\9typeof(value),\
\9\9\9\9tostring(key)\
\9\9\9)\
\
\9\9\9error(message, 3)\
\9\9end\
\
\9\9self._currentConfig[key] = value\
\9end\
end\
\
function Config:get()\
\9return self._currentConfig\
end\
\
function Config:scoped(configValues, callback)\
\9local previousValues = {}\
\9for key, value in pairs(self._currentConfig) do\
\9\9previousValues[key] = value\
\9end\
\
\9self.set(configValues)\
\
\9local success, result = pcall(callback)\
\
\9self.set(previousValues)\
\
\9assert(success, result)\
end\
\
return Config", '@'.."Orca.include.node_modules.roact.src.Config")) setfenv(fn, newEnv("Orca.include.node_modules.roact.src.Config")) return fn() end)

newModule("ElementKind", "ModuleScript", "Orca.include.node_modules.roact.src.ElementKind", "Orca.include.node_modules.roact.src", function () local fn = assert(loadstring("--[[\
\9Contains markers for annotating the type of an element.\
\
\9Use `ElementKind` as a key, and values from it as the value.\
\
\9\9local element = {\
\9\9\9[ElementKind] = ElementKind.Host,\
\9\9}\
]]\
\
local Symbol = require(script.Parent.Symbol)\
local strict = require(script.Parent.strict)\
local Portal = require(script.Parent.Portal)\
\
local ElementKind = newproxy(true)\
\
local ElementKindInternal = {\
\9Portal = Symbol.named(\"Portal\"),\
\9Host = Symbol.named(\"Host\"),\
\9Function = Symbol.named(\"Function\"),\
\9Stateful = Symbol.named(\"Stateful\"),\
\9Fragment = Symbol.named(\"Fragment\"),\
}\
\
function ElementKindInternal.of(value)\
\9if typeof(value) ~= \"table\" then\
\9\9return nil\
\9end\
\
\9return value[ElementKind]\
end\
\
local componentTypesToKinds = {\
\9[\"string\"] = ElementKindInternal.Host,\
\9[\"function\"] = ElementKindInternal.Function,\
\9[\"table\"] = ElementKindInternal.Stateful,\
}\
\
function ElementKindInternal.fromComponent(component)\
\9if component == Portal then\
\9\9return ElementKind.Portal\
\9else\
\9\9return componentTypesToKinds[typeof(component)]\
\9end\
end\
\
getmetatable(ElementKind).__index = ElementKindInternal\
\
strict(ElementKindInternal, \"ElementKind\")\
\
return ElementKind", '@'.."Orca.include.node_modules.roact.src.ElementKind")) setfenv(fn, newEnv("Orca.include.node_modules.roact.src.ElementKind")) return fn() end)

newModule("ElementUtils", "ModuleScript", "Orca.include.node_modules.roact.src.ElementUtils", "Orca.include.node_modules.roact.src", function () local fn = assert(loadstring("local Type = require(script.Parent.Type)\
local Symbol = require(script.Parent.Symbol)\
\
local function noop()\
\9return nil\
end\
\
local ElementUtils = {}\
\
--[[\
\9A signal value indicating that a child should use its parent's key, because\
\9it has no key of its own.\
\
\9This occurs when you return only one element from a function component or\
\9stateful render function.\
]]\
ElementUtils.UseParentKey = Symbol.named(\"UseParentKey\")\
\
--[[\
\9Returns an iterator over the children of an element.\
\9`elementOrElements` may be one of:\
\9* a boolean\
\9* nil\
\9* a single element\
\9* a fragment\
\9* a table of elements\
\
\9If `elementOrElements` is a boolean or nil, this will return an iterator with\
\9zero elements.\
\
\9If `elementOrElements` is a single element, this will return an iterator with\
\9one element: a tuple where the first value is ElementUtils.UseParentKey, and\
\9the second is the value of `elementOrElements`.\
\
\9If `elementOrElements` is a fragment or a table, this will return an iterator\
\9over all the elements of the array.\
\
\9If `elementOrElements` is none of the above, this function will throw.\
]]\
function ElementUtils.iterateElements(elementOrElements)\
\9local richType = Type.of(elementOrElements)\
\
\9-- Single child\
\9if richType == Type.Element then\
\9\9local called = false\
\
\9\9return function()\
\9\9\9if called then\
\9\9\9\9return nil\
\9\9\9else\
\9\9\9\9called = true\
\9\9\9\9return ElementUtils.UseParentKey, elementOrElements\
\9\9\9end\
\9\9end\
\9end\
\
\9local regularType = typeof(elementOrElements)\
\
\9if elementOrElements == nil or regularType == \"boolean\" then\
\9\9return noop\
\9end\
\
\9if regularType == \"table\" then\
\9\9return pairs(elementOrElements)\
\9end\
\
\9error(\"Invalid elements\")\
end\
\
--[[\
\9Gets the child corresponding to a given key, respecting Roact's rules for\
\9children. Specifically:\
\9* If `elements` is nil or a boolean, this will return `nil`, regardless of\
\9\9the key given.\
\9* If `elements` is a single element, this will return `nil`, unless the key\
\9\9is ElementUtils.UseParentKey.\
\9* If `elements` is a table of elements, this will return `elements[key]`.\
]]\
function ElementUtils.getElementByKey(elements, hostKey)\
\9if elements == nil or typeof(elements) == \"boolean\" then\
\9\9return nil\
\9end\
\
\9if Type.of(elements) == Type.Element then\
\9\9if hostKey == ElementUtils.UseParentKey then\
\9\9\9return elements\
\9\9end\
\
\9\9return nil\
\9end\
\
\9if typeof(elements) == \"table\" then\
\9\9return elements[hostKey]\
\9end\
\
\9error(\"Invalid elements\")\
end\
\
return ElementUtils", '@'.."Orca.include.node_modules.roact.src.ElementUtils")) setfenv(fn, newEnv("Orca.include.node_modules.roact.src.ElementUtils")) return fn() end)

newModule("GlobalConfig", "ModuleScript", "Orca.include.node_modules.roact.src.GlobalConfig", "Orca.include.node_modules.roact.src", function () local fn = assert(loadstring("--[[\
\9Exposes a single instance of a configuration as Roact's GlobalConfig.\
]]\
\
local Config = require(script.Parent.Config)\
\
return Config.new()", '@'.."Orca.include.node_modules.roact.src.GlobalConfig")) setfenv(fn, newEnv("Orca.include.node_modules.roact.src.GlobalConfig")) return fn() end)

newModule("Logging", "ModuleScript", "Orca.include.node_modules.roact.src.Logging", "Orca.include.node_modules.roact.src", function () local fn = assert(loadstring("--[[\
\9Centralized place to handle logging. Lets us:\
\9- Unit test log output via `Logging.capture`\
\9- Disable verbose log messages when not debugging Roact\
\
\9This should be broken out into a separate library with the addition of\
\9scoping and logging configuration.\
]]\
\
-- Determines whether log messages will go to stdout/stderr\
local outputEnabled = true\
\
-- A set of LogInfo objects that should have messages inserted into them.\
-- This is a set so that nested calls to Logging.capture will behave.\
local collectors = {}\
\
-- A set of all stack traces that have called warnOnce.\
local onceUsedLocations = {}\
\
--[[\
\9Indent a potentially multi-line string with the given number of tabs, in\
\9addition to any indentation the string already has.\
]]\
local function indent(source, indentLevel)\
\9local indentString = (\"\\t\"):rep(indentLevel)\
\
\9return indentString .. source:gsub(\"\\n\", \"\\n\" .. indentString)\
end\
\
--[[\
\9Indents a list of strings and then concatenates them together with newlines\
\9into a single string.\
]]\
local function indentLines(lines, indentLevel)\
\9local outputBuffer = {}\
\
\9for _, line in ipairs(lines) do\
\9\9table.insert(outputBuffer, indent(line, indentLevel))\
\9end\
\
\9return table.concat(outputBuffer, \"\\n\")\
end\
\
local logInfoMetatable = {}\
\
--[[\
\9Automatic coercion to strings for LogInfo objects to enable debugging them\
\9more easily.\
]]\
function logInfoMetatable:__tostring()\
\9local outputBuffer = {\"LogInfo {\"}\
\
\9local errorCount = #self.errors\
\9local warningCount = #self.warnings\
\9local infosCount = #self.infos\
\
\9if errorCount + warningCount + infosCount == 0 then\
\9\9table.insert(outputBuffer, \"\\t(no messages)\")\
\9end\
\
\9if errorCount > 0 then\
\9\9table.insert(outputBuffer, (\"\\tErrors (%d) {\"):format(errorCount))\
\9\9table.insert(outputBuffer, indentLines(self.errors, 2))\
\9\9table.insert(outputBuffer, \"\\t}\")\
\9end\
\
\9if warningCount > 0 then\
\9\9table.insert(outputBuffer, (\"\\tWarnings (%d) {\"):format(warningCount))\
\9\9table.insert(outputBuffer, indentLines(self.warnings, 2))\
\9\9table.insert(outputBuffer, \"\\t}\")\
\9end\
\
\9if infosCount > 0 then\
\9\9table.insert(outputBuffer, (\"\\tInfos (%d) {\"):format(infosCount))\
\9\9table.insert(outputBuffer, indentLines(self.infos, 2))\
\9\9table.insert(outputBuffer, \"\\t}\")\
\9end\
\
\9table.insert(outputBuffer, \"}\")\
\
\9return table.concat(outputBuffer, \"\\n\")\
end\
\
local function createLogInfo()\
\9local logInfo = {\
\9\9errors = {},\
\9\9warnings = {},\
\9\9infos = {},\
\9}\
\
\9setmetatable(logInfo, logInfoMetatable)\
\
\9return logInfo\
end\
\
local Logging = {}\
\
--[[\
\9Invokes `callback`, capturing all output that happens during its execution.\
\
\9Output will not go to stdout or stderr and will instead be put into a\
\9LogInfo object that is returned. If `callback` throws, the error will be\
\9bubbled up to the caller of `Logging.capture`.\
]]\
function Logging.capture(callback)\
\9local collector = createLogInfo()\
\
\9local wasOutputEnabled = outputEnabled\
\9outputEnabled = false\
\9collectors[collector] = true\
\
\9local success, result = pcall(callback)\
\
\9collectors[collector] = nil\
\9outputEnabled = wasOutputEnabled\
\
\9assert(success, result)\
\
\9return collector\
end\
\
--[[\
\9Issues a warning with an automatically attached stack trace.\
]]\
function Logging.warn(messageTemplate, ...)\
\9local message = messageTemplate:format(...)\
\
\9for collector in pairs(collectors) do\
\9\9table.insert(collector.warnings, message)\
\9end\
\
\9-- debug.traceback inserts a leading newline, so we trim it here\
\9local trace = debug.traceback(\"\", 2):sub(2)\
\9local fullMessage = (\"%s\\n%s\"):format(message, indent(trace, 1))\
\
\9if outputEnabled then\
\9\9warn(fullMessage)\
\9end\
end\
\
--[[\
\9Issues a warning like `Logging.warn`, but only outputs once per call site.\
\
\9This is useful for marking deprecated functions that might be called a lot;\
\9using `warnOnce` instead of `warn` will reduce output noise while still\
\9correctly marking all call sites.\
]]\
function Logging.warnOnce(messageTemplate, ...)\
\9local trace = debug.traceback()\
\
\9if onceUsedLocations[trace] then\
\9\9return\
\9end\
\
\9onceUsedLocations[trace] = true\
\9Logging.warn(messageTemplate, ...)\
end\
\
return Logging", '@'.."Orca.include.node_modules.roact.src.Logging")) setfenv(fn, newEnv("Orca.include.node_modules.roact.src.Logging")) return fn() end)

newModule("None", "ModuleScript", "Orca.include.node_modules.roact.src.None", "Orca.include.node_modules.roact.src", function () local fn = assert(loadstring("local Symbol = require(script.Parent.Symbol)\
\
-- Marker used to specify that the value is nothing, because nil cannot be\
-- stored in tables.\
local None = Symbol.named(\"None\")\
\
return None", '@'.."Orca.include.node_modules.roact.src.None")) setfenv(fn, newEnv("Orca.include.node_modules.roact.src.None")) return fn() end)

newModule("NoopRenderer", "ModuleScript", "Orca.include.node_modules.roact.src.NoopRenderer", "Orca.include.node_modules.roact.src", function () local fn = assert(loadstring("--[[\
\9Reference renderer intended for use in tests as well as for documenting the\
\9minimum required interface for a Roact renderer.\
]]\
\
local NoopRenderer = {}\
\
function NoopRenderer.isHostObject(target)\
\9-- Attempting to use NoopRenderer to target a Roblox instance is almost\
\9-- certainly a mistake.\
\9return target == nil\
end\
\
function NoopRenderer.mountHostNode(reconciler, node)\
end\
\
function NoopRenderer.unmountHostNode(reconciler, node)\
end\
\
function NoopRenderer.updateHostNode(reconciler, node, newElement)\
\9return node\
end\
\
return NoopRenderer", '@'.."Orca.include.node_modules.roact.src.NoopRenderer")) setfenv(fn, newEnv("Orca.include.node_modules.roact.src.NoopRenderer")) return fn() end)

newModule("Portal", "ModuleScript", "Orca.include.node_modules.roact.src.Portal", "Orca.include.node_modules.roact.src", function () local fn = assert(loadstring("local Symbol = require(script.Parent.Symbol)\
\
local Portal = Symbol.named(\"Portal\")\
\
return Portal", '@'.."Orca.include.node_modules.roact.src.Portal")) setfenv(fn, newEnv("Orca.include.node_modules.roact.src.Portal")) return fn() end)

newInstance("PropMarkers", "Folder", "Orca.include.node_modules.roact.src.PropMarkers", "Orca.include.node_modules.roact.src")

newModule("Change", "ModuleScript", "Orca.include.node_modules.roact.src.PropMarkers.Change", "Orca.include.node_modules.roact.src.PropMarkers", function () local fn = assert(loadstring("--[[\
\9Change is used to generate special prop keys that can be used to connect to\
\9GetPropertyChangedSignal.\
\
\9Generally, Change is indexed by a Roblox property name:\
\
\9\9Roact.createElement(\"TextBox\", {\
\9\9\9[Roact.Change.Text] = function(rbx)\
\9\9\9\9print(\"The TextBox\", rbx, \"changed text to\", rbx.Text)\
\9\9\9end,\
\9\9})\
]]\
\
local Type = require(script.Parent.Parent.Type)\
\
local Change = {}\
\
local changeMetatable = {\
\9__tostring = function(self)\
\9\9return (\"RoactHostChangeEvent(%s)\"):format(self.name)\
\9end,\
}\
\
setmetatable(Change, {\
\9__index = function(self, propertyName)\
\9\9local changeListener = {\
\9\9\9[Type] = Type.HostChangeEvent,\
\9\9\9name = propertyName,\
\9\9}\
\
\9\9setmetatable(changeListener, changeMetatable)\
\9\9Change[propertyName] = changeListener\
\
\9\9return changeListener\
\9end,\
})\
\
return Change\
", '@'.."Orca.include.node_modules.roact.src.PropMarkers.Change")) setfenv(fn, newEnv("Orca.include.node_modules.roact.src.PropMarkers.Change")) return fn() end)

newModule("Children", "ModuleScript", "Orca.include.node_modules.roact.src.PropMarkers.Children", "Orca.include.node_modules.roact.src.PropMarkers", function () local fn = assert(loadstring("local Symbol = require(script.Parent.Parent.Symbol)\
\
local Children = Symbol.named(\"Children\")\
\
return Children", '@'.."Orca.include.node_modules.roact.src.PropMarkers.Children")) setfenv(fn, newEnv("Orca.include.node_modules.roact.src.PropMarkers.Children")) return fn() end)

newModule("Event", "ModuleScript", "Orca.include.node_modules.roact.src.PropMarkers.Event", "Orca.include.node_modules.roact.src.PropMarkers", function () local fn = assert(loadstring("--[[\
\9Index into `Event` to get a prop key for attaching to an event on a Roblox\
\9Instance.\
\
\9Example:\
\
\9\9Roact.createElement(\"TextButton\", {\
\9\9\9Text = \"Hello, world!\",\
\
\9\9\9[Roact.Event.MouseButton1Click] = function(rbx)\
\9\9\9\9print(\"Clicked\", rbx)\
\9\9\9end\
\9\9})\
]]\
\
local Type = require(script.Parent.Parent.Type)\
\
local Event = {}\
\
local eventMetatable = {\
\9__tostring = function(self)\
\9\9return (\"RoactHostEvent(%s)\"):format(self.name)\
\9end,\
}\
\
setmetatable(Event, {\
\9__index = function(self, eventName)\
\9\9local event = {\
\9\9\9[Type] = Type.HostEvent,\
\9\9\9name = eventName,\
\9\9}\
\
\9\9setmetatable(event, eventMetatable)\
\
\9\9Event[eventName] = event\
\
\9\9return event\
\9end,\
})\
\
return Event\
", '@'.."Orca.include.node_modules.roact.src.PropMarkers.Event")) setfenv(fn, newEnv("Orca.include.node_modules.roact.src.PropMarkers.Event")) return fn() end)

newModule("Ref", "ModuleScript", "Orca.include.node_modules.roact.src.PropMarkers.Ref", "Orca.include.node_modules.roact.src.PropMarkers", function () local fn = assert(loadstring("local Symbol = require(script.Parent.Parent.Symbol)\
\
local Ref = Symbol.named(\"Ref\")\
\
return Ref", '@'.."Orca.include.node_modules.roact.src.PropMarkers.Ref")) setfenv(fn, newEnv("Orca.include.node_modules.roact.src.PropMarkers.Ref")) return fn() end)

newModule("PureComponent", "ModuleScript", "Orca.include.node_modules.roact.src.PureComponent", "Orca.include.node_modules.roact.src", function () local fn = assert(loadstring("--[[\
\9A version of Component with a `shouldUpdate` method that forces the\
\9resulting component to be pure.\
]]\
\
local Component = require(script.Parent.Component)\
\
local PureComponent = Component:extend(\"PureComponent\")\
\
-- When extend()ing a component, you don't get an extend method.\
-- This is to promote composition over inheritance.\
-- PureComponent is an exception to this rule.\
PureComponent.extend = Component.extend\
\
function PureComponent:shouldUpdate(newProps, newState)\
\9-- In a vast majority of cases, if state updated, something has updated.\
\9-- We don't bother checking in this case.\
\9if newState ~= self.state then\
\9\9return true\
\9end\
\
\9if newProps == self.props then\
\9\9return false\
\9end\
\
\9for key, value in pairs(newProps) do\
\9\9if self.props[key] ~= value then\
\9\9\9return true\
\9\9end\
\9end\
\
\9for key, value in pairs(self.props) do\
\9\9if newProps[key] ~= value then\
\9\9\9return true\
\9\9end\
\9end\
\
\9return false\
end\
\
return PureComponent", '@'.."Orca.include.node_modules.roact.src.PureComponent")) setfenv(fn, newEnv("Orca.include.node_modules.roact.src.PureComponent")) return fn() end)

newModule("RobloxRenderer", "ModuleScript", "Orca.include.node_modules.roact.src.RobloxRenderer", "Orca.include.node_modules.roact.src", function () local fn = assert(loadstring("--[[\
\9Renderer that deals in terms of Roblox Instances. This is the most\
\9well-supported renderer after NoopRenderer and is currently the only\
\9renderer that does anything.\
]]\
\
local Binding = require(script.Parent.Binding)\
local Children = require(script.Parent.PropMarkers.Children)\
local ElementKind = require(script.Parent.ElementKind)\
local SingleEventManager = require(script.Parent.SingleEventManager)\
local getDefaultInstanceProperty = require(script.Parent.getDefaultInstanceProperty)\
local Ref = require(script.Parent.PropMarkers.Ref)\
local Type = require(script.Parent.Type)\
local internalAssert = require(script.Parent.internalAssert)\
\
local config = require(script.Parent.GlobalConfig).get()\
\
local applyPropsError = [[\
Error applying props:\
\9%s\
In element:\
%s\
]]\
\
local updatePropsError = [[\
Error updating props:\
\9%s\
In element:\
%s\
]]\
\
local function identity(...)\
\9return ...\
end\
\
local function applyRef(ref, newHostObject)\
\9if ref == nil then\
\9\9return\
\9end\
\
\9if typeof(ref) == \"function\" then\
\9\9ref(newHostObject)\
\9elseif Type.of(ref) == Type.Binding then\
\9\9Binding.update(ref, newHostObject)\
\9else\
\9\9-- TODO (#197): Better error message\
\9\9error((\"Invalid ref: Expected type Binding but got %s\"):format(\
\9\9\9typeof(ref)\
\9\9))\
\9end\
end\
\
local function setRobloxInstanceProperty(hostObject, key, newValue)\
\9if newValue == nil then\
\9\9local hostClass = hostObject.ClassName\
\9\9local _, defaultValue = getDefaultInstanceProperty(hostClass, key)\
\9\9newValue = defaultValue\
\9end\
\
\9-- Assign the new value to the object\
\9hostObject[key] = newValue\
\
\9return\
end\
\
local function removeBinding(virtualNode, key)\
\9local disconnect = virtualNode.bindings[key]\
\9disconnect()\
\9virtualNode.bindings[key] = nil\
end\
\
local function attachBinding(virtualNode, key, newBinding)\
\9local function updateBoundProperty(newValue)\
\9\9local success, errorMessage = xpcall(function()\
\9\9\9setRobloxInstanceProperty(virtualNode.hostObject, key, newValue)\
\9\9end, identity)\
\
\9\9if not success then\
\9\9\9local source = virtualNode.currentElement.source\
\
\9\9\9if source == nil then\
\9\9\9\9source = \"<enable element tracebacks>\"\
\9\9\9end\
\
\9\9\9local fullMessage = updatePropsError:format(errorMessage, source)\
\9\9\9error(fullMessage, 0)\
\9\9end\
\9end\
\
\9if virtualNode.bindings == nil then\
\9\9virtualNode.bindings = {}\
\9end\
\
\9virtualNode.bindings[key] = Binding.subscribe(newBinding, updateBoundProperty)\
\
\9updateBoundProperty(newBinding:getValue())\
end\
\
local function detachAllBindings(virtualNode)\
\9if virtualNode.bindings ~= nil then\
\9\9for _, disconnect in pairs(virtualNode.bindings) do\
\9\9\9disconnect()\
\9\9end\
\9end\
end\
\
local function applyProp(virtualNode, key, newValue, oldValue)\
\9if newValue == oldValue then\
\9\9return\
\9end\
\
\9if key == Ref or key == Children then\
\9\9-- Refs and children are handled in a separate pass\
\9\9return\
\9end\
\
\9local internalKeyType = Type.of(key)\
\
\9if internalKeyType == Type.HostEvent or internalKeyType == Type.HostChangeEvent then\
\9\9if virtualNode.eventManager == nil then\
\9\9\9virtualNode.eventManager = SingleEventManager.new(virtualNode.hostObject)\
\9\9end\
\
\9\9local eventName = key.name\
\
\9\9if internalKeyType == Type.HostChangeEvent then\
\9\9\9virtualNode.eventManager:connectPropertyChange(eventName, newValue)\
\9\9else\
\9\9\9virtualNode.eventManager:connectEvent(eventName, newValue)\
\9\9end\
\
\9\9return\
\9end\
\
\9local newIsBinding = Type.of(newValue) == Type.Binding\
\9local oldIsBinding = Type.of(oldValue) == Type.Binding\
\
\9if oldIsBinding then\
\9\9removeBinding(virtualNode, key)\
\9end\
\
\9if newIsBinding then\
\9\9attachBinding(virtualNode, key, newValue)\
\9else\
\9\9setRobloxInstanceProperty(virtualNode.hostObject, key, newValue)\
\9end\
end\
\
local function applyProps(virtualNode, props)\
\9for propKey, value in pairs(props) do\
\9\9applyProp(virtualNode, propKey, value, nil)\
\9end\
end\
\
local function updateProps(virtualNode, oldProps, newProps)\
\9-- Apply props that were added or updated\
\9for propKey, newValue in pairs(newProps) do\
\9\9local oldValue = oldProps[propKey]\
\
\9\9applyProp(virtualNode, propKey, newValue, oldValue)\
\9end\
\
\9-- Clean up props that were removed\
\9for propKey, oldValue in pairs(oldProps) do\
\9\9local newValue = newProps[propKey]\
\
\9\9if newValue == nil then\
\9\9\9applyProp(virtualNode, propKey, nil, oldValue)\
\9\9end\
\9end\
end\
\
local RobloxRenderer = {}\
\
function RobloxRenderer.isHostObject(target)\
\9return typeof(target) == \"Instance\"\
end\
\
function RobloxRenderer.mountHostNode(reconciler, virtualNode)\
\9local element = virtualNode.currentElement\
\9local hostParent = virtualNode.hostParent\
\9local hostKey = virtualNode.hostKey\
\
\9if config.internalTypeChecks then\
\9\9internalAssert(ElementKind.of(element) == ElementKind.Host, \"Element at given node is not a host Element\")\
\9end\
\9if config.typeChecks then\
\9\9assert(element.props.Name == nil, \"Name can not be specified as a prop to a host component in Roact.\")\
\9\9assert(element.props.Parent == nil, \"Parent can not be specified as a prop to a host component in Roact.\")\
\9end\
\
\9local instance = Instance.new(element.component)\
\9virtualNode.hostObject = instance\
\
\9local success, errorMessage = xpcall(function()\
\9\9applyProps(virtualNode, element.props)\
\9end, identity)\
\
\9if not success then\
\9\9local source = element.source\
\
\9\9if source == nil then\
\9\9\9source = \"<enable element tracebacks>\"\
\9\9end\
\
\9\9local fullMessage = applyPropsError:format(errorMessage, source)\
\9\9error(fullMessage, 0)\
\9end\
\
\9instance.Name = tostring(hostKey)\
\
\9local children = element.props[Children]\
\
\9if children ~= nil then\
\9\9reconciler.updateVirtualNodeWithChildren(virtualNode, virtualNode.hostObject, children)\
\9end\
\
\9instance.Parent = hostParent\
\9virtualNode.hostObject = instance\
\
\9applyRef(element.props[Ref], instance)\
\
\9if virtualNode.eventManager ~= nil then\
\9\9virtualNode.eventManager:resume()\
\9end\
end\
\
function RobloxRenderer.unmountHostNode(reconciler, virtualNode)\
\9local element = virtualNode.currentElement\
\
\9applyRef(element.props[Ref], nil)\
\
\9for _, childNode in pairs(virtualNode.children) do\
\9\9reconciler.unmountVirtualNode(childNode)\
\9end\
\
\9detachAllBindings(virtualNode)\
\
\9virtualNode.hostObject:Destroy()\
end\
\
function RobloxRenderer.updateHostNode(reconciler, virtualNode, newElement)\
\9local oldProps = virtualNode.currentElement.props\
\9local newProps = newElement.props\
\
\9if virtualNode.eventManager ~= nil then\
\9\9virtualNode.eventManager:suspend()\
\9end\
\
\9-- If refs changed, detach the old ref and attach the new one\
\9if oldProps[Ref] ~= newProps[Ref] then\
\9\9applyRef(oldProps[Ref], nil)\
\9\9applyRef(newProps[Ref], virtualNode.hostObject)\
\9end\
\
\9local success, errorMessage = xpcall(function()\
\9\9updateProps(virtualNode, oldProps, newProps)\
\9end, identity)\
\
\9if not success then\
\9\9local source = newElement.source\
\
\9\9if source == nil then\
\9\9\9source = \"<enable element tracebacks>\"\
\9\9end\
\
\9\9local fullMessage = updatePropsError:format(errorMessage, source)\
\9\9error(fullMessage, 0)\
\9end\
\
\9local children = newElement.props[Children]\
\9if children ~= nil or oldProps[Children] ~= nil then\
\9\9reconciler.updateVirtualNodeWithChildren(virtualNode, virtualNode.hostObject, children)\
\9end\
\
\9if virtualNode.eventManager ~= nil then\
\9\9virtualNode.eventManager:resume()\
\9end\
\
\9return virtualNode\
end\
\
return RobloxRenderer\
", '@'.."Orca.include.node_modules.roact.src.RobloxRenderer")) setfenv(fn, newEnv("Orca.include.node_modules.roact.src.RobloxRenderer")) return fn() end)

newModule("SingleEventManager", "ModuleScript", "Orca.include.node_modules.roact.src.SingleEventManager", "Orca.include.node_modules.roact.src", function () local fn = assert(loadstring("--[[\
\9A manager for a single host virtual node's connected events.\
]]\
\
local Logging = require(script.Parent.Logging)\
\
local CHANGE_PREFIX = \"Change.\"\
\
local EventStatus = {\
\9-- No events are processed at all; they're silently discarded\
\9Disabled = \"Disabled\",\
\
\9-- Events are stored in a queue; listeners are invoked when the manager is resumed\
\9Suspended = \"Suspended\",\
\
\9-- Event listeners are invoked as the events fire\
\9Enabled = \"Enabled\",\
}\
\
local SingleEventManager = {}\
SingleEventManager.__index = SingleEventManager\
\
function SingleEventManager.new(instance)\
\9local self = setmetatable({\
\9\9-- The queue of suspended events\
\9\9_suspendedEventQueue = {},\
\
\9\9-- All the event connections being managed\
\9\9-- Events are indexed by a string key\
\9\9_connections = {},\
\
\9\9-- All the listeners being managed\
\9\9-- These are stored distinctly from the connections\
\9\9-- Connections can have their listeners replaced at runtime\
\9\9_listeners = {},\
\
\9\9-- The suspension status of the manager\
\9\9-- Managers start disabled and are \"resumed\" after the initial render\
\9\9_status = EventStatus.Disabled,\
\
\9\9-- If true, the manager is processing queued events right now.\
\9\9_isResuming = false,\
\
\9\9-- The Roblox instance the manager is managing\
\9\9_instance = instance,\
\9}, SingleEventManager)\
\
\9return self\
end\
\
function SingleEventManager:connectEvent(key, listener)\
\9self:_connect(key, self._instance[key], listener)\
end\
\
function SingleEventManager:connectPropertyChange(key, listener)\
\9local success, event = pcall(function()\
\9\9return self._instance:GetPropertyChangedSignal(key)\
\9end)\
\
\9if not success then\
\9\9error((\"Cannot get changed signal on property %q: %s\"):format(\
\9\9\9tostring(key),\
\9\9\9event\
\9\9), 0)\
\9end\
\
\9self:_connect(CHANGE_PREFIX .. key, event, listener)\
end\
\
function SingleEventManager:_connect(eventKey, event, listener)\
\9-- If the listener doesn't exist we can just disconnect the existing connection\
\9if listener == nil then\
\9\9if self._connections[eventKey] ~= nil then\
\9\9\9self._connections[eventKey]:Disconnect()\
\9\9\9self._connections[eventKey] = nil\
\9\9end\
\
\9\9self._listeners[eventKey] = nil\
\9else\
\9\9if self._connections[eventKey] == nil then\
\9\9\9self._connections[eventKey] = event:Connect(function(...)\
\9\9\9\9if self._status == EventStatus.Enabled then\
\9\9\9\9\9self._listeners[eventKey](self._instance, ...)\
\9\9\9\9elseif self._status == EventStatus.Suspended then\
\9\9\9\9\9-- Store this event invocation to be fired when resume is\
\9\9\9\9\9-- called.\
\
\9\9\9\9\9local argumentCount = select(\"#\", ...)\
\9\9\9\9\9table.insert(self._suspendedEventQueue, { eventKey, argumentCount, ... })\
\9\9\9\9end\
\9\9\9end)\
\9\9end\
\
\9\9self._listeners[eventKey] = listener\
\9end\
end\
\
function SingleEventManager:suspend()\
\9self._status = EventStatus.Suspended\
end\
\
function SingleEventManager:resume()\
\9-- If we're already resuming events for this instance, trying to resume\
\9-- again would cause a disaster.\
\9if self._isResuming then\
\9\9return\
\9end\
\
\9self._isResuming = true\
\
\9local index = 1\
\
\9-- More events might be added to the queue when evaluating events, so we\
\9-- need to be careful in order to preserve correct evaluation order.\
\9while index <= #self._suspendedEventQueue do\
\9\9local eventInvocation = self._suspendedEventQueue[index]\
\9\9local listener = self._listeners[eventInvocation[1]]\
\9\9local argumentCount = eventInvocation[2]\
\
\9\9-- The event might have been disconnected since suspension started; in\
\9\9-- this case, we drop the event.\
\9\9if listener ~= nil then\
\9\9\9-- Wrap the listener in a coroutine to catch errors and handle\
\9\9\9-- yielding correctly.\
\9\9\9local listenerCo = coroutine.create(listener)\
\9\9\9local success, result = coroutine.resume(\
\9\9\9\9listenerCo,\
\9\9\9\9self._instance,\
\9\9\9\9unpack(eventInvocation, 3, 2 + argumentCount))\
\
\9\9\9-- If the listener threw an error, we log it as a warning, since\
\9\9\9-- there's no way to write error text in Roblox Lua without killing\
\9\9\9-- our thread!\
\9\9\9if not success then\
\9\9\9\9Logging.warn(\"%s\", result)\
\9\9\9end\
\9\9end\
\
\9\9index = index + 1\
\9end\
\
\9self._isResuming = false\
\9self._status = EventStatus.Enabled\
\9self._suspendedEventQueue = {}\
end\
\
return SingleEventManager", '@'.."Orca.include.node_modules.roact.src.SingleEventManager")) setfenv(fn, newEnv("Orca.include.node_modules.roact.src.SingleEventManager")) return fn() end)

newModule("Symbol", "ModuleScript", "Orca.include.node_modules.roact.src.Symbol", "Orca.include.node_modules.roact.src", function () local fn = assert(loadstring("--[[\
\9A 'Symbol' is an opaque marker type.\
\
\9Symbols have the type 'userdata', but when printed to the console, the name\
\9of the symbol is shown.\
]]\
\
local Symbol = {}\
\
--[[\
\9Creates a Symbol with the given name.\
\
\9When printed or coerced to a string, the symbol will turn into the string\
\9given as its name.\
]]\
function Symbol.named(name)\
\9assert(type(name) == \"string\", \"Symbols must be created using a string name!\")\
\
\9local self = newproxy(true)\
\
\9local wrappedName = (\"Symbol(%s)\"):format(name)\
\
\9getmetatable(self).__tostring = function()\
\9\9return wrappedName\
\9end\
\
\9return self\
end\
\
return Symbol", '@'.."Orca.include.node_modules.roact.src.Symbol")) setfenv(fn, newEnv("Orca.include.node_modules.roact.src.Symbol")) return fn() end)

newModule("Type", "ModuleScript", "Orca.include.node_modules.roact.src.Type", "Orca.include.node_modules.roact.src", function () local fn = assert(loadstring("--[[\
\9Contains markers for annotating objects with types.\
\
\9To set the type of an object, use `Type` as a key and the actual marker as\
\9the value:\
\
\9\9local foo = {\
\9\9\9[Type] = Type.Foo,\
\9\9}\
]]\
\
local Symbol = require(script.Parent.Symbol)\
local strict = require(script.Parent.strict)\
\
local Type = newproxy(true)\
\
local TypeInternal = {}\
\
local function addType(name)\
\9TypeInternal[name] = Symbol.named(\"Roact\" .. name)\
end\
\
addType(\"Binding\")\
addType(\"Element\")\
addType(\"HostChangeEvent\")\
addType(\"HostEvent\")\
addType(\"StatefulComponentClass\")\
addType(\"StatefulComponentInstance\")\
addType(\"VirtualNode\")\
addType(\"VirtualTree\")\
\
function TypeInternal.of(value)\
\9if typeof(value) ~= \"table\" then\
\9\9return nil\
\9end\
\
\9return value[Type]\
end\
\
getmetatable(Type).__index = TypeInternal\
\
getmetatable(Type).__tostring = function()\
\9return \"RoactType\"\
end\
\
strict(TypeInternal, \"Type\")\
\
return Type", '@'.."Orca.include.node_modules.roact.src.Type")) setfenv(fn, newEnv("Orca.include.node_modules.roact.src.Type")) return fn() end)

newModule("assertDeepEqual", "ModuleScript", "Orca.include.node_modules.roact.src.assertDeepEqual", "Orca.include.node_modules.roact.src", function () local fn = assert(loadstring("--[[\
\9A utility used to assert that two objects are value-equal recursively. It\
\9outputs fairly nicely formatted messages to help diagnose why two objects\
\9would be different.\
\
\9This should only be used in tests.\
]]\
\
local function deepEqual(a, b)\
\9if typeof(a) ~= typeof(b) then\
\9\9local message = (\"{1} is of type %s, but {2} is of type %s\"):format(\
\9\9\9typeof(a),\
\9\9\9typeof(b)\
\9\9)\
\9\9return false, message\
\9end\
\
\9if typeof(a) == \"table\" then\
\9\9local visitedKeys = {}\
\
\9\9for key, value in pairs(a) do\
\9\9\9visitedKeys[key] = true\
\
\9\9\9local success, innerMessage = deepEqual(value, b[key])\
\9\9\9if not success then\
\9\9\9\9local message = innerMessage\
\9\9\9\9\9:gsub(\"{1}\", (\"{1}[%s]\"):format(tostring(key)))\
\9\9\9\9\9:gsub(\"{2}\", (\"{2}[%s]\"):format(tostring(key)))\
\
\9\9\9\9return false, message\
\9\9\9end\
\9\9end\
\
\9\9for key, value in pairs(b) do\
\9\9\9if not visitedKeys[key] then\
\9\9\9\9local success, innerMessage = deepEqual(value, a[key])\
\
\9\9\9\9if not success then\
\9\9\9\9\9local message = innerMessage\
\9\9\9\9\9\9:gsub(\"{1}\", (\"{1}[%s]\"):format(tostring(key)))\
\9\9\9\9\9\9:gsub(\"{2}\", (\"{2}[%s]\"):format(tostring(key)))\
\
\9\9\9\9\9return false, message\
\9\9\9\9end\
\9\9\9end\
\9\9end\
\
\9\9return true\
\9end\
\
\9if a == b then\
\9\9return true\
\9end\
\
\9local message = \"{1} ~= {2}\"\
\9return false, message\
end\
\
local function assertDeepEqual(a, b)\
\9local success, innerMessageTemplate = deepEqual(a, b)\
\
\9if not success then\
\9\9local innerMessage = innerMessageTemplate\
\9\9\9:gsub(\"{1}\", \"first\")\
\9\9\9:gsub(\"{2}\", \"second\")\
\
\9\9local message = (\"Values were not deep-equal.\\n%s\"):format(innerMessage)\
\
\9\9error(message, 2)\
\9end\
end\
\
return assertDeepEqual", '@'.."Orca.include.node_modules.roact.src.assertDeepEqual")) setfenv(fn, newEnv("Orca.include.node_modules.roact.src.assertDeepEqual")) return fn() end)

newModule("assign", "ModuleScript", "Orca.include.node_modules.roact.src.assign", "Orca.include.node_modules.roact.src", function () local fn = assert(loadstring("local None = require(script.Parent.None)\
\
--[[\
\9Merges values from zero or more tables onto a target table. If a value is\
\9set to None, it will instead be removed from the table.\
\
\9This function is identical in functionality to JavaScript's Object.assign.\
]]\
local function assign(target, ...)\
\9for index = 1, select(\"#\", ...) do\
\9\9local source = select(index, ...)\
\
\9\9if source ~= nil then\
\9\9\9for key, value in pairs(source) do\
\9\9\9\9if value == None then\
\9\9\9\9\9target[key] = nil\
\9\9\9\9else\
\9\9\9\9\9target[key] = value\
\9\9\9\9end\
\9\9\9end\
\9\9end\
\9end\
\
\9return target\
end\
\
return assign", '@'.."Orca.include.node_modules.roact.src.assign")) setfenv(fn, newEnv("Orca.include.node_modules.roact.src.assign")) return fn() end)

newModule("createContext", "ModuleScript", "Orca.include.node_modules.roact.src.createContext", "Orca.include.node_modules.roact.src", function () local fn = assert(loadstring("local Symbol = require(script.Parent.Symbol)\
local createFragment = require(script.Parent.createFragment)\
local createSignal = require(script.Parent.createSignal)\
local Children = require(script.Parent.PropMarkers.Children)\
local Component = require(script.Parent.Component)\
\
--[[\
\9Construct the value that is assigned to Roact's context storage.\
]]\
local function createContextEntry(currentValue)\
\9return {\
\9\9value = currentValue,\
\9\9onUpdate = createSignal(),\
\9}\
end\
\
local function createProvider(context)\
\9local Provider = Component:extend(\"Provider\")\
\
\9function Provider:init(props)\
\9\9self.contextEntry = createContextEntry(props.value)\
\9\9self:__addContext(context.key, self.contextEntry)\
\9end\
\
\9function Provider:willUpdate(nextProps)\
\9\9-- If the provided value changed, immediately update the context entry.\
\9\9--\
\9\9-- During this update, any components that are reachable will receive\
\9\9-- this updated value at the same time as any props and state updates\
\9\9-- that are being applied.\
\9\9if nextProps.value ~= self.props.value then\
\9\9\9self.contextEntry.value = nextProps.value\
\9\9end\
\9end\
\
\9function Provider:didUpdate(prevProps)\
\9\9-- If the provided value changed, after we've updated every reachable\
\9\9-- component, fire a signal to update the rest.\
\9\9--\
\9\9-- This signal will notify all context consumers. It's expected that\
\9\9-- they will compare the last context value they updated with and only\
\9\9-- trigger an update on themselves if this value is different.\
\9\9--\
\9\9-- This codepath will generally only update consumer components that has\
\9\9-- a component implementing shouldUpdate between them and the provider.\
\9\9if prevProps.value ~= self.props.value then\
\9\9\9self.contextEntry.onUpdate:fire(self.props.value)\
\9\9end\
\9end\
\
\9function Provider:render()\
\9\9return createFragment(self.props[Children])\
\9end\
\
\9return Provider\
end\
\
local function createConsumer(context)\
\9local Consumer = Component:extend(\"Consumer\")\
\
\9function Consumer.validateProps(props)\
\9\9if type(props.render) ~= \"function\" then\
\9\9\9return false, \"Consumer expects a `render` function\"\
\9\9else\
\9\9\9return true\
\9\9end\
\9end\
\
\9function Consumer:init(props)\
\9\9-- This value may be nil, which indicates that our consumer is not a\
\9\9-- descendant of a provider for this context item.\
\9\9self.contextEntry = self:__getContext(context.key)\
\9end\
\
\9function Consumer:render()\
\9\9-- Render using the latest available for this context item.\
\9\9--\
\9\9-- We don't store this value in state in order to have more fine-grained\
\9\9-- control over our update behavior.\
\9\9local value\
\9\9if self.contextEntry ~= nil then\
\9\9\9value = self.contextEntry.value\
\9\9else\
\9\9\9value = context.defaultValue\
\9\9end\
\
\9\9return self.props.render(value)\
\9end\
\
\9function Consumer:didUpdate()\
\9\9-- Store the value that we most recently updated with.\
\9\9--\
\9\9-- This value is compared in the contextEntry onUpdate hook below.\
\9\9if self.contextEntry ~= nil then\
\9\9\9self.lastValue = self.contextEntry.value\
\9\9end\
\9end\
\
\9function Consumer:didMount()\
\9\9if self.contextEntry ~= nil then\
\9\9\9-- When onUpdate is fired, a new value has been made available in\
\9\9\9-- this context entry, but we may have already updated in the same\
\9\9\9-- update cycle.\
\9\9\9--\
\9\9\9-- To avoid sending a redundant update, we compare the new value\
\9\9\9-- with the last value that we updated with (set in didUpdate) and\
\9\9\9-- only update if they differ. This may happen when an update from a\
\9\9\9-- provider was blocked by an intermediate component that returned\
\9\9\9-- false from shouldUpdate.\
\9\9\9self.disconnect = self.contextEntry.onUpdate:subscribe(function(newValue)\
\9\9\9\9if newValue ~= self.lastValue then\
\9\9\9\9\9-- Trigger a dummy state update.\
\9\9\9\9\9self:setState({})\
\9\9\9\9end\
\9\9\9end)\
\9\9end\
\9end\
\
\9function Consumer:willUnmount()\
\9\9if self.disconnect ~= nil then\
\9\9\9self.disconnect()\
\9\9end\
\9end\
\
\9return Consumer\
end\
\
local Context = {}\
Context.__index = Context\
\
function Context.new(defaultValue)\
\9return setmetatable({\
\9\9defaultValue = defaultValue,\
\9\9key = Symbol.named(\"ContextKey\"),\
\9}, Context)\
end\
\
function Context:__tostring()\
\9return \"RoactContext\"\
end\
\
local function createContext(defaultValue)\
\9local context = Context.new(defaultValue)\
\
\9return {\
\9\9Provider = createProvider(context),\
\9\9Consumer = createConsumer(context),\
\9}\
end\
\
return createContext\
", '@'.."Orca.include.node_modules.roact.src.createContext")) setfenv(fn, newEnv("Orca.include.node_modules.roact.src.createContext")) return fn() end)

newModule("createElement", "ModuleScript", "Orca.include.node_modules.roact.src.createElement", "Orca.include.node_modules.roact.src", function () local fn = assert(loadstring("local Children = require(script.Parent.PropMarkers.Children)\
local ElementKind = require(script.Parent.ElementKind)\
local Logging = require(script.Parent.Logging)\
local Type = require(script.Parent.Type)\
\
local config = require(script.Parent.GlobalConfig).get()\
\
local multipleChildrenMessage = [[\
The prop `Roact.Children` was defined but was overriden by the third parameter to createElement!\
This can happen when a component passes props through to a child element but also uses the `children` argument:\
\
\9Roact.createElement(\"Frame\", passedProps, {\
\9\9child = ...\
\9})\
\
Instead, consider using a utility function to merge tables of children together:\
\
\9local children = mergeTables(passedProps[Roact.Children], {\
\9\9child = ...\
\9})\
\
\9local fullProps = mergeTables(passedProps, {\
\9\9[Roact.Children] = children\
\9})\
\
\9Roact.createElement(\"Frame\", fullProps)]]\
\
--[[\
\9Creates a new element representing the given component.\
\
\9Elements are lightweight representations of what a component instance should\
\9look like.\
\
\9Children is a shorthand for specifying `Roact.Children` as a key inside\
\9props. If specified, the passed `props` table is mutated!\
]]\
local function createElement(component, props, children)\
\9if config.typeChecks then\
\9\9assert(component ~= nil, \"`component` is required\")\
\9\9assert(typeof(props) == \"table\" or props == nil, \"`props` must be a table or nil\")\
\9\9assert(typeof(children) == \"table\" or children == nil, \"`children` must be a table or nil\")\
\9end\
\
\9if props == nil then\
\9\9props = {}\
\9end\
\
\9if children ~= nil then\
\9\9if props[Children] ~= nil then\
\9\9\9Logging.warnOnce(multipleChildrenMessage)\
\9\9end\
\
\9\9props[Children] = children\
\9end\
\
\9local elementKind = ElementKind.fromComponent(component)\
\
\9local element = {\
\9\9[Type] = Type.Element,\
\9\9[ElementKind] = elementKind,\
\9\9component = component,\
\9\9props = props,\
\9}\
\
\9if config.elementTracing then\
\9\9-- We trim out the leading newline since there's no way to specify the\
\9\9-- trace level without also specifying a message.\
\9\9element.source = debug.traceback(\"\", 2):sub(2)\
\9end\
\
\9return element\
end\
\
return createElement", '@'.."Orca.include.node_modules.roact.src.createElement")) setfenv(fn, newEnv("Orca.include.node_modules.roact.src.createElement")) return fn() end)

newModule("createFragment", "ModuleScript", "Orca.include.node_modules.roact.src.createFragment", "Orca.include.node_modules.roact.src", function () local fn = assert(loadstring("local ElementKind = require(script.Parent.ElementKind)\
local Type = require(script.Parent.Type)\
\
local function createFragment(elements)\
\9return {\
\9\9[Type] = Type.Element,\
\9\9[ElementKind] = ElementKind.Fragment,\
\9\9elements = elements,\
\9}\
end\
\
return createFragment", '@'.."Orca.include.node_modules.roact.src.createFragment")) setfenv(fn, newEnv("Orca.include.node_modules.roact.src.createFragment")) return fn() end)

newModule("createReconciler", "ModuleScript", "Orca.include.node_modules.roact.src.createReconciler", "Orca.include.node_modules.roact.src", function () local fn = assert(loadstring("local Type = require(script.Parent.Type)\
local ElementKind = require(script.Parent.ElementKind)\
local ElementUtils = require(script.Parent.ElementUtils)\
local Children = require(script.Parent.PropMarkers.Children)\
local Symbol = require(script.Parent.Symbol)\
local internalAssert = require(script.Parent.internalAssert)\
\
local config = require(script.Parent.GlobalConfig).get()\
\
local InternalData = Symbol.named(\"InternalData\")\
\
--[[\
\9The reconciler is the mechanism in Roact that constructs the virtual tree\
\9that later gets turned into concrete objects by the renderer.\
\
\9Roact's reconciler is constructed with the renderer as an argument, which\
\9enables switching to different renderers for different platforms or\
\9scenarios.\
\
\9When testing the reconciler itself, it's common to use `NoopRenderer` with\
\9spies replacing some methods. The default (and only) reconciler interface\
\9exposed by Roact right now uses `RobloxRenderer`.\
]]\
local function createReconciler(renderer)\
\9local reconciler\
\9local mountVirtualNode\
\9local updateVirtualNode\
\9local unmountVirtualNode\
\
\9--[[\
\9\9Unmount the given virtualNode, replacing it with a new node described by\
\9\9the given element.\
\
\9\9Preserves host properties, depth, and legacyContext from parent.\
\9]]\
\9local function replaceVirtualNode(virtualNode, newElement)\
\9\9local hostParent = virtualNode.hostParent\
\9\9local hostKey = virtualNode.hostKey\
\9\9local depth = virtualNode.depth\
\9\9local parent = virtualNode.parent\
\
\9\9-- If the node that is being replaced has modified context, we need to\
\9\9-- use the original *unmodified* context for the new node\
\9\9-- The `originalContext` field will be nil if the context was unchanged\
\9\9local context = virtualNode.originalContext or virtualNode.context\
\9\9local parentLegacyContext = virtualNode.parentLegacyContext\
\
\9\9unmountVirtualNode(virtualNode)\
\9\9local newNode = mountVirtualNode(newElement, hostParent, hostKey, context, parentLegacyContext)\
\
\9\9-- mountVirtualNode can return nil if the element is a boolean\
\9\9if newNode ~= nil then\
\9\9\9newNode.depth = depth\
\9\9\9newNode.parent = parent\
\9\9end\
\
\9\9return newNode\
\9end\
\
\9--[[\
\9\9Utility to update the children of a virtual node based on zero or more\
\9\9updated children given as elements.\
\9]]\
\9local function updateChildren(virtualNode, hostParent, newChildElements)\
\9\9if config.internalTypeChecks then\
\9\9\9internalAssert(Type.of(virtualNode) == Type.VirtualNode, \"Expected arg #1 to be of type VirtualNode\")\
\9\9end\
\
\9\9local removeKeys = {}\
\
\9\9-- Changed or removed children\
\9\9for childKey, childNode in pairs(virtualNode.children) do\
\9\9\9local newElement = ElementUtils.getElementByKey(newChildElements, childKey)\
\9\9\9local newNode = updateVirtualNode(childNode, newElement)\
\
\9\9\9if newNode ~= nil then\
\9\9\9\9virtualNode.children[childKey] = newNode\
\9\9\9else\
\9\9\9\9removeKeys[childKey] = true\
\9\9\9end\
\9\9end\
\
\9\9for childKey in pairs(removeKeys) do\
\9\9\9virtualNode.children[childKey] = nil\
\9\9end\
\
\9\9-- Added children\
\9\9for childKey, newElement in ElementUtils.iterateElements(newChildElements) do\
\9\9\9local concreteKey = childKey\
\9\9\9if childKey == ElementUtils.UseParentKey then\
\9\9\9\9concreteKey = virtualNode.hostKey\
\9\9\9end\
\
\9\9\9if virtualNode.children[childKey] == nil then\
\9\9\9\9local childNode = mountVirtualNode(\
\9\9\9\9\9newElement,\
\9\9\9\9\9hostParent,\
\9\9\9\9\9concreteKey,\
\9\9\9\9\9virtualNode.context,\
\9\9\9\9\9virtualNode.legacyContext\
\9\9\9\9)\
\
\9\9\9\9-- mountVirtualNode can return nil if the element is a boolean\
\9\9\9\9if childNode ~= nil then\
\9\9\9\9\9childNode.depth = virtualNode.depth + 1\
\9\9\9\9\9childNode.parent = virtualNode\
\9\9\9\9\9virtualNode.children[childKey] = childNode\
\9\9\9\9end\
\9\9\9end\
\9\9end\
\9end\
\
\9local function updateVirtualNodeWithChildren(virtualNode, hostParent, newChildElements)\
\9\9updateChildren(virtualNode, hostParent, newChildElements)\
\9end\
\
\9local function updateVirtualNodeWithRenderResult(virtualNode, hostParent, renderResult)\
\9\9if Type.of(renderResult) == Type.Element\
\9\9\9or renderResult == nil\
\9\9\9or typeof(renderResult) == \"boolean\"\
\9\9then\
\9\9\9updateChildren(virtualNode, hostParent, renderResult)\
\9\9else\
\9\9\9error((\"%s\\n%s\"):format(\
\9\9\9\9\"Component returned invalid children:\",\
\9\9\9\9virtualNode.currentElement.source or \"<enable element tracebacks>\"\
\9\9\9), 0)\
\9\9end\
\9end\
\
\9--[[\
\9\9Unmounts the given virtual node and releases any held resources.\
\9]]\
\9function unmountVirtualNode(virtualNode)\
\9\9if config.internalTypeChecks then\
\9\9\9internalAssert(Type.of(virtualNode) == Type.VirtualNode, \"Expected arg #1 to be of type VirtualNode\")\
\9\9end\
\
\9\9local kind = ElementKind.of(virtualNode.currentElement)\
\
\9\9if kind == ElementKind.Host then\
\9\9\9renderer.unmountHostNode(reconciler, virtualNode)\
\9\9elseif kind == ElementKind.Function then\
\9\9\9for _, childNode in pairs(virtualNode.children) do\
\9\9\9\9unmountVirtualNode(childNode)\
\9\9\9end\
\9\9elseif kind == ElementKind.Stateful then\
\9\9\9virtualNode.instance:__unmount()\
\9\9elseif kind == ElementKind.Portal then\
\9\9\9for _, childNode in pairs(virtualNode.children) do\
\9\9\9\9unmountVirtualNode(childNode)\
\9\9\9end\
\9\9elseif kind == ElementKind.Fragment then\
\9\9\9for _, childNode in pairs(virtualNode.children) do\
\9\9\9\9unmountVirtualNode(childNode)\
\9\9\9end\
\9\9else\
\9\9\9error((\"Unknown ElementKind %q\"):format(tostring(kind)), 2)\
\9\9end\
\9end\
\
\9local function updateFunctionVirtualNode(virtualNode, newElement)\
\9\9local children = newElement.component(newElement.props)\
\
\9\9updateVirtualNodeWithRenderResult(virtualNode, virtualNode.hostParent, children)\
\
\9\9return virtualNode\
\9end\
\
\9local function updatePortalVirtualNode(virtualNode, newElement)\
\9\9local oldElement = virtualNode.currentElement\
\9\9local oldTargetHostParent = oldElement.props.target\
\
\9\9local targetHostParent = newElement.props.target\
\
\9\9assert(renderer.isHostObject(targetHostParent), \"Expected target to be host object\")\
\
\9\9if targetHostParent ~= oldTargetHostParent then\
\9\9\9return replaceVirtualNode(virtualNode, newElement)\
\9\9end\
\
\9\9local children = newElement.props[Children]\
\
\9\9updateVirtualNodeWithChildren(virtualNode, targetHostParent, children)\
\
\9\9return virtualNode\
\9end\
\
\9local function updateFragmentVirtualNode(virtualNode, newElement)\
\9\9updateVirtualNodeWithChildren(virtualNode, virtualNode.hostParent, newElement.elements)\
\
\9\9return virtualNode\
\9end\
\
\9--[[\
\9\9Update the given virtual node using a new element describing what it\
\9\9should transform into.\
\
\9\9`updateVirtualNode` will return a new virtual node that should replace\
\9\9the passed in virtual node. This is because a virtual node can be\
\9\9updated with an element referencing a different component!\
\
\9\9In that case, `updateVirtualNode` will unmount the input virtual node,\
\9\9mount a new virtual node, and return it in this case, while also issuing\
\9\9a warning to the user.\
\9]]\
\9function updateVirtualNode(virtualNode, newElement, newState)\
\9\9if config.internalTypeChecks then\
\9\9\9internalAssert(Type.of(virtualNode) == Type.VirtualNode, \"Expected arg #1 to be of type VirtualNode\")\
\9\9end\
\9\9if config.typeChecks then\
\9\9\9assert(\
\9\9\9\9Type.of(newElement) == Type.Element or typeof(newElement) == \"boolean\" or newElement == nil,\
\9\9\9\9\"Expected arg #2 to be of type Element, boolean, or nil\"\
\9\9\9)\
\9\9end\
\
\9\9-- If nothing changed, we can skip this update\
\9\9if virtualNode.currentElement == newElement and newState == nil then\
\9\9\9return virtualNode\
\9\9end\
\
\9\9if typeof(newElement) == \"boolean\" or newElement == nil then\
\9\9\9unmountVirtualNode(virtualNode)\
\9\9\9return nil\
\9\9end\
\
\9\9if virtualNode.currentElement.component ~= newElement.component then\
\9\9\9return replaceVirtualNode(virtualNode, newElement)\
\9\9end\
\
\9\9local kind = ElementKind.of(newElement)\
\
\9\9local shouldContinueUpdate = true\
\
\9\9if kind == ElementKind.Host then\
\9\9\9virtualNode = renderer.updateHostNode(reconciler, virtualNode, newElement)\
\9\9elseif kind == ElementKind.Function then\
\9\9\9virtualNode = updateFunctionVirtualNode(virtualNode, newElement)\
\9\9elseif kind == ElementKind.Stateful then\
\9\9\9shouldContinueUpdate = virtualNode.instance:__update(newElement, newState)\
\9\9elseif kind == ElementKind.Portal then\
\9\9\9virtualNode = updatePortalVirtualNode(virtualNode, newElement)\
\9\9elseif kind == ElementKind.Fragment then\
\9\9\9virtualNode = updateFragmentVirtualNode(virtualNode, newElement)\
\9\9else\
\9\9\9error((\"Unknown ElementKind %q\"):format(tostring(kind)), 2)\
\9\9end\
\
\9\9-- Stateful components can abort updates via shouldUpdate. If that\
\9\9-- happens, we should stop doing stuff at this point.\
\9\9if not shouldContinueUpdate then\
\9\9\9return virtualNode\
\9\9end\
\
\9\9virtualNode.currentElement = newElement\
\
\9\9return virtualNode\
\9end\
\
\9--[[\
\9\9Constructs a new virtual node but not does mount it.\
\9]]\
\9local function createVirtualNode(element, hostParent, hostKey, context, legacyContext)\
\9\9if config.internalTypeChecks then\
\9\9\9internalAssert(renderer.isHostObject(hostParent) or hostParent == nil, \"Expected arg #2 to be a host object\")\
\9\9\9internalAssert(typeof(context) == \"table\" or context == nil, \"Expected arg #4 to be of type table or nil\")\
\9\9\9internalAssert(\
\9\9\9\9typeof(legacyContext) == \"table\" or legacyContext == nil,\
\9\9\9\9\"Expected arg #5 to be of type table or nil\"\
\9\9\9)\
\9\9end\
\9\9if config.typeChecks then\
\9\9\9assert(hostKey ~= nil, \"Expected arg #3 to be non-nil\")\
\9\9\9assert(\
\9\9\9\9Type.of(element) == Type.Element or typeof(element) == \"boolean\",\
\9\9\9\9\"Expected arg #1 to be of type Element or boolean\"\
\9\9\9)\
\9\9end\
\
\9\9return {\
\9\9\9[Type] = Type.VirtualNode,\
\9\9\9currentElement = element,\
\9\9\9depth = 1,\
\9\9\9parent = nil,\
\9\9\9children = {},\
\9\9\9hostParent = hostParent,\
\9\9\9hostKey = hostKey,\
\
\9\9\9-- Legacy Context API\
\9\9\9-- A table of context values inherited from the parent node\
\9\9\9legacyContext = legacyContext,\
\
\9\9\9-- A saved copy of the parent context, used when replacing a node\
\9\9\9parentLegacyContext = legacyContext,\
\
\9\9\9-- Context API\
\9\9\9-- A table of context values inherited from the parent node\
\9\9\9context = context or {},\
\
\9\9\9-- A saved copy of the unmodified context; this will be updated when\
\9\9\9-- a component adds new context and used when a node is replaced\
\9\9\9originalContext = nil,\
\9\9}\
\9end\
\
\9local function mountFunctionVirtualNode(virtualNode)\
\9\9local element = virtualNode.currentElement\
\
\9\9local children = element.component(element.props)\
\
\9\9updateVirtualNodeWithRenderResult(virtualNode, virtualNode.hostParent, children)\
\9end\
\
\9local function mountPortalVirtualNode(virtualNode)\
\9\9local element = virtualNode.currentElement\
\
\9\9local targetHostParent = element.props.target\
\9\9local children = element.props[Children]\
\
\9\9assert(renderer.isHostObject(targetHostParent), \"Expected target to be host object\")\
\
\9\9updateVirtualNodeWithChildren(virtualNode, targetHostParent, children)\
\9end\
\
\9local function mountFragmentVirtualNode(virtualNode)\
\9\9local element = virtualNode.currentElement\
\9\9local children = element.elements\
\
\9\9updateVirtualNodeWithChildren(virtualNode, virtualNode.hostParent, children)\
\9end\
\
\9--[[\
\9\9Constructs a new virtual node and mounts it, but does not place it into\
\9\9the tree.\
\9]]\
\9function mountVirtualNode(element, hostParent, hostKey, context, legacyContext)\
\9\9if config.internalTypeChecks then\
\9\9\9internalAssert(renderer.isHostObject(hostParent) or hostParent == nil, \"Expected arg #2 to be a host object\")\
\9\9\9internalAssert(\
\9\9\9\9typeof(legacyContext) == \"table\" or legacyContext == nil,\
\9\9\9\9\"Expected arg #5 to be of type table or nil\"\
\9\9\9)\
\9\9end\
\9\9if config.typeChecks then\
\9\9\9assert(hostKey ~= nil, \"Expected arg #3 to be non-nil\")\
\9\9\9assert(\
\9\9\9\9Type.of(element) == Type.Element or typeof(element) == \"boolean\",\
\9\9\9\9\"Expected arg #1 to be of type Element or boolean\"\
\9\9\9)\
\9\9end\
\
\9\9-- Boolean values render as nil to enable terse conditional rendering.\
\9\9if typeof(element) == \"boolean\" then\
\9\9\9return nil\
\9\9end\
\
\9\9local kind = ElementKind.of(element)\
\
\9\9local virtualNode = createVirtualNode(element, hostParent, hostKey, context, legacyContext)\
\
\9\9if kind == ElementKind.Host then\
\9\9\9renderer.mountHostNode(reconciler, virtualNode)\
\9\9elseif kind == ElementKind.Function then\
\9\9\9mountFunctionVirtualNode(virtualNode)\
\9\9elseif kind == ElementKind.Stateful then\
\9\9\9element.component:__mount(reconciler, virtualNode)\
\9\9elseif kind == ElementKind.Portal then\
\9\9\9mountPortalVirtualNode(virtualNode)\
\9\9elseif kind == ElementKind.Fragment then\
\9\9\9mountFragmentVirtualNode(virtualNode)\
\9\9else\
\9\9\9error((\"Unknown ElementKind %q\"):format(tostring(kind)), 2)\
\9\9end\
\
\9\9return virtualNode\
\9end\
\
\9--[[\
\9\9Constructs a new Roact virtual tree, constructs a root node for\
\9\9it, and mounts it.\
\9]]\
\9local function mountVirtualTree(element, hostParent, hostKey)\
\9\9if config.typeChecks then\
\9\9\9assert(Type.of(element) == Type.Element, \"Expected arg #1 to be of type Element\")\
\9\9\9assert(renderer.isHostObject(hostParent) or hostParent == nil, \"Expected arg #2 to be a host object\")\
\9\9end\
\
\9\9if hostKey == nil then\
\9\9\9hostKey = \"RoactTree\"\
\9\9end\
\
\9\9local tree = {\
\9\9\9[Type] = Type.VirtualTree,\
\9\9\9[InternalData] = {\
\9\9\9\9-- The root node of the tree, which starts into the hierarchy of\
\9\9\9\9-- Roact component instances.\
\9\9\9\9rootNode = nil,\
\9\9\9\9mounted = true,\
\9\9\9},\
\9\9}\
\
\9\9tree[InternalData].rootNode = mountVirtualNode(element, hostParent, hostKey)\
\
\9\9return tree\
\9end\
\
\9--[[\
\9\9Unmounts the virtual tree, freeing all of its resources.\
\
\9\9No further operations should be done on the tree after it's been\
\9\9unmounted, as indicated by its the `mounted` field.\
\9]]\
\9local function unmountVirtualTree(tree)\
\9\9local internalData = tree[InternalData]\
\9\9if config.typeChecks then\
\9\9\9assert(Type.of(tree) == Type.VirtualTree, \"Expected arg #1 to be a Roact handle\")\
\9\9\9assert(internalData.mounted, \"Cannot unmounted a Roact tree that has already been unmounted\")\
\9\9end\
\
\9\9internalData.mounted = false\
\
\9\9if internalData.rootNode ~= nil then\
\9\9\9unmountVirtualNode(internalData.rootNode)\
\9\9end\
\9end\
\
\9--[[\
\9\9Utility method for updating the root node of a virtual tree given a new\
\9\9element.\
\9]]\
\9local function updateVirtualTree(tree, newElement)\
\9\9local internalData = tree[InternalData]\
\9\9if config.typeChecks then\
\9\9\9assert(Type.of(tree) == Type.VirtualTree, \"Expected arg #1 to be a Roact handle\")\
\9\9\9assert(Type.of(newElement) == Type.Element, \"Expected arg #2 to be a Roact Element\")\
\9\9end\
\
\9\9internalData.rootNode = updateVirtualNode(internalData.rootNode, newElement)\
\
\9\9return tree\
\9end\
\
\9local function suspendParentEvents(virtualNode)\
\9\9local parentNode = virtualNode.parent\
\9\9while parentNode do\
\9\9\9if parentNode.eventManager ~= nil then\
\9\9\9\9parentNode.eventManager:suspend()\
\9\9\9end\
\
\9\9\9parentNode = parentNode.parent\
\9\9end\
\9end\
\
\9local function resumeParentEvents(virtualNode)\
\9\9local parentNode = virtualNode.parent\
\9\9while parentNode do\
\9\9\9if parentNode.eventManager ~= nil then\
\9\9\9\9parentNode.eventManager:resume()\
\9\9\9end\
\
\9\9\9parentNode = parentNode.parent\
\9\9end\
\9end\
\
\9reconciler = {\
\9\9mountVirtualTree = mountVirtualTree,\
\9\9unmountVirtualTree = unmountVirtualTree,\
\9\9updateVirtualTree = updateVirtualTree,\
\
\9\9createVirtualNode = createVirtualNode,\
\9\9mountVirtualNode = mountVirtualNode,\
\9\9unmountVirtualNode = unmountVirtualNode,\
\9\9updateVirtualNode = updateVirtualNode,\
\9\9updateVirtualNodeWithChildren = updateVirtualNodeWithChildren,\
\9\9updateVirtualNodeWithRenderResult = updateVirtualNodeWithRenderResult,\
\
\9\9suspendParentEvents = suspendParentEvents,\
\9\9resumeParentEvents = resumeParentEvents,\
\9}\
\
\9return reconciler\
end\
\
return createReconciler\
", '@'.."Orca.include.node_modules.roact.src.createReconciler")) setfenv(fn, newEnv("Orca.include.node_modules.roact.src.createReconciler")) return fn() end)

newModule("createReconcilerCompat", "ModuleScript", "Orca.include.node_modules.roact.src.createReconcilerCompat", "Orca.include.node_modules.roact.src", function () local fn = assert(loadstring("--[[\
\9Contains deprecated methods from Reconciler. Broken out so that removing\
\9this shim is easy -- just delete this file and remove it from init.\
]]\
\
local Logging = require(script.Parent.Logging)\
\
local reifyMessage = [[\
Roact.reify has been renamed to Roact.mount and will be removed in a future release.\
Check the call to Roact.reify at:\
]]\
\
local teardownMessage = [[\
Roact.teardown has been renamed to Roact.unmount and will be removed in a future release.\
Check the call to Roact.teardown at:\
]]\
\
local reconcileMessage = [[\
Roact.reconcile has been renamed to Roact.update and will be removed in a future release.\
Check the call to Roact.reconcile at:\
]]\
\
local function createReconcilerCompat(reconciler)\
\9local compat = {}\
\
\9function compat.reify(...)\
\9\9Logging.warnOnce(reifyMessage)\
\
\9\9return reconciler.mountVirtualTree(...)\
\9end\
\
\9function compat.teardown(...)\
\9\9Logging.warnOnce(teardownMessage)\
\
\9\9return reconciler.unmountVirtualTree(...)\
\9end\
\
\9function compat.reconcile(...)\
\9\9Logging.warnOnce(reconcileMessage)\
\
\9\9return reconciler.updateVirtualTree(...)\
\9end\
\
\9return compat\
end\
\
return createReconcilerCompat", '@'.."Orca.include.node_modules.roact.src.createReconcilerCompat")) setfenv(fn, newEnv("Orca.include.node_modules.roact.src.createReconcilerCompat")) return fn() end)

newModule("createRef", "ModuleScript", "Orca.include.node_modules.roact.src.createRef", "Orca.include.node_modules.roact.src", function () local fn = assert(loadstring("--[[\
\9A ref is nothing more than a binding with a special field 'current'\
\9that maps to the getValue method of the binding\
]]\
local Binding = require(script.Parent.Binding)\
\
local function createRef()\
\9local binding, _ = Binding.create(nil)\
\
\9local ref = {}\
\
\9--[[\
\9\9A ref is just redirected to a binding via its metatable\
\9]]\
\9setmetatable(ref, {\
\9\9__index = function(self, key)\
\9\9\9if key == \"current\" then\
\9\9\9\9return binding:getValue()\
\9\9\9else\
\9\9\9\9return binding[key]\
\9\9\9end\
\9\9end,\
\9\9__newindex = function(self, key, value)\
\9\9\9if key == \"current\" then\
\9\9\9\9error(\"Cannot assign to the 'current' property of refs\", 2)\
\9\9\9end\
\
\9\9\9binding[key] = value\
\9\9end,\
\9\9__tostring = function(self)\
\9\9\9return (\"RoactRef(%s)\"):format(tostring(binding:getValue()))\
\9\9end,\
\9})\
\
\9return ref\
end\
\
return createRef", '@'.."Orca.include.node_modules.roact.src.createRef")) setfenv(fn, newEnv("Orca.include.node_modules.roact.src.createRef")) return fn() end)

newModule("createSignal", "ModuleScript", "Orca.include.node_modules.roact.src.createSignal", "Orca.include.node_modules.roact.src", function () local fn = assert(loadstring("--[[\
\9This is a simple signal implementation that has a dead-simple API.\
\
\9\9local signal = createSignal()\
\
\9\9local disconnect = signal:subscribe(function(foo)\
\9\9\9print(\"Cool foo:\", foo)\
\9\9end)\
\
\9\9signal:fire(\"something\")\
\
\9\9disconnect()\
]]\
\
local function createSignal()\
\9local connections = {}\
\9local suspendedConnections = {}\
\9local firing = false\
\
\9local function subscribe(self, callback)\
\9\9assert(typeof(callback) == \"function\", \"Can only subscribe to signals with a function.\")\
\
\9\9local connection = {\
\9\9\9callback = callback,\
\9\9\9disconnected = false,\
\9\9}\
\
\9\9-- If the callback is already registered, don't add to the suspendedConnection. Otherwise, this will disable\
\9\9-- the existing one.\
\9\9if firing and not connections[callback] then\
\9\9\9suspendedConnections[callback] = connection\
\9\9end\
\
\9\9connections[callback] = connection\
\
\9\9local function disconnect()\
\9\9\9assert(not connection.disconnected, \"Listeners can only be disconnected once.\")\
\
\9\9\9connection.disconnected = true\
\9\9\9connections[callback] = nil\
\9\9\9suspendedConnections[callback] = nil\
\9\9end\
\
\9\9return disconnect\
\9end\
\
\9local function fire(self, ...)\
\9\9firing = true\
\9\9for callback, connection in pairs(connections) do\
\9\9\9if not connection.disconnected and not suspendedConnections[callback] then\
\9\9\9\9callback(...)\
\9\9\9end\
\9\9end\
\
\9\9firing = false\
\
\9\9for callback, _ in pairs(suspendedConnections) do\
\9\9\9suspendedConnections[callback] = nil\
\9\9end\
\9end\
\
\9return {\
\9\9subscribe = subscribe,\
\9\9fire = fire,\
\9}\
end\
\
return createSignal\
", '@'.."Orca.include.node_modules.roact.src.createSignal")) setfenv(fn, newEnv("Orca.include.node_modules.roact.src.createSignal")) return fn() end)

newModule("createSpy", "ModuleScript", "Orca.include.node_modules.roact.src.createSpy", "Orca.include.node_modules.roact.src", function () local fn = assert(loadstring("--[[\
\9A utility used to create a function spy that can be used to robustly test\
\9that functions are invoked the correct number of times and with the correct\
\9number of arguments.\
\
\9This should only be used in tests.\
]]\
\
local assertDeepEqual = require(script.Parent.assertDeepEqual)\
\
local function createSpy(inner)\
\9local self = {\
\9\9callCount = 0,\
\9\9values = {},\
\9\9valuesLength = 0,\
\9}\
\
\9self.value = function(...)\
\9\9self.callCount = self.callCount + 1\
\9\9self.values = {...}\
\9\9self.valuesLength = select(\"#\", ...)\
\
\9\9if inner ~= nil then\
\9\9\9return inner(...)\
\9\9end\
\9end\
\
\9self.assertCalledWith = function(_, ...)\
\9\9local len = select(\"#\", ...)\
\
\9\9if self.valuesLength ~= len then\
\9\9\9error((\"Expected %d arguments, but was called with %d arguments\"):format(\
\9\9\9\9self.valuesLength,\
\9\9\9\9len\
\9\9\9), 2)\
\9\9end\
\
\9\9for i = 1, len do\
\9\9\9local expected = select(i, ...)\
\
\9\9\9assert(self.values[i] == expected, \"value differs\")\
\9\9end\
\9end\
\
\9self.assertCalledWithDeepEqual = function(_, ...)\
\9\9local len = select(\"#\", ...)\
\
\9\9if self.valuesLength ~= len then\
\9\9\9error((\"Expected %d arguments, but was called with %d arguments\"):format(\
\9\9\9\9self.valuesLength,\
\9\9\9\9len\
\9\9\9), 2)\
\9\9end\
\
\9\9for i = 1, len do\
\9\9\9local expected = select(i, ...)\
\
\9\9\9assertDeepEqual(self.values[i], expected)\
\9\9end\
\9end\
\
\9self.captureValues = function(_, ...)\
\9\9local len = select(\"#\", ...)\
\9\9local result = {}\
\
\9\9assert(self.valuesLength == len, \"length of expected values differs from stored values\")\
\
\9\9for i = 1, len do\
\9\9\9local key = select(i, ...)\
\9\9\9result[key] = self.values[i]\
\9\9end\
\
\9\9return result\
\9end\
\
\9setmetatable(self, {\
\9\9__index = function(_, key)\
\9\9\9error((\"%q is not a valid member of spy\"):format(key))\
\9\9end,\
\9})\
\
\9return self\
end\
\
return createSpy", '@'.."Orca.include.node_modules.roact.src.createSpy")) setfenv(fn, newEnv("Orca.include.node_modules.roact.src.createSpy")) return fn() end)

newModule("forwardRef", "ModuleScript", "Orca.include.node_modules.roact.src.forwardRef", "Orca.include.node_modules.roact.src", function () local fn = assert(loadstring("local assign = require(script.Parent.assign)\
local None = require(script.Parent.None)\
local Ref = require(script.Parent.PropMarkers.Ref)\
\
local config = require(script.Parent.GlobalConfig).get()\
\
local excludeRef = {\
\9[Ref] = None,\
}\
\
--[[\
\9Allows forwarding of refs to underlying host components. Accepts a render\
\9callback which accepts props and a ref, and returns an element.\
]]\
local function forwardRef(render)\
\9if config.typeChecks then\
\9\9assert(typeof(render) == \"function\", \"Expected arg #1 to be a function\")\
\9end\
\
\9return function(props)\
\9\9local ref = props[Ref]\
\9\9local propsWithoutRef = assign({}, props, excludeRef)\
\
\9\9return render(propsWithoutRef, ref)\
\9end\
end\
\
return forwardRef", '@'.."Orca.include.node_modules.roact.src.forwardRef")) setfenv(fn, newEnv("Orca.include.node_modules.roact.src.forwardRef")) return fn() end)

newModule("getDefaultInstanceProperty", "ModuleScript", "Orca.include.node_modules.roact.src.getDefaultInstanceProperty", "Orca.include.node_modules.roact.src", function () local fn = assert(loadstring("--[[\
\9Attempts to get the default value of a given property on a Roblox instance.\
\
\9This is used by the reconciler in cases where a prop was previously set on a\
\9primitive component, but is no longer present in a component's new props.\
\
\9Eventually, Roblox might provide a nicer API to query the default property\
\9of an object without constructing an instance of it.\
]]\
\
local Symbol = require(script.Parent.Symbol)\
\
local Nil = Symbol.named(\"Nil\")\
local _cachedPropertyValues = {}\
\
local function getDefaultInstanceProperty(className, propertyName)\
\9local classCache = _cachedPropertyValues[className]\
\
\9if classCache then\
\9\9local propValue = classCache[propertyName]\
\
\9\9-- We have to use a marker here, because Lua doesn't distinguish\
\9\9-- between 'nil' and 'not in a table'\
\9\9if propValue == Nil then\
\9\9\9return true, nil\
\9\9end\
\
\9\9if propValue ~= nil then\
\9\9\9return true, propValue\
\9\9end\
\9else\
\9\9classCache = {}\
\9\9_cachedPropertyValues[className] = classCache\
\9end\
\
\9local created = Instance.new(className)\
\9local ok, defaultValue = pcall(function()\
\9\9return created[propertyName]\
\9end)\
\
\9created:Destroy()\
\
\9if ok then\
\9\9if defaultValue == nil then\
\9\9\9classCache[propertyName] = Nil\
\9\9else\
\9\9\9classCache[propertyName] = defaultValue\
\9\9end\
\9end\
\
\9return ok, defaultValue\
end\
\
return getDefaultInstanceProperty", '@'.."Orca.include.node_modules.roact.src.getDefaultInstanceProperty")) setfenv(fn, newEnv("Orca.include.node_modules.roact.src.getDefaultInstanceProperty")) return fn() end)

newModule("internalAssert", "ModuleScript", "Orca.include.node_modules.roact.src.internalAssert", "Orca.include.node_modules.roact.src", function () local fn = assert(loadstring("local function internalAssert(condition, message)\
\9if not condition then\
\9\9error(message .. \" (This is probably a bug in Roact!)\", 3)\
\9end\
end\
\
return internalAssert", '@'.."Orca.include.node_modules.roact.src.internalAssert")) setfenv(fn, newEnv("Orca.include.node_modules.roact.src.internalAssert")) return fn() end)

newModule("invalidSetStateMessages", "ModuleScript", "Orca.include.node_modules.roact.src.invalidSetStateMessages", "Orca.include.node_modules.roact.src", function () local fn = assert(loadstring("--[[\
\9These messages are used by Component to help users diagnose when they're\
\9calling setState in inappropriate places.\
\
\9The indentation may seem odd, but it's necessary to avoid introducing extra\
\9whitespace into the error messages themselves.\
]]\
local ComponentLifecyclePhase = require(script.Parent.ComponentLifecyclePhase)\
\
local invalidSetStateMessages = {}\
\
invalidSetStateMessages[ComponentLifecyclePhase.WillUpdate] = [[\
setState cannot be used in the willUpdate lifecycle method.\
Consider using the didUpdate method instead, or using getDerivedStateFromProps.\
\
Check the definition of willUpdate in the component %q.]]\
\
invalidSetStateMessages[ComponentLifecyclePhase.WillUnmount] = [[\
setState cannot be used in the willUnmount lifecycle method.\
A component that is being unmounted cannot be updated!\
\
Check the definition of willUnmount in the component %q.]]\
\
invalidSetStateMessages[ComponentLifecyclePhase.ShouldUpdate] = [[\
setState cannot be used in the shouldUpdate lifecycle method.\
shouldUpdate must be a pure function that only depends on props and state.\
\
Check the definition of shouldUpdate in the component %q.]]\
\
invalidSetStateMessages[ComponentLifecyclePhase.Render] = [[\
setState cannot be used in the render method.\
render must be a pure function that only depends on props and state.\
\
Check the definition of render in the component %q.]]\
\
invalidSetStateMessages[\"default\"] = [[\
setState can not be used in the current situation, because Roact doesn't know\
which part of the lifecycle this component is in.\
\
This is a bug in Roact.\
It was triggered by the component %q.\
]]\
\
return invalidSetStateMessages", '@'.."Orca.include.node_modules.roact.src.invalidSetStateMessages")) setfenv(fn, newEnv("Orca.include.node_modules.roact.src.invalidSetStateMessages")) return fn() end)

newModule("oneChild", "ModuleScript", "Orca.include.node_modules.roact.src.oneChild", "Orca.include.node_modules.roact.src", function () local fn = assert(loadstring("--[[\
\9Retrieves at most one child from the children passed to a component.\
\
\9If passed nil or an empty table, will return nil.\
\
\9Throws an error if passed more than one child.\
]]\
local function oneChild(children)\
\9if not children then\
\9\9return nil\
\9end\
\
\9local key, child = next(children)\
\
\9if not child then\
\9\9return nil\
\9end\
\
\9local after = next(children, key)\
\
\9if after then\
\9\9error(\"Expected at most child, had more than one child.\", 2)\
\9end\
\
\9return child\
end\
\
return oneChild", '@'.."Orca.include.node_modules.roact.src.oneChild")) setfenv(fn, newEnv("Orca.include.node_modules.roact.src.oneChild")) return fn() end)

newModule("strict", "ModuleScript", "Orca.include.node_modules.roact.src.strict", "Orca.include.node_modules.roact.src", function () local fn = assert(loadstring("local function strict(t, name)\
\9name = name or tostring(t)\
\
\9return setmetatable(t, {\
\9\9__index = function(self, key)\
\9\9\9local message = (\"%q (%s) is not a valid member of %s\"):format(\
\9\9\9\9tostring(key),\
\9\9\9\9typeof(key),\
\9\9\9\9name\
\9\9\9)\
\
\9\9\9error(message, 2)\
\9\9end,\
\
\9\9__newindex = function(self, key, value)\
\9\9\9local message = (\"%q (%s) is not a valid member of %s\"):format(\
\9\9\9\9tostring(key),\
\9\9\9\9typeof(key),\
\9\9\9\9name\
\9\9\9)\
\
\9\9\9error(message, 2)\
\9\9end,\
\9})\
end\
\
return strict", '@'.."Orca.include.node_modules.roact.src.strict")) setfenv(fn, newEnv("Orca.include.node_modules.roact.src.strict")) return fn() end)

newInstance("roact-hooked", "Folder", "Orca.include.node_modules.roact-hooked", "Orca.include.node_modules")

newModule("out", "ModuleScript", "Orca.include.node_modules.roact-hooked.out", "Orca.include.node_modules.roact-hooked", function () local fn = assert(loadstring("-- Compiled with roblox-ts v1.2.7\
local TS = _G[script]\
local exports = {}\
local _with_hooks = TS.import(script, script, \"with-hooks\")\
local withHooks = _with_hooks.withHooks\
local withHooksPure = _with_hooks.withHooksPure\
for _k, _v in pairs(TS.import(script, script, \"hooks\")) do\
\9exports[_k] = _v\
end\
--[[\
\9*\
\9* `hooked` is a [higher-order component](https://reactjs.org/docs/higher-order-components.html) that turns your\
\9* Function Component into a [class component](https://roblox.github.io/roact/guide/components/).\
\9*\
\9* `hooked` allows you to hook into the Component's lifecycle through Hooks.\
\9*\
\9* @example\
\9* const MyComponent = hooked<Props>(\
\9*   (props) => {\
\9*     // render using props\
\9*   },\
\9* );\
\9*\
\9* @see https://reactjs.org/docs/hooks-intro.html\
]]\
local function hooked(functionComponent)\
\9return withHooks(functionComponent)\
end\
--[[\
\9*\
\9* `pure` is a [higher-order component](https://reactjs.org/docs/higher-order-components.html) that turns your\
\9* Function Component into a [PureComponent](https://roblox.github.io/roact/performance/reduce-reconciliation/#purecomponent).\
\9*\
\9* If your function component wrapped in `pure` has a {@link useState}, {@link useReducer} or {@link useContext} Hook\
\9* in its implementation, it will still rerender when state or context changes.\
\9*\
\9* @example\
\9* const MyComponent = pure<Props>(\
\9*   (props) => {\
\9*     // render using props\
\9*   },\
\9* );\
\9*\
\9* @see https://reactjs.org/docs/react-api.html\
\9* @see https://roblox.github.io/roact/performance/reduce-reconciliation/\
]]\
local function pure(functionComponent)\
\9return withHooksPure(functionComponent)\
end\
exports.hooked = hooked\
exports.pure = pure\
return exports\
", '@'.."Orca.include.node_modules.roact-hooked.out")) setfenv(fn, newEnv("Orca.include.node_modules.roact-hooked.out")) return fn() end)

newModule("hooks", "ModuleScript", "Orca.include.node_modules.roact-hooked.out.hooks", "Orca.include.node_modules.roact-hooked.out", function () local fn = assert(loadstring("-- Compiled with roblox-ts v1.2.7\
local TS = _G[script]\
local exports = {}\
exports.useBinding = TS.import(script, script, \"use-binding\").useBinding\
exports.useCallback = TS.import(script, script, \"use-callback\").useCallback\
exports.useContext = TS.import(script, script, \"use-context\").useContext\
exports.useEffect = TS.import(script, script, \"use-effect\").useEffect\
exports.useMemo = TS.import(script, script, \"use-memo\").useMemo\
exports.useReducer = TS.import(script, script, \"use-reducer\").useReducer\
exports.useState = TS.import(script, script, \"use-state\").useState\
exports.useMutable = TS.import(script, script, \"use-mutable\").useMutable\
exports.useRef = TS.import(script, script, \"use-ref\").useRef\
return exports\
", '@'.."Orca.include.node_modules.roact-hooked.out.hooks")) setfenv(fn, newEnv("Orca.include.node_modules.roact-hooked.out.hooks")) return fn() end)

newModule("use-binding", "ModuleScript", "Orca.include.node_modules.roact-hooked.out.hooks.use-binding", "Orca.include.node_modules.roact-hooked.out.hooks", function () local fn = assert(loadstring("-- Compiled with roblox-ts v1.2.7\
local TS = _G[script]\
local createBinding = TS.import(script, TS.getModule(script, \"@rbxts\", \"roact\").src).createBinding\
local memoizedHook = TS.import(script, script.Parent.Parent, \"utils\", \"memoized-hook\").memoizedHook\
--[[\
\9*\
\9* `useBinding` returns a memoized *`Binding`*, a special object that Roact automatically unwraps into values. When a\
\9* binding is updated, Roact will only change the specific properties that are subscribed to it.\
\9*\
\9* The first value returned is a `Binding` object, which will typically be passed as a prop to a Roact host component.\
\9* The second is a function that can be called with a new value to update the binding.\
\9*\
\9* @example\
\9* const [binding, setBindingValue] = useBinding(initialValue);\
\9*\
\9* @param initialValue - Initialized as the `.current` property\
\9* @returns A memoized `Binding` object, and a function to update the value of the binding.\
\9*\
\9* @see https://roblox.github.io/roact/advanced/bindings-and-refs/#bindings\
]]\
local function useBinding(initialValue)\
\9return memoizedHook(function()\
\9\9local bindingSet = { createBinding(initialValue) }\
\9\9return bindingSet\
\9end).state\
end\
return {\
\9useBinding = useBinding,\
}\
", '@'.."Orca.include.node_modules.roact-hooked.out.hooks.use-binding")) setfenv(fn, newEnv("Orca.include.node_modules.roact-hooked.out.hooks.use-binding")) return fn() end)

newModule("use-callback", "ModuleScript", "Orca.include.node_modules.roact-hooked.out.hooks.use-callback", "Orca.include.node_modules.roact-hooked.out.hooks", function () local fn = assert(loadstring("-- Compiled with roblox-ts v1.2.7\
local TS = _G[script]\
local useMemo = TS.import(script, script.Parent, \"use-memo\").useMemo\
--[[\
\9*\
\9* Returns a memoized version of the callback that only changes if one of the dependencies has changed.\
\9*\
\9* This is useful when passing callbacks to optimized child components that rely on reference equality to prevent\
\9* unnecessary renders.\
\9*\
\9* `useCallback(fn, deps)` is equivalent to `useMemo(() => fn, deps)`.\
\9*\
\9* @example\
\9* const memoizedCallback = useCallback(\
\9*   () => {\
\9*     doSomething(a, b);\
\9*   },\
\9*   [a, b],\
\9* );\
\9*\
\9* @param callback - An inline callback\
\9* @param deps - An array of dependencies\
\9* @returns A memoized version of the callback\
\9*\
\9* @see https://reactjs.org/docs/hooks-reference.html#usecallback\
]]\
local function useCallback(callback, deps)\
\9return useMemo(function()\
\9\9return callback\
\9end, deps)\
end\
return {\
\9useCallback = useCallback,\
}\
", '@'.."Orca.include.node_modules.roact-hooked.out.hooks.use-callback")) setfenv(fn, newEnv("Orca.include.node_modules.roact-hooked.out.hooks.use-callback")) return fn() end)

newModule("use-context", "ModuleScript", "Orca.include.node_modules.roact-hooked.out.hooks.use-context", "Orca.include.node_modules.roact-hooked.out.hooks", function () local fn = assert(loadstring("-- Compiled with roblox-ts v1.2.7\
local TS = _G[script]\
--[[\
\9*\
\9* @see https://github.com/Kampfkarren/roact-hooks/blob/main/src/createUseContext.lua\
]]\
local _memoized_hook = TS.import(script, script.Parent.Parent, \"utils\", \"memoized-hook\")\
local memoizedHook = _memoized_hook.memoizedHook\
local resolveCurrentComponent = _memoized_hook.resolveCurrentComponent\
local useEffect = TS.import(script, script.Parent, \"use-effect\").useEffect\
local useState = TS.import(script, script.Parent, \"use-state\").useState\
local function copyComponent(component)\
\9return setmetatable({}, {\
\9\9__index = component,\
\9})\
end\
--[[\
\9*\
\9* Accepts a context object (the value returned from `Roact.createContext`) and returns the current context value, as\
\9* given by the nearest context provider for the given context.\
\9*\
\9* When the nearest `Context.Provider` above the component updates, this Hook will trigger a rerender with the latest\
\9* context value.\
\9*\
\9* If there is no Provider, `useContext` returns the default value of the context.\
\9*\
\9* @param context - The Context object to read from\
\9* @returns The latest context value of the nearest Provider\
\9*\
\9* @see https://reactjs.org/docs/hooks-reference.html#usecontext\
]]\
local function useContext(context)\
\9local thisContext = context\
\9local _binding = memoizedHook(function()\
\9\9local consumer = copyComponent(resolveCurrentComponent())\
\9\9thisContext.Consumer.init(consumer)\
\9\9return consumer.contextEntry\
\9end)\
\9local contextEntry = _binding.state\
\9if contextEntry then\
\9\9local _binding_1 = useState(contextEntry.value)\
\9\9local value = _binding_1[1]\
\9\9local setValue = _binding_1[2]\
\9\9useEffect(function()\
\9\9\9return contextEntry.onUpdate:subscribe(setValue)\
\9\9end, {})\
\9\9return value\
\9else\
\9\9return thisContext.defaultValue\
\9end\
end\
return {\
\9useContext = useContext,\
}\
", '@'.."Orca.include.node_modules.roact-hooked.out.hooks.use-context")) setfenv(fn, newEnv("Orca.include.node_modules.roact-hooked.out.hooks.use-context")) return fn() end)

newModule("use-effect", "ModuleScript", "Orca.include.node_modules.roact-hooked.out.hooks.use-effect", "Orca.include.node_modules.roact-hooked.out.hooks", function () local fn = assert(loadstring("-- Compiled with roblox-ts v1.2.7\
local TS = _G[script]\
local areDepsEqual = TS.import(script, script.Parent.Parent, \"utils\", \"are-deps-equal\").areDepsEqual\
local _memoized_hook = TS.import(script, script.Parent.Parent, \"utils\", \"memoized-hook\")\
local memoizedHook = _memoized_hook.memoizedHook\
local resolveCurrentComponent = _memoized_hook.resolveCurrentComponent\
local function scheduleEffect(effect)\
\9local _binding = resolveCurrentComponent()\
\9local effects = _binding.effects\
\9if effects.tail == nil then\
\9\9-- This is the first effect in the list\
\9\9effects.tail = effect\
\9\9effects.head = effects.tail\
\9else\
\9\9-- Append to the end of the list\
\9\9local _exp = effects.tail\
\9\9_exp.next = effect\
\9\9effects.tail = _exp.next\
\9end\
\9return effect\
end\
--[[\
\9*\
\9* Accepts a function that contains imperative, possibly effectful code. The function passed to `useEffect` will run\
\9* synchronously (thread-blocking) after the Roblox Instance is created and rendered.\
\9*\
\9* The clean-up function (returned by the effect) runs before the component is removed from the UI to prevent memory\
\9* leaks. Additionally, if a component renders multiple times, the **previous effect is cleaned up before executing\
\9* the next effect**.\
\9*\
\9*`useEffect` runs in the same phase as `didMount` and `didUpdate`. All cleanup functions are called on `willUnmount`.\
\9*\
\9* @example\
\9* useEffect(() => {\
\9*   // use value\
\9*   return () => {\
\9*     // cleanup\
\9*   }\
\9* }, [value]);\
\9*\
\9* useEffect(() => {\
\9*   // did update\
\9* });\
\9*\
\9* useEffect(() => {\
\9*   // did mount\
\9*   return () => {\
\9*     // will unmount\
\9*   }\
\9* }, []);\
\9*\
\9* @param callback - Imperative function that can return a cleanup function\
\9* @param deps - If present, effect will only activate if the values in the list change\
\9*\
\9* @see https://reactjs.org/docs/hooks-reference.html#useeffect\
]]\
local function useEffect(callback, deps)\
\9local hook = memoizedHook(nil)\
\9local _prevDeps = hook.state\
\9if _prevDeps ~= nil then\
\9\9_prevDeps = _prevDeps.deps\
\9end\
\9local prevDeps = _prevDeps\
\9if deps and areDepsEqual(deps, prevDeps) then\
\9\9return nil\
\9end\
\9hook.state = scheduleEffect({\
\9\9id = hook.id,\
\9\9callback = callback,\
\9\9deps = deps,\
\9})\
end\
return {\
\9useEffect = useEffect,\
}\
", '@'.."Orca.include.node_modules.roact-hooked.out.hooks.use-effect")) setfenv(fn, newEnv("Orca.include.node_modules.roact-hooked.out.hooks.use-effect")) return fn() end)

newModule("use-memo", "ModuleScript", "Orca.include.node_modules.roact-hooked.out.hooks.use-memo", "Orca.include.node_modules.roact-hooked.out.hooks", function () local fn = assert(loadstring("-- Compiled with roblox-ts v1.2.7\
local TS = _G[script]\
local areDepsEqual = TS.import(script, script.Parent.Parent, \"utils\", \"are-deps-equal\").areDepsEqual\
local memoizedHook = TS.import(script, script.Parent.Parent, \"utils\", \"memoized-hook\").memoizedHook\
--[[\
\9*\
\9* `useMemo` will only recompute the memoized value when one of the `deps` has changed. This optimization helps to\
\9* avoid expensive calculations on every render.\
\9*\
\9* Remember that the function passed to `useMemo` runs during rendering. Don’t do anything there that you wouldn’t\
\9* normally do while rendering. For example, side effects belong in `useEffect`, not `useMemo`.\
\9*\
\9* If no array is provided, a new value will be computed on every render. This is usually a mistake, so `deps` must be\
\9* explicitly written as `undefined`.\
\9*\
\9* @example\
\9* const memoizedValue = useMemo(() => computeExpensiveValue(a, b), [a, b]);\
\9*\
\9* @param factory - A \"create\" function that computes a value\
\9* @param deps - An array of dependencies\
\9* @returns A memoized value\
\9*\
\9* @see https://reactjs.org/docs/hooks-reference.html#usememo\
]]\
local function useMemo(factory, deps)\
\9local hook = memoizedHook(function()\
\9\9return {}\
\9end)\
\9local _binding = hook.state\
\9local prevValue = _binding[1]\
\9local prevDeps = _binding[2]\
\9if prevValue ~= nil and (deps and areDepsEqual(deps, prevDeps)) then\
\9\9return prevValue\
\9end\
\9local nextValue = factory()\
\9hook.state = { nextValue, deps }\
\9return nextValue\
end\
return {\
\9useMemo = useMemo,\
}\
", '@'.."Orca.include.node_modules.roact-hooked.out.hooks.use-memo")) setfenv(fn, newEnv("Orca.include.node_modules.roact-hooked.out.hooks.use-memo")) return fn() end)

newModule("use-mutable", "ModuleScript", "Orca.include.node_modules.roact-hooked.out.hooks.use-mutable", "Orca.include.node_modules.roact-hooked.out.hooks", function () local fn = assert(loadstring("-- Compiled with roblox-ts v1.2.7\
local TS = _G[script]\
local memoizedHook = TS.import(script, script.Parent.Parent, \"utils\", \"memoized-hook\").memoizedHook\
-- Function overloads from https://github.com/DefinitelyTyped/DefinitelyTyped/blob/master/types/react/index.d.ts#L1061\
--[[\
\9*\
\9* `useMutable` returns a mutable object whose `.current` property is initialized to the argument `initialValue`.\
\9* The returned object will persist for the full lifetime of the component.\
\9*\
\9* `useMutable()` is handy for keeping any mutable value around similar to how you’d use instance fields in classes.\
\9*\
\9* This cannot be used as a [Roact Ref](https://roblox.github.io/roact/advanced/bindings-and-refs/#refs). If you want\
\9* to reference a Roblox Instance, refer to {@link useRef}.\
\9*\
\9* @example\
\9* const container = useMutable(initialValue);\
\9* useEffect(() => {\
\9*   container.current = value;\
\9* });\
\9*\
\9* @param initialValue - Initialized as the `.current` property\
\9* @returns A memoized, mutable object\
\9*\
\9* @see https://reactjs.org/docs/hooks-reference.html#useref\
]]\
--[[\
\9*\
\9* `useMutable` returns a mutable object whose `.current` property is initialized to the argument `initialValue`.\
\9* The returned object will persist for the full lifetime of the component.\
\9*\
\9* `useMutable()` is handy for keeping any mutable value around similar to how you’d use instance fields in classes.\
\9*\
\9* This cannot be used as a [Roact Ref](https://roblox.github.io/roact/advanced/bindings-and-refs/#refs). If you want\
\9* to reference a Roblox Instance, refer to {@link useRef}.\
\9*\
\9* @example\
\9* const container = useMutable(initialValue);\
\9* useEffect(() => {\
\9*   container.current = value;\
\9* });\
\9*\
\9* @param initialValue - Initialized as the `.current` property\
\9* @returns A memoized, mutable object\
\9*\
\9* @see https://reactjs.org/docs/hooks-reference.html#useref\
]]\
-- convenience overload for refs given as a ref prop as they typically start with a null value\
--[[\
\9*\
\9* `useMutable` returns a mutable object whose `.current` property is initialized to the argument `initialValue`.\
\9* The returned object will persist for the full lifetime of the component.\
\9*\
\9* `useMutable()` is handy for keeping any mutable value around similar to how you’d use instance fields in classes.\
\9*\
\9* This cannot be used as a [Roact Ref](https://roblox.github.io/roact/advanced/bindings-and-refs/#refs). If you want\
\9* to reference a Roblox Instance, refer to {@link useRef}.\
\9*\
\9* @example\
\9* const container = useMutable(initialValue);\
\9* useEffect(() => {\
\9*   container.current = value;\
\9* });\
\9*\
\9* @returns A memoized, mutable object\
\9*\
\9* @see https://reactjs.org/docs/hooks-reference.html#useref\
]]\
-- convenience overload for potentially undefined initialValue / call with 0 arguments\
-- has a default to stop it from defaulting to {} instead\
--[[\
\9*\
\9* `useMutable` returns a mutable object whose `.current` property is initialized to the argument `initialValue`.\
\9* The returned object will persist for the full lifetime of the component.\
\9*\
\9* `useMutable()` is handy for keeping any mutable value around similar to how you’d use instance fields in classes.\
\9*\
\9* This cannot be used as a [Roact Ref](https://roblox.github.io/roact/advanced/bindings-and-refs/#refs). If you want\
\9* to reference a Roblox Instance, refer to {@link useRef}.\
\9*\
\9* @example\
\9* const container = useMutable(initialValue);\
\9* useEffect(() => {\
\9*   container.current = value;\
\9* });\
\9*\
\9* @param initialValue - Initialized as the `.current` property\
\9* @returns A memoized, mutable object\
\9*\
\9* @see https://reactjs.org/docs/hooks-reference.html#useref\
]]\
local function useMutable(initialValue)\
\9return memoizedHook(function()\
\9\9return {\
\9\9\9current = initialValue,\
\9\9}\
\9end).state\
end\
return {\
\9useMutable = useMutable,\
}\
", '@'.."Orca.include.node_modules.roact-hooked.out.hooks.use-mutable")) setfenv(fn, newEnv("Orca.include.node_modules.roact-hooked.out.hooks.use-mutable")) return fn() end)

newModule("use-reducer", "ModuleScript", "Orca.include.node_modules.roact-hooked.out.hooks.use-reducer", "Orca.include.node_modules.roact-hooked.out.hooks", function () local fn = assert(loadstring("-- Compiled with roblox-ts v1.2.7\
local TS = _G[script]\
local _memoized_hook = TS.import(script, script.Parent.Parent, \"utils\", \"memoized-hook\")\
local memoizedHook = _memoized_hook.memoizedHook\
local resolveCurrentComponent = _memoized_hook.resolveCurrentComponent\
--[[\
\9*\
\9* Accepts a reducer of type `(state, action) => newState`, and returns the current state paired with a `dispatch`\
\9* method.\
\9*\
\9* If a new state is the same value as the current state, this will bail out without rerendering the component.\
\9*\
\9* `useReducer` is usually preferable to `useState` when you have complex state logic that involves multiple sub-values.\
\9* It also lets you optimize performance for components that trigger deep updates because [you can pass `dispatch` down\
\9* instead of callbacks](https://reactjs.org/docs/hooks-faq.html#how-to-avoid-passing-callbacks-down).\
\9*\
\9* There are two different ways to initialize `useReducer` state. You can use the initial state as a second argument,\
\9* or [create the initial state lazily](https://reactjs.org/docs/hooks-reference.html#lazy-initialization). To do this,\
\9* you can pass an init function as the third argument. The initial state will be set to `initializer(initialArg)`.\
\9*\
\9* @param reducer - Function that returns a state given the current state and an action\
\9* @param initializerArg - State used during the initial render, or passed to `initializer` if provided\
\9* @param initializer - Optional function that returns an initial state given `initializerArg`\
\9* @returns The current state, and an action dispatcher\
\9*\
\9* @see https://reactjs.org/docs/hooks-reference.html#usereducer\
]]\
-- overload where dispatch could accept 0 arguments.\
--[[\
\9*\
\9* Accepts a reducer of type `(state, action) => newState`, and returns the current state paired with a `dispatch`\
\9* method.\
\9*\
\9* If a new state is the same value as the current state, this will bail out without rerendering the component.\
\9*\
\9* `useReducer` is usually preferable to `useState` when you have complex state logic that involves multiple sub-values.\
\9* It also lets you optimize performance for components that trigger deep updates because [you can pass `dispatch` down\
\9* instead of callbacks](https://reactjs.org/docs/hooks-faq.html#how-to-avoid-passing-callbacks-down).\
\9*\
\9* There are two different ways to initialize `useReducer` state. You can use the initial state as a second argument,\
\9* or [create the initial state lazily](https://reactjs.org/docs/hooks-reference.html#lazy-initialization). To do this,\
\9* you can pass an init function as the third argument. The initial state will be set to `initializer(initialArg)`.\
\9*\
\9* @param reducer - Function that returns a state given the current state and an action\
\9* @param initializerArg - State used during the initial render, or passed to `initializer` if provided\
\9* @param initializer - Optional function that returns an initial state given `initializerArg`\
\9* @returns The current state, and an action dispatcher\
\9*\
\9* @see https://reactjs.org/docs/hooks-reference.html#usereducer\
]]\
-- overload where dispatch could accept 0 arguments.\
--[[\
\9*\
\9* Accepts a reducer of type `(state, action) => newState`, and returns the current state paired with a `dispatch`\
\9* method.\
\9*\
\9* If a new state is the same value as the current state, this will bail out without rerendering the component.\
\9*\
\9* `useReducer` is usually preferable to `useState` when you have complex state logic that involves multiple sub-values.\
\9* It also lets you optimize performance for components that trigger deep updates because [you can pass `dispatch` down\
\9* instead of callbacks](https://reactjs.org/docs/hooks-faq.html#how-to-avoid-passing-callbacks-down).\
\9*\
\9* There are two different ways to initialize `useReducer` state. You can use the initial state as a second argument,\
\9* or [create the initial state lazily](https://reactjs.org/docs/hooks-reference.html#lazy-initialization). To do this,\
\9* you can pass an init function as the third argument. The initial state will be set to `initializer(initialArg)`.\
\9*\
\9* @param reducer - Function that returns a state given the current state and an action\
\9* @param initializerArg - State used during the initial render, or passed to `initializer` if provided\
\9* @param initializer - Optional function that returns an initial state given `initializerArg`\
\9* @returns The current state, and an action dispatcher\
\9*\
\9* @see https://reactjs.org/docs/hooks-reference.html#usereducer\
]]\
-- overload for free \"I\"; all goes as long as initializer converts it into \"ReducerState<R>\".\
--[[\
\9*\
\9* Accepts a reducer of type `(state, action) => newState`, and returns the current state paired with a `dispatch`\
\9* method.\
\9*\
\9* If a new state is the same value as the current state, this will bail out without rerendering the component.\
\9*\
\9* `useReducer` is usually preferable to `useState` when you have complex state logic that involves multiple sub-values.\
\9* It also lets you optimize performance for components that trigger deep updates because [you can pass `dispatch` down\
\9* instead of callbacks](https://reactjs.org/docs/hooks-faq.html#how-to-avoid-passing-callbacks-down).\
\9*\
\9* There are two different ways to initialize `useReducer` state. You can use the initial state as a second argument,\
\9* or [create the initial state lazily](https://reactjs.org/docs/hooks-reference.html#lazy-initialization). To do this,\
\9* you can pass an init function as the third argument. The initial state will be set to `initializer(initialArg)`.\
\9*\
\9* @param reducer - Function that returns a state given the current state and an action\
\9* @param initializerArg - State used during the initial render, or passed to `initializer` if provided\
\9* @param initializer - Optional function that returns an initial state given `initializerArg`\
\9* @returns The current state, and an action dispatcher\
\9*\
\9* @see https://reactjs.org/docs/hooks-reference.html#usereducer\
]]\
-- overload where \"I\" may be a subset of ReducerState<R>; used to provide autocompletion.\
-- If \"I\" matches ReducerState<R> exactly then the last overload will allow initializer to be omitted.\
--[[\
\9*\
\9* Accepts a reducer of type `(state, action) => newState`, and returns the current state paired with a `dispatch`\
\9* method.\
\9*\
\9* If a new state is the same value as the current state, this will bail out without rerendering the component.\
\9*\
\9* `useReducer` is usually preferable to `useState` when you have complex state logic that involves multiple sub-values.\
\9* It also lets you optimize performance for components that trigger deep updates because [you can pass `dispatch` down\
\9* instead of callbacks](https://reactjs.org/docs/hooks-faq.html#how-to-avoid-passing-callbacks-down).\
\9*\
\9* There are two different ways to initialize `useReducer` state. You can use the initial state as a second argument,\
\9* or [create the initial state lazily](https://reactjs.org/docs/hooks-reference.html#lazy-initialization). To do this,\
\9* you can pass an init function as the third argument. The initial state will be set to `initializer(initialArg)`.\
\9*\
\9* @param reducer - Function that returns a state given the current state and an action\
\9* @param initializerArg - State used during the initial render, or passed to `initializer` if provided\
\9* @param initializer - Optional function that returns an initial state given `initializerArg`\
\9* @returns The current state, and an action dispatcher\
\9*\
\9* @see https://reactjs.org/docs/hooks-reference.html#usereducer\
]]\
-- Implementation matches a previous overload, is this required?\
local function useReducer(reducer, initializerArg, initializer)\
\9local currentComponent = resolveCurrentComponent()\
\9local hook = memoizedHook(function()\
\9\9local _result\
\9\9if initializer then\
\9\9\9_result = initializer(initializerArg)\
\9\9else\
\9\9\9_result = initializerArg\
\9\9end\
\9\9return _result\
\9end)\
\9local function dispatch(action)\
\9\9local nextState = reducer(hook.state, action)\
\9\9if hook.state ~= nextState then\
\9\9\9currentComponent:setHookState(hook.id, function()\
\9\9\9\9hook.state = nextState\
\9\9\9\9return hook.state\
\9\9\9end)\
\9\9end\
\9end\
\9return { hook.state, dispatch }\
end\
return {\
\9useReducer = useReducer,\
}\
", '@'.."Orca.include.node_modules.roact-hooked.out.hooks.use-reducer")) setfenv(fn, newEnv("Orca.include.node_modules.roact-hooked.out.hooks.use-reducer")) return fn() end)

newModule("use-ref", "ModuleScript", "Orca.include.node_modules.roact-hooked.out.hooks.use-ref", "Orca.include.node_modules.roact-hooked.out.hooks", function () local fn = assert(loadstring("-- Compiled with roblox-ts v1.2.7\
local TS = _G[script]\
local createRef = TS.import(script, TS.getModule(script, \"@rbxts\", \"roact\").src).createRef\
local memoizedHook = TS.import(script, script.Parent.Parent, \"utils\", \"memoized-hook\").memoizedHook\
--[[\
\9*\
\9* `useRef` returns a memoized *`Ref`*, a special type of binding that points to Roblox Instance objects that are\
\9* created by Roact. The returned object will persist for the full lifetime of the component.\
\9*\
\9* `useMutable()` is handy for keeping any mutable value around similar to how you’d use instance fields in classes.\
\9*\
\9* This is not mutable like React's `useRef` hook. If you want to use a mutable object, refer to {@link useMutable}.\
\9*\
\9* @example\
\9* const ref = useRef<TextBox>();\
\9*\
\9* useEffect(() => {\
\9* \9const textBox = ref.getValue();\
\9* \9if (textBox) {\
\9* \9\9textBox.CaptureFocus();\
\9* \9}\
\9* }, []);\
\9*\
\9* return <textbox Ref={ref} />;\
\9*\
\9* @returns A memoized `Ref` object\
\9*\
\9* @see https://roblox.github.io/roact/advanced/bindings-and-refs/#refs\
]]\
local function useRef()\
\9return memoizedHook(function()\
\9\9return createRef()\
\9end).state\
end\
return {\
\9useRef = useRef,\
}\
", '@'.."Orca.include.node_modules.roact-hooked.out.hooks.use-ref")) setfenv(fn, newEnv("Orca.include.node_modules.roact-hooked.out.hooks.use-ref")) return fn() end)

newModule("use-state", "ModuleScript", "Orca.include.node_modules.roact-hooked.out.hooks.use-state", "Orca.include.node_modules.roact-hooked.out.hooks", function () local fn = assert(loadstring("-- Compiled with roblox-ts v1.2.7\
local TS = _G[script]\
local useReducer = TS.import(script, script.Parent, \"use-reducer\").useReducer\
--[[\
\9*\
\9* Returns a stateful value, and a function to update it.\
\9*\
\9* During the initial render, the returned state (`state`) is the same as the value passed as the first argument\
\9* (`initialState`).\
\9*\
\9* The `setState` function is used to update the state. It always knows the current state, so it's safe to omit from\
\9* the `useEffect` or `useCallback` dependency lists.\
\9*\
\9* If you update a State Hook to the same value as the current state, this will bail out without rerendering the\
\9* component.\
\9*\
\9* @example\
\9* const [state, setState] = useState(initialState);\
\9* const [state, setState] = useState(() => someExpensiveComputation());\
\9* setState(newState);\
\9* setState((prevState) => prevState + 1)\
\9*\
\9* @param initialState - State used during the initial render. Can be a function, which will be executed on initial render\
\9* @returns A stateful value, and an updater function\
\9*\
\9* @see https://reactjs.org/docs/hooks-reference.html#usestate\
]]\
--[[\
\9*\
\9* Returns a stateful value, and a function to update it.\
\9*\
\9* During the initial render, the returned state (`state`) is the same as the value passed as the first argument\
\9* (`initialState`).\
\9*\
\9* The `setState` function is used to update the state. It always knows the current state, so it's safe to omit from\
\9* the `useEffect` or `useCallback` dependency lists.\
\9*\
\9* If you update a State Hook to the same value as the current state, this will bail out without rerendering the\
\9* component.\
\9*\
\9* @example\
\9* const [state, setState] = useState(initialState);\
\9* const [state, setState] = useState(() => someExpensiveComputation());\
\9* setState(newState);\
\9* setState((prevState) => prevState + 1)\
\9*\
\9* @param initialState - State used during the initial render. Can be a function, which will be executed on initial render\
\9* @returns A stateful value, and an updater function\
\9*\
\9* @see https://reactjs.org/docs/hooks-reference.html#usestate\
]]\
--[[\
\9*\
\9* Returns a stateful value, and a function to update it.\
\9*\
\9* During the initial render, the returned state (`state`) is the same as the value passed as the first argument\
\9* (`initialState`).\
\9*\
\9* The `setState` function is used to update the state. It always knows the current state, so it's safe to omit from\
\9* the `useEffect` or `useCallback` dependency lists.\
\9*\
\9* If you update a State Hook to the same value as the current state, this will bail out without rerendering the\
\9* component.\
\9*\
\9* @example\
\9* const [state, setState] = useState(initialState);\
\9* const [state, setState] = useState(() => someExpensiveComputation());\
\9* setState(newState);\
\9* setState((prevState) => prevState + 1)\
\9*\
\9* @param initialState - State used during the initial render. Can be a function, which will be executed on initial render\
\9* @returns A stateful value, and an updater function\
\9*\
\9* @see https://reactjs.org/docs/hooks-reference.html#usestate\
]]\
local function useState(initialState)\
\9local _binding = useReducer(function(state, action)\
\9\9local _result\
\9\9if type(action) == \"function\" then\
\9\9\9_result = action(state)\
\9\9else\
\9\9\9_result = action\
\9\9end\
\9\9return _result\
\9end, nil, function()\
\9\9local _result\
\9\9if type(initialState) == \"function\" then\
\9\9\9_result = initialState()\
\9\9else\
\9\9\9_result = initialState\
\9\9end\
\9\9return _result\
\9end)\
\9local state = _binding[1]\
\9local dispatch = _binding[2]\
\9return { state, dispatch }\
end\
return {\
\9useState = useState,\
}\
", '@'.."Orca.include.node_modules.roact-hooked.out.hooks.use-state")) setfenv(fn, newEnv("Orca.include.node_modules.roact-hooked.out.hooks.use-state")) return fn() end)

newModule("types", "ModuleScript", "Orca.include.node_modules.roact-hooked.out.types", "Orca.include.node_modules.roact-hooked.out", function () local fn = assert(loadstring("-- Compiled with roblox-ts v1.2.7\
-- Roact\
-- Reducers\
-- Utility types\
-- Hooks\
return nil\
", '@'.."Orca.include.node_modules.roact-hooked.out.types")) setfenv(fn, newEnv("Orca.include.node_modules.roact-hooked.out.types")) return fn() end)

newInstance("utils", "Folder", "Orca.include.node_modules.roact-hooked.out.utils", "Orca.include.node_modules.roact-hooked.out")

newModule("are-deps-equal", "ModuleScript", "Orca.include.node_modules.roact-hooked.out.utils.are-deps-equal", "Orca.include.node_modules.roact-hooked.out.utils", function () local fn = assert(loadstring("-- Compiled with roblox-ts v1.2.7\
local function areDepsEqual(nextDeps, prevDeps)\
\9if prevDeps == nil then\
\9\9return false\
\9end\
\9if #nextDeps ~= #prevDeps then\
\9\9return false\
\9end\
\9do\
\9\9local i = 0\
\9\9local _shouldIncrement = false\
\9\9while true do\
\9\9\9if _shouldIncrement then\
\9\9\9\9i += 1\
\9\9\9else\
\9\9\9\9_shouldIncrement = true\
\9\9\9end\
\9\9\9if not (i < #nextDeps) then\
\9\9\9\9break\
\9\9\9end\
\9\9\9if nextDeps[i + 1] == prevDeps[i + 1] then\
\9\9\9\9continue\
\9\9\9end\
\9\9\9return false\
\9\9end\
\9end\
\9return true\
end\
return {\
\9areDepsEqual = areDepsEqual,\
}\
", '@'.."Orca.include.node_modules.roact-hooked.out.utils.are-deps-equal")) setfenv(fn, newEnv("Orca.include.node_modules.roact-hooked.out.utils.are-deps-equal")) return fn() end)

newModule("memoized-hook", "ModuleScript", "Orca.include.node_modules.roact-hooked.out.utils.memoized-hook", "Orca.include.node_modules.roact-hooked.out.utils", function () local fn = assert(loadstring("-- Compiled with roblox-ts v1.2.7\
local EXCEPTION_INVALID_HOOK_CALL = table.concat({ \"Invalid hook call. Hooks can only be called inside of the body of a function component.\", \"This is usually the result of conflicting versions of roact-hooked.\", \"See https://reactjs.org/link/invalid-hook-call for tips about how to debug and fix this problem.\" }, \"\\n\")\
local EXCEPTION_RENDER_NOT_DONE = \"Failed to render hook! (Another hooked component is rendering)\"\
local EXCEPTION_RENDER_OVERLAP = \"Failed to render hook! (Another hooked component rendered during this one)\"\
local currentHook\
local currentlyRenderingComponent\
--[[\
\9*\
\9* Prepares for an upcoming render.\
]]\
local function renderReady(component)\
\9local _arg0 = currentlyRenderingComponent == nil\
\9assert(_arg0, EXCEPTION_RENDER_NOT_DONE)\
\9currentlyRenderingComponent = component\
end\
--[[\
\9*\
\9* Cleans up hooks. Must be called after finishing a render!\
]]\
local function renderDone(component)\
\9local _arg0 = currentlyRenderingComponent == component\
\9assert(_arg0, EXCEPTION_RENDER_OVERLAP)\
\9currentlyRenderingComponent = nil\
\9currentHook = nil\
end\
--[[\
\9*\
\9* Returns the currently-rendering component. Throws an error if a component is not mid-render.\
]]\
local function resolveCurrentComponent()\
\9return currentlyRenderingComponent or error(EXCEPTION_INVALID_HOOK_CALL, 3)\
end\
--[[\
\9*\
\9* Gets or creates a new hook. Hooks are memoized for every component. See the original source\
\9* {@link https://github.com/facebook/react/blob/main/packages/react-reconciler/src/ReactFiberHooks.new.js#L619 here}.\
\9*\
\9* @param initialValue - Initial value for `Hook.state` and `Hook.baseState`.\
]]\
local function memoizedHook(initialValue)\
\9local currentlyRenderingComponent = resolveCurrentComponent()\
\9local _result\
\9if currentHook then\
\9\9_result = currentHook.next\
\9else\
\9\9_result = currentlyRenderingComponent.firstHook\
\9end\
\9local nextHook = _result\
\9if nextHook then\
\9\9-- The hook has already been created\
\9\9currentHook = nextHook\
\9else\
\9\9-- This is a new hook, should be from an initial render\
\9\9local _result_1\
\9\9if type(initialValue) == \"function\" then\
\9\9\9_result_1 = initialValue()\
\9\9else\
\9\9\9_result_1 = initialValue\
\9\9end\
\9\9local state = _result_1\
\9\9local newHook = {\
\9\9\9id = currentHook and currentHook.id + 1 or 0,\
\9\9\9state = state,\
\9\9\9baseState = state,\
\9\9}\
\9\9if not currentHook then\
\9\9\9-- This is the first hook in the list\
\9\9\9currentHook = newHook\
\9\9\9currentlyRenderingComponent.firstHook = currentHook\
\9\9else\
\9\9\9-- Append to the end of the list\
\9\9\9currentHook.next = newHook\
\9\9\9currentHook = currentHook.next\
\9\9end\
\9end\
\9return currentHook\
end\
return {\
\9renderReady = renderReady,\
\9renderDone = renderDone,\
\9resolveCurrentComponent = resolveCurrentComponent,\
\9memoizedHook = memoizedHook,\
}\
", '@'.."Orca.include.node_modules.roact-hooked.out.utils.memoized-hook")) setfenv(fn, newEnv("Orca.include.node_modules.roact-hooked.out.utils.memoized-hook")) return fn() end)

newModule("with-hooks", "ModuleScript", "Orca.include.node_modules.roact-hooked.out.with-hooks", "Orca.include.node_modules.roact-hooked.out", function () local fn = assert(loadstring("-- Compiled with roblox-ts v1.2.7\
local TS = _G[script]\
local exports = {}\
local _with_hooks = TS.import(script, script, \"with-hooks\")\
exports.withHooks = _with_hooks.withHooks\
exports.withHooksPure = _with_hooks.withHooksPure\
return exports\
", '@'.."Orca.include.node_modules.roact-hooked.out.with-hooks")) setfenv(fn, newEnv("Orca.include.node_modules.roact-hooked.out.with-hooks")) return fn() end)

newModule("component-with-hooks", "ModuleScript", "Orca.include.node_modules.roact-hooked.out.with-hooks.component-with-hooks", "Orca.include.node_modules.roact-hooked.out.with-hooks", function () local fn = assert(loadstring("-- Compiled with roblox-ts v1.2.7\
local TS = _G[script]\
local _memoized_hook = TS.import(script, script.Parent.Parent, \"utils\", \"memoized-hook\")\
local renderDone = _memoized_hook.renderDone\
local renderReady = _memoized_hook.renderReady\
local ComponentWithHooks\
do\
\9ComponentWithHooks = {}\
\9function ComponentWithHooks:constructor()\
\9end\
\9function ComponentWithHooks:init()\
\9\9self.effects = {}\
\9\9self.effectHandles = {}\
\9end\
\9function ComponentWithHooks:setHookState(id, reducer)\
\9\9self:setState(function(state)\
\9\9\9return {\
\9\9\9\9[id] = reducer(state[id]),\
\9\9\9}\
\9\9end)\
\9end\
\9function ComponentWithHooks:render()\
\9\9renderReady(self)\
\9\9local _functionComponent = self.functionComponent\
\9\9local _props = self.props\
\9\9local _success, _valueOrError = pcall(_functionComponent, _props)\
\9\9local result = _success and {\
\9\9\9success = true,\
\9\9\9value = _valueOrError,\
\9\9} or {\
\9\9\9success = false,\
\9\9\9error = _valueOrError,\
\9\9}\
\9\9renderDone(self)\
\9\9if not result.success then\
\9\9\9error(\"(ComponentWithHooks) \" .. result.error)\
\9\9end\
\9\9return result.value\
\9end\
\9function ComponentWithHooks:didMount()\
\9\9self:flushEffects()\
\9end\
\9function ComponentWithHooks:didUpdate()\
\9\9self:flushEffects()\
\9end\
\9function ComponentWithHooks:willUnmount()\
\9\9self:unmountEffects()\
\9\9self.effects.head = nil\
\9end\
\9function ComponentWithHooks:flushEffectsHelper(effect)\
\9\9if not effect then\
\9\9\9return nil\
\9\9end\
\9\9local _effectHandles = self.effectHandles\
\9\9local _id = effect.id\
\9\9local _result = _effectHandles[_id]\
\9\9if _result ~= nil then\
\9\9\9_result()\
\9\9end\
\9\9local handle = effect.callback()\
\9\9if handle then\
\9\9\9local _effectHandles_1 = self.effectHandles\
\9\9\9local _id_1 = effect.id\
\9\9\9-- ▼ Map.set ▼\
\9\9\9_effectHandles_1[_id_1] = handle\
\9\9\9-- ▲ Map.set ▲\
\9\9end\
\9\9self:flushEffectsHelper(effect.next)\
\9end\
\9function ComponentWithHooks:flushEffects()\
\9\9self:flushEffectsHelper(self.effects.head)\
\9\9self.effects.head = nil\
\9\9self.effects.tail = nil\
\9end\
\9function ComponentWithHooks:unmountEffects()\
\9\9-- This does not clean up effects by order of id, but it should not matter\
\9\9-- because this is on unmount\
\9\9local _effectHandles = self.effectHandles\
\9\9local _arg0 = function(handle)\
\9\9\9return handle()\
\9\9end\
\9\9-- ▼ ReadonlyMap.forEach ▼\
\9\9for _k, _v in pairs(_effectHandles) do\
\9\9\9_arg0(_v, _k, _effectHandles)\
\9\9end\
\9\9-- ▲ ReadonlyMap.forEach ▲\
\9\9-- ▼ Map.clear ▼\
\9\9table.clear(self.effectHandles)\
\9\9-- ▲ Map.clear ▲\
\9end\
end\
return {\
\9ComponentWithHooks = ComponentWithHooks,\
}\
", '@'.."Orca.include.node_modules.roact-hooked.out.with-hooks.component-with-hooks")) setfenv(fn, newEnv("Orca.include.node_modules.roact-hooked.out.with-hooks.component-with-hooks")) return fn() end)

newModule("with-hooks", "ModuleScript", "Orca.include.node_modules.roact-hooked.out.with-hooks.with-hooks", "Orca.include.node_modules.roact-hooked.out.with-hooks", function () local fn = assert(loadstring("-- Compiled with roblox-ts v1.2.7\
local TS = _G[script]\
local ComponentWithHooks = TS.import(script, script.Parent, \"component-with-hooks\").ComponentWithHooks\
local Roact = TS.import(script, TS.getModule(script, \"@rbxts\", \"roact\").src)\
local function componentWithHooksMixin(ctor)\
\9for k, v in pairs(ComponentWithHooks) do\
\9\9ctor[k] = v\
\9end\
end\
local function withHooks(functionComponent)\
\9local ComponentClass\
\9do\
\9\9ComponentClass = Roact.Component:extend(\"ComponentClass\")\
\9\9function ComponentClass:init()\
\9\9end\
\9\9ComponentClass.functionComponent = functionComponent\
\9end\
\9componentWithHooksMixin(ComponentClass)\
\9return ComponentClass\
end\
local function withHooksPure(functionComponent)\
\9local ComponentClass\
\9do\
\9\9ComponentClass = Roact.PureComponent:extend(\"ComponentClass\")\
\9\9function ComponentClass:init()\
\9\9end\
\9\9ComponentClass.functionComponent = functionComponent\
\9end\
\9componentWithHooksMixin(ComponentClass)\
\9return ComponentClass\
end\
return {\
\9withHooks = withHooks,\
\9withHooksPure = withHooksPure,\
}\
", '@'.."Orca.include.node_modules.roact-hooked.out.with-hooks.with-hooks")) setfenv(fn, newEnv("Orca.include.node_modules.roact-hooked.out.with-hooks.with-hooks")) return fn() end)

newInstance("roact-rodux-hooked", "Folder", "Orca.include.node_modules.roact-rodux-hooked", "Orca.include.node_modules")

newModule("out", "ModuleScript", "Orca.include.node_modules.roact-rodux-hooked.out", "Orca.include.node_modules.roact-rodux-hooked", function () local fn = assert(loadstring("-- Compiled with roblox-ts v1.2.3\
local TS = _G[script]\
local exports = {}\
exports.Provider = TS.import(script, script, \"components\", \"provider\").Provider\
exports.useDispatch = TS.import(script, script, \"hooks\", \"use-dispatch\").useDispatch\
exports.useSelector = TS.import(script, script, \"hooks\", \"use-selector\").useSelector\
exports.useStore = TS.import(script, script, \"hooks\", \"use-store\").useStore\
exports.shallowEqual = TS.import(script, script, \"helpers\", \"shallow-equal\").shallowEqual\
exports.RoactRoduxContext = TS.import(script, script, \"components\", \"context\").RoactRoduxContext\
return exports\
", '@'.."Orca.include.node_modules.roact-rodux-hooked.out")) setfenv(fn, newEnv("Orca.include.node_modules.roact-rodux-hooked.out")) return fn() end)

newInstance("components", "Folder", "Orca.include.node_modules.roact-rodux-hooked.out.components", "Orca.include.node_modules.roact-rodux-hooked.out")

newModule("context", "ModuleScript", "Orca.include.node_modules.roact-rodux-hooked.out.components.context", "Orca.include.node_modules.roact-rodux-hooked.out.components", function () local fn = assert(loadstring("-- Compiled with roblox-ts v1.2.3\
local TS = _G[script]\
local Roact = TS.import(script, TS.getModule(script, \"@rbxts\", \"roact\").src)\
local RoactRoduxContext = Roact.createContext(nil)\
return {\
\9RoactRoduxContext = RoactRoduxContext,\
}\
", '@'.."Orca.include.node_modules.roact-rodux-hooked.out.components.context")) setfenv(fn, newEnv("Orca.include.node_modules.roact-rodux-hooked.out.components.context")) return fn() end)

newModule("provider", "ModuleScript", "Orca.include.node_modules.roact-rodux-hooked.out.components.provider", "Orca.include.node_modules.roact-rodux-hooked.out.components", function () local fn = assert(loadstring("-- Compiled with roblox-ts v1.2.3\
local TS = _G[script]\
local RoactRoduxContext = TS.import(script, script.Parent, \"context\").RoactRoduxContext\
local _roact_hooked = TS.import(script, TS.getModule(script, \"@rbxts\", \"roact-hooked\").out)\
local hooked = _roact_hooked.hooked\
local useMemo = _roact_hooked.useMemo\
local Roact = TS.import(script, TS.getModule(script, \"@rbxts\", \"roact\").src)\
--[[\
\9*\
\9* Makes the Rodux store available to the `useStore()` calls in the component hierarchy below.\
]]\
local Provider = hooked(function(_param)\
\9local store = _param.store\
\9local children = _param[Roact.Children]\
\9local contextValue = useMemo(function()\
\9\9return {\
\9\9\9store = store,\
\9\9}\
\9end, { store })\
\9local _ptr = {\
\9\9value = contextValue,\
\9}\
\9local _ptr_1 = {}\
\9local _length = #_ptr_1\
\9if children then\
\9\9for _k, _v in pairs(children) do\
\9\9\9if type(_k) == \"number\" then\
\9\9\9\9_ptr_1[_length + _k] = _v\
\9\9\9else\
\9\9\9\9_ptr_1[_k] = _v\
\9\9\9end\
\9\9end\
\9end\
\9return Roact.createElement(RoactRoduxContext.Provider, _ptr, _ptr_1)\
end)\
return {\
\9Provider = Provider,\
}\
", '@'.."Orca.include.node_modules.roact-rodux-hooked.out.components.provider")) setfenv(fn, newEnv("Orca.include.node_modules.roact-rodux-hooked.out.components.provider")) return fn() end)

newInstance("helpers", "Folder", "Orca.include.node_modules.roact-rodux-hooked.out.helpers", "Orca.include.node_modules.roact-rodux-hooked.out")

newModule("shallow-equal", "ModuleScript", "Orca.include.node_modules.roact-rodux-hooked.out.helpers.shallow-equal", "Orca.include.node_modules.roact-rodux-hooked.out.helpers", function () local fn = assert(loadstring("-- Compiled with roblox-ts v1.2.3\
local TS = _G[script]\
local Object = TS.import(script, TS.getModule(script, \"@rbxts\", \"object-utils\"))\
--[[\
\9*\
\9* Compares two arbitrary values for shallow equality. Object values are compared based on their keys, i.e. they must\
\9* have the same keys and for each key the value must be equal.\
]]\
local function shallowEqual(left, right)\
\9if left == right then\
\9\9return true\
\9end\
\9if not (type(left) == \"table\") or not (type(right) == \"table\") then\
\9\9return false\
\9end\
\9local keysLeft = Object.keys(left)\
\9local keysRight = Object.keys(right)\
\9if #keysLeft ~= #keysRight then\
\9\9return false\
\9end\
\9local _arg0 = function(value, index)\
\9\9return value == right[index]\
\9end\
\9-- ▼ ReadonlyArray.every ▼\
\9local _result = true\
\9for _k, _v in ipairs(keysLeft) do\
\9\9if not _arg0(_v, _k - 1, keysLeft) then\
\9\9\9_result = false\
\9\9\9break\
\9\9end\
\9end\
\9-- ▲ ReadonlyArray.every ▲\
\9return _result\
end\
return {\
\9shallowEqual = shallowEqual,\
}\
", '@'.."Orca.include.node_modules.roact-rodux-hooked.out.helpers.shallow-equal")) setfenv(fn, newEnv("Orca.include.node_modules.roact-rodux-hooked.out.helpers.shallow-equal")) return fn() end)

newInstance("hooks", "Folder", "Orca.include.node_modules.roact-rodux-hooked.out.hooks", "Orca.include.node_modules.roact-rodux-hooked.out")

newModule("use-dispatch", "ModuleScript", "Orca.include.node_modules.roact-rodux-hooked.out.hooks.use-dispatch", "Orca.include.node_modules.roact-rodux-hooked.out.hooks", function () local fn = assert(loadstring("-- Compiled with roblox-ts v1.2.3\
local TS = _G[script]\
local useMutable = TS.import(script, TS.getModule(script, \"@rbxts\", \"roact-hooked\").out).useMutable\
local useStore = TS.import(script, script.Parent, \"use-store\").useStore\
--[[\
\9*\
\9* A hook to access the Rodux Store's `dispatch` method.\
\9*\
\9* @returns Rodux store's `dispatch` method\
\9*\
\9* @example\
\9* import Roact from \"@rbxts/roact\";\
\9* import { hooked } from \"@rbxts/roact-hooked\";\
\9* import { useDispatch } from \"@rbxts/roact-rodux-hooked\";\
\9* import type { RootStore } from \"./store\";\
\9*\
\9* export const CounterComponent = hooked(() => {\
\9*   const dispatch = useDispatch<RootStore>();\
\9*   return (\
\9*     <textlabel\
\9*       Text={\"Increase counter\"}\
\9*       Event={{\
\9*         Activated: () => dispatch({ type: \"increase-counter\" }),\
\9*       }}\
\9*     />\
\9*   );\
\9* });\
]]\
local function useDispatch()\
\9local store = useStore()\
\9return useMutable(function(action)\
\9\9return store:dispatch(action)\
\9end).current\
end\
return {\
\9useDispatch = useDispatch,\
}\
", '@'.."Orca.include.node_modules.roact-rodux-hooked.out.hooks.use-dispatch")) setfenv(fn, newEnv("Orca.include.node_modules.roact-rodux-hooked.out.hooks.use-dispatch")) return fn() end)

newModule("use-selector", "ModuleScript", "Orca.include.node_modules.roact-rodux-hooked.out.hooks.use-selector", "Orca.include.node_modules.roact-rodux-hooked.out.hooks", function () local fn = assert(loadstring("-- Compiled with roblox-ts v1.2.3\
local TS = _G[script]\
local _roact_hooked = TS.import(script, TS.getModule(script, \"@rbxts\", \"roact-hooked\").out)\
local useEffect = _roact_hooked.useEffect\
local useMutable = _roact_hooked.useMutable\
local useReducer = _roact_hooked.useReducer\
local useStore = TS.import(script, script.Parent, \"use-store\").useStore\
--[[\
\9*\
\9* This interface allows you to easily create a hook that is properly typed for your store's root state.\
\9*\
\9* @example\
\9* interface RootState {\
\9*   property: string;\
\9* }\
\9*\
\9* const useAppSelector: TypedUseSelectorHook<RootState> = useSelector;\
]]\
--[[\
\9*\
\9* A hook to access the Rodux Store's state. This hook takes a selector function as an argument. The selector is called\
\9* with the store state.\
\9*\
\9* This hook takes an optional equality comparison function as the second parameter that allows you to customize the\
\9* way the selected state is compared to determine whether the component needs to be re-rendered.\
\9*\
\9* @param selector - The selector function\
\9* @param equalityFn - The function that will be used to determine equality\
\9*\
\9* @returns The selected portion of the state\
\9*\
\9* @example\
\9* import Roact from \"@rbxts/roact\";\
\9* import { hooked } from \"@rbxts/roact-hooked\";\
\9* import { useSelector } from \"@rbxts/roact-rodux-hooked\";\
\9* import type { RootState } from \"./store\";\
\9*\
\9* export const CounterComponent = hooked(() => {\
\9*   const count = useSelector((state: RootState) => state.counter);\
\9*   return <textlabel Text={`Counter: ${count}`} />;\
\9* });\
]]\
local function useSelector(selector, equalityFn)\
\9if equalityFn == nil then\
\9\9equalityFn = function(a, b)\
\9\9\9return a == b\
\9\9end\
\9end\
\9local _binding = useReducer(function(s)\
\9\9return s + 1\
\9end, 0)\
\9local forceRender = _binding[2]\
\9local store = useStore()\
\9local latestSubscriptionCallbackError = useMutable()\
\9local latestSelector = useMutable()\
\9local latestStoreState = useMutable()\
\9local latestSelectedState = useMutable()\
\9local storeState = store:getState()\
\9local selectedState\
\9TS.try(function()\
\9\9local _value = selector ~= latestSelector.current or storeState ~= latestStoreState.current or latestSubscriptionCallbackError.current\
\9\9if _value ~= \"\" and _value then\
\9\9\9local newSelectedState = selector(storeState)\
\9\9\9-- ensure latest selected state is reused so that a custom equality function can result in identical references\
\9\9\9if latestSelectedState.current == nil or not equalityFn(newSelectedState, latestSelectedState.current) then\
\9\9\9\9selectedState = newSelectedState\
\9\9\9else\
\9\9\9\9selectedState = latestSelectedState.current\
\9\9\9end\
\9\9else\
\9\9\9selectedState = latestSelectedState.current\
\9\9end\
\9end, function(err)\
\9\9if latestSubscriptionCallbackError.current ~= nil then\
\9\9\9err ..= \"\\nThe error may be correlated with this previous error:\\n\" .. latestSubscriptionCallbackError.current .. \"\\n\\n\"\
\9\9end\
\9\9error(err)\
\9end)\
\9useEffect(function()\
\9\9latestSelector.current = selector\
\9\9latestStoreState.current = storeState\
\9\9latestSelectedState.current = selectedState\
\9\9latestSubscriptionCallbackError.current = nil\
\9end)\
\9useEffect(function()\
\9\9local function checkForUpdates(newStoreState)\
\9\9\9local _exitType, _returns = TS.try(function()\
\9\9\9\9-- Avoid calling selector multiple times if the store's state has not changed\
\9\9\9\9if newStoreState == latestStoreState.current then\
\9\9\9\9\9return TS.TRY_RETURN, {}\
\9\9\9\9end\
\9\9\9\9local newSelectedState = latestSelector.current(newStoreState)\
\9\9\9\9if equalityFn(newSelectedState, latestSelectedState.current) then\
\9\9\9\9\9return TS.TRY_RETURN, {}\
\9\9\9\9end\
\9\9\9\9latestSelectedState.current = newSelectedState\
\9\9\9\9latestStoreState.current = newStoreState\
\9\9\9end, function(err)\
\9\9\9\9-- we ignore all errors here, since when the component\
\9\9\9\9-- is re-rendered, the selectors are called again, and\
\9\9\9\9-- will throw again, if neither props nor store state\
\9\9\9\9-- changed\
\9\9\9\9latestSubscriptionCallbackError.current = err\
\9\9\9end)\
\9\9\9if _exitType then\
\9\9\9\9return unpack(_returns)\
\9\9\9end\
\9\9\9task.spawn(forceRender)\
\9\9end\
\9\9local subscription = store.changed:connect(checkForUpdates)\
\9\9checkForUpdates(store:getState())\
\9\9return function()\
\9\9\9return subscription:disconnect()\
\9\9end\
\9end, { store })\
\9return selectedState\
end\
return {\
\9useSelector = useSelector,\
}\
", '@'.."Orca.include.node_modules.roact-rodux-hooked.out.hooks.use-selector")) setfenv(fn, newEnv("Orca.include.node_modules.roact-rodux-hooked.out.hooks.use-selector")) return fn() end)

newModule("use-store", "ModuleScript", "Orca.include.node_modules.roact-rodux-hooked.out.hooks.use-store", "Orca.include.node_modules.roact-rodux-hooked.out.hooks", function () local fn = assert(loadstring("-- Compiled with roblox-ts v1.2.3\
local TS = _G[script]\
local RoactRoduxContext = TS.import(script, script.Parent.Parent, \"components\", \"context\").RoactRoduxContext\
local useContext = TS.import(script, TS.getModule(script, \"@rbxts\", \"roact-hooked\").out).useContext\
--[[\
\9*\
\9* A hook to access the Rodux Store.\
\9*\
\9* @returns The Rodux store\
\9*\
\9* @example\
\9* import Roact from \"@rbxts/roact\";\
\9* import { hooked } from \"@rbxts/roact-hooked\";\
\9* import { useStore } from \"@rbxts/roact-rodux-hooked\";\
\9* import type { RootStore } from \"./store\";\
\9*\
\9* export const CounterComponent = hooked(() => {\
\9*   const store = useStore<RootStore>();\
\9*   return <textlabel Text={store.getState()} />;\
\9* });\
]]\
local function useStore()\
\9return useContext(RoactRoduxContext).store\
end\
return {\
\9useStore = useStore,\
}\
", '@'.."Orca.include.node_modules.roact-rodux-hooked.out.hooks.use-store")) setfenv(fn, newEnv("Orca.include.node_modules.roact-rodux-hooked.out.hooks.use-store")) return fn() end)

newModule("types", "ModuleScript", "Orca.include.node_modules.roact-rodux-hooked.out.types", "Orca.include.node_modules.roact-rodux-hooked.out", function () local fn = assert(loadstring("-- Compiled with roblox-ts v1.2.3\
--[[\
\9*\
\9* A Roact Context\
]]\
return nil\
", '@'.."Orca.include.node_modules.roact-rodux-hooked.out.types")) setfenv(fn, newEnv("Orca.include.node_modules.roact-rodux-hooked.out.types")) return fn() end)

newInstance("rodux", "Folder", "Orca.include.node_modules.rodux", "Orca.include.node_modules")

newModule("src", "ModuleScript", "Orca.include.node_modules.rodux.src", "Orca.include.node_modules.rodux", function () local fn = assert(loadstring("local Store = require(script.Store)\
local createReducer = require(script.createReducer)\
local combineReducers = require(script.combineReducers)\
local makeActionCreator = require(script.makeActionCreator)\
local loggerMiddleware = require(script.loggerMiddleware)\
local thunkMiddleware = require(script.thunkMiddleware)\
\
return {\
\9Store = Store,\
\9createReducer = createReducer,\
\9combineReducers = combineReducers,\
\9makeActionCreator = makeActionCreator,\
\9loggerMiddleware = loggerMiddleware.middleware,\
\9thunkMiddleware = thunkMiddleware,\
}\
", '@'.."Orca.include.node_modules.rodux.src")) setfenv(fn, newEnv("Orca.include.node_modules.rodux.src")) return fn() end)

newModule("NoYield", "ModuleScript", "Orca.include.node_modules.rodux.src.NoYield", "Orca.include.node_modules.rodux.src", function () local fn = assert(loadstring("--!nocheck\
\
--[[\
\9Calls a function and throws an error if it attempts to yield.\
\
\9Pass any number of arguments to the function after the callback.\
\
\9This function supports multiple return; all results returned from the\
\9given function will be returned.\
]]\
\
local function resultHandler(co, ok, ...)\
\9if not ok then\
\9\9local message = (...)\
\9\9error(debug.traceback(co, message), 2)\
\9end\
\
\9if coroutine.status(co) ~= \"dead\" then\
\9\9error(debug.traceback(co, \"Attempted to yield inside changed event!\"), 2)\
\9end\
\
\9return ...\
end\
\
local function NoYield(callback, ...)\
\9local co = coroutine.create(callback)\
\
\9return resultHandler(co, coroutine.resume(co, ...))\
end\
\
return NoYield\
", '@'.."Orca.include.node_modules.rodux.src.NoYield")) setfenv(fn, newEnv("Orca.include.node_modules.rodux.src.NoYield")) return fn() end)

newModule("Signal", "ModuleScript", "Orca.include.node_modules.rodux.src.Signal", "Orca.include.node_modules.rodux.src", function () local fn = assert(loadstring("--[[\
\9A limited, simple implementation of a Signal.\
\
\9Handlers are fired in order, and (dis)connections are properly handled when\
\9executing an event.\
]]\
local function immutableAppend(list, ...)\
\9local new = {}\
\9local len = #list\
\
\9for key = 1, len do\
\9\9new[key] = list[key]\
\9end\
\
\9for i = 1, select(\"#\", ...) do\
\9\9new[len + i] = select(i, ...)\
\9end\
\
\9return new\
end\
\
local function immutableRemoveValue(list, removeValue)\
\9local new = {}\
\
\9for i = 1, #list do\
\9\9if list[i] ~= removeValue then\
\9\9\9table.insert(new, list[i])\
\9\9end\
\9end\
\
\9return new\
end\
\
local Signal = {}\
\
Signal.__index = Signal\
\
function Signal.new(store)\
\9local self = {\
\9\9_listeners = {},\
\9\9_store = store\
\9}\
\
\9setmetatable(self, Signal)\
\
\9return self\
end\
\
function Signal:connect(callback)\
\9if typeof(callback) ~= \"function\" then\
\9\9error(\"Expected the listener to be a function.\")\
\9end\
\
\9if self._store and self._store._isDispatching then\
\9\9error(\
\9\9\9'You may not call store.changed:connect() while the reducer is executing. ' ..\
\9\9\9\9'If you would like to be notified after the store has been updated, subscribe from a ' ..\
\9\9\9\9'component and invoke store:getState() in the callback to access the latest state. '\
\9\9)\
\9end\
\
\9local listener = {\
\9\9callback = callback,\
\9\9disconnected = false,\
\9\9connectTraceback = debug.traceback(),\
\9\9disconnectTraceback = nil\
\9}\
\
\9self._listeners = immutableAppend(self._listeners, listener)\
\
\9local function disconnect()\
\9\9if listener.disconnected then\
\9\9\9error((\
\9\9\9\9\"Listener connected at: \\n%s\\n\" ..\
\9\9\9\9\"was already disconnected at: \\n%s\\n\"\
\9\9\9):format(\
\9\9\9\9tostring(listener.connectTraceback),\
\9\9\9\9tostring(listener.disconnectTraceback)\
\9\9\9))\
\9\9end\
\
\9\9if self._store and self._store._isDispatching then\
\9\9\9error(\"You may not unsubscribe from a store listener while the reducer is executing.\")\
\9\9end\
\
\9\9listener.disconnected = true\
\9\9listener.disconnectTraceback = debug.traceback()\
\9\9self._listeners = immutableRemoveValue(self._listeners, listener)\
\9end\
\
\9return {\
\9\9disconnect = disconnect\
\9}\
end\
\
function Signal:fire(...)\
\9for _, listener in ipairs(self._listeners) do\
\9\9if not listener.disconnected then\
\9\9\9listener.callback(...)\
\9\9end\
\9end\
end\
\
return Signal", '@'.."Orca.include.node_modules.rodux.src.Signal")) setfenv(fn, newEnv("Orca.include.node_modules.rodux.src.Signal")) return fn() end)

newModule("Store", "ModuleScript", "Orca.include.node_modules.rodux.src.Store", "Orca.include.node_modules.rodux.src", function () local fn = assert(loadstring("local RunService = game:GetService(\"RunService\")\
\
local Signal = require(script.Parent.Signal)\
local NoYield = require(script.Parent.NoYield)\
\
local ACTION_LOG_LENGTH = 3\
\
local rethrowErrorReporter = {\
\9reportReducerError = function(prevState, action, errorResult)\
\9\9error(string.format(\"Received error: %s\\n\\n%s\", errorResult.message, errorResult.thrownValue))\
\9end,\
\9reportUpdateError = function(prevState, currentState, lastActions, errorResult)\
\9\9error(string.format(\"Received error: %s\\n\\n%s\", errorResult.message, errorResult.thrownValue))\
\9end,\
}\
\
local function tracebackReporter(message)\
\9return debug.traceback(tostring(message))\
end\
\
local Store = {}\
\
-- This value is exposed as a private value so that the test code can stay in\
-- sync with what event we listen to for dispatching the Changed event.\
-- It may not be Heartbeat in the future.\
Store._flushEvent = RunService.Heartbeat\
\
Store.__index = Store\
\
--[[\
\9Create a new Store whose state is transformed by the given reducer function.\
\
\9Each time an action is dispatched to the store, the new state of the store\
\9is given by:\
\
\9\9state = reducer(state, action)\
\
\9Reducers do not mutate the state object, so the original state is still\
\9valid.\
]]\
function Store.new(reducer, initialState, middlewares, errorReporter)\
\9assert(typeof(reducer) == \"function\", \"Bad argument #1 to Store.new, expected function.\")\
\9assert(middlewares == nil or typeof(middlewares) == \"table\", \"Bad argument #3 to Store.new, expected nil or table.\")\
\9if middlewares ~= nil then\
\9\9for i=1, #middlewares, 1 do\
\9\9\9assert(\
\9\9\9\9typeof(middlewares[i]) == \"function\",\
\9\9\9\9(\"Expected the middleware ('%s') at index %d to be a function.\"):format(tostring(middlewares[i]), i)\
\9\9\9)\
\9\9end\
\9end\
\
\9local self = {}\
\
\9self._errorReporter = errorReporter or rethrowErrorReporter\
\9self._isDispatching = false\
\9self._reducer = reducer\
\9local initAction = {\
\9\9type = \"@@INIT\",\
\9}\
\9self._actionLog = { initAction }\
\9local ok, result = xpcall(function()\
\9\9self._state = reducer(initialState, initAction)\
\9end, tracebackReporter)\
\9if not ok then\
\9\9self._errorReporter.reportReducerError(initialState, initAction, {\
\9\9\9message = \"Caught error in reducer with init\",\
\9\9\9thrownValue = result,\
\9\9})\
\9\9self._state = initialState\
\9end\
\9self._lastState = self._state\
\
\9self._mutatedSinceFlush = false\
\9self._connections = {}\
\
\9self.changed = Signal.new(self)\
\
\9setmetatable(self, Store)\
\
\9local connection = self._flushEvent:Connect(function()\
\9\9self:flush()\
\9end)\
\9table.insert(self._connections, connection)\
\
\9if middlewares then\
\9\9local unboundDispatch = self.dispatch\
\9\9local dispatch = function(...)\
\9\9\9return unboundDispatch(self, ...)\
\9\9end\
\
\9\9for i = #middlewares, 1, -1 do\
\9\9\9local middleware = middlewares[i]\
\9\9\9dispatch = middleware(dispatch, self)\
\9\9end\
\
\9\9self.dispatch = function(_self, ...)\
\9\9\9return dispatch(...)\
\9\9end\
\9end\
\
\9return self\
end\
\
--[[\
\9Get the current state of the Store. Do not mutate this!\
]]\
function Store:getState()\
\9if self._isDispatching then\
\9\9error((\"You may not call store:getState() while the reducer is executing. \" ..\
\9\9\9\"The reducer (%s) has already received the state as an argument. \" ..\
\9\9\9\"Pass it down from the top reducer instead of reading it from the store.\"):format(tostring(self._reducer)))\
\9end\
\
\9return self._state\
end\
\
--[[\
\9Dispatch an action to the store. This allows the store's reducer to mutate\
\9the state of the application by creating a new copy of the state.\
\
\9Listeners on the changed event of the store are notified when the state\
\9changes, but not necessarily on every Dispatch.\
]]\
function Store:dispatch(action)\
\9if typeof(action) ~= \"table\" then\
\9\9error((\"Actions must be tables. \" ..\
\9\9\9\"Use custom middleware for %q actions.\"):format(typeof(action)),\
\9\9\0092\
\9\9)\
\9end\
\
\9if action.type == nil then\
\9\9error(\"Actions may not have an undefined 'type' property. \" ..\
\9\9\9\"Have you misspelled a constant? \\n\" ..\
\9\9\9tostring(action), 2)\
\9end\
\
\9if self._isDispatching then\
\9\9error(\"Reducers may not dispatch actions.\")\
\9end\
\
\9local ok, result = pcall(function()\
\9\9self._isDispatching = true\
\9\9self._state = self._reducer(self._state, action)\
\9\9self._mutatedSinceFlush = true\
\9end)\
\
\9self._isDispatching = false\
\
\9if not ok then\
\9\9self._errorReporter.reportReducerError(\
\9\9\9self._state,\
\9\9\9action,\
\9\9\9{\
\9\9\9\9message = \"Caught error in reducer\",\
\9\9\9\9thrownValue = result,\
\9\9\9}\
\9\9)\
\9end\
\
\9if #self._actionLog == ACTION_LOG_LENGTH then\
\9\9table.remove(self._actionLog, 1)\
\9end\
\9table.insert(self._actionLog, action)\
end\
\
--[[\
\9Marks the store as deleted, disconnecting any outstanding connections.\
]]\
function Store:destruct()\
\9for _, connection in ipairs(self._connections) do\
\9\9connection:Disconnect()\
\9end\
\
\9self._connections = nil\
end\
\
--[[\
\9Flush all pending actions since the last change event was dispatched.\
]]\
function Store:flush()\
\9if not self._mutatedSinceFlush then\
\9\9return\
\9end\
\
\9self._mutatedSinceFlush = false\
\
\9-- On self.changed:fire(), further actions may be immediately dispatched, in\
\9-- which case self._lastState will be set to the most recent self._state,\
\9-- unless we cache this value first\
\9local state = self._state\
\
\9local ok, errorResult = xpcall(function()\
\9\9-- If a changed listener yields, *very* surprising bugs can ensue.\
\9\9-- Because of that, changed listeners cannot yield.\
\9\9NoYield(function()\
\9\9\9self.changed:fire(state, self._lastState)\
\9\9end)\
\9end, tracebackReporter)\
\
\9if not ok then\
\9\9self._errorReporter.reportUpdateError(\
\9\9\9self._lastState,\
\9\9\9state,\
\9\9\9self._actionLog,\
\9\9\9{\
\9\9\9\9message = \"Caught error flushing store updates\",\
\9\9\9\9thrownValue = errorResult,\
\9\9\9}\
\9\9)\
\9end\
\
\9self._lastState = state\
end\
\
return Store\
", '@'.."Orca.include.node_modules.rodux.src.Store")) setfenv(fn, newEnv("Orca.include.node_modules.rodux.src.Store")) return fn() end)

newModule("combineReducers", "ModuleScript", "Orca.include.node_modules.rodux.src.combineReducers", "Orca.include.node_modules.rodux.src", function () local fn = assert(loadstring("--[[\
\9Create a composite reducer from a map of keys and sub-reducers.\
]]\
local function combineReducers(map)\
\9return function(state, action)\
\9\9-- If state is nil, substitute it with a blank table.\
\9\9if state == nil then\
\9\9\9state = {}\
\9\9end\
\
\9\9local newState = {}\
\
\9\9for key, reducer in pairs(map) do\
\9\9\9-- Each reducer gets its own state, not the entire state table\
\9\9\9newState[key] = reducer(state[key], action)\
\9\9end\
\
\9\9return newState\
\9end\
end\
\
return combineReducers\
", '@'.."Orca.include.node_modules.rodux.src.combineReducers")) setfenv(fn, newEnv("Orca.include.node_modules.rodux.src.combineReducers")) return fn() end)

newModule("createReducer", "ModuleScript", "Orca.include.node_modules.rodux.src.createReducer", "Orca.include.node_modules.rodux.src", function () local fn = assert(loadstring("return function(initialState, handlers)\
\9return function(state, action)\
\9\9if state == nil then\
\9\9\9state = initialState\
\9\9end\
\
\9\9local handler = handlers[action.type]\
\
\9\9if handler then\
\9\9\9return handler(state, action)\
\9\9end\
\
\9\9return state\
\9end\
end\
", '@'.."Orca.include.node_modules.rodux.src.createReducer")) setfenv(fn, newEnv("Orca.include.node_modules.rodux.src.createReducer")) return fn() end)

newModule("loggerMiddleware", "ModuleScript", "Orca.include.node_modules.rodux.src.loggerMiddleware", "Orca.include.node_modules.rodux.src", function () local fn = assert(loadstring("-- We want to be able to override outputFunction in tests, so the shape of this\
-- module is kind of unconventional.\
--\
-- We fix it this weird shape in init.lua.\
local prettyPrint = require(script.Parent.prettyPrint)\
local loggerMiddleware = {\
\9outputFunction = print,\
}\
\
function loggerMiddleware.middleware(nextDispatch, store)\
\9return function(action)\
\9\9local result = nextDispatch(action)\
\
\9\9loggerMiddleware.outputFunction((\"Action dispatched: %s\\nState changed to: %s\"):format(\
\9\9\9prettyPrint(action),\
\9\9\9prettyPrint(store:getState())\
\9\9))\
\
\9\9return result\
\9end\
end\
\
return loggerMiddleware\
", '@'.."Orca.include.node_modules.rodux.src.loggerMiddleware")) setfenv(fn, newEnv("Orca.include.node_modules.rodux.src.loggerMiddleware")) return fn() end)

newModule("makeActionCreator", "ModuleScript", "Orca.include.node_modules.rodux.src.makeActionCreator", "Orca.include.node_modules.rodux.src", function () local fn = assert(loadstring("--[[\13\
\9A helper function to define a Rodux action creator with an associated name.\13\
]]\13\
local function makeActionCreator(name, fn)\13\
\9assert(type(name) == \"string\", \"Bad argument #1: Expected a string name for the action creator\")\13\
\13\
\9assert(type(fn) == \"function\", \"Bad argument #2: Expected a function that creates action objects\")\13\
\13\
\9return setmetatable({\13\
\9\9name = name,\13\
\9}, {\13\
\9\9__call = function(self, ...)\13\
\9\9\9local result = fn(...)\13\
\13\
\9\9\9assert(type(result) == \"table\", \"Invalid action: An action creator must return a table\")\13\
\13\
\9\9\9result.type = name\13\
\13\
\9\9\9return result\13\
\9\9end\13\
\9})\13\
end\13\
\13\
return makeActionCreator\13\
", '@'.."Orca.include.node_modules.rodux.src.makeActionCreator")) setfenv(fn, newEnv("Orca.include.node_modules.rodux.src.makeActionCreator")) return fn() end)

newModule("prettyPrint", "ModuleScript", "Orca.include.node_modules.rodux.src.prettyPrint", "Orca.include.node_modules.rodux.src", function () local fn = assert(loadstring("local indent = \"    \"\
\
local function prettyPrint(value, indentLevel)\
\9indentLevel = indentLevel or 0\
\9local output = {}\
\
\9if typeof(value) == \"table\" then\
\9\9table.insert(output, \"{\\n\")\
\
\9\9for tableKey, tableValue in pairs(value) do\
\9\9\9table.insert(output, indent:rep(indentLevel + 1))\
\9\9\9table.insert(output, tostring(tableKey))\
\9\9\9table.insert(output, \" = \")\
\
\9\9\9table.insert(output, prettyPrint(tableValue, indentLevel + 1))\
\9\9\9table.insert(output, \"\\n\")\
\9\9end\
\
\9\9table.insert(output, indent:rep(indentLevel))\
\9\9table.insert(output, \"}\")\
\9elseif typeof(value) == \"string\" then\
\9\9table.insert(output, string.format(\"%q\", value))\
\9\9table.insert(output, \" (string)\")\
\9else\
\9\9table.insert(output, tostring(value))\
\9\9table.insert(output, \" (\")\
\9\9table.insert(output, typeof(value))\
\9\9table.insert(output, \")\")\
\9end\
\
\9return table.concat(output, \"\")\
end\
\
return prettyPrint", '@'.."Orca.include.node_modules.rodux.src.prettyPrint")) setfenv(fn, newEnv("Orca.include.node_modules.rodux.src.prettyPrint")) return fn() end)

newModule("thunkMiddleware", "ModuleScript", "Orca.include.node_modules.rodux.src.thunkMiddleware", "Orca.include.node_modules.rodux.src", function () local fn = assert(loadstring("--[[\
\9A middleware that allows for functions to be dispatched.\
\9Functions will receive a single argument, the store itself.\
\9This middleware consumes the function; middleware further down the chain\
\9will not receive it.\
]]\
local function tracebackReporter(message)\
\9return debug.traceback(message)\
end\
\
local function thunkMiddleware(nextDispatch, store)\
\9return function(action)\
\9\9if typeof(action) == \"function\" then\
\9\9\9local ok, result = xpcall(function()\
\9\9\9\9return action(store)\
\9\9\9end, tracebackReporter)\
\
\9\9\9if not ok then\
\9\9\9\9-- report the error and move on so it's non-fatal app\
\9\9\9\9store._errorReporter.reportReducerError(store:getState(), action, {\
\9\9\9\9\9message = \"Caught error in thunk\",\
\9\9\9\9\9thrownValue = result,\
\9\9\9\9})\
\9\9\9\9return nil\
\9\9\9end\
\
\9\9\9return result\
\9\9end\
\
\9\9return nextDispatch(action)\
\9end\
end\
\
return thunkMiddleware\
", '@'.."Orca.include.node_modules.rodux.src.thunkMiddleware")) setfenv(fn, newEnv("Orca.include.node_modules.rodux.src.thunkMiddleware")) return fn() end)

newModule("services", "ModuleScript", "Orca.include.node_modules.services", "Orca.include.node_modules", function () local fn = assert(loadstring("return setmetatable({}, {\
\9__index = function(self, serviceName)\
\9\9local service = game:GetService(serviceName)\
\9\9self[serviceName] = service\
\9\9return service\
\9end,\
})\
", '@'.."Orca.include.node_modules.services")) setfenv(fn, newEnv("Orca.include.node_modules.services")) return fn() end)

newInstance("types", "Folder", "Orca.include.node_modules.types", "Orca.include.node_modules")

newInstance("include", "Folder", "Orca.include.node_modules.types.include", "Orca.include.node_modules.types")

newInstance("generated", "Folder", "Orca.include.node_modules.types.include.generated", "Orca.include.node_modules.types.include")

init()