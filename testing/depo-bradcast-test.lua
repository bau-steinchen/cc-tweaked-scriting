local modem = peripheral.wrap("top")
rednet.open(peripheral.getName(modem))

rednet.broadcast({
    sender = "manager",
    sender = "ALL",
    signal = "GREEN",
})