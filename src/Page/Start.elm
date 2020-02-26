module Page.Start exposing (Model, init, view)

import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (onClick)

type alias Model =
    { }

init : ( Model, Cmd msg )
init =
    ( initialModel, Cmd.none )

initialModel : Model
initialModel =
    {}

view : Model -> Html msg
view _ =
    let
        newRoomPath = 
            "rooms/new"
        joinRoomPath =
            "rooms/join"
    in
    div []
        [ h1 [] [ text "Password" ]
        , a [ href newRoomPath ] [ text "Create New Room" ]
        , a [ href joinRoomPath ] [ text "Join Room" ]
        ]
    

