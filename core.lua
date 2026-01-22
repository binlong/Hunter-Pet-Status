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
rezButton:SetMovable(true)
rezButton:RegisterForDrag("LeftButton")
rezButton:SetScript("OnDragStart", rezButton.StartMoving)
rezButton:SetScript("OnDragStop", rezButton.StopMovingOrSizing)
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
summonButton:SetMovable(true)
summonButton:RegisterForDrag("LeftButton")
summonButton:SetScript("OnDragStart", summonButton.StartMoving)
summonButton:SetScript("OnDragStop", summonButton.StopMovingOrSizing)
-- Can click the button to hide if doesn't want to rez/summon pet yet
summonButton:SetScript("OnClick", function() summonButton:Hide() end)

local summonIcon = summonButton:CreateTexture(nil, "BACKGROUND")
summonIcon:SetTexture(132161)
summonIcon:SetAllPoints(summonButton)
summonButton.texture = rezIcon
summonButton:SetPoint("CENTER", 0, 0)
summonButton:Hide()

local wakeUpButton = CreateFrame("Button", "HunterPetStatusWakeUpButton", UIParent)
wakeUpButton:SetFrameStrata("BACKGROUND")
wakeUpButton:SetSize(128,128)
wakeUpButton:SetMovable(true)
wakeUpButton:RegisterForDrag("LeftButton")
wakeUpButton:SetScript("OnDragStart", wakeUpButton.StartMoving)
wakeUpButton:SetScript("OnDragStop", wakeUpButton.StopMovingOrSizing)
-- Can click the button to hide if doesn't want to rez/summon pet yet
wakeUpButton:SetScript("OnClick", function() wakeUpButton:Hide() end)

local wakeUpIcon = wakeUpButton:CreateTexture(nil, "BACKGROUND")
wakeUpIcon:SetTexture(589118)
wakeUpIcon:SetAllPoints(wakeUpButton)
wakeUpButton.texture = rezIcon
wakeUpButton:SetPoint("CENTER", 0, 0)
wakeUpButton:Hide()

local function hideAllButtons()
	rezButton:Hide()
	summonButton:Hide()
	wakeUpButton:Hide()
end

-- Checks if pet is summoned or dead
local function checkPetStatus()
	local currentSpec = GetSpecialization()
	local currentSpecName = currentSpec and select(2, GetSpecializationInfo(currentSpec)) or "None"
	local playDeadBuff = AuraUtil.FindAuraByName("Play Dead", "pet") or "None"
	-- if UnitExists("pet") and UnitHealth("pet") ~= 0 then
	if UnitExists("pet") and not UnitIsDead("pet") then
		IS_PET_ALIVE = true
		hideAllButtons()
	end
	local inInstance, instanceType = IsInInstance()
	if (inInstance and not UnitAffectingCombat("player")) then
		if UnitClass("player"):lower() == "hunter" then
			if currentSpecName:lower() == "beast mastery" or currentSpecName:lower() == "survival"then
				if not IS_PET_ALIVE then
					rezButton:Show()
				elseif UnitExists("pet") and UnitIsDead("pet") then
					rezButton:Show()
				elseif not UnitExists("pet") then
					summonButton:Show()
				elseif playDeadBuff:lower() == "play dead" then
					wakeUpButton:Show()
				end
			end
		end
	end
	if (not inInstance) then
		hideAllButtons()
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
		if UnitIsDead("pet") then
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

-- This tracks to see if pet got a buff for "Play Dead"
local petBuffFrame = CreateFrame("FRAME", "PetBuffFrame", nil, "BackdropTemplate")
petBuffFrame:RegisterEvent("UNIT_AURA")

local function checkPetBuffEventHandler(self, event, ...)
	local unit_id = ...
	if unit_id == "pet" then
		checkPetStatus()
	end
end


frame:SetScript("OnEvent", eventHandler)
petFrame:SetScript("OnEvent", petEventHandler)
pullTimerFrame:SetScript("OnEvent", pullTimerEventHandler)
petBuffFrame:SetScript("OnEvent", checkPetBuffEventHandler)
