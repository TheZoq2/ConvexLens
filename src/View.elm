module View exposing (view)

-- Standard library imports

import Html
import Html.Styled exposing (..)
import Html.Styled.Events exposing (..)
import Html.Styled.Attributes exposing (..)
import Svg.Styled as Svg exposing (svg)
import Svg.Styled.Attributes as SvgAttributes exposing (viewBox)

-- External imports

import List.Extra
import Mouse
import Graph

-- Main imports

import Msg exposing (Msg(..))
import Model exposing (Model)

-- Project imports

import Types exposing 
    ( TriggerMode(..)
    , readingsToChannels
    , allTriggerModes
    , triggerModeSymbol
    )
import TimeUnits exposing 
    ( toMicroseconds
    , allTimeUnits
    , timeUnitString
    , TimeUnit
    )
import Signal exposing (continuousRead, isRisingEdge, isFallingEdge, edgeTrigger)
import CircularBuffer
import Style





stepPreprocessor : List (Float, Bool) -> List (Float, Bool)
stepPreprocessor original =
    let
        duplicated = List.Extra.interweave original original

        (times, values) = List.unzip duplicated

        shiftedTimes = List.drop 1 times
    in
        List.Extra.zip shiftedTimes values


trigFunction : TriggerMode -> (Bool -> Bool -> Bool)
trigFunction mode =
    case mode of
        Continuous -> continuousRead
        RisingEdge -> isRisingEdge
        FallingEdge -> isFallingEdge


timeUnitSelector : TimeUnit -> (TimeUnit -> Msg) -> List (Html Msg)
timeUnitSelector currentUnit msg =
    singleChoiseSelector currentUnit allTimeUnits timeUnitString msg


singleChoiseSelector : a -> List a -> (a -> String) -> (a -> Msg) -> List (Html Msg)
singleChoiseSelector current choises nameFunction msg =
    List.map
        (\alternative ->
            (if alternative == current then Style.selectedButton else Style.unselectedButton)
                [ onClick (msg alternative)
                ]
                [ text <| nameFunction alternative
                ]
        )
        choises


drawGraph : (Int, Int) -> (Float, Float) -> List (Float, Bool) -> Html Msg
drawGraph (viewWidth, viewHeight) valueRange readingList =
    Style.graphContainer [Html.Styled.Attributes.fromUnstyled <| Mouse.onDown GraphClicked]
        [ Svg.svg
            [ SvgAttributes.viewBox <| "0 0 " ++ (toString viewWidth) ++ " " ++ (toString viewHeight)
            , SvgAttributes.width <| toString viewWidth ++ "px"
            , SvgAttributes.height <| toString viewHeight ++ "px"
            ]
            [ Svg.fromUnstyled <| Graph.drawHorizontalLines (viewWidth, viewHeight) (0,1) 1
            , Svg.fromUnstyled <| Graph.drawGraph (viewWidth, viewHeight) (0,1) valueRange
              <| List.map (\(time, val) -> if val then (time, 1) else (time, 0)) readingList
            ]
        ]


view : Model -> Html.Html Msg
view model =
    let
        readings = List.map stepPreprocessor 
            <| readingsToChannels
            <| (CircularBuffer.intoList model.readings) ++ [model.currentReading]


        valueRange = edgeTrigger
            (trigFunction model.triggerMode)
            (toMicroseconds model.timeSpan)
            (Maybe.withDefault [] <| List.Extra.getAt model.triggerChannel readings)

        graphViewX = 600
        graphViewY = 50
        graphViewSize = (graphViewX, graphViewY)

        -- Calculate the graph offset
        graphOffset = 
            model.graphOffset / graphViewX * (Tuple.second valueRange - Tuple.first valueRange)

        (displayMin, displayMax) = valueRange
        displayRange = (displayMin - graphOffset, displayMax - graphOffset)

        graphFunction = drawGraph graphViewSize displayRange


        triggerModeButtons = 
                singleChoiseSelector
                    model.triggerMode
                    allTriggerModes
                    triggerModeSymbol
                    TriggerModeSet

        triggerModeRow = div []
            (  [label [] [text ("Trigger mode: ")]]
            ++ triggerModeButtons
            )

        timeSpanSelection =
            div
                []
                ([ label [] [text "Time range: "]
                , Style.inputField 
                    [onInput TimeSpanSet, placeholder (toString model.timeSpan.value)]
                    []
                ]
                ++ timeUnitSelector model.timeSpan.unit TimeSpanUnitSet
                )

        triggerChannelSelector =
            div []
                ( [label [] [text "TriggerChannel: "]]
                ++ ( singleChoiseSelector
                    model.triggerChannel
                    (List.range 0 <| (List.length readings) - 1)
                    toString
                    TriggerChannelSet
                  )
                )

        buttonRow = [div [] [button [onClick ResetValues] [text "Reset"]]]
    in
        toUnstyled <| contentContainer model
            <|  [ Style.buttonRow []
                    [ triggerModeRow
                    , triggerChannelSelector
                    , timeSpanSelection
                    ]
                ]
                ++
                (List.map graphFunction readings)
                ++
                buttonRow
                ++
                [Style.globalStyle]



contentContainer : Model -> List (Html Msg) -> Html Msg
contentContainer model children =
    let
        eventListeners =
            if model.mouseDragReceiver == Nothing then
                []
            else
                [ Html.Styled.Attributes.fromUnstyled <| Mouse.onMove MouseGlobalMove
                , Html.Styled.Attributes.fromUnstyled <| Mouse.onUp MouseGlobalUp
                , Html.Styled.Attributes.fromUnstyled <| Mouse.onLeave MouseGlobalLeave
                ]
    in
    Style.contentContainer
        eventListeners
        children

