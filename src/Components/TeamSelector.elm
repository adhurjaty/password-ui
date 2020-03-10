module Components.TeamSelector exposing 
    ( Model
    , Msg
    , initialModel
    , subscriptions
    , update
    , view)

import DnDList
import Html
import Html.Attributes
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
                ( dnd, fruits ) =
                    system.update msg model.dnd model.fruits
            in
            ( { model | dnd = dnd, fruits = fruits }
            , system.commands model.dnd
            )



-- VIEW


view : Model -> Html.Html Msg
view model =
    Html.section []
        [ model.players
            |> List.indexedMap (itemView model.dnd)
            |> Html.div containerStyles
        , ghostView model.dnd model.players
        ]


itemView : DnDList.Model -> Int -> Player -> Html.Html Msg
itemView dnd index fruit =
    let
        fruitId : String
        fruitId =
            "id-" ++ fruit
    in
    case system.info dnd of
        Just { dragIndex } ->
            if dragIndex /= index then
                Html.div
                    (Html.Attributes.id fruitId :: itemStyles green ++ system.dropEvents index fruitId)
                    [ Html.div (handleStyles darkGreen) []
                    , Html.text fruit
                    ]

            else
                Html.div
                    (Html.Attributes.id fruitId :: itemStyles "dimgray")
                    []

        Nothing ->
            Html.div
                (Html.Attributes.id fruitId :: itemStyles green)
                [ Html.div (handleStyles darkGreen ++ system.dragEvents index fruitId) []
                , Html.text fruit
                ]


ghostView : DnDList.Model -> List Players -> Html.Html Msg
ghostView dnd players =
    let
        maybeDragPlayer : Maybe Player
        maybeDragPlayer =
            system.info dnd
                |> Maybe.andThen (\{ dragIndex } -> players |> List.drop dragIndex |> List.head)
    in
    case maybeDragPlayer of
        Just player ->
            Html.div
                (itemStyles orange ++ system.ghostStyles dnd)
                [ Html.div (handleStyles darkOrange) []
                , Html.text player
                ]

        Nothing ->
            Html.text ""



-- COLORS


green : String
green =
    "#cddc39"


orange : String
orange =
    "#dc9a39"


darkGreen : String
darkGreen =
    "#afb42b"


darkOrange : String
darkOrange =
    "#b4752b"



-- STYLES


containerStyles : List (Html.Attribute msg)
containerStyles =
    [ Html.Attributes.style "display" "flex"
    , Html.Attributes.style "flex-wrap" "wrap"
    , Html.Attributes.style "align-items" "center"
    , Html.Attributes.style "justify-content" "center"
    , Html.Attributes.style "padding-top" "4em"
    ]


itemStyles : String -> List (Html.Attribute msg)
itemStyles color =
    [ Html.Attributes.style "width" "180px"
    , Html.Attributes.style "height" "100px"
    , Html.Attributes.style "background-color" color
    , Html.Attributes.style "border-radius" "8px"
    , Html.Attributes.style "color" "#000"
    , Html.Attributes.style "display" "flex"
    , Html.Attributes.style "align-items" "center"
    , Html.Attributes.style "margin" "0 4em 4em 0"
    ]


handleStyles : String -> List (Html.Attribute msg)
handleStyles color =
    [ Html.Attributes.style "width" "50px"
    , Html.Attributes.style "height" "50px"
    , Html.Attributes.style "background-color" color
    , Html.Attributes.style "border-radius" "8px"
    , Html.Attributes.style "margin" "20px"
    , Html.Attributes.style "cursor" "pointer"
    ]