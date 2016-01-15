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
    var un: array [0..$5B] of AnsiChar;
  End;

  TClubSetDataClass = class (TIffEntry<TClubSetData>)
    public
      constructor Create(data: PAnsiChar);
  end;

  TClubSet = class (TIffEntryList<TClubSetData, TClubSetDataClass>)
    private
    public
  end;

implementation

uses ConsolePas;

constructor TClubSetDataClass.Create(data: PAnsiChar);
begin
  inherited;
end;

end.
