-- local functions
local function set_output(power)
    redstone.setAnalogOutput("back", power)
    sleep(1)
    redstone.setAnalogOutput("back", 0)
end

local function inputs()
    -- pins { W2, L, S*, W1, D1, D2, D3, input }
    -- index{ 1,  2, 3,  4,  5,  6,  7,  8 }
    local pins = {0, 0, 0, 0, 0, 0, 0, 0}
    local left = redstone.getAnalogueInput("left") -- 2 statisch zum testen
    local right = redstone.getAnalogueInput("right") -- 8 statisch zum testen
    
    -- Left: Bit 0-3 (LSB)
    for i = 1, 4 do
        pins[i] = bit.band(left, 2^(i-1)) > 0 and 1 or 0
    end
    
    -- Right: Bit 4-7 (oder separat 0-3)
    for i = 5, 8 do
        pins[i] = bit.band(right, 2^(i-5)) > 0 and 1 or 0
    end
    
    return pins
end

local function clear_monitor(mon)
    mon.clear()
    mon.setCursorPos(1,1)
    mon.setTextScale(1)
    mon.setTextColor(32)
end

local mon = peripheral.wrap("top")
if mon then
    clear_monitor(mon)
    mon.write("Monitor connected")
end


-- global functions
-- section 0 - idle waiting for new train
function waiting()
    -- pins { W2, L, S*, W1, D1, D2, D3, input }
    -- index{ 1,  2, 3,  4,  5,  6,  7,  8 }
    mon.write("Idle: awaiting new shunting order")

    -- waiting for new train
    mon.setCursorPos(1,2)
    while inputs()[8] == 0 do
        mon.setCursorPos(1,2)
        mon.write(string.rep(" ", 50))  -- Alte Zeile löschen (50 Zeichen)
        mon.setCursorPos(1,2)
        mon.write(table.concat(inputs(), " "))  -- Neu schreiben
        sleep(5)
    end
    -- New train arrived at input

    mon.setCursorPos(1,3)
    mon.write("New train arrived - starting schedule.")

    -- power station to input
    set_output(10)
    sleep(5)
end

-- section 1 - move input train to handover
function input_cargowaggon()
    -- pins { W2, L, S*, W1, D1, D2, D3, input }
    -- index{ 1,  2, 3,  4,  5,  6,  7,  8 }
    mon.write("Waiting for Cargo!")

    -- waiting until trains is at station
    mon.setCursorPos(1,2)
    while inputs()[3] == 0 do
        mon.setCursorPos(1,2)
        mon.write(string.rep(" ", 50))  -- Alte Zeile löschen (50 Zeichen)
        mon.setCursorPos(1,2)
        mon.write(table.concat(inputs(), " "))  -- Neu schreiben
        mon.setCursorPos(1,5)
        mon.write(" need xx1xxxxx;" .. inputs()[3])
        sleep(5)
    end
    sleep(5)
    -- train arrived at cargo changer

    mon.setCursorPos(1,3)
    mon.write("Decoupling...  ")

    set_output(4)

    sleep(1)

    mon.setCursorPos(1,4)
    mon.write("Sending Loco to wait position")

    set_output(7)
end

-- section 2
function get_cargowaggon()
    -- pins { W2, L, S*, W1, D1, D2, D3, input }
    -- index{ 1,  2, 3,  4,  5,  6,  7,  8 }
    mon.write("Waiting for loco to park")

    while inputs()[4] == 0 do
        mon.setCursorPos(1,2)
        mon.write(string.rep(" ", 50))  -- Alte Zeile löschen (50 Zeichen)
        mon.setCursorPos(1,2)
        mon.write(table.concat(inputs(), " "))  -- Neu schreiben
        mon.setCursorPos(1,5)
        mon.write(" need xxx1xxxx;" .. inputs()[4])
        sleep(5)
    end
    -- loco arrived at waiting spot

    mon.setCursorPos(1,2)
    mon.write("Sending shunting loco...  ")

    set_output(6)

    mon.write("Done")
    sleep(2)
end

-- section 3
function move_full()
    -- pins { W2, L, S*, W1, D1, D2, D3, input }
    -- index{ 1,  2, 3,  4,  5,  6,  7,  8 }
    mon.write("Waiting for loco arival")

    while inputs()[3] == 0 do
        mon.setCursorPos(1,2)
        mon.write(string.rep(" ", 50))  -- Alte Zeile löschen (50 Zeichen)
        mon.setCursorPos(1,2)
        mon.write(table.concat(inputs(), " "))  -- Neu schreiben
        mon.setCursorPos(1,5)
        mon.write(" need xx1xxxxx;" .. inputs()[3])
        sleep(5)
    end
    sleep(5)
    -- loco arrived at cargo changer

    mon.setCursorPos(1,3)
    mon.write("Decoupling...  ")

    set_output(4)

    mon.write("Done")
    sleep(2)

    set_output(7)
end

-- section 4, 6
function handle_cargowaggon()
    -- pins { W2, L, S*, W1, D1, D2, D3, input }
    -- index{ 1,  2, 3,  4,  5,  6,  7,  8 }
    mon.write("Drop Cargowaggon")

    local waggons = 3

    for i = 1,waggons do
        while ( inputs()[5] == 0 and inputs()[6] == 0 and inputs()[7] == 0 ) do
            sleep(5)
        end
        -- loco arrived at cargo changer

        mon.setCursorPos(1,3)
        mon.write("Decoupling...  ")
        set_output(1) -- Coupler D1
        set_output(2) -- Coupler D2
        set_output(3) -- Coupler D3

        mon.write("Done")
        sleep(2)

        set_output(5) -- S

        sleep(5)
    end
end

-- section 5
function wait_for_empty()
    -- pins { W2, L, S*, W1, D1, D2, D3, input }
    -- index{ 1,  2, 3,  4,  5,  6,  7,  8 }
    mon.write("Waiting for Empty")

    while redstone.getAnalogueInput("bottom") == 0 do
        sleep(5)
    end
    mon.setCursorPos(1,3)
    mon.write("Waiting until empty Cargo...  ")

    sleep(5)

    set_output(9) -- W2

    sleep(2)

end

-- section 7
function output_cargowaggon()
    -- pins { W2, L, S*, W1, D1, D2, D3, input }
    -- index{ 1,  2, 3,  4,  5,  6,  7,  8 }
    mon.write("Waiting for loco arival")

    while inputs()[3] == 0 do
        mon.setCursorPos(1,2)
        mon.write(string.rep(" ", 50))  -- Alte Zeile löschen (50 Zeichen)
        mon.setCursorPos(1,2)
        mon.write(table.concat(inputs(), " "))  -- Neu schreiben
        mon.setCursorPos(1,5)
        mon.write(" need xx1xxxxx;" .. inputs()[3])
        sleep(5)
    end
    sleep(5)
    -- loco arrived at cargo changer

    mon.setCursorPos(1,3)
    mon.write("Decoupling...  ")

    set_output(4)

    mon.write("Done")
    sleep(2)

    set_output(7)
end

-- section 8
function park_loco()
    -- pins { W2, L, S*, W1, D1, D2, D3, input }
    -- index{ 1,  2, 3,  4,  5,  6,  7,  8 }
    mon.write("Waiting for loco parking")

    while inputs()[2] == 0 do
        mon.setCursorPos(1,2)
        mon.write(string.rep(" ", 50))  -- Alte Zeile löschen (50 Zeichen)
        mon.setCursorPos(1,2)
        mon.write(table.concat(inputs(), " "))  -- Neu schreiben
        mon.setCursorPos(1,5)
        mon.write(" need x1xxxxxx;" .. inputs()[2])
        sleep(5)
    end
    -- loco arrived at depot

    mon.write("Done")
    sleep(2)

    set_output(8)
end

-- section 8
function send_train()
    -- pins { W2, L, S*, W1, D1, D2, D3, input }
    -- index{ 1,  2, 3,  4,  5,  6,  7,  8 }
    mon.write("Waiting for loco arrival")

    while inputs()[3] == 0 do
        mon.setCursorPos(1,2)
        mon.write(string.rep(" ", 50))  -- Alte Zeile löschen (50 Zeichen)
        mon.setCursorPos(1,2)
        mon.write(table.concat(inputs(), " "))  -- Neu schreiben
        mon.setCursorPos(1,5)
        mon.write(" need x1xxxxxx;" .. inputs()[3])
        sleep(5)
    end
    sleep(5)
    -- loco arrived at depot

    mon.setCursorPos(1,3)
    mon.write("Coupling...  ")

    set_output(4)

    sleep(1)

    set_output(7)
end

-- script part
local schedule = 0 

-- Switch-Tabelle
local schedule_section = {
  [0] = waiting,
  [1] = input_cargowaggon,
  [2] = get_cargowaggon,
  [3] = move_full,
  [4] = handle_cargowaggon,
  [5] = wait_for_empty,
  [6] = handle_cargowaggon,
  [7] = output_cargowaggon,
  [8] = park_loco,
  [9] = send_train,
  ["default"] = function() print("Unbekannt: Schedule") end
}
local schedule_action = schedule_section[schedule]


-- working routine
while true do
    -- pins { W2, L, S*, W1, D1, D2, D3, input }
    -- index{ 1,  2, 3,  4,  5,  6,  7,  8 }
    clear_monitor(mon) -- clear monitor for ervery schedule change

    schedule_action = schedule_section[schedule]
    schedule_action()

    -- handle next schedule
    schedule = schedule + 1
    if schedule > 9 then
        schedule = 0
    end

    -- while true do
    --     mon.setCursorPos(1,1)
    --     mon.write(string.rep(" ", 50))  -- Alte Zeile löschen (50 Zeichen)
    --     mon.setCursorPos(1,1)
    --     mon.write(table.concat(inputs(), " ")) 
    --     mon.setCursorPos(1,2)
    --     mon.write("left: " .. redstone.getAnalogueInput("left") .. " right: " .. redstone.getAnalogueInput("right"))
    --     sleep(5)
    -- end
end

