local L = LibStub("AceLocale-3.0"):NewLocale("LagBar", "enUS")
if not L then return end

L["FPS"] = "FPS"
L["Ms"] = "ms"
L["Mem"] = "MEM"
L["In"] = "IN"
L["Out"] = "OUT"

L["FeatureHeader"] = "Features:"
L["RightClickToLock"] = "Right mouse click to lock/unlock window position."
L["ResetCommand"] = "• |cFF00FF00/lagbar reset|r - resets window position to the center of the screen;"
L["BgCommand"] = "• |cFF00FF00/lagbar bg|r - shows/hides the background of the window;"
L["ScaleCommand"] = "• |cFF00FF00/lagbar scale #|r - changes the scale of the LagBar frame (e.g. 0.5, 0.2, 1, 1.1, 1.5);"
L["HelpTitle"] = "LagBar"
L["MemoryCommand"] = "• |cFF00FF00/lagbar memory|r - toggles total add-on memory (and tooltip breakdown);"
L["NetCommand"] = "• |cFF00FF00/lagbar net|r - toggles network IN/OUT (download/upload) display;"
L["TopAddOnMemory"] = "Top add-ons by memory:"
L["TopAddOnCPU"] = "Top add-ons by CPU (script profiling):"
L["MemoryEnabled"] = "LagBar: Add-on memory line enabled."
L["MemoryDisabled"] = "LagBar: Add-on memory line disabled."
L["NetEnabled"] = "LagBar: Network IN/OUT enabled."
L["NetDisabled"] = "LagBar: Network IN/OUT disabled."