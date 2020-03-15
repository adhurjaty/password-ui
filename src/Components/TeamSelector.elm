module Components.TeamSelector exposing 
    ( Model
    , Msg
    , init
    , update
    , view
    )

import DnDList
import Html
import Html.Attributes
import Html.Keyed
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
    , items : List Player
    }


initialModel : Model
initialModel =
    { dnd = system.model
    , items = []
    }


init : () -> ( Model, Cmd Msg )
init _ =
    ( initialModel, Cmd.none )


-- UPDATE


type Msg
    = MyMsg DnDList.Msg


update : Msg -> Model -> ( Model, Cmd Msg )
update message model =
    case message of
        MyMsg msg ->
            let
                ( dnd, items ) =
                    system.update msg model.dnd model.items
            in
            ( { model | dnd = dnd, items = items }
            , system.commands model.dnd
            )



-- VIEW


view : Model -> Html.Html Msg
view model =
    Html.section []
        [ model.items
            |> List.indexedMap (itemView model.dnd)
            |> Html.Keyed.node "div" containerStyles
        , ghostView model.dnd model.items
        ]


itemView : DnDList.Model -> Int -> Player -> ( String, Html.Html Msg )
itemView dnd index player =
    let
        itemId : String
        itemId =
            "id-" ++ player.name
    in
    case system.info dnd of
        Just { dragIndex } ->
            if dragIndex /= index then
                ( player.name
                , Html.div
                    (Html.Attributes.id itemId :: itemStyles green ++ system.dropEvents index itemId)
                    [ Html.text player.name ]
                )

            else
                ( player.name
                , Html.div
                    (Html.Attributes.id itemId :: itemStyles "dimgray")
                    []
                )

        Nothing ->
            ( player.name
            , Html.div
                (Html.Attributes.id itemId :: itemStyles green ++ system.dragEvents index itemId)
                [ Html.text player.name ]
            )


ghostView : DnDList.Model -> List Player -> Html.Html Msg
ghostView dnd items =
    let
        maybeDragItem : Maybe Player
        maybeDragItem =
            system.info dnd
                |> Maybe.andThen (\{ dragIndex } -> items |> List.drop dragIndex |> List.head)
    in
    case maybeDragItem of
        Just player ->
            Html.div
                (itemStyles ghostGreen ++ system.ghostStyles dnd)
                [ Html.text player.name ]

        Nothing ->
            Html.text ""



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


itemStyles : String -> List (Html.Attribute msg)
itemStyles color =
    [ Html.Attributes.style "width" "5rem"
    , Html.Attributes.style "height" "5rem"
    , Html.Attributes.style "background-color" color
    , Html.Attributes.style "border-radius" "8px"
    , Html.Attributes.style "color" "white"
    , Html.Attributes.style "cursor" "pointer"
    , Html.Attributes.style "margin" "0 2em 2em 0"
    , Html.Attributes.style "display" "flex"
    , Html.Attributes.style "align-items" "center"
    , Html.Attributes.style "justify-content" "center"
    ]
