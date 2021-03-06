module Page.GameRoom exposing (Model, Msg, init, update, view)

import Api exposing (urlBase)
import Browser.Navigation as Nav
import Components exposing (viewError)
import DnDList
import Error exposing (buildErrorMessage)
import Game exposing (Game)
import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Keyed
import Http
import Player exposing (Player)
import RemoteData exposing(WebData)
import Room exposing (Room, RoomId, roomDecoder)
import Team exposing (Team)


config : DnDList.Config Player
config =
    { beforeUpdate = \_ _ list -> list
    , movement = DnDList.Free
    , listen = DnDList.OnDrag
    , operation = DnDList.Swap
    }


system : DnDList.System Player Msg
system =
    DnDList.create config DndMsg


type alias Model =
    { navKey : Nav.Key
    , room : WebData Room
    , dnd : DnDList.Model
    , startError : Maybe String
    }

type Msg
    = RoomReceived (WebData Room)
    | DndMsg DnDList.Msg

init : RoomId -> Nav.Key -> ( Model, Cmd Msg )
init roomId navKey =
    ( initialModel navKey, getRoom roomId )

initialModel : Nav.Key -> Model
initialModel navKey =
    { navKey =  navKey
    , room = RemoteData.Loading
    , dnd = system.model
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
            ( { model | room = room }, Cmd.none )
        DndMsg message ->
            let
                room = model.room
            in
            case room of
                RemoteData.Success actualRoom ->
                    let
                        ( dnd, players ) =
                            system.update message model.dnd actualRoom.players

                        updatedRoom = RemoteData.map 
                            (\roomData -> 
                                { roomData | players = players }
                            ) room
                        -- dummy = Debug.log "players" (String.join ", " (List.map (\player -> player.name) players))
                    in
                    ( { model | dnd = dnd, room = updatedRoom }
                    , system.commands model.dnd
                    )
                _ ->
                    ( model, Cmd.none )
            
            
            

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
                    viewStartRoom actualRoom model.dnd

        RemoteData.Failure httpError ->
            httpError |> buildErrorMessage >> viewFetchError


viewStartRoom : Room -> DnDList.Model -> Html Msg
viewStartRoom room dndModel =
    div [ class "start-game-content" ]
        [ div [] [ text "Room Code:"]
        , h1 [] [ text (Room.idToString room.id) ]
        , viewPlayers room.players dndModel
        ]

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


viewPlayers : List Player -> DnDList.Model -> Html Msg
viewPlayers players dnd =
    div [ class "player-team-assignment" ]
        (
            [ label [ class "team-label" ] [ text "Team 1" ]
            , label [class "team-label" ] [ text "Team 2" ] 
            ]
            ++ List.indexedMap (itemView dnd) players
            ++ [ ghostView dnd players ]
        )

-- viewPlayers : List Player -> DnDList.Model -> Html Msg
-- viewPlayers players dnd =
--     section []
--         [ players
--             |> List.indexedMap (itemView dnd)
--             |> Html.Keyed.node "div" containerStyles
--         , ghostView dnd players
--         ]


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


itemView : DnDList.Model -> Int -> Player -> Html Msg
itemView dnd index player =
    let
        itemId : String
        itemId =
            "id-" ++ player.name
    in
    case system.info dnd of
        Just { dragIndex } ->
            if dragIndex /= index then
                div
                    (id itemId :: itemStyles green ++ system.dropEvents index itemId)
                    [ text player.name ]

            else
                div
                    (id itemId :: itemStyles "dimgray")
                    []

        Nothing ->
            div
                (id itemId :: itemStyles green ++ system.dragEvents index itemId)
                [ text player.name ]


ghostView : DnDList.Model -> List Player -> Html Msg
ghostView dnd players =
    let
        maybeDragItem : Maybe Player
        maybeDragItem =
            system.info dnd
                |> Maybe.andThen (\{ dragIndex } -> players |> List.drop dragIndex |> List.head)
    in
    case maybeDragItem of
        Just player ->
            div
                (itemStyles ghostGreen ++ system.ghostStyles dnd)
                [ text player.name ]

        Nothing ->
            text ""
            

-- COLORS


green : String
green =
    "#3da565"


ghostGreen : String
ghostGreen =
    "#2f804e"



-- STYLES

containerStyles : List (Html.Attribute msg)
containerStyles =
    [ Html.Attributes.style "display" "flex"
    , Html.Attributes.style "flex-wrap" "wrap"
    , Html.Attributes.style "align-items" "center"
    , Html.Attributes.style "justify-content" "center"
    , Html.Attributes.style "padding-top" "2em"
    ]

itemStyles : String -> List (Attribute msg)
itemStyles color =
    [ style "width" "100%"
    , style "height" "4em"
    , style "background-color" color
    , style "border-radius" "8px"
    , style "color" "white"
    , style "cursor" "pointer"
    , style "display" "flex"
    , style "align-items" "center"
    , style "justify-content" "center"
    ]

