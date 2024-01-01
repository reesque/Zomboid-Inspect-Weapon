-- @author Risky
-- Core file, contains all the event listeners and windows handler

require "ISUI/ISCollapsableWindow"
require "TimedActions/ISEquipWeaponAction"

riskyInspectWindow = nil
riskyShowPotentialAttachment = true

riskyUI = ISCollapsableWindow:derive("riskyUI")

function riskyUI:new(x, y, width, height)
    local o = {}
	o = ISCollapsableWindow:new(x, y, width, height)

    setmetatable(o, self)
    self.__index = self

    o.panelWidth = 0
    o.panelHeight = 0

    o.currentPrimaryItem = getPlayer():getPrimaryHandItem()
    o.itemWeight = getPlayer():getInventory():getCapacityWeight()
    o.itemCap = getPlayer():getInventory():getItems():size()

    o.weaponCondition = (getPlayer():getPrimaryHandItem():getCondition() * 100) / getPlayer():getPrimaryHandItem():getConditionMax()

    local weapon = getPlayer():getPrimaryHandItem()
    if (weapon:IsWeapon() and weapon:isRanged()) then
        if (weapon:isTwoHandWeapon()) then
            getPlayer():setVariable("IsInspectTwoHandedRanged", "true")
        else
            getPlayer():setVariable("IsInspectOneHandedRanged", "true")
        end
    end

	return o
end

function riskyUI:update()
    if self and self:getIsVisible() then
        if (self.currentPrimaryItem ~= getPlayer():getPrimaryHandItem()) then
            self:close()
        end

        if self.itemCap ~= getPlayer():getInventory():getItems():size() or 
                self.itemWeight ~= getPlayer():getInventory():getCapacityWeight() or
                self.weaponCondition ~= (getPlayer():getPrimaryHandItem():getCondition() * 100) / getPlayer():getPrimaryHandItem():getConditionMax() then
            self.itemCap = getPlayer():getInventory():getItems():size()
            self.itemWeight = getPlayer():getInventory():getCapacityWeight()
            self.weaponCondition = (getPlayer():getPrimaryHandItem():getCondition() * 100) / getPlayer():getPrimaryHandItem():getConditionMax()
            self:renderInventory()
        end
    end
end

function riskyUI:prerender()
    ISCollapsableWindow.prerender(self)

    if getPlayer():getPrimaryHandItem() ~= nil and getPlayer():getPrimaryHandItem():IsWeapon() then
        local weapon = getPlayer():getPrimaryHandItem()
        local conditionPerc = (weapon:getCondition() * 100) / weapon:getConditionMax()

        self:drawTexture(weapon:getTexture(), 20, 50, 1, 1, 1, 1)
        self:drawText(weapon:getDisplayName(), 65, 35, 1, 1, 1, 1, UIFont.Medium)

        local conditionText = ""
        if conditionPerc >= 100 and weapon:getHaveBeenRepaired() == 1 then
            conditionText = getText('IGUI_RISKY_CONDITION') .. ": " .. getText('IGUI_RISKY_PRISTINE')
        elseif conditionPerc <= 100 and conditionPerc > 50 then
            conditionText = getText('IGUI_RISKY_CONDITION') .. ": " .. getText('IGUI_RISKY_USED')
        elseif conditionPerc < 50 and conditionPerc > 30 then
            conditionText = getText('IGUI_RISKY_CONDITION') .. ": " .. getText('IGUI_RISKY_DAMAGED')
        else
            conditionText = getText('IGUI_RISKY_CONDITION') .. ": " .. getText('IGUI_RISKY_BADLY_DAMAGED')
        end
        self:drawText(conditionText, 65, 55, 1, 1, 1, 1, UIFont.Small)

        local repairText = ""
        if weapon:getHaveBeenRepaired() == 1 then
            repairText = getText('IGUI_RISKY_REPAIR_NONE')
        elseif weapon:getHaveBeenRepaired() > 1 and weapon:getHaveBeenRepaired() < 4 then
            repairText = getText('IGUI_RISKY_REPAIR_SLIGHTLY')
        else
            repairText = getText('IGUI_RISKY_REPAIR_HEAVILY')
        end
        self:drawText(repairText, 65, 70, 1, 1, 1, 1, UIFont.Small)
            
        if weapon:isRanged() then
            local attachTextMeasure = getTextManager():MeasureStringX(UIFont.Medium, getText('IGUI_RISKY_ATTACHMENTS'))
            if (getPlayer():getInventory():getFirstTagEvalRecurse("Screwdriver", predicateNotBroken)) then
                self:drawText("(", attachTextMeasure + 25, 100, 1, 1, 1, 1, UIFont.Medium)
                self:drawTextureScaled(getTexture("Item_Screwdriver"),  attachTextMeasure + 35, 103, 15, 15, 1.0, 1.0, 1.0, 1.0);
                self:drawText(")", attachTextMeasure + 55, 100, 1, 1, 1, 1, UIFont.Medium)
            end

            self:drawText(getText('IGUI_RISKY_ATTACHMENTS'), 20, 100, 1, 1, 1, 1, UIFont.Medium)

            local canon = getText('IGUI_RISKY_NONE')
            local clip = getText('IGUI_RISKY_NONE')
            local recoilPad = getText('IGUI_RISKY_NONE')
            local scope = getText('IGUI_RISKY_NONE')
            local sling = getText('IGUI_RISKY_NONE')
            local stock = getText('IGUI_RISKY_NONE')

            -- Canon
            if weapon:getCanon() ~= nil then
                canon = weapon:getCanon():getDisplayName()
            end
            self:drawText(canon, 70, 137, 1, 1, 1, 1, UIFont.Small)
            self:drawText(getText('IGUI_RISKY_CANON'), 70, 152, 1, 1, 1, 1, UIFont.Small)

            -- Clip - DISABLE UNTIL THEY INTRODUCE CLIP ATTACHMENT SLOT
            ---if weapon:getClip() ~= nil then
            ---    clip = weapon:getClip():getDisplayName()
            ---end
            if weapon:isContainsClip() then
                local tempContainer = ItemContainer.new("magazine", nil, nil, 10, 10)
                local magazine = tempContainer:AddItem(weapon:getMagazineType())
                tempContainer:clear()
                tempContainer = nil

                clip = magazine:getDisplayName()
            end
            self:drawText(clip, 70, 187, 1, 1, 1, 1, UIFont.Small)
            self:drawText(getText('IGUI_RISKY_CLIP'), 70, 202, 1, 1, 1, 1, UIFont.Small)

            -- Recoil Pad
            if weapon:getRecoilpad() ~= nil then
                recoilPad = weapon:getRecoilpad():getDisplayName()
            end
            self:drawText(recoilPad, 70, 237, 1, 1, 1, 1, UIFont.Small)
            self:drawText(getText('IGUI_RISKY_RECOIL_PAD'), 70, 252, 1, 1, 1, 1, UIFont.Small)

            local canonWidth, clipWidth, recoilPadWidth

            if weapon:getCanon() ~= nil then canonWidth = getTextManager():MeasureStringX(UIFont.Small, weapon:getCanon():getDisplayName()) else canonWidth = 0 end
            --if weapon:getClip() ~= nil then clipWidth = getTextManager():MeasureStringX(UIFont.Small, weapon:getClip():getDisplayName()) else clipWidth = 0 end
            if weapon:isContainsClip() then clipWidth = getTextManager():MeasureStringX(UIFont.Small, clip) else clipWidth = 0 end
            if weapon:getRecoilpad() ~= nil then recoilPadWidth = getTextManager():MeasureStringX(UIFont.Small, weapon:getRecoilpad():getDisplayName()) else recoilPadWidth = 0 end

            local leftWidth = math.max(getTextManager():MeasureStringX(UIFont.Small, getText('IGUI_RISKY_NONE')),
                                        getTextManager():MeasureStringX(UIFont.Small, getText('IGUI_RISKY_CANON')),
                                        getTextManager():MeasureStringX(UIFont.Small, getText('IGUI_RISKY_CLIP')),
                                        getTextManager():MeasureStringX(UIFont.Small, getText('IGUI_RISKY_RECOIL_PAD')),
                                        canonWidth, clipWidth, recoilPadWidth)

            -- Scope
            if weapon:getScope() ~= nil then
                scope = weapon:getScope():getDisplayName()
            end
            self:drawText(scope, leftWidth + 150, 137, 1, 1, 1, 1, UIFont.Small)
            self:drawText(getText('IGUI_RISKY_SCOPE'), leftWidth + 150, 152, 1, 1, 1, 1, UIFont.Small)

            -- Sling
            if weapon:getSling() ~= nil then
                sling = weapon:getSling():getDisplayName()
            end
            self:drawText(sling, leftWidth + 150, 187, 1, 1, 1, 1, UIFont.Small)
            self:drawText(getText('IGUI_RISKY_SLING'), leftWidth + 150, 202, 1, 1, 1, 1, UIFont.Small)

            -- Stock
            if weapon:getStock() ~= nil then
                stock= weapon:getStock():getDisplayName()
            end
            self:drawText(stock, leftWidth + 150, 237, 1, 1, 1, 1, UIFont.Small)
            self:drawText(getText('IGUI_RISKY_STOCK'), leftWidth + 150, 252, 1, 1, 1, 1, UIFont.Small)
        end
    else
        self:close()
    end
end

function riskyUI:renderInventory()
    self:clearChildren()

    -- Close button
    local closeButton = ISButton:new(3, 0, 15, 15, "", self, function(self, button) self:close() end);
	closeButton:initialise();
	closeButton.borderColor.a = 0.0;
	closeButton.backgroundColor.a = 0;
	closeButton.backgroundColorMouseOver.a = 0;
	closeButton:setImage(getTexture("media/ui/Dialog_Titlebar_CloseIcon.png"));
	self:addChild(closeButton);

    if getPlayer():getPrimaryHandItem() ~= nil and getPlayer():getPrimaryHandItem():IsWeapon() then
        local weapon = getPlayer():getPrimaryHandItem()
        local conditionPerc = (weapon:getCondition() * 100) / weapon:getConditionMax()

        local conditionText = ""
        if conditionPerc >= 100 and weapon:getHaveBeenRepaired() == 1 then
            conditionText = getText('IGUI_RISKY_CONDITION') .. ": " .. getText('IGUI_RISKY_PRISTINE')
        elseif conditionPerc <= 100 and conditionPerc > 50 then
            conditionText = getText('IGUI_RISKY_CONDITION') .. ": " .. getText('IGUI_RISKY_USED')
        elseif conditionPerc < 50 and conditionPerc > 30 then
            conditionText = getText('IGUI_RISKY_CONDITION') .. ": " .. getText('IGUI_RISKY_DAMAGED')
        else
            conditionText = getText('IGUI_RISKY_CONDITION') .. ": " .. getText('IGUI_RISKY_BADLY_DAMAGED')
        end

        local repairText = ""
        if weapon:getHaveBeenRepaired() == 1 then
            repairText = getText('IGUI_RISKY_REPAIR_NONE')
        elseif weapon:getHaveBeenRepaired() > 1 and weapon:getHaveBeenRepaired() < 4 then
            repairText = getText('IGUI_RISKY_REPAIR_SLIGHTLY')
        else
            repairText = getText('IGUI_RISKY_REPAIR_HEAVILY')
        end

        -- Repair icon
        local fixingList = FixingManager.getFixes(weapon)

        if not fixingList:isEmpty() and conditionPerc < 100 then
            local repairButton = ISButton:new(66 + getTextManager():MeasureStringX(UIFont.Small, repairText), 70, 15, 15, "", self, function(self, button)
                local context = ISContextMenu.get(getPlayer():getPlayerNum(), getMouseX(), getMouseY())
                local fixOption = context:addOption(getText("ContextMenu_Repair"), getPlayer():getInventory():getItems(), nil);
                local subMenuFix = ISContextMenu:getNew(context);
                context:addSubMenu(fixOption, subMenuFix);
                ISInventoryPaneContextMenu.buildFixingMenu(weapon, getPlayer():getPlayerNum(), fixingList:get(0), fixOption, subMenuFix)
                context:addToUIManager()
            end);
            repairButton:initialise();
            repairButton.borderColor.a = 0.0;
            repairButton.backgroundColor.a = 0;
            repairButton.backgroundColorMouseOver.a = 0;
            repairButton:setImage(getTexture("media/ui/Panel_info_button.png"));
            self:addChild(repairButton);
        end

        self.panelWidth = math.max(getTextManager():MeasureStringX(UIFont.Medium, weapon:getDisplayName()),
                                    getTextManager():MeasureStringX(UIFont.Small, conditionText),
                                    getTextManager():MeasureStringX(UIFont.Small, repairText) + 17) + 100

        if (weapon:isRanged()) then
            -- Width/Height
            self.panelHeight = 110
            self:setHeight(self.panelHeight)

            local itemList = getPlayer():getInventory():getItems()
            local containerCount = 1
            allContainers = {}
        
            -- Probe containers
            for i=0,itemList:size() - 1,1 do
                if instanceof(itemList:get(i), 'InventoryContainer') and (itemList:get(i):isEquipped()) then
                    table.insert(allContainers, itemList:get(i))
                    containerCount = containerCount + 1
                end
            end

            -- Not an ideal way to get the object loose ammo and box ammo object, but for the time being...
            local tempContainer = ItemContainer.new("ammoCount", nil, nil, 10, 10)
            local looseAmmo = tempContainer:AddItem(weapon:getAmmoType())
            local boxAmmo = tempContainer:AddItem(weapon:getAmmoBox())

            local looseAmmoCount = getPlayer():getInventory():getItemCount(weapon:getAmmoType())
            local boxAmmoCount = getPlayer():getInventory():getItemCount(weapon:getAmmoBox())

            if (containerCount > 1) then
                for i=1,containerCount - 1 do
                    looseAmmoCount = looseAmmoCount + allContainers[i]:getInventory():getItemCount(weapon:getAmmoType())
                    boxAmmoCount = boxAmmoCount + allContainers[i]:getInventory():getItemCount(weapon:getAmmoBox())
                end
            end

            -- Loose ammo
            item = ammoButton:new(self.panelWidth + 10, 40, 50, 50, looseAmmo, looseAmmoCount)
            item:bringToTop()
            self:addChild(item)

            -- Box ammo
            item = ammoButton:new(self.panelWidth + 65, 40, 50, 50, boxAmmo, boxAmmoCount)
            item:bringToTop()
            self:addChild(item)

            tempContainer:clear()
            tempContainer = nil

            self.panelWidth = self.panelWidth + 130
        
            self.panelHeight = self.panelHeight + 180

            -- Canon
            item = attachmentButton:new(20, 130, 40, 40, weapon:getCanon(), weapon, WeaponPart.TYPE_CANON)
            item:bringToTop()
            self:addChild(item)

            -- Clip - DISABLE UNTIL THEY INTRODUCE CLIP ATTACHMENTS
            --item = attachmentButton:new(20, 180, 40, 40, weapon:getClip(), weapon, WeaponPart.TYPE_CLIP)
            --item:bringToTop()
            --self:addChild(item)
            local magazine = nil
            if weapon:isContainsClip() then
                local tempContainer = ItemContainer.new("magazine", nil, nil, 10, 10)
                magazine = tempContainer:AddItem(weapon:getMagazineType())
                tempContainer:clear()
                tempContainer = nil
            end
            item = magazineButton:new(20, 180, 40, 40, magazine, weapon)
            item:bringToTop()
            self:addChild(item)

            -- Recoil Pad
            item = attachmentButton:new(20, 230, 40, 40, weapon:getRecoilpad(), weapon, WeaponPart.TYPE_RECOILPAD)
            item:bringToTop()
            self:addChild(item)

            local canonWidth, clipWidth, recoilPadWidth, scopeWidth, slingWidth, stockWidth

            if weapon:getCanon() ~= nil then canonWidth = getTextManager():MeasureStringX(UIFont.Small, weapon:getCanon():getDisplayName()) else canonWidth = 0 end
            --if weapon:getClip() ~= nil then clipWidth = getTextManager():MeasureStringX(UIFont.Small, weapon:getClip():getDisplayName()) else clipWidth = 0 end
            if weapon:isContainsClip() then clipWidth = getTextManager():MeasureStringX(UIFont.Small, magazine:getDisplayName()) else clipWidth = 0 end
            if weapon:getRecoilpad() ~= nil then recoilPadWidth = getTextManager():MeasureStringX(UIFont.Small, weapon:getRecoilpad():getDisplayName()) else recoilPadWidth = 0 end

            local leftWidth = math.max(getTextManager():MeasureStringX(UIFont.Small, getText('IGUI_RISKY_NONE')),
                                        getTextManager():MeasureStringX(UIFont.Small, getText('IGUI_RISKY_CANON')),
                                        getTextManager():MeasureStringX(UIFont.Small, getText('IGUI_RISKY_CLIP')),
                                        getTextManager():MeasureStringX(UIFont.Small, getText('IGUI_RISKY_RECOIL_PAD')),
                                        canonWidth, clipWidth, recoilPadWidth)

            -- Scope
            item = attachmentButton:new(leftWidth + 100, 130, 40, 40, weapon:getScope(), weapon, WeaponPart.TYPE_SCOPE)
            item:bringToTop()
            self:addChild(item)

            -- Sling
            item = attachmentButton:new(leftWidth + 100, 180, 40, 40, weapon:getSling(), weapon, WeaponPart.TYPE_SLING)
            item:bringToTop()
            self:addChild(item)

            -- Stock
            item = attachmentButton:new(leftWidth + 100, 230, 40, 40, weapon:getStock(), weapon, WeaponPart.TYPE_STOCK)
            item:bringToTop()
            self:addChild(item)

            if weapon:getScope() ~= nil then scopeWidth = getTextManager():MeasureStringX(UIFont.Small, weapon:getScope():getDisplayName()) else scopeWidth = 0 end
            if weapon:getSling() ~= nil then slingWidth = getTextManager():MeasureStringX(UIFont.Small, weapon:getSling():getDisplayName()) else slingWidth = 0 end
            if weapon:getStock() ~= nil then stockWidth = getTextManager():MeasureStringX(UIFont.Small, weapon:getStock():getDisplayName()) else stockWidth = 0 end

            local rightWidth = math.max(getTextManager():MeasureStringX(UIFont.Small, getText('IGUI_RISKY_NONE')),
                                        getTextManager():MeasureStringX(UIFont.Small, getText('IGUI_RISKY_SCOPE')),
                                        getTextManager():MeasureStringX(UIFont.Small, getText('IGUI_RISKY_SLING')),
                                        getTextManager():MeasureStringX(UIFont.Small, getText('IGUI_RISKY_STOCK')),
                                        scopeWidth, slingWidth, stockWidth)

            self.panelWidth = math.max(self.panelWidth, leftWidth + rightWidth + 175)
        else
            self.panelHeight = 110
        end
    end

    self:setWidth(self.panelWidth)
    self:setHeight(self.panelHeight)
end

function riskyUI:close()
    getPlayer():getModData().inspectWindowPos = {self.x, self.y}

    getPlayer():setVariable("IsInspectOneHandedRanged", "false")
    getPlayer():setVariable("IsInspectTwoHandedRanged", "false")

    self:setVisible(false)
    riskyInspectWindow = nil
end

riskyUI.onMove = function()
    if riskyInspectWindow ~= nil and riskyInspectWindow:getIsVisible() then
        riskyInspectWindow:close()
        riskyInspectWindow = nil
    end
end

Events.OnPlayerMove.Add(riskyUI.onMove)

riskyUI.createWorldMenuEntry = function(_player, _context, _worldObjects)
    if getPlayer():getPrimaryHandItem() ~= nil and getPlayer():getPrimaryHandItem():IsWeapon() then
        _context:addOption(getText('IGUI_RISKY_INSPECT_WEAPON'), worldobjects, function() ISTimedActionQueue.add(riskyInspectAction:new(getPlayer(), 1)) end)
    end
end

Events.OnFillWorldObjectContextMenu.Add(riskyUI.createWorldMenuEntry);

riskyUI.createInventoryMenuEntry = function(_player, _context, _items)local container = nil
    local resItems = {}
    for i,v in ipairs(_items) do
        if not instanceof(v, "InventoryItem") then
            for _, it in ipairs(v.items) do
                resItems[it] = true
            end
            container = v.items[1]:getContainer()
        else
            resItems[v] = true
            container = v:getContainer()
        end
    end

    local inspectSubMenu = _context:getNew(_context)
    local entryCount = 0

    for v, _ in pairs(resItems) do
        if v:IsWeapon() then
            inspectSubMenu:addOption(v:getName(), v, function() 
                ISTimedActionQueue.add(ISInventoryTransferAction:new(getPlayer(), v, v:getContainer(), getPlayer():getInventory()))
                ISTimedActionQueue.add(ISEquipWeaponAction:new(getPlayer(), v, 50, true, v:isTwoHandWeapon()));
                ISTimedActionQueue.add(riskyInspectAction:new(getPlayer(), 1));
            end)

            entryCount = entryCount + 1
        end
    end
           
    if entryCount ~= 0 then
        local option = _context:addOption(getText('IGUI_RISKY_INSPECT_WEAPON'))
        _context:addSubMenu(option, inspectSubMenu)
    end
end

Events.OnFillInventoryObjectContextMenu.Add(riskyUI.createInventoryMenuEntry)

riskyUI.onAttack = function(_character, _weapon)
    if riskyInspectWindow ~= nil and riskyInspectWindow:getIsVisible() then
        riskyInspectWindow:close()
        riskyInspectWindow = nil
    end
end

Events.OnWeaponSwing.Add(riskyUI.onAttack)

-- Windows position
riskyUI.onGameStart = function()
    if (getPlayer():getModData().inspectWindowPos == nil) then
        getPlayer():getModData().inspectWindowPos = {100, 100}
    end
end

Events.OnGameStart.Add(riskyUI.onGameStart)

riskyUI.onCreatePlayer = function(playerIndex, player)
    if (player:getModData().inspectWindowPos == nil) then
        player:getModData().inspectWindowPos = {100, 100}
    end
end

Events.OnCreatePlayer.Add(riskyUI.onCreatePlayer)

-- KEYBINDING
riskyUI.initKeyBind = function()
	table.insert(keyBinding, { value = "[OPTION_INSPECT_WEAPON]" } );
	table.insert(keyBinding, { value = "OPTION_INSPECT_CURRENT_WEAPON", key = 39 } );
end
Events.OnGameBoot.Add(riskyUI.initKeyBind);

riskyUI.inspectOnKey = function(_keyPressed)
    if _keyPressed == getCore():getKey("OPTION_INSPECT_CURRENT_WEAPON") then
        local weapon = getPlayer():getPrimaryHandItem()
        if (weapon ~= nil and weapon:IsWeapon()) then
            ISTimedActionQueue.add(riskyInspectAction:new(getPlayer(), 1))
        end
    end
end

Events.OnKeyPressed.Add(riskyUI.inspectOnKey)

-- SELECT ATTACHMENT PANE

selectAttachmentPane = ISPanel:derive("selectAttachmentPane")

function selectAttachmentPane:new(x,y,category)
    local o = {}
    o = ISPanel:new(x, y, 40 * 5 + 20, 126);

    setmetatable(o, self)
    self.__index = self
    
    o.category = category
    o.backgroundColor = {r=0, g=0, b=0, a=1};
    o.borderColor = {r=0.9, g=0.9, b=0.9, a=0.7};

    o.currentPrimaryItem = getPlayer():getPrimaryHandItem()
    o.elements = {}

    if (riskyShowPotentialAttachment) then
        o.potentialAttachment = {}
        local items = getAllItems();
        for i=0,items:size()-1 do
            local item = items:get(i);

            if not item:getObsolete() and not item:isHidden() and item:getTypeString() == "WeaponPart" then
                o.potentialAttachment[item:getFullName()] = 1
            end
        end
    end

    return o
end

function selectAttachmentPane:prerender()
	self:setStencilRect(0,0,self.width, self.height);
    self:drawRect(-self:getXScroll(), -self:getYScroll(), self.width, self.height, self.backgroundColor.a, self.backgroundColor.r, self.backgroundColor.g, self.backgroundColor.b);
end

function selectAttachmentPane:render()
    self:clearStencilRect();
	self:drawRectBorder(-self:getXScroll(), -self:getYScroll(), self.width, self.height, self.borderColor.a, self.borderColor.r, self.borderColor.g, self.borderColor.b);
end

function selectAttachmentPane:createChildren()
    self:addScrollBars(false)
	self:setScrollWithParent(false)
	self:setScrollChildren(true)
end

function selectAttachmentPane:onMouseWheel(del)
	self:setYScroll(self:getYScroll() - (del*42))
	return true;
end

function selectAttachmentPane:update()
    if self and self:getIsVisible() then
        if (self.currentPrimaryItem ~= getPlayer():getPrimaryHandItem() or riskyInspectWindow == nil) then
            self:close()
        end

        if self.itemCap ~= getPlayer():getInventory():getItems():size() or 
            self.itemWeight ~= getPlayer():getInventory():getCapacityWeight() then
            self.itemCap = getPlayer():getInventory():getItems():size()
            self.itemWeight = getPlayer():getInventory():getCapacityWeight()

            if (#self.elements ~= 0) then
                for i=1,#self.elements do
                    self:removeChild(self.elements[i])
                end
            end

            self:renderInventory()
        end
    end
end

function selectAttachmentPane:renderInventory()
    local weapon = getPlayer():getPrimaryHandItem()
    if getPlayer():getPrimaryHandItem() ~= nil and getPlayer():getPrimaryHandItem():IsWeapon() then
        local weaponParts = getPlayer():getInventory():getItemsFromCategory("WeaponPart");

        local alreadyDoneList = {};
        local itemNum = 0
        local rowCount = -1
        for i=0, weaponParts:size() - 1 do
            local part = weaponParts:get(i);
            if part:getMountOn():contains(weapon:getFullType()) and not alreadyDoneList[part:getName()] then
                if (part:getPartType() == self.category) then
                    alreadyDoneList[part:getName()] = true;

                    if (math.fmod(itemNum, 5) == 0) then
                        rowCount = rowCount + 1
                    end

                    local x = 2 + 41 * math.fmod(itemNum, 5)
                    local y = 2 + 41 * rowCount

                    if riskyShowPotentialAttachment then
                        self.potentialAttachment[part:getFullType()] = nil
                    end

                    local item = addAttachmentButton:new(x, y, 40, 40, part, weapon, true)

                    table.insert(self.elements, item)
                    item:bringToTop()
                    self:addChild(item)

                    itemNum = itemNum + 1
                end
            end
        end

        if riskyShowPotentialAttachment then
            local tempContainer = ItemContainer.new("potentialAttachment", nil, nil, 10, 10)
            for k,v in pairs(self.potentialAttachment) do
                local potentialPart = tempContainer:AddItem(k)

                if potentialPart:getMountOn():contains(weapon:getFullType()) and potentialPart:getPartType() == self.category then
                    if (math.fmod(itemNum, 5) == 0) then
                        rowCount = rowCount + 1
                    end

                    local x = 2 + 41 * math.fmod(itemNum, 5)
                    local y = 2 + 41 * rowCount

                    local item = addAttachmentButton:new(x, y, 40, 40, potentialPart, weapon, false)

                    table.insert(self.elements, item)
                    item:bringToTop()
                    self:addChild(item)

                    itemNum = itemNum + 1
                end

                tempContainer:clear()
            end
            tempContainer = nil
        end

        self:setScrollHeight(42 * (rowCount + 1))

        if (self:getHeight() >= self:getScrollHeight()) then
            self:setWidth(40 * 5 + 8)
        end
    end
end

function selectAttachmentPane:close()
    self:setVisible(false)
end

function selectAttachmentPane:onMouseDownOutside(x, y)
    if self:getIsVisible() and not self.vscroll:isMouseOver() then
        self:close()
    end
end

-- SELECT MAGAZINE PANE

selectMagazinePane = ISPanel:derive("selectMagazinePane")

function selectMagazinePane:new(x,y,weapon)
    local o = {}
    o = ISPanel:new(x, y, 40 * 5 + 20, 126);

    setmetatable(o, self)
    self.__index = self
    
    o.weapon = weapon
    o.backgroundColor = {r=0, g=0, b=0, a=1};
    o.borderColor = {r=0.9, g=0.9, b=0.9, a=0.7};
    
    o.currentPrimaryItem = getPlayer():getPrimaryHandItem()
    o.elements = {}

    return o
end

function selectMagazinePane:prerender()
	self:setStencilRect(0,0,self.width, self.height)
    self:drawRect(-self:getXScroll(), -self:getYScroll(), self.width, self.height, self.backgroundColor.a, self.backgroundColor.r, self.backgroundColor.g, self.backgroundColor.b)
end

function selectMagazinePane:render()
    self:clearStencilRect()
	self:drawRectBorder(-self:getXScroll(), -self:getYScroll(), self.width, self.height, self.borderColor.a, self.borderColor.r, self.borderColor.g, self.borderColor.b)
end

function selectMagazinePane:createChildren()
    self:addScrollBars(false)
	self:setScrollWithParent(false)
	self:setScrollChildren(true)
end

function selectMagazinePane:onMouseWheel(del)
	self:setYScroll(self:getYScroll() - (del*42))
	return true;
end

function selectMagazinePane:update()
    if self and self:getIsVisible() then
        if (self.currentPrimaryItem ~= getPlayer():getPrimaryHandItem() or riskyInspectWindow == nil) then
            self:close()
        end

        if self.itemCap ~= getPlayer():getInventory():getItems():size() or 
            self.itemWeight ~= getPlayer():getInventory():getCapacityWeight() then
            self.itemCap = getPlayer():getInventory():getItems():size()
            self.itemWeight = getPlayer():getInventory():getCapacityWeight()

            if (#self.elements ~= 0) then
                for i=1,#self.elements do
                    self:removeChild(self.elements[i])
                end
            end

            self:renderInventory()
        end
    end
end

function selectMagazinePane:renderInventory()
    local weapon = getPlayer():getPrimaryHandItem()
    local magList = getPlayer():getInventory():getItemsFromFullType(self.weapon:getMagazineType())
    if magList:size() > 0 then
        local itemNum = 0
        local rowCount = -1
        for i=0, magList:size() - 1 do
            if (math.fmod(itemNum, 5) == 0) then
                rowCount = rowCount + 1
            end

            local x = 2 + 41 * math.fmod(itemNum, 5)
            local y = 2 + 41 * rowCount

            local item = addMagazineButton:new(x, y, 40, 40, magList:get(i), weapon)

            table.insert(self.elements, item)
            item:bringToTop()
            self:addChild(item)

            itemNum = itemNum + 1
        end

        self:setScrollHeight(42 * (rowCount + 1))

        if (self:getHeight() >= self:getScrollHeight()) then
            self:setWidth(40 * 5 + 8)
        end
    end
end

function selectMagazinePane:close()
    self:setVisible(false)
end

function selectMagazinePane:onMouseDownOutside(x, y)
    if self:getIsVisible() and not self.vscroll:isMouseOver() then
        self:close()
    end
end