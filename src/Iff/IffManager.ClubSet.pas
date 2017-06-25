{*******************************************************}
{                                                       }
{       Pangya Server                                   }
{                                                       }
{       Copyright (C) 2015 Shad'o Soft tm               }
{                                                       }
{*******************************************************}

unit IffManager.ClubSet;

interface

uses
  IffManager.IffEntry, IffManager.IffEntryList;

type

  TClubSetData = packed Record // $EC
    var base: TIffbase;
    var un: array [0..$5B] of UTF8Char;
  End;

  TClubSetDataClass = class (TIffEntry<TClubSetData>)
    public
      constructor Create(data: PUTF8Char);
  end;

  TClubSet = class (TIffEntryList<TClubSetData, TClubSetDataClass>)
    private
    public
  end;

implementation

constructor TClubSetDataClass.Create(data: PUTF8Char);
begin
  inherited;
end;

end.
