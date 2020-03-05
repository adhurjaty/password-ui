module Room exposing 
    ( Room
    , RoomId
    , NewRoom
    , emptyRoom
    , emptyRoomId
    , idDecoder
    , newRoomEncoder
    , newRoomDecoder
    )

import Json.Decode as Decode exposing (Decoder, int, list, string)
import Json.Decode.Pipeline exposing (required, optional)
import Json.Encode as Encode
import Player exposing (Player, PlayerId, playersDecoder)

type alias Room =
    { id : RoomId
    , players : List Player
    }
type alias NewRoom =
    { id : RoomId
    , playerId : PlayerId
    , playerName : String
    }

type RoomId
    = RoomId String

idDecoder : Decoder RoomId
idDecoder =
    Decode.map RoomId string

-- roomEncoder : Room -> Encode.Value
-- roomEncoder room =
--     Encode.object
--         [ ("id", encodeRoomId room.id)
--         , ("players", Encode.string room.)
--         ]

emptyRoom : Room
emptyRoom =
    { id = emptyRoomId
    , players = []
    }

emptyRoomId : RoomId
emptyRoomId =
    RoomId ""


newRoomEncoder : String -> Encode.Value
newRoomEncoder name =
    Encode.object
        [( "name", Encode.string name )]

  
newRoomDecoder : Decoder NewRoom
newRoomDecoder =
    Decode.succeed NewRoom
        |> required "id" idDecoder
        |> required "playerId" Player.idDecoder
        |> optional "playerName" string ""

