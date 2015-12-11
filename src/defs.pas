unit defs;

interface

uses PacketData;

type
  TPlayerUID = record
    var id: UInt32;
    var login: AnsiString;
    procedure SetId(id: integer);
  end;

  TIffId = packed record
    case UInt32 of
     0: (id: UInt32);
     1: (a, b, c, typ: UInt8);
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

  TPLAYER_ACTION  = (
    PLAYER_ACTION_NULL            = $00,
    PLAYER_ACTION_APPEAR          = $04,
    PLAYER_ACTION_SUB             = $05,
    PLAYER_ACTION_MOVE            = $06,
    PLAYER_ACTION_ANIMATION       = $07
  );

  TPLAYER_ACTION_SUB = (
    PLAYER_ACTION_SUB_STAND       = $00,
    PLAYER_ACTION_SUB_SIT         = $01,
    PLAYER_ACTION_SUB_SLEEP       = $02
  );

  TSHOT_TYPE = (
    SHOT_TYPE_NORMAL = $02,
    SHOT_TYPE_OB     = $03,
    SHOT_TYPE_INHOLE = $04,
    SHOT_TYPE_UNKNOW = $FF
  );

  TCLUB_TYPE = (
    CLUB_TYPE_1W = 0,
    CLUB_TYPE_2W,
    CLUB_TYPE_3W,
    CLUB_TYPE_2L,
    CLUB_TYPE_3L,
    CLUB_TYPE_4L,
    CLUB_TYPE_5L,
    CLUB_TYPE_6L,
    CLUB_TYPE_7L,
    CLUB_TYPE_8L,
    CLUB_TYPE_9L,
    CLUB_TYPE_PW,
    CLUB_TYPE_SW,
    CLUB_TYPE_PT
  );

  TITEM_TYPE = (
    ITEM_TYPE_CHARACTER           = $04,
    ITEM_TYPE_FASHION             = $08,
    ITEM_TYPE_CLUB                = $10,
    ITEM_TYPE_AZTEC               = $14,
    ITEM_TYPE_ITEM1               = $18,
    ITEM_TYPE_ITEM2               = $1A,
    ITEM_TYPE_CADDIE              = $1C,
    ITEM_TYPE_CADDIE_ITEM         = $20,
    ITEM_TYPE_ITEM_SET            = $24,
    ITEM_TYPE_CADDIE_ITEM2        = $34,
    ITEM_TYPE_SKIN                = $38,
    ITEM_TYPE_TITLE               = $39,
    ITEM_TYPE_HAIR_COLOR1         = $3C,
    ITEM_TYPE_HAIR_COLOR2         = $3E,
    ITEM_TYPE_MASCOT              = $40,
    ITEM_TYPE_FURNITURE           = $48,
    ITEM_TYPE_CARD_SET            = $7C,
    ITEM_TYPE_UNKNOW              = $FF
  );


implementation

procedure TPlayerUID.SetId(id: Integer);
begin
  self.id := id;
end;

end.
