module Components.TeamSelector exposing 
    ( Model
    , Msg
    , initialModel
    , update
    , view
    )

import DnDList
import Html exposing (..)
import Html.Attributes exposing (..)
import Player exposing (Player)


-- SYSTEM


config : DnDList.Config Player
config =
    { beforeUpdate = \_ _ list -> list
    , movement = DnDList.Free
    , listen = DnDList.OnDrag
    , operation = DnDList.Swap
    }


system : DnDList.System Player Msg
system =
    DnDList.create config MyMsg



-- MODEL


type alias Model =
    { dnd : DnDList.Model
    , players : List Player
    }


initialModel : Model
initialModel =
    { dnd = system.model
    , players = []
    }

-- UPDATE


type Msg
    = MyMsg DnDList.Msg


update : Msg -> Model -> ( Model, Cmd Msg )
update message model =
    case message of
        MyMsg msg ->
            let
                ( dnd, players ) =
                    system.update msg model.dnd model.players
                dummy = Debug.log "players" (String.join ", " (List.map (\player -> player.name) players))
            in
            ( { model | dnd = dnd, players = players }
            , system.commands model.dnd
            )


view : Model -> Html Msg
view model =
    div [ class "player-team-assignment" ]
        (
            [ label [ class "team-label" ] [ text "Team 1" ]
            , label [class "team-label" ] [ text "Team 2" ] 
            ]
            ++ List.indexedMap (itemView model.dnd) model.players
            ++ [ ghostView model.dnd model.players ]
        )


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
