{-# LANGUAGE DeriveGeneric #-}

module Multicast.Command
    ( module S
    , module Multicast.Command
    ) where

import           Data.Serialize as S
import           GHC.Generics

type ClientId = Int
type MessagePort = Int

data Command
    = Register
    | Unregister
    | Connect
    | Disconnect
    | Send String
    deriving  (Eq, Show, Read, Generic)

data Message
    = Message
    { command     :: Command
    , respondPort :: ClientId
    } deriving (Eq, Show, Generic)

instance Serialize Command

instance Serialize Message
