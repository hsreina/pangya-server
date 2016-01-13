unit IffManager.Caddie;

interface

uses
  IffManager.IffEntry, IffManager.IffEntryList;

type

  TCaddieData = packed Record // $E0
    var base: TIffbase;
    var un: array [0..$D7] of AnsiChar;
  End;

  TCaddieDataClass = class (TIffEntry<TCaddieData>)
    public
      constructor Create(data: PAnsiChar);
  end;

  TCaddie = class (TIffEntryList<TCaddieData, TCaddieDataClass>)
    private
    public
      function GetDataSize: UInt32;
  end;

implementation

uses ConsolePas;

constructor TCaddieDataClass.Create(data: PAnsiChar);
begin
  inherited;
end;

function TCaddie.GetDataSize: UInt32;
begin
  Result := $E0;
end;

end.
