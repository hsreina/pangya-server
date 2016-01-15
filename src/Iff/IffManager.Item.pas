{*******************************************************}
{                                                       }
{       Pangya Server                                   }
{                                                       }
{       Copyright (C) 2015 Shad'o Soft tm               }
{                                                       }
{*******************************************************}

unit IffManager.Item;

interface

uses
  IffManager.IffEntry, IffManager.IffEntryList;

type

  TItemData = packed Record // $E0
    var base: TIffbase;
    var un: array [0..$4F] of AnsiChar;
  End;

  TItemDataClass = class (TIffEntry<TItemData>)
    public
      constructor Create(data: PAnsiChar);
  end;

  TItem = class (TIffEntryList<TItemData, TItemDataClass>)
    private
    public
  end;

implementation

uses ConsolePas;

constructor TItemDataClass.Create(data: PAnsiChar);
begin
  inherited;
end;

end.
