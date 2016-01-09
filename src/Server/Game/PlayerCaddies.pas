{*******************************************************}
{                                                       }
{       Pangya Server                                   }
{                                                       }
{       Copyright (C) 2015 Shad'o Soft tm               }
{                                                       }
{*******************************************************}

unit PlayerCaddies;

interface

uses PlayerGenericDataList, PlayerCaddie;

type
  TPlayerCaddies = TPlayerGenericDataList<TPlayerCaddieData,
    TPlayerCaddie, TDoubleCounter>;

implementation

end.
