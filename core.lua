-- Setup the Frames
local frame = CreateFrame("FRAME", "HunterPetStatusFrame", nil, "BackdropTemplate")
frame:RegisterEvent("PLAYER_ENTERING_WORLD")
frame:RegisterEvent("PLAYER_UNGHOST")
frame:RegisterEvent("PLAYER_ALIVE")
frame:RegisterEvent("READY_CHECK")
frame:RegisterEvent("UNIT_PET")
frame:RegisterEvent("PLAYER_REGEN_ENABLED")

local rezButton = CreateFrame("Button", "HunterPetStatusRezButton", UIParent)
rezButton:SetFrameStrata("BACKGROUND")
rezButton:SetSize(128,128)
-- Can click the button to hide if doesn't want to rez/summon pet yet
rezButton:SetScript("OnClick", function() rezButton:Hide() end)

local rezIcon = rezButton:CreateTexture(nil, "BACKGROUND")
rezIcon:SetTexture(132163)
rezIcon:SetAllPoints(rezButton)
rezButton.texture = rezIcon
rezButton:SetPoint("CENTER", 0, 0)
rezButton:Hide()

local summonButton = CreateFrame("Button", "HunterPetStatusSummonButton", UIParent)
summonButton:SetFrameStrata("BACKGROUND")
summonButton:SetSize(128,128)
-- Can click the button to hide if doesn't want to rez/summon pet yet
summonButton:SetScript("OnClick", function() summonButton:Hide() end)

local summonIcon = summonButton:CreateTexture(nil, "BACKGROUND")
summonIcon:SetTexture(132161)
summonIcon:SetAllPoints(summonButton)
summonButton.texture = rezIcon
summonButton:SetPoint("CENTER", 0, 0)
summonButton:Hide()

-- Checks if pet is summoned or dead
local function checkPetStatus()
	local currentSpec = GetSpecialization()
	local currentSpecName = currentSpec and select(2, GetSpecializationInfo(currentSpec)) or "None"
	if UnitExists("pet") and UnitHealth("pet") ~= 0 then
		IS_PET_ALIVE = true
		rezButton:Hide()
		summonButton:Hide()
	end
	inInstance, instanceType = IsInInstance()
	if (inInstance and not UnitAffectingCombat("player")) then
		if UnitClass("player"):lower() == "hunter" and currentSpecName:lower() == "beast mastery" then
			if not IS_PET_ALIVE then
				rezButton:Show()
			elseif UnitExists("pet") and UnitHealth("pet") == 0 then
				rezButton:Show()
			elseif not UnitExists("pet") then
				summonButton:Show()
			end
		end
	end
	if (not inInstance) then
		rezButton:Hide()
		summonButton:Hide()
	end
end

local function eventHandler(self, event, ...)
	-- First instance of IS_PET_ALIVE is nil on very first load so we assume your pet is alive
	if IS_PET_ALIVE == nil then
		IS_PET_ALIVE = true
	end
	checkPetStatus()
end

-- This tracks to see if your pet dies so the addon can then show the correct icon whether to rez pet
local petFrame = CreateFrame("FRAME", "PetFrame", nil, "BackdropTemplate")
petFrame:RegisterEvent("PET_ATTACK_STOP")

local function petEventHandler(self, event, ...)
	if UnitClass("player"):lower() == "hunter" then
		if UnitHealth("pet") == 0 then
			IS_PET_ALIVE = false
			RaidNotice_AddMessage(RaidBossEmoteFrame, "Pet has died!!!", ChatTypeInfo["RAID_BOSS_EMOTE"])
		end
	end
end

-- Does a check on pull timer
local pullTimerFrame = CreateFrame("FRAME", "PullTimerFrame", nil, "BackdropTemplate")
pullTimerFrame:RegisterEvent("CHAT_MSG_ADDON")

local function pullTimerEventHandler(self, event, ...)
	local prefix, msg = ...
	if prefix:lower() == "bigwigs" or prefix:lower() == "d4" then
		if msg:lower():find("pull") or msg:lower():find("pt") then
			checkPetStatus()
		end
	end
end

frame:SetScript("OnEvent", eventHandler)
petFrame:SetScript("OnEvent", petEventHandler)
pullTimerFrame:SetScript("OnEvent", pullTimerEventHandler)