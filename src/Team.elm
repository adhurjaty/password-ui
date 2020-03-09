module Team exposing (Team, teamsDecoder, name)

import Json.Decode.Pipeline exposing (required, optional)
import Json.Decode as Decode exposing (Decoder, int, list, string)
import Json.Encode as Encode
import Player exposing (Player, playersDecoder)

type alias Team =
    { players : List Player
    , score : Int
    }

teamDecoder : Decoder Team
teamDecoder =
    Decode.succeed Team
        |> required "players" playersDecoder
        |> required "score" int


teamsDecoder : Decoder (List Team)
teamsDecoder =
    list teamDecoder


name : Team -> String
name team =
    String.join " + " (List.map (\player -> player.name) team.players)
