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
    var un: array [0..$4F] of UTF8Char;
  End;

  TItemDataClass = class (TIffEntry<TItemData>)
    public
      constructor Create(data: PUTF8Char);
  end;

  TItem = class (TIffEntryList<TItemData, TItemDataClass>)
    private
    public
  end;

implementation

constructor TItemDataClass.Create(data: PUTF8Char);
begin
  inherited;
end;

end.
