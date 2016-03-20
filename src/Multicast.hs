module Multicast where

import System.IO
import Control.Monad
import Data.Function
import Control.Exception
import Control.Concurrent
import Control.Concurrent.Chan
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
        forkIO $ fix $ \loop -> do
            (_, msg) <- readChan chan
            loop

        mainLoop sock chan 0
            )

mainLoop sock chan msgNum = do
    conn <- accept sock
    _ <- forkIO $ runConn conn chan msgNum
    mainLoop sock chan $! msgNum + 1

runConn (sock, _) chan msgNum = do
    hdl <- socketToHandle sock ReadWriteMode
    hSetBuffering hdl NoBuffering

    hPutStrLn hdl "Hi, what's your name?"
    name <- hGetLine hdl
    let broadcast msg = writeChan chan (msgNum, name ++ ": " ++ msg)
    broadcast $ "--> " ++ name ++ " entered chat."
    hPutStrLn hdl $ "Welcome, " ++ name ++ "!"

    commLine <- dupChan chan

    bracket (forkIO $ fix $ \go -> do
        (nextNum, line) <- readChan commLine
        when (msgNum /= nextNum) $ hPutStrLn hdl line
        go)
        (\thread -> do
            killThread thread
            hClose hdl
            broadcast $ "<-- " ++ name ++ " left.")
        (\_ -> fix $ \go -> do
            line <- hGetLine hdl
            broadcast line
            go)
