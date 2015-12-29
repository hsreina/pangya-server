{*******************************************************}
{                                                       }
{       Pangya Server                                   }
{                                                       }
{       Copyright (C) 2015 Shad'o Soft tm               }
{                                                       }
{*******************************************************}

unit PlayerCaddies;

interface

uses PlayerGenericDataList, PlayerCaddie, SyncableServer;

type
  TPlayerCaddies = TPlayerGenericDataList<TPlayerCaddieData,
    TPlayerCaddie>;

implementation

end.
