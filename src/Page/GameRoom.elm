module Page.GameRoom exposing (Model, Msg, init, update, view)

import Api exposing (urlBase)
import Browser.Navigation as Nav
import Components exposing (viewError)
import Error exposing (buildErrorMessage)
import Html exposing (..)
import Html.Attributes exposing (..)
import Http
import Player exposing (Player)
import RemoteData exposing(WebData)
import Room exposing (Room, RoomId, roomDecoder)

type alias Model =
    { navKey : Nav.Key
    , room : WebData Room
    , startError : Maybe String
    }

type Msg
    = RoomReceived (WebData Room)

init : RoomId -> Nav.Key -> ( Model, Cmd Msg )
init roomId navKey =
    ( initialModel navKey, getRoom roomId )

initialModel : Nav.Key -> Model
initialModel navKey =
    { navKey =  navKey
    , room = RemoteData.Loading
    , startError = Nothing
    }

getRoom : RoomId -> Cmd Msg
getRoom roomId =
    Http.get
        { url = urlBase ++ "rooms/" ++ Room.idToString roomId
        , expect = 
            roomDecoder
                |> Http.expectJson (RemoteData.fromResult >> RoomReceived)
        }


update : Msg -> Model -> ( Model, Cmd Msg)
update msg model =
    case msg of
        RoomReceived room ->
            ( { model | room = room }, Cmd.none )


view : Model -> Html Msg
view model =
    div [ class "start-room-wrapper"]
        ( viewRoom model.room ++ [ viewError model.startError ] )
        

viewRoom : WebData Room -> List (Html Msg)
viewRoom room =
    case room of
        RemoteData.NotAsked ->
            [ text "" ]

        RemoteData.Loading ->
            [ text "Loading..." ]
    
        RemoteData.Success actualRoom ->
            let
                game = actualRoom.game
            in
            case game of
                Just game ->
                    viewGameRoom actualRoom game
            
                Nothing ->
                    viewStartRoom actualRoom

        RemoteData.Failure httpError ->
            httpError |> buildErrorMessage >> viewFetchError


viewStartRoom : Room -> List (Html Msg)
viewStartRoom room =
    [ h3 [] [ text "Room Code"]
    , h1 [] [ text (Room.idToString room.id) ]
    , viewPlayers room.players
    ]

viewPlayers : List Player -> Html Msg
viewPlayers players =
    ul []
        ( List.map viewPlayer players )


viewPlayer : Player -> Html Msg
viewPlayer player =
    li [] [ text player.name ]

viewGameRoom : Room -> Game -> List (Html Msg)
viewGameRoom room game =
    [ div [] 
        [ text "Round: " ++ game.round ]
    , div []
        viewTeamScores game.teams
    , div []
        [ div [] 
            [ text "Points: " ++ game.pendingScore ]
        , h1 [] [ text game.word ]
        , div []
            [ button [] [ text "Wrong" ]
            , button [] [ text "Right" ]
            ]
        ]
    , div [] 
        [ text "Room Code:"
        , br [] []
        , text Room.idToString room.id
        ]
    ]


viewFetchError : String -> List (Html Msg)
viewFetchError errorMessage =
    let
        errorHeading =
            "Couldn't fetch posts at this time"    
    in
    [ h3 [] [text errorHeading ]
    , text ("Error: " ++ errorMessage)
    ]


            
    
