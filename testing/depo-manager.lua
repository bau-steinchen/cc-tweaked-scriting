local modem = peripheral.find("modem")
rednet.open(peripheral.getName(modem))

local mon = peripheral.find("monitor")
mon.setTextScale(1)
mon.setBackgroundColor(colors.black)
mon.clear()

-------------------------------------------------
-- Konfiguration
-------------------------------------------------

local DEPOTS = {
    depo1 =    { row = 2, textX = 22, leftX = 9,  rightX = 31, name = "Depot 1" },
    depo2 =    { row = 3, textX = 22, leftX = 9,  rightX = 31, name = "Depot 2" },
    depo3 =    { row = 4, textX = 22, leftX = 9,  rightX = 31, name = "Depot 3" },
    depo4 =    { row = 5, textX = 22, leftX = 9,  rightX = 31, name = "Depot 4" },
    depo5 =    { row = 6, textX = 22, leftX = 9,  rightX = 31, name = "Depot 5" },
    depo_tmp = { row = 9, textX = 14, leftX = 29, rightX = 11, name = "Depo tmp"},
}

-------------------------------------------------
-- Zeichnen
-------------------------------------------------

local function drawPlan()
    mon.setTextColor(colors.white)

    mon.setCursorPos(1,2)
    mon.write("     __[ ]__________<Depot 1>[ ]____     ")
    mon.setCursorPos(1,3)
    mon.write("    /__[ ]__________<Depot 2>[ ]____\\    ")
    mon.setCursorPos(1,4)
    mon.write("   /___[ ]__________<Depot 3>[ ]_____\\   ")
    mon.setCursorPos(1,5)
    mon.write("  /____[ ]__________<Depot 4>[ ]______\\  ")
    mon.setCursorPos(1,6)
    mon.write(" /_____[ ]__________<Depot 5>[ ]_______\\ ")
    mon.setCursorPos(1,7)
    mon.write(" |                                     | ")
    mon.setCursorPos(1,8)
    mon.write(" |                                     | ")
    mon.setCursorPos(1,9)
    mon.write(" \\_______[ ]<Demo tmp>_____[ ]_________/ ")
end

local function drawSignal(x, y, color)
    mon.setCursorPos(x, y)
    mon.setBackgroundColor(color)
    mon.write(" ")
    mon.setBackgroundColor(colors.black)
end

local function drawDepotText(x, y, name, isRed)
    mon.setCursorPos(x, y)
    mon.setTextColor(isRed and colors.red or colors.green)
    mon.write(name)
    mon.setTextColor(colors.white)
end

-------------------------------------------------
-- Startanzeige
-------------------------------------------------

drawPlan()

-------------------------------------------------
-- Hauptloop
-------------------------------------------------

while true do
    local id, message = rednet.receive()

    if type(message) == "table" then
        local depot = DEPOTS[message.type]

        if depot then
            local row = depot.row

            if message.side == "back" then
                drawDepotText(depot.textX, row, depot.name, message.signal)

            elseif message.side == "left" then
                drawSignal(depot.leftX, row,
                    message.signal and colors.red or colors.green)

            elseif message.side == "right" then
                drawSignal(depot.rightX, row,
                    message.signal and colors.red or colors.green)
            end
        end
    end
end