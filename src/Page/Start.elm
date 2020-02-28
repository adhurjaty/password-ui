module Page.Start exposing (Model, Msg, init, view)

import Html exposing (..)
import Html.Attributes exposing (..)

type alias Model =
    { }

init : ( Model, Cmd Msg )
init =
    ( initialModel, Cmd.none )

initialModel : Model
initialModel =
    {}

view : Model -> Html Msg
view _ =
    let
        newRoomPath = 
            "rooms/new"
        joinRoomPath =
            "rooms/join"
    in
    div [ class "start-wrapper" ]
        [ h1 [ class "password-header" ] [ text "Password" ]
        , a [ href newRoomPath, class "start-create-button button" ] [ text "Create New Room" ]
        , a [ href joinRoomPath, class "start-join-button button" ] [ text "Join Room" ]
        ]

type Msg
    = NoOp
    

