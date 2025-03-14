--LagBar by Derkyle (edited by DarhangeR)

local flagElvUI = select(4, GetAddOnInfo("ElvUI")) == 1 or false;
local r, g, b, a, dynamicEdgeSize, dynamicInsets = 1, 1, 1, 1, 12, 3;
local dynamicEdges = "Interface/DialogFrame/UI-DialogBox-Border";
if flagElvUI then
	dynamicEdges = "Interface/Buttons/WHITE8X8";
	r, g, b, a, dynamicEdgeSize, dynamicInsets = .0,.0,.0,.75, 2, 2;
end;

LagBar = {};
LagBar.version = GetAddOnMetadata("LagBar", "Version");
LagBar.PL_Lock = false;
LagBar.LOW_LATENCY = 300;
LagBar.MEDIUM_LATENCY = 600;
LagBar.MAX_INTERVAL = 1;
LagBar.UPDATE_INTERVAL = 0;
local L = LibStub("AceLocale-3.0"):GetLocale("LagBar");
function LagBar:Enable()
	if not LagBar_DB then
		LagBar_DB = {};
		LagBar_DB.x = 0;
		LagBar_DB.y = 0;
		LagBar_DB.locked = false;
		LagBar_DB.bgShown = true;
		LagBar_DB.scale = 1;
	end;

	if LagBar_DB.scale == nil then
		LagBar_DB.scale = 1;
	end;

	SLASH_LAGBAR1 = "/lagbar";
	SlashCmdList["LAGBAR"] = LagBar_SlashCommand;

	LagBar:DrawGUI();
	LagBar:MoveFrame();
end;

function LagBar:OnEvent(event, arg1, arg2, arg3, arg4, ...)
	if event == "ADDON_LOADED" and arg1 == "LagBar" then
		LagBar:Enable();
	end
end;

function LagBar_SlashCommand(cmd)
	local a,b,c = strfind(cmd, "(%S+)"); --contiguous string of non-space characters	
	if a and a ~= "" then
		if c and c:lower() == "reset" then
			DEFAULT_CHAT_FRAME:AddMessage("LagBar: Frame position has been reset!");
			LagBarFrame:SetPoint("CENTER", UIParent, "CENTER", 0, 0);			
			return nil;
		elseif c and c:lower() == "bg" then
			LagBar:BackgroundToggle();
			return nil;		
		elseif c and c:lower() == "worldping" then
			LagBar:WorldPingToggle();
			return nil;		
		elseif c and c:lower() == "impdisplay" then
			LagBar:ImpDisplayToggle();
			return nil;	
		elseif c and c:lower() == "scale" then
			if b then
				local scalenum = strsub(cmd, b+2)
				if scalenum and scalenum ~= "" and tonumber(scalenum) then
					LagBar_DB.scale = tonumber(scalenum)
					LagBarFrame:SetScale(tonumber(scalenum))
					DEFAULT_CHAT_FRAME:AddMessage("LagBar: scale has been set to ["..tonumber(scalenum).."]")
					return true
				end
			end
		end
	end
	DEFAULT_CHAT_FRAME:AddMessage("LagBar");
	DEFAULT_CHAT_FRAME:AddMessage("/lagbar reset - resets the frame position");
	DEFAULT_CHAT_FRAME:AddMessage("/lagbar bg - toggles the background on/off");
	DEFAULT_CHAT_FRAME:AddMessage("/lagbar scale # - Set the scale of the LagBar frame. Use small numbers like 0.5, 0.2, 1, 1.1, 1.5, etc..");
end;

function LagBar:MoveFrame()
	if LagBar.PL_Lock then return end
	LagBar.PL_Lock = true;	
	LagBarFrame:ClearAllPoints();
	LagBarFrame:SetPoint("CENTER", UIParent, LagBar_DB.x and "BOTTOMLEFT" or "BOTTOM", LagBar_DB.x or 0, LagBar_DB.y or 221);
	LagBarFrame:Show();
	LagBar.PL_Lock = false;
end;

function LagBar:DrawGUI()	

	if LagBarFrame then
		return
	end	

	lbFrame = CreateFrame("Frame", "LagBarFrame", UIParent, "GameTooltipTemplate");
	lbFrame:SetPoint("CENTER", UIParent, LagBar_DB.x and "BOTTOMLEFT" or "BOTTOM", LagBar_DB.x or 0, LagBar_DB.y or 221);
	lbFrame:EnableMouse(true);
	lbFrame:SetToplevel(true);
	lbFrame:SetMovable(true);
	lbFrame:SetFrameStrata("LOW");
	lbFrame:SetHeight(25);
	LagBarFrame:SetWidth(120);

	LagBarFrame:SetScale(LagBar_DB.scale)
	if LagBar_DB.bgShown then
		local backdrop_header = { 
			bgFile = "Interface/DialogFrame/UI-DialogBox-Background",
			edgeFile = dynamicEdges, 
			tile = false, 
			tileSize = 0, 
			edgeSize = dynamicEdgeSize,
			insets = {left = dynamicInsets, right = dynamicInsets, top = dynamicInsets, bottom = dynamicInsets }
		};
		lbFrame:SetBackdrop(backdrop_header);
		lbFrame:SetBackdropColor(.1,.1,.1, 1);
		lbFrame:SetBackdropBorderColor(r, g, b, a);
	else
		lbFrame:SetBackdrop(nil);
	end	
	lbFrame:RegisterForDrag("LeftButton")
	lbFrame.text = lbFrame:CreateFontString("$parentText", "ARTWORK", "GameFontNormalSmall");
	lbFrame.text:SetPoint("CENTER", lbFrame, "CENTER", 0, 0);
	lbFrame.text:Show();
	lbFrame:SetScript("OnEnter", function()
		GameTooltip:SetOwner(lbFrame, "ANCHOR_TOPRIGHT", 0, 15);
		GameTooltip:SetText(L["FeatureHeader"]);
		GameTooltip:AddLine(" ");
		GameTooltip:AddLine(L["RightClickToLock"], 1, 1, 1, true);
		GameTooltip:AddLine(" ");
		GameTooltip:AddLine(L["ResetCommand"], 1, 1, 1, true);
		GameTooltip:AddLine(L["BgCommand"], 1, 1, 1, true);
		GameTooltip:AddLine(L["ScaleCommand"], 1, 1, 1, true);
		GameTooltip:Show();
	end)
	lbFrame:SetScript("OnLeave", function()
		GameTooltip:Hide();
	end)
	lbFrame:SetScript("OnLoad", function()end)
	lbFrame:SetScript("OnShow", function()end)	
	lbFrame:SetScript("OnUpdate", function()			
		LagBar:OnUpdate(arg1);
	end)
	lbFrame:SetScript("OnMouseDown", function(frame, button) 
		if not LagBar_DB.locked and button ~= "RightButton" then
			frame.isMoving = true
			frame:StartMoving();
		end
	end)
	lbFrame:SetScript("OnMouseUp", function(frame, button) 
		if not LagBar_DB.locked and button ~= "RightButton" then
			if( frame.isMoving ) then
				frame.isMoving = nil;
				frame:StopMovingOrSizing();
				LagBar_DB.x, LagBar_DB.y = frame:GetCenter();
			end	
		elseif button == "RightButton" then
			if LagBar_DB.locked then
				LagBar_DB.locked = false;
				DEFAULT_CHAT_FRAME:AddMessage("LagBar: Unlocked");
			else
				LagBar_DB.locked = true;
				DEFAULT_CHAT_FRAME:AddMessage("LagBar: Locked");
			end
		end
	end)
	LagBar.frame = lbFrame;
end;

function LagBar:BackgroundToggle()
	if not LagBar_DB.bgShown then
		LagBar_DB.bgShown = true;
		DEFAULT_CHAT_FRAME:AddMessage("LagBar: Background Shown");
	elseif LagBar_DB.bgShown then
		LagBar_DB.bgShown = false;
		DEFAULT_CHAT_FRAME:AddMessage("LagBar: Background Hidden");
	else
		LagBar_DB.bgShown = true;
		DEFAULT_CHAT_FRAME:AddMessage("LagBar: Background Shown");
	end

	if LagBar_DB.bgShown and LagBar.frame then
		local backdrop_header = { 
			bgFile = "Interface/DialogFrame/UI-DialogBox-Background",
			edgeFile = dynamicEdges, 
			tile = false, 
			tileSize = 0, 
			edgeSize = dynamicEdgeSize,
			insets = {left = dynamicInsets, right = dynamicInsets, top = dynamicInsets, bottom = dynamicInsets }
		};
		LagBar.frame:SetBackdrop(backdrop_header);
		LagBar.frame:SetBackdropColor(.1,.1,.1, 1);
		LagBar.frame:SetBackdropBorderColor(r, g, b, a);
	else
		LagBar.frame:SetBackdrop(nil);
	end
end;

function LagBar:OnUpdate(arg1)
	if (LagBar.UPDATE_INTERVAL > 0) then
		LagBar.UPDATE_INTERVAL = LagBar.UPDATE_INTERVAL - arg1;
	else
		LagBar.UPDATE_INTERVAL = LagBar.MAX_INTERVAL;
		local d = " "
		local framerate = floor(GetFramerate() + 0.5)
		local framerate_text = format("|cff%s%d|r", LagBar_GetThresholdHexColor(framerate / 60), framerate)
		local framerate_local = L["FPS"];
		
		local latency = select(3, GetNetStats())
		local latency_text = format("|cff%s%d|r", LagBar_GetThresholdHexColor(latency, 1000, 500, 250, 100, 0), latency)
		local latency_local = L["Ms"];
		LagBarFrameText:SetText(framerate_local..d..framerate_text.." | "..latency_local..d..latency_text);
	end
end;

function LagBar_GetThresholdHexColor(quality, ...)
	local r, g, b = LagBar_GetThresholdColor(quality, ...);
	return string.format("%02x%02x%02x", r*255, g*255, b*255);
end;

function LagBar_GetThresholdColor(quality, ...)
	local inf = 1/0;	
	if quality ~= quality or quality == inf or quality == -inf then
		return 1, 1, 1;
	end
	local percent = LagBar_GetThresholdPercentage(quality, ...);
	if percent <= 0 then
		return 1, 0, 0;
	elseif percent <= 0.5 then
		return 1, percent*2, 0;
	elseif percent >= 1 then
		return 0, 1, 0;
	else
		return 2 - percent*2, 1, 0;
	end
end;

function LagBar_GetThresholdPercentage(quality, ...)
	local n = select('#', ...);
	if n <= 1 then
		return LagBar_GetThresholdPercentage(quality, 0, ... or 1);
	end
	local worst = ...
	local best = select(n, ...);
	if worst == best and quality == worst then
		return 0.5;
	end
	if worst <= best then
		if quality <= worst then
			return 0;
		elseif quality >= best then
			return 1;
		end
		local last = worst;
		for i = 2, n-1 do
			local value = select(i, ...)
			if quality <= value then
				return ((i-2) + (quality - last) / (value - last)) / (n-1);
			end
			last = value;
		end
		local value = select(n, ...)
		return ((n-2) + (quality - last) / (value - last)) / (n-1);
	else
		if quality >= worst then
			return 0;
		elseif quality <= best then
			return 1;
		end
		local last = worst
		for i = 2, n-1 do
			local value = select(i, ...)
			if quality >= value then
				return ((i-2) + (quality - last) / (value - last)) / (n-1);
			end
			last = value;
		end
		local value = select(n, ...)
		return ((n-2) + (quality - last) / (value - last)) / (n-1);
	end
end;