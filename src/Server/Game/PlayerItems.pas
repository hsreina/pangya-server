unit PlayerItems;

interface

uses PlayerGenericData, PlayerGenericDataList, PlayerItem;

type
  TPlayerItems = TPlayerGenericDataList<TPlayerItemData,
    TPlayerItem>;

implementation

end.
