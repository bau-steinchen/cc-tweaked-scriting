-- Signal node with accepting broadcasts
local sender = "computer_20"

-- Helper function: compare tables
local function tablesEqual(t1, t2)
    if type(t1) ~= type(t2) then return false end
    if type(t1) ~= "table" then return t1 == t2 end
    local keys1, keys2 = {}, {}
    for k in pairs(t1) do keys1[k] = true end
    for k in pairs(t2) do keys2[k] = true end
    for k in pairs(keys1) do if not keys2[k] then return false end end
    for k in pairs(keys2) do if not keys1[k] then return false end end
    for k, v1 in pairs(t1) do
        local v2 = t2[k]
        if not tablesEqual(v1, v2) then return false end
    end
    return true
end

-- Signal
local signal = peripheral.wrap("top")

local modem = peripheral.wrap("bottom")
rednet.open(peripheral.getName(modem))

local lastData = {signal = {}}

local lastMessage = {sender="none"}

while true do
    -- REDNET CHECK (non-blocking, 0.6 Sec. Timeout)
    local id, message = rednet.receive(0.6)
    if message then
        if type(message) == "table" then
            if message.receiver == sender or message.receiver == "ALL" then
                lastMessage = message
                -- and event for this computer occured
                if message.signal == "RED" then
                    signal.setForcedRed(true)
                else 
                    signal.setForcedRed(false)
                end
            end
        end
    end

    -- SIGNAL CHECK (periodic)
    local currentData = {
        sender = sender,
        signal = {
            name = peripheral.getName(signal),
            state = signal.getState(),
            signalType = signal.getSignalType()
        }
    }
    
    -- check for any changes
    local changed = false
    for category, data in pairs(currentData) do
        if not tablesEqual(lastData[category], data) then
            changed = true
            break
        end
    end
    
    if changed then
        rednet.broadcast(textutils.serialize(currentData))
        lastData = currentData

        -- Optional: Terminal-Status
        term.clear()
        term.setCursorPos(1,1)
        print("=== MONITOR ===")
        print("Signal State: " .. tostring(currentData.signal.state))
        print("Rednet letzte Msg: " .. tostring(lastMessage.sender))
    end
    sleep(0.3)
end
