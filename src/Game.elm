module Game exposing 
    ( Game
    , gameDecoder
    )


import Json.Decode as Decode exposing (Decoder, int, list, string, nullable, bool)
import Json.Decode.Pipeline exposing (optional, required)
import Json.Encode as Encode
import Team exposing (Team, teamsDecoder)

type alias Game =
    { turn : Bool
    , pendingScore : Int
    , round : Int
    , word : String
    , teams : List Team
    }

gameDecoder : Decoder Game
gameDecoder =
    Decode.succeed Game
        |> required "turn" bool
        |> required "pendingScore" int
        |> required "round" int
        |> required "word" string
        |> required "teams" teamsDecoder

