{*******************************************************}
{                                                       }
{       Pangya Server                                   }
{                                                       }
{       Copyright (C) 2015 Shad'o Soft tm               }
{                                                       }
{*******************************************************}

unit PacketsDef;

interface

type

  PTClientPacketHeader = ^TClientPacketHeader;
  TClientPacketHeader = packed record
    var xx: UInt8;
    var size: UInt16;
    var yy: UInt8;
  end;

{$SCOPEDENUMS ON}
  // Client login packets (packets sent from the game to the Login Server)
  TCLPID = (
    PLAYER_LOGIN                        = $0001,
    PLAYER_SELECT_SERVER                = $0003,
    PLAYER_SET_NICKNAME                 = $0006,
    PLAYER_CONFIRM                      = $0007,
    PLAYER_SELECT_CHARCTER              = $0008,
    PLAYER_RECONNECT                    = $000B,
    NOTHING                             = $FFFF
  );

  TSLPID = (
    LOGIN                                = $0001,
    SERVERS_LIST                         = $0002,
    PLAYER_SECURITY2                     = $0003,
    UN_0009                              = $0009,
    PLAYER_SECURITY1                     = $0010,
    GG_CHECK                             = $0040,
    LOBBIES_LIST                         = $004D,
    NOTHING                              = $FFFF
  );

  // Client game packets (packets sent from the game to the Game Server)
  TCGPID = (
    PLAYER_LOGIN                        = $0002,
    PLAYER_MESSAGE                      = $0003,
    PLAYER_JOIN_LOBBY                   = $0004,
    PLAYER_REQUEST_OFFLINE_PLAYER_INFO  = $0007,
    PLAYER_CREATE_GAME                  = $0008,
    PLAYER_JOIN_GAME                    = $0009,
    PLAYER_CHANGE_GAME_SETTINGS         = $000A,
    PLAYER_CHANGE_EQUPMENT_A            = $000B,
    PLAYER_CHANGE_EQUPMENT_B            = $000C,
    PLAYER_READY                        = $000D,
    PLAYER_START_GAME                   = $000E,
    PLAYER_LEAVE_GAME                   = $000F,
    PLAYER_LOAD_OK                      = $0011,
    PLAYER_ACTION_SHOT                  = $0012,
    PLAYER_ACTION_ROTATE                = $0013,
    PLAYER_ACTION_HIT                   = $0014,
    PLAYER_POWER_SHOT                   = $0015,
    PLAYER_ACTION_CHANGE_CLUB           = $0016,
    PLAYER_USE_ITEM                     = $0017,
    PLAYER_MOVE_AZTEC                   = $0019,
    PLAYER_HOLE_INFORMATIONS            = $001A,
    PLAYER_SHOTDATA                     = $001B,
    PLAYER_SHOT_SYNC                    = $001C,
    PLAYER_BUY_ITEM                     = $001D,
    PLAYER_CHANGE_EQUIP                 = $0020,
    MASTER_KICK_PLAYER                  = $0026,
    PLAYER_WHISPER                      = $002A,
    PLAYER_REQUEST_INFO                 = $002F,
    PLAYER_PAUSE_GAME                   = $0030,
    PLAYER_HOLE_COMPLETE                = $0031,
    PLAYER_EXCEPTION                    = $0033,
    PLAYER_1ST_SHOT_READY               = $0034,
    ADMIN_JOIN_GAME                     = $003E,
    PLAYER_REQUEST_COOKIES_COUNT        = $003D,
    PLAYER_REQUEST_IDENTITY             = $0041,
    PLAYER_REQUEST_SERVERS_LIST         = $0043,
    PLAYER_LOADING_INFO                 = $0048,
    PLAYER_UPGRADE                      = $004B,
    PLAYER_NOTICE                       = $0057,
    PLAYER_REQUEST_SERVER_TIME          = $005C,
    PLAYER_ACTION                       = $0063,
    PLAYER_DELETE_ITEM                  = $0064,
    PLAYER_FAST_FORWARD                 = $0065,
    PLAYER_ENTER_SCRATCHY_SERIAL        = $0071,
    PLAYER_SET_MASCOT_TEXT              = $0073,
    PLAYER_CLOSE_SHOP                   = $0075,
    PLAYER_EDIT_SHOP                    = $0076,
    PLAYER_ENTER_SHOP                   = $0077,
    PLAYER_EDIT_SHOP_NAME               = $0079,
    PLAYER_REQUEST_SHOP_VISITORS_COUNT  = $007A,
    PLAYER_REQUEST_INCOME               = $007B,
    PLAYER_EDIT_SHOP_ITEMS              = $007C,
    PLAYER_BUY_SHOP_ITEM                = $007D,
    PLAYER_JOIN_MULTIPLAYER_GAME_LIST   = $0081,
    PLAYER_LEAVE_MULTIPLAYER_GAME_LIST  = $0082,
    PLAYER_REQUEST_MESSENGER_LIST       = $008B,
    PLAYER_GM_COMMAND                   = $008F,
    PLAYER_OPEN_RARE_SHOP               = $0098,
    PLAYER_CLEAR_QUEST                  = $00AE,
    PLAYER_SEND_INVITE                  = $00BA,
    PLAYER_REQUEST_LOCKER_ACCESS        = $00CC,
    PLAYER_REQUEST_LOCKER_PAGE          = $00CD,
    PLAYER_CHANGE_LOCKER_PASSWORD       = $00D1,
    PLAYER_REQUEST_LOCKER               = $00D3,
    PLAYER_LOCKER_PANGS_TRANSACTION     = $00D4,
    PLAYER_REQUEST_LOCKER_PANGS         = $00D5,
    PLAYER_UN_00EB                      = $00EB,
    PLAYER_GUILD_CREATE                 = $0101,
    PLAYER_GUILD_CHECK_NAME             = $0102,
    PLAYER_GUILD_LIST                   = $0108,
    PLAYER_GUILD_LIST_SEARCH            = $0109,
    PLAYER_GUILD_REQUEST_JOIN           = $010C,
    PLAYER_OPEN_SCRATCHY_CARD           = $012A,
    PLAYER_UN_0140                      = $0140,
    PLAYER_REQUEST_INBOX                = $0143,
    PLAYER_REQUEST_INBOX_DETAILS        = $0144,
    PLAYER_SEND_MAIL                    = $0145,
    PLAYER_MOVE_INBOX_GIFT              = $0146,
    PLAYER_DELETE_MAIL                  = $0147,
    PLAYER_PLAY_BONGDARI_SHOP           = $014B,
    PLAYER_REQUEST_DAILY_QUEST          = $0151,
    PLAYER_ACCEPT_DAILY_QUEST           = $0152,
    PLAYER_GIVEUP_DAILY_QUEST           = $0154,
    PLAYER_REQUEST_ACHIEVEMENTS         = $0157,
    PLAYER_REQUEST_DAILY_REWARD         = $016E,
    PLAYER_ENTER_GRAND_PRIX             = $0176,
    PLAYER_LEAVE_GRAND_PRIX             = $0177,
    ENTER_GRAND_PRIX_EVENT              = $0179,
    LEAVE_GRAND_PRIX_EVENT              = $017A,
    PLAYER_SET_ASSIST_MODE              = $0184,
    PLAYER_CHAR_MASTERY                 = $0188,
    PLAYER_RECYCLE_ITEM                 = $018D,
    NOTHING                             = $FFFF
  );

  TSGPID = (
    PLAYER_MAIN_DATA                    = $0044,
    GAME_PLAY_INFO                      = $0052,
    PLAYER_ACTION_SHOT                  = $0055,
    PLAYER_ACTION_ROTATE                = $0056,
    PLAYER_ACTION_CHANGE_CLUB           = $0059,
    PLAYER_NEXT                         = $0063,
    PLAYER_CHARACTERS_DATA              = $0070,
    PLAYER_CADDIES_DATA                 = $0071,
    PLAYER_EQUIP_DATA                   = $0072,
    PLAYER_ITEMS_DATA                   = $0073,
    PLAYER_1ST_SHOT_READY               = $0090,
    PLAYER_COOKIES                      = $0096,
    PLAYER_LOADING_INFO                 = $00A3,
    PLAYER_MASCOTS_DATA                 = $00E1,
    NOTHING                             = $FFFF
  );

  // Sync server packets from any server to Sync server
  TSSPID = (

    // Register on Sync server
    REGISTER_SERVER             = $0000,

    // Send player Sync packet
    PLAYER_SYNC                 = $0001,

    // Do an action related to the player requested by a server
    PLAYER_ACTION               = $0002,

    NOTHING                     = $FFFF
  );

  // Action packet with players
  TSSAPID = (
    SEND_SERVER_LIST           = $0001, // Send the list of game server
    SEND_LOBBIES_LIST          = $0002, // Send the list of lobbies
    PLAYER_MAIN_SAVE           = $0003,
    PLAYER_CHARACTERS          = $0004,
    PLAYER_ITEMS               = $0005,
    PLAYER_CADDIES             = $0006,
    PLAYER_COOKIES             = $0007,
    PLAYER_MASCOTS             = $0008,
    NOTHING                    = $FFFF
  );

{$SCOPEDENUMS OFF}

function WriteAction(actionId: TSGPID): RawByteString; overload;
function WriteAction(actionId: TSSPID): RawByteString; overload;
function WriteAction(actionId: TSSAPID): RawByteString; overload;
function WriteAction(actionId: TCGPID): RawByteString; overload;

implementation

function WriteAction(actionId: TSGPID): RawByteString;
begin
  setLength(result, 2);
  move(actionId, result[1], 2);
end;

function WriteAction(actionId: TSSPID): RawByteString;
begin
  setLength(result, 2);
  move(actionId, result[1], 2);
end;

function WriteAction(actionId: TSSAPID): RawByteString;
begin
  setLength(result, 2);
  move(actionId, result[1], 2);
end;

function WriteAction(actionId: TCGPID): RawByteString;
begin
  setLength(result, 2);
  move(actionId, result[1], 2);
end;

end.
