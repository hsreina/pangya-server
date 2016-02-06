{*******************************************************}
{                                                       }
{       Pangya Server                                   }
{                                                       }
{       Copyright (C) 2015 Shad'o Soft tm               }
{                                                       }
{*******************************************************}

unit PangyaPacketsDef;

interface

type

  // Client login packets (packets sent from the game to the Login Server)
  TCLPID = (
    CLPID_PLAYER_LOGIN                        = $0001,
    CLPID_PLAYER_SELECT_SERVER                = $0003,
    CLPID_PLAYER_SET_NICKNAME                 = $0006,
    CLPID_PLAYER_CONFIRM                      = $0007,
    CLPID_PLAYER_SELECT_CHARCTER              = $0008,
    CLPID_PLAYER_RECONNECT                    = $000B,
    CLPID_NOTHING                             = $FFFF
  );

  TSLPID = (
    SPID_LOGIN                                = $0001,
    SPID_SERVERS_LIST                         = $0002,
    SPID_PLAYER_SECURITY2                     = $0003,
    SPID_UN_0009                              = $0009,
    SPID_PLAYER_SECURITY1                     = $0010,
    SPID_GG_CHECK                             = $0040,
    SPID_LOBBIES_LIST                         = $004D,
    SPID_NOTHING                              = $FFFF
  );

  // Client game packets (packets sent from the game to the Game Server)
  TCGPID = (
    CGPID_PLAYER_LOGIN                        = $0002,
    CGPID_PLAYER_MESSAGE                      = $0003,
    CGPID_PLAYER_JOIN_LOBBY                   = $0004,
    CGPID_PLAYER_REQUEST_OFFLINE_PLAYER_INFO  = $0007,
    CGPID_PLAYER_CREATE_GAME                  = $0008,
    CGPID_PLAYER_JOIN_GAME                    = $0009,
    CGPID_PLAYER_CHANGE_GAME_SETTINGS         = $000A,
    CGPID_PLAYER_CHANGE_EQUPMENT_A            = $000B,
    CGPID_PLAYER_CHANGE_EQUPMENT_B            = $000C,
    CGPID_PLAYER_READY                        = $000D,
    CGPID_PLAYER_START_GAME                   = $000E,
    CGPID_PLAYER_LEAVE_GAME                   = $000F,
    CGPID_PLAYER_LOAD_OK                      = $0011,
    CGPID_PLAYER_ACTION_SHOT                  = $0012,
    CGPID_PLAYER_ACTION_ROTATE                = $0013,
    CGPID_PLAYER_ACTION_HIT                   = $0014,
    CGPID_PLAYER_POWER_SHOT                   = $0015,
    CGPID_PLAYER_ACTION_CHANGE_CLUB           = $0016,
    CGPID_PLAYER_USE_ITEM                     = $0017,
    CGPID_PLAYER_MOVE_AZTEC                   = $0019,
    CGPID_PLAYER_HOLE_INFORMATIONS            = $001A,
    CGPID_PLAYER_SHOTDATA                     = $001B,
    CGPID_PLAYER_SHOT_SYNC                    = $001C,
    CGPID_PLAYER_BUY_ITEM                     = $001D,
    CGPID_PLAYER_CHANGE_EQUIP                 = $0020,
    CGPID_MASTER_KICK_PLAYER                  = $0026,
    CGPID_PLAYER_WHISPER                      = $002A,
    CGPID_PLAYER_REQUEST_INFO                 = $002F,
    CGPID_PLAYER_PAUSE_GAME                   = $0030,
    CGPID_PLAYER_HOLE_COMPLETE                = $0031,
    CGPID_PLAYER_EXCEPTION                    = $0033,
    CGPID_PLAYER_1ST_SHOT_READY               = $0034,
    CGPID_PLAYER_REQUEST_COOKIES_COUNT        = $003D,
    CGPID_PLAYER_REQUEST_IDENTITY             = $0041,
    CGPID_PLAYER_REQQUEST_SERVERS_LIST        = $0043,
    CGPID_PLAYER_LOADING_INFO                 = $0048,
    CGPID_PLAYER_UPGRADE                      = $004B,
    CGPID_PLAYER_NOTICE                       = $0057,
    CGPID_PLAYER_REQUEST_SERVER_TIME          = $005C,
    CGPID_PLAYER_ACTION                       = $0063,
    CGPID_PLAYER_FAST_FORWARD                 = $0065,
    CGPID_PLAYER_ENTER_SCRATCHY_SERIAL        = $0071,
    CGPID_PLAYER_SET_MASCOT_TEXT              = $0073,
    CGPID_PLAYER_CLOSE_SHOP                   = $0075,
    CGPID_PLAYER_EDIT_SHOP                    = $0076,
    CGPID_PLAYER_ENTER_SHOP                   = $0077,
    CGPID_PLAYER_EDIT_SHOP_NAME               = $0079,
    CGPID_PLAYER_REQUEST_SHOP_VISITORS_COUNT  = $007A,
    CGPID_PLAYER_REQUEST_INCOME               = $007B,
    CGPID_PLAYER_EDIT_SHOP_ITEMS              = $007C,
    CGPID_PLAYER_BUY_SHOP_ITEM                = $007D,
    CGPID_PLAYER_JOIN_MULTIPLAYER_GAME_LIST   = $0081,
    CGPID_PLAYER_LEAVE_MULTIPLAYER_GAME_LIST  = $0082,
    CGPID_PLAYER_REQUEST_MESSENGER_LIST       = $008B,
    CGPID_PLAYER_GM_COMMAND                   = $008F,
    CGPID_PLAYER_OPEN_RARE_SHOP               = $0098,
    CGPID_PLAYER_CLEAR_QUEST                  = $00AE,
    CGPID_PLAYER_SEND_INVITE                  = $00BA,
    CGPID_PLAYER_REQUEST_LOCKER_ACCESS        = $00CC,
    CGPID_PLAYER_REQUEST_LOCKER_PAGE          = $00CD,
    CGPID_PLAYER_CHANGE_LOCKER_PASSWORD       = $00D1,
    CGPID_PLAYER_REQUEST_LOCKER               = $00D3,
    CGPID_PLAYER_LOCKER_PANGS_TRANSACTION     = $00D4,
    CGPID_PLAYER_REQUEST_LOCKER_PANGS         = $00D5,
    CGPID_PLAYER_UN_00EB                      = $00EB,
    CGPID_PLAYER_OPEN_SCRATCHY_CARD           = $012A,
    CGPID_PLAYER_UN_0140                      = $0140,
    CGPID_PLAYER_REQUEST_INBOX                = $0143,
    CGPID_PLAYER_REQUEST_INBOX_DETAILS        = $0144,
    CGPID_PLAYER_SEND_MAIL                    = $0145,
    CGPID_PLAYER_MOVE_INBOX_GIFT              = $0146,
    CGPID_PLAYER_DELETE_MAIL                  = $0147,
    CGPID_PLAYER_PLAY_BONGDARI_SHOP           = $014B,
    CGPID_PLAYER_REQUEST_DAILY_QUEST          = $0151,
    CGPID_PLAYER_ACCEPT_DAILY_QUEST           = $0152,
    CGPID_PLAYER_GIVEUP_DAILY_QUEST           = $0154,
    CGPID_PLAYER_REQUEST_ACHIEVEMENTS         = $0157,
    CGPID_PLAYER_REQUEST_DAILY_REWARD         = $016E,
    CGPID_PLAYER_ENTER_GRAND_PRIX             = $0176,
    CGPID_PLAYER_LEAVE_GRAND_PRIX             = $0177,
    CGPID_ENTER_GRAND_PRIX_EVENT              = $0179,
    CGPID_LEAVE_GRAND_PRIX_EVENT              = $017A,
    CGPID_PLAYER_SET_ASSIST_MODE              = $0184,
    CGPID_PLAYER_RECYCLE_ITEM                 = $018D,
    CGPID_NOTHING                             = $FFFF
  );

  TSGPID = (
    SGPID_PLAYER_MAIN_DATA                    = $0044,
    SGPID_GAME_PLAY_INFO                      = $0052,
    SGPID_PLAYER_ACTION_SHOT                  = $0055,
    SGPID_PLAYER_ACTION_ROTATE                = $0056,
    SGPID_PLAYER_ACTION_CHANGE_CLUB           = $0059,
    SGPID_PLAYER_NEXT                         = $0063,
    SGPID_PLAYER_CHARACTERS_DATA              = $0070,
    SGPID_PLAYER_CADDIES_DATA                 = $0071,
    SGPID_PLAYER_EQUIP_DATA                   = $0072,
    SGPID_PLAYER_ITEMS_DATA                   = $0073,
    SGPID_PLAYER_1ST_SHOT_READY               = $0090,
    SFPID_PLAYER_COOKIES                      = $0096,
    SGPID_PLAYER_LOADING_INFO                 = $00A3,
    SGPID_PLAYER_MASCOTS_DATA                 = $00E1,
    SGPID_NOTHING                             = $FFFF
  );

  // Sync server packets from any server to Sync server
  TSSPID = (
    SSPID_REGISTER_SERVER             = $0000,
    SSPID_PLAYER_SYNC                 = $0001, // send player Sync packet
    SSPID_PLAYER_ACTION               = $0002, // do an action related to the player
    SSPID_NOTHING                     = $FFFF
  );

  // Action packet with players
  TSSAPID = (
    SSAPID_SEND_SERVER_LIST           = $0001, // Send the list of game server
    SSAPID_SEND_LOBBIES_LIST          = $0002, // Send the list of lobbies
    SSAPID_PLAYER_MAIN_SAVE           = $0003,
    SSAPID_PLAYER_CHARACTERS          = $0004,
    SSAPID_PLAYER_ITEMS               = $0005,
    SSAPID_PLAYER_CADDIES             = $0006,
    SSAPID_PLAYER_COOKIES             = $0007,
    SSAPID_PLAYER_MASCOTS             = $0008,
    SSAPID_NOTHING                    = $FFFF
  );

function WriteAction(actionId: TSGPID): AnsiString; overload;
function WriteAction(actionId: TSSPID): AnsiString; overload;
function WriteAction(actionId: TSSAPID): AnsiString; overload;
function WriteAction(actionId: TCGPID): AnsiString; overload;

function WriteHeader(id: TSGPID): AnsiString; overload;

implementation

function WriteAction(actionId: TSGPID): AnsiString;
begin
  setLength(result, 2);
  move(actionId, result[1], 2);
end;

function WriteAction(actionId: TSSPID): AnsiString;
begin
  setLength(result, 2);
  move(actionId, result[1], 2);
end;

function WriteAction(actionId: TSSAPID): AnsiString;
begin
  setLength(result, 2);
  move(actionId, result[1], 2);
end;

function WriteAction(actionId: TCGPID): AnsiString;
begin
  setLength(result, 2);
  move(actionId, result[1], 2);
end;

function WriteHeader(id: TSGPID): AnsiString; overload;
begin
  setLength(result, 2);
  move(id, result[1], 2);
end;

end.
