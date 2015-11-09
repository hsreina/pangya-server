unit PangyaPacketsDef;

interface

type

  // Client login packets (packets sent from the game to the Login Server)
  TCLPID = (
    CLPID_PLAYER_LOGIN                = $0001,
    CLPID_PLAYER_SELECT_SERVER        = $0003,
    CLPID_PLAYER_SET_NICKNAME         = $0006,
    CLPID_PLAYER_CONFIRM              = $0007,
    CLPID_PLAYER_SELECT_CHARCTER      = $0008,
    CLPID_PLAYER_RECONNECT = $000B,
    CLPID_NOTHING                     = $FFFF
  );

  TSLPID = (
    SPID_SERVERS_LIST                 = $0002,
    SPID_NOTHING                      = $FFFF
  );

  // Client game packets (packets sent from the game to the Game Server)
  TCGPID = (
    CGPID_PLAYER_LOGIN                = $0002,
    CGPID_PLAYER_JOIN_LOBBY           = $0004,
    CGPID_PLAYER_BUY_ITEM             = $001D,
    CGPID_PLAYER_CHANGE_EQUIP         = $0020,
    CGPID_PLAYER_UN_0140              = $0140
  );

  // Sync server packets from any server to Sync server
  TSSPID = (
    SSPID_LOGIN_PLAYER_SYNC           = $0001, // send player Sync packet
    SSPID_LOGIN_PLAYER_ACTION         = $0002, // do an action related to the player
    SSPID_NOTHING                     = $FFFF
  );


  // Action packet with players
  TSSAPID = (
    SSAPID_SEND_SERVER_LIST           = $0001, // Send the list of gamae server
    SSAPID_NOTHING                    = $FFFF
  );

implementation

end.
