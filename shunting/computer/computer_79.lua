-- Coupler Node mit Redstone-Station-Inputs + command-Steuerung

local NODE_NAME = "computer_79"
local MODEM_SIDE = "back"

-- Redstone outputs for gates
local GATE1 = "top"
local GATE2 = "right"
local GATE3 = "bottom"
local GATE4 = "left"

local activePulseTimer = nil
local PULSE_DURATION = 1.0

local modem = peripheral.wrap(MODEM_SIDE)
if not modem then
    error("Kein Modem an " .. MODEM_SIDE)
end

rednet.open(MODEM_SIDE)


local function redraw(currentData)
    term.clear()
    term.setCursorPos(1, 1)
    print("=== COUPLER NODE ===")
    print("Node: " .. NODE_NAME) 
    print("waiting for Gate open/close")  
end

local function stopPulse()
    redstone.setAnalogOutput(GATE1, 0)
    redstone.setAnalogOutput(GATE2, 0)
    redstone.setAnalogOutput(GATE3, 0)
    redstone.setAnalogOutput(GATE4, 0)
    activePulseTimer = nil
end

local function handleMessage(senderId, message, protocol)
    if type(message) ~= "table" then return end

    if message.receiver and message.receiver ~= NODE_NAME then return end

    if message.gate == "GATE1" then
        redstone.setAnalogOutput(GATE1, 15)
        activePulseTimer = os.startTimer(PULSE_DURATION)
    elseif message.gate == "GATE2" then
        redstone.setAnalogOutput(GATE2, 15)
        activePulseTimer = os.startTimer(PULSE_DURATION)
    elseif message.gate == "GATE3" then
        redstone.setAnalogOutput(GATE3, 15)
        activePulseTimer = os.startTimer(PULSE_DURATION)
    elseif message.gate == "GATE4" then
        redstone.setAnalogOutput(GATE4, 15)
        activePulseTimer = os.startTimer(PULSE_DURATION)
    end
end

redraw()

while true do
    local event, p1, p2, p3 = os.pullEvent()

    if event == "rednet_message" then
        local senderId, message, protocol = p1, p2, p3
        handleMessage(senderId, message, protocol)

    elseif event == "timer" then
        if activePulseTimer and p1 == activePulseTimer then
            stopPulse()
        end
    end
end