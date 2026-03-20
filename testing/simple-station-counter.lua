local station = peripheral.wrap("left")
if not station then
    error("No Train Station found!")
end

local monitor = peripheral.find("monitor")
if not monitor then
    error("No Monitor found!")
end

monitor.setTextScale(1.5)
monitor.clear()
monitor.setCursorPos(1, 1)

local function formatTime(seconds)
    local mins = math.floor(seconds / 60)
    local secs = seconds % 60
    return string.format("%02d:%02d", mins, secs)
end


local function getRemainingDelay()
    if not station.isTrainPresent() then
        return nil
    end
    if not station.hasSchedule() then
        return nil
    end
    local schedule = station.getSchedule()
    if schedule and schedule[1] and schedule[1].delay then
        return math.ceil(tonumber(schedule[1].delay) / 20)  -- seconds
    end
    return nil
end

-- main
while true do
    monitor.clear()
    local remaining = getRemainingDelay()
    
    if remaining then
        monitor.setCursorPos(1, 1)
        monitor.write("Abfahrt in:")
        monitor.setCursorPos(1, 3)
        monitor.write(formatTime(remaining))
    end
    
    sleep(1)  -- every second for ressource caring
end