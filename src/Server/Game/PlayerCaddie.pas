unit PlayerCaddie;

interface

uses PlayerGenericData;

type
  TPlayerCaddieData = packed record
    var Id: Uint32;
    var IffId: Uint32;
    var Un: array [0..$10] of AnsiChar;
  end;

  TPlayerCaddie = class (TPlayerGenericData<TPlayerCaddieData>)
    public
      procedure SetIffId(iffId: UInt32);
      procedure SetID(id: UInt32);
  end;

implementation

procedure TPlayerCaddie.SetIffId(iffId: Cardinal);
begin
  self.m_data.IffId := IffId;
end;

procedure TPlayerCaddie.SetID(id: Cardinal);
begin
  self.m_data.Id := id;
end;

end.
