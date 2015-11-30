unit PlayerCaddies;

interface

uses PlayerGenericDataList, PlayerCaddie, SyncableServer;

type
  TPlayerCaddies = TPlayerGenericDataList<TPlayerCaddieData,
    TPlayerCaddie>;

implementation

end.
