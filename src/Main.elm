module Main exposing (..)

-- Standard library imports
import Html
import WebSocket
import Mouse

-- Library imports
import Json.Decode

-- Main imports
import View exposing (view)
import Model exposing (Model, init, MouseDragReceiver(..))
import Msg exposing (Msg(..))
import Sockets exposing (Message(..))
import CircularBuffer

-- Internal imports
import Types exposing
    ( Message(..)
    , messageDecoder
    )


-- Url of the websocket server
url : String
url = "ws://192.168.0.104:8765"

-- Update function

update : Msg -> Model -> (Model, Cmd Msg)
update msg model =
    case msg of
        NewMessage message ->
            let
                decoded = Json.Decode.decodeString messageDecoder message
            in
                case decoded of
                    Ok (NewReading reading) ->
                        ({model
                            | readings = CircularBuffer.push reading model.readings
                            , currentReading = reading
                        }, Cmd.none)
                    Ok (CurrentTime time) ->
                        let
                            oldReading = model.currentReading
                            newReading = {oldReading | time = time}
                        in
                            ({model | currentReading = newReading}, Cmd.none)
                    Err e ->
                        let
                            _ = Debug.log "Error decoding message: " e
                        in
                            (model, Cmd.none)
        TriggerModeSet mode ->
            ({model | triggerMode = mode} |> resetOffset, Cmd.none)
        TimeSpanSet val ->
            let
                asFloat = Result.withDefault model.timeSpan.value <| String.toFloat val
                oldSpan = model.timeSpan
            in
                ({model | timeSpan = { oldSpan | value = asFloat }} |> resetOffset, Cmd.none)
        TimeSpanUnitSet unit ->
            let
                oldSpan = model.timeSpan
            in
                ({model | timeSpan = { oldSpan | unit = unit }} |> resetOffset, Cmd.none)
        TriggerChannelSet index ->
            ({model | triggerChannel = index}, Cmd.none)
        ChannelToggled index ->
            let
                updateFunction i val =
                    if i == index then
                        not val
                    else
                        val
                activeChannels = List.indexedMap updateFunction model.activeChannels
            in
                ( { model | activeChannels = activeChannels}
                , Sockets.sendMessage url <| ActiveChannels activeChannels
                )
        ResetValues ->
            (Model.resetBuffer model, Cmd.none)
        MouseGlobalMove {clientPos} ->
            let
                (newX, _) = clientPos
                (oldX, _) = model.lastDragPos

                offsetChange = case model.mouseDragReceiver of
                    Just Graph ->
                        newX - oldX
                    _ ->
                        0
            in
                ( {model 
                    | lastDragPos = clientPos
                    , graphOffset = model.graphOffset + offsetChange
                  }
                , Cmd.none)
        MouseGlobalLeave _ ->
            ({model | mouseDragReceiver = Nothing}, Cmd.none)
        MouseGlobalUp _ ->
            ({model | mouseDragReceiver = Nothing}, Cmd.none)
        GraphClicked event ->
            ({model
                | mouseDragReceiver = Just Graph
                , lastDragPos = event.clientPos
            }, Cmd.none)



resetOffset : Model -> Model
resetOffset model =
    {model | graphOffset = 0}



-- Subscriptions

subscriptions : Model -> Sub Msg
subscriptions model =
    Sub.batch <|
        [ WebSocket.listen url NewMessage ]



main : Program Never Model Msg
main =
    Html.program
        { init = init
        , view = view
        , update = update
        , subscriptions = subscriptions
        }
