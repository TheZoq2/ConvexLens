module Sockets exposing (Message(..), sendMessage)

import Json.Encode as Encode
import WebSocket

type Message
    = ActiveChannels (List Bool)


encodeMessage : Message -> Encode.Value
encodeMessage msg =
        case msg of
            ActiveChannels channels -> 
                Encode.object
                    [ ("ActiveChannels"
                      , Encode.list <| List.map Encode.bool channels
                      )
                    ]

sendMessage : String -> Message -> Cmd msg
sendMessage url message =
    WebSocket.send url <| Encode.encode 0 <| encodeMessage message


