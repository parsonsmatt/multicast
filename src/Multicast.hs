{-# LANGUAGE BangPatterns #-}
{-# LANGUAGE RankNTypes #-}

module Multicast where

import System.IO
import Data.Monoid
import Control.Monad
import Control.Exception
import Control.Concurrent
import Network.Socket

server :: IO ()
server = do
    bracket (do
        sock <- socket AF_INET Stream 0
        setSocketOption sock ReuseAddr 1
        bind sock (SockAddrInet 4242 iNADDR_ANY)
        listen sock 2
        return sock
            )
            close
            (\sock -> do
        chan <- newChan
        _ <- forkIO $ forever $ do
            (_, msg) <- readChan chan
            putStrLn ("[Server]: " <> msg)

        mainLoop sock chan 0
            )

mainLoop :: Socket -> Chan (Int, String) -> Int -> IO ()
mainLoop sock chan !msgNum = do
    conn <- accept sock
    _ <- forkIO $ runConn conn chan msgNum
    mainLoop sock chan $! msgNum + 1

runConn :: (Socket, a) -> Chan (Int, String) -> Int -> IO ()
runConn (sock, _) chan !msgNum = do
    hdl <- socketToHandle sock ReadWriteMode
    hSetBuffering hdl NoBuffering

    hPutStrLn hdl "Hi, what's your name?"
    name <- hGetLine hdl
    let broadcast msg = writeChan chan (msgNum, name <> ": " <> msg)
    broadcast $ "<-- entered chat."
    hPutStrLn hdl $ "Welcome, " <> name <> "!"

    commLine <- dupChan chan

    bracket (forkIO $ forever $ do
                (nextNum, line) <- readChan commLine
                when (msgNum /= nextNum) $ hPutStrLn hdl line
            )
            (\thread -> do
                killThread thread
                hClose hdl
                broadcast $ "<-- " <> name <> " left."
            )
            (const . forever $ hGetLine hdl >>= broadcast)
