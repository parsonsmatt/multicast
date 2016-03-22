# multicast

[![Build Status](https://travis-ci.org/parsonsmatt/multicast.png)](https://travis-ci.org/parsonsmatt/multicast)

A toy implementation of a multicast messaging server. The messaging has
a time-restricted asynchronous/persistent model, so if you register and
disconnect, you'll still receive messages up to `n` seconds ago.

## Client

The client implements a UI in the excellent `brick` library. It has the
relatively simple job of parsing user input, sending commands to the server,
and printing the messages out as they come in.

## Server

The server main loop will have the following design:

1. Accept a client connection and fork a thread to handle it.
2. For the client connection, accept a command, parse it, acknowledge it, and
   close the connection.
3. If the command was a message to send, distribute it to all of the registered
   clients.
4. For each registered client, keep an actor running which receives distributed
   messages and attempts to send them to the client. Each registered client
   will have an MVar containing a socket that enables sending of messages.
5. To enable the time-restriction, the registered clients will filter messages
   out of the queue if they're too old.
