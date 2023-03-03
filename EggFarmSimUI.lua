local lukanker = {}

local UIS = game:GetService('UserInputService')

local Player = game.Players.LocalPlayer

local Window
local Sections = {}

local DragMousePosition
local FramePosition
local Dragging = false

function lukanker.New()
	Window = CreateWindowUI()
	local Menu = Window.Menu

	Menu.InputBegan:Connect(function(Input)
		if Input.UserInputType == Enum.UserInputType.MouseButton1 then
			Dragging = true

			DragMousePosition = Vector2.new(Input.Position.X, Input.Position.Y)
			FramePosition = Vector2.new(Menu.Position.X.Offset, Menu.Position.Y.Offset)
		end
	end)

	Menu.InputEnded:Connect(function(Input)
		if Input.UserInputType == Enum.UserInputType.MouseButton1 then
			Dragging = false
		end
	end)

	UIS.InputChanged:Connect(function(Input)
		if Dragging then
			local NewPosition = FramePosition + ((Vector2.new(Input.Position.X, Input.Position.Y) - DragMousePosition))
			Menu.Position = UDim2.new(0, NewPosition.X, 0, NewPosition.Y)
		end
	end)

	return lukanker
end

function lukanker:NewSection(Name)
	if not Window then return end

	local Sections = {}

	local Section = CreateSectionUI(Name)
	local SectionButton = CreateSectionButtonUI(Name)

	SectionButton.MouseButton1Click:Connect(function()
		for i, SectionObject in pairs(Window.Menu.Sections:GetChildren()) do
			SectionObject.Visible = false
			Section.Visible = true
		end
	end)


	table.insert(Sections, Section)

	function Sections:CreateTab(Name)
		local Tabs = {}

		local Tab = CreateTabUI(Section, Name)

		table.insert(Tabs, Tab)

		function Tabs:CreateToggle(Name, DefaultValue, Key, callback)
			local Toggle = CreateToggleButtonUI(Tab, Name)
			local State = DefaultValue

			if State then
				Toggle.Borders.Borders.BackgroundColor3 = Color3.new(0, 0.737255, 0.831373)
			else
				Toggle.Borders.Borders.BackgroundColor3 = Color3.new(0.258824, 0.258824, 0.258824)
			end

			callback(State)

			Toggle.InputBegan:Connect(function(Input)
				if Input.UserInputType == Enum.UserInputType.MouseButton1 then
					State = not State

					if State then
						Toggle.Borders.Borders.BackgroundColor3 = Color3.new(0, 0.737255, 0.831373)
					else
						Toggle.Borders.Borders.BackgroundColor3 = Color3.new(0.258824, 0.258824, 0.258824)
					end
					callback(State)
				end
			end)

			UIS.InputBegan:Connect(function(Input, IsTyping)
				if IsTyping then return end
				if Input.KeyCode == Enum.KeyCode[Key] and Key then
					State = not State

					if State then
						Toggle.Borders.Borders.BackgroundColor3 = Color3.new(0, 0.737255, 0.831373)
					else
						Toggle.Borders.Borders.BackgroundColor3 = Color3.new(0.258824, 0.258824, 0.258824)
					end

					callback(State)
				end
			end)
		end

		function Tabs:CreateUseButton(Name, Key, callback)
			local UseButton = CreateUseButtonUI(Tab, Name)

			UseButton.InputBegan:Connect(function(Input)
				if Input.UserInputType == Enum.UserInputType.MouseButton1 then
					callback()
				end
			end)

			UIS.InputBegan:Connect(function(Input, IsTyping)
				if IsTyping then return end
				if Input.KeyCode == Enum.KeyCode[Key] and Key then
					callback()
				end
			end)
		end

		function Tabs:CreateSlider(DefaultValue, Max, callback)
			local Cursor = CreateSliderUI(Tab)
			local Slider = Cursor.Parent
			local TextLabel = Slider.Number
			local DraggingSlider = false

			TextLabel.Text = DefaultValue
			Cursor.Position = UDim2.new(DefaultValue / Max, 0, Cursor.Position.Y.Scale, Cursor.Position.Y.Offset)

			callback(DefaultValue)

			Cursor.InputBegan:Connect(function(Input)
				if Input.UserInputType == Enum.UserInputType.MouseButton1 then
					DraggingSlider = true
				end
			end)

			Cursor.InputEnded:Connect(function(Input)
				if Input.UserInputType == Enum.UserInputType.MouseButton1 then
					DraggingSlider = false
				end
			end)

			UIS.InputChanged:Connect(function(Input)
				if DraggingSlider then
					local MousePos = UIS:GetMouseLocation().X
					local Position = Snap((MousePos - Slider.AbsolutePosition.X) / Slider.AbsoluteSize.X, 1 / Max)
					local Percentage = math.clamp(Position, 0, 1)
					local Value = math.round(Percentage * Max)

					TextLabel.Text = Value
					Cursor.Position = UDim2.new(Percentage, 0, Cursor.Position.Y.Scale, Cursor.Position.Y.Offset)

					callback(Value)
				end
			end)
		end

		return Tabs
	end


	return Sections
end

function CreateWindowUI()
	Window = Instance.new("ScreenGui")
	Window.Parent = game.Players.LocalPlayer.PlayerGui
	Window.Name = "Window"
	Window.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

	local Menu = Instance.new("Frame")
	Menu.Parent = Window
	Menu.AnchorPoint = Vector2.new(0.5, 0.5)
	Menu.BackgroundColor3 = Color3.new(1, 1, 1)
	Menu.BorderColor3 = Color3.new(0.105882, 0.164706, 0.207843)
	Menu.BorderSizePixel = 0
	Menu.Name = "Menu"
	Menu.Position = UDim2.new(0.5, 0, 0.5, -30)
	Menu.Size = UDim2.new(0, 540, 0, 396)
	Menu.ZIndex = 2

	local Close = Instance.new("TextButton")
	Close.Parent = Menu
	Close.BackgroundColor3 = Color3.new(1, 1, 1)
	Close.BackgroundTransparency = 1
	Close.Modal = true
	Close.Name = "Close"
	Close.Position = UDim2.new(1, -46, 0, 10)
	Close.Rotation = 45
	Close.Size = UDim2.new(0, 36, 0, 36)
	Close.Text = "+"
	Close.TextColor3 = Color3.new(1, 0.321569, 0.321569)
	Close.TextSize = 54
	Close.ZIndex = 8

	local Categories = Instance.new("Frame")
	Categories.Parent = Menu
	Categories.BackgroundColor3 = Color3.new(1, 1, 1)
	Categories.BackgroundTransparency = 1
	Categories.Name = "Categories"
	Categories.Position = UDim2.new(0, 10, 0, 56)
	Categories.Size = UDim2.new(0, 100, 0, 100)
	Categories.ZIndex = 5
	
	local UIListLayout = Instance.new("UIListLayout")
	UIListLayout.Parent = Categories
	UIListLayout.FillDirection = Enum.FillDirection.Horizontal
	UIListLayout.Padding = UDim.new(0, 10)
	UIListLayout.SortOrder = Enum.SortOrder.LayoutOrder

	local Title = Instance.new("TextLabel")
	Title.Parent = Menu
	Title.BackgroundColor3 = Color3.new(1, 1, 1)
	Title.BackgroundTransparency = 1
	Title.BorderColor3 = Color3.new(0.105882, 0.164706, 0.207843)
	Title.Name = "Title"
	Title.Position = UDim2.new(0, 15, 0, 10)
	Title.Size = UDim2.new(1, 0, 0, 36)
	Title.Text = "Egg Farm Simulator"
	Title.TextColor3 = Color3.new(0.458824, 0.458824, 0.458824)
	Title.TextSize = 26
	Title.TextStrokeColor3 = Color3.new(1, 1, 1)
	Title.TextXAlignment = Enum.TextXAlignment.Left
	Title.ZIndex = 3

	local Sections = Instance.new("Folder")
	Sections.Parent = Menu
	Sections.Name = "Sections"

	return Window
end

function CreateSectionUI(Name)
	local Section = Instance.new("ScrollingFrame")
	Section.Parent = Window.Menu.Sections
	Section.BackgroundColor3 = Color3.new(1, 1, 1)
	Section.BackgroundTransparency = 1
	Section.BorderSizePixel = 0
	Section.BottomImage = "rbxassetid://76676396"
	Section.CanvasSize = UDim2.new(0, 0, 0, 260)
	Section.MidImage = "rbxassetid://76676368"
	Section.Name = Name
	Section.Position = UDim2.new(0, 10, 0, 102)
	Section.ScrollBarThickness = 4
	Section.Size = UDim2.new(0.351851851, 330, 1, -112)
	Section.TopImage = "rbxassetid://76676352"
	Section.VerticalScrollBarInset = Enum.ScrollBarInset.Always

	local UIGridLayout = Instance.new("UIGridLayout")
	UIGridLayout.Parent = Section
	UIGridLayout.CellPadding = UDim2.new(0, 10, 0, 10)
	UIGridLayout.CellSize = UDim2.new(0.32, 0, 1, 0)
	UIGridLayout.FillDirectionMaxCells = 3
	UIGridLayout.SortOrder = Enum.SortOrder.LayoutOrder

	return Section
end

function CreateSectionButtonUI(Name)
	local TextButton = Instance.new("TextButton")
	TextButton.Parent = Window.Menu.Categories
	TextButton.AutoButtonColor = false
	TextButton.BackgroundColor3 = Color3.new(1, 1, 1)
	TextButton.BackgroundTransparency = 1
	TextButton.BorderColor3 = Color3.new(0.105882, 0.164706, 0.207843)
	TextButton.BorderSizePixel = 0
	TextButton.LayoutOrder = 1
	TextButton.Name = "TextButton"
	TextButton.Position = UDim2.new(0, 10, 0, 10)
	TextButton.Size = UDim2.new(0, 96, 0, 36)
	TextButton.Text = ""
	TextButton.TextColor3 = Color3.new(1, 1, 1)
	TextButton.TextSize = 22
	TextButton.ZIndex = 4

	local Background = Instance.new("Frame")
	Background.Parent = TextButton
	Background.BackgroundColor3 = Color3.new(0.258824, 0.258824, 0.258824)
	Background.BorderSizePixel = 0
	Background.Name = "Background"
	Background.Size = UDim2.new(1, 0, 1.00000012, 0)
	Background.ZIndex = 0

	local Borders = Instance.new("Frame")
	Borders.Parent = Background
	Borders.BackgroundColor3 = Color3.new(0, 0.737255, 0.831373)
	Borders.BorderSizePixel = 0
	Borders.Name = "Borders"
	Borders.Size = UDim2.new(1, 0, 0.888888896, 0)
	Borders.ZIndex = 0

	local UICorner = Instance.new("UICorner")
	UICorner.Parent = Borders
	local UICorner1 = Instance.new("UICorner")
	UICorner1.Parent = Background

	local TextLabel = Instance.new("TextLabel")
	TextLabel.Parent = TextButton
	TextLabel.AnchorPoint = Vector2.new(0.5, 0.5)
	TextLabel.BackgroundColor3 = Color3.new(1, 1, 1)
	TextLabel.BackgroundTransparency = 1
	TextLabel.BorderSizePixel = 0
	TextLabel.Font = Enum.Font.SourceSans
	TextLabel.Position = UDim2.new(0.5, 0, 0.5, 0)
	TextLabel.Size = UDim2.new(1, 0, 1, 0)
	TextLabel.Text = "Character"
	TextLabel.TextColor3 = Color3.new(1, 1, 1)
	TextLabel.TextScaled = true
	TextLabel.TextSize = 14
	TextLabel.TextWrapped = true

	return TextButton
end

function CreateTabUI(Section, Name)
	local Tab = Instance.new("Frame")
	Tab.Parent = Section
	Tab.BackgroundColor3 = Color3.new(0.258824, 0.258824, 0.258824)
	Tab.BorderSizePixel = 0
	Tab.Name = "Tab"
	Tab.Size = UDim2.new(0, 100, 0, 100)
	
	local Title = Instance.new("TextLabel")
	Title.Parent = Tab
	Title.BackgroundColor3 = Color3.new(1, 1, 1)
	Title.BackgroundTransparency = 1
	Title.BorderSizePixel = 0
	Title.Font = Enum.Font.SourceSans
	Title.Name = "Title"
	Title.Position = UDim2.new(0, 15, 0, 0)
	Title.Size = UDim2.new(1, 0, 0.150000006, 0)
	Title.Text = Name
	Title.TextColor3 = Color3.new(1, 1, 1)
	Title.TextScaled = true
	Title.TextSize = 14
	Title.TextWrapped = true
	Title.TextXAlignment = Enum.TextXAlignment.Left
	
	local UICorner = Instance.new("UICorner")
	UICorner.Parent = Tab

	local Background = Instance.new("Frame")
	Background.Parent = Tab
	Background.BackgroundColor3 = Color3.new(0.470588, 0.564706, 0.611765)
	Background.BorderSizePixel = 0
	Background.Name = "Background"
	Background.Size = UDim2.new(1, 0, 0.980000019, 0)
	Background.ZIndex = 0

	local UICorner2 = Instance.new("UICorner")
	UICorner2.Parent = Background

	local Options = Instance.new("Frame")
	Options.Parent = Tab
	Options.BackgroundColor3 = Color3.new(0.470588, 0.564706, 0.611765)
	Options.BorderSizePixel = 0
	Options.Name = "Options"
	Options.Position = UDim2.new(0, 0, 0.14, 0)
	Options.Size = UDim2.new(1, 0, 0.81, 0)
	Options.ZIndex = 0

	local UIListLayout = Instance.new("UIListLayout")
	UIListLayout.Parent = Options
	UIListLayout.Padding = UDim.new(0, 2)
	UIListLayout.SortOrder = Enum.SortOrder.LayoutOrder

	return Tab
end

function CreateToggleButtonUI(Tab, Name)
	local Toggle = Instance.new("Frame")
	Toggle.Parent = Tab.Options
	Toggle.BackgroundColor3 = Color3.new(1, 1, 1)
	Toggle.BackgroundTransparency = 1
	Toggle.BorderSizePixel = 0
	Toggle.Name = "Toggle"
	Toggle.Size = UDim2.new(1, 0, 0, 30)

	local TextButton = Instance.new("TextButton")
	TextButton.Parent = Toggle
	TextButton.AutoButtonColor = false
	TextButton.BackgroundColor3 = Color3.new(1, 1, 1)
	TextButton.BackgroundTransparency = 1
	TextButton.BorderColor3 = Color3.new(0.105882, 0.164706, 0.207843)
	TextButton.BorderSizePixel = 0
	TextButton.LayoutOrder = 1
	TextButton.Name = "TextButton"
	TextButton.Position = UDim2.new(0, 10, 0, 10)
	TextButton.Size = UDim2.new(0, 96, 0, 36)
	TextButton.Text = ""
	TextButton.TextColor3 = Color3.new(1, 1, 1)
	TextButton.TextSize = 22
	TextButton.ZIndex = 4

	local Borders = Instance.new("Frame")
	Borders.Parent = TextButton
	Borders.BackgroundColor3 = Color3.new(0.258824, 0.258824, 0.258824)
	Borders.BorderSizePixel = 0
	Borders.Name = "Borders"
	Borders.Size = UDim2.new(0.375624746, 0, 1.00000012, 0)
	Borders.ZIndex = 0
	
	local UICorner = Instance.new("UICorner")
	UICorner.Parent = Borders

	local Borders1 = Instance.new("Frame")
	Borders1.Parent = Borders
	Borders1.BackgroundColor3 = Color3.new(0, 0.737255, 0.831373)
	Borders1.BorderSizePixel = 0
	Borders1.Name = "Borders"
	Borders1.Size = UDim2.new(1, 0, 0.888888896, 0)
	Borders1.ZIndex = 0

	local UICorner1 = Instance.new("UICorner")
	UICorner1.Parent = Borders1

	local Title = Instance.new("TextLabel")
	Title.Parent = Toggle
	Title.AnchorPoint = Vector2.new(0.5, 0.5)
	Title.BackgroundColor3 = Color3.new(1, 1, 1)
	Title.BackgroundTransparency = 1
	Title.BorderSizePixel = 0
	Title.Font = Enum.Font.SourceSans
	Title.Name = "Title"
	Title.Position = UDim2.new(0.5, 55, 0.5, 12)
	Title.Size = UDim2.new(1, 0, 1, 0)
	Title.Text = "Farm"
	Title.TextColor3 = Color3.new(1, 1, 1)
	Title.TextScaled = true
	Title.TextSize = 14
	Title.TextWrapped = true
	Title.TextXAlignment = Enum.TextXAlignment.Left

	return TextButton
end

function CreateSliderUI(Tab)
	local Slider = Instance.new("Frame")
	Slider.Parent = Tab.ScrollingFrame
	Slider.AnchorPoint = Vector2.new(0.5, 0.5)
	Slider.BackgroundColor3 = Color3.new(1, 1, 1)
	Slider.BackgroundTransparency = 1
	Slider.Name = "Slider"
	Slider.Position = UDim2.new(0.5, 0, 0.349999994, 0)
	Slider.Size = UDim2.new(1, 0, 0, 20)

	local SliderFrame = Instance.new("Frame")
	SliderFrame.Parent = Slider
	SliderFrame.AnchorPoint = Vector2.new(0, 0.5)
	SliderFrame.BackgroundColor3 = Color3.new(0, 0, 0)
	SliderFrame.BackgroundTransparency = 0.5
	SliderFrame.BorderColor3 = Color3.new(0.717647, 0.772549, 0.827451)
	SliderFrame.BorderSizePixel = 0
	SliderFrame.Name = "SliderFrame"
	SliderFrame.Position = UDim2.new(0, 12, 0, 2)
	SliderFrame.Size = UDim2.new(1, -80, 0, 4)

	local Overlay = Instance.new("ImageLabel")
	Overlay.Parent = SliderFrame
	Overlay.BackgroundColor3 = Color3.new(1, 1, 1)
	Overlay.BackgroundTransparency = 1
	Overlay.BorderSizePixel = 0
	Overlay.Image = "rbxassetid://7070634111"
	Overlay.ImageColor3 = Color3.new(0.717647, 0.772549, 0.827451)
	Overlay.Name = "Overlay"
	Overlay.Position = UDim2.new(0, -3, 0, -3)
	Overlay.ScaleType = Enum.ScaleType.Slice
	Overlay.Size = UDim2.new(1, 6, 1, 6)
	Overlay.SliceCenter = Rect.new(5, 5, 5, 5)

	local Cursor = Instance.new("TextButton")
	Cursor.Parent = SliderFrame
	Cursor.AnchorPoint = Vector2.new(0.5, 0.5)
	Cursor.BackgroundColor3 = Color3.new(0.25098, 0.313726, 0.298039)
	Cursor.BorderSizePixel = 0
	Cursor.Name = "Cursor"
	Cursor.Position = UDim2.new(0, 0, 0.5, 0)
	Cursor.Size = UDim2.new(0, 13, 0, 13)
	Cursor.Text = ""
	Cursor.TextColor3 = Color3.new(1, 1, 1)
	Cursor.TextSize = 14
	Cursor.TextStrokeTransparency = 0.6000000238418579
	Cursor.TextWrapped = true
	Cursor.ZIndex = 2

	local Overlay1 = Instance.new("ImageLabel")
	Overlay1.Parent = Cursor
	Overlay1.BackgroundColor3 = Color3.new(1, 1, 1)
	Overlay1.BackgroundTransparency = 1
	Overlay1.BorderSizePixel = 0
	Overlay1.Image = "rbxassetid://7070585107"
	Overlay1.ImageColor3 = Color3.new(0.717647, 0.772549, 0.827451)
	Overlay1.Name = "Overlay"
	Overlay1.Position = UDim2.new(0, -2, 0, -2)
	Overlay1.ScaleType = Enum.ScaleType.Slice
	Overlay1.Size = UDim2.new(1, 4, 1, 4)
	Overlay1.SliceCenter = Rect.new(8, 8, 8, 8)
	Overlay1.ZIndex = 2

	local Number = Instance.new("TextLabel")
	Number.Parent = SliderFrame
	Number.Active = true
	Number.AnchorPoint = Vector2.new(0.5, 1)
	Number.BackgroundColor3 = Color3.new(0.972549, 0.972549, 0.972549)
	Number.BackgroundTransparency = 1
	Number.Name = "Number"
	Number.Position = UDim2.new(1, 32, 0, 12)
	Number.Selectable = true
	Number.Size = UDim2.new(0, 40, 0, 20)
	Number.Text = "1"
	Number.TextSize = 10
	Number.TextStrokeColor3 = Color3.new(0.203922, 0.243137, 0.258824)
	Number.TextTransparency = 0.1
	Number.Font = Enum.Font.Legacy
	Number.TextXAlignment = Enum.TextXAlignment.Center
	Number.ZIndex = 2

	local Overlay2 = Instance.new("ImageLabel")
	Overlay2.Parent = Number
	Overlay2.BackgroundColor3 = Color3.new(1, 1, 1)
	Overlay2.BackgroundTransparency = 1
	Overlay2.BorderSizePixel = 0
	Overlay2.Image = "http://www.roblox.com/asset/?id=4645592841"
	Overlay2.ImageColor3 = Color3.new(0.717647, 0.772549, 0.827451)
	Overlay2.Name = "Overlay"
	Overlay2.Position = UDim2.new(0, -1, 0, -1)
	Overlay2.ScaleType = Enum.ScaleType.Slice
	Overlay2.Size = UDim2.new(1, 2, 1, 2)
	Overlay2.SliceCenter = Rect.new(8, 8, 8, 8)

	return Cursor
end

function CreateUseButtonUI(Tab, Name)
	local Use = Instance.new("Frame")
	Use.Parent = Tab.ScrollingFrame
	Use.AnchorPoint = Vector2.new(0.5, 0.5)
	Use.BackgroundColor3 = Color3.new(1, 1, 1)
	Use.BackgroundTransparency = 1
	Use.Name = "Use"
	Use.Position = UDim2.new(0.5, 0, 0.349999994, 0)
	Use.Size = UDim2.new(0, 285, 0, 30)

	local TextButton = Instance.new("TextButton")
	TextButton.Parent = Use
	TextButton.AutoButtonColor = false
	TextButton.BackgroundColor3 = Color3.new(0.34902, 0.47451, 0.466667)
	TextButton.BorderSizePixel = 0
	TextButton.LayoutOrder = 1
	TextButton.Name = Name
	TextButton.Position = UDim2.new(0, 10, 0, 5)
	TextButton.Size = UDim2.new(0, 70, 0, 24)
	TextButton.Text = Name
	TextButton.TextColor3 = Color3.new(1, 1, 1)
	TextButton.TextStrokeTransparency = 0.6000000238418579
	TextButton.TextWrapped = true

	local Overlay = Instance.new("ImageLabel")
	Overlay.Parent = TextButton
	Overlay.BackgroundColor3 = Color3.new(1, 1, 1)
	Overlay.BackgroundTransparency = 1
	Overlay.BorderSizePixel = 0
	Overlay.Image = "http://www.roblox.com/asset/?id=4645592841"
	Overlay.ImageColor3 = Color3.new(0.717647, 0.772549, 0.827451)
	Overlay.Name = "Overlay"
	Overlay.Position = UDim2.new(0, -1, 0, -1)
	Overlay.ScaleType = Enum.ScaleType.Slice
	Overlay.Size = UDim2.new(1, 2, 1, 2)
	Overlay.SliceCenter = Rect.new(8, 8, 8, 8)

	return TextButton
end

function Snap(number, factor)
	if factor == 0 then
		return number
	else
		return math.floor(number/factor + 0.5) * factor
	end
end

return lukanker
