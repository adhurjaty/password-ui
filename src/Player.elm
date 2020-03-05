module Player exposing 
    ( Player
    , PlayerId
    , playerEncoder
    , playersDecoder
    , idDecoder
    , emptyPlayerId)

import Json.Decode as Decode exposing (Decoder, int, list, string, nullable)
import Json.Decode.Pipeline exposing (optional, required)
import Json.Encode as Encode

type alias Player =
    { id : Maybe PlayerId
    , name : String
    }

type PlayerId
    = PlayerId String

idDecoder : Decoder PlayerId
idDecoder =
    Decode.map PlayerId string

encodeId : PlayerId -> Encode.Value
encodeId (PlayerId id) =
    Encode.string id

emptyPlayerId : PlayerId
emptyPlayerId =
    PlayerId ""

playerEncoder : Player -> Encode.Value
playerEncoder player =
    Encode.object
        [ ("name", Encode.string player.name)
        ]

-- newPlayerEncoder : Player -> Encode.Value
-- newPlayerEncoder player =
--     Encode.object
--         [ ("id", encodeId player.id)
--         , ("name", Encode.string player.name)
--         ]

playerDecoder : Decoder Player
playerDecoder =
    Decode.succeed Player
        |> required "id" (nullable idDecoder)
        |> required "name" string

playersDecoder : Decoder (List Player)
playersDecoder =
    list playerDecoder
