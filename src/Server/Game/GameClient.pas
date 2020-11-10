unit GameClient;

interface

uses Client, GameServerPlayer;

type
  TGameClient = TClient<TGameServerPlayer>;

implementation

end.
