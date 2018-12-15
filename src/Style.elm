module Style exposing (..)

-- Standard library imports
import Dict exposing (Dict)

-- External imports
import Css exposing (..)
import Css.Global
import Html.Styled exposing (..)

-- Project imports




-- Common styles

globalStyle : Html msg
globalStyle =
    Css.Global.global
        [ Css.Global.body
            [ backgroundColor (hex "0b151d")
            ]
        ]
    

{-|
  Applied to the outer div of the body
-}
contentContainer : List (Attribute msg) -> List (Html msg) -> Html msg
contentContainer =
    styled div
        [ fontFamilies ["sans-serif"]
        , color (hex "fff")
        ]



{-|
  Applied to each 'card' in the page
-}
valueContainerItem : List (Attribute msg) -> List (Html msg) -> Html msg
valueContainerItem =
    styled div
        [ padding (px 5)
        , margin (px 5)
        , boxShadow4 (px 2) (px 2) (px 5) (hex "aaa")
        , backgroundColor (hex "fff")
        ]



graphContainer : List (Attribute msg) -> List (Html msg) -> Html msg
graphContainer =
    styled div
        [ margin2 (px 10) (px 0)
        , Css.Global.descendants
            [ Css.Global.polyline
                [ property "stroke-width" "2px"
                , property "stroke" "#ff4545"
                ]
            ]
        ]


buttonRow : List (Attribute msg) -> List (Html msg) -> Html msg
buttonRow =
    styled div
        [ margin2 (px 5) zero
        , displayFlex
        , flexWrap wrap
        , Css.Global.children
            [ Css.Global.div
                [ padding2 (px 7) (px 0)
                , float left
                , margin2 (px 0) (px 10)
                , Css.Global.children
                    [ Css.Global.label
                        [ display block
                        , fontSize (px 13)
                        , margin2 (px 3) (px 0)
                        ]
                    ]
                ]
            ]
        ]



inputField : List (Attribute msg) -> List (Html msg) -> Html msg
inputField =
    styled input
        [ border (px 0)
        , padding (px 5)
        , borderBottom3 (px 3) solid (rgb 142 42 186)
        , backgroundColor (hex "#0b151d")
        , color (hex "#fff")
        ]



{-|
  A button with the standard look for the project
-}
styledButton : List (Attribute msg) -> List (Html msg) -> Html msg
styledButton =
    styled button
        [ borderRadius (px 2)
        , padding2 (px 7) (px 8)
        , paddingBottom (px 0)
        , boxShadow4 (px 2) (px 2) (px 2) (hex "000")
        , margin (px 3)
        , hover
            [ borderBottomColor (rgb 207 161 227)]
        , color (hex "fff")
        , backgroundColor (hex "083253")
        ]



unselectedButton : List (Attribute msg) -> List (Html msg) -> Html msg
unselectedButton =
    styled styledButton
        [ borderTop (px 0)
        , borderLeft (px 0)
        , borderRight (px 0)
        , borderBottom3 (px 4) solid (rgba 0 0 0 0)
        ]

selectedButton : List (Attribute msg) -> List (Html msg) -> Html msg
selectedButton =
    styled styledButton
        [ borderTop (px 0)
        , borderLeft (px 0)
        , borderRight (px 0)
        , borderBottom3 (px 3) solid (rgb 142 42 186)
        ]
