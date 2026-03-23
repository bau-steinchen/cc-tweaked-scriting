local modem = peripheral.wrap("bottom")
rednet.open(peripheral.getName(modem))

local mon = peripheral.wrap("top")
mon.setTextScale(1)
mon.setBackgroundColor(colors.black)
mon.clear()

-------------------------------------------------
-- Konfiguration
-------------------------------------------------

local DEPOTS = {
    checkpoint  = { row = 2, textX = 22, leftX = 9,  rightX = 31, name = "Depo" },
    depo1       = { row = 3, textX = 22, leftX = 9,  rightX = 31, name = "Depo" },
    depo2       = { row = 4, textX = 22, leftX = 9,  rightX = 31, name = "Depo" },
    depo3       = { row = 5, textX = 22, leftX = 9,  rightX = 31, name = "Depo" },
    depo4       = { row = 6, textX = 22, leftX = 9,  rightX = 31, name = "Depo" },
    depo5       = { row = 6, textX = 22, leftX = 9,  rightX = 31, name = "Depo" },
    depo6       = { row = 6, textX = 22, leftX = 9,  rightX = 31, name = "Depo" },
    depo7       = { row = 6, textX = 22, leftX = 9,  rightX = 31, name = "Depo" },
    depo8       = { row = 6, textX = 22, leftX = 9,  rightX = 31, name = "Depo" },
    depo9       = { row = 6, textX = 22, leftX = 9,  rightX = 31, name = "Depo" },
    depo10      = { row = 6, textX = 22, leftX = 9,  rightX = 31, name = "Depo" },
    depo11      = { row = 6, textX = 22, leftX = 9,  rightX = 31, name = "Depo" },
    entry1      = { row = 9, textX = 14, leftX = 29, rightX = 11, name = "Signal"},
    entry2      = { row = 9, textX = 14, leftX = 29, rightX = 11, name = "Signal"},
    entry3      = { row = 9, textX = 14, leftX = 29, rightX = 11, name = "Signal"},
    entry4      = { row = 9, textX = 14, leftX = 29, rightX = 11, name = "Signal"},
    entry5      = { row = 9, textX = 14, leftX = 29, rightX = 11, name = "Signal"},
    entry6      = { row = 9, textX = 14, leftX = 29, rightX = 11, name = "Signal"},
    entry7      = { row = 9, textX = 14, leftX = 29, rightX = 11, name = "Signal"},
    entry8      = { row = 9, textX = 14, leftX = 29, rightX = 11, name = "Signal"},
    entry9      = { row = 9, textX = 14, leftX = 29, rightX = 11, name = "Signal"},
    entry10     = { row = 9, textX = 14, leftX = 29, rightX = 11, name = "Signal"},
    entry11     = { row = 9, textX = 14, leftX = 29, rightX = 11, name = "Signal"},
    entry12     = { row = 9, textX = 14, leftX = 29, rightX = 11, name = "Signal"},
}

-------------------------------------------------
-- Zeichnen
-------------------------------------------------

local function drawPlan()
    mon.setTextColor(colors.white)

    mon.setCursorPos(1,2) 
    mon.write("       ___[ ]_____________________________________<Depo>[ ]________________[ ]____ ---> Base     ")
    mon.setCursorPos(1,3)
    mon.write("      /___[ ]_____________________________________<Depo>[ ]____\\/    ")
    mon.setCursorPos(1,4)
    mon.write("      |/__[ ]_____________________________________<Depo>[ ]____\\|   ")
    mon.setCursorPos(1,5)
    mon.write("      |/__[ ]_____________________________________<Depo>[ ]____\\|   ")
    mon.setCursorPos(1,6)
    mon.write("      |/__[ ]_____________________________________<Depo>[ ]____\\|   ")
    mon.setCursorPos(1,7)
    mon.write("      |/__[ ]_____________________________________<Depo>[ ]____\\|   ")
    mon.setCursorPos(1,8)
    mon.write("      |/__[ ]_____________________________________<Depo>[ ]____\\|   ")
    mon.setCursorPos(1,9)
    mon.write("      |/__[ ]_____________________________________<Depo>[ ]____\\|   ")
    mon.setCursorPos(1,10)
    mon.write("      |/__[ ]_____________________________________<Depo>[ ]____\\|   ")
    mon.setCursorPos(1,11)
    mon.write("      |/__[ ]_____________________________________<Depo>[ ]____\\|   ")
    mon.setCursorPos(1,12)
    mon.write("      |/__[ ]_____________________________________<Depo>[ ]____\\|   ")
    mon.setCursorPos(1,13)
    mon.write("      |/__[ ]_______________________________<Checkpoint>[ ]____\\|   ")
    mon.setCursorPos(1,14)
    mon.write("      |                                                         | ")
    mon.setCursorPos(1,15)
    mon.write("      |                                                         | ")
    mon.setCursorPos(1,16)
    mon.write("     [ ]                                                       [ ]  ")
    mon.setCursorPos(1,17)
    mon.write("      |                                            ________[ ]__|____[ ]___________________ <--- Base ")
    mon.setCursorPos(1,17)
    mon.write("      |                                           /             |                                      ")
    mon.setCursorPos(1,17)
    mon.write(" _____|\\___[ ]__________________________________       ___[ ]___\\__[ ]___________________ ---> Base ")
    mon.setCursorPos(1,17)
    mon.write("      |                                                /          ")
    mon.setCursorPos(1,18)
    mon.write(" _[ ]_/_______________________________________________       | ")




    
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