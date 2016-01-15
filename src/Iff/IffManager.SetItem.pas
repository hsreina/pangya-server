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
    var un: array [0..$63] of AnsiChar;
  End;

  TSetItemDataClass = class (TIffEntry<TSetItemData>)
    public
      constructor Create(data: PAnsiChar);
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

end.
