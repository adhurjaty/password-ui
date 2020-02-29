module Room exposing 
    ( Room
    )

import Json.Decode as Decode exposing (Decoder, int, list, string)
import Json.Encode as Encode
import Player exposing (Player)

type alias Room =
    { id : RoomId
    , players : List Player
    }

type RoomId
    = RoomId String

idDecoder : Decoder RoomId
idDecoder =
    Decoder.map RoomId String

roomEncoder : Room -> Encode.Value
roomEncoder room =
    Encode.object
        [ ("id", encodeRoomId room.id)
        , ("players", Encode.string room.)
        ]

newRoomEncoder : String -> Encode.Value
newRoomEncoder name =
    Encode.object
        [( "name", Encode.string name )]

emptyRoomId : RoomId
emptyRoomId = ""
