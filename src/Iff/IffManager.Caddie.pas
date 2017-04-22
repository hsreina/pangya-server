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
    var un: array [0..$4F] of AnsiChar;
  End;

  TCaddieDataClass = class (TIffEntry<TCaddieData>)
    public
      constructor Create(data: PAnsiChar);
  end;

  TCaddie = class (TIffEntryList<TCaddieData, TCaddieDataClass>)
    private
    public
  end;

implementation

constructor TCaddieDataClass.Create(data: PAnsiChar);
begin
  inherited;
end;

end.
