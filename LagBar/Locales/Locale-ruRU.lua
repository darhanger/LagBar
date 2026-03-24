local L = LibStub("AceLocale-3.0"):NewLocale("LagBar", "ruRU")
if not L then return end

L["FPS"] = "Кадр/с"
L["Ms"] = "мс"
L["Mem"] = "ПАМ"
L["In"] = "ВХ"
L["Out"] = "ИСХ"

L["FeatureHeader"] = "Особенности:"
L["RightClickToLock"] = "Щелкните правой кнопкой мыши, чтобы заблокировать/разблокировать положение окна."
L["ResetCommand"] = "• |cFF00FF00/lagbar reset|r - сбросить положение окна в центр экрана;"
L["BgCommand"] = "• |cFF00FF00/lagbar bg|r - показать/скрыть фон окна;"
L["ScaleCommand"] = "• |cFF00FF00/lagbar scale #|r - изменить масштаб окна LagBar (напр. 0.5, 0.2, 1, 1.1, 1.5);"
L["HelpTitle"] = "LagBar"
L["MemoryCommand"] = "• |cFF00FF00/lagbar memory|r - вкл./выкл. память аддонов и список в подсказке;"
L["NetCommand"] = "• |cFF00FF00/lagbar net|r - вкл./выкл. отображение сети ВХ/ИСХ (скорость);"
L["TopAddOnMemory"] = "Аддоны по памяти:"
L["TopAddOnCPU"] = "Аддоны по CPU (script profiling):"
L["MemoryEnabled"] = "LagBar: строка памяти аддонов включена."
L["MemoryDisabled"] = "LagBar: строка памяти аддонов выключена."
L["NetEnabled"] = "LagBar: отображение ВХ/ИСХ включено."
L["NetDisabled"] = "LagBar: отображение ВХ/ИСХ выключено."