unit IffManager.Ball;

interface

uses
  IffManager.IffEntry, IffManager.IffEntryList;

type

  TBallData = packed Record // $318
    var base: TIffbase;
    var un: array [0..$30F] of AnsiChar;
  End;

  TBallDataClass = class (TIffEntry<TBallData>)
    public
      constructor Create(data: PAnsiChar);
  end;

  TBall = class (TIffEntryList<TBallData, TBallDataClass>)
    private
    public
      function GetDataSize: UInt32;
  end;

implementation

uses ConsolePas;

constructor TBallDataClass.Create(data: PAnsiChar);
begin
  inherited;
end;

function TBall.GetDataSize: UInt32;
begin
  Result := $318;
end;

end.
