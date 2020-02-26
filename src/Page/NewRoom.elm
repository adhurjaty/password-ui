module Page.NewRoom exposing (view)

import Browser.Navigation as Nav
import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (onClick)

type alias Model =
    { navKey : Nav.Key
    , name : String
    , createError : Maybe String
    }

init : Nav.Key -> ( Model, Cmd Msg)
init navKey =
    ( initialModel navKey, Cmd.none )

initialModel : Nav.Key -> Model
initialModel navKey =
    { navKey = navKey
    , name = ""
    , createError = Nothing
    }

type Msg
    = StoreName
    | CreateRoom
    | RoomCreated

view : Model -> Html Msg
view model =
    div [ class "new-room-wrapper" ]
        [ h1 [ class "password-header" ] [ text "Passwrod" ]
        , input [ class "new-room-name-input"
                , type_ "text"
                , placeholder "Player Name"
                ]
                []
        ]
