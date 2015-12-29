{*******************************************************}
{                                                       }
{       Pangya Server                                   }
{                                                       }
{       Copyright (C) 2015 Shad'o Soft tm               }
{                                                       }
{*******************************************************}

unit PlayerItems;

interface

uses PlayerGenericData, PlayerGenericDataList, PlayerItem;

type
  TPlayerItems = TPlayerGenericDataList<TPlayerItemData,
    TPlayerItem>;

implementation

end.
