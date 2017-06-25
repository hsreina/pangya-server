{*******************************************************}
{                                                       }
{       Pangya Server                                   }
{                                                       }
{       Copyright (C) 2015 Shad'o Soft tm               }
{                                                       }
{*******************************************************}

unit IffManager.Caddie;

interface

uses
  IffManager.IffEntry, IffManager.IffEntryList;

type

  TCaddieData = packed Record // $E0
    var base: TIffbase;
    var un: array [0..$4F] of UTF8Char;
  End;

  TCaddieDataClass = class (TIffEntry<TCaddieData>)
    public
      constructor Create(data: PUTF8Char);
  end;

  TCaddie = class (TIffEntryList<TCaddieData, TCaddieDataClass>)
    private
    public
  end;

implementation

constructor TCaddieDataClass.Create(data: PUTF8Char);
begin
  inherited;
end;

end.
