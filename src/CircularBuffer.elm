module CircularBuffer exposing
    ( CircularBuffer
    , new
    , intoList
    , push
    )

import Array exposing (Array)


type alias CircularBuffer a =
    { current: Int
    , data: Array (Maybe a)
    , size: Int
    }


new : Int -> CircularBuffer a
new size =
    { current = 0
    , data = Array.initialize size (\_ -> Nothing)
    , size = size
    }



intoList : CircularBuffer a -> List a
intoList {current, data, size} =
    let
        -- Generate a list of indices to use
        indices = List.map (\i -> ((i + current) % size)) <| List.range 0 (size-1)
    in
        List.filterMap (\i -> Maybe.withDefault Nothing <| Array.get i data) indices



push : a -> CircularBuffer a -> CircularBuffer a
push elem {current, data, size} =
    { current = (current + 1) % size
    , data = Array.set current (Just elem) data
    , size = size
    }
