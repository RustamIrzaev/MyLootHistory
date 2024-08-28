local defaults = {
  width = 400,
  height = 300
}

local frameBackdrop = {
  bgFile = "Interface\\Tooltips\\UI-Tooltip-Background",
  edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
  tile = true,
  tileSize = 32,
  edgeSize = 10,
  insets = { left = 4, right = 4, top = 4, bottom = 4 }
}

function Frame(name, parent, width, height)
  local frame = CreateFrame("Frame", name, parent or UIParent)
  frame:Hide()

  frame:SetSize(width or defaults.width, height or defaults.height)
  frame:SetPoint("CENTER")

  frame:SetBackdrop(frameBackdrop)

  frame:SetBackdropColor(0, 0, 0, 0.7)
  frame:SetBackdropBorderColor(0, 0, 1, 1)

  frame:EnableMouse(true)
  frame:SetMovable(true)
  frame:RegisterForDrag("LeftButton")

  frame:SetScript("OnDragStart", function(self)
    self:StartMoving()
  end)

  frame:SetScript("OnDragStop", function(self)
    self:StopMovingOrSizing()
  end)

  return frame
end