module Main exposing (..)

import Browser exposing (Document, UrlRequest)
import Browser.Navigation as Nav
import Html exposing (..)
import Html.Attributes exposing (src)
import Url exposing (Url)

import Page.Start as Start
import Route exposing (Route)

---- MODEL ----

type Page
    = NotFoundPage
    | StartPage Start.Model

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
                    ( StartPage pageModel, Cmd.none )
    in
    ( { model | page = currentPage } 
    , Cmd.batch [ existingCmds, mappedPageCmds ]
    )


---- UPDATE ----

type Msg
    = LinkClicked UrlRequest
    | UrlChanged Url


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    ( model, Cmd.none )

---- VIEW ----

view : Model -> Document Msg
view model =
    { title = "Password"
    , body = [ currentView model ]
    }

currentView : Model -> Html Msg
currentView model =
    case model.page of
        NotFoundPage ->
            notFoundView
    
        StartPage pageModel ->
            Start.view pageModel

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