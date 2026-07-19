--LagBar by Derkyle (edited by DarhangeR)

local flagElvUI = select(4, GetAddOnInfo("ElvUI")) == 1 or false;
local r, g, b, a, dynamicEdgeSize, dynamicInsets = 1, 1, 1, 1, 12, 3;
local dynamicEdges = "Interface/DialogFrame/UI-DialogBox-Border";
if flagElvUI then
	dynamicEdges = "Interface/Buttons/WHITE8X8";
	r, g, b, a, dynamicEdgeSize, dynamicInsets = .0,.0,.0,.75, 2, 2;
end;

local format = string.format;
local floor = math.floor;
local tonumber = tonumber;
local strfind = string.find;
local strlower = string.lower;
local strsub = string.sub;

local CreateFrame = CreateFrame;
local DEFAULT_CHAT_FRAME = DEFAULT_CHAT_FRAME;
local GameTooltip = GameTooltip;
local GetAddOnCPUUsage = GetAddOnCPUUsage;
local GetAddOnInfo = GetAddOnInfo;
local GetAddOnMemoryUsage = GetAddOnMemoryUsage;
local GetCVar = GetCVar;
local GetFramerate = GetFramerate;
local GetNetStats = GetNetStats;
local GetNumAddOns = GetNumAddOns;
local IsAddOnLoaded = IsAddOnLoaded;
local SlashCmdList = SlashCmdList;
local UIParent = UIParent;
local UpdateAddOnCPUUsage = UpdateAddOnCPUUsage;
local UpdateAddOnMemoryUsage = UpdateAddOnMemoryUsage;

local BACKDROP = {
	bgFile = "Interface/DialogFrame/UI-DialogBox-Background",
	edgeFile = dynamicEdges,
	tile = false,
	tileSize = 0,
	edgeSize = dynamicEdgeSize,
	insets = {
		left = dynamicInsets,
		right = dynamicInsets,
		top = dynamicInsets,
		bottom = dynamicInsets,
	},
};

LagBar = {};
local LagBar = LagBar;
LagBar.version = GetAddOnMetadata("LagBar", "Version");
LagBar.PL_Lock = false;
LagBar.LOW_LATENCY = 300;
LagBar.MEDIUM_LATENCY = 600;
LagBar.MAX_INTERVAL = 1;
local L = LibStub("AceLocale-3.0"):GetLocale("LagBar");

local FPS_LABEL = L["FPS"];
local LATENCY_LABEL = L["Ms"];
local MEMORY_LABEL = L["Mem"];
local DOWNLOAD_LABEL = L["In"];
local UPLOAD_LABEL = L["Out"];

local DISPLAY_BASE = "%s |cff%06x%d|r | %s |cff%06x%d|r";
local DISPLAY_NET = "%s |cff%06x%d|r | %s |cff%06x%d|r | |cffffffff%s:|r |cff%06x%.2f KB/s|r | |cffffffff%s:|r |cff%06x%.2f KB/s|r";
local DISPLAY_MEMORY_KB = "%s |cff%06x%d|r | %s |cff%06x%d|r | |cffffffff%s:|r |cff%06x%d KB|r";
local DISPLAY_MEMORY_MB = "%s |cff%06x%d|r | %s |cff%06x%d|r | |cffffffff%s:|r |cff%06x%.1f MB|r";
local DISPLAY_NET_MEMORY_KB = "%s |cff%06x%d|r | %s |cff%06x%d|r | |cffffffff%s:|r |cff%06x%.2f KB/s|r | |cffffffff%s:|r |cff%06x%.2f KB/s|r | |cffffffff%s:|r |cff%06x%d KB|r";
local DISPLAY_NET_MEMORY_MB = "%s |cff%06x%d|r | %s |cff%06x%d|r | |cffffffff%s:|r |cff%06x%.2f KB/s|r | |cffffffff%s:|r |cff%06x%.2f KB/s|r | |cffffffff%s:|r |cff%06x%.1f MB|r";

local HUGE = math.huge;

local db;
local lagBarFrame;
local lagBarText;

local loadedAddonNames = {};
local loadedAddonTitles = {};
local loadedAddonCount = 0;
local loadedAddonsInitialized = false;
local topAddonTitles = {};
local topAddonValues = {};
local TOP_ADDON_COUNT = 15;

local function LagBar_CacheLoadedAddOn(addonName, addonTitle)
	if strfind(addonName, "Blizzard_", 1, true) == 1 then
		return;
	end

	loadedAddonCount = loadedAddonCount + 1;
	loadedAddonNames[loadedAddonCount] = addonName;
	loadedAddonTitles[loadedAddonCount] = addonTitle or addonName;
end

local function LagBar_InitializeLoadedAddOns()
	local addonCount = GetNumAddOns();
	for i = 1, addonCount do
		if IsAddOnLoaded(i) then
			local addonName, addonTitle = GetAddOnInfo(i);
			LagBar_CacheLoadedAddOn(addonName, addonTitle);
		end
	end
end

local function LagBar_BuildTopAddonUsage(getUsage)
	local topCount = 0;
	for i = 1, loadedAddonCount do
		local value = getUsage(loadedAddonNames[i]);
		local position = topCount + 1;

		while position > 1 and value > topAddonValues[position - 1] do
			position = position - 1;
		end

		if position <= TOP_ADDON_COUNT then
			local newCount = topCount + 1;
			if newCount > TOP_ADDON_COUNT then
				newCount = TOP_ADDON_COUNT;
			end

			for j = newCount, position + 1, -1 do
				topAddonValues[j] = topAddonValues[j - 1];
				topAddonTitles[j] = topAddonTitles[j - 1];
			end

			topAddonValues[position] = value;
			topAddonTitles[position] = loadedAddonTitles[i];
			topCount = newCount;
		end
	end

	return topCount;
end

local function LagBar_AddAddonUsageTooltip(tt)
	UpdateAddOnMemoryUsage();
	tt:AddLine(L["TopAddOnMemory"], 0, 0.81, 0.82);
	local topCount = LagBar_BuildTopAddonUsage(GetAddOnMemoryUsage);
	for i = 1, topCount do
		local memory = topAddonValues[i];
		if memory > 999 then
			tt:AddLine(format("%s: %.1f MB", topAddonTitles[i], memory / 1024), 1, 1, 1);
		else
			tt:AddLine(format("%s: %d KB", topAddonTitles[i], memory), 1, 1, 1);
		end
	end
	if GetCVar("scriptProfile") == "1" then
		UpdateAddOnCPUUsage();
		tt:AddLine(" ");
		tt:AddLine(L["TopAddOnCPU"], 0, 0.81, 0.82);
		topCount = LagBar_BuildTopAddonUsage(GetAddOnCPUUsage);
		for i = 1, topCount do
			tt:AddLine(format("%s: %.2f ms", topAddonTitles[i], topAddonValues[i]), 1, 1, 1);
		end
	end
end

function LagBar:Enable()
	if not LagBar_DB then
		LagBar_DB = {};
		LagBar_DB.x = 0;
		LagBar_DB.y = 0;
		LagBar_DB.locked = false;
		LagBar_DB.bgShown = true;
		LagBar_DB.scale = 1;
	end;
	db = LagBar_DB;

	if db.scale == nil then
		db.scale = 1;
	end;

	if db.showMemory == nil then
		db.showMemory = false;
	end
	if db.showNet == nil then
		db.showNet = false;
	end

	if not loadedAddonsInitialized then
		LagBar_InitializeLoadedAddOns();
		loadedAddonsInitialized = true;
	end

	SLASH_LAGBAR1 = "/lagbar";
	SlashCmdList["LAGBAR"] = LagBar_SlashCommand;

	LagBar:DrawGUI();
	LagBar:MoveFrame();
end;

function LagBar:OnEvent(event, arg1, arg2, arg3, arg4, ...)
	if event ~= "ADDON_LOADED" then
		return;
	end

	if arg1 == "LagBar" then
		LagBar:Enable();
	elseif loadedAddonsInitialized then
		local addonName, addonTitle = GetAddOnInfo(arg1);
		LagBar_CacheLoadedAddOn(addonName or arg1, addonTitle);
	end
end;

function LagBar_SlashCommand(cmd)
	local _, commandEnd, command = strfind(cmd, "(%S+)");
	if command then
		command = strlower(command);
		if command == "reset" then
			DEFAULT_CHAT_FRAME:AddMessage("LagBar: Frame position has been reset!");
			lagBarFrame:SetPoint("CENTER", UIParent, "CENTER", 0, 0);			
			return nil;
		elseif command == "bg" then
			LagBar:BackgroundToggle();
			return nil;		
		elseif command == "worldping" then
			LagBar:WorldPingToggle();
			return nil;		
		elseif command == "impdisplay" then
			LagBar:ImpDisplayToggle();
			return nil;
		elseif command == "memory" then
			LagBar:MemoryToggle();
			return nil;
		elseif command == "net" then
			LagBar:NetToggle();
			return nil;
		elseif command == "scale" then
			local scale = tonumber(strsub(cmd, commandEnd + 2));
			if scale then
				db.scale = scale;
				lagBarFrame:SetScale(scale);
				DEFAULT_CHAT_FRAME:AddMessage("LagBar: scale has been set to ["..scale.."]");
				return true;
			end
		end
	end
	DEFAULT_CHAT_FRAME:AddMessage(L["HelpTitle"]);
	DEFAULT_CHAT_FRAME:AddMessage(L["ResetCommand"]);
	DEFAULT_CHAT_FRAME:AddMessage(L["BgCommand"]);
	DEFAULT_CHAT_FRAME:AddMessage(L["ScaleCommand"]);
	DEFAULT_CHAT_FRAME:AddMessage(L["MemoryCommand"]);
	DEFAULT_CHAT_FRAME:AddMessage(L["NetCommand"]);
end;

function LagBar:MoveFrame()
	if LagBar.PL_Lock then return end
	LagBar.PL_Lock = true;	
	lagBarFrame:ClearAllPoints();
	lagBarFrame:SetPoint("CENTER", UIParent, db.x and "BOTTOMLEFT" or "BOTTOM", db.x or 0, db.y or 221);
	lagBarFrame:Show();
	LagBar.PL_Lock = false;
end;

function LagBar:DrawGUI()	

	if lagBarFrame then
		return
	end	

	local lbFrame = CreateFrame("Frame", "LagBarFrame", UIParent, "GameTooltipTemplate");
	lagBarFrame = lbFrame;
	lbFrame:SetPoint("CENTER", UIParent, db.x and "BOTTOMLEFT" or "BOTTOM", db.x or 0, db.y or 221);
	lbFrame:EnableMouse(true);
	lbFrame:SetToplevel(true);
	lbFrame:SetMovable(true);
	lbFrame:SetFrameStrata("LOW");
	lbFrame:SetHeight(25);
	lbFrame:SetWidth(120);

	lbFrame:SetScale(db.scale)
	if db.bgShown then
		lbFrame:SetBackdrop(BACKDROP);
		lbFrame:SetBackdropColor(.1,.1,.1, 1);
		lbFrame:SetBackdropBorderColor(r, g, b, a);
	else
		lbFrame:SetBackdrop(nil);
	end	
	lbFrame:RegisterForDrag("LeftButton")
	lbFrame.text = lbFrame:CreateFontString("$parentText", "ARTWORK", "GameFontNormalSmall");
	lagBarText = lbFrame.text;
	lagBarText:SetPoint("CENTER", lbFrame, "CENTER", 0, 0);
	lagBarText:Show();
	lbFrame:SetScript("OnEnter", function()
		if not db.showMemory then
			return;
		end
		GameTooltip:SetOwner(lbFrame, "ANCHOR_TOPRIGHT", 0, 15);
		LagBar_AddAddonUsageTooltip(GameTooltip);
		GameTooltip:Show();
	end)
	lbFrame:SetScript("OnLeave", function()
		GameTooltip:Hide();
	end)
	lbFrame:SetScript("OnMouseDown", function(frame, button) 
		if not db.locked and button ~= "RightButton" then
			frame.isMoving = true
			frame:StartMoving();
		end
	end)
	lbFrame:SetScript("OnMouseUp", function(frame, button) 
		if not db.locked and button ~= "RightButton" then
			if( frame.isMoving ) then
				frame.isMoving = nil;
				frame:StopMovingOrSizing();
				db.x, db.y = frame:GetCenter();
			end	
		elseif button == "RightButton" then
			if db.locked then
				db.locked = false;
				DEFAULT_CHAT_FRAME:AddMessage("LagBar: Unlocked");
			else
				db.locked = true;
				DEFAULT_CHAT_FRAME:AddMessage("LagBar: Locked");
			end
		end
	end)
	LagBar.frame = lbFrame;

	local updateGroup = lbFrame:CreateAnimationGroup();
	local updateAnimation = updateGroup:CreateAnimation("Alpha");
	updateAnimation:SetOrder(1);
	updateAnimation:SetChange(0);
	updateAnimation:SetDuration(LagBar.MAX_INTERVAL);
	updateGroup:SetLooping("REPEAT");
	updateGroup:SetScript("OnLoop", LagBar.OnUpdate);
	lbFrame.updateGroup = updateGroup;

	LagBar:OnUpdate();
	updateGroup:Play();
end;

function LagBar:BackgroundToggle()
	if not db.bgShown then
		db.bgShown = true;
		DEFAULT_CHAT_FRAME:AddMessage("LagBar: Background Shown");
	elseif db.bgShown then
		db.bgShown = false;
		DEFAULT_CHAT_FRAME:AddMessage("LagBar: Background Hidden");
	else
		db.bgShown = true;
		DEFAULT_CHAT_FRAME:AddMessage("LagBar: Background Shown");
	end

	if db.bgShown and lagBarFrame then
		lagBarFrame:SetBackdrop(BACKDROP);
		lagBarFrame:SetBackdropColor(.1,.1,.1, 1);
		lagBarFrame:SetBackdropBorderColor(r, g, b, a);
	else
		lagBarFrame:SetBackdrop(nil);
	end
end;

function LagBar:MemoryToggle()
	db.showMemory = not db.showMemory;
	if db.showMemory then
		DEFAULT_CHAT_FRAME:AddMessage(L["MemoryEnabled"]);
	else
		DEFAULT_CHAT_FRAME:AddMessage(L["MemoryDisabled"]);
	end
end

function LagBar:NetToggle()
	db.showNet = not db.showNet;
	if db.showNet then
		DEFAULT_CHAT_FRAME:AddMessage(L["NetEnabled"]);
	else
		DEFAULT_CHAT_FRAME:AddMessage(L["NetDisabled"]);
	end
end

local function LagBar_GetPackedThresholdColor(quality, worst, second, third, fourth, best)
	if quality >= worst then
		return 16711680;
	elseif quality >= second then
		local percent = ((quality - worst) / (second - worst)) / 4;
		return 16711680 + floor(percent * 510) * 256;
	elseif quality >= third then
		local percent = (1 + (quality - second) / (third - second)) / 4;
		return 16711680 + floor(percent * 510) * 256;
	elseif quality >= fourth then
		local percent = (2 + (quality - third) / (fourth - third)) / 4;
		return floor((2 - percent * 2) * 255) * 65536 + 65280;
	elseif quality <= best then
		return 65280;
	end

	local percent = (3 + (quality - fourth) / (best - fourth)) / 4;
	return floor((2 - percent * 2) * 255) * 65536 + 65280;
end

local lastFramerate;
local lastFramerateColor;
local lastLatency;
local lastLatencyColor;
local lastShowNet;
local lastDownload;
local lastDownloadColor;
local lastUpload;
local lastUploadColor;
local lastShowMemory;
local lastMemory;
local lastMemoryColor;
local lastMemoryIsMB;

function LagBar:OnUpdate()
	local framerate = floor(GetFramerate() + 0.5);
	local framerateQuality = framerate / 60;
	local framerateColor;
	if framerateQuality <= 0 then
		framerateColor = 16711680;
	elseif framerateQuality <= 0.5 then
		framerateColor = 16711680 + floor(framerateQuality * 510) * 256;
	elseif framerateQuality >= 1 then
		framerateColor = 65280;
	else
		framerateColor = floor((2 - framerateQuality * 2) * 255) * 65536 + 65280;
	end
	local download, upload, latency = GetNetStats();
	local latencyValue = floor(latency);
	local latencyColor = LagBar_GetPackedThresholdColor(latency, 1000, 500, 250, 100, 0);
	local showNet = db.showNet;
	local showMemory = db.showMemory;
	local downloadValue;
	local downloadColor;
	local uploadValue;
	local uploadColor;
	local memoryValue;
	local memoryMB;
	local memoryColor;
	local memoryIsMB;

	if showNet then
		downloadValue = floor(download * 100 + 0.5);
		uploadValue = floor(upload * 100 + 0.5);
		downloadColor = LagBar_GetPackedThresholdColor(download, 100, 50, 25, 15, 5);
		uploadColor = LagBar_GetPackedThresholdColor(upload, 100, 50, 25, 15, 5);
	end

	if showMemory then
		UpdateAddOnMemoryUsage();
		local totalMemory = 0;
		for i = 1, loadedAddonCount do
			totalMemory = totalMemory + GetAddOnMemoryUsage(loadedAddonNames[i]);
		end

		memoryMB = totalMemory / 1024;
		memoryColor = LagBar_GetPackedThresholdColor(memoryMB, 50, 30, 20, 10, 5);
		memoryIsMB = totalMemory > 999;
		if memoryIsMB then
			memoryValue = floor(memoryMB * 10 + 0.5);
		else
			memoryValue = floor(totalMemory);
		end
	end

	local displayChanged = framerate ~= lastFramerate
		or framerateColor ~= lastFramerateColor
		or latencyValue ~= lastLatency
		or latencyColor ~= lastLatencyColor
		or showNet ~= lastShowNet
		or showMemory ~= lastShowMemory;

	if showNet and (downloadValue ~= lastDownload
		or downloadColor ~= lastDownloadColor
		or uploadValue ~= lastUpload
		or uploadColor ~= lastUploadColor) then
		displayChanged = true;
	end

	if showMemory and (memoryValue ~= lastMemory
		or memoryColor ~= lastMemoryColor
		or memoryIsMB ~= lastMemoryIsMB) then
		displayChanged = true;
	end

	if not displayChanged then
		return;
	end

	lastFramerate = framerate;
	lastFramerateColor = framerateColor;
	lastLatency = latencyValue;
	lastLatencyColor = latencyColor;
	lastShowNet = showNet;
	lastDownload = downloadValue;
	lastDownloadColor = downloadColor;
	lastUpload = uploadValue;
	lastUploadColor = uploadColor;
	lastShowMemory = showMemory;
	lastMemory = memoryValue;
	lastMemoryColor = memoryColor;
	lastMemoryIsMB = memoryIsMB;

	if showNet then
		if showMemory then
			if memoryIsMB then
				lagBarText:SetFormattedText(DISPLAY_NET_MEMORY_MB,
					FPS_LABEL, framerateColor, framerate,
					LATENCY_LABEL, latencyColor, latencyValue,
					DOWNLOAD_LABEL, downloadColor, download,
					UPLOAD_LABEL, uploadColor, upload,
					MEMORY_LABEL, memoryColor, memoryMB);
			else
				lagBarText:SetFormattedText(DISPLAY_NET_MEMORY_KB,
					FPS_LABEL, framerateColor, framerate,
					LATENCY_LABEL, latencyColor, latencyValue,
					DOWNLOAD_LABEL, downloadColor, download,
					UPLOAD_LABEL, uploadColor, upload,
					MEMORY_LABEL, memoryColor, memoryValue);
			end
		else
			lagBarText:SetFormattedText(DISPLAY_NET,
				FPS_LABEL, framerateColor, framerate,
				LATENCY_LABEL, latencyColor, latencyValue,
				DOWNLOAD_LABEL, downloadColor, download,
				UPLOAD_LABEL, uploadColor, upload);
		end
	elseif showMemory then
		if memoryIsMB then
			lagBarText:SetFormattedText(DISPLAY_MEMORY_MB,
				FPS_LABEL, framerateColor, framerate,
				LATENCY_LABEL, latencyColor, latencyValue,
				MEMORY_LABEL, memoryColor, memoryMB);
		else
			lagBarText:SetFormattedText(DISPLAY_MEMORY_KB,
				FPS_LABEL, framerateColor, framerate,
				LATENCY_LABEL, latencyColor, latencyValue,
				MEMORY_LABEL, memoryColor, memoryValue);
		end
	else
		lagBarText:SetFormattedText(DISPLAY_BASE,
			FPS_LABEL, framerateColor, framerate,
			LATENCY_LABEL, latencyColor, latencyValue);
	end

	local textWidth = lagBarText:GetStringWidth() + 24;
	if textWidth < 120 then
		textWidth = 120;
	end
	lagBarFrame:SetWidth(textWidth);
end;

function LagBar_GetThresholdHexColor(quality, ...)
	local r, g, b = LagBar_GetThresholdColor(quality, ...);
	return format("%02x%02x%02x", r*255, g*255, b*255);
end;

function LagBar_GetThresholdColor(quality, ...)
	if quality ~= quality or quality == HUGE or quality == -HUGE then
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
