local addonName, addon = ...

-- Initialize addon namespace
DailyWeeklyTodo = LibStub("AceAddon-3.0"):NewAddon("DailyWeeklyTodo", "AceConsole-3.0", "AceEvent-3.0")
local DWT = DailyWeeklyTodo

-- Default settings
local defaults = {
    profile = {
        dailyTodos = {
            {text = "Complete 4 World Quests", completed = false, enabled = true},
            {text = "Do Emissary Quest", completed = false, enabled = true},
            {text = "Complete Dungeon", completed = false, enabled = true},
        },
        weeklyTodos = {
            {text = "Complete Weekly Mythic+ Quest", completed = false, enabled = true},
            {text = "Complete World Boss", completed = false, enabled = true},
            {text = "Do 5 Mythic+ Dungeons", completed = false, enabled = true},
        },
        lastDailyReset = 0,
        lastWeeklyReset = 0,
        windowPosition = {
            x = 100,
            y = 100,
        },
        showOnLogin = true,
        windowWidth = 300,
        windowHeight = 400,
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

function DWT:OnInitialize()
    -- Initialize database
    self.db = LibStub("AceDB-3.0"):New("DailyWeeklyTodoData", defaults, true)
    
    -- Register slash commands
    self:RegisterChatCommand("dwt", "SlashCommand")
    self:RegisterChatCommand("dailytodo", "SlashCommand")
    
    -- Register events
    self:RegisterEvent("PLAYER_LOGIN")
    self:RegisterEvent("ADDON_LOADED")
    
    print("|cff00ff00Daily Weekly Todo|r loaded. Type /dwt to open.")
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
    elseif command == "config" then
        print("|cff00ff00Daily Weekly Todo:|r Configuration options coming soon!")
    else
        print("|cff00ff00Daily Weekly Todo Commands:|r")
        print("/dwt show - Show the todo window")
        print("/dwt hide - Hide the todo window")
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
    
    -- Check daily reset (daily reset is at server midnight)
    local todayMidnight = serverTime - (serverTime % 86400)
    if self.db.profile.lastDailyReset < todayMidnight then
        self:ResetDailyTodos()
        self.db.profile.lastDailyReset = now
    end
    
    -- Check weekly reset (region-specific)
    local lastWeeklyReset = self:GetLastWeeklyResetTime()
    if self.db.profile.lastWeeklyReset < lastWeeklyReset then
        self:ResetWeeklyTodos()
        self.db.profile.lastWeeklyReset = now
        
        -- Debug info
        local region = self:GetServerRegion()
        print("|cff00ff00Daily Weekly Todo:|r Weekly reset detected for " .. region .. " region.")
    end
end

function DWT:ResetDailyTodos()
    for i, todo in ipairs(self.db.profile.dailyTodos) do
        if todo.enabled then
            todo.completed = false
        end
    end
    if self.mainFrame and self.mainFrame:IsShown() then
        self:RefreshUI()
    end
end

function DWT:ResetWeeklyTodos()
    for i, todo in ipairs(self.db.profile.weeklyTodos) do
        if todo.enabled then
            todo.completed = false
        end
    end
    if self.mainFrame and self.mainFrame:IsShown() then
        self:RefreshUI()
    end
end

function DWT:ResetTodos()
    self:ResetDailyTodos()
    self:ResetWeeklyTodos()
end

function DWT:AddDailyTodo(text)
    table.insert(self.db.profile.dailyTodos, {
        text = text,
        completed = false,
        enabled = true
    })
    if self.mainFrame and self.mainFrame:IsShown() then
        self:RefreshUI()
    end
end

function DWT:AddWeeklyTodo(text)
    table.insert(self.db.profile.weeklyTodos, {
        text = text,
        completed = false,
        enabled = true
    })
    if self.mainFrame and self.mainFrame:IsShown() then
        self:RefreshUI()
    end
end

function DWT:ToggleTodo(todoType, index)
    local todoList = todoType == "daily" and self.db.profile.dailyTodos or self.db.profile.weeklyTodos
    if todoList[index] then
        todoList[index].completed = not todoList[index].completed
        if self.mainFrame and self.mainFrame:IsShown() then
            self:RefreshUI()
        end
    end
end

-- Utility functions
function DWT:GetCompletedCount(todoType)
    local todoList = todoType == "daily" and self.db.profile.dailyTodos or self.db.profile.weeklyTodos
    local completed = 0
    local total = 0
    
    for _, todo in ipairs(todoList) do
        if todo.enabled then
            total = total + 1
            if todo.completed then
                completed = completed + 1
            end
        end
    end
    
    return completed, total
end