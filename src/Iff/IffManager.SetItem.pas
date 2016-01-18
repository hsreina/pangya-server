{*******************************************************}
{                                                       }
{       Pangya Server                                   }
{                                                       }
{       Copyright (C) 2015 Shad'o Soft tm               }
{                                                       }
{*******************************************************}

unit IffManager.SetItem;

interface

uses
  IffManager.IffEntry, IffManager.IffEntryList;

type

  TItemSetDetail = packed record
    var IffId: UInt32;
    var Count: UInt32;
  end;

  TSetItemData = packed Record // $F4
    var base: TIffbase;
    var un1: array [0..$17] of AnsiChar;
    var nbOfItems : cardinal;
    var IffIds: array [0..$7] of cardinal;
    var un2: array [0..7] of AnsiChar;
    var counts: array [0..$7] of cardinal;
  End;

  TSetItemDataClass = class (TIffEntry<TSetItemData>)
    public
      constructor Create(data: PAnsiChar);

      // Will do better later
      function GetItem(index: UInt32): TItemSetDetail;
      function GetCount: UInt32;
  end;

  TSetItem = class (TIffEntryList<TSetItemData, TSetItemDataClass>)
    private
  end;

implementation

uses ConsolePas;

constructor TSetItemDataClass.Create(data: PAnsiChar);
begin
  inherited;
end;

function TSetItemDataClass.GetItem(index: Cardinal): TItemSetDetail;
begin
  if (index >= 0) and (index < m_data.nbOfItems) then
  begin
    Result.IffId := m_data.IffIds[index];
    Result.Count := m_data.counts[index];
  end;
end;

function TSetItemDataClass.GetCount: UInt32;
begin
  Result := m_data.nbOfItems;
end;

end.
