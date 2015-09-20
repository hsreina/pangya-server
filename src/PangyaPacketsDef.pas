unit PangyaPacketsDef;

interface

type

  TCLPID = (
    CLPID_PLAYER_LOGIN                = $0001,
    CLPID_PLAYER_SELECT_SERVER        = $0003,
    CLPID_PLAYER_SET_NICKNAME         = $0006,
    CLPID_PLAYER_CONFIRM              = $0007,
    CLPID_PLAYER_SELECT_CHARCTER      = $0008,
    CLPID_NOTHING                     = $FFFF
  );

  TSLPID = (
    SPID_SERVERS_LIST                   = $0002,
    SPID_NOTHING                        = $FFFF
  );

  TCGPID = (
    CGPID_PLAYER_LOGIN                = $0002
  );

implementation

end.
