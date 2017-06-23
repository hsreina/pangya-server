{*******************************************************}
{                                                       }
{       Pangya Server                                   }
{                                                       }
{       Copyright (C) 2015 Shad'o Soft tm               }
{                                                       }
{*******************************************************}

unit IffManager.Skin;

interface

uses
  IffManager.IffEntry, IffManager.IffEntryList;

type

  TSkinData = packed Record // $DC
    var base: TIffbase;
    var un: array [0..$4B] of UTF8Char;
  End;

  TSkinDataClass = class (TIffEntry<TSkinData>)
    public
      constructor Create(data: PUTF8Char);
  end;

  TSkin = class (TIffEntryList<TSkinData, TSkinDataClass>)
    private
    public
  end;

implementation

constructor TSkinDataClass.Create(data: PUTF8Char);
begin
  inherited;
end;

end.
