module Page.Start exposing (Model, init, view)

import Html exposing (..)
import Html.Attributes exposing (..)

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
    div [ class "start-wrapper" ]
        [ h1 [ class "start-header" ] [ text "Password" ]
        , a [ href newRoomPath, class "start-create-button button" ] [ text "Create New Room" ]
        , a [ href joinRoomPath, class "start-join-button button" ] [ text "Join Room" ]
        ]
    

