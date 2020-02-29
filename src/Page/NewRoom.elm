module Page.NewRoom exposing (Model, Msg, init, view)

import Api exposing (urlBase)
import Browser.Navigation as Nav
import Components exposing (viewError)
import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (onClick, onInput)
import Http

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
    = StoreName String
    | CreateRoom
    | RoomCreated

view : Model -> Html Msg
view model =
    div [ class "new-room-wrapper" ]
        [ viewForm model
        , viewError model.createError
        ]

viewForm : Model -> Html Msg
viewForm model =
    Html.form []
        [ h1 [ class "password-header" ] [ text "Password" ]
        , input [ class "new-room-name-input"
                , type_ "text"
                , placeholder "Player Name"
                , value model.name
                , onInput StoreName
                ]
                []
        , button [ class "new-room-submit"
                , onClick CreateRoom
                , type_ "submit"
                ]
                [ text "Submit" ]
        ]

update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        StoreName name ->
            ( { model | name = name }, Cmd.none )            
    
        CreateRoom ->
            ( model, createRoom model.name )

        RoomCreated ->
            ( model, Cmd.none )

createRoom : String -> Cmd msg
createRoom name =
    Http.post
        { url = urlBase ++ "rooms/new"
        , body = Http.jsonBody (newRoomEncoder name)
        , expect = Http.expectJson RoomCreated roomEncoder
        }


            
    
