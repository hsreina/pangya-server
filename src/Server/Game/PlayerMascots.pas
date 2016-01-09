{*******************************************************}
{                                                       }
{       Pangya Server                                   }
{                                                       }
{       Copyright (C) 2015 Shad'o Soft tm               }
{                                                       }
{*******************************************************}

unit PlayerMascots;

interface

uses PlayerGenericDataList, PlayerMascot;

type
  TPlayerMascots = TPlayerGenericDataList<TPlayerMascotData,
    TPlayerMascot, TMascotCounter>;

implementation

end.
