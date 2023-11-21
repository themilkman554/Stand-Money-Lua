--[[
	abuazizv for the orginal rebound lua
    ayim for transaction hash finder and 'better code'
	decuwu for the money counter
	gamecrunch 
	big smoke
--]]

util.require_natives(1663599433)
--shameless skidded from MB
local function SetGlobalInt(address, value)
    memory.write_int(memory.script_global(address), value)
end

local function GetGlobalInt(global)
            return memory.read_int(memory.script_global(global))
        end
        function STAT_GET_INT(stat)
            local IntPTR = memory.alloc_int()
            STATS.STAT_GET_INT(util.joaat(ADD_MP_INDEX(stat)), IntPTR, -1)
            return memory.read_int(IntPTR)
        end
if not SCRIPT_SILENT_START then
    util.toast("WARNING: All features in this script are considered risky! There is a chance you will get banned within an unknown number of days (bans are delayed randomly). You have been warned.")
end

local global = 4536533
local currentMoney = MONEY.NETWORK_GET_VC_WALLET_BALANCE(util.get_char_slot())
local moneyEarned = 0
local moneyEarnedPerMinute = 0
local startTime = 0
local yield = util.yield
local debug = util.draw_debug_text
local wait = false
local overlay, displayTime, displayEarned, displayEarnedPerHour, displayEarnedPerMin, displayEarnedPerSec = false, false, false, false, false, false

local function startTimer()
    startTime = os.time()
end

local function stopTimer()
    startTime = 0
end

local function getElapsedSeconds()
    if startTime ~= 0 then
        return os.time() - startTime
    else
        return 0
    end
end

local function addCommas(number)
    local numberString = tostring(number)
    local decimalIndex = string.find(numberString, "%.")
    if decimalIndex then
        numberString = string.sub(numberString, 1, decimalIndex - 1)
    end
    local reversedString = string.reverse(numberString)
    local formattedString = string.gsub(reversedString, "(%d%d%d)", "%1,")
    formattedString = string.reverse(formattedString)
    if string.sub(formattedString, 1, 1) == "," then
        formattedString = string.sub(formattedString, 2)
    end
    return formattedString
end

local function checkEarned(amount)
    if overlay then
        if MONEY.NETWORK_GET_VC_WALLET_BALANCE(util.get_char_slot()) > 2147483640 then
            util.toast("Attempting to transfer all money to bank")
            wait = true
            local wallet = MONEY.NETWORK_GET_VC_WALLET_BALANCE(util.get_char_slot())
            repeat
                wallet = MONEY.NETWORK_GET_VC_WALLET_BALANCE(util.get_char_slot())
                NETSHOPPING.NET_GAMESERVER_TRANSFER_WALLET_TO_BANK(util.get_char_slot(), wallet)
                yield()
            until wallet == 0
            wait = false
            util.toast("Continuing loop")
        end

        if MONEY.NETWORK_GET_VC_WALLET_BALANCE(util.get_char_slot()) - currentMoney == amount then
            moneyEarned = moneyEarned + amount
        end
        currentMoney = MONEY.NETWORK_GET_VC_WALLET_BALANCE(util.get_char_slot()	)
    end
end 

local function amountPerSecond(moneyEarned)
    if overlay then
        moneyEarnedPerMinute = moneyEarned / getElapsedSeconds()
    end
    if moneyEarnedPerMinute >= 0 then
        return moneyEarnedPerMinute
    else
        return 0
    end
end

local function draw_stats()
    if overlay then

        if displayTime then
            debug("Seconds Elapsed:" .. getElapsedSeconds())
        end

        if displayEarned then
            debug("Money Earned: $" .. addCommas(moneyEarned))
        end

        if displayEarnedPerHour then
            debug("Money/Hour: $" .. addCommas(amountPerSecond(moneyEarned) * 3600))
        end

        if displayEarnedPerMin then
            debug("Money/Minute: $" .. addCommas(amountPerSecond(moneyEarned) * 60))
        end

        if displayEarnedPerSec then
            debug("Money/Second: $" .. addCommas(amountPerSecond(moneyEarned)))
        end

    end
    return "HANDLER_CONTINUE"
end

local function trigger_transaction(hash, amount)
    SetGlobalInt(global + 1, 2147483646)
    SetGlobalInt(global + 7, 2147483647)
    SetGlobalInt(global + 6, 0)
    SetGlobalInt(global + 5, 0)
    SetGlobalInt(global + 3, hash)
    SetGlobalInt(global + 2, amount)
    SetGlobalInt(global,2)
	checkEarned(amount)
end
	
local my_root = menu.my_root()
local limited = my_root:list("limited Transactions", {}, "")
local loopSettings = my_root:list("Loop Settings", {}, "")

loopSettings:toggle("Enable Overlay", {}, "", function(on) 
    overlay = on
end)

loopSettings:toggle("Display Elapsed Time", {}, "", function(on) 
    displayTime = on
end)

loopSettings:toggle("Display Total Earned", {}, "", function(on) 
    displayEarned = on
end)

loopSettings:toggle("Display Earned Per Hour", {}, "", function(on) 
    displayEarnedPerHour = on
end)

loopSettings:toggle("Display Earned Per Minute", {},  "", function(on) 
    displayEarnedPerMin = on
end)

loopSettings:toggle("Display Earned Per Second", {}, "", function(on) 
    displayEarnedPerSec = on
end)

loopSettings:colour("Choose Color", {}, "Choose a color for the text", 1.0, 1.0, 1.0, 1.0, true, function(newColor)
    currentColor = newColor
end)

util.create_thread(function()
    while true do
	    draw_stats()
	    yield(0)
    end
end)

local state = { on = false }

local function startLoop()
    state.on = true
    while state.on do
        if wait then
            repeat
                coroutine.yield()
            until not wait
        end

        trigger_transaction(0x615762F1, 1000000)
        coroutine.yield()
    end
end

local function stopLoop()
    state.on = false
end

my_root:toggle("1M Loop [BEST]", {}, "", function(on)
    if on then
        startTimer()
        startLoop()
    else
        moneyEarned = 0
        stopTimer()
        stopLoop()
    end
end)

my_root:toggle_loop("50K Loop", {}, "", function()
    trigger_transaction(0x610F9AB4, 50000)
	yield()
end)

my_root:toggle_loop("40m Loop [SLOW]", {}, "", function()
    trigger_transaction(0x176D9D54, 15000000)
	yield(3000)
	trigger_transaction(0xED97AFC1, 7000000)
	yield(3000)
	trigger_transaction(0xA174F633, 15000000)
	yield(3000)
	trigger_transaction(0x314FB8B0, 1000000)
	yield(3000)
	trigger_transaction(0x4B6A869C, 2000000)
	yield(40000)
end)

my_root:toggle_loop("5K Chip Loop", {}, "", function()
    SetGlobalInt(1971266, 1)
	yield(3000)
end)

--from heist control
my_root:toggle_loop("Block Transaction Errors", {}, "", function()
    if not util.is_session_started() then return end
    if GetGlobalInt(4536683) == 4 or 20 then
        SetGlobalInt(4536677, 0)
    end
end)
--credit to jesus is cap

Opti = my_root:toggle("Optimised Settings", {""}, "Will hopefully Maximise your TPS and FPS", function()
	if menu.get_value(Opti) then
	menu.trigger_commands("potatomode on")
	menu.trigger_commands("nosky on")
	menu.trigger_commands("lodscale 0")
	menu.trigger_commands("fovfponfoot 0")
	menu.trigger_commands("fovtponfoot 0")
	yield(100) GRAPHICS.TOGGLE_PAUSED_RENDERPHASES(on)
	end
	if not menu.get_value(Opti) then
	menu.trigger_commands("potatomode off")
	menu.trigger_commands("nosky off")
	menu.trigger_commands("lodscale 1")
	menu.trigger_commands("fovfponfoot -5")
	menu.trigger_commands("fovtponfoot -5")
	GRAPHICS.TOGGLE_PAUSED_RENDERPHASES(not on)
	end
end)
		
local Options = {
{name = "15m JOB_BONUS", hash = util.joaat("SERVICE_EARN_JOB_BONUS"), amount = 15000000},
{name = "15m BEND_JOB", hash = util.joaat("SERVICE_EARN_BEND_JOB"), amount = 15000000},
{name = "15m GANGOPS_AWARD_MASTERMIND_4", hash = util.joaat("SERVICE_EARN_GANGOPS_AWARD_MASTERMIND_4"), amount = 15000000},        
{name = "15m JOB_BONUS_CRIMINAL_MASTERMIND", hash = util.joaat("SERVICE_EARN_JOB_BONUS_CRIMINAL_MASTERMIND"), amount = 15000000},  
{name = "7m GANGOPS_AWARD_MASTERMIND_3", hash = util.joaat("SERVICE_EARN_GANGOPS_AWARD_MASTERMIND_3"), amount = 7000000},
{name = "3.6m CASINO_HEIST_FINALE", hash = util.joaat("SERVICE_EARN_CASINO_HEIST_FINALE"), amount = 3619000},
{name = "3m AGENCY_STORY_FINALE", hash = util.joaat("SERVICE_EARN_AGENCY_STORY_FINALE"), amount = 3000000},
{name = "3m GANGOPS_AWARD_MASTERMIND_2", hash = util.joaat("SERVICE_EARN_GANGOPS_AWARD_MASTERMIND_2"), amount = 3000000},
{name = "2.5m ISLAND_HEIST_FINALE", hash = util.joaat("SERVICE_EARN_ISLAND_HEIST_FINALE"), amount = 2550000},
{name = "2.5m GANGOPS_FINALE", hash = util.joaat("SERVICE_EARN_GANGOPS_FINALE"), amount = 2550000},
{name = "2m JOB_BONUS_HEIST_AWARD", hash = util.joaat("SERVICE_EARN_JOB_BONUS_HEIST_AWARD"), amount = 2000000},
{name = "2m TUNER_ROBBERY_FINALE", hash = util.joaat("SERVICE_EARN_TUNER_ROBBERY_FINALE"), amount = 2000000},
{name = "2m GANGOPS_AWARD_ORDER", hash = util.joaat("SERVICE_EARN_GANGOPS_AWARD_ORDER"), amount = 2000000},
{name = "2m FROM_BUSINESS_HUB_SELL", hash = util.joaat("SERVICE_EARN_FROM_BUSINESS_HUB_SELL"), amount = 2000000},
{name = "1.5m GANGOPS_AWARD_LOYALTY_AWARD_4", hash = util.joaat("SERVICE_EARN_GANGOPS_AWARD_LOYALTY_AWARD_4"), amount = 1500000},  
{name = "1.2m BOSS_AGENCY", hash = util.joaat("SERVICE_EARN_BOSS_AGENCY"), amount = 1200000},
{name = "1m DAILY_OBJECTIVES", hash = util.joaat("SERVICE_EARN_DAILY_OBJECTIVES"), amount = 1000000},
{name = "1m MUSIC_STUDIO_SHORT_TRIP", hash = util.joaat("SERVICE_EARN_MUSIC_STUDIO_SHORT_TRIP"), amount = 1000000},
{name = "1m DAILY_OBJECTIVE_EVENT", hash = util.joaat("SERVICE_EARN_DAILY_OBJECTIVE_EVENT"), amount = 1000000},
{name = "1m JUGGALO_STORY_MISSION", hash = util.joaat("SERVICE_EARN_JUGGALO_STORY_MISSION"), amount = 1000000},
{name = "700k GANGOPS_AWARD_LOYALTY_AWARD_3", hash = util.joaat("SERVICE_EARN_GANGOPS_AWARD_LOYALTY_AWARD_3"), amount = 700000},   
{name = "680k BETTING", hash = util.joaat("SERVICE_EARN_BETTING"), amount = 680000},
{name = "620k FROM_VEHICLE_EXPORT", hash = util.joaat("SERVICE_EARN_FROM_VEHICLE_EXPORT"), amount = 620000},
{name = "500k ISLAND_HEIST_AWARD_MIXING_IT_UP", hash = util.joaat("SERVICE_EARN_ISLAND_HEIST_AWARD_MIXING_IT_UP"), amount = 500000},
{name = "500k WINTER_22_AWARD_JUGGALO_STORY", hash = util.joaat("SERVICE_EARN_WINTER_22_AWARD_JUGGALO_STORY"), amount = 500000},
{name = "500k CASINO_AWARD_STRAIGHT_FLUSH", hash = util.joaat("SERVICE_EARN_CASINO_AWARD_STRAIGHT_FLUSH"), amount = 500000},
{name = "400k ISLAND_HEIST_AWARD_PROFESSIONAL", hash = util.joaat("SERVICE_EARN_ISLAND_HEIST_AWARD_PROFESSIONAL"), amount = 400000},
{name = "400k ISLAND_HEIST_AWARD_CAT_BURGLAR", hash = util.joaat("SERVICE_EARN_ISLAND_HEIST_AWARD_CAT_BURGLAR"), amount = 400000},
{name = "400k ISLAND_HEIST_AWARD_ELITE_THIEF", hash = util.joaat("SERVICE_EARN_ISLAND_HEIST_AWARD_ELITE_THIEF"), amount = 400000},
{name = "400k ISLAND_HEIST_AWARD_THE_ISLAND_HEIST", hash = util.joaat("SERVICE_EARN_ISLAND_HEIST_AWARD_THE_ISLAND_HEIST"), amount = 400000},
{name = "350k CASINO_HEIST_AWARD_ELITE_THIEF", hash = util.joaat("SERVICE_EARN_CASINO_HEIST_AWARD_ELITE_THIEF"), amount = 350000},
{name = "300k AMBIENT_JOB_BLAST", hash = util.joaat("SERVICE_EARN_AMBIENT_JOB_BLAST"), amount = 300000},
{name = "300k PREMIUM_JOB", hash = util.joaat("SERVICE_EARN_PREMIUM_JOB"), amount = 300000},
{name = "300k GANGOPS_AWARD_LOYALTY_AWARD_2", hash = util.joaat("SERVICE_EARN_GANGOPS_AWARD_LOYALTY_AWARD_2"), amount = 300000},
{name = "300k CASINO_HEIST_AWARD_ALL_ROUNDER", hash = util.joaat("SERVICE_EARN_CASINO_HEIST_AWARD_ALL_ROUNDER"), amount = 300000},
{name = "300k ISLAND_HEIST_AWARD_PRO_THIEF", hash = util.joaat("SERVICE_EARN_ISLAND_HEIST_AWARD_PRO_THIEF"), amount = 300000},
{name = "300k YOHAN_SOURCE_GOODS", hash = util.joaat("SERVICE_EARN_YOHAN_SOURCE_GOODS"), amount = 300000},
{name = "270k SMUGGLER_AGENCY", hash = util.joaat("SERVICE_EARN_SMUGGLER_AGENCY"), amount = 270000},
{name = "250k FIXER_AWARD_AGENCY_STORY", hash = util.joaat("SERVICE_EARN_FIXER_AWARD_AGENCY_STORY"), amount = 250000},
{name = "250k CASINO_HEIST_AWARD_PROFESSIONAL", hash = util.joaat("SERVICE_EARN_CASINO_HEIST_AWARD_PROFESSIONAL"), amount = 250000},
{name = "200k GANGOPS_AWARD_SUPPORTING", hash = util.joaat("SERVICE_EARN_GANGOPS_AWARD_SUPPORTING"), amount = 200000},
{name = "200k COLLECTABLES_ACTION_FIGURES", hash = util.joaat("SERVICE_EARN_COLLECTABLES_ACTION_FIGURES"), amount = 200000},
{name = "200k ISLAND_HEIST_AWARD_GOING_ALONE", hash = util.joaat("SERVICE_EARN_ISLAND_HEIST_AWARD_GOING_ALONE"), amount = 200000},
{name = "200k JOB_BONUS_FIRST_TIME_BONUS", hash = util.joaat("SERVICE_EARN_JOB_BONUS_FIRST_TIME_BONUS"), amount = 200000},
{name = "200k GANGOPS_AWARD_FIRST_TIME_XM_SILO", hash = util.joaat("SERVICE_EARN_GANGOPS_AWARD_FIRST_TIME_XM_SILO"), amount = 200000},
{name = "200k DOOMSDAY_FINALE_BONUS", hash = util.joaat("SERVICE_EARN_DOOMSDAY_FINALE_BONUS"), amount = 200000},
{name = "200k GANGOPS_AWARD_FIRST_TIME_XM_BASE", hash = util.joaat("SERVICE_EARN_GANGOPS_AWARD_FIRST_TIME_XM_BASE"), amount = 200000},
{name = "200k COLLECTABLE_COMPLETED_COLLECTION", hash = util.joaat("SERVICE_EARN_COLLECTABLE_COMPLETED_COLLECTION"), amount = 200000},
{name = "200k ISLAND_HEIST_ELITE_CHALLENGE", hash = util.joaat("SERVICE_EARN_ISLAND_HEIST_ELITE_CHALLENGE"), amount = 200000},
{name = "200k AMBIENT_JOB_CHECKPOINT_COLLECTION", hash = util.joaat("SERVICE_EARN_AMBIENT_JOB_CHECKPOINT_COLLECTION"), amount = 200000},
{name = "200k GANGOPS_AWARD_FIRST_TIME_XM_SUBMARINE", hash = util.joaat("SERVICE_EARN_GANGOPS_AWARD_FIRST_TIME_XM_SUBMARINE"), amount = 200000},
{name = "200k ISLAND_HEIST_AWARD_TEAM_WORK", hash = util.joaat("SERVICE_EARN_ISLAND_HEIST_AWARD_TEAM_WORK"), amount = 200000},
{name = "200k CASINO_HEIST_ELITE_DIRECT", hash = util.joaat("SERVICE_EARN_CASINO_HEIST_ELITE_DIRECT"), amount = 200000},
{name = "200k CASINO_HEIST_ELITE_STEALTH", hash = util.joaat("SERVICE_EARN_CASINO_HEIST_ELITE_STEALTH"), amount = 200000},
{name = "200k AMBIENT_JOB_TIME_TRIAL", hash = util.joaat("SERVICE_EARN_AMBIENT_JOB_TIME_TRIAL"), amount = 200000},
{name = "200k CASINO_HEIST_AWARD_UNDETECTED", hash = util.joaat("SERVICE_EARN_CASINO_HEIST_AWARD_UNDETECTED"), amount = 200000},
{name = "200k CASINO_HEIST_ELITE_SUBTERFUGE", hash = util.joaat("SERVICE_EARN_CASINO_HEIST_ELITE_SUBTERFUGE"), amount = 200000},
{name = "200k GANGOPS_ELITE_XM_SILO", hash = util.joaat("SERVICE_EARN_GANGOPS_ELITE_XM_SILO"), amount = 200000},
{name = "190k VEHICLE_SALES", hash = util.joaat("SERVICE_EARN_VEHICLE_SALES"), amount = 190000},
{name = "180k JOBS", hash = util.joaat("SERVICE_EARN_JOBS"), amount = 180000},
{name = "165k AMBIENT_JOB_RC_TIME_TRIAL", hash = util.joaat("SERVICE_EARN_AMBIENT_JOB_RC_TIME_TRIAL"), amount = 165000},
{name = "150k AMBIENT_JOB_BEAST", hash = util.joaat("SERVICE_EARN_AMBIENT_JOB_BEAST"), amount = 150000},
{name = "150k CASINO_HEIST_AWARD_IN_PLAIN_SIGHT", hash = util.joaat("SERVICE_EARN_CASINO_HEIST_AWARD_IN_PLAIN_SIGHT"), amount = 150000},
{name = "150k AMBIENT_JOB_SOURCE_RESEARCH", hash = util.joaat("SERVICE_EARN_AMBIENT_JOB_SOURCE_RESEARCH"), amount = 150000},
{name = "150k GANGOPS_ELITE_XM_SUBMARINE", hash = util.joaat("SERVICE_EARN_GANGOPS_ELITE_XM_SUBMARINE"), amount = 150000},
{name = "120k AMBIENT_JOB_KING", hash = util.joaat("SERVICE_EARN_AMBIENT_JOB_KING"), amount = 120000},
{name = "120k AMBIENT_JOB_PENNED_IN", hash = util.joaat("SERVICE_EARN_AMBIENT_JOB_PENNED_IN"), amount = 120000},
{name = "115k SIGHTSEEING_REWARD", hash = util.joaat("SERVICE_EARN_SIGHTSEEING_REWARD"), amount = 115000},
{name = "100k CASINO_AWARD_HIGH_ROLLER_PLATINUM", hash = util.joaat("SERVICE_EARN_CASINO_AWARD_HIGH_ROLLER_PLATINUM"), amount = 100000},
{name = "100k TUNER_AWARD_BOLINGBROKE_ASS", hash = util.joaat("SERVICE_EARN_TUNER_AWARD_BOLINGBROKE_ASS"), amount = 100000},
{name = "100k CASINO_AWARD_FULL_HOUSE", hash = util.joaat("SERVICE_EARN_CASINO_AWARD_FULL_HOUSE"), amount = 100000},
{name = "100k AGENCY_SECURITY_CONTRACT", hash = util.joaat("SERVICE_EARN_AGENCY_SECURITY_CONTRACT"), amount = 100000},
{name = "100k DAILY_STASH_HOUSE_COMPLETED", hash = util.joaat("SERVICE_EARN_DAILY_STASH_HOUSE_COMPLETED"), amount = 100000},
{name = "100k CASINO_AWARD_MISSION_SIX_FIRST_TIME", hash = util.joaat("SERVICE_EARN_CASINO_AWARD_MISSION_SIX_FIRST_TIME"), amount = 100000},
{name = "100k AMBIENT_JOB_CHALLENGES", hash = util.joaat("SERVICE_EARN_AMBIENT_JOB_CHALLENGES"), amount = 100000},
{name = "100k AMBIENT_JOB_METAL_DETECTOR", hash = util.joaat("SERVICE_EARN_AMBIENT_JOB_METAL_DETECTOR"), amount = 100000},
{name = "100k AMBIENT_JOB_HOT_PROPERTY", hash = util.joaat("SERVICE_EARN_AMBIENT_JOB_HOT_PROPERTY"), amount = 100000},
{name = "100k AMBIENT_JOB_CLUBHOUSE_CONTRACT", hash = util.joaat("SERVICE_EARN_AMBIENT_JOB_CLUBHOUSE_CONTRACT"), amount = 100000},
{name = "100k TUNER_AWARD_FLEECA_BANK", hash = util.joaat("SERVICE_EARN_TUNER_AWARD_FLEECA_BANK"), amount = 100000},
{name = "100k AMBIENT_JOB_SMUGGLER_PLANE", hash = util.joaat("SERVICE_EARN_AMBIENT_JOB_SMUGGLER_PLANE"), amount = 100000},
{name = "100k FIXER_AWARD_SHORT_TRIP", hash = util.joaat("SERVICE_EARN_FIXER_AWARD_SHORT_TRIP"), amount = 100000},
{name = "100k AMBIENT_JOB_SMUGGLER_TRAIL", hash = util.joaat("SERVICE_EARN_AMBIENT_JOB_SMUGGLER_TRAIL"), amount = 100000},
{name = "100k TUNER_AWARD_METH_JOB", hash = util.joaat("SERVICE_EARN_TUNER_AWARD_METH_JOB"), amount = 100000},
{name = "100k CASINO_HEIST_AWARD_SMASH_N_GRAB", hash = util.joaat("SERVICE_EARN_CASINO_HEIST_AWARD_SMASH_N_GRAB"), amount = 100000},
{name = "100k AGENCY_STORY_PREP", hash = util.joaat("SERVICE_EARN_AGENCY_STORY_PREP"), amount = 100000},
{name = "100k WINTER_22_AWARD_DAILY_STASH", hash = util.joaat("SERVICE_EARN_WINTER_22_AWARD_DAILY_STASH"), amount = 100000},
{name = "100k JUGGALO_PHONE_MISSION", hash = util.joaat("SERVICE_EARN_JUGGALO_PHONE_MISSION"), amount = 100000},
{name = "100k AMBIENT_JOB_GOLDEN_GUN", hash = util.joaat("SERVICE_EARN_AMBIENT_JOB_GOLDEN_GUN"), amount = 100000},
{name = "100k AMBIENT_JOB_URBAN_WARFARE", hash = util.joaat("SERVICE_EARN_AMBIENT_JOB_URBAN_WARFARE"), amount = 100000},
{name = "100k AGENCY_PAYPHONE_HIT", hash = util.joaat("SERVICE_EARN_AGENCY_PAYPHONE_HIT"), amount = 100000},
{name = "100k TUNER_AWARD_FREIGHT_TRAIN", hash = util.joaat("SERVICE_EARN_TUNER_AWARD_FREIGHT_TRAIN"), amount = 100000},
{name = "100k WINTER_22_AWARD_DEAD_DROP", hash = util.joaat("SERVICE_EARN_WINTER_22_AWARD_DEAD_DROP"), amount = 100000},
{name = "100k CLUBHOUSE_DUFFLE_BAG", hash = util.joaat("SERVICE_EARN_CLUBHOUSE_DUFFLE_BAG"), amount = 100000},
{name = "100k WINTER_22_AWARD_RANDOM_EVENT", hash = util.joaat("SERVICE_EARN_WINTER_22_AWARD_RANDOM_EVENT"), amount = 100000},
{name = "100k TUNER_AWARD_MILITARY_CONVOY", hash = util.joaat("SERVICE_EARN_TUNER_AWARD_MILITARY_CONVOY"), amount = 100000},
{name = "100k JUGGALO_STORY_MISSION_PARTICIPATION", hash = util.joaat("SERVICE_EARN_JUGGALO_STORY_MISSION_PARTICIPATION"), amount = 100000},
{name = "100k AMBIENT_JOB_CRIME_SCENE", hash = util.joaat("SERVICE_EARN_AMBIENT_JOB_CRIME_SCENE"), amount = 100000},
{name = "100k TUNER_AWARD_IAA_RAID", hash = util.joaat("SERVICE_EARN_TUNER_AWARD_IAA_RAID"), amount = 100000},
{name = "100k ARENA_CAREER_TIER_PROGRESSION_4", hash = util.joaat("SERVICE_EARN_ARENA_CAREER_TIER_PROGRESSION_4"), amount = 100000},
{name = "100k AUTO_SHOP_DELIVERY_AWARD", hash = util.joaat("SERVICE_EARN_AUTO_SHOP_DELIVERY_AWARD"), amount = 100000},
{name = "100k CASINO_AWARD_TOP_PAIR", hash = util.joaat("SERVICE_EARN_CASINO_AWARD_TOP_PAIR"), amount = 100000},
{name = "100k TUNER_AWARD_UNION_DEPOSITORY", hash = util.joaat("SERVICE_EARN_TUNER_AWARD_UNION_DEPOSITORY"), amount = 100000},
{name = "100k AMBIENT_JOB_UNDERWATER_CARGO", hash = util.joaat("SERVICE_EARN_AMBIENT_JOB_UNDERWATER_CARGO"), amount = 100000},
{name = "100k COLLECTABLE_ITEM", hash = util.joaat("SERVICE_EARN_COLLECTABLE_ITEM"), amount = 100000},
{name = "100k WINTER_22_AWARD_ACID_LAB", hash = util.joaat("SERVICE_EARN_WINTER_22_AWARD_ACID_LAB"), amount = 100000},
{name = "100k AMBIENT_JOB_MAZE_BANK", hash = util.joaat("SERVICE_EARN_AMBIENT_JOB_MAZE_BANK"), amount = 100000},
{name = "100k GANGOPS_ELITE_XM_BASE", hash = util.joaat("SERVICE_EARN_GANGOPS_ELITE_XM_BASE"), amount = 100000},
{name = "100k WINTER_22_AWARD_TAXI", hash = util.joaat("SERVICE_EARN_WINTER_22_AWARD_TAXI"), amount = 100000},
{name = "100k TUNER_DAILY_VEHICLE_BONUS", hash = util.joaat("SERVICE_EARN_TUNER_DAILY_VEHICLE_BONUS"), amount = 100000},
{name = "100k TUNER_AWARD_BUNKER_RAID", hash = util.joaat("SERVICE_EARN_TUNER_AWARD_BUNKER_RAID"), amount = 100000},
{name = "100k AMBIENT_JOB_AMMUNATION_DELIVERY", hash = util.joaat("SERVICE_EARN_AMBIENT_JOB_AMMUNATION_DELIVERY"), amount = 100000},
{name = "90k GANGOPS_SETUP", hash = util.joaat("SERVICE_EARN_GANGOPS_SETUP"), amount = 90000},
{name = "80k AMBIENT_JOB_DEAD_DROP", hash = util.joaat("SERVICE_EARN_AMBIENT_JOB_DEAD_DROP"), amount = 80000},
{name = "80k AMBIENT_JOB_HOT_TARGET_DELIVER", hash = util.joaat("SERVICE_EARN_AMBIENT_JOB_HOT_TARGET_DELIVER"), amount = 80000},
{name = "75k ARENA_CAREER_TIER_PROGRESSION_3", hash = util.joaat("SERVICE_EARN_ARENA_CAREER_TIER_PROGRESSION_3"), amount = 75000},
{name = "70k AMBIENT_JOB_XMAS_MUGGER", hash = util.joaat("SERVICE_EARN_AMBIENT_JOB_XMAS_MUGGER"), amount = 70000},
{name = "65k IMPORT_EXPORT", hash = util.joaat("SERVICE_EARN_IMPORT_EXPORT"), amount = 65000},
{name = "60k FROM_CLUB_MANAGEMENT_PARTICIPATION", hash = util.joaat("SERVICE_EARN_FROM_CLUB_MANAGEMENT_PARTICIPATION"), amount = 60000},
{name = "60k NIGHTCLUB_DANCING_AWARD", hash = util.joaat("SERVICE_EARN_NIGHTCLUB_DANCING_AWARD"), amount = 60000},
{name = "55k ARENA_CAREER_TIER_PROGRESSION_2", hash = util.joaat("SERVICE_EARN_ARENA_CAREER_TIER_PROGRESSION_2"), amount = 55000},
{name = "50k FROM_BUSINESS_BATTLE", hash = util.joaat("SERVICE_EARN_FROM_BUSINESS_BATTLE"), amount = 50000},
{name = "50k ISLAND_HEIST_DJ_MISSION", hash = util.joaat("SERVICE_EARN_ISLAND_HEIST_DJ_MISSION"), amount = 50000},
{name = "50k ARENA_SKILL_LVL_AWARD", hash = util.joaat("SERVICE_EARN_ARENA_SKILL_LVL_AWARD"), amount = 50000},
{name = "50k AMBIENT_JOB_GANG_CONVOY", hash = util.joaat("SERVICE_EARN_AMBIENT_JOB_GANG_CONVOY"), amount = 50000},
{name = "50k COLLECTABLES_SIGNAL_JAMMERS_COMPLETE", hash = util.joaat("SERVICE_EARN_COLLECTABLES_SIGNAL_JAMMERS_COMPLETE"), amount = 50000},
{name = "50k AMBIENT_JOB_HELI_HOT_TARGET", hash = util.joaat("SERVICE_EARN_AMBIENT_JOB_HELI_HOT_TARGET"), amount = 50000},
{name = "50k ACID_LAB_SELL_PARTICIPATION", hash = util.joaat("SERVICE_EARN_ACID_LAB_SELL_PARTICIPATION"), amount = 50000},
{name = "50k FROM_CONTRABAND", hash = util.joaat("SERVICE_EARN_FROM_CONTRABAND"), amount = 50000},
{name = "50k CASINO_AWARD_HIGH_ROLLER_GOLD", hash = util.joaat("SERVICE_EARN_CASINO_AWARD_HIGH_ROLLER_GOLD"), amount = 50000},
{name = "50k CASINO_AWARD_MISSION_THREE_FIRST_TIME", hash = util.joaat("SERVICE_EARN_CASINO_AWARD_MISSION_THREE_FIRST_TIME"), amount = 50000},
{name = "50k GOON", hash = util.joaat("SERVICE_EARN_GOON"), amount = 50000},
{name = "50k FIXER_AWARD_PHONE_HIT", hash = util.joaat("SERVICE_EARN_FIXER_AWARD_PHONE_HIT"), amount = 50000},
{name = "50k CASINO_AWARD_MISSION_FOUR_FIRST_TIME", hash = util.joaat("SERVICE_EARN_CASINO_AWARD_MISSION_FOUR_FIRST_TIME"), amount = 50000},
{name = "50k TAXI_JOB", hash = util.joaat("SERVICE_EARN_TAXI_JOB"), amount = 50000},
{name = "50k CASINO_AWARD_MISSION_ONE_FIRST_TIME", hash = util.joaat("SERVICE_EARN_CASINO_AWARD_MISSION_ONE_FIRST_TIME"), amount = 50000},
{name = "50k AMBIENT_JOB_SHOP_ROBBERY", hash = util.joaat("SERVICE_EARN_AMBIENT_JOB_SHOP_ROBBERY"), amount = 50000},
{name = "50k ARENA_WAR", hash = util.joaat("SERVICE_EARN_ARENA_WAR"), amount = 50000},
{name = "50k CASINO_AWARD_MISSION_FIVE_FIRST_TIME", hash = util.joaat("SERVICE_EARN_CASINO_AWARD_MISSION_FIVE_FIRST_TIME"), amount = 50000},
{name = "50k CASINO_AWARD_LUCKY_LUCKY", hash = util.joaat("SERVICE_EARN_CASINO_AWARD_LUCKY_LUCKY"), amount = 50000},
{name = "50k AMBIENT_JOB_PASS_PARCEL", hash = util.joaat("SERVICE_EARN_AMBIENT_JOB_PASS_PARCEL"), amount = 50000},
{name = "50k TUNER_CAR_CLUB_MEMBERSHIP", hash = util.joaat("SERVICE_EARN_TUNER_CAR_CLUB_MEMBERSHIP"), amount = 50000},
{name = "50k CASINO_AWARD_MISSION_TWO_FIRST_TIME", hash = util.joaat("SERVICE_EARN_CASINO_AWARD_MISSION_TWO_FIRST_TIME"), amount = 50000},
{name = "50k AMBIENT_JOB_HOT_TARGET_KILL", hash = util.joaat("SERVICE_EARN_AMBIENT_JOB_HOT_TARGET_KILL"), amount = 50000}
}

for i, v in ipairs(Options) do
    limited:action(v.name, {}, "", function()
        trigger_transaction(v.hash, v.amount)
    end)
end
