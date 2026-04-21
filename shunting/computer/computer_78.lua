-- Coupler Node mit Redstone-Station-Inputs + command-Steuerung

local NODE_NAME = "computer_78"
local MODEM_SIDE = "top"


-- Inputs
local STATION = "right"

local POLL_INTERVAL = 0.5

local modem = peripheral.wrap(MODEM_SIDE)
if not modem then
    error("Kein Modem an " .. MODEM_SIDE)
end

rednet.open(MODEM_SIDE)
local lastData = {
    sender = NODE_NAME,
    empty = { cargo = false }
}


local pollTimer = nil

local function tablesEqual(t1, t2)
    if type(t1) ~= type(t2) then return false end
    if type(t1) ~= "table" then return t1 == t2 end

    local seen = {}
    for k, v in pairs(t1) do
        seen[k] = true
        if not tablesEqual(v, t2[k]) then
            return false
        end
    end

    for k in pairs(t2) do
        if not seen[k] then
            return false
        end
    end

    return true
end

local function dump(value, indent, seen)
    indent = indent or ""
    seen = seen or {}

    if type(value) ~= "table" then
        print(indent .. tostring(value))
        return
    end

    if seen[value] then
        print(indent .. "<cycle>")
        return
    end
    seen[value] = true

    print(indent .. "{")
    for k, v in pairs(value) do
        io.write(indent .. "  [" .. tostring(k) .. "] = ")
        if type(v) == "table" then
            print()
            dump(v, indent .. "  ", seen)
        else
            print(tostring(v))
        end
    end
    print(indent .. "}")
end

local function redraw(currentData)
    term.clear()
    term.setCursorPos(1, 1)
    print("=== COUPLER NODE ===")
    print("Node: " .. NODE_NAME)   
end


local function readRedstoneStations()
    local currentData = {
        sender = NODE_NAME,
        empty = {
            cargo = rs.getInput(STATION)
        }
    }

    if not tablesEqual(lastData, currentData) then
        rednet.broadcast(currentData)
        lastData = currentData
        redraw(currentData)
    end
end


pollTimer = os.startTimer(0.1)
redraw(lastData)

while true do
    local event, p1, p2, p3 = os.pullEvent()

    if event == "redstone" then
        readRedstoneStations()
        redraw(lastData)
    end
end