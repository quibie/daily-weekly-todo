local addonName, addon = ...
local DWT = DailyWeeklyTodo

-- UI Constants
local FRAME_WIDTH = 380
local FRAME_HEIGHT = 500
local HEADER_HEIGHT = 30
local FOOTER_HEIGHT = 35
local CHECKBOX_SIZE = 18
local BUTTON_SIZE = 16
local ROW_HEIGHT = 24
local PADDING = 10
local INDENT = 25

-- Create a todo row with delete, reorder buttons, and checkbox
function DWT:CreateTodoRow(parent, todo, todoType, index, characterKey, isCurrentCharacter)
    local row = CreateFrame("Frame", nil, parent)
    row:SetHeight(ROW_HEIGHT)
    
    local xOffset = 0
    
    -- Delete button (X) - leftmost
    local deleteBtn = CreateFrame("Button", nil, row)
    deleteBtn:SetSize(BUTTON_SIZE, BUTTON_SIZE)
    deleteBtn:SetPoint("LEFT", row, "LEFT", xOffset, 0)
    deleteBtn:SetNormalTexture("Interface\\Buttons\\UI-StopButton")
    deleteBtn:SetHighlightTexture("Interface\\Buttons\\UI-StopButton", "ADD")
    deleteBtn:SetScript("OnClick", function()
        DWT:DeleteTodo(todoType, index, characterKey)
    end)
    deleteBtn:SetScript("OnEnter", function(self)
        GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
        GameTooltip:SetText("Delete Task")
        GameTooltip:Show()
    end)
    deleteBtn:SetScript("OnLeave", function()
        GameTooltip:Hide()
    end)
    if not isCurrentCharacter then
        deleteBtn:SetAlpha(0.3)
        deleteBtn:SetEnabled(false)
    end
    row.deleteBtn = deleteBtn
    xOffset = xOffset + BUTTON_SIZE + 2
    
    -- Move up button
    local upBtn = CreateFrame("Button", nil, row)
    upBtn:SetSize(BUTTON_SIZE, BUTTON_SIZE)
    upBtn:SetPoint("LEFT", row, "LEFT", xOffset, 0)
    upBtn:SetNormalTexture("Interface\\ChatFrame\\UI-ChatIcon-ScrollUp-Up")
    upBtn:SetPushedTexture("Interface\\ChatFrame\\UI-ChatIcon-ScrollUp-Down")
    upBtn:SetHighlightTexture("Interface\\ChatFrame\\UI-ChatIcon-ScrollUp-Highlight", "ADD")
    upBtn:SetScript("OnClick", function()
        DWT:MoveTodoUp(todoType, index, characterKey)
    end)
    upBtn:SetScript("OnEnter", function(self)
        GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
        GameTooltip:SetText("Move Up")
        GameTooltip:Show()
    end)
    upBtn:SetScript("OnLeave", function()
        GameTooltip:Hide()
    end)
    if not isCurrentCharacter then
        upBtn:SetAlpha(0.3)
        upBtn:SetEnabled(false)
    end
    row.upBtn = upBtn
    xOffset = xOffset + BUTTON_SIZE + 1
    
    -- Move down button
    local downBtn = CreateFrame("Button", nil, row)
    downBtn:SetSize(BUTTON_SIZE, BUTTON_SIZE)
    downBtn:SetPoint("LEFT", row, "LEFT", xOffset, 0)
    downBtn:SetNormalTexture("Interface\\ChatFrame\\UI-ChatIcon-ScrollDown-Up")
    downBtn:SetPushedTexture("Interface\\ChatFrame\\UI-ChatIcon-ScrollDown-Down")
    downBtn:SetHighlightTexture("Interface\\ChatFrame\\UI-ChatIcon-ScrollDown-Highlight", "ADD")
    downBtn:SetScript("OnClick", function()
        DWT:MoveTodoDown(todoType, index, characterKey)
    end)
    downBtn:SetScript("OnEnter", function(self)
        GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
        GameTooltip:SetText("Move Down")
        GameTooltip:Show()
    end)
    downBtn:SetScript("OnLeave", function()
        GameTooltip:Hide()
    end)
    if not isCurrentCharacter then
        downBtn:SetAlpha(0.3)
        downBtn:SetEnabled(false)
    end
    row.downBtn = downBtn
    xOffset = xOffset + BUTTON_SIZE + 4
    
    -- Checkbox
    local checkbox = CreateFrame("CheckButton", nil, row)
    checkbox:SetSize(CHECKBOX_SIZE, CHECKBOX_SIZE)
    checkbox:SetPoint("LEFT", row, "LEFT", xOffset, 0)
    checkbox:SetNormalTexture("Interface\\Buttons\\UI-CheckBox-Up")
    checkbox:SetPushedTexture("Interface\\Buttons\\UI-CheckBox-Down")
    checkbox:SetHighlightTexture("Interface\\Buttons\\UI-CheckBox-Highlight", "ADD")
    checkbox:SetCheckedTexture("Interface\\Buttons\\UI-CheckBox-Check")
    checkbox:SetDisabledTexture("Interface\\Buttons\\UI-CheckBox-Check-Disabled")
    checkbox:SetChecked(todo.completed)
    checkbox:SetScript("OnClick", function()
        DWT:ToggleTodo(todoType, index, characterKey)
    end)
    if not isCurrentCharacter then
        checkbox:SetEnabled(false)
    end
    row.checkbox = checkbox
    xOffset = xOffset + CHECKBOX_SIZE + 4
    
    -- Text label
    local text = row:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    text:SetPoint("LEFT", row, "LEFT", xOffset, 0)
    text:SetPoint("RIGHT", row, "RIGHT", -5, 0)
    text:SetJustifyH("LEFT")
    text:SetText(todo.text)
    text:SetWordWrap(false)
    
    if todo.completed then
        text:SetTextColor(0.5, 0.5, 0.5)
    else
        text:SetTextColor(1, 1, 1)
    end
    
    row.text = text
    return row
end

-- Create collapsible section header
function DWT:CreateSectionHeader(parent, title, isCollapsed, onToggle, colorR, colorG, colorB, progress)
    local header = CreateFrame("Button", nil, parent)
    header:SetHeight(22)
    
    -- Collapse indicator
    local indicator = header:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    indicator:SetPoint("LEFT", header, "LEFT", 0, 0)
    indicator:SetText(isCollapsed and "+" or "-")
    indicator:SetTextColor(0.8, 0.8, 0.8)
    header.indicator = indicator
    
    -- Title text
    local titleText = header:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
    titleText:SetPoint("LEFT", indicator, "RIGHT", 5, 0)
    titleText:SetText(title)
    titleText:SetTextColor(colorR or 1, colorG or 1, colorB or 1)
    header.titleText = titleText
    
    -- Progress text
    if progress then
        local progressText = header:CreateFontString(nil, "OVERLAY", "GameFontNormal")
        progressText:SetPoint("RIGHT", header, "RIGHT", -5, 0)
        progressText:SetText(progress)
        progressText:SetTextColor(0.7, 0.7, 0.7)
        header.progressText = progressText
    end
    
    header:SetScript("OnClick", onToggle)
    header:SetHighlightTexture("Interface\\QuestFrame\\UI-QuestLogTitleHighlight", "ADD")
    
    return header
end

-- Create character section
function DWT:CreateCharacterSection(parent, characterKey, charInfo, yOffset)
    local charData = self:GetCharacterData(characterKey)
    if not charData then return yOffset end
    
    local isCurrentCharacter = charInfo.isCurrentCharacter
    local isCollapsed = self:IsCharacterCollapsed(characterKey)
    local r, g, b = self:GetClassColor(charInfo.class)
    
    local charName = charInfo.name
    if isCurrentCharacter then
        charName = charName .. " (You)"
    end
    charName = charName .. " - " .. charInfo.realm
    
    local dailyCompleted, dailyTotal = self:GetCompletedCount("daily", characterKey)
    local weeklyCompleted, weeklyTotal = self:GetCompletedCount("weekly", characterKey)
    local totalCompleted = dailyCompleted + weeklyCompleted
    local totalTasks = dailyTotal + weeklyTotal
    local progress = string.format("(%d/%d)", totalCompleted, totalTasks)
    
    local charHeader = self:CreateSectionHeader(
        parent, 
        charName, 
        isCollapsed, 
        function() self:ToggleCharacterCollapsed(characterKey) end,
        r, g, b,
        progress
    )
    charHeader:SetPoint("TOPLEFT", parent, "TOPLEFT", 0, -yOffset)
    charHeader:SetPoint("RIGHT", parent, "RIGHT", 0, 0)
    table.insert(self.uiElements, charHeader)
    yOffset = yOffset + 24
    
    if isCollapsed then
        return yOffset
    end
    
    -- Daily section
    if #charData.dailyTodos > 0 then
        local dailyLabel = parent:CreateFontString(nil, "OVERLAY", "GameFontNormal")
        dailyLabel:SetPoint("TOPLEFT", parent, "TOPLEFT", INDENT, -yOffset)
        dailyLabel:SetText("Daily")
        dailyLabel:SetTextColor(0.9, 0.8, 0.5)
        table.insert(self.uiElements, dailyLabel)
        
        local dailyProgress = parent:CreateFontString(nil, "OVERLAY", "GameFontNormal")
        dailyProgress:SetPoint("TOPRIGHT", parent, "TOPRIGHT", -10, -yOffset)
        dailyProgress:SetText(dailyCompleted .. "/" .. dailyTotal)
        dailyProgress:SetTextColor(0.7, 0.7, 0.7)
        table.insert(self.uiElements, dailyProgress)
        
        yOffset = yOffset + 18
        
        for i, todo in ipairs(charData.dailyTodos) do
            local row = self:CreateTodoRow(parent, todo, "daily", i, characterKey, isCurrentCharacter)
            row:SetPoint("TOPLEFT", parent, "TOPLEFT", INDENT + 5, -yOffset)
            row:SetPoint("RIGHT", parent, "RIGHT", -10, 0)
            table.insert(self.uiElements, row)
            yOffset = yOffset + ROW_HEIGHT
        end
        
        yOffset = yOffset + 5
    end
    
    -- Weekly section
    if #charData.weeklyTodos > 0 then
        local weeklyLabel = parent:CreateFontString(nil, "OVERLAY", "GameFontNormal")
        weeklyLabel:SetPoint("TOPLEFT", parent, "TOPLEFT", INDENT, -yOffset)
        weeklyLabel:SetText("Weekly")
        weeklyLabel:SetTextColor(0.5, 0.8, 0.9)
        table.insert(self.uiElements, weeklyLabel)
        
        local weeklyProgress = parent:CreateFontString(nil, "OVERLAY", "GameFontNormal")
        weeklyProgress:SetPoint("TOPRIGHT", parent, "TOPRIGHT", -10, -yOffset)
        weeklyProgress:SetText(weeklyCompleted .. "/" .. weeklyTotal)
        weeklyProgress:SetTextColor(0.7, 0.7, 0.7)
        table.insert(self.uiElements, weeklyProgress)
        
        yOffset = yOffset + 18
        
        for i, todo in ipairs(charData.weeklyTodos) do
            local row = self:CreateTodoRow(parent, todo, "weekly", i, characterKey, isCurrentCharacter)
            row:SetPoint("TOPLEFT", parent, "TOPLEFT", INDENT + 5, -yOffset)
            row:SetPoint("RIGHT", parent, "RIGHT", -10, 0)
            table.insert(self.uiElements, row)
            yOffset = yOffset + ROW_HEIGHT
        end
    end
    
    yOffset = yOffset + 10
    
    return yOffset
end

function DWT:CreateMainFrame()
    if self.mainFrame then
        return self.mainFrame
    end
    
    -- Main frame with simple dark background
    local frame = CreateFrame("Frame", "DailyWeeklyTodoMainFrame", UIParent, "BackdropTemplate")
    frame:SetSize(FRAME_WIDTH, FRAME_HEIGHT)
    frame:SetPoint("CENTER", UIParent, "CENTER", 0, 0)
    frame:SetFrameStrata("HIGH")
    frame:SetClampedToScreen(true)
    frame:SetMovable(true)
    frame:EnableMouse(true)
    frame:RegisterForDrag("LeftButton")
    frame:SetScript("OnDragStart", frame.StartMoving)
    frame:SetScript("OnDragStop", frame.StopMovingOrSizing)
    frame:SetBackdrop({
        bgFile = "Interface\\DialogFrame\\UI-DialogBox-Background-Dark",
        edgeFile = "Interface\\DialogFrame\\UI-DialogBox-Border",
        tile = true,
        tileSize = 32,
        edgeSize = 32,
        insets = { left = 8, right = 8, top = 8, bottom = 8 }
    })
    frame:SetBackdropColor(0, 0, 0, 0.9)
    frame:Hide()
    
    -- Header bar
    local header = CreateFrame("Frame", nil, frame, "BackdropTemplate")
    header:SetHeight(HEADER_HEIGHT)
    header:SetPoint("TOPLEFT", frame, "TOPLEFT", 8, -8)
    header:SetPoint("TOPRIGHT", frame, "TOPRIGHT", -8, -8)
    header:SetBackdrop({
        bgFile = "Interface\\DialogFrame\\UI-DialogBox-Background",
        edgeFile = nil,
    })
    header:SetBackdropColor(0.1, 0.1, 0.1, 1)
    frame.header = header
    
    -- Title
    local title = header:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
    title:SetPoint("LEFT", header, "LEFT", 10, 0)
    title:SetText("Daily & Weekly Todos")
    title:SetTextColor(1, 0.82, 0)
    frame.title = title
    
    -- Close button
    local closeBtn = CreateFrame("Button", nil, header, "UIPanelCloseButton")
    closeBtn:SetPoint("RIGHT", header, "RIGHT", 0, 0)
    closeBtn:SetScript("OnClick", function()
        self:HideMainFrame()
    end)
    frame.closeBtn = closeBtn
    
    -- Scroll frame area
    local scrollParent = CreateFrame("Frame", nil, frame)
    scrollParent:SetPoint("TOPLEFT", header, "BOTTOMLEFT", 0, -5)
    scrollParent:SetPoint("BOTTOMRIGHT", frame, "BOTTOMRIGHT", -8, FOOTER_HEIGHT + 8)
    frame.scrollParent = scrollParent
    
    -- Scroll frame
    local scrollFrame = CreateFrame("ScrollFrame", nil, scrollParent, "UIPanelScrollFrameTemplate")
    scrollFrame:SetPoint("TOPLEFT", scrollParent, "TOPLEFT", 5, 0)
    scrollFrame:SetPoint("BOTTOMRIGHT", scrollParent, "BOTTOMRIGHT", -25, 0)
    frame.scrollFrame = scrollFrame
    
    -- Content frame
    local content = CreateFrame("Frame", nil, scrollFrame)
    content:SetWidth(FRAME_WIDTH - 60)
    content:SetHeight(1)
    scrollFrame:SetScrollChild(content)
    frame.content = content
    
    -- Footer bar with Add button
    local footer = CreateFrame("Frame", nil, frame, "BackdropTemplate")
    footer:SetHeight(FOOTER_HEIGHT)
    footer:SetPoint("BOTTOMLEFT", frame, "BOTTOMLEFT", 8, 8)
    footer:SetPoint("BOTTOMRIGHT", frame, "BOTTOMRIGHT", -8, 8)
    footer:SetBackdrop({
        bgFile = "Interface\\DialogFrame\\UI-DialogBox-Background",
    })
    footer:SetBackdropColor(0.1, 0.1, 0.1, 1)
    frame.footer = footer
    
    -- Add Task button
    local addBtn = CreateFrame("Button", nil, footer, "UIPanelButtonTemplate")
    addBtn:SetSize(100, 24)
    addBtn:SetPoint("CENTER", footer, "CENTER", 0, 0)
    addBtn:SetText("Add Task")
    addBtn:SetScript("OnClick", function()
        self:ShowAddTodoDialog()
    end)
    frame.addBtn = addBtn
    
    self.mainFrame = frame
    self.uiElements = {}
    self:RefreshUI()
    return frame
end

function DWT:ClearUIElements()
    if self.uiElements then
        for _, element in ipairs(self.uiElements) do
            if element.Hide then element:Hide() end
            if element.SetParent then element:SetParent(nil) end
        end
    end
    self.uiElements = {}
end

function DWT:RefreshUI()
    if not self.mainFrame then
        return
    end
    
    self:ClearUIElements()
    
    local content = self.mainFrame.content
    local yOffset = PADDING
    
    local characters = self:GetAllCharacters()
    
    -- Show message if no characters
    if #characters == 0 then
        local noCharsText = content:CreateFontString(nil, "OVERLAY", "GameFontNormal")
        noCharsText:SetPoint("TOPLEFT", content, "TOPLEFT", PADDING, -yOffset)
        noCharsText:SetText("No character data yet. Reload your UI.")
        noCharsText:SetTextColor(0.7, 0.7, 0.7)
        table.insert(self.uiElements, noCharsText)
        yOffset = yOffset + 30
    else
        for _, charInfo in ipairs(characters) do
            yOffset = self:CreateCharacterSection(content, charInfo.key, charInfo, yOffset)
        end
    end
    
    -- Check if any character has todos
    local hasTodos = false
    for _, charInfo in ipairs(characters) do
        local charData = self:GetCharacterData(charInfo.key)
        if charData and (#charData.dailyTodos > 0 or #charData.weeklyTodos > 0) then
            hasTodos = true
            break
        end
    end
    
    if not hasTodos and #characters > 0 then
        local noTodosText = content:CreateFontString(nil, "OVERLAY", "GameFontNormal")
        noTodosText:SetPoint("TOPLEFT", content, "TOPLEFT", PADDING, -yOffset)
        noTodosText:SetText("No tasks yet. Click 'Add Task' below!")
        noTodosText:SetTextColor(0.7, 0.7, 0.7)
        table.insert(self.uiElements, noTodosText)
        yOffset = yOffset + 30
    end
    
    content:SetHeight(math.max(yOffset + PADDING, 100))
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
    StaticPopupDialogs["DWT_ADD_TODO"] = {
        text = "Enter task text:",
        button1 = "Add Daily",
        button2 = "Add Weekly",
        button3 = "Cancel",
        hasEditBox = true,
        timeout = 0,
        whileDead = true,
        hideOnEscape = true,
        OnShow = function(self)
            self.editBox:SetFocus()
        end,
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
