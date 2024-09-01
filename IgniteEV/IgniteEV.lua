print("Ignite EV-- /ignite unlock|lock to move things")
-- may want to add an icon indicator for this function later
local function check_ignite_duration()
    for i=1,40 do
        name,_,_,_,duration,expirationTime = UnitDebuff("target",i,"PLAYER|HARMFUL");
        if name == "Ignite" then
            --print(duration)
            local duration_disp=duration
            --print(expirationTime)
            break
        end
    end
    return duration
end
local function check_leak() -- i dont think this function is ever called. found a work-around.
    if subevent=="SPELL_PERIODIC_DAMAGE" and playerGUID == sourceGUID then
        destGUID,_,_,_,_,amount,_,_,_,_,_,_,critical=select(8,CombatLogGetCurrentEventInfo())
        --if spellName == "Ignite" then -- logic was implimented before function call.
        ignite_pool=ignite_pool-amount
    end
end
local function add_to_pool_and_leaks()
    if subevent == "SPELL_DAMAGE" then
        destGUID,_,_,_,_,spellName,_,amount,_,_,_,_,_,critical=select(8,CombatLogGetCurrentEventInfo())
    end
    if spellName=="Ignite" and playerGUID == sourceGUID then
        ignite_pool=ignite_pool-amount
    end 
    if critical  and playerGUID == sourceGUID then
        local dest=destGUID
        mastery_ = (1 + (2.8 * GetMastery())/100)
        ignite=mastery_*amount*.4
        ignite_pool=ignite+ignite_pool
    end
end
-- all the stuff that makes icons appear:---------------------
-- a frame indicates a new UI component
-- using variable: modifies the frame actions.
local icon_parent= CreateFrame("Frame","Parent_frame",UIParent)
icon_parent:SetSize(192,64)
icon_parent:SetPoint("CENTER",UIParent,"CENTER",-200,-100)
local iconPaths = {
    "Interface\\Icons\\Spell_Fire_Incinerate",
    "Interface\\icons\\spell_fire_FlameBolt",
    "Interface\\Icons\\Spell_Fire_Fireball02",
}
-- Declare and calc values to display
-- Create and position each icon
local pool=0
local fireball_icon=0
local pyro_icon=0
local iconSize = 64
local display_values={
    pool,
    fireball_icon,
    pyro_icon,
}

local fontStrings={}
local icons={}
local function createIconsWithText(iconPaths, iconSize, icon_parent, display_values)
    for i, iconPath in ipairs(iconPaths) do
        -- Create and configure the icon texture
        local icon = icon_parent:CreateTexture(nil, "BACKGROUND")
        icon:SetTexture(iconPath)
        icon:SetSize(iconSize, iconSize)
        
        -- Position icons in a row (horizontal layout)
        icon:SetPoint("LEFT", icon_parent, "LEFT", (i - 1) * iconSize, 0)
        
        -- Create and configure the text
        local iconText = icon_parent:CreateFontString(nil, "OVERLAY", "GameFontNormal")
        iconText:SetPoint("TOP", icon, "BOTTOM", 0, -5)
        iconText:SetText(tostring(display_values[i]))
        fontStrings[i]=iconText
        icons[i]=icon
    end
    return fontStrings, icons
end
-- function call to toggle combustion indicator
local function check_negative(FB_EV_IGNITE,texture2,text2)
    if FB_EV_IGNITE<=0 then
        local start=GetSpellCooldown("Combustion")
        if start==0 then
            texture2:Show()
            text2:Show()
        end
    else
        texture2:Hide()
        text2:Hide()
    end
end
-- toggle combust value for pyroblast
local function check_negative_pyro(FB_EV_IGNITE,texture3,text3)
    if FB_EV_IGNITE<=0 then
        local start=GetSpellCooldown("Combustion")
        if start==0 then
            texture3:Show()
            text3:Show()
        end
    else
        texture3:Hide()
        text3:Hide()
    end
end

-- end display stuff
-- create the logical indicator if fireball is worth. need to include combstion cd dependencies.
local textureFrame = CreateFrame("Frame", "MyTextureFrame", UIParent)
textureFrame:SetSize(256, 256)  -- Set the size of the frame (width, height)
textureFrame:SetPoint("CENTER",0,225)  -- Position the frame in the center of the screen
-- make it movable
textureFrame:SetMovable(true)
--textureFrame:EnableMouse(true)
textureFrame:RegisterForDrag("LeftButton")
textureFrame:SetScript("OnDragStart",function(self)
    if not self.isLocked then
        self:StartMoving()
    end
end)
textureFrame:SetScript("OnDragStop",function(self)
    self:StopMovingOrSizing()
end)
-- Resizing functionality
textureFrame:SetResizable(true)
textureFrame:SetResizeBounds(32,32,256,256)
-- Resize handle (corner of the frame)
local resizeButton = CreateFrame("Button", nil, textureFrame)
resizeButton:SetSize(16, 16)
resizeButton:SetPoint("BOTTOMRIGHT", textureFrame, "BOTTOMRIGHT")
resizeButton:SetNormalTexture("Interface\\CHATFRAME\\UI-ChatIM-SizeGrabber-Up")
resizeButton:SetHighlightTexture("Interface\\CHATFRAME\\UI-ChatIM-SizeGrabber-Highlight")
resizeButton:SetPushedTexture("Interface\\CHATFRAME\\UI-ChatIM-SizeGrabber-Down")

resizeButton:SetScript("OnMouseDown", function(self, button)
    if button == "LeftButton" and not textureFrame.isLocked then
        textureFrame:StartSizing("BOTTOMRIGHT")
        textureFrame.isResizing = true
    end
end)

resizeButton:SetScript("OnMouseUp", function(self, button)
    if textureFrame.isResizing then
        textureFrame:StopMovingOrSizing()
        textureFrame.isResizing = false
        --textureFrame.texture:SetAllPoints(textureFrame)  -- Adjust texture to the new size
    end
end)

-- Lock/Unlock toggle and other in-game /commands
textureFrame.isLocked = true
resizeButton:Hide()
SLASH_IGNITE1 = "/ignite"
SlashCmdList["IGNITE"] = function(msg)
    if msg == "unlock" then
        textureFrame.isLocked = false
        textureFrame3.isLocked = false
        resizeButton:Show()
        textureFrame3:EnableMouse(true)
        textureFrame:EnableMouse(true)
        texture2:Show()
        texture3:Show()
        resizeButton2:Show()
        print("IgniteEV: Frame unlocked.")
    elseif msg == "lock" then
        textureFrame.isLocked = true
        textureFrame3.isLocked = true
        resizeButton:Hide()
        resizeButton2:Hide()
        textureFrame3:EnableMouse(false)
        textureFrame:EnableMouse(false)
        texture3:Hide()
        texture2:Hide()
        print("IgniteEV: Frame locked.")
    elseif msg == "hide info" then
        for i=1,3 do
            icons[i]:Hide()
            fontStrings[i]:Hide()
        end
    elseif msg == "show info" then
        for i=1,3 do
            icons[i]:Show()
            fontStrings[i]:Show()
        end
    else
        print("Usage:\n/ignite unlock  -- move and resize icons\n /ignite lock  --  lock icons in place"..
    "\n /ignite show info -- shows info panel icons:the math functions used in the addon \n /ignite hide info -- hides the info panel")
    end
end
--________________________________________________
-- Create a texture frame and icon for fireball negative EV indicator.
texture2 = textureFrame:CreateTexture(nil, "ARTWORK")
texture2:SetAllPoints(textureFrame)  -- Make the texture fill the frame
texture2:SetTexture("Interface\\Icons\\ability_mage_firestarter")-- reference custom texture
local text2=textureFrame:CreateFontString(nil,"OVERLAY","GameFontNormal")
text2:SetPoint("TOP", texture2, "BOTTOM", 0, -5)
text2:SetText(tostring(display_values[2]))
texture2:Hide()
text2:Hide()
fontStrings[4]=text2
-- do same thing for pyro proc.
textureFrame3 = CreateFrame("Frame", "MyTextureFrame2", UIParent)-- watchlist
textureFrame3:SetSize(256, 256)  -- Set the size of the frame (width, height)
textureFrame3:SetPoint("CENTER",0,225)  -- Position the frame in the center of the screen
--______________________________________________________
textureFrame3:SetMovable(true)
--textureFrame3:EnableMouse(true)
textureFrame3:RegisterForDrag("LeftButton")
textureFrame3:SetScript("OnDragStart", function(self)
    if not self.isLocked then
        self:StartMoving()
    end
end)
textureFrame3:SetScript("OnDragStop", function(self)
    self:StopMovingOrSizing()
end)

-- Resizing functionality
textureFrame3:SetResizable(true)
textureFrame3:SetResizeBounds(32,32,256,256)  -- Maximum size

-- Resize handle (corner of the frame)
resizeButton2 = CreateFrame("Button", nil, textureFrame3)
resizeButton2:SetSize(16, 16)
resizeButton2:SetPoint("BOTTOMRIGHT", textureFrame3, "BOTTOMRIGHT")
resizeButton2:SetNormalTexture("Interface\\CHATFRAME\\UI-ChatIM-SizeGrabber-Up")
resizeButton2:SetHighlightTexture("Interface\\CHATFRAME\\UI-ChatIM-SizeGrabber-Highlight")
resizeButton2:SetPushedTexture("Interface\\CHATFRAME\\UI-ChatIM-SizeGrabber-Down")

resizeButton2:SetScript("OnMouseDown", function(self, button)
    if button == "LeftButton" and not textureFrame3.isLocked then
        textureFrame3:StartSizing("BOTTOMRIGHT")
        textureFrame3.isResizing = true
    end
end)

resizeButton2:SetScript("OnMouseUp", function(self, button)
    if textureFrame3.isResizing then
        textureFrame3:StopMovingOrSizing()
        textureFrame3.isResizing = false
        --textureFrame3.texture:SetAllPoints(textureFrame3)  -- Adjust texture to the new size
    end
end)

-- Lock/Unlock toggle
textureFrame3.isLocked = true
resizeButton2:Hide()
--_____________________________________________________________________
-- Create a texture and set the custom texture: for pyroblast EV
texture3 = textureFrame3:CreateTexture(nil, "ARTWORK")
texture3:SetAllPoints(textureFrame3)  -- Make the texture fill the frame
texture3:SetTexture("Interface\\Icons\\Ability_Rhyolith_Volcano")-- reference custom texture
local text3=textureFrame3:CreateFontString(nil,"OVERLAY","GameFontNormal")
text3:SetPoint("TOP", texture3, "BOTTOM", 0, -5)
text3:SetText(tostring(display_values[3]))
texture3:Hide()
text3:Hide()
fontStrings[5]=text3
--texture2:Hide()
--EV calc functions:
function check_EV_Leak(ignite_pool,duration)
    local castTime=select(4,GetSpellInfo("Fireball"))
    castTime=castTime/1000 -- convert from MS to seconds
    local IGT=duration
    local x=4
    local t=IGT-castTime
    local Theoretical_Ignite=ignite_pool
    if IGT==4 and t<=2 then
        --print('big leak')
        Theoretical_Ignite=(ignite_pool/2)
        x=x-2
    end
    if x>=t then
        --print('leak')
        x=x-2
        Theoretical_Ignite=(2*ignite_pool/3)
    end
    return Theoretical_Ignite -- the ignite before fireball would hit.
end
function check_EV_Leak_Pyro(ignite_pool,duration)
    local castTime=getGCD()-- use gcd instead of cast-time-- works for all variations
    castTime=castTime/1000 -- convert from MS to seconds
    local IGT=duration
    local x=4
    local t=IGT-castTime
    local Theoretical_Ignite=ignite_pool
    if IGT==4 and t<=2 then
        --print('big leak')
        Theoretical_Ignite=(ignite_pool/2)
        x=x-2
    end
    if x>=t then
        --print('leak')
        x=x-2
        Theoretical_Ignite=(2*ignite_pool/3)
    end
    return Theoretical_Ignite -- the ignite before pyro would hit.
end
function check_EV_Leak_2(ignite_pool,duration,gcd)
    local castTime=select(4,GetSpellInfo("Fireball"))
    castTime=castTime/1000 -- convert from MS to seconds
    local IGT=duration
    local x=4
    local t=IGT-castTime-gcd
    local Theoretical_Ignite=ignite_pool
    if IGT==4 and t<=2 then
        --print('big leak')
        Theoretical_Ignite=(ignite_pool/2)
        x=x-2
    end
    while x>=t do
        --print('leak')
        x=x-2
        Theoretical_Ignite=(2*ignite_pool/3)
    end
    EV_type=0
    return Theoretical_Ignite
end
function getGCD()
    local spellhaste=UnitSpellHaste("player")
    local gcd=1.5/(1+(spellhaste/100))
    --print(gcd)
    return gcd
end
-- theoretical ignite pool calc functions
function fireball_EV(ignite_pool)
    local fireball_dam=1273+(1.5913*GetSpellBonusDamage(3))+175
    local EV_ignite_pool= ignite_pool+(fireball_dam*2.06*.4*(1 + (2.8 * GetMastery())/100))
    --display new ignite pool.
    --print(EV_ignite_pool)
    -- factor in durration.
    return EV_ignite_pool
end
function pyroblast_EV(ignite_pool)
    local pyroblast_dam=1594+(1.99*GetSpellBonusDamage(3))+216
    local EV_ignite_pool= ignite_pool+(pyroblast_dam*2.06*.4*(1 + (2.8 * GetMastery())/100))
    --display new ignite pool.
    --print(EV_ignite_pool)
    -- factor in durration.
    return EV_ignite_pool
end
-- create UI elements and icons
local fontStrings,icons=createIconsWithText(iconPaths, iconSize, icon_parent, display_values)
--print(fontStrings[1]:GetText())
-- hide info panel on init.
for i=1,3 do
    icons[i]:Hide()
    fontStrings[i]:Hide()
end

local playerGUID=UnitGUID("player")
--print(playerGUID)
local f = CreateFrame("Frame")
local ignite_pool=0
local ignite=0
local mastery_ = (1 + (2.8 * GetMastery())/100)
local valid_ignite_spells = {
    ["Fireball"]=true,
    ["Pyroblast!"]=true,
    ["Pyroblast"]=true,
    ["Fire Blast"]=true,
    ["Blast Wave"]=true,
    ["Dragon's Breath"]=true,
    ["Flame Orb"]=true,
    ["Scorch"]=true,
    ["Flamestrike"]=true,
}
-- separate spells to allow EV timer to add up
local instant_ignite_spells= {
    ["Pyroblast!"]=true,
    ["Fire Blast"]=true,
    ["Dragon's Breath"]=true,
    ["Flamestrike"]=true,
}
local EV_type=0
f: RegisterEvent("Combat_LOG_EVENT_UNFILTERED")
f:SetScript('OnEvent', function(self,event)
    local _,subevent,_,sourceGUID=CombatLogGetCurrentEventInfo()
    local amount, critical
    --print(subevent)
    if subevent == "SPELL_AURA_APPLIED" and playerGUID == sourceGUID then
        local applied=select(13,CombatLogGetCurrentEventInfo())
        local dest=select(8,CombatLogGetCurrentEventInfo())
        local dguid=UnitGUID("target")
        --print(dest)
        --print(applied)
        if applied=="Ignite" and dest==dguid then
            local fb_EV_duration=check_ignite_duration()
            --print(fb_EV_duration) -- may want a UI element showing this later
            local Theoretical_Ignite1=check_EV_Leak(ignite_pool,fb_EV_duration)
            FB_EV_IGNITE=fireball_EV(Theoretical_Ignite1)-ignite_pool
            check_negative(FB_EV_IGNITE,texture2,text2)
            --print("FIREBALL EV")
            if fontStrings[2] then
                fontStrings[2]:SetText(math.floor(FB_EV_IGNITE))
                fontStrings[4]: SetText(math.floor(FB_EV_IGNITE))
            end
            -- get pyro theoretical dam calculated
            local PTheoretical_Ignite=check_EV_Leak_Pyro(ignite_pool,fb_EV_duration)
            local Pyro_EV_Ignite=pyroblast_EV(PTheoretical_Ignite)-ignite_pool
            --Pyro_EV_Ignite=-2
            check_negative_pyro(Pyro_EV_Ignite,texture3,text3)
            if fontStrings[3] then
                fontStrings[3]:SetText(math.floor(Pyro_EV_Ignite))
                fontStrings[5]:SetText(math.floor(Pyro_EV_Ignite))
            end
            --print(FB_EV_IGNITE)
            --- check which function to use, separate function for different cast-sequences
            if EV_type == 2 then
                --print("using alternate calc")
                local gcd=getGCD()
                local Theoretical_Ignite2=check_EV_Leak_2(ignite_pool,fb_EV_duration,gcd)
                FB_EV_IGNITE=fireball_EV(Theoretical_Ignite2)-ignite_pool
                check_negative(FB_EV_IGNITE,texture2,text2)
                if fontStrings[2] then
                    fontStrings[2]:SetText(math.floor(FB_EV_IGNITE))
                    fontStrings[4]: SetText(math.floor(FB_EV_IGNITE))
                end
            end
            --print("ignite applied")
        end
    end
    if subevent == "SPELL_AURA_REFRESH" and playerGUID == sourceGUID then
        local refresh=select(13,CombatLogGetCurrentEventInfo())
        local dest=select(8,CombatLogGetCurrentEventInfo())
        local dguid=UnitGUID("target")
        --print(refresh)
        if refresh=="Ignite" and dest==dguid then
            fb_EV_duration=check_ignite_duration()
            --print(fb_EV_duration)
            --print("REAPPLY FB EV")
            local Theoretical_Ignite1=check_EV_Leak(ignite_pool,fb_EV_duration)
            FB_EV_IGNITE=fireball_EV(Theoretical_Ignite1)-ignite_pool
            check_negative(FB_EV_IGNITE,texture2,text2)
            if fontStrings[2] then
                fontStrings[2]:SetText(math.floor(FB_EV_IGNITE))
                fontStrings[4]: SetText(math.floor(FB_EV_IGNITE))
            end
            --pyro EV
            local PTheoretical_Ignite=check_EV_Leak_Pyro(ignite_pool,fb_EV_duration)
            local Pyro_EV_Ignite=pyroblast_EV(PTheoretical_Ignite)-ignite_pool
            check_negative_pyro(Pyro_EV_Ignite,texture3,text3)
            if fontStrings[3] then
                fontStrings[3]:SetText(math.floor(Pyro_EV_Ignite))
                fontStrings[5]:SetText(math.floor(Pyro_EV_Ignite))
            end
            -- do this if you casted an instant and need to wait a gcd before casting.
            --print(EV_type)
            if EV_type == 2 then
                local gcd=getGCD()
                local Theoretical_Ignite2=check_EV_Leak_2(ignite_pool,fb_EV_duration,gcd)
                FB_EV_IGNITE=fireball_EV(Theoretical_Ignite2)-ignite_pool
                check_negative(FB_EV_IGNITE,texture2,text2)
                if fontStrings[2] then
                    fontStrings[2]:SetText(math.floor(FB_EV_IGNITE))
                    fontStrings[4]: SetText(math.floor(FB_EV_IGNITE))
                end
            end
            --print(FB_EV_IGNITE)
            --print("ignite reapplied")
        end
    end
    if subevent == "SPELL_AURA_REMOVED" and playerGUID == sourceGUID then
        local Ignite_fall=select(13,CombatLogGetCurrentEventInfo())
        local dest=select(8,CombatLogGetCurrentEventInfo())
        --print(dest) spell destination has to line up, so target switching doesn't become a nightmare
        local dguid=UnitGUID("target")
        if Ignite_fall=="Ignite" and dest==dguid then
            ignite_pool=0
            --print(subevent)
            FB_EV_IGNITE=fireball_EV(ignite_pool)
            check_negative(FB_EV_IGNITE,texture2,text2)
            Pyro_EV_Ignite=pyroblast_EV(ignite_pool)
            check_negative_pyro(Pyro_EV_Ignite,texture3,text3)
            if fontStrings[2] then
                fontStrings[2]: SetText(math.floor(FB_EV_IGNITE))
                fontStrings[4]: SetText(math.floor(FB_EV_IGNITE))
            end
            if fontStrings[3] then
                fontStrings[3]: SetText(math.floor(Pyro_EV_Ignite))
                fontStrings[5]: SetText(math.floor(Pyro_EV_Ignite))
            end
        end
    end
    if subevent == "SPELL_DAMAGE" then
        destGUID,_,_,_,_,spellName,_,amount,_,_,_,_,_,critical=select(8,CombatLogGetCurrentEventInfo())
        --print(amount)
        local dguid=UnitGUID("target")
        -- if ignite ticks, subtract the damage from the pool
        if spellName=="Ignite" and playerGUID == sourceGUID and destGUID==dguid then
            ignite_pool=ignite_pool-amount
            if ignite_pool<=0 then
                ignite_pool=0
            end
            if fontStrings[1] then
                fontStrings[1]:SetText(math.floor(ignite_pool))
            end
            --print(amount)
            --print("New Ignite after leak:")
            --print(ignite_pool)
        end 
        -- Calculate ignite damge
        if critical and valid_ignite_spells[spellName] and playerGUID == sourceGUID and destGUID==dguid then
            local destination=destGUID
            -- resets value if there are rounding errors
            if ignite_pool<100 then
                ignite_pool=0
            end
            mastery_ = (1 + (2.8 * GetMastery())/100)
            ignite=mastery_*amount*.4
            --print(ignite)
            ignite_pool=ignite+ignite_pool
            --print(ignite_pool)
            if fontStrings[1] then
                fontStrings[1]:SetText(math.floor(ignite_pool))
            end
            --print("add to pool working")
            -- add a ticker to see which subset of spells are used (instant or casted)
        end
        --changes the calculation call depending on predicted cast-sequence.
        if critical and instant_ignite_spells[spellName] and playerGUID == sourceGUID and destGUID==dguid then
            EV_type=2
        end
        if spellName=="Pyroblast!" then
            EV_type=2
        end
    end    
end)