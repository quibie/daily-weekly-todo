local addonName, addon = ...

-- Initialize addon namespace
DailyWeeklyTodo = LibStub("AceAddon-3.0"):NewAddon("DailyWeeklyTodo", "AceConsole-3.0", "AceEvent-3.0")
local DWT = DailyWeeklyTodo

-- Default settings
local defaults = {
    global = {
        characters = {}, -- Store all character data
        collapsedCharacters = {}, -- Track which character sections are collapsed
    },
    profile = {
        dailyTodos = {},
        weeklyTodos = {},
        lastDailyReset = 0,
        lastWeeklyReset = 0,
        windowPosition = {
            x = 100,
            y = 100,
        },
        showOnLogin = true,
        windowWidth = 350,
        windowHeight = 500,
    }
}

-- Server region weekly reset times (in UTC)
local WEEKLY_RESET_TIMES = {
    ["US"] = {day = 3, hour = 15}, -- Tuesday 15:00 UTC (10am EST)
    ["EU"] = {day = 3, hour = 7},  -- Wednesday 07:00 UTC (8am CET)
    ["KR"] = {day = 3, hour = 23}, -- Wednesday 23:00 UTC (8am KST)
    ["TW"] = {day = 3, hour = 23}, -- Wednesday 23:00 UTC (8am CST)
    ["CN"] = {day = 3, hour = 23}, -- Wednesday 23:00 UTC (8am CST)
}

function DWT:GetCurrentCharacterKey()
    local name = UnitName("player")
    local realm = GetRealmName()
    return name .. "-" .. realm
end

function DWT:OnInitialize()
    -- Initialize database
    self.db = LibStub("AceDB-3.0"):New("DailyWeeklyTodoData", defaults, true)
    
    -- Store character key
    self.characterKey = self:GetCurrentCharacterKey()
    
    -- Initialize character data in global storage if not exists
    if not self.db.global.characters[self.characterKey] then
        self.db.global.characters[self.characterKey] = {
            name = UnitName("player"),
            realm = GetRealmName(),
            class = select(2, UnitClass("player")),
            dailyTodos = {},
            weeklyTodos = {},
            lastDailyReset = 0,
            lastWeeklyReset = 0,
        }
    end
    
    -- Register slash commands
    self:RegisterChatCommand("dwt", "SlashCommand")
    self:RegisterChatCommand("dailytodo", "SlashCommand")
    
    -- Register events
    self:RegisterEvent("PLAYER_LOGIN")
    self:RegisterEvent("ADDON_LOADED")
    
    print("|cff00ff00Daily Weekly Todo|r loaded. Type /dwt to open.")
end

function DWT:GetCharacterData(characterKey)
    characterKey = characterKey or self.characterKey
    return self.db.global.characters[characterKey]
end

function DWT:GetCurrentCharacterData()
    return self:GetCharacterData(self.characterKey)
end

function DWT:OnEnable()
    -- Check for daily/weekly resets
    self:CheckResets()
end

function DWT:PLAYER_LOGIN()
    if self.db.profile.showOnLogin then
        C_Timer.After(2, function()
            self:ShowMainFrame()
        end)
    end
end

function DWT:ADDON_LOADED(event, loadedAddonName)
    if loadedAddonName == addonName then
        self:CheckResets()
    end
end

function DWT:SlashCommand(input)
    local command = string.lower(input or "")
    
    if command == "show" or command == "" then
        self:ShowMainFrame()
    elseif command == "hide" then
        self:HideMainFrame()
    elseif command == "reset" then
        self:ResetTodos()
        print("|cff00ff00Daily Weekly Todo:|r All todos reset!")
    elseif command == "add" then
        self:ShowAddTodoDialog()
    elseif command == "config" then
        print("|cff00ff00Daily Weekly Todo:|r Configuration options coming soon!")
    else
        print("|cff00ff00Daily Weekly Todo Commands:|r")
        print("/dwt show - Show the todo window")
        print("/dwt hide - Hide the todo window")
        print("/dwt add - Add a new todo")
        print("/dwt reset - Reset all todos")
        print("/dwt config - Open configuration")
    end
end

function DWT:GetServerRegion()
    -- Detect server region based on realm list or portal
    local realmName = GetNormalizedRealmName()
    if not realmName then
        return "US" -- Default fallback
    end
    
    -- Use GetCVar to check region
    local portal = GetCVar("portal")
    if portal then
        if portal == "EU" then
            return "EU"
        elseif portal == "KR" then
            return "KR"
        elseif portal == "TW" then
            return "TW"
        elseif portal == "CN" then
            return "CN"
        else
            return "US"
        end
    end
    
    -- Fallback: try to determine by checking some EU-specific realms
    local euRealms = {
        ["Khadgar"] = true, ["Stormrage"] = true, ["Silvermoon"] = true,
        ["Draenor"] = true, ["Tarren Mill"] = true, ["Outland"] = true,
        ["Twisting Nether"] = true, ["Ravencrest"] = true, ["Defias Brotherhood"] = true
    }
    
    if euRealms[realmName] then
        return "EU"
    end
    
    return "US" -- Default to US if uncertain
end

function DWT:GetLastWeeklyResetTime()
    local region = self:GetServerRegion()
    local resetInfo = WEEKLY_RESET_TIMES[region] or WEEKLY_RESET_TIMES["US"]
    
    local currentTime = time()
    local currentDate = date("*t", currentTime)
    
    -- Find the most recent weekly reset time
    local daysToSubtract = 0
    local currentWeekday = currentDate.wday -- 1=Sunday, 2=Monday, ..., 7=Saturday
    
    if currentWeekday == 1 then -- Sunday
        currentWeekday = 7 -- Treat Sunday as day 7 for easier calculation
    else
        currentWeekday = currentWeekday - 1 -- Shift so Monday=1, Tuesday=2, etc.
    end
    
    -- Calculate days since last reset
    if currentWeekday >= resetInfo.day then
        daysToSubtract = currentWeekday - resetInfo.day
    else
        daysToSubtract = (currentWeekday + 7) - resetInfo.day
    end
    
    -- Calculate the exact reset time
    local resetTime = currentTime - (daysToSubtract * 86400) -- Go back to reset day
    local resetDate = date("*t", resetTime)
    
    -- Set to the exact reset hour and clear minutes/seconds
    resetDate.hour = resetInfo.hour
    resetDate.min = 0
    resetDate.sec = 0
    
    local exactResetTime = time(resetDate)
    
    -- If we're before this week's reset, go back one more week
    if exactResetTime > currentTime then
        exactResetTime = exactResetTime - (7 * 86400)
    end
    
    return exactResetTime
end

function DWT:CheckResets()
    local now = time()
    local serverTime = C_DateAndTime.GetServerTimeLocal()
    local charData = self:GetCurrentCharacterData()
    
    -- Check daily reset (daily reset is at server midnight)
    local todayMidnight = serverTime - (serverTime % 86400)
    if charData.lastDailyReset < todayMidnight then
        self:ResetDailyTodos()
        charData.lastDailyReset = now
    end
    
    -- Check weekly reset (region-specific)
    local lastWeeklyReset = self:GetLastWeeklyResetTime()
    if charData.lastWeeklyReset < lastWeeklyReset then
        self:ResetWeeklyTodos()
        charData.lastWeeklyReset = now
        
        -- Debug info
        local region = self:GetServerRegion()
        print("|cff00ff00Daily Weekly Todo:|r Weekly reset detected for " .. region .. " region.")
    end
end

function DWT:ResetDailyTodos(characterKey)
    local charData = self:GetCharacterData(characterKey)
    if not charData then return end
    
    for i, todo in ipairs(charData.dailyTodos) do
        todo.completed = false
    end
    if self.mainFrame and self.mainFrame:IsShown() then
        self:RefreshUI()
    end
end

function DWT:ResetWeeklyTodos(characterKey)
    local charData = self:GetCharacterData(characterKey)
    if not charData then return end
    
    for i, todo in ipairs(charData.weeklyTodos) do
        todo.completed = false
    end
    if self.mainFrame and self.mainFrame:IsShown() then
        self:RefreshUI()
    end
end

function DWT:ResetTodos(characterKey)
    self:ResetDailyTodos(characterKey)
    self:ResetWeeklyTodos(characterKey)
end

function DWT:AddDailyTodo(text, characterKey)
    local charData = self:GetCharacterData(characterKey)
    if not charData then return end
    
    table.insert(charData.dailyTodos, {
        text = text,
        completed = false,
    })
    if self.mainFrame and self.mainFrame:IsShown() then
        self:RefreshUI()
    end
end

function DWT:AddWeeklyTodo(text, characterKey)
    local charData = self:GetCharacterData(characterKey)
    if not charData then return end
    
    table.insert(charData.weeklyTodos, {
        text = text,
        completed = false,
    })
    if self.mainFrame and self.mainFrame:IsShown() then
        self:RefreshUI()
    end
end

function DWT:DeleteTodo(todoType, index, characterKey)
    local charData = self:GetCharacterData(characterKey)
    if not charData then return end
    
    local todoList = todoType == "daily" and charData.dailyTodos or charData.weeklyTodos
    if todoList[index] then
        table.remove(todoList, index)
        if self.mainFrame and self.mainFrame:IsShown() then
            self:RefreshUI()
        end
    end
end

function DWT:MoveTodoUp(todoType, index, characterKey)
    local charData = self:GetCharacterData(characterKey)
    if not charData then return end
    
    local todoList = todoType == "daily" and charData.dailyTodos or charData.weeklyTodos
    if index > 1 and todoList[index] then
        todoList[index], todoList[index - 1] = todoList[index - 1], todoList[index]
        if self.mainFrame and self.mainFrame:IsShown() then
            self:RefreshUI()
        end
    end
end

function DWT:MoveTodoDown(todoType, index, characterKey)
    local charData = self:GetCharacterData(characterKey)
    if not charData then return end
    
    local todoList = todoType == "daily" and charData.dailyTodos or charData.weeklyTodos
    if index < #todoList and todoList[index] then
        todoList[index], todoList[index + 1] = todoList[index + 1], todoList[index]
        if self.mainFrame and self.mainFrame:IsShown() then
            self:RefreshUI()
        end
    end
end

function DWT:ToggleTodo(todoType, index, characterKey)
    local charData = self:GetCharacterData(characterKey)
    if not charData then return end
    
    local todoList = todoType == "daily" and charData.dailyTodos or charData.weeklyTodos
    if todoList[index] then
        todoList[index].completed = not todoList[index].completed
        if self.mainFrame and self.mainFrame:IsShown() then
            self:RefreshUI()
        end
    end
end

function DWT:ToggleCharacterCollapsed(characterKey)
    if self.db.global.collapsedCharacters[characterKey] then
        self.db.global.collapsedCharacters[characterKey] = nil
    else
        self.db.global.collapsedCharacters[characterKey] = true
    end
    if self.mainFrame and self.mainFrame:IsShown() then
        self:RefreshUI()
    end
end

function DWT:IsCharacterCollapsed(characterKey)
    return self.db.global.collapsedCharacters[characterKey] == true
end

-- Get all characters
function DWT:GetAllCharacters()
    local characters = {}
    for key, data in pairs(self.db.global.characters) do
        table.insert(characters, {
            key = key,
            name = data.name,
            realm = data.realm,
            class = data.class,
            isCurrentCharacter = (key == self.characterKey)
        })
    end
    -- Sort: current character first, then alphabetically
    table.sort(characters, function(a, b)
        if a.isCurrentCharacter then return true end
        if b.isCurrentCharacter then return false end
        return a.key < b.key
    end)
    return characters
end

-- Utility functions
function DWT:GetCompletedCount(todoType, characterKey)
    local charData = self:GetCharacterData(characterKey)
    if not charData then return 0, 0 end
    
    local todoList = todoType == "daily" and charData.dailyTodos or charData.weeklyTodos
    local completed = 0
    local total = 0
    
    for _, todo in ipairs(todoList) do
        total = total + 1
        if todo.completed then
            completed = completed + 1
        end
    end
    
    return completed, total
end

-- Get class color
function DWT:GetClassColor(class)
    if class and RAID_CLASS_COLORS[class] then
        local color = RAID_CLASS_COLORS[class]
        return color.r, color.g, color.b
    end
    return 1, 1, 1
end
