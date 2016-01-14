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

  TSetItemData = packed Record // $F4
    var base: TIffbase;
    var un: array [0..$EB] of AnsiChar;
  End;

  TSetItemDataClass = class (TIffEntry<TSetItemData>)
    public
      constructor Create(data: PAnsiChar);
  end;

  TSetItem = class (TIffEntryList<TSetItemData, TSetItemDataClass>)
    private
    public
      function GetDataSize: UInt32; override;
  end;

implementation

uses ConsolePas;

constructor TSetItemDataClass.Create(data: PAnsiChar);
begin
  inherited;
end;

function TSetItem.GetDataSize: UInt32;
begin
  Result := $F4;
end;

end.
