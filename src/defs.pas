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
    GAME_TYPE_VERSUS_STROKE       = $00,
    GAME_TYPE_VERSUS_MATCH        = $01,
    GAME_TYPE_CHAT_ROOM           = $02,
    GAME_TYPE_TOURNEY_TOURNEY     = $04, // 30 Players tournament
    GAME_TYPE_TOURNEY_TEAM        = $05, // 30 Players team tournament
    GAME_TYPE_TOURNEY_GUILD       = $06, // Guild battle
    GAME_TYPE_BATTLE_PANG_BATTLE  = $07, // Pang Battle
    GAME_TYPE_08                  = $08, // Public My Room
    GAME_TYPE_0F                  = $0F, // Playing for the first time
    GAME_TYPE_10                  = $10, // Learn with caddie
    GAME_TYPE_11                  = $11, // Stroke
    GAME_TYPE_12                  = $12, // This is Chaos!
    GAME_TYPE_14                  = $14 // Grand Prix
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
