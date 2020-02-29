module Components exposing (..)

import Html exposing (..)
import Html.Attributes exposing (..)

viewError : Maybe String -> Html msg
viewError maybeString =
    case maybeString of
        Just error ->
            div [ class "form-error" ]
                [ text ("Error: " ++ error) ]
    
        Nothing ->
            text ""
    
