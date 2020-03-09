module Page.NewRoom exposing (Model, Msg, init, view, update)

import Api exposing (urlBase)
import Browser.Navigation as Nav
import Components exposing (viewError)
import Error exposing (buildErrorMessage)
import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (onClick, onInput)
import Http
import Player exposing (PlayerId, emptyPlayerId)
import Room exposing (Room, RoomId, NewRoom, emptyRoomId, newRoomEncoder, newRoomDecoder)
import Route

type alias Model =
    { navKey : Nav.Key
    , room : NewRoom
    , createError : Maybe String
    }

init : Nav.Key -> ( Model, Cmd Msg)
init navKey =
    ( initialModel navKey, Cmd.none )

initialModel : Nav.Key -> Model
initialModel navKey =
    { navKey = navKey
    , room = initNewRoom
    , createError = Nothing
    }

initNewRoom : NewRoom
initNewRoom =
    { id = emptyRoomId
    , playerId = emptyPlayerId
    , playerName = ""
    }

type Msg
    = StoreName String
    | CreateRoom
    | RoomCreated (Result Http.Error NewRoom)

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
                , value model.room.playerName
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
            let
                oldRoom = model.room
                newRoom = { oldRoom | playerName = name }
            in
            ( { model | room = newRoom }, Cmd.none )            
    
        CreateRoom ->
            ( model, createRoom model.room.playerName )

        RoomCreated (Ok newRoom) ->
            ( { model | room = newRoom, createError = Nothing }
            , Route.pushUrl (Route.GameRoom newRoom.id) model.navKey )

        RoomCreated (Err error) ->
            ( {model | createError = Just (buildErrorMessage error) }
            , Cmd.none
            )

createRoom : String -> Cmd Msg
createRoom name =
    Http.post
        { url = urlBase ++ "rooms/new"
        , body = Http.jsonBody (newRoomEncoder name)
        , expect = Http.expectJson RoomCreated newRoomDecoder
        }

          
    
