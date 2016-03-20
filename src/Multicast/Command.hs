{-# LANGUAGE DeriveGeneric #-}

module Multicast.Command where

import Data.Serialize
import GHC.Generics

type ClientId = Int
type MessagePort = Int

data Command
    = Register ClientId MessagePort
    | Unregister ClientId
    | Connect ClientId MessagePort
    | Disconnect ClientId
    | Send ClientId String
    deriving  (Eq, Show, Read, Generic)

instance Serialize Command
