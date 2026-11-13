hs.hotkey.bind({"alt"}, "space", function()
  hs.task.new("/usr/bin/open", nil,
    {"-gna", "/Applications/CloseNotificationKeyboard.app"}):start()
end)
