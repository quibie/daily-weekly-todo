local addonName, addon = ...
local DWT = DailyWeeklyTodo

-- UI Constants
local FRAME_WIDTH = 400
local FRAME_HEIGHT = 550
local CHECKBOX_SIZE = 18
local BUTTON_SIZE = 16
local ROW_HEIGHT = 24
local PADDING = 10
local INDENT = 25

-- Create a todo row with delete, reorder buttons, and checkbox
function DWT:CreateTodoRow(parent, todo, todoType, index, characterKey, isCurrentCharacter)
    local row = CreateFrame("Frame", nil, parent)
    row:SetSize(parent:GetWidth(), ROW_HEIGHT)
    
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
    -- Only enable delete for current character
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
    local text = row:CreateFontString(nil, "OVERLAY")
    text:SetFontObject("GameFontNormal")
    text:SetPoint("LEFT", row, "LEFT", xOffset, 0)
    text:SetPoint("RIGHT", row, "RIGHT", -5, 0)
    text:SetJustifyH("LEFT")
    text:SetText(todo.text)
    text:SetWordWrap(false)
    
    -- Update text appearance based on completion
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
    header:SetSize(parent:GetWidth(), 22)
    
    -- Collapse indicator
    local indicator = header:CreateFontString(nil, "OVERLAY")
    indicator:SetFontObject("GameFontNormal")
    indicator:SetPoint("LEFT", header, "LEFT", 0, 0)
    indicator:SetText(isCollapsed and "▶" or "▼")
    indicator:SetTextColor(0.8, 0.8, 0.8)
    header.indicator = indicator
    
    -- Title text
    local titleText = header:CreateFontString(nil, "OVERLAY")
    titleText:SetFontObject("GameFontNormalLarge")
    titleText:SetPoint("LEFT", indicator, "RIGHT", 5, 0)
    titleText:SetText(title)
    titleText:SetTextColor(colorR or 1, colorG or 1, colorB or 1)
    header.titleText = titleText
    
    -- Progress text
    if progress then
        local progressText = header:CreateFontString(nil, "OVERLAY")
        progressText:SetFontObject("GameFontNormal")
        progressText:SetPoint("RIGHT", header, "RIGHT", -5, 0)
        progressText:SetText(progress)
        progressText:SetTextColor(0.7, 0.7, 0.7)
        header.progressText = progressText
    end
    
    -- Click handler
    header:SetScript("OnClick", onToggle)
    header:SetHighlightTexture("Interface\\QuestFrame\\UI-QuestLogTitleHighlight", "ADD")
    
    return header
end

-- Create character section with collapsible daily/weekly todos
function DWT:CreateCharacterSection(parent, characterKey, charInfo, yOffset)
    local charData = self:GetCharacterData(characterKey)
    if not charData then return yOffset end
    
    local isCurrentCharacter = charInfo.isCurrentCharacter
    local isCollapsed = self:IsCharacterCollapsed(characterKey)
    local r, g, b = self:GetClassColor(charInfo.class)
    
    -- Character header
    local charName = charInfo.name
    if isCurrentCharacter then
        charName = charName .. " (Current)"
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
        local dailyLabel = parent:CreateFontString(nil, "OVERLAY")
        dailyLabel:SetFontObject("GameFontNormal")
        dailyLabel:SetPoint("TOPLEFT", parent, "TOPLEFT", INDENT, -yOffset)
        dailyLabel:SetText("Daily")
        dailyLabel:SetTextColor(0.9, 0.8, 0.5) -- Gold
        table.insert(self.uiElements, dailyLabel)
        
        local dailyProgress = parent:CreateFontString(nil, "OVERLAY")
        dailyProgress:SetFontObject("GameFontNormal")
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
        
        yOffset = yOffset + 5 -- Small gap between daily and weekly
    end
    
    -- Weekly section
    if #charData.weeklyTodos > 0 then
        local weeklyLabel = parent:CreateFontString(nil, "OVERLAY")
        weeklyLabel:SetFontObject("GameFontNormal")
        weeklyLabel:SetPoint("TOPLEFT", parent, "TOPLEFT", INDENT, -yOffset)
        weeklyLabel:SetText("Weekly")
        weeklyLabel:SetTextColor(0.5, 0.8, 0.9) -- Blue
        table.insert(self.uiElements, weeklyLabel)
        
        local weeklyProgress = parent:CreateFontString(nil, "OVERLAY")
        weeklyProgress:SetFontObject("GameFontNormal")
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
    
    -- Add separator if not last character
    yOffset = yOffset + 10
    
    return yOffset
end

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
    
    -- Close button
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
    content:SetSize(FRAME_WIDTH - 60, 1000)
    scrollFrame:SetScrollChild(content)
    frame.content = content
    
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
    
    -- Clear existing UI elements
    self:ClearUIElements()
    
    local content = self.mainFrame.content
    local yOffset = PADDING
    
    -- Get all characters
    local characters = self:GetAllCharacters()
    
    -- Create sections for each character
    for _, charInfo in ipairs(characters) do
        yOffset = self:CreateCharacterSection(content, charInfo.key, charInfo, yOffset)
    end
    
    -- If no characters have todos, show a message
    if yOffset <= PADDING + 10 then
        local noTodosText = content:CreateFontString(nil, "OVERLAY")
        noTodosText:SetFontObject("GameFontNormal")
        noTodosText:SetPoint("TOPLEFT", content, "TOPLEFT", PADDING, -yOffset)
        noTodosText:SetText("No todos yet. Use /dwt add to add tasks.")
        noTodosText:SetTextColor(0.7, 0.7, 0.7)
        table.insert(self.uiElements, noTodosText)
        yOffset = yOffset + 30
    end
    
    -- Update content height for scrolling
    content:SetHeight(math.max(yOffset + PADDING, FRAME_HEIGHT - 80))
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
