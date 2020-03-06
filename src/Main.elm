module Main exposing (..)

import Browser exposing (Document, UrlRequest)
import Browser.Navigation as Nav
import Html exposing (..)
import Html.Attributes exposing (src, class)
import Url exposing (Url)

import Page.Start as Start
import Page.NewRoom as NewRoom
import Page.StartRoom as StartRoom
import Route exposing (Route)

---- MODEL ----

type Page
    = NotFoundPage
    | StartPage Start.Model
    | NewRoomPage NewRoom.Model
    | StartRoomPage StartRoom.Model

type alias Model =
    { route : Route
    , page : Page
    , navKey : Nav.Key
    }

init : () -> Url -> Nav.Key -> ( Model, Cmd Msg )
init flags url navKey =
    let
        model =
            { route = Route.parseUrl url
            , page = NotFoundPage
            , navKey = navKey
            }
    in
    initCurrentPage ( model, Cmd.none )

initCurrentPage : ( Model, Cmd Msg ) -> ( Model, Cmd Msg )
initCurrentPage ( model, existingCmds ) =
    let
        ( currentPage, mappedPageCmds ) =
            case model.route of
                Route.NotFound ->
                    ( NotFoundPage, Cmd.none )

                Route.Start ->
                    let
                        ( pageModel, pageCmds ) =
                            Start.init
                    in
                    ( StartPage pageModel, Cmd.map StartMsg pageCmds )

                Route.NewRoom ->
                    let
                        ( pageModel, pageCmds ) =
                            NewRoom.init model.navKey
                    in
                    ( NewRoomPage pageModel, Cmd.map NewRoomMsg pageCmds )

                Route.StartRoom roomId ->
                    let
                        ( pageModel, pageCmds ) =
                            StartRoom.init roomId model.navKey
                    in
                    ( StartRoomPage pageModel, Cmd.map StartRoomMsg pageCmds )
    in
    ( { model | page = currentPage } 
    , Cmd.batch [ existingCmds, mappedPageCmds ]
    )

---- UPDATE ----

type Msg
    = LinkClicked UrlRequest
    | UrlChanged Url
    | StartMsg Start.Msg
    | NewRoomMsg NewRoom.Msg
    | StartRoomMsg StartRoom.Msg


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case (msg, model.page) of
        ( LinkClicked urlRequest, _ ) ->
            case urlRequest of
                Browser.Internal url ->
                    ( model
                    , Nav.pushUrl model.navKey (Url.toString url)
                    )
            
                Browser.External url ->
                    ( model
                    , Nav.load url
                    )
                
        ( NewRoomMsg subMsg, NewRoomPage roomModel ) ->
            let
                ( updatedRoomModel, updatedCmd ) =
                    NewRoom.update subMsg roomModel
            in
            ( { model | page = NewRoomPage updatedRoomModel }
            , Cmd.map NewRoomMsg updatedCmd
            )

        ( StartRoomMsg subMsg, StartRoomPage roomModel ) ->
            let
                ( updatedRoomModel,  updatedCmd ) =
                    StartRoom.update subMsg roomModel
            in
            ( { model | page = StartRoomPage updatedRoomModel }
            , Cmd.map StartRoomMsg updatedCmd
            )

        ( UrlChanged url, _ ) ->
            let
                newRoute =
                    Route.parseUrl url
            in
            ( { model | route = newRoute }, Cmd.none )
                |> initCurrentPage
            
        (_, _) ->
             ( model, Cmd.none )

---- VIEW ----

view : Model -> Document Msg
view model =
    { title = "Password"
    , body = [ viewTemplate model ]
    }

viewTemplate : Model -> Html Msg
viewTemplate model =
    div [ class "content-wrapper" ]
        [ currentView model ]

currentView : Model -> Html Msg
currentView model =
    case model.page of
        NotFoundPage ->
            notFoundView
    
        StartPage pageModel ->
            Start.view pageModel
                |> Html.map StartMsg

        NewRoomPage pageModel ->
            NewRoom.view pageModel
                |> Html.map NewRoomMsg

        StartRoomPage pageModel ->
            StartRoom.view pageModel
                |> Html.map StartRoomMsg


notFoundView : Html msg
notFoundView =
    h3 [] [ text "Oops! The page you requested was not found!" ]

---- PROGRAM ----


main : Program () Model Msg
main =
    Browser.application
        { view = view
        , init = init
        , update = update
        , subscriptions = always Sub.none
        , onUrlRequest = LinkClicked
        , onUrlChange = UrlChanged
        }
