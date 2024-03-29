-- @author Risky
-- Custom buttons for UI on windows/panels

require "ISUI/ISButton"
require "ISUI/ISPanel"

function predicateNotBroken(item)
	return not item:isBroken()
end

ammoButton = ISButton:derive("ammoButton")

function ammoButton:new (x, y, w, h, slotItem, stackAmount)
    local o = {}
    o = ISButton:new(x, y, w, h)

    setmetatable(o, self)
    self.__index = self

    o.stackAmount = stackAmount

    o.currentTint = ImmutableColor.new(1.0, 1.0, 1.0, 1.0)

    o.borderColor.r = 0.0
    o.borderColor.g = 0.0
    o.borderColor.b = 0.0
    o.borderColor.a = 0.0

    o.backgroundColor.r = 0.5
    o.backgroundColor.g = 0.5
    o.backgroundColor.b = 0.5
    o.backgroundColor.a = 0.3

    o.backgroundColorMouseOver.r = 0.5
    o.backgroundColorMouseOver.g = 0.5
    o.backgroundColorMouseOver.b = 0.5
    o.backgroundColorMouseOver.a = 0.3

    if slotItem then
        o.backgroundColorMouseOver.a = 0.8
        o.toolTip = ISToolTipInv:new(slotItem)
        o.toolTip:setOwner(o)
        o.toolTip:setVisible(false)
        o.toolTip:addToUIManager()

        -- Texture related
        o:setImage(slotItem:getTexture())
        
        local visual = slotItem:getVisual()
        o.tint = nil
        if visual then
            o.tint = visual:getTint(slotItem:getClothingItem())
            o.currentTint = visual:getTint(slotItem:getClothingItem())
        end

        if o.tint ~= nil then
            o:setTextureRGBA(o.tint:getRedFloat(), o.tint:getGreenFloat(), o.tint:getBlueFloat(), 1.0)
        end
        
        o.slotItem = slotItem
    end

    o:bringToTop();

    return o
end

function ammoButton:render()
    ISButton.render(self)

    if self.slotItem then
        self:drawText(tostring(self.stackAmount), 4, 0, 1.0, 1.0, 1.0, 1.0)

        -- Texture related
        self:setImage(self.slotItem:getTexture())

        if self.currentTint ~= nil then
            self:setTextureRGBA(self.currentTint:getRedFloat(), self.currentTint:getGreenFloat(), self.currentTint:getBlueFloat(), self.currentTint:getAlphaFloat())
        end

        if self:isMouseOver() then
            self.toolTip:setVisible(true)
            self.toolTip:bringToTop()
        else
            self.toolTip:setVisible(false)
        end
    end
end

function ammoButton:close()
    ISButton.close(self)
    self.toolTip:setVisible(false)
    self.toolTip:removeFromUIManager()
end

-- Attachment Button

attachmentButton = ISButton:derive("attachmentButton")

function attachmentButton:new (x, y, w, h, slotItem, attachingTo, attachmentType)
    local o = {}
    o = ISButton:new(x, y, w, h)

    setmetatable(o, self)
    self.__index = self

    o.currentTint = ImmutableColor.new(1.0, 1.0, 1.0, 1.0)

    o.borderColor.r = 0.0
    o.borderColor.g = 0.0
    o.borderColor.b = 0.0
    o.borderColor.a = 0.0

    o.backgroundColor.r = 0.5
    o.backgroundColor.g = 0.5
    o.backgroundColor.b = 0.5
    o.backgroundColor.a = 0.3

    o.backgroundColorMouseOver.r = 0.5
    o.backgroundColorMouseOver.g = 0.5
    o.backgroundColorMouseOver.b = 0.5
    o.backgroundColorMouseOver.a = 0.8

    o.attachingTo = attachingTo
    o.attachmentType = attachmentType

    if slotItem then
        o.toolTip = ISToolTipInv:new(slotItem)
        o.toolTip:setOwner(o)
        o.toolTip:setVisible(false)
        o.toolTip:addToUIManager()

        -- Texture related
        o:setImage(slotItem:getTexture())
        
        local visual = slotItem:getVisual()
        o.tint = nil
        if visual then
            o.tint = visual:getTint(slotItem:getClothingItem())
            o.currentTint = visual:getTint(slotItem:getClothingItem())
        end

        if o.tint ~= nil then
            o:setTextureRGBA(o.tint:getRedFloat(), o.tint:getGreenFloat(), o.tint:getBlueFloat(), 1.0)
        end
        
        o.slotItem = slotItem
    end

    o:bringToTop();

    -- Joypad
    o.isJoypadFocused = false

    return o
end

function attachmentButton:render()
    ISButton.render(self)

    if self:isMouseOver() == false then
        if self.isJoypadFocused then
            self.backgroundColor.a = 0.8
            if self.slotItem then
                self.toolTip.followMouse = false
                self.toolTip:setX(80)
                self.toolTip:setY(30)
                self.toolTip:setVisible(true)
                self.toolTip:bringToTop()
            end
        else
            self.backgroundColor.a = 0.3
            if self.slotItem then
                self.toolTip.followMouse = false
                self.toolTip:setVisible(false)
            end
        end
    end

    if self.slotItem then
        -- Texture related
        self:setImage(self.slotItem:getTexture())

        if self.currentTint ~= nil then
            self:setTextureRGBA(self.currentTint:getRedFloat(), self.currentTint:getGreenFloat(), self.currentTint:getBlueFloat(), self.currentTint:getAlphaFloat())
        end

        if not self.isJoypadFocused then
            if self:isMouseOver() then
                self.toolTip.followMouse = true
                self.toolTip:setVisible(true)
                self.toolTip:bringToTop()
            else
                self.toolTip.followMouse = true
                self.toolTip:setVisible(false)
            end
        end
    end
end

function attachmentButton:onMouseDoubleClick()
    if self.slotItem then
        ISTimedActionQueue.add(ISRemoveWeaponUpgrade:new(getPlayer(), self.attachingTo, self.slotItem, 50))
    end
end

function attachmentButton:onMouseUp()
    if self.slotItem == nil then
        local screwdriver = getPlayer():getInventory():getFirstTagEvalRecurse("Screwdriver", predicateNotBroken)
        if screwdriver then
            local pane = selectAttachmentPane:new(riskyInspectWindow:getX() + self:getX() + 43, riskyInspectWindow:getY() + self:getY() - 3, self.attachmentType)
            pane:addToUIManager()
            pane:bringToTop()
        end
    end
end

function attachmentButton:joypadConfirm()
    if self.slotItem then
        ISTimedActionQueue.add(ISRemoveWeaponUpgrade:new(getPlayer(), self.attachingTo, self.slotItem, 50))
    else
        local screwdriver = getPlayer():getInventory():getFirstTagEvalRecurse("Screwdriver", predicateNotBroken)
        if screwdriver then
            local pane = selectAttachmentPane:new(riskyInspectWindow:getX() + self:getX() + 43, riskyInspectWindow:getY() + self:getY() - 3, self.attachmentType)
            pane:addToUIManager()
            pane:bringToTop()

            setJoypadFocus(getPlayer():getPlayerNum(), pane)
        end
    end
end

function attachmentButton:joypadPrompt()
    if self.slotItem then
        return getText('IGUI_RISKY_DETACH')
    else
        return getText('IGUI_RISKY_ATTACH')
    end
end

function attachmentButton:close()
    ISButton.close(self)
    self.toolTip:setVisible(false)
    self.toolTip:removeFromUIManager()
end

-- Add Attachment Button

addAttachmentButton = ISButton:derive("addAttachmentButton")

function addAttachmentButton:new (x, y, w, h, slotItem, attachingTo, enabled)
    local o = {}
    o = ISButton:new(x, y, w, h)

    setmetatable(o, self)
    self.__index = self

    o.enabled = enabled

    o.borderColor.r = 0.0
    o.borderColor.g = 0.0
    o.borderColor.b = 0.0
    o.borderColor.a = 0.0

    o.backgroundColor.r = 0.5
    o.backgroundColor.g = 0.5
    o.backgroundColor.b = 0.5
    o.backgroundColor.a = 0.3

    o.backgroundColorMouseOver.r = 0.5
    o.backgroundColorMouseOver.g = 0.5
    o.backgroundColorMouseOver.b = 0.5

    if enabled then
        o.backgroundColorMouseOver.a = 0.8
        o.currentTint = ImmutableColor.new(1.0, 1.0, 1.0, 1.0)
    else
        o.backgroundColorMouseOver.a = 0.3
        o.currentTint = ImmutableColor.new(1.0, 1.0, 1.0, 0.3)
    end

    o.attachingTo = attachingTo
    o.isJoypadFocused = false

    if slotItem then
        o.toolTip = ISToolTipInv:new(slotItem)
        o.toolTip:setOwner(o)
        o.toolTip:setVisible(false)
        o.toolTip:addToUIManager()

        -- Texture related
        o:setImage(slotItem:getTexture())
        
        local visual = slotItem:getVisual()
        o.tint = nil
        if visual then
            o.tint = visual:getTint(slotItem:getClothingItem())
            o.currentTint = visual:getTint(slotItem:getClothingItem())

            if not enabled then
                o.currentTint.a = 0.3
            end
        end

        if o.tint ~= nil then
            if enabled then
                o:setTextureRGBA(o.tint:getRedFloat(), o.tint:getGreenFloat(), o.tint:getBlueFloat(), 1.0)
            else
                o:setTextureRGBA(o.tint:getRedFloat(), o.tint:getGreenFloat(), o.tint:getBlueFloat(), 0.3)
            end
        end
        
        o.slotItem = slotItem
    end

    o:bringToTop();

    return o
end

function addAttachmentButton:render()
    ISButton.render(self)

    if self:isMouseOver() == false then
        if self.isJoypadFocused then
            self.backgroundColor.a = 0.8
            if self.slotItem then
                self.toolTip.followMouse = false
                self.toolTip:setX(80)
                self.toolTip:setY(30)
                self.toolTip:setVisible(true)
                self.toolTip:bringToTop()
            end
        else
            self.backgroundColor.a = 0.3
            if self.slotItem then
                self.toolTip.followMouse = false
                self.toolTip:setVisible(false)
            end
        end
    end

    if self.slotItem then
        -- Texture related
        self:setImage(self.slotItem:getTexture())

        if self.currentTint ~= nil then
            self:setTextureRGBA(self.currentTint:getRedFloat(), self.currentTint:getGreenFloat(), self.currentTint:getBlueFloat(), self.currentTint:getAlphaFloat())
        end

        if not self.isJoypadFocused then
            if self:isMouseOver() then
                self.toolTip.followMouse = true
                self.toolTip:setVisible(true)
                self.toolTip:bringToTop()
            else
                self.toolTip.followMouse = true
                self.toolTip:setVisible(false)
            end
        end
    end
end

function addAttachmentButton:onMouseDown()
    if self.slotItem and self.enabled then
        local screwdriver = getPlayer():getInventory():getFirstTagEvalRecurse("Screwdriver", predicateNotBroken)
        if screwdriver then
            ISTimedActionQueue.add(ISUpgradeWeapon:new(getPlayer(), self.attachingTo, self.slotItem, 50));
            ISTimedActionQueue.add(ISEquipWeaponAction:new(getPlayer(), self.attachingTo, 50, true, self.attachingTo:isTwoHandWeapon()))
        end
    end
end

function addAttachmentButton:close()
    ISButton.close(self)
    self.toolTip:setVisible(false)
    self.toolTip:removeFromUIManager()
end

function addAttachmentButton:joypadConfirm()
    if self.slotItem and self.enabled then
        local screwdriver = getPlayer():getInventory():getFirstTagEvalRecurse("Screwdriver", predicateNotBroken)
        if screwdriver then
            ISTimedActionQueue.add(ISUpgradeWeapon:new(getPlayer(), self.attachingTo, self.slotItem, 50));
            ISTimedActionQueue.add(ISEquipWeaponAction:new(getPlayer(), self.attachingTo, 50, true, self.attachingTo:isTwoHandWeapon()))
        end
    end
end

function addAttachmentButton:joypadPrompt()
    if self.slotItem and self.enabled then
        return getText('IGUI_RISKY_ATTACH')
    else
        return nil
    end
end

-- Magazine Button

magazineButton = ISButton:derive("magazineButton")

function magazineButton:new (x, y, w, h, slotItem, attachingTo)
    local o = {}
    o = ISButton:new(x, y, w, h)

    setmetatable(o, self)
    self.__index = self

    o.currentTint = ImmutableColor.new(1.0, 1.0, 1.0, 1.0)

    o.borderColor.r = 0.0
    o.borderColor.g = 0.0
    o.borderColor.b = 0.0
    o.borderColor.a = 0.0

    o.backgroundColor.r = 0.5
    o.backgroundColor.g = 0.5
    o.backgroundColor.b = 0.5
    o.backgroundColor.a = 0.3

    o.backgroundColorMouseOver.r = 0.5
    o.backgroundColorMouseOver.g = 0.5
    o.backgroundColorMouseOver.b = 0.5
    o.backgroundColorMouseOver.a = 0.8

    o.attachingTo = attachingTo

    o.isJoypadFocused = false

    if slotItem then
        o.toolTip = ISToolTipInv:new(slotItem)
        o.toolTip:setOwner(o)
        o.toolTip:setVisible(false)
        o.toolTip:addToUIManager()

        -- Texture related
        o:setImage(slotItem:getTexture())
        
        local visual = slotItem:getVisual()
        o.tint = nil
        if visual then
            o.tint = visual:getTint(slotItem:getClothingItem())
            o.currentTint = visual:getTint(slotItem:getClothingItem())
        end

        if o.tint ~= nil then
            o:setTextureRGBA(o.tint:getRedFloat(), o.tint:getGreenFloat(), o.tint:getBlueFloat(), o.tint:getAlphaFloat())
        end
        
        o.slotItem = slotItem
    end

    o:bringToTop();

    return o
end

function magazineButton:render()
    ISButton.render(self)

    if self:isMouseOver() == false then
        if self.isJoypadFocused then
            self.backgroundColor.a = 0.8
            if self.slotItem then
                self.toolTip.followMouse = false
                self.toolTip:setX(80)
                self.toolTip:setY(30)
                self.toolTip:setVisible(true)
                self.toolTip:bringToTop()
            end
        else
            self.backgroundColor.a = 0.3
            if self.slotItem then
                self.toolTip.followMouse = false
                self.toolTip:setVisible(false)
            end
        end
    end

    if self.slotItem then
        self:drawText(tostring(self.attachingTo:getCurrentAmmoCount()), 4, 0, 1.0, 1.0, 1.0, 1.0)

        -- Texture related
        self:setImage(self.slotItem:getTexture())

        if self.currentTint ~= nil then
            self:setTextureRGBA(self.currentTint:getRedFloat(), self.currentTint:getGreenFloat(), self.currentTint:getBlueFloat(), self.currentTint:getAlphaFloat())
        end

        if not self.isJoypadFocused then
            if self:isMouseOver() then
                self.toolTip.followMouse = true
                self.toolTip:setVisible(true)
                self.toolTip:bringToTop()
            else
                self.toolTip.followMouse = true
                self.toolTip:setVisible(false)
            end
        end
    end
end

function magazineButton:onMouseDoubleClick()
    if self.slotItem then
        ISTimedActionQueue.add(ISEjectMagazine:new(getPlayer(), self.attachingTo))
    end
end

function magazineButton:onMouseUp()
    if self.slotItem == nil then
        local pane = selectMagazinePane:new(riskyInspectWindow:getX() + self:getX() + 43, riskyInspectWindow:getY() + self:getY() - 3, self.attachingTo)
        pane:addToUIManager()
        pane:bringToTop()
    end
end

function magazineButton:close()
    ISButton.close(self)
    self.toolTip:setVisible(false)
    self.toolTip:removeFromUIManager()
end

function magazineButton:joypadConfirm()
    if self.slotItem then
        ISTimedActionQueue.add(ISEjectMagazine:new(getPlayer(), self.attachingTo))
    else
        local pane = selectMagazinePane:new(riskyInspectWindow:getX() + self:getX() + 43, riskyInspectWindow:getY() + self:getY() - 3, self.attachingTo)
        pane:addToUIManager()
        pane:bringToTop()

        setJoypadFocus(getPlayer():getPlayerNum(), pane)
    end
end

function magazineButton:joypadPrompt()
    if self.slotItem then
        return getText('IGUI_RISKY_EJECT')
    else
        return getText('IGUI_RISKY_ATTACH')
    end
end

-- Add Magazine Button

addMagazineButton = ISButton:derive("addMagazineButton")

function addMagazineButton:new (x, y, w, h, slotItem, attachingTo, origin)
    local o = {}
    o = ISButton:new(x, y, w, h)

    setmetatable(o, self)
    self.__index = self

    o.borderColor.r = 0.0
    o.borderColor.g = 0.0
    o.borderColor.b = 0.0
    o.borderColor.a = 0.0

    o.backgroundColor.r = 0.5
    o.backgroundColor.g = 0.5
    o.backgroundColor.b = 0.5
    o.backgroundColor.a = 0.3

    o.backgroundColorMouseOver.r = 0.5
    o.backgroundColorMouseOver.g = 0.5
    o.backgroundColorMouseOver.b = 0.5

    o.backgroundColorMouseOver.a = 0.8
    o.currentTint = ImmutableColor.new(1.0, 1.0, 1.0, 1.0)

    o.attachingTo = attachingTo
    o.isJoypadFocused = false
    o.origin = origin

    if slotItem then
        o.toolTip = ISToolTipInv:new(slotItem)
        o.toolTip:initialise()
        o.toolTip:setOwner(o)
        o.toolTip:setVisible(false)
        o.toolTip:addToUIManager()

        -- Texture related
        o:setImage(slotItem:getTexture())
        
        local visual = slotItem:getVisual()
        o.tint = nil
        if visual then
            o.tint = visual:getTint(slotItem:getClothingItem())
            o.currentTint = visual:getTint(slotItem:getClothingItem())
        end

        if o.tint ~= nil then
            o:setTextureRGBA(o.tint:getRedFloat(), o.tint:getGreenFloat(), o.tint:getBlueFloat(), o.tint:getAlphaFloat())
        end
        
        o.slotItem = slotItem
    end

    o:bringToTop();

    return o
end

function addMagazineButton:render()
    ISButton.render(self)

    if self:isMouseOver() == false then
        if self.isJoypadFocused then
            self.backgroundColor.a = 0.8
            if self.slotItem and (self.contextMenu == nil or not self.contextMenu.visibleCheck) then
                self.toolTip.followMouse = false
                self.toolTip:setX(80)
                self.toolTip:setY(30)
                self.toolTip:setVisible(true)
                self.toolTip:bringToTop()
            end
        else
            self.backgroundColor.a = 0.5
            if self.slotItem then
                self.toolTip.followMouse = false
                self.toolTip:setVisible(false)
            end
        end
    end

    if self.slotItem then
        self:drawText(tostring(self.slotItem:getCurrentAmmoCount()), 4, 0, 1.0, 1.0, 1.0, 1.0)

        -- Texture related
        self:setImage(self.slotItem:getTexture())

        if self.currentTint ~= nil then
            self:setTextureRGBA(self.currentTint:getRedFloat(), self.currentTint:getGreenFloat(), self.currentTint:getBlueFloat(), self.currentTint:getAlphaFloat())
        end

        if not self.isJoypadFocused then
            if self:isMouseOver() and (self.contextMenu == nil or not self.contextMenu.visibleCheck) then
                self.toolTip.followMouse = true
                self.toolTip:setVisible(true)
                self.toolTip:bringToTop()
            else
                self.toolTip.followMouse = true
                self.toolTip:setVisible(false)
            end
        end
    end
end

function addMagazineButton:onMouseDown()
    if self.slotItem then
        ISTimedActionQueue.add(ISInsertMagazine:new(getPlayer(), self.attachingTo, self.slotItem))
    end
end

function addMagazineButton:onRightMouseUp(x,y)
    self:doMenu(getMouseX(), getMouseY())
end

function addMagazineButton:doMenu(x,y)
    local context = ISContextMenu.get(getPlayer():getPlayerNum(), x, y)
    ISInventoryPaneContextMenu.doMagazineMenu(getPlayer(), self.slotItem, context)
    context.origin = self.origin
    context:bringToTop()
    setJoypadFocus(getPlayer():getPlayerNum(), context)
end

function addMagazineButton:close()
    ISButton.close(self)
    self.toolTip:setVisible(false)
    self.toolTip:removeFromUIManager()
end

function addMagazineButton:joypadConfirm()
    if self.slotItem then
        ISTimedActionQueue.add(ISInsertMagazine:new(getPlayer(), self.attachingTo, self.slotItem))
    end
end

function addMagazineButton:joypadPrompt()
    return getText('IGUI_RISKY_ATTACH')
end

function addMagazineButton:joypadMenu()
    self:doMenu(80, 130)
end

-- Repair button

repairButton = ISButton:derive("repairButton")

function repairButton:new (x, y, w, h, title, clicktarget, onclick)
    local o = {}
    o = ISButton:new(x, y, w, h, title, clicktarget, onclick)

    setmetatable(o, self)
    self.__index = self

    o.borderColor.r = 0.0
    o.borderColor.g = 0.0
    o.borderColor.b = 0.0
    o.borderColor.a = 0.0

    o.backgroundColor.r = 0.5
    o.backgroundColor.g = 0.5
    o.backgroundColor.b = 0.5
    o.borderColor.a = 0.0;
    o.backgroundColor.a = 0;
    o.backgroundColorMouseOver.a = 0.8;

    o:setImage(getTexture("media/ui/Panel_info_button.png"));

    o.isJoypadFocused = false
    o.onclick = onclick

    return o
end

function repairButton:render()
    ISButton.render(self)

    if self:isMouseOver() == false then
        if self.isJoypadFocused then
            self.backgroundColor.a = 0.8
        else
            self.backgroundColor.a = 0.0
        end
    end
end

function repairButton:joypadConfirm()
    self.onclick()
end

function repairButton:joypadPrompt()
    return getText('IGUI_RISKY_REPAIR')
end