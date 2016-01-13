unit IffManager.ClubSet;

interface

uses
  IffManager.IffEntry, IffManager.IffEntryList;

type

  TClubSetData = packed Record // $EC
    var base: TIffbase;
    var un: array [0..$E3] of AnsiChar;
  End;

  TClubSetDataClass = class (TIffEntry<TClubSetData>)
    public
      constructor Create(data: PAnsiChar);
  end;

  TClubSet = class (TIffEntryList<TClubSetData, TClubSetDataClass>)
    private
    public
      function GetDataSize: UInt32;
  end;

implementation

uses ConsolePas;

constructor TClubSetDataClass.Create(data: PAnsiChar);
begin
  inherited;
end;

function TClubSet.GetDataSize: UInt32;
begin
  Result := $EC;
end;

end.
