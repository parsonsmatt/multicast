module Main where

import Network.Socket
import Control.Monad
import Control.Concurrent
import System.IO
import Multicast.Command

main :: IO ()
main = do
    putStrLn "~~ Multicast Client ~~"
    putStrLn "Connecting to server..."
    sock <- socket AF_INET Stream 0
    setSocketOption sock ReuseAddr 1
    addr <- head <$> getAddrInfo Nothing (Just "127.0.0.1") (Just "4242")
    connect sock (addrAddress addr)
    h <- socketToHandle sock ReadWriteMode
    askForName <- hGetLine h
    name <- prompt askForName
    hPutStrLn h name

    forkIO $ forever $ do
        resp <- prompt ""
        hPutStrLn h resp

    forever $ do
        p <- hGetLine h
        putStrLn p


prompt s = do
    putStr $ s ++ "> "
    hFlush stdout
    getLine
