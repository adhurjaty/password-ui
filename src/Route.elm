module Route exposing (Route(..), pushUrl, parseUrl)

import Browser.Navigation as Nav
import Url exposing (Url)
import Url.Parser exposing (..)
import Room exposing (RoomId)

type Route
    = NotFound
    | Start
    | NewRoom
    | GameRoom RoomId

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
        , map Start (s "start")
        , map NewRoom (s "rooms" </> s "new")
        , map GameRoom (s "rooms" </> Room.idParser )
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

        NewRoom ->
            "/rooms/new"

        GameRoom roomId ->
            "/rooms/" ++ Room.idToString roomId
