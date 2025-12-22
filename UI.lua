local addonName, addon = ...
local DWT = DailyWeeklyTodo

-- UI Constants
local FRAME_WIDTH = 350
local FRAME_HEIGHT = 500
local CHECKBOX_SIZE = 20
local ROW_HEIGHT = 25
local PADDING = 10

function DWT:CreateMainFrame()
    if self.mainFrame then
        return self.mainFrame
    end
    
    -- Create main frame
    local frame = CreateFrame("Frame", "DailyWeeklyTodoMainFrame", UIParent, "BasicFrameTemplateWithInset")
    frame:SetSize(FRAME_WIDTH, FRAME_HEIGHT)
    frame:SetPoint("CENTER", UIParent, "CENTER", 0, 0)
    frame:SetFrameStrata("HIGH")
    frame:SetClampedToScreen(true)
    frame:SetMovable(true)
    frame:EnableMouse(true)
    frame:RegisterForDrag("LeftButton")
    frame:SetScript("OnDragStart", frame.StartMoving)
    frame:SetScript("OnDragStop", frame.StopMovingOrSizing)
    frame:Hide()
    
    -- Title
    frame.title = frame:CreateFontString(nil, "OVERLAY")
    frame.title:SetFontObject("GameFontHighlightLarge")
    frame.title:SetPoint("CENTER", frame.TitleBg, "CENTER", 0, 0)
    frame.title:SetText("Daily & Weekly Todos")
    
    -- Close button (already exists in BasicFrameTemplate)
    frame.CloseButton:SetScript("OnClick", function()
        self:HideMainFrame()
    end)
    
    -- Create scroll frame for todos
    local scrollFrame = CreateFrame("ScrollFrame", nil, frame, "UIPanelScrollFrameTemplate")
    scrollFrame:SetPoint("TOPLEFT", frame.Inset, "TOPLEFT", 4, -4)
    scrollFrame:SetPoint("BOTTOMRIGHT", frame.Inset, "BOTTOMRIGHT", -23, 4)
    frame.scrollFrame = scrollFrame
    
    -- Create content frame
    local content = CreateFrame("Frame", nil, scrollFrame)
    content:SetSize(FRAME_WIDTH - 50, 1000) -- Height will be adjusted dynamically
    scrollFrame:SetScrollChild(content)
    frame.content = content
    
    -- Daily section header
    local dailyHeader = content:CreateFontString(nil, "OVERLAY")
    dailyHeader:SetFontObject("GameFontNormalLarge")
    dailyHeader:SetPoint("TOPLEFT", content, "TOPLEFT", PADDING, -PADDING)
    dailyHeader:SetText("Daily Todos")
    dailyHeader:SetTextColor(0.9, 0.8, 0.5) -- Gold color
    frame.dailyHeader = dailyHeader
    
    -- Daily progress text
    local dailyProgress = content:CreateFontString(nil, "OVERLAY")
    dailyProgress:SetFontObject("GameFontNormal")
    dailyProgress:SetPoint("TOPRIGHT", content, "TOPRIGHT", -PADDING, -PADDING)
    dailyProgress:SetText("0/0")
    dailyProgress:SetTextColor(0.7, 0.7, 0.7)
    frame.dailyProgress = dailyProgress
    
    -- Container for daily todos
    local dailyContainer = CreateFrame("Frame", nil, content)
    dailyContainer:SetPoint("TOPLEFT", dailyHeader, "BOTTOMLEFT", 0, -5)
    dailyContainer:SetPoint("RIGHT", content, "RIGHT", -PADDING, 0)
    dailyContainer:SetHeight(1)
    frame.dailyContainer = dailyContainer
    
    -- Weekly section header  
    local weeklyHeader = content:CreateFontString(nil, "OVERLAY")
    weeklyHeader:SetFontObject("GameFontNormalLarge")
    weeklyHeader:SetPoint("TOPLEFT", dailyContainer, "BOTTOMLEFT", 0, -20)
    weeklyHeader:SetText("Weekly Todos")
    weeklyHeader:SetTextColor(0.5, 0.8, 0.9) -- Blue color
    frame.weeklyHeader = weeklyHeader
    
    -- Weekly progress text
    local weeklyProgress = content:CreateFontString(nil, "OVERLAY")
    weeklyProgress:SetFontObject("GameFontNormal")
    weeklyProgress:SetPoint("TOPRIGHT", content, "TOPRIGHT", -PADDING, weeklyHeader:GetTop() - content:GetTop())
    weeklyProgress:SetText("0/0")
    weeklyProgress:SetTextColor(0.7, 0.7, 0.7)
    frame.weeklyProgress = weeklyProgress
    
    -- Container for weekly todos
    local weeklyContainer = CreateFrame("Frame", nil, content)
    weeklyContainer:SetPoint("TOPLEFT", weeklyHeader, "BOTTOMLEFT", 0, -5)
    weeklyContainer:SetPoint("RIGHT", content, "RIGHT", -PADDING, 0)
    weeklyContainer:SetHeight(1)
    frame.weeklyContainer = weeklyContainer
    
    -- Add todo button
    local addButton = CreateFrame("Button", nil, frame, "UIPanelButtonTemplate")
    addButton:SetSize(100, 25)
    addButton:SetPoint("BOTTOMLEFT", frame, "BOTTOMLEFT", PADDING, PADDING)
    addButton:SetText("Add Todo")
    addButton:SetScript("OnClick", function()
        self:ShowAddTodoDialog()
    end)
    frame.addButton = addButton
    
    -- Reset button
    local resetButton = CreateFrame("Button", nil, frame, "UIPanelButtonTemplate")
    resetButton:SetSize(80, 25)
    resetButton:SetPoint("BOTTOMRIGHT", frame, "BOTTOMRIGHT", -PADDING, PADDING)
    resetButton:SetText("Reset All")
    resetButton:SetScript("OnClick", function()
        self:ResetTodos()
        self:RefreshUI()
        print("|cff00ff00Daily Weekly Todo:|r All todos reset!")
    end)
    frame.resetButton = resetButton
    
    self.mainFrame = frame
    self:RefreshUI()
    return frame
end

function DWT:CreateTodoCheckbox(parent, todo, todoType, index)
    local checkbox = CreateFrame("CheckButton", nil, parent)
    checkbox:SetSize(CHECKBOX_SIZE, CHECKBOX_SIZE)
    checkbox:SetNormalTexture("Interface\\Buttons\\UI-CheckBox-Up")
    checkbox:SetPushedTexture("Interface\\Buttons\\UI-CheckBox-Down")
    checkbox:SetHighlightTexture("Interface\\Buttons\\UI-CheckBox-Highlight", "ADD")
    checkbox:SetCheckedTexture("Interface\\Buttons\\UI-CheckBox-Check")
    checkbox:SetDisabledTexture("Interface\\Buttons\\UI-CheckBox-Check-Disabled")
    
    -- Set checked state
    checkbox:SetChecked(todo.completed)
    
    -- Create text label
    local text = checkbox:CreateFontString(nil, "OVERLAY")
    text:SetFontObject("GameFontNormal")
    text:SetPoint("LEFT", checkbox, "RIGHT", 5, 0)
    text:SetText(todo.text)
    
    -- Update text appearance based on completion
    if todo.completed then
        text:SetTextColor(0.5, 0.5, 0.5)
    else
        text:SetTextColor(1, 1, 1)
    end
    
    -- Click handler
    checkbox:SetScript("OnClick", function(self)
        DWT:ToggleTodo(todoType, index)
    end)
    
    -- Enable/disable checkbox based on todo enabled state
    if not todo.enabled then
        checkbox:SetEnabled(false)
        text:SetTextColor(0.3, 0.3, 0.3)
    end
    
    checkbox.text = text
    return checkbox
end

function DWT:RefreshUI()
    if not self.mainFrame then
        return
    end
    
    -- Clear existing checkboxes
    if self.dailyCheckboxes then
        for _, checkbox in ipairs(self.dailyCheckboxes) do
            checkbox:Hide()
            checkbox:SetParent(nil)
        end
    end
    
    if self.weeklyCheckboxes then
        for _, checkbox in ipairs(self.weeklyCheckboxes) do
            checkbox:Hide()
            checkbox:SetParent(nil)
        end
    end
    
    self.dailyCheckboxes = {}
    self.weeklyCheckboxes = {}
    
    -- Create daily todo checkboxes
    local yOffset = 0
    for i, todo in ipairs(self.db.profile.dailyTodos) do
        if todo.enabled then
            local checkbox = self:CreateTodoCheckbox(self.mainFrame.dailyContainer, todo, "daily", i)
            checkbox:SetPoint("TOPLEFT", self.mainFrame.dailyContainer, "TOPLEFT", 0, -yOffset)
            table.insert(self.dailyCheckboxes, checkbox)
            yOffset = yOffset + ROW_HEIGHT
        end
    end
    
    -- Update daily container height
    self.mainFrame.dailyContainer:SetHeight(math.max(yOffset, 1))
    
    -- Create weekly todo checkboxes
    yOffset = 0
    for i, todo in ipairs(self.db.profile.weeklyTodos) do
        if todo.enabled then
            local checkbox = self:CreateTodoCheckbox(self.mainFrame.weeklyContainer, todo, "weekly", i)
            checkbox:SetPoint("TOPLEFT", self.mainFrame.weeklyContainer, "TOPLEFT", 0, -yOffset)
            table.insert(self.weeklyCheckboxes, checkbox)
            yOffset = yOffset + ROW_HEIGHT
        end
    end
    
    -- Update weekly container height
    self.mainFrame.weeklyContainer:SetHeight(math.max(yOffset, 1))
    
    -- Update progress counters
    local dailyCompleted, dailyTotal = self:GetCompletedCount("daily")
    local weeklyCompleted, weeklyTotal = self:GetCompletedCount("weekly")
    
    self.mainFrame.dailyProgress:SetText(dailyCompleted .. "/" .. dailyTotal)
    self.mainFrame.weeklyProgress:SetText(weeklyCompleted .. "/" .. weeklyTotal)
    
    -- Update content height for scrolling
    local totalHeight = 60 + self.mainFrame.dailyContainer:GetHeight() + 40 + self.mainFrame.weeklyContainer:GetHeight() + 40
    self.mainFrame.content:SetHeight(totalHeight)
end

function DWT:ShowMainFrame()
    if not self.mainFrame then
        self:CreateMainFrame()
    end
    
    self.mainFrame:Show()
    self:RefreshUI()
end

function DWT:HideMainFrame()
    if self.mainFrame then
        self.mainFrame:Hide()
    end
end

function DWT:ShowAddTodoDialog()
    -- Simple input dialog for adding todos
    StaticPopupDialogs["DWT_ADD_TODO"] = {
        text = "Enter todo text:",
        button1 = "Add Daily",
        button2 = "Add Weekly",
        button3 = "Cancel",
        hasEditBox = true,
        timeout = 0,
        whileDead = true,
        hideOnEscape = true,
        OnAccept = function(self)
            local text = self.editBox:GetText()
            if text and text:trim() ~= "" then
                DWT:AddDailyTodo(text)
            end
        end,
        OnCancel = function(self)
            local text = self.editBox:GetText()
            if text and text:trim() ~= "" then
                DWT:AddWeeklyTodo(text)
            end
        end,
        EditBoxOnEnterPressed = function(self)
            local parent = self:GetParent()
            local text = parent.editBox:GetText()
            if text and text:trim() ~= "" then
                DWT:AddDailyTodo(text)
            end
            parent:Hide()
        end,
        EditBoxOnEscapePressed = function(self)
            self:GetParent():Hide()
        end,
    }
    
    StaticPopup_Show("DWT_ADD_TODO")
end