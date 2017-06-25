{*******************************************************}
{                                                       }
{       Pangya Server                                   }
{                                                       }
{       Copyright (C) 2015 Shad'o Soft tm               }
{                                                       }
{*******************************************************}

unit IffManager.Club;

interface

uses
  IffManager.IffEntry, IffManager.IffEntryList;

type

  TClubData = packed Record // $DC
    var base: TIffbase;
    var un: array [0..$4B] of UTF8Char;
  End;

  TClubDataClass = class (TIffEntry<TClubData>)
    public
      constructor Create(data: PUTF8Char);
  end;

  TClub = class (TIffEntryList<TClubData, TClubDataClass>)
    private
    public
  end;

implementation

constructor TClubDataClass.Create(data: PUTF8Char);
begin
  inherited;
end;

end.

