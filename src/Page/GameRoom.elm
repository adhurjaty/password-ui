module Page.GameRoom exposing (Model, Msg, init, update, view)

import Api exposing (urlBase)
import Browser.Navigation as Nav
import Components exposing (viewError)
import Components.TeamSelector as TeamSelector
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
    , teamSelector : TeamSelector.Model
    , startError : Maybe String
    }

type Msg
    = RoomReceived (WebData Room)
    | SelectorMsg TeamSelector.Msg

init : RoomId -> Nav.Key -> ( Model, Cmd Msg )
init roomId navKey =
    ( initialModel navKey, getRoom roomId )

initialModel : Nav.Key -> Model
initialModel navKey =
    { navKey =  navKey
    , room = RemoteData.Loading
    , teamSelector = TeamSelector.initialModel
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


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        RoomReceived room ->
            let
                selector = model.teamSelector
                updatedSelector = case room of
                    RemoteData.Success actualRoom ->
                        { selector | players = actualRoom.players }
                    _ ->
                        selector
            in
            ( { model | room = room, teamSelector = updatedSelector }, Cmd.none )
        SelectorMsg selectorMsg ->
            let
                room = model.room
                ( updatedModel, updatedCmd ) = 
                    TeamSelector.update selectorMsg model.teamSelector
                
                updatedRoom = RemoteData.map 
                    (\roomData ->
                        { roomData | players = updatedModel.players }
                    )
                    room
            in
            ( { model | teamSelector = updatedModel, room = updatedRoom }
            , Cmd.map SelectorMsg updatedCmd
            )
            

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
                    viewStartRoom actualRoom model.teamSelector

        RemoteData.Failure httpError ->
            httpError |> buildErrorMessage >> viewFetchError


viewStartRoom : Room -> TeamSelector.Model -> Html Msg
viewStartRoom room selectorModel =
    div [ class "start-game-content" ]
        [ div [] [ text "Room Code:"]
        , h1 [] [ text (Room.idToString room.id) ]
        , TeamSelector.view selectorModel 
            |> Html.map SelectorMsg
        ]

-- viewPlayers : List Player -> Html Msg
-- viewPlayers players =
--     div [ class "player-team-assignment" ]
--         ([ label [ class "team-label" ] [ text "Team 1" ]
--         , label [ class "team-label" ] [ text "Team 2" ]
--         ]
--         ++ List.map viewPlayer players 
--         )


-- viewPlayer : Player -> Html Msg
-- viewPlayer player =
--     div [ class "team-member-selection" ] [ text player.name ]

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


            
    
