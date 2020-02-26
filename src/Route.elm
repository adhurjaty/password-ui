module Route exposing (Route(..), pushUrl, parseUrl)

import Browser.Navigation as Nav
import Url exposing (Url)
import Url.Parser exposing (..)

type Route
    = NotFound
    | Start

parseUrl : Url -> Route
parseUrl url =
    case parse matchRoute url of
        Just route ->
            route
        Nothing ->
            NotFound

matchRoute : Parser (Route -> a) a
matchRoute =
    oneOf
        [ map Start top
        ]

pushUrl : Route -> Nav.Key -> Cmd msg
pushUrl route navKey =
    routeToString route
        |> Nav.pushUrl navKey

routeToString : Route -> String
routeToString route =
    case route of
        NotFound ->
            "/not-found"
        
        Start ->
            "/start"
