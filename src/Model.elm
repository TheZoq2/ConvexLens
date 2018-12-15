module Model exposing (Model, init, MouseDragReceiver(..), resetBuffer)

import Types exposing (Reading, TriggerMode(..))
import TimeUnits exposing (Time, TimeUnit(..))
import Msg exposing (Msg)
import CircularBuffer exposing (CircularBuffer)


circularBufferSize : Int
circularBufferSize = 200

-- Helper types
type MouseDragReceiver
    = Graph

-- Model and init

type alias Model =
    { readings: CircularBuffer Reading
    , currentReading: Reading
    , triggerMode: TriggerMode
    , timeSpan: Time
    , triggerChannel: Int
    , mouseDragReceiver: Maybe MouseDragReceiver
    , lastDragPos: (Float, Float)
    , graphOffset: Float
    }


init : (Model, Cmd Msg)
init =
    ( { readings = CircularBuffer.new circularBufferSize
      , currentReading = (Reading [False, False] 400)
      , triggerMode = FallingEdge
      , timeSpan = Time Millisecond 1
      , triggerChannel = 1
      , mouseDragReceiver = Nothing
      , lastDragPos = (0,0)
      , graphOffset = 0
    }
    , Cmd.none
    )



resetBuffer : Model -> Model
resetBuffer model =
    {model | readings = CircularBuffer.new circularBufferSize}
