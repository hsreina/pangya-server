unit PangyaPacketsDef;

interface

type

  // Client login packets (packets sent from the game to the Login Server)
  TCLPID = (
    CLPID_PLAYER_LOGIN                      = $0001,
    CLPID_PLAYER_SELECT_SERVER              = $0003,
    CLPID_PLAYER_SET_NICKNAME               = $0006,
    CLPID_PLAYER_CONFIRM                    = $0007,
    CLPID_PLAYER_SELECT_CHARCTER            = $0008,
    CLPID_PLAYER_RECONNECT                  = $000B,
    CLPID_NOTHING                           = $FFFF
  );

  TSLPID = (
    SPID_SERVERS_LIST                       = $0002,
    SPID_NOTHING                            = $FFFF
  );

  // Client game packets (packets sent from the game to the Game Server)
  TCGPID = (
    CGPID_PLAYER_LOGIN                      = $0002,
    CGPID_PLAYER_MESSAGE                    = $0003,
    CGPID_PLAYER_JOIN_LOBBY                 = $0004,
    CGPID_PLAYER_CREATE_GAME                = $0008,
    CGPID_PLAYER_CHANGE_GAME_SETTINGS       = $000A,
    CGPID_PLAYER_LEAVE_GAME                 = $000F,
    CGPID_PLAYER_BUY_ITEM                   = $001D,
    CGPID_PLAYER_CHANGE_EQUIP               = $0020,
    CGPID_PLAYER_ACTION                     = $0063,
    CGPID_PLAYER_JOIN_MULTIPLAYER_GAME_LIST = $0081,
    CGPID_PLAYER_LEAV_MULTIPLAYER_GAME_LIST = $0082,
    CGPID_PLAYER_OPEN_RARE_SHOP             = $0098,
    CGPID_PLAYER_UN_00EB                    = $00EB,
    CGPID_PLAYER_OPEN_SCRATCHY_CARD         = $012A,
    CGPID_PLAYER_UN_0140                    = $0140,
    CGPID_NOTHING                           = $FFFF
  );

  TSGPID = (
    SGPID_PLAYER_MAIN_DATA                  = $0070,
    SGPID_NOTHING                           = $FFFF
  );

  // Sync server packets from any server to Sync server
  TSSPID = (
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
    SSAPID_NOTHING                    = $FFFF
  );

function WriteAction(actionId: TSGPID): AnsiString; overload;
function WriteAction(actionId: TSSPID): AnsiString; overload;
function WriteAction(actionId: TSSAPID): AnsiString; overload;

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

end.
