unit defs;

interface

uses PacketData;

type
  TPlayerUID = record
    var id: UInt32;
    var login: AnsiString;
    procedure SetId(id: integer);
  end;

TGAME_TYPE = (
  GAME_TYPE_VERSUS_STROKE   = $00
);

TGAME_MODE = (
  GAME_MODE_FRONT               = $00,
  GAME_MODE_BACK                = $01,
  GAME_MODE_RANDOM              = $02,
  GAME_MODE_SHUFFLE             = $03,
  GAME_MODE_REPEAT              = $04
);


implementation

procedure TPlayerUID.SetId(id: Integer);
begin
  self.id := id;
end;

end.
