module Page.GameRoom exposing (Model, Msg, init, update, view)

import Api exposing (urlBase)
import Browser.Navigation as Nav
import Components exposing (viewError)
import Error exposing (buildErrorMessage)
import Game exposing (Game)
import Html exposing (..)
import Html.Attributes exposing (..)
import Http
import Player exposing (Player)
import RemoteData exposing(WebData)
import Room exposing (Room, RoomId, roomDecoder)
import Team exposing (Team)

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


-- view : Model -> Html Msg
-- view model =
--     div [ class "game-room-wrapper"]
--         ( viewRoom model.room ++ [ viewError model.startError ] )
        

view : Model -> Html Msg
view model =
    let
        room = model.room
    in
    case room of
        RemoteData.NotAsked ->
            div [] [ text "" ]

        RemoteData.Loading ->
            div [ class "loading-message" ] [ text "Loading..." ]
    
        RemoteData.Success actualRoom ->
            let
                maybeGame = actualRoom.game
            in
            case maybeGame of
                Just game ->
                    viewGameRoom actualRoom game
            
                Nothing ->
                    viewStartRoom actualRoom

        RemoteData.Failure httpError ->
            httpError |> buildErrorMessage >> viewFetchError


viewStartRoom : Room -> Html Msg
viewStartRoom room =
    div [ class "start-game-content" ]
        [ div [] [ text "Room Code:"]
        , h1 [] [ text (Room.idToString room.id) ]
        , viewPlayers room.players
        ]

viewPlayers : List Player -> Html Msg
viewPlayers players =
    div [ class "player-team-assignment" ]
        ([ label [ class "team-label" ] [ text "Team 1" ]
        , label [ class "team-label" ] [ text "Team 2" ]
        ]
        ++ List.map viewPlayer players 
        )


viewPlayer : Player -> Html Msg
viewPlayer player =
    div [ class "team-member-selection" ] [ text player.name ]

viewGameRoom : Room -> Game -> Html Msg
viewGameRoom room game =
    div [ class "game-room-wrapper" ]
        [ div [ class "round-indicator" ] 
            [ text ("Round: " ++ String.fromInt game.round) ]
        , div [ class "scoreboard" ]
            (viewTeamScores game.teams game.turn)
        , div [ class "game-info-section"]
            [ div [ class "point-indicator" ] 
                [ text ("Points: " ++ String.fromInt game.pendingScore) ]
            , div [ class "word-section" ] [ text game.word ]
            , div [ class "answer-buttons" ]
                [ button [ class "answer-button wrong-button" ] [ text "Wrong" ]
                , button [ class "answer-button right-button" ] [ text "Right" ]
                ]
            ]
        , div [ class "room-code" ] 
            [ text ("Room Code: " ++ Room.idToString room.id) ]
        ]


viewTeamScores : List Team -> Int -> List (Html Msg)
viewTeamScores teams turn =
    List.indexedMap (viewTeamScore turn) teams


viewTeamScore : Int -> Int -> Team -> Html Msg
viewTeamScore turn idx team =
    let
        turnClass = 
            if idx == turn then
                " score-turn"
            else
                ""
    in
    div [ class ("team-score-section" ++ turnClass) ]
        [ div [ class "team-name-display" ] [ text (Team.name team) ]
        , div [ class "score-display" ] [ text (String.fromInt team.score) ]
        ]


viewFetchError : String -> Html Msg
viewFetchError errorMessage =
    let
        errorHeading =
            "Couldn't fetch posts at this time"    
    in
    div [ class "error-content" ]
        [ h3 [] [text errorHeading ]
        , text ("Error: " ++ errorMessage)
        ]


            
    
