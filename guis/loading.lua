-- TenacityForRoblox startup experience.
-- Reworked presentation; keeps the shipped splashscreen.png background.
local TweenService = game:GetService('TweenService')
local Players = game:GetService('Players')
local HttpService = game:GetService('HttpService')

local screen = {
    Value = 0,
    Tweens = {},
    Started = os.clock(),
    MinimumDisplay = 0.75,
    StepThresholds = {0.08, 0.28, 0.62, 0.98}
}

local function create(class, parent, props)
    local object = Instance.new(class)
    for key, value in props do
        object[key] = value
    end
    object.Parent = parent
    return object
end

local function asset(name)
    if not getcustomasset then return '' end
    local path = 'tenacity/assets/tenacity/'..name
    local runtime = shared.TenacityRuntime

    if runtime then
        local ok, value = pcall(runtime.Read, path, getcustomasset)
        if ok and value then return value end
    end

    local ok, value = pcall(function()
        if isfile and isfile(path) then
            return getcustomasset(path)
        end
        return ''
    end)

    return ok and value or ''
end

local function loadFont(assetName, familyName, weight)
    if not (getcustomasset and writefile) then return nil end

    local fontAsset = asset(assetName)
    if fontAsset == '' then return nil end

    local jsonPath = 'tenacity/assets/'..familyName..'.font.json'
    local ok = pcall(writefile, jsonPath, HttpService:JSONEncode({
        name = familyName,
        faces = {{
            name = 'Regular',
            weight = weight or 400,
            style = 'normal',
            assetId = fontAsset
        }}
    }))
    if not ok then return nil end

    local family = getcustomasset(jsonPath)
    if family == '' then return nil end

    local worked, result = pcall(function()
        return Font.new(
            family,
            weight == 700 and Enum.FontWeight.Bold or Enum.FontWeight.Regular,
            Enum.FontStyle.Normal
        )
    end)

    return worked and result or nil
end

local function tween(owner, object, info, goal, key)
    if key and owner.Tweens[key] then
        owner.Tweens[key]:Cancel()
    end

    local motion = TweenService:Create(object, info, goal)
    if key then
        owner.Tweens[key] = motion
    else
        table.insert(owner.Tweens, motion)
    end
    motion:Play()
    return motion
end

local function corner(parent, radius)
    return create('UICorner', parent, {
        CornerRadius = UDim.new(0, radius or 12)
    })
end

function screen:SetTheme()
    -- Loader intentionally owns its presentation so startup is stable even
    -- before the main Tenacity theme system has finished initializing.
end

function screen:WaitForMinimumDisplay()
    local left = self.MinimumDisplay - (os.clock() - self.Started)
    if left > 0 then
        task.wait(left)
    end
end

function screen:UpdateSteps()
    if not self.Steps then return end

    for index, step in self.Steps do
        local unlocked = self.Value >= (self.StepThresholds[index] or 1)
        local active = index == math.clamp(math.ceil(self.Value * #self.Steps), 1, #self.Steps)

        tween(self, step.Dot, TweenInfo.new(0.22, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {
            BackgroundTransparency = unlocked and 0 or 0.68,
            Size = unlocked and UDim2.fromOffset(active and 10 or 8, active and 10 or 8) or UDim2.fromOffset(6, 6)
        }, 'StepDot'..index)

        tween(self, step.Label, TweenInfo.new(0.22, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {
            TextTransparency = unlocked and 0 or 0.48
        }, 'StepLabel'..index)
    end
end

function screen:SetLoadingProgress(value, message)
    if not self.LoadingScreen then return end

    if type(value) == 'number'
        and value == value
        and value ~= math.huge
        and value ~= -math.huge
    then
        self.Value = math.max(self.Value, math.clamp(value, 0, 1))

        tween(self, self.Progress, TweenInfo.new(0.38, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {
            Size = UDim2.fromScale(self.Value, 1)
        }, 'Progress')

        self.Percent.Text = string.format('%d%%', math.floor(self.Value * 100 + 0.5))
        self.Stage.Text =
            self.Value < 0.24 and 'BOOTSTRAP'
            or self.Value < 0.55 and 'INTERFACE'
            or self.Value < 0.86 and 'MODULES'
            or 'READY'

        self:UpdateSteps()
    end

    if message then
        self.Status.Text = tostring(message)
    end
end

function screen:HideLoadingScreen(immediate)
    local gui = self.LoadingScreen
    if not gui then return end

    self.LoadingScreen = nil
    if shared.TenacityLoading == self then
        shared.TenacityLoading = nil
    end

    if immediate then
        gui:Destroy()
        return
    end

    self:WaitForMinimumDisplay()

    if self.ContentScale then
        tween(self, self.ContentScale, TweenInfo.new(0.34, Enum.EasingStyle.Quint, Enum.EasingDirection.In), {
            Scale = 0.96
        }, 'ExitScale')
    end

    tween(self, self.Root, TweenInfo.new(0.38, Enum.EasingStyle.Quint, Enum.EasingDirection.In), {
        GroupTransparency = 1
    }, 'Exit')

    task.delay(0.42, function()
        if gui.Parent then
            gui:Destroy()
        end
    end)
end

function screen:ShowLoadingScreen()
    self:HideLoadingScreen(true)

    local parent = Players.LocalPlayer:WaitForChild('PlayerGui')
    local old = parent:FindFirstChild('TenacityLoadingScreen')
    if old then old:Destroy() end

    self.Started = os.clock()
    self.Value = 0
    self.TitleFont = loadFont('tenacity-bold.ttf', 'TenacityLoaderBold', 700)
        or Font.fromEnum(Enum.Font.GothamBold)
    self.BodyFont = loadFont('tenacity.ttf', 'TenacityLoaderRegular', 400)
        or Font.fromEnum(Enum.Font.Gotham)

    local gui = create('ScreenGui', parent, {
        Name = 'TenacityLoadingScreen',
        ResetOnSpawn = false,
        IgnoreGuiInset = true,
        DisplayOrder = 1000000,
        ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    })

    self.LoadingScreen = gui
    shared.TenacityLoading = self

    local root = create('CanvasGroup', gui, {
        Name = 'Experience',
        BackgroundColor3 = Color3.fromRGB(7, 8, 12),
        BorderSizePixel = 0,
        Size = UDim2.fromScale(1, 1),
        GroupTransparency = 1
    })
    self.Root = root

    -- Keep the original shipped background exactly as requested.
    local splash = asset('splashscreen.png')
    if splash ~= '' then
        create('ImageLabel', root, {
            Name = 'Splash',
            BackgroundTransparency = 1,
            Image = splash,
            Size = UDim2.fromScale(1, 1),
            ScaleType = Enum.ScaleType.Crop,
            ImageTransparency = 0
        })
    end

    -- Soft cinematic shading over the same background.
    local shade = create('Frame', root, {
        Name = 'Shade',
        BackgroundColor3 = Color3.fromRGB(5, 6, 10),
        BackgroundTransparency = 0.17,
        BorderSizePixel = 0,
        Size = UDim2.fromScale(1, 1)
    })
    create('UIGradient', shade, {
        Rotation = 90,
        Color = ColorSequence.new({
            ColorSequenceKeypoint.new(0, Color3.fromRGB(7, 8, 12)),
            ColorSequenceKeypoint.new(0.56, Color3.fromRGB(17, 16, 22)),
            ColorSequenceKeypoint.new(1, Color3.fromRGB(6, 7, 10))
        }),
        Transparency = NumberSequence.new({
            NumberSequenceKeypoint.new(0, 0.52),
            NumberSequenceKeypoint.new(0.52, 0.72),
            NumberSequenceKeypoint.new(1, 0.22)
        })
    })

    -- Centered loader instead of the old giant bottom-left dock.
    local content = create('Frame', root, {
        Name = 'Loader',
        AnchorPoint = Vector2.new(0.5, 0.5),
        Position = UDim2.fromScale(0.5, 0.53),
        Size = UDim2.fromOffset(560, 300),
        BackgroundTransparency = 1
    })
    self.Content = content

    local contentScale = create('UIScale', content, {Scale = 0.93})
    self.ContentScale = contentScale

    local glow = create('Frame', content, {
        Name = 'Glow',
        AnchorPoint = Vector2.new(0.5, 0),
        Position = UDim2.new(0.5, 0, 0, -18),
        Size = UDim2.fromOffset(180, 180),
        BackgroundColor3 = Color3.fromRGB(224, 85, 190),
        BackgroundTransparency = 0.82,
        BorderSizePixel = 0
    })
    corner(glow, 90)

    local logoAsset = asset('modernlogobigger.png')
    if logoAsset ~= '' then
        create('ImageLabel', content, {
            Name = 'Logo',
            AnchorPoint = Vector2.new(0.5, 0),
            Position = UDim2.new(0.5, 0, 0, 0),
            Size = UDim2.fromOffset(92, 92),
            BackgroundTransparency = 1,
            Image = logoAsset,
            ScaleType = Enum.ScaleType.Fit
        })
    end

    local title = create('TextLabel', content, {
        Name = 'Title',
        BackgroundTransparency = 1,
        Position = UDim2.fromOffset(0, 101),
        Size = UDim2.new(1, 0, 0, 44),
        Text = 'TENACITY',
        TextColor3 = Color3.new(1, 1, 1),
        TextSize = 38,
        TextXAlignment = Enum.TextXAlignment.Center,
        FontFace = self.TitleFont
    })

    local subtitle = create('TextLabel', content, {
        Name = 'Subtitle',
        BackgroundTransparency = 1,
        Position = UDim2.fromOffset(0, 143),
        Size = UDim2.new(1, 0, 0, 20),
        Text = 'ROBLOX  •  STARTING CLIENT',
        TextColor3 = Color3.fromRGB(178, 181, 192),
        TextSize = 12,
        TextXAlignment = Enum.TextXAlignment.Center,
        FontFace = self.BodyFont
    })

    local stage = create('TextLabel', content, {
        Name = 'Stage',
        BackgroundTransparency = 1,
        Position = UDim2.fromOffset(18, 184),
        Size = UDim2.fromOffset(180, 20),
        Text = 'BOOTSTRAP',
        TextColor3 = Color3.fromRGB(195, 198, 209),
        TextSize = 11,
        TextXAlignment = Enum.TextXAlignment.Left,
        FontFace = self.TitleFont
    })
    self.Stage = stage

    local percent = create('TextLabel', content, {
        Name = 'Percent',
        BackgroundTransparency = 1,
        Position = UDim2.new(1, -118, 0, 177),
        Size = UDim2.fromOffset(100, 27),
        Text = '0%',
        TextColor3 = Color3.new(1, 1, 1),
        TextSize = 22,
        TextXAlignment = Enum.TextXAlignment.Right,
        FontFace = self.TitleFont
    })
    self.Percent = percent

    local status = create('TextLabel', content, {
        Name = 'Status',
        BackgroundTransparency = 1,
        Position = UDim2.fromOffset(18, 207),
        Size = UDim2.new(1, -36, 0, 24),
        Text = 'Starting Tenacity',
        TextColor3 = Color3.fromRGB(232, 233, 239),
        TextSize = 15,
        TextXAlignment = Enum.TextXAlignment.Left,
        TextTruncate = Enum.TextTruncate.AtEnd,
        FontFace = self.BodyFont
    })
    self.Status = status

    local track = create('Frame', content, {
        Name = 'ProgressTrack',
        Position = UDim2.fromOffset(18, 239),
        Size = UDim2.new(1, -36, 0, 5),
        BackgroundColor3 = Color3.fromRGB(255, 255, 255),
        BackgroundTransparency = 0.84,
        BorderSizePixel = 0
    })
    corner(track, 999)

    local progress = create('Frame', track, {
        Name = 'Progress',
        Size = UDim2.fromScale(0, 1),
        BackgroundColor3 = Color3.new(1, 1, 1),
        BorderSizePixel = 0,
        ClipsDescendants = true
    })
    corner(progress, 999)
    self.Progress = progress

    local grad = create('UIGradient', progress, {
        Rotation = 0,
        Color = ColorSequence.new({
            ColorSequenceKeypoint.new(0, Color3.fromRGB(77, 178, 247)),
            ColorSequenceKeypoint.new(0.5, Color3.fromRGB(184, 104, 235)),
            ColorSequenceKeypoint.new(1, Color3.fromRGB(238, 72, 190))
        })
    })

    local stepHolder = create('Frame', content, {
        Name = 'Steps',
        Position = UDim2.fromOffset(18, 260),
        Size = UDim2.new(1, -36, 0, 28),
        BackgroundTransparency = 1
    })

    local steps = {'BOOT', 'UI', 'MODULES', 'READY'}
    self.Steps = {}

    for index, caption in ipairs(steps) do
        local x = (index - 1) * 0.25
        local item = create('Frame', stepHolder, {
            Name = caption,
            Position = UDim2.new(x, 0, 0, 0),
            Size = UDim2.new(0.25, 0, 1, 0),
            BackgroundTransparency = 1
        })

        local dot = create('Frame', item, {
            Name = 'Dot',
            AnchorPoint = Vector2.new(0, 0.5),
            Position = UDim2.new(0, 0, 0.5, 0),
            Size = UDim2.fromOffset(6, 6),
            BackgroundColor3 = Color3.fromRGB(238, 101, 203),
            BackgroundTransparency = 0.68,
            BorderSizePixel = 0
        })
        corner(dot, 999)

        local labelObject = create('TextLabel', item, {
            Name = 'Label',
            BackgroundTransparency = 1,
            Position = UDim2.fromOffset(14, 0),
            Size = UDim2.new(1, -14, 1, 0),
            Text = caption,
            TextColor3 = Color3.fromRGB(192, 195, 205),
            TextTransparency = 0.48,
            TextSize = 10,
            TextXAlignment = Enum.TextXAlignment.Left,
            FontFace = self.TitleFont
        })

        self.Steps[index] = {
            Dot = dot,
            Label = labelObject
        }
    end

    local footer = create('TextLabel', root, {
        Name = 'Hint',
        AnchorPoint = Vector2.new(0.5, 1),
        Position = UDim2.new(0.5, 0, 1, -18),
        Size = UDim2.fromOffset(420, 20),
        BackgroundTransparency = 1,
        Text = 'RSHIFT  •  CLICKGUI',
        TextColor3 = Color3.fromRGB(150, 153, 164),
        TextSize = 10,
        TextXAlignment = Enum.TextXAlignment.Center,
        FontFace = self.BodyFont
    })

    task.spawn(function()
        local phase = 0
        while gui.Parent and self.LoadingScreen == gui do
            phase = (phase + 0.006) % 1
            grad.Offset = Vector2.new(math.sin(phase * math.pi * 2) * 0.3, 0)

            local pulse = (math.sin(phase * math.pi * 2) + 1) * 0.5
            glow.BackgroundTransparency = 0.88 - (pulse * 0.08)
            task.wait()
        end
    end)

    self:UpdateSteps()

    tween(self, root, TweenInfo.new(0.4, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {
        GroupTransparency = 0
    }, 'Enter')

    tween(self, contentScale, TweenInfo.new(0.55, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
        Scale = 1
    }, 'EnterScale')

    gui.Destroying:Connect(function()
        if self.LoadingScreen == gui then
            self.LoadingScreen = nil
        end
        if shared.TenacityLoading == self then
            shared.TenacityLoading = nil
        end
    end)
end

local ok, err = pcall(screen.ShowLoadingScreen, screen)
if not ok then
    screen:HideLoadingScreen(true)
    warn('[Tenacity] Loading UI unavailable: '..tostring(err))
end

return screen
