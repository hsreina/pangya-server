{*******************************************************}
{                                                       }
{       Pangya Server                                   }
{                                                       }
{       Copyright (C) 2015 Shad'o Soft tm               }
{                                                       }
{*******************************************************}

unit defs;

interface

type
  TPlayerUID = record
    var id: UInt32;
    var login: RawByteString;
    procedure SetId(id: integer);
  end;

  TIffId = packed record
    case UInt32 of
      0: (id: UInt32);
      1: (a, b, c, typ: UInt8);
  end;

  TGAME_TYPE = (
    GAME_TYPE_VERSUS_STROKE = $00,
    GAME_TYPE_VERSUS_MATCH = $01,
    GAME_TYPE_CHAT_ROOM = $02,
    GAME_TYPE_03 = $03,
    GAME_TYPE_TOURNEY_TOURNEY = $04, // 30 Players tournament
    GAME_TYPE_TOURNEY_TEAM = $05, // 30 Players team tournament
    GAME_TYPE_TOURNEY_GUILD = $06, // Guild battle
    GAME_TYPE_BATTLE_PANG_BATTLE = $07, // Pang Battle
    GAME_TYPE_08 = $08, // Public My Room
    GAME_TYPE_09 = $09,
    GAME_TYPE_0A = $0A,
    GAME_TYPE_0B = $0B,
    GAME_TYPE_0C = $0C,
    GAME_TYPE_0D = $0D,
    GAME_TYPE_CHIP_IN_PRACTICE = $0E,
    GAME_TYPE_0F = $0F, // Playing for the first time
    GAME_TYPE_10 = $10, // Learn with caddie
    GAME_TYPE_11 = $11, // Stroke
    GAME_TYPE_12 = $12, // This is Chaos!
    GAME_TYPE_HOLE_REPEAT = $13, // This is Chaos!
    GAME_TYPE_14 = $14 // Grand Prix
  );

  TGAME_MODE = (
    GAME_MODE_FRONT = $00,
    GAME_MODE_BACK = $01,
    GAME_MODE_RANDOM = $02,
    GAME_MODE_SHUFFLE = $03,
    GAME_MODE_REPEAT = $04
  );

  TPLAYER_ACTION = (
    PLAYER_ACTION_NULL = $00,
    PLAYER_ACTION_APPEAR = $04,
    PLAYER_ACTION_SUB = $05,
    PLAYER_ACTION_MOVE = $06,
    PLAYER_ACTION_ANIMATION = $07
  );

  TPLAYER_ACTION_SUB = (
    PLAYER_ACTION_SUB_STAND = $00,
    PLAYER_ACTION_SUB_SIT = $01,
    PLAYER_ACTION_SUB_SLEEP = $02
  );

  TSHOT_TYPE = (
    SHOT_TYPE_NORMAL = $02,
    SHOT_TYPE_OB = $03,
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
    ITEM_TYPE_CHARACTER = $04,
    ITEM_TYPE_FASHION = $08,
    ITEM_TYPE_CLUB = $10,
    ITEM_TYPE_AZTEC = $14,
    ITEM_TYPE_ITEM1 = $18,
    ITEM_TYPE_ITEM2 = $1A,
    ITEM_TYPE_CADDIE = $1C,
    ITEM_TYPE_CADDIE_ITEM = $20,
    ITEM_TYPE_ITEM_SET = $24,
    ITEM_TYPE_CADDIE_ITEM2 = $34,
    ITEM_TYPE_SKIN = $38,
    ITEM_TYPE_TITLE = $39,
    ITEM_TYPE_HAIR_COLOR1 = $3C,
    ITEM_TYPE_HAIR_COLOR2 = $3E,
    ITEM_TYPE_MASCOT = $40,
    ITEM_TYPE_FURNITURE = $48,
    ITEM_TYPE_CARD_SET = $7C,
    ITEM_TYPE_UNKNOW = $FF
  );

  TRank = (
    ROOKIE_F = $00,
    ROOKIE_E = $01,
    ROOKIE_D = $02,
    ROOKIE_C = $03,
    ROOKIE_B = $04,
    ROOKIE_A = $05,
    BEGINNER_E = $06,
    BEGINNER_D = $07,
    BEGINNER_C = $08,
    BEGINNER_B = $09,
    BEGINNER_A = $0A,
    JUNIOR_E = $0B,
    JUNIOR_D = $0C,
    JUNIOR_C = $0D,
    JUNIOR_B = $0E,
    JUNIOR_A = $0F,
    SENIOR_E = $10,
    SENIOR_D = $11,
    SENIOR_C = $12,
    SENIOR_B = $13,
    SENIOR_A = $14,
    AMATEUR_E = $15,
    AMATEUR_D = $16,
    AMATEUR_C = $17,
    AMATEUR_B = $18,
    AMATEUR_A = $19,
    SEMI_PRO_E = $1A,
    SEMI_PRO_D = $1B,
    SEMI_PRO_C = $1C,
    SEMI_PRO_B = $1D,
    SEMI_PRO_A = $1E,
    PRO_E = $1F,
    PRO_D = $20,
    PRO_C = $21,
    PRO_B = $22,
    PRO_A = $23,
    NATIONAL_PRO_E = $24,
    NATIONAL_PRO_D = $25,
    NATIONAL_PRO_C = $26,
    NATIONAL_PRO_B = $27,
    NATIONAL_PRO_A = $28,
    WORLD_PRO_E = $29,
    WORLD_PRO_D = $2A,
    WORLD_PRO_C = $2B,
    WORLD_PRO_B = $2C,
    WORLD_PRO_A = $2D,
    MASTER_E = $2E,
    MASTER_D = $2F,
    MASTER_C = $30,
    MASTER_B = $31,
    MASTER_A = $32,
    TOP_MASTER_E = $33,
    TOP_MASTER_D = $34,
    TOP_MASTER_C = $35,
    TOP_MASTER_B = $36,
    TOP_MASTER_A = $37,
    WORLD_MASTER_E = $38,
    WORLD_MASTER_D = $39,
    WORLD_MASTER_C = $3A,
    WORLD_MASTER_B = $3B,
    WORLD_MASTER_A = $3C,
    LEGEND_E = $3D,
    LEGEND_D = $3E,
    LEGEND_C = $3F,
    LEGEND_B = $40,
    LEGEND_A = $41,
    INFINITY_LEGEND_E = $42,
    INFINITY_LEGEND_D = $43,
    INFINITY_LEGEND_C = $44,
    INFINITY_LEGEND_B = $45,
    INFINITY_LEGEND_A = $46
  );

  TCREATE_GAME_RESULT = (
    CREATE_GAME_RESULT_SUCCESS = $00,
    CREATE_GAME_RESULT_FULL = $02,
    CREATE_GAME_ROOM_DONT_EXISTS = $03,
    CREATE_GAME_INCORRECT_PASSWORD = $04,
    CREATE_GAME_INVALID_LEVEL = $05,
    CREATE_GAME_CREATE_FAILED = $07,
    CREATE_GAME_ALREADY_STARTED = $08,
    CREATE_GAME_CREATE_FAILED2 = $09,
    CREATE_GAME_NEED_REGISTER_WITH_GUILD = $0D,
    CREATE_GAME_PANG_BATTLE_INSSUFICENT_PANGS = $0F,
    CREATE_GAME_APPROACH_INSSUFICENT_PANGS = $11,
    CREATE_GAME_CANT_CREATE = $12
  );

  TPRICE_TYPE = (
    PRICE_TYPE_UNKNOW = $00,
    PRICE_TYPE_PANG   = $01,
    PRICE_TYPE_COOKIE = $02
  );

function WriteGameCreateResult(gameCreateResult: TCREATE_GAME_RESULT): Uint8;

implementation

procedure TPlayerUID.SetId(id: integer);
begin
  self.id := id;
end;

function WriteGameCreateResult(gameCreateResult: TCREATE_GAME_RESULT): Uint8;
begin
  move(gameCreateResult, result, 1);
end;

end.
