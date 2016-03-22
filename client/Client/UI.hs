{-# LANGUAGE TemplateHaskell #-}
{-# LANGUAGE OverloadedStrings #-}

module Client.UI where

import Control.Lens
import qualified Graphics.Vty as V

import qualified Brick.Main as M
import qualified Brick.Types as T
import Brick.Widgets.Core
  ( (<+>)
  , (<=>)
  , hLimit
  , vLimit
  , str
  , padBottom
  , padLeft
  , padRight
  , withBorderStyle
  )
import qualified Brick.Widgets.Center as C
import qualified Brick.Widgets.Edit as E
import qualified Brick.Widgets.Border.Style as BS
import qualified Brick.Widgets.Border as B
import qualified Brick.AttrMap as A
import Brick.Util (on)
import Data.Text (Text)
import qualified Data.Text as Text

data St =
    St 
    { _messages :: [Text]
    , _editor :: E.Editor
    }

makeLenses ''St

initialState :: St
initialState =
    St ["wut", "hay", "asdf"] (E.editor "Text Enter" (str . unlines) Nothing "")

appCursor :: St -> [T.CursorLocation] -> Maybe T.CursorLocation
appCursor st = M.showCursorNamed ("Text Enter")

appEvent :: St -> V.Event -> T.EventM (T.Next St)
appEvent st ev =
    case ev of
        V.EvKey V.KEsc [] -> M.halt st
        _ -> M.continue =<< T.handleEventLensed st editor ev

theMap :: A.AttrMap
theMap = A.attrMap V.defAttr
    [ (E.editAttr, V.white `on` V.blue)
    ]

theApp :: M.App St V.Event
theApp =
    M.App { M.appDraw = drawUI
          , M.appChooseCursor = appCursor
          , M.appHandleEvent = appEvent
          , M.appStartEvent = return
          , M.appAttrMap = const theMap
          , M.appLiftVtyEvent = id
          }

drawUI :: St -> [T.Widget]
drawUI st = [ui]
    where
        ui = C.center $ chatMessages 
                        <=>
                        str "Commands: /connect, /disconnect "
                        <=>
                        inputBox 
                        <=>
                        str "ESC to quit"
        chatMessages = B.borderWithLabel (str "Messages")
            $ withBorderStyle BS.unicode
            $ padBottom T.Max 
            $ padLeft (T.Pad 3)
            $ padRight T.Max
            $ str (Text.unpack . Text.unlines . view messages $ st) 
        inputBox = B.borderWithLabel (str "Input")
            $ withBorderStyle BS.unicode 
            $ padLeft T.Max $ (vLimit 2 $ E.renderEditor $ st^.editor)

main :: IO ()
main = do
    st <- M.defaultMain theApp initialState
    return ()
