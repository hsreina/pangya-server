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
    var un: array [0..$D3] of AnsiChar;
  End;

  TClubDataClass = class (TIffEntry<TClubData>)
    public
      constructor Create(data: PAnsiChar);
  end;

  TClub = class (TIffEntryList<TClubData, TClubDataClass>)
    private
    public
      function GetDataSize: UInt32; override;
  end;

implementation

uses ConsolePas;

constructor TClubDataClass.Create(data: PAnsiChar);
begin
  inherited;
end;

function TClub.GetDataSize: UInt32;
begin
  Result := $DC;
end;

end.

