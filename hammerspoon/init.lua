hs.autoLaunch(true)

-- alt+space: dismiss notifications. Stacks get "Clear All", single alerts "Close".
local function closeNotifications()
  local nc = hs.application.get("com.apple.notificationcenterui")
  if not nc then return end
  local app = hs.axuielement.applicationElement(nc)
  local closed = 0

  local function press(elem, wanted)
    for _, name in ipairs(elem:actionNames() or {}) do
      if elem:actionDescription(name) == wanted then
        elem:performAction(name)
        closed = closed + 1
        return true
      end
    end
    return false
  end

  local function visit(elem)
    local subrole = elem:attributeValue("AXSubrole")
    if subrole == "AXNotificationCenterAlertStack" or subrole == "AXNotificationCenterAlert" then
      if press(elem, "Clear All") or press(elem, "Close") then return end
    end
    for _, child in ipairs(elem:attributeValue("AXChildren") or {}) do visit(child) end
  end

  -- Closing one notification can reveal the next, so repeat until a pass closes nothing.
  for _ = 1, 10 do
    local before = closed
    for _, win in ipairs(app:attributeValue("AXWindows") or {}) do visit(win) end
    if closed == before then break end
    hs.timer.usleep(300000)
  end
end

hs.hotkey.bind({"alt"}, "space", closeNotifications)
