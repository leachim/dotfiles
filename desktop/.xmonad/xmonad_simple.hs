
-- Options
{-# LANGUAGE DeriveDataTypeable, NoMonomorphismRestriction, MultiParamTypeClasses, ImplicitParams #-}


-- Imports {{{
--
--

import XMonad
import XMonad.Config.Gnome

main = do
	xmonad $ gnomeConfig {
-------------------	xmonad $ myUrgencyHook $ xfceConfig {
-------------------	xmonad $ myUrgencyHook $ kde4Config {
      , modMask		    = mod4Mask
      }`additionalKeys`
				[ ((mod4Mask, xK_p), spawn "dmenu_run"),
				-- yeganesh -x , but then give command in shell somehow elegant, somehow like this --((mod4Mask, xK_p), spawn "xterm -e '/usr/bin/env -u yeganesh -x"), 
				  ((mod4Mask .|. shiftMask , xK_p), spawn "gmrun"),
				  ((mod4Mask .|. shiftMask, xK_End), spawn "pkill -KILL -u michael") ]
          --        ("<XF86ScreenSaver>", spawn "slock") ]
	
