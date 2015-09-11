
-- Options
{-# LANGUAGE DeriveDataTypeable, NoMonomorphismRestriction, MultiParamTypeClasses, ImplicitParams #-}

-- Imports {{{
--
--

import XMonad
import XMonad.Config.Gnome
--import XMonad.Config.Xfce
--import XMonad.Config.Kde

-- Modules
import Control.Applicative
import Control.Concurrent
import Control.Exception as E
import Data.Char (isSpace)
import Data.List
import Data.Monoid
import Data.Ratio ((%))
import Graphics.X11.ExtraTypes.XF86
import Graphics.X11.Xinerama
import qualified Data.Map as M
import qualified XMonad.Actions.FlexibleResize as Flex
import qualified XMonad.StackSet as W
import qualified XMonad.Util.ExtensibleState as XS
import System.Exit
import System.IO

import XMonad.Actions.CycleWS
import XMonad.Actions.DynamicWorkspaces
import XMonad.Actions.FloatKeys
import XMonad.Actions.GridSelect
import XMonad.Actions.MouseResize
import XMonad.Actions.ShowText
import XMonad hiding ( (|||) )

import XMonad.Hooks.DynamicHooks
import XMonad.Hooks.DynamicLog
import XMonad.Hooks.EwmhDesktops
import XMonad.Hooks.FadeInactive
import XMonad.Hooks.ManageDocks
--import XMonad.Hooks.ManageDocks -- avoids xmonad overlapping
import XMonad.Hooks.ManageHelpers
--import XMonad.Hooks.ManageHelpers ( isFullscreen, isDialog, doFullFloat )
import XMonad.Hooks.SetWMName
import XMonad.Hooks.UrgencyHook

import XMonad.Layout
import XMonad.Layout.DraggingVisualizer
import XMonad.Layout.Gaps
import XMonad.Layout.Grid
import XMonad.Layout.IM
import XMonad.Layout.LayoutBuilder
import XMonad.Layout.LayoutCombinators
import XMonad.Layout.LayoutHints
import XMonad.Layout.LayoutModifier
import XMonad.Layout.MagicFocus
import XMonad.Layout.Magnifier
import XMonad.Layout.Maximize
import XMonad.Layout.Minimize
import XMonad.Layout.MosaicAlt
import XMonad.Layout.MultiToggle
import XMonad.Layout.MultiToggle.Instances
import XMonad.Layout.Named
import XMonad.Layout.NoBorders
--import XMonad.Layout.NoBorders (smartBorders, noBorders)
import XMonad.Layout.NoFrillsDecoration
import XMonad.Layout.OneBig
import XMonad.Layout.PerWorkspace
--import XMonad.Layout.PerWorkspace (onWorkspace, onWorkspaces)
import XMonad.Layout.Reflect
--import XMonad.Layout.Reflect (reflectHoriz)
import XMonad.Layout.Renamed
import XMonad.Layout.ResizableTile
import XMonad.Layout.SimpleFloat
--import XMonad.Layout.SimplestFloat
import XMonad.Layout.Spacing
import XMonad.Layout.Tabbed
import XMonad.Layout.ToggleLayouts
import XMonad.Layout.WindowNavigation
import XMonad.Layout.WindowSwitcherDecoration

import XMonad.Operations

import XMonad.Prompt
import XMonad.Prompt.AppendFile (appendFilePrompt)
import XMonad.Prompt.Man
import XMonad.Prompt.RunOrRaise (runOrRaisePrompt)
import XMonad.Prompt.Shell
import XMonad.Prompt.XMonad

import XMonad.Util.Cursor
import XMonad.Util.EZConfig
import XMonad.Util.Loggers
import XMonad.Util.NamedScratchpad
import XMonad.Util.Run
--import XMonad.Util.Run(spawnPipe)
import XMonad.Util.Scratchpad
import XMonad.Util.Timer
--}}}


userDir = "/home/michael/"
autoStart = userDir ++ ".xmonad/autostart.sh"
bitmapDir = userDir ++ ".xmonad/xbm/"


-- Define Terminal
	-- myTerminal = "tmux"
	-- myTerminal = "xterm"
	-- myTerminal = "xterm -bg black -fg gray -fa \"Ubuntu Mono\" -fs 12 -e '/usr/bin/env -u TMUX tmux -2'",
	-- myTerminal = "urxvt -e '/usr/bin/env -u TMUX tmux -2'",
	-- myTerminal = "urxvt -fg Black -bg White -rv -e tmux -2 new-session"
	-- myTerminal = "zsh"
myTerminal = "urxvt -fg Black -bg White -rv -e tmux -2 new-session"

-- Define workspaces
myWorkspaces    = ["1:main","2:web","3:vim","4:fac","5:music", "6:gimp", "7:misc", "8:sec", "9:tert"]

-- Dzen/Conky
	-- myStatusBar = "conky -c /home/michael/.xmonad/.conky_dzen | dzen2 -x '2080' -w '1040' -h '24' -ta 'r' -bg '#1B1D1E' -fg '#FFFFFF' -y '1920'"
	-- myStatusBar = "dzen2 -ta l -x 0 -y 1920 -w 900 -h 12 -fn inconsolata-9 -fg #ffffff -bg #000000"


-- Color of current window title in xmobar.
xmobarTitleColor = "#FFB6B0"

-- Color of current workspace in xmobar.
xmobarCurrentWorkspaceColor = "#CEFFAC"

-- Width of the window border in pixels.
myBorderWidth = 1



--------------------------------------------------------------------------------------------
-- MAIN                                                                                   --
--------------------------------------------------------------------------------------------


main = do
	-- r <- getScreenRes ":0" 0  --display ":0", screen 0
	-- dzen <- spawnPipe myStatusBar
	-- spawn "urxvtd &"
	-- topLeftBar  <- dzenSpawnPipe $ dzenTopLeftFlags r
	-- dzenLeftBar <- spawnPipe myXmonadBar
	spawn $ "sh " ++ autoStart
	xmproc <- spawnPipe "xmobar --top $HOME/.xmonad/xmobarrc"
	xmonad $ myUrgencyHook $ gnomeConfig { --xfceConfig, kde4Config
		  terminal				= myTerminal
		, workspaces			= myWorkspaces
		, modMask				= mod4Mask
		, handleEventHook		= myHandleEventHook --event config
		, manageHook			= manageDocks <+> myManageHook --xprop config
		-- , manageHook = manageHook defaultConfig
		-- <+> composeAll myManagementHooks
		-- <+> manageDocks
		, layoutHook			= avoidStruts $ myLayoutHook
		-- , startupHook		= myStartupHook --autostart config
	  , startupHook = do
		setWMName "LG3D"
		-- spawn "~/.xmonad/startup-hook"
		-- , logHook			= dynamicLogWithPP $ myDzenPP dzen
		--, logHook = takeTopFocus <+> dynamicLogWithPP xmobarPP {
		, logHook = dynamicLogWithPP xmobarPP {
			  ppOutput = hPutStrLn xmproc
			, ppTitle = xmobarColor myTitleColor "" . shorten myTitleLength
			, ppCurrent = xmobarColor myCurrentWSColor "" . wrap myCurrentWSLeft myCurrentWSRight
			, ppVisible = xmobarColor myVisibleWSColor ""
			. wrap myVisibleWSLeft myVisibleWSRight
			, ppUrgent = xmobarColor myUrgentWSColor ""
			. wrap myUrgentWSLeft myUrgentWSRight
			}		
		, focusFollowsMouse = True
		, normalBorderColor = "#444444"
		, focusedBorderColor = "red"
		, borderWidth = 1
		}`additionalKeys`
				[ ((mod4Mask, xK_p), spawn "dmenu_run")
				-- , yeganesh -x , but then give command in shell somehow elegant, somehow like this --((mod4Mask, xK_p), spawn "xterm -e '/usr/bin/env -u yeganesh -x")
					, ((mod4Mask .|. shiftMask , xK_p), spawn "gmrun")
					, ((mod4Mask .|. shiftMask, xK_End), spawn "pkill -KILL -u michael") 
				-- ("<XF86ScreenSaver>", spawn "slock") ]
				]


--------------------------------------------------------------------------------------------
-- HANDLE EVENT HOOK CONFIG                                                               --
--------------------------------------------------------------------------------------------

-- Wrapper for the Timer id, so it can be stored as custom mutable state
data TidState = TID TimerId deriving Typeable

instance ExtensionClass TidState where
	initialValue = TID 0

-- Handle event hook
myHandleEventHook =
	fullscreenEventHook <+> docksEventHook <+>
	clockEventHook <+> handleTimerEvent <+>
	notFocusFloat where
		clockEventHook e = do                 --thanks to DarthFennec
			(TID t) <- XS.get                 --get the recent Timer id
			handleTimer t e $ do              --run the following if e matches the id
				startTimer 1 >>= XS.put . TID --restart the timer, store the new id
				ask >>= logHook . config      --get the loghook and run it
				return Nothing                --return required type
			return $ All True                 --return required type
		notFocusFloat = followOnlyIf (fmap not isFloat) where --Do not focusFollowMouse on Float layout
			isFloat = fmap (isSuffixOf myFloaName) $ gets (description . W.layout . W.workspace . W.current . windowset)



--------------------------------------------------------------------------------------------
-- MANAGE HOOK CONFIG                                                                     --
--------------------------------------------------------------------------------------------

-- Manage Hook
myManageHook :: ManageHook
myManageHook =
	manageDocks <+>
	(scratchpadManageHook $ W.RationalRect 0 0 1 (3/4)) <+>
	dynamicMasterHook <+>
	manageWindows

-- Manage Windows
manageWindows :: ManageHook
manageWindows = composeAll . concat $
	[ [ resource  =? r --> doIgnore                    | r <- myIgnores ]
	, [ className =? c --> doShift (myWorkspaces !! 1) | c <- myWebS    ]
	, [ className =? c --> doShift (myWorkspaces !! 2) | c <- myCodeS   ]
	, [ className =? c --> doShift (myWorkspaces !! 3) | c <- myGfxS    ]
	, [ className =? c --> doShift (myWorkspaces !! 4) | c <- myChatS   ]
	, [ className =? c --> doShift (myWorkspaces !! 9) | c <- myAlt3S   ]
	, [ className =? c --> doCenterFloat               | c <- myFloatCC ]
	, [ name      =? n --> doCenterFloat               | n <- myFloatCN ]
	, [ name      =? n --> doSideFloat NW              | n <- myFloatSN ]
	, [ className =? c --> doF W.focusDown             | c <- myFocusDC ]
	, [ currentWs =? (myWorkspaces !! 1) --> keepMaster "Chromium"      ]
	, [ isFullscreen   --> doFullFloat ]
	] where
		name      = stringProperty "WM_NAME"
		myIgnores = ["desktop", "desktop_window"]
		myWebS    = ["Chromium", "Firefox", "Opera"]
		myCodeS   = ["NetBeans IDE 7.3"]
		myChatS   = ["Pidgin", "Xchat"]
		myGfxS    = ["Gimp", "gimp", "GIMP"]
		myAlt3S   = ["Amule", "Transmission-gtk"]
		myFloatCC = ["MPlayer", "mplayer2", "File-roller", "zsnes", "Gcalctool", "Exo-helper-1"
		            , "Gksu", "Galculator", "Nvidia-settings", "XFontSel", "XCalc", "XClock"
		            , "Ossxmix", "Xvidcap", "Main", "Wicd-client.py"]
		myFloatCN = ["Choose a file", "Open Image", "File Operation Progress", "Firefox Preferences"
		            , "Preferences", "Search Engines", "Set up sync", "Passwords and Exceptions"
		            , "Autofill Options", "Rename File", "Copying files", "Moving files"
		            , "File Properties", "Replace", "Quit GIMP", "Change Foreground Color"
		            , "Change Background Color", ""]
		myFloatSN = ["Event Tester"]
		myFocusDC = ["Event Tester", "Notify-osd"]
		keepMaster c = assertSlave <+> assertMaster where
			assertSlave = fmap (/= c) className --> doF W.swapDown
			assertMaster = className =? c --> doF W.swapMaster



--------------------------------------------------------------------------------------------
-- layout config                                                                          --
--------------------------------------------------------------------------------------------

myLayoutHook = 
     onWorkspace "2:www" browseLayout $ 
     onWorkspace "3:dev" devLayout $
     onWorkspace "7:sys" monitoringLayout $ 
     onWorkspace "9:files" filesLayout $ 
     defaultLayout
     where
         tall = ResizableTall 1 (3/100) (3/5) []
         spaced = spacing 5
         tiles = renamed [Replace "Tiles"] $ spaced tall
         mirrorTiles = renamed [Replace "MirrorTiles"] $ Mirror tiles
         magnifiedTiles = renamed [Replace "MagnifiedTiles"] $ magnifiercz' 1.2 tiles
         grid = renamed [Replace "Grid"] $ spaced Grid
         tabs = renamed [Replace "Tabs"] simpleTabbed
         devLayout = smartBorders $ magnifiedTiles ||| tabs ||| Full ||| tiles ||| mirrorTiles ||| grid
         browseLayout = smartBorders $ tabs ||| Full ||| magnifiedTiles ||| tiles ||| mirrorTiles ||| grid
         monitoringLayout = smartBorders $ tiles ||| grid ||| tabs ||| Full ||| magnifiedTiles ||| mirrorTiles   
         filesLayout = smartBorders $ Full ||| tiles ||| tabs ||| magnifiedTiles ||| mirrorTiles ||| grid
         defaultLayout = smartBorders $ tiles ||| tabs ||| Full ||| magnifiedTiles ||| mirrorTiles ||| grid   



--------------------------------------------------------------------------------------------
-- TODO
--------------------------------------------------------------------------------------------




iconMap = M.map (bitmapDir ++) icons
    where 
        icons = M.fromList [("Full", "layout_full.xbm"),
                            ("Tiles", "layout_tall.xbm"),
                            ("MagnifiedTiles", "layout_mtall.xbm"),
                            ("MirrorTiles", "layout_mirror_tall.xbm"),
                            ("Tabs", "layout_tabbed.xbm"),
                            ("Grid", "layout_grid.xbm"),
                            ("corner", "corner.xbm")]

largeXPConfig = 
    defaultXPConfig { font                  = "xft: inconsolata-14"
                    , bgColor               = "#1B1D1E"
                    , fgColor               = "#A6E22E"
                    , bgHLight              = "#A6E22E"
                    , fgHLight              = "#1B1D1E"
                    , promptBorderWidth     = 0
                    , height                = 22
                    , historyFilter         = deleteConsecutive
                    }


-- import from jens
myDzenPP h = defaultPP
    { ppCurrent = wrap ("^fg(#ffffff)^bg(#333333)^i(" ++ cornerIcon ++ ")^fg(orange)") "^bg()^fg()" 
    , ppVisible = wrap ("^fg(#ffffff)^i(" ++ cornerIcon ++ ")^fg(#ffffff)") "^fg()"
    , ppHidden = wrap ("^i(" ++ cornerIcon ++ ")^fg(#AAAAAA)") "^fg()"
    , ppHiddenNoWindows = \wsId -> if wsId `notElem` myWorkspaces then "" 
                                   else wrap ("^fg(#666666)^i(" ++ cornerIcon ++ ")") "^fg()" wsId 
    , ppUrgent = wrap "^fg(#ffffff)" "^fg()" 
    , ppSep = " | "
    , ppWsSep = " "
    , ppTitle = wrap (bwWrapper "-[ ") (bwWrapper " ]-") . dzenColor ("#c8e7a8") "" . shorten 20
    , ppLayout = dzenColor ("magenta") "" . wrap "^i(" ")" . lookupIcon
    , ppOutput = hPutStrLn h
    }
    where 
        bwWrapper = dzenColor ("#ffffff") ("#000000") 
        lookupIcon x = M.findWithDefault x x iconMap
        cornerIcon = lookupIcon "corner"




-- von david brewer, essential for layout
{-
  Xmobar configuration variables. These settings control the appearance
  of text which xmonad is sending to xmobar via the DynamicLog hook.
-}

myTitleColor     = "#eeeeee"  -- color of window title
myTitleLength    = 120         -- truncate window title to this length
myCurrentWSColor = "#e6744c"  -- color of active workspace
myVisibleWSColor = "#c185a7"  -- color of inactive workspace
myUrgentWSColor  = "#cc0000"  -- color of workspace with 'urgent' window
myCurrentWSLeft  = "["        -- wrap active workspace with these
myCurrentWSRight = "]"
myVisibleWSLeft  = "("        -- wrap inactive workspace with these
myVisibleWSRight = ")"
myUrgentWSLeft  = "{"         -- wrap urgent workspace with these
myUrgentWSRight = "}"



      


-- Hooks {{{
-- ManageHook {{{
manageHook' :: ManageHook
manageHook' = (composeAll . concat $
    [ [resource     =? r            --> doIgnore            |   r   <- myIgnores] -- ignore desktop
    , [className    =? c            --> doShift  "1:main"   |   c   <- myDev    ] -- move dev to main
    , [className    =? c            --> doShift  "2:web"    |   c   <- myWebs   ] -- move webs to main
    , [className    =? c            --> doShift  "3:vim"    |   c   <- myVim    ] -- move webs to main
    , [className    =? c            --> doShift	 "4:chat"   |   c   <- myChat   ] -- move chat to chat
    , [className    =? c            --> doShift  "5:music"  |   c   <- myMusic  ] -- move music to music
    , [className    =? c            --> doShift  "6:gimp"   |   c   <- myGimp   ] -- move img to div
    , [className    =? c            --> doCenterFloat       |   c   <- myFloats ] -- float my floats
    , [name         =? n            --> doCenterFloat       |   n   <- myNames  ] -- float my names
    , [isFullscreen                 --> myDoFullFloat                           ]
    ]) 

    where

        role      = stringProperty "WM_WINDOW_ROLE"
        name      = stringProperty "WM_NAME"

        -- classnames
        myFloats  = ["Smplayer","MPlayer","VirtualBox","Xmessage","XFontSel","Downloads","Nm-connection-editor"]
        myWebs    = ["Firefox","Google-chrome","Chromium", "Chromium-browser"]
        myMovie   = ["Boxee","Trine"]
        myMusic	  = ["Rhythmbox","Spotify"]
        myChat	  = ["Pidgin","Buddy List", "Psi", "Psi+", "chat", "psi"]
        myGimp	  = ["Gimp"]
        myDev	  = ["gnome-terminal"]
        myVim	  = ["Gvim"]

        -- resources
        myIgnores = ["desktop","desktop_window","notify-osd","stalonetray","trayer"]

        -- names
        myNames   = ["bashrun","Google Chrome Options","Chromium Options"]

-- a trick for fullscreen but stil allow focusing of other WSs
myDoFullFloat :: ManageHook
myDoFullFloat = doF W.focusDown <+> doFullFloat
-- }}}
layoutHook'  =  onWorkspaces ["1:main","5:music"] customLayout $ 
                onWorkspaces ["6:gimp"] gimpLayout $ 
                onWorkspaces ["4:chat"] imLayout $
                customLayout2

--Bar
myLogHook :: Handle -> X ()
myLogHook h = dynamicLogWithPP $ defaultPP
    {
        ppCurrent           =   dzenColor "#ebac54" "#1B1D1E" . pad
      , ppVisible           =   dzenColor "white" "#1B1D1E" . pad
      , ppHidden            =   dzenColor "white" "#1B1D1E" . pad . clickable myWorkspaces . trimSpace . noScratchPad
      , ppHiddenNoWindows   =   dzenColor "#7b7b7b" "#1B1D1E" . pad . clickable myWorkspaces . trimSpace . noScratchPad
      , ppUrgent            =   dzenColor "black" "red" . pad . clickable myWorkspaces . trimSpace . dzenStrip
      , ppWsSep             =   " "
      , ppSep               =   "  |  "
      , ppLayout            =   dzenColor "#ebac54" "#1B1D1E" .
                                (\x -> case x of
                                    "ResizableTall"             ->      "^i(" ++ myBitmapsDir ++ "/tall.xbm)"
                                    "Mirror ResizableTall"      ->      "^i(" ++ myBitmapsDir ++ "/mtall.xbm)"
                                    "Full"                      ->      "^i(" ++ myBitmapsDir ++ "/full.xbm)"
                                    "Simple Float"              ->      "~"
                                    _                           ->      x
                                )
      , ppTitle             =   (" " ++) . dzenColor "white" "#1B1D1E" . dzenEscape
      , ppOutput            =   hPutStrLn h
    }
    where
        noScratchPad ws = if ws /= "NSP" then ws else ""


-- Wraps a workspace name with a dzen clickable action that focusses that workspace
clickable workspaces workspace = clickableExp workspaces 1 workspace

clickableExp [] _ ws = ws
clickableExp (ws:other) n l | l == ws = "^ca(1,xdotool key alt+F" ++ show (n) ++ ")" ++ ws ++ "^ca()"
                            | otherwise = clickableExp other (n+1) l


-- Layout
customLayout = avoidStruts $ tiled ||| Mirror tiled ||| Full ||| simpleFloat
  where
    tiled   = ResizableTall 1 (2/100) (1/2) []

customLayout2 = avoidStruts $ Full ||| tiled ||| Mirror tiled ||| simpleFloat
  where
    tiled   = ResizableTall 1 (2/100) (1/2) []

gimpLayout  = avoidStruts $ withIM (0.11) (Role "gimp-toolbox") $
              reflectHoriz $
              withIM (0.15) (Role "gimp-dock") Full

imLayout    = avoidStruts $ withIM (1%5) (Or (Title "Buddy List") (And (Resource "main") (ClassName "psi"))) Grid 
--}}}
-- Theme {{{
-- Color names are easier to remember:
colorOrange         = "#FD971F"
colorDarkGray       = "#1B1D1E"
colorPink           = "#F92672"
colorGreen          = "#A6E22E"
colorBlue           = "#66D9EF"
colorYellow         = "#E6DB74"
colorWhite          = "#CCCCC6"
 
colorNormalBorder   = "#CCCCC6"
colorFocusedBorder  = "#fd971f"


barFont  = "terminus"
barXFont = "inconsolata:size=12"
xftFont = "xft: inconsolata-14"
--}}}

-- Prompt Config {{{
mXPConfig :: XPConfig
mXPConfig =
    defaultXPConfig {
		      font                  = barFont
                    , bgColor               = colorDarkGray
                    , fgColor               = colorGreen
                    , bgHLight              = colorGreen
                    , fgHLight              = colorDarkGray
                    , promptBorderWidth     = 0
                    , height                = 14
                    , historyFilter         = deleteConsecutive
                    }
 
-- insert

-- Trims leading and trailing white space
trimSpace = f . f
    where f = reverse . dropWhile isSpace



--------------------------------------------------------------------------------------------
--------------------------------------------------------------------------------------------
--------------------------------------------------------------------------------------------
-- UNUSED CODE                                                                   		  --
--------------------------------------------------------------------------------------------
--------------------------------------------------------------------------------------------
--------------------------------------------------------------------------------------------



--------------------------------------------------------------------------------------------
-- LOOK AND FEEL CONFIG                                                                   --
--------------------------------------------------------------------------------------------

-- Colors, fonts and paths
dzenFont       = "-*-montecarlo-medium-r-normal-*-11-*-*-*-*-*-*-*"
colorBlack     = "#020202" --Background
colorBlackAlt  = "#1c1c1c" --Black Xdefaults
colorGray      = "#444444" --Gray
colorGrayAlt   = "#101010" --Gray dark
colorGrayAlt2  = "#404040"
colorGrayAlt3  = "#252525"
--colorWhite     = "#a9a6af" --Foreground
colorWhiteAlt  = "#9d9d9d" --White dark
colorWhiteAlt2 = "#b5b3b3"
colorWhiteAlt3 = "#707070"
colorMagenta   = "#8e82a2"
--colorBlue      = "#44aacc"
colorBlueAlt   = "#3955c4"
colorRed       = "#f7a16e"
colorRedAlt    = "#e0105f"
--colorGreen     = "#66ff66"
colorGreenAlt  = "#558965"
boxLeftIcon    = "/home/nnoell/.icons/xbm_icons/subtle/boxleft.xbm"  --left icon of dzen boxes
boxLeftIcon2   = "/home/nnoell/.icons/xbm_icons/subtle/boxleft2.xbm" --left icon2 of dzen boxes
boxRightIcon   = "/home/nnoell/.icons/xbm_icons/subtle/boxright.xbm" --right icon of dzen boxes
xDefRes        = 1366 --no longer used
yDefRes        = 768  --no longer used
-- relevant for right bottom entry?
panelHeight    = 12   --height of top and bottom panels
boxHeight      = 14   --height of dzen logger box
topPanelSepPos = 950  --left-right alignment pos of top panel
botPanelSepPos = 450  --left-right alignment pos of bottom panel

-- Title theme
myTitleTheme :: Theme
myTitleTheme = defaultTheme
	{ fontName            = dzenFont
	, inactiveBorderColor = colorGrayAlt2
	, inactiveColor       = colorGrayAlt3
	, inactiveTextColor   = colorWhiteAlt3
	, activeBorderColor   = colorGrayAlt2
	, activeColor         = colorGrayAlt2
	, activeTextColor     = colorWhiteAlt2
	, urgentBorderColor   = colorGray
	, urgentTextColor     = colorGreen
	, decoHeight          = 14
	}

-- Prompt theme
myXPConfig :: XPConfig
myXPConfig = defaultXPConfig
	{ font              = dzenFont
	, bgColor           = colorBlack
	, fgColor           = colorWhite
	, bgHLight          = colorBlue
	, fgHLight          = colorBlack
	, borderColor       = colorGrayAlt
	, promptBorderWidth = 1
	, height            = panelHeight
	, position          = Top
	, historySize       = 100
	, historyFilter     = deleteConsecutive
	, autoComplete      = Nothing
	}

-- GridSelect color scheme
myColorizer :: Window -> Bool -> X (String, String)
myColorizer = colorRangeFromClassName
	(0x00,0x00,0x00) --lowest inactive bg
	(0x1C,0x1C,0x1C) --highest inactive bg
	(0x44,0xAA,0xCC) --active bg
	(0xBB,0xBB,0xBB) --inactive fg
	(0x00,0x00,0x00) --active fg

-- GridSelect theme
myGSConfig :: t -> GSConfig Window
myGSConfig colorizer = (buildDefaultGSConfig myColorizer)
	{ gs_cellheight  = 50
	, gs_cellwidth   = 200
	, gs_cellpadding = 10
	, gs_font        = dzenFont
	}

-- Flash text config
myTextConfig :: ShowTextConfig
myTextConfig = STC
	{ st_font = dzenFont
	, st_bg   = colorBlack
	, st_fg   = colorWhite
	}

-- Dzen logger box pretty printing themes
gray2BoxPP :: BoxPP
gray2BoxPP = BoxPP
	{ bgColorBPP   = colorBlack
	, fgColorBPP   = colorGray
	, boxColorBPP  = colorGrayAlt
	, leftIconBPP  = boxLeftIcon2
	, rightIconBPP = boxRightIcon
	, boxHeightBPP = boxHeight
	}

blueBoxPP :: BoxPP
blueBoxPP = BoxPP
	{ bgColorBPP   = colorBlack
	, fgColorBPP   = colorBlue
	, boxColorBPP  = colorGrayAlt
	, leftIconBPP  = boxLeftIcon
	, rightIconBPP = boxRightIcon
	, boxHeightBPP = boxHeight
	}

blue2BoxPP :: BoxPP
blue2BoxPP = BoxPP
	{ bgColorBPP   = colorBlack
	, fgColorBPP   = colorBlue
	, boxColorBPP  = colorGrayAlt
	, leftIconBPP  = boxLeftIcon2
	, rightIconBPP = boxRightIcon
	, boxHeightBPP = boxHeight
	}

whiteBoxPP :: BoxPP
whiteBoxPP = BoxPP
	{ bgColorBPP   = colorBlack
	, fgColorBPP   = colorWhiteAlt
	, boxColorBPP  = colorGrayAlt
	, leftIconBPP  = boxLeftIcon
	, rightIconBPP = boxRightIcon
	, boxHeightBPP = boxHeight
	}

blackBoxPP :: BoxPP
blackBoxPP = BoxPP
	{ bgColorBPP   = colorBlack
	, fgColorBPP   = colorBlack
	, boxColorBPP  = colorGrayAlt
	, leftIconBPP  = boxLeftIcon
	, rightIconBPP = boxRightIcon
	, boxHeightBPP = boxHeight
	}

white2BBoxPP :: BoxPP
white2BBoxPP = BoxPP
	{ bgColorBPP   = colorBlack
	, fgColorBPP   = colorBlack
	, boxColorBPP  = colorWhiteAlt
	, leftIconBPP  = boxLeftIcon2
	, rightIconBPP = boxRightIcon
	, boxHeightBPP = boxHeight
	}

blue2BBoxPP :: BoxPP --current workspace
blue2BBoxPP = BoxPP
	{ bgColorBPP   = colorBlack
	, fgColorBPP   = colorBlack
	, boxColorBPP  = colorBlue
	, leftIconBPP  = boxLeftIcon2
	, rightIconBPP = boxRightIcon
	, boxHeightBPP = boxHeight
	}

green2BBoxPP :: BoxPP --urgent workspace
green2BBoxPP = BoxPP
	{ bgColorBPP   = colorBlack
	, fgColorBPP   = colorBlack
	, boxColorBPP  = colorGreen
	, leftIconBPP  = boxLeftIcon2
	, rightIconBPP = boxRightIcon
	, boxHeightBPP = boxHeight
	}

-- Dzen logger clickable areas
calendarCA :: CA
calendarCA = CA
	{ leftClickCA   = "/home/nnoell/bin/dzencal.sh"
	, middleClickCA = "/home/nnoell/bin/dzencal.sh"
	, rightClickCA  = "/home/nnoell/bin/dzencal.sh"
	, wheelUpCA     = "/home/nnoell/bin/dzencal.sh"
	, wheelDownCA   = "/home/nnoell/bin/dzencal.sh"
	}

layoutCA :: CA
layoutCA = CA
	{ leftClickCA   = "/usr/bin/xdotool key super+space"
	, middleClickCA = "/usr/bin/xdotool key super+v"
	, rightClickCA  = "/usr/bin/xdotool key super+shift+space"
	, wheelUpCA     = "/usr/bin/xdotool key super+f"
	, wheelDownCA   = "/usr/bin/xdotool key super+control+f"
	}

workspaceCA :: CA
workspaceCA = CA
	{ leftClickCA   = "/usr/bin/xdotool key super+1"
	, middleClickCA = "/usr/bin/xdotool key super+g"
	, rightClickCA  = "/usr/bin/xdotool key super+0"
	, wheelUpCA     = "/usr/bin/xdotool key ctrl+alt+Right"
	, wheelDownCA   = "/usr/bin/xdotool key ctrl+alt+Left"
	}

focusCA :: CA
focusCA = CA
	{ leftClickCA   = "/usr/bin/xdotool key super+m"
	, middleClickCA = "/usr/bin/xdotool key super+c"
	, rightClickCA  = "/usr/bin/xdotool key super+shift+m"
	, wheelUpCA     = "/usr/bin/xdotool key super+shift+j"
	, wheelDownCA   = "/usr/bin/xdotool key super+shift+k"
	}


-- Layout names (must be one word /= to: Mirror, ReflectX, ReflectY, Switcher, Normal and Unique)
myTileName = "Tiled"
myMirrName = "MirrTld"
myMosAName = "Mosaic"
myOneBName = "OneBig"
myCst1Name = "Default"
myCst2Name = "MstrTab"
myCst3Name = "Web"
myChatName = "Chat"
myFTabName = "Full"
myFloaName = "Float"




--------------------------------------------------------------------------------------------
-- LAYOUT CONFIG                                                                          --
--------------------------------------------------------------------------------------------

-- Tabbed transformer (W+f)
data TABBED = TABBED deriving (Read, Show, Eq, Typeable)
instance Transformer TABBED Window where
	transform TABBED x k = k myFTabU (\_ -> x)

-- Floated transformer (W+ctl+f)
data FLOATED = FLOATED deriving (Read, Show, Eq, Typeable)
instance Transformer FLOATED Window where
	transform FLOATED x k = k myFloaU (\_ -> x)

-- Unique Layouts
myFTabU = smartBorders $ named ("Unique " ++ myFTabName) $ tabbedAlways shrinkText myTitleTheme
myFloaU = named ("Unique " ++ myFloaName) $ mouseResize $ noFrillsDeco shrinkText myTitleTheme simplestFloat

-- Layout hook
unused_myLayoutHook =
	gaps [(U,panelHeight), (D,panelHeight)] $
	configurableNavigation noNavigateBorders $
	minimize $
	maximize $
	mkToggle (single TABBED) $
	mkToggle (single FLOATED) $
	mkToggle (single MIRROR) $
	mkToggle (single REFLECTX) $
	mkToggle (single REFLECTY) $
	onWorkspace (myWorkspaces !! 1) webLayouts $
	onWorkspace (myWorkspaces !! 2) codeLayouts $
	onWorkspace (myWorkspaces !! 4) chatLayouts $
	allLayouts where
		--per workspace layouts
		webLayouts  = (myToggleL myCst3 myCst3Name) ||| (myToggleL myCst1 myCst1Name)                                   --workspace 2 layouts
		codeLayouts = (myToggleL myCst2 myCst2Name) ||| (myToggleL myOneB myOneBName) ||| (myToggleL myTile myTileName) --workspace 3 layouts
		chatLayouts = myToggleL (withIM (0.2) (Title "Buddy List") myMosA) myChatName                                   --workspace 5 layouts
		allLayouts  =                                                                                                   -- rest of workspaces layouts
			(myToggleL myCst1 myCst1Name) |||
			(myToggleL myCst2 myCst2Name) |||
			(myToggleL myTile myTileName) |||
			(myToggleL myOneB myOneBName) |||
			(myToggleL myMirr myMirrName) |||
			(myToggleL myMosA myMosAName) |||
			(myToggleL myCst3 myCst3Name)
		--layouts
		myTile = ResizableTall 1 0.03 0.5 []                                                                               --default xmonad layout
		myMirr = Mirror myTile                                                                                             --mirror default xmonad layout
		myMosA = MosaicAlt M.empty                                                                                         --default mosaicAlt layout
		myOneB = OneBig 0.75 0.65                                                                                          --default OneBig layout
		myCst1 = (layoutN 2 (relBox 0 0 1 0.6) (Just $ relBox 0 0 1 1) $ myTile) $ (layoutAll (relBox 0 0.6 1 1) $ myTabb) --custom1 layout
		myCst2 = (layoutN 1 (relBox 0 0 0.4 1) (Just $ relBox 0 0 1 1) $ myTile) $ (layoutAll (relBox 0.4 0 1 1) $ myTabb) --custom2 layout
		myCst3 = (layoutN 1 (relBox 0 0 1 0.7) (Just $ relBox 0 0 1 1) $ myTabb) $ (layoutAll (relBox 0 0.7 1 1) $ myTabb) --custom3 layout
		myChat = withIM (0.20) (Title "Buddy List") myMosA                                                                 --custom chat layout
		myTabb = tabbed shrinkText myTitleTheme                                                                            --default tabbed layout
		--costom draggingVisualizer toggle
		myToggleL l n = smartBorders $ toggleLayouts (named ("Switcher " ++ n) $ switcher l) (named ("Normal " ++ n) l) where
			switcher l = windowSwitcherDecoration shrinkText myTitleTheme $ draggingVisualizer l



--------------------------------------------------------------------------------------------
-- DZEN STATUS BARS CONFIG                                                                --
--------------------------------------------------------------------------------------------

--myUrgencyHook = withUrgencyHook dzenUrgencyHook { args = ["-y 1000"] }

-- urgencyHook
myUrgencyHook :: LayoutClass l Window => XConfig l -> XConfig l
myUrgencyHook = withUrgencyHook dzenUrgencyHook
	{ duration = 2000000
	, args =
		[ "-x", "0"
---		, "-y", "0"
		, "-y", "1000"
		, "-h", show panelHeight
		, "-w", show topPanelSepPos
		, "-fn", dzenFont
		, "-bg", colorBlack
		, "-fg", colorGreen
		]
	}

-- Dzen top left bar flags
dzenTopLeftFlags :: Res -> DF
dzenTopLeftFlags r = DF
	{ 
	xPosDF		   = quot (xRes r) 4
	--xPosDF       = 0
	--, yPosDF       = 0
	, yPosDF	   = (yRes r) - panelHeight
	--, widthDF      = topPanelSepPos
	, widthDF      = quot (xRes r) 4
	, heightDF     = panelHeight
	, alignementDF = "l"
	, fgColorDF    = colorWhiteAlt
	, bgColorDF    = colorBlack
	, fontDF       = dzenFont
	, eventDF      = "onstart=lower"
	, extrasDF     = "-p"
	}

-- Top left bar logHook
myTopLeftLogHook :: Handle -> X ()
myTopLeftLogHook h = dynamicLogWithPP defaultPP
	{ ppOutput = hPutStrLn h
	, ppOrder  = \(_:_:_:x) -> x
	, ppSep    = " "
	, ppExtras = [ myLayoutL, myWorkspaceL, myFocusL ]
	}

-- Dzen top right bar flags
dzenTopRightFlags :: Res -> DF
dzenTopRightFlags r = DF
	{ xPosDF		= quot (xRes r) 2
	--xPosDF       = topPanelSepPos - 400
	--, yPosDF       = 0
	, yPosDF		= (yRes r) - panelHeight
	--, widthDF      = (xRes r) - topPanelSepPos
	, widthDF      = quot (xRes r) 4
	, heightDF     = panelHeight
	, alignementDF = "r"
	, fgColorDF    = colorWhiteAlt
	, bgColorDF    = colorBlack
	, fontDF       = dzenFont
	, eventDF      = "onstart=lower"
	, extrasDF     = "-p"
	}

-- Top right bar logHook
myTopRightLogHook :: Handle -> X ()
myTopRightLogHook h = dynamicLogWithPP defaultPP
	{ ppOutput  = hPutStrLn h
	, ppOrder   = \(_:_:_:x) -> x
	, ppSep     = " "
	, ppExtras  = [ myUptimeL, myDateL ]
	}

-- Dzen bottom left bar flags
dzenBotLeftFlags :: Res -> DF
dzenBotLeftFlags r = DF
	{ xPosDF       = 0
	, yPosDF       = (yRes r) - panelHeight
	--, widthDF      = botPanelSepPos
	, widthDF      = quot (xRes r) 4
	, heightDF     = panelHeight
	, alignementDF = "l"
	, fgColorDF    = colorWhiteAlt
	, bgColorDF    = colorBlack
	, fontDF       = dzenFont
	, eventDF      = "onstart=lower"
	, extrasDF     = "-p"
	}

-- Bottom left bar logHook
myBotLeftLogHook :: Handle -> X ()
myBotLeftLogHook h = dynamicLogWithPP . namedScratchpadFilterOutWorkspacePP $ defaultPP
	{ ppOutput          = hPutStrLn h
	, ppOrder           = \(ws:_:_:x) -> [ws] ++ x
	, ppSep             = " "
	, ppWsSep           = ""
	, ppCurrent         = dzenBoxStyle blue2BBoxPP
	, ppUrgent          = dzenBoxStyle green2BBoxPP . dzenClickWorkspace
	, ppVisible         = dzenBoxStyle blackBoxPP . dzenClickWorkspace
	, ppHiddenNoWindows = dzenBoxStyle blackBoxPP . dzenClickWorkspace
	, ppHidden          = dzenBoxStyle whiteBoxPP . dzenClickWorkspace
	, ppExtras          = [ myResL, myBrightL ]
	} where
		dzenClickWorkspace ws = "^ca(1," ++ xdo "w;" ++ xdo index ++ ")" ++ "^ca(3," ++ xdo "w;" ++ xdo index ++ ")" ++ ws ++ "^ca()^ca()" where
			wsIdxToString Nothing = "1"
			wsIdxToString (Just n) = show $ mod (n+1) $ length myWorkspaces
			index = wsIdxToString (elemIndex ws myWorkspaces)
			xdo key = "/usr/bin/xdotool key super+" ++ key

-- Dzen bottom right bar flags
dzenBotRightFlags :: Res -> DF
dzenBotRightFlags r = DF
	{ xPosDF       = (quot (xRes r) 4 ) + (quot (xRes r) 2)
	, yPosDF       = (yRes r) - panelHeight
	--, widthDF      = (xRes r) - botPanelSepPos
	, widthDF      = quot (xRes r) 4
	, heightDF     = panelHeight
	, alignementDF = "r"
	, fgColorDF    = colorBlue
	, bgColorDF    = colorBlack
	, fontDF       = dzenFont
	, eventDF      = "onstart=lower"
	, extrasDF     = "-p"
	}

-- Bottom right bar logHook
myBotRightLogHook :: Handle -> X ()
myBotRightLogHook h = dynamicLogWithPP defaultPP
	{ ppOutput = hPutStrLn h
	, ppOrder  = \(_:_:_:x) -> x
	, ppSep    = " "
	, ppExtras = [ myCpuL, myMemL, myTempL, myWifiL, myBatL ]
	}


--------------------------------------------------------------------------------------------
-- LOGGERS CONFIG                                                                         --
--------------------------------------------------------------------------------------------

-- BotRight Loggers
myBatL =
	(dzenBoxStyleL gray2BoxPP $ labelL "BATTERY") ++!
	(dzenBoxStyleL blueBoxPP  $ batPercent 30 colorRed) ++!
	(dzenBoxStyleL whiteBoxPP batStatus)
myWifiL =
	(dzenBoxStyleL gray2BoxPP $ labelL "WIFI") ++!
	(dzenBoxStyleL blueBoxPP wifiSignal)
myTempL =
	(dzenBoxStyleL gray2BoxPP $ labelL "TEMP") ++!
	(dzenBoxStyleL blueBoxPP  $ cpuTemp 2 70 colorRed) --2 because I have 2 thermal zones
myMemL =
	(dzenBoxStyleL gray2BoxPP $ labelL "MEM") ++!
	(dzenBoxStyleL blueBoxPP  $ memUsage [percMemUsage, totMBMemUsage])
myCpuL =
	(dzenBoxStyleL gray2BoxPP $ labelL "CPU") ++!
	(dzenBoxStyleL blueBoxPP  $ cpuUsage "/tmp/haskell-cpu-usage.txt" 70 colorRed)

-- BotLeft Loggers
myResL =
	(dzenBoxStyleL blue2BoxPP $ labelL "RES") ++!
	(dzenBoxStyleL whiteBoxPP $ screenRes ":0" 0)
myBrightL =
	(dzenBoxStyleL blue2BoxPP $ labelL "BRIGHT") ++!
	(dzenBoxStyleL whiteBoxPP $ brightPerc 15) --15 because brightness go from 0 to 15 in my case, usually must be 10

-- TopRight Loggers
myDateL =
	(dzenBoxStyleL white2BBoxPP $ date "%A") ++!
	-- (dzenBoxStyleL whiteBoxPP   $ date $ "%Y^fg(" ++ colorGray ++ ").^fg()%m^fg(" ++ colorGray ++ ").^fg()^fg(" ++ colorBlue ++ ")%d^fg()") ++!
	-- (dzenBoxStyleL whiteBoxPP   $ date $ "%H^fg(" ++ colorGray ++ "):^fg()%M^fg(" ++ colorGray ++ "):^fg()^fg()") ++!
	(dzenBoxStyleL whiteBoxPP   $ date $ "%H^fg(" ++ colorGray ++ "):^fg()%M^fg(" ++ colorGray ++ "):^fg()^fg(" ++ colorGreen ++ ")%S^fg()") ++!
	(dzenClickStyleL calendarCA $ dzenBoxStyleL blueBoxPP $ labelL "CALENDAR")
myUptimeL =
	(dzenBoxStyleL blue2BoxPP   $ labelL "UPTIME") ++!
	(dzenBoxStyleL whiteBoxPP uptime)

-- TopLeft Loggers
myFocusL  =
	(dzenClickStyleL focusCA  $ dzenBoxStyleL white2BBoxPP $ labelL "FOCUS") ++!
	(dzenBoxStyleL whiteBoxPP $ shortenL 100 logTitle)
myLayoutL =
	(dzenClickStyleL layoutCA $ dzenBoxStyleL blue2BoxPP $ labelL "LAYOUT") ++!
	(dzenBoxStyleL whiteBoxPP $ onLogger (layoutText . removeWord . removeWord) logLayout) where
		removeWord xs = tail $ dropWhile (/= ' ') xs
		layoutText xs
			| isPrefixOf "Mirror" xs   = layoutText $ removeWord xs ++ " ^fg(" ++ colorBlue  ++ ")M^fg(" ++ colorGray ++ ")|^fg(" ++ colorWhiteAlt ++ ")"
			| isPrefixOf "ReflectY" xs = layoutText $ removeWord xs ++ " ^fg(" ++ colorBlue  ++ ")Y^fg(" ++ colorGray ++ ")|^fg(" ++ colorWhiteAlt ++ ")"
			| isPrefixOf "ReflectX" xs = layoutText $ removeWord xs ++ " ^fg(" ++ colorBlue  ++ ")X^fg(" ++ colorGray ++ ")|^fg(" ++ colorWhiteAlt ++ ")"
			| isPrefixOf "Switcher" xs = layoutText $ removeWord xs ++ " ^fg(" ++ colorRed   ++ ")S^fg(" ++ colorGray ++ ")|^fg(" ++ colorWhiteAlt ++ ")"
			| isPrefixOf "Normal" xs   = layoutText $ removeWord xs ++ " ^fg(" ++ colorGreen ++ ")N^fg(" ++ colorGray ++ ")|^fg(" ++ colorWhiteAlt ++ ")"
			| isPrefixOf "Unique" xs   = layoutText $ removeWord xs ++ " ^fg(" ++ colorGreen ++ ")U^fg(" ++ colorGray ++ ")|^fg(" ++ colorWhiteAlt ++ ")"
			| otherwise                = concat $ reverse $ words xs
myWorkspaceL =
	(dzenClickStyleL workspaceCA $ dzenBoxStyleL blue2BoxPP $ labelL "WORKSPACE") ++!
	(dzenBoxStyleL whiteBoxPP $ onLogger namedWorkspaces logCurrent) where
		namedWorkspaces w
			| (elem w $ map show [0..9]) = "^fg(" ++ colorGreen ++ ")" ++ w ++ "^fg(" ++ colorGray ++ ")|^fg()" ++ workspaceNames !! (mod ((read w::Int) - 1) 10)
			| otherwise                  = "^fg(" ++ colorRed   ++ ")x^fg(" ++ colorGray ++ ")|^fg()" ++ w




--------------------------------------------------------------------------------------------
-- DZEN UTILS                                                                             --
--------------------------------------------------------------------------------------------

-- Dzen flags
data DF = DF
	{ xPosDF       :: Int
	, yPosDF       :: Int
	, widthDF      :: Int
	, heightDF     :: Int
	, alignementDF :: String
	, fgColorDF    :: String
	, bgColorDF    :: String
	, fontDF       :: String
	, eventDF      :: String
	, extrasDF     :: String
	}

-- Dzen box pretty config
data BoxPP = BoxPP
	{ bgColorBPP   :: String
	, fgColorBPP   :: String
	, boxColorBPP  :: String
	, leftIconBPP  :: String
	, rightIconBPP :: String
	, boxHeightBPP :: Int
	}

-- Dzen clickable area config
data CA = CA
	{ leftClickCA   :: String
	, middleClickCA :: String
	, rightClickCA  :: String
	, wheelUpCA     :: String
	, wheelDownCA   :: String
	}

-- Create a dzen string with its flags
dzenFlagsToStr :: DF -> String
dzenFlagsToStr df =
	" -x '" ++ (show $ xPosDF df) ++
	"' -y '" ++ (show $ yPosDF df) ++
	"' -w '" ++ (show $ widthDF df) ++
	"' -h '" ++ (show $ heightDF df) ++
	"' -ta '" ++ alignementDF df ++
	"' -fg '" ++ fgColorDF df ++
	"' -bg '" ++ bgColorDF df ++
	"' -fn '" ++ fontDF df ++
	"' -e '" ++ eventDF df ++
	"' " ++ extrasDF df

-- Uses dzen format to draw a "box" arround a given text
dzenBoxStyle :: BoxPP -> String -> String
dzenBoxStyle bpp t =
	"^fg(" ++ (boxColorBPP bpp) ++
	")^i(" ++ (leftIconBPP bpp)  ++
	")^ib(1)^r(1920x" ++ (show $ boxHeightBPP bpp) ++
	")^p(-1920)^fg(" ++ (fgColorBPP bpp) ++
	")" ++ t ++
	"^fg(" ++ (boxColorBPP bpp) ++
	")^i(" ++ (rightIconBPP bpp) ++
	")^fg(" ++ (bgColorBPP bpp) ++
	")^r(1920x" ++ (show $ boxHeightBPP bpp) ++
	")^p(-1920)^fg()^ib(0)"

-- Uses dzen format to make dzen text clickable
dzenClickStyle :: CA -> String -> String
dzenClickStyle ca t = "^ca(1," ++ leftClickCA ca ++
	")^ca(2," ++ middleClickCA ca ++
	")^ca(3," ++ rightClickCA ca ++
	")^ca(4," ++ wheelUpCA ca ++
	")^ca(5," ++ wheelDownCA ca ++
	")" ++ t ++
	"^ca()^ca()^ca()^ca()^ca()"

-- Launch dzen through the system shell and return a Handle to its standard input
dzenSpawnPipe df = spawnPipe $ "dzen2" ++ dzenFlagsToStr df

-- Logger version of dzenBoxStyle
dzenBoxStyleL :: BoxPP -> Logger -> Logger
dzenBoxStyleL bpp l = (fmap . fmap) (dzenBoxStyle bpp) l

-- Logger version of dzenClickStyle
dzenClickStyleL :: CA -> Logger -> Logger
dzenClickStyleL ca l = (fmap . fmap) (dzenClickStyle ca) l


--------------------------------------------------------------------------------------------
-- HARDCODED LOGGERS (you may need to amend them so that they work on your computer)      --
--------------------------------------------------------------------------------------------

-- Concat two Loggers
(++!) :: Logger -> Logger -> Logger
l1 ++! l2 = (liftA2 . liftA2) (++) l1 l2

-- Label
labelL :: String -> Logger
labelL = return . return

-- Init version for Logger
initL :: Logger -> Logger
initL = (fmap . fmap) initNotNull

-- Concat a list of loggers
concatL :: [Logger] -> Logger
concatL [] = return $ return ""
concatL (x:xs) = x ++! concatL xs

-- Concat a list of loggers with spaces between them
concatWithSpaceL :: [Logger] -> Logger
concatWithSpaceL [] = return $ return ""
concatWithSpaceL (x:xs) = x ++! (labelL " ") ++! concatWithSpaceL xs

initNotNull :: String -> String
initNotNull [] = "0\n"
initNotNull xs = init xs

tailNotNull :: [String] -> [String]
tailNotNull [] = ["0\n"]
tailNotNull xs = tail xs

-- Convert the content of a file into a Logger
fileToLogger :: (String -> String) -> String -> FilePath -> Logger
fileToLogger f e p = do
	let readWithE f1 e1 p1 = E.catch (do
		contents <- readFile p1
		return $ f1 (initNotNull contents) ) ((\_ -> return e1) :: E.SomeException -> IO String)
	str <- liftIO $ readWithE f e p
	return $ return str

-- Battery percent
batPercent :: Int -> String -> Logger
batPercent v c = fileToLogger format "N/A" "/sys/class/power_supply/BAT0/capacity" where
	format x = if ((read x::Int) <= v) then "^fg(" ++ c ++ ")" ++ x ++ "%^fg()" else (x ++ "%")

-- Battery status
batStatus :: Logger
batStatus = fileToLogger (\x -> x) "AC Conection" "/sys/class/power_supply/BAT1/status"

-- Brightness percenn
brightPerc :: Int -> Logger
brightPerc p = fileToLogger format "0" "/sys/class/backlight/acpi_video0/actual_brightness" where
	format x = (show $ div ((read x::Int) * 100) p) ++ "%"

-- wifi signal
wifiSignal :: Logger
wifiSignal = fileToLogger format "N/A" "/proc/net/wireless" where
	format x = if (length $ lines x) >= 3 then (initNotNull ((words ((lines x) !! 2)) !! 2) ++ "%") else "Off"

-- CPU temperature
cpuTemp :: Int -> Int -> String -> Logger
cpuTemp n v c = initL $ concatWithSpaceL $ map (fileToLogger divc "0") pathtemps where
	pathtemps = map (++"/thermal_zone/temp") $ map ("/sys/bus/acpi/devices/LNXTHERM:0"++) $ take n $ map show [0..]
	divc x = crit $ div (read x::Int) 1000
	crit x = if (x >= v) then "^fg(" ++ c ++ ")" ++ show x ++ "°^fg()" else (show x ++ "°")

-- Memory usage
memUsage :: [(String -> String)] -> Logger
memUsage xs = initL $ concatWithSpaceL $ map funct xs where
	funct x = fileToLogger x "N/A" "/proc/meminfo"

_memUsed x = (_memValues x !! 0) - ((_memValues x !! 2) + (_memValues x !! 3) + (_memValues x !! 1))
_memPerc x = div (_memUsed x * 100) (_memValues x !! 0)
_memValues x = map (getValues x) $ take 4 [0..] where
	getValues x n = read (words (lines x !! n) !! 1)::Int

freeBMemUsage x = (show $ _memValues x !! 1) ++ "B"
freeMBMemUsage x = (show $ div (_memValues x !! 1) 1024) ++ "MB"
totBMemUsage = (++"B") . show . _memUsed
totMBMemUsage = (++"MB") . show . (`div` 1024) . _memUsed
percMemUsage = (++"%") . show . _memPerc

-- CPU Usage: this is an ugly hack that depends on "haskell-cpu-usage" app (See my github repo to get the app)
cpuUsage :: String -> Int -> String -> Logger
cpuUsage path v c = fileToLogger format "0" path where
	format x = if (null x) then "N/A" else initNotNull $ concat $ map (++" ") $ map crit $ tailNotNull $ words $ x
	crit x = if ((read x::Int) >= v) then "^fg(" ++ c ++ ")" ++ x ++ "%^fg()" else (x ++ "%")

-- Uptime
uptime :: Logger
uptime = fileToLogger format "0" "/proc/uptime" where
	u x  = read (takeWhile (/='.') x)::Integer
	h x  = div (u x) 3600
	hr x = mod (u x) 3600
	m x  = div (hr x) 60
	s x  = mod (hr x) 60
	format x = (show $ h x) ++ "h " ++ (show $ m x) ++ "m " ++ (show $ s x) ++ "s"

-- Gets the current resolution given a display and a screen
getScreenRes :: String -> Int -> IO Res
getScreenRes d n = do
	dpy <- openDisplay d
	r <- liftIO $ getScreenInfo dpy
	closeDisplay dpy
	return $ Res
		{ xRes = fromIntegral $ rect_width $ r !! n
		, yRes = fromIntegral $ rect_height $ r !! n
		}

-- Screen Resolution
data Res = Res
	{ xRes :: Int
	, yRes :: Int
	}

-- Resolution logger
screenRes :: String -> Int -> Logger
screenRes d n = do
	res <- liftIO $ getScreenRes d n
	return $ return $ (show $ xRes res) ++ "x" ++ (show $ yRes res)
