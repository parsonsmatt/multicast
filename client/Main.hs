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

    _ <- forkIO $ forever $ do
        resp <- prompt "> "
        case parseCommand resp of
             Just cmd ->
                 case cmd of
                      Send str -> hPutStrLn h str
                      _ -> hPrint h cmd
             Nothing -> putStrLn "lol fail"
        hPutStrLn h resp

    forever $ do
        p <- hGetLine h
        putStrLn p


prompt :: String -> IO String
prompt s = do
    putStr s
    hFlush stdout
    getLine

parseCommand :: String -> Maybe Command
parseCommand ('/' : rest) =
    case words rest of
         ["connect"] -> Just Connect
         ["disconnect"] -> Just Disconnect
         ["register"] -> Just Register
         ["unregister"] -> Just Unregister
         _ -> Nothing
parseCommand msg = Just (Send msg)

