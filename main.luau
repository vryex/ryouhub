-- Ryou
-- Interfaz de cliente en Luau.
-- Creador Ryou · TikTok @x0brxn

local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local Input = game:GetService("UserInputService")

local Ryou = {}
local mounted = {}

local rgb = Color3.fromRGB
local offset = UDim2.fromOffset
local scale = UDim2.fromScale
local center = Vector2.new(0.5, 0.5)
local colors = {
	shell = rgb(11, 16, 23),
	rail = rgb(14, 21, 30),
	card = rgb(21, 31, 42),
	control = rgb(30, 43, 56),
	stroke = rgb(48, 63, 78),
	text = rgb(237, 245, 249),
	secondary = rgb(158, 180, 194),
	ink = rgb(14, 27, 32),
	scrim = rgb(3, 7, 11),
}

local palettes = {
	{ name = "Menta", color = rgb(112, 243, 206), shade = rgb(27, 73, 70) },
	{ name = "Violeta", color = rgb(208, 170, 255), shade = rgb(62, 43, 86) },
	{ name = "Hielo", color = rgb(158, 219, 255), shade = rgb(33, 64, 88) },
}
local sizes = {
	{ name = "Chico", factor = 0.91 },
	{ name = "Normal", factor = 1 },
	{ name = "Grande", factor = 1.12 },
}
local pageNames = { "Inicio", "Apariencia", "Ajustes", "Créditos" }

local function create(class, parent, properties)
	local object = Instance.new(class)
	for property, value in pairs(properties) do
		object[property] = value
	end
	object.Parent = parent
	return object
end

local function round(object, radius)
	create("UICorner", object, { CornerRadius = UDim.new(0, radius) })
	return object
end

local function border(object, color)
	create("UIStroke", object, {
		ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
		Color = color or colors.stroke,
		Thickness = 1,
	})
	return object
end

local function frame(parent, properties)
	if properties.BackgroundColor3 == nil then
		properties.BackgroundTransparency = 1
	end
	properties.BorderSizePixel = 0
	return create("Frame", parent, properties)
end

local function label(parent, name, content, size, properties)
	properties.Name = name
	properties.Text = content
	properties.TextSize = size
	properties.BackgroundTransparency = 1
	properties.BorderSizePixel = 0
	properties.Font = properties.Font or Enum.Font.GothamMedium
	properties.TextColor3 = properties.TextColor3 or colors.text
	properties.TextXAlignment = properties.TextXAlignment or Enum.TextXAlignment.Left
	properties.TextTruncate = Enum.TextTruncate.AtEnd
	return create("TextLabel", parent, properties)
end

local function button(parent, name, title, properties)
	properties.Name = name
	properties.Text = title
	properties.TextSize = properties.TextSize or 13
	properties.Font = Enum.Font.GothamBold
	properties.TextColor3 = properties.TextColor3 or colors.text
	properties.BackgroundColor3 = properties.BackgroundColor3 or colors.control
	properties.AutoButtonColor = true
	properties.BorderSizePixel = 0
	return round(create("TextButton", parent, properties), 10)
end

local function list(parent, direction, gap)
	return create("UIListLayout", parent, {
		FillDirection = direction,
		SortOrder = Enum.SortOrder.LayoutOrder,
		Padding = UDim.new(0, gap),
	})
end

function Ryou.mount(playerGui, configuration)
	local existing = mounted[playerGui]
	if existing then
		return existing
	end

	configuration = configuration or {}
	local localPlayer = Players.LocalPlayer
	local displayName = configuration.displayName or (localPlayer and localPlayer.DisplayName) or "jugador"
	local settings = { palette = 1, size = 2, motion = true, clock = false }

	local gui = create("ScreenGui", playerGui, {
		Name = "RyouUI",
		ResetOnSpawn = false,
		DisplayOrder = 30,
		ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
		ScreenInsets = Enum.ScreenInsets.CoreUISafeInsets,
	})

	local root = frame(gui, { Name = "SafeArea", Size = scale(1, 1) })
	local launcher = border(button(root, "Launcher", "Ryou", {
		AnchorPoint = Vector2.new(1, 1),
		Position = UDim2.new(1, -16, 1, -116),
		Size = offset(72, 46),
		BackgroundColor3 = colors.rail,
		TextSize = 16,
		ZIndex = 2,
	}))

	local clock = round(create("TextLabel", root, {
		Name = "Clock",
		AnchorPoint = Vector2.new(1, 0),
		Position = UDim2.new(1, -16, 0, 12),
		Size = offset(80, 34),
		Font = Enum.Font.GothamBold,
		TextSize = 14,
		BackgroundColor3 = colors.rail,
		TextColor3 = colors.text,
		BorderSizePixel = 0,
		Visible = false,
	}), 10)

	local overlay = create("TextButton", root, {
		Name = "Overlay",
		Size = scale(1, 1),
		Text = "",
		AutoButtonColor = false,
		Selectable = false,
		Modal = true,
		BackgroundColor3 = colors.scrim,
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		Visible = false,
		ZIndex = 3,
	})

	local panel = border(round(create("CanvasGroup", root, {
		Name = "Panel",
		AnchorPoint = center,
		Position = scale(0.5, 0.5),
		Size = offset(920, 566),
		BackgroundColor3 = colors.shell,
		BorderSizePixel = 0,
		GroupTransparency = 1,
		Active = true,
		Visible = false,
		ZIndex = 4,
	}), 18))
	local panelScale = create("UIScale", panel, { Scale = 1 })

	local header = frame(panel, {
		Name = "Header",
		Size = UDim2.new(1, 0, 0, 65),
		BackgroundColor3 = colors.rail,
	})
	local logoBadge = round(frame(header, {
		Position = offset(19, 13), Size = offset(37, 37), BackgroundColor3 = colors.control,
	}), 11)
	local logo = label(logoBadge, "Mark", "R", 24, {
		Size = scale(1, 1),
		Font = Enum.Font.GothamBold,
		TextXAlignment = Enum.TextXAlignment.Center,
	})
	label(header, "Brand", "Ryou", 23, {
		Position = offset(67, 0), Size = UDim2.new(1, -136, 1, 0), Font = Enum.Font.GothamBold,
	})
	local close = button(header, "Cerrar", "×", {
		AnchorPoint = Vector2.new(1, 0), Position = UDim2.new(1, -13, 0, 10),
		Size = offset(45, 44), TextSize = 23,
	})

	local rail = frame(panel, {
		Name = "Sidebar", Position = offset(0, 65), Size = UDim2.new(0, 174, 1, -65),
		BackgroundColor3 = colors.rail,
	})
	local railItems = frame(rail, {
		Position = offset(12, 18), Size = UDim2.new(1, -24, 1, -74),
	})
	list(railItems, Enum.FillDirection.Vertical, 7)
	label(rail, "Shortcut", "Shift der. · Abrir", 11, {
		Position = UDim2.new(0, 17, 1, -45), Size = offset(146, 31), TextColor3 = colors.secondary,
	})

	local bottom = frame(panel, {
		Name = "BottomNav",
		Position = UDim2.new(0, 0, 1, -60),
		Size = UDim2.new(1, 0, 0, 60),
		BackgroundColor3 = colors.rail,
	})
	local divider = frame(panel, {
		Position = offset(0, 64), Size = UDim2.new(1, 0, 0, 1), BackgroundColor3 = colors.stroke,
	})

	local body = create("CanvasGroup", panel, {
		Name = "Content",
		Position = offset(174, 65),
		Size = UDim2.new(1, -174, 1, -65),
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
	})

	local intro = create("CanvasGroup", panel, {
		Name = "Intro",
		Size = scale(1, 1),
		BackgroundColor3 = colors.shell,
		BorderSizePixel = 0,
		Visible = false,
		ZIndex = 6,
	})
	local introTitle = label(intro, "IntroWordmark", "Ryou", 72, {
		AnchorPoint = center, Position = scale(0.5, 0.47), Size = offset(264, 96),
		Font = Enum.Font.GothamBold, TextXAlignment = Enum.TextXAlignment.Center,
	})
	local introLine = round(frame(intro, {
		AnchorPoint = center, Position = UDim2.new(0.5, 0, 0.47, 53),
		Size = offset(12, 3), BackgroundColor3 = palettes[1].color,
	}), 4)

	local function makePage(name, title)
		local page = create("ScrollingFrame", body, {
			Name = "Page" .. name, Size = scale(1, 1), BackgroundTransparency = 1,
			BorderSizePixel = 0, CanvasSize = offset(0, 0), AutomaticCanvasSize = Enum.AutomaticSize.Y,
			ScrollingDirection = Enum.ScrollingDirection.Y, ScrollBarThickness = 3,
			ScrollBarImageColor3 = colors.secondary, Visible = name == "Inicio",
		})
		local stack = frame(page, {
			Position = offset(16, 15), Size = UDim2.new(1, -34, 0, 0),
			AutomaticSize = Enum.AutomaticSize.Y,
		})
		create("UIPadding", stack, { PaddingBottom = UDim.new(0, 19) })
		list(stack, Enum.FillDirection.Vertical, 12)
		label(stack, name, title, 24, {
			LayoutOrder = 1, Size = UDim2.new(1, 0, 0, 36), Font = Enum.Font.GothamBold,
		})
		return page, stack
	end

	local home, homeStack = makePage("Inicio", "Inicio")
	local appearance, appearanceStack = makePage("Apariencia", "Apariencia")
	local options, optionsStack = makePage("Ajustes", "Ajustes")
	local credits, creditsStack = makePage("Créditos", "Créditos")
	local pages = { home, appearance, options, credits }

	local function card(parent, order, height)
		return border(round(frame(parent, {
			LayoutOrder = order, Size = UDim2.new(1, 0, 0, height), BackgroundColor3 = colors.card,
		}), 13))
	end

	local hero = card(homeStack, 2, 160)
	hero.ClipsDescendants = true
	local heroGradient = create("UIGradient", hero, { Rotation = 20 })
	local heroLines = frame(hero, {
		AnchorPoint = Vector2.new(1, 0.5), Position = UDim2.new(1, 8, 0.5, 0),
		Size = offset(147, 147), Rotation = 35,
	})
	local stripes = {}
	for index = 1, 5 do
		stripes[index] = frame(heroLines, {
			Position = offset(9 + index * 23, -30), Size = offset(1, 208),
			BackgroundColor3 = palettes[1].color, BackgroundTransparency = 0.87,
		})
	end
	local heroMark = label(hero, "HeroMark", "R", 134, {
		AnchorPoint = Vector2.new(1, 0.5), Position = UDim2.new(1, -14, 0.5, 0),
		Size = offset(119, 148), TextTransparency = 0.84,
		Font = Enum.Font.GothamBold, TextXAlignment = Enum.TextXAlignment.Right,
	})
	label(hero, "Greeting", "Hola, " .. displayName, 26, {
		Position = offset(16, 19), Size = UDim2.new(1, -34, 0, 36), Font = Enum.Font.GothamBold,
	})
	label(hero, "HeroDescription", "Tema, tamaño y movimiento", 13, {
		Position = offset(16, 58), Size = UDim2.new(1, -35, 0, 22), TextColor3 = colors.secondary,
	})
	local customize = button(hero, "Personalizar", "Personalizar  ›", {
		Position = offset(16, 97), Size = offset(143, 43), TextColor3 = colors.ink,
	})

	local summary = card(homeStack, 3, 97)
	label(summary, "ThemeCaption", "Tema activo", 12, {
		Position = offset(14, 17), Size = UDim2.new(0.5, -19, 0, 19), TextColor3 = colors.secondary,
	})
	label(summary, "MotionCaption", "Movimiento", 12, {
		Position = UDim2.new(0.5, 10, 0, 17), Size = UDim2.new(0.5, -22, 0, 19), TextColor3 = colors.secondary,
	})
	frame(summary, {
		Position = UDim2.new(0.5, -2, 0, 20), Size = UDim2.new(0, 1, 1, -40),
		BackgroundColor3 = colors.stroke,
	})
	local themeValue = label(summary, "ThemeValue", "", 20, {
		Position = offset(14, 41), Size = UDim2.new(0.5, -19, 0, 30), Font = Enum.Font.GothamBold,
	})
	local motionValue = label(summary, "MotionValue", "", 18, {
		Position = UDim2.new(0.5, 10, 0, 41), Size = UDim2.new(0.5, -22, 0, 30),
		Font = Enum.Font.GothamBold,
	})

	local function choiceRow(parent, order, title, prefix, choices, onSelect)
		local row = card(parent, order, 109)
		label(row, prefix .. "Title", title, 15, {
			Position = offset(14, 11), Size = UDim2.new(1, -28, 0, 27), Font = Enum.Font.GothamBold,
		})
		local items = frame(row, { Position = offset(12, 49), Size = UDim2.new(1, -24, 0, 44) })
		local buttons = {}
		for index, choice in ipairs(choices) do
			local control = button(items, prefix .. choice.name, choice.name, {
				Position = UDim2.new((index - 1) / #choices, 3, 0, 0),
				Size = UDim2.new(1 / #choices, -6, 1, 0),
			})
			control.Activated:Connect(function()
				onSelect(index)
			end)
			buttons[index] = control
		end
		return buttons
	end

	local function toggleRow(parent, order, id, title, detail, onToggle)
		local row = card(parent, order, 86)
		label(row, id .. "Title", title, 15, {
			Position = offset(13, 12), Size = UDim2.new(1, -117, 0, 25), Font = Enum.Font.GothamBold,
		})
		label(row, id .. "Detail", detail, 11, {
			Position = offset(13, 42), Size = UDim2.new(1, -116, 0, 22), TextColor3 = colors.secondary,
		})
		local control = button(row, id, "", {
			AnchorPoint = Vector2.new(1, 0.5), Position = UDim2.new(1, -12, 0.5, 0),
			Size = offset(82, 44),
		})
		control.Activated:Connect(onToggle)
		return control
	end

	local creditCard = card(creditsStack, 2, 150)
	label(creditCard, "CreatorCaption", "Creador", 12, {
		Position = offset(15, 13), Size = UDim2.new(1, -30, 0, 20), TextColor3 = colors.secondary,
	})
	label(creditCard, "Creator", "Ryou", 25, {
		Position = offset(15, 36), Size = UDim2.new(1, -30, 0, 31), Font = Enum.Font.GothamBold,
	})
	label(creditCard, "TikTokCaption", "TikTok", 12, {
		Position = offset(15, 84), Size = UDim2.new(1, -30, 0, 20), TextColor3 = colors.secondary,
	})
	local tiktok = label(creditCard, "TikTok", "@x0brxn", 17, {
		Position = offset(15, 106), Size = UDim2.new(1, -30, 0, 26), Font = Enum.Font.GothamBold,
	})

	local activePage = 1
	local open = false
	local openedBefore = false
	local showOnMount = configuration.openOnMount ~= false
	local version = 0
	local alive = true
	local layout
	local motions = {}
	local pinnedLauncher
	local function styleControl(control, selected)
		local accent = palettes[settings.palette].color
		control.BackgroundColor3 = selected and accent or colors.control
		control.TextColor3 = selected and colors.ink or colors.text
	end

	local function cancelMotion(object)
		local tween = motions[object]
		if tween then
			motions[object] = nil
			tween:Cancel()
		end
	end

	local function animate(object, duration, properties, direction)
		cancelMotion(object)
		if not settings.motion then
			for property, value in pairs(properties) do
				object[property] = value
			end
			return
		end
		local tween = TweenService:Create(object,
			TweenInfo.new(duration, Enum.EasingStyle.Quint, direction or Enum.EasingDirection.Out),
			properties
		)
		motions[object] = tween
		tween:Play()
	end

	local desktopNav = {}
	local mobileNav = {}

	local function paintNav()
		for index in ipairs(pageNames) do
			styleControl(desktopNav[index], index == activePage)
			styleControl(mobileNav[index], index == activePage)
		end
	end

	local function showPage(index)
		if activePage == index then
			return
		end
		pages[activePage].Visible = false
		activePage = index
		pages[index].Visible = true
		paintNav()
		cancelMotion(body)
		body.GroupTransparency = settings.motion and 0.27 or 0
		animate(body, 0.24, { GroupTransparency = 0 })
	end

	for index, name in ipairs(pageNames) do
		local desktop = button(railItems, name, name, {
			LayoutOrder = index, Size = UDim2.new(1, 0, 0, 44),
		})
		local mobile = button(bottom, name, name, {
			Position = UDim2.new((index - 1) / #pageNames, 4, 0, 7),
			Size = UDim2.new(1 / #pageNames, -8, 0, 46),
			TextSize = 11,
		})
		desktopNav[index] = desktop
		mobileNav[index] = mobile
		desktop.Activated:Connect(function()
			showPage(index)
		end)
		mobile.Activated:Connect(function()
			showPage(index)
		end)
	end
	customize.Activated:Connect(function()
		showPage(2)
	end)

	local function refreshClock()
		local now = os.date("%H:%M")
		if clock.Text ~= now then
			clock.Text = now
		end
	end

	local repaint
	local paletteButtons = choiceRow(appearanceStack, 2, "Color de acento", "Paleta", palettes, function(index)
		settings.palette = index
		repaint()
	end)
	local sizeButtons = choiceRow(appearanceStack, 3, "Tamaño de interfaz", "Tamaño", sizes, function(index)
		settings.size = index
		repaint()
		layout()
	end)

	local motionButton = toggleRow(optionsStack, 2, "Movimiento", "Movimiento reducido", "Entrada y cambios de sección", function()
		settings.motion = not settings.motion
		if not settings.motion then
			for object in pairs(motions) do
				cancelMotion(object)
			end
			intro.Visible = false
			panel.Position = scale(0.5, 0.5)
			panel.GroupTransparency = 0
			body.GroupTransparency = 0
			overlay.BackgroundTransparency = 0.36
		end
		repaint()
	end)
	local clockButton = toggleRow(optionsStack, 3, "Reloj", "Reloj en pantalla", "Visible con el panel cerrado", function()
		settings.clock = not settings.clock
		refreshClock()
		repaint()
	end)

	repaint = function()
		local palette = palettes[settings.palette]
		for index, control in ipairs(paletteButtons) do
			styleControl(control, index == settings.palette)
		end
		for index, control in ipairs(sizeButtons) do
			styleControl(control, index == settings.size)
		end
		paintNav()
		styleControl(motionButton, not settings.motion)
		styleControl(clockButton, settings.clock)
		motionButton.Text = settings.motion and "No" or "Sí"
		clockButton.Text = settings.clock and "Sí" or "No"
		themeValue.Text = palette.name
		themeValue.TextColor3 = palette.color
		motionValue.Text = settings.motion and "Animado" or "Reducido"
		logo.TextColor3 = palette.color
		launcher.TextColor3 = palette.color
		heroMark.TextColor3 = palette.color
		for _, stripe in ipairs(stripes) do
			stripe.BackgroundColor3 = palette.color
		end
		introLine.BackgroundColor3 = palette.color
		customize.BackgroundColor3 = palette.color
		tiktok.TextColor3 = palette.color
		heroGradient.Color = ColorSequence.new(palette.shade, colors.card)
		clock.Visible = settings.clock and not open
	end

	local function placeLauncher(x, y)
		local viewport = root.AbsoluteSize
		local maxX = math.max(viewport.X - 10, 82)
		local maxY = math.max(viewport.Y - 10, 56)
		launcher.Position = offset(math.clamp(x, 82, maxX), math.clamp(y, 56, maxY))
	end

	layout = function()
		local viewport = root.AbsoluteSize
		if viewport.X < 1 or viewport.Y < 1 then
			return
		end
		local compact = viewport.X < 740 or viewport.Y < 430
		local availableWidth = math.max(viewport.X - 20, 1)
		local availableHeight = math.max(viewport.Y - 20, 1)
		local factor = math.min(sizes[settings.size].factor, availableWidth / 320, availableHeight / 286)
		local designWidth = math.min(math.floor(availableWidth / factor), compact and 530 or 920)
		local designHeight = math.min(math.floor(availableHeight / factor), compact and 622 or 566)
		panelScale.Scale = factor
		panel.Size = offset(designWidth, designHeight)
		rail.Visible = not compact
		bottom.Visible = compact
		body.Position = offset(compact and 0 or 174, 65)
		body.Size = UDim2.new(1, compact and 0 or -174, 1, compact and -125 or -65)
		if pinnedLauncher then
			placeLauncher(pinnedLauncher.X * viewport.X, pinnedLauncher.Y * viewport.Y)
		end
	end

	local function setOpen(wantOpen)
		showOnMount = false
		if not alive then
			return
		end
		if wantOpen == open then
			return
		end
		version = version + 1
		local current = version
		open = wantOpen
		clock.Visible = settings.clock and not open
		if wantOpen then
			local firstOpen = not openedBefore
			openedBefore = true
			panel.Visible = true
			overlay.Visible = true
			launcher.Visible = false
			panel.Position = UDim2.new(0.5, 0, 0.5, 15)
			panel.GroupTransparency = 1
			animate(panel, 0.38, { Position = scale(0.5, 0.5), GroupTransparency = 0 })
			animate(overlay, 0.25, { BackgroundTransparency = 0.36 })
			if firstOpen and settings.motion then
				intro.Visible = true
				introLine.Size = offset(12, 3)
				introTitle.Position = UDim2.new(0.5, 0, 0.47, 7)
				animate(introLine, 0.54, { Size = offset(122, 3) })
				animate(introTitle, 0.45, { Position = UDim2.new(0.5, 0, 0.47, 0) })
				task.delay(0.47, function()
					if alive and version == current then
						animate(intro, 0.27, { GroupTransparency = 1 })
					end
				end)
				task.delay(0.76, function()
					if alive and version == current then
						intro.Visible = false
					end
				end)
			end
			return
		end

		intro.Visible = false
		animate(panel, 0.22, {
			Position = UDim2.new(0.5, 0, 0.5, 12),
			GroupTransparency = 1,
		}, Enum.EasingDirection.In)
		animate(overlay, 0.20, { BackgroundTransparency = 1 })
		local function finishClosing()
			if alive and version == current then
				panel.Visible = false
				overlay.Visible = false
				launcher.Visible = true
			end
		end
		if settings.motion then
			task.delay(0.23, finishClosing)
		else
			finishClosing()
		end
	end

	local press
	local dragged = false
	launcher.InputBegan:Connect(function(event)
		local kind = event.UserInputType
		if kind ~= Enum.UserInputType.Touch and kind ~= Enum.UserInputType.MouseButton1 then
			return
		end
		local viewport = root.AbsoluteSize
		dragged = false
		press = {
			event = event,
			x = event.Position.X,
			y = event.Position.Y,
			launcherX = launcher.Position.X.Scale * viewport.X + launcher.Position.X.Offset,
			launcherY = launcher.Position.Y.Scale * viewport.Y + launcher.Position.Y.Offset,
		}
	end)

	local connections = {
		Input.InputChanged:Connect(function(event)
			if not press then
				return
			end
			local movingTouch = press.event.UserInputType == Enum.UserInputType.Touch and event == press.event
			local movingMouse = press.event.UserInputType == Enum.UserInputType.MouseButton1
				and event.UserInputType == Enum.UserInputType.MouseMovement
			if not movingTouch and not movingMouse then
				return
			end
			local dx = event.Position.X - press.x
			local dy = event.Position.Y - press.y
			dragged = dragged or math.abs(dx) + math.abs(dy) > 9
			if dragged then
				placeLauncher(press.launcherX + dx, press.launcherY + dy)
				local viewport = root.AbsoluteSize
				if viewport.X > 0 and viewport.Y > 0 then
					pinnedLauncher = Vector2.new(
						launcher.Position.X.Offset / viewport.X,
						launcher.Position.Y.Offset / viewport.Y
					)
				end
			end
		end),
		Input.InputEnded:Connect(function(event)
			if press and event == press.event then
				press = nil
			end
		end),
		Input.InputBegan:Connect(function(event, handled)
			if not handled and event.KeyCode == Enum.KeyCode.RightShift and not Input:GetFocusedTextBox() then
				setOpen(not open)
			end
		end),
	}

	launcher.Activated:Connect(function()
		if not dragged then
			setOpen(true)
		end
		dragged = false
	end)
	close.Activated:Connect(function()
		setOpen(false)
	end)
	overlay.Activated:Connect(function(event)
		local pointer = event.Position
		local corner = panel.AbsolutePosition
		local size = panel.AbsoluteSize
		local inside = pointer.X >= corner.X and pointer.X < corner.X + size.X
			and pointer.Y >= corner.Y and pointer.Y < corner.Y + size.Y
		if not inside then
			setOpen(false)
		end
	end)
	root:GetPropertyChangedSignal("AbsoluteSize"):Connect(layout)

	gui.Destroying:Connect(function()
		alive = false
		mounted[playerGui] = nil
		for _, connection in ipairs(connections) do
			connection:Disconnect()
		end
		for object in pairs(motions) do
			cancelMotion(object)
		end
	end)

	task.spawn(function()
		while alive do
			if settings.clock and not open then
				refreshClock()
			end
			task.wait(1)
		end
	end)

	local controller = {}

	function controller:Open()
		setOpen(true)
	end

	function controller:Close()
		setOpen(false)
	end

	function controller:Destroy()
		if alive then
			gui:Destroy()
		end
	end

	mounted[playerGui] = controller
	layout()
	repaint()
	task.defer(function()
		if showOnMount then
			controller:Open()
		end
	end)

	return controller
end

return Ryou
