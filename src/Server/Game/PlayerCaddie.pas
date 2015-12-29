{*******************************************************}
{                                                       }
{       Pangya Server                                   }
{                                                       }
{       Copyright (C) 2015 Shad'o Soft tm               }
{                                                       }
{*******************************************************}

unit PlayerCaddie;

interface

uses PlayerGenericData;

type
  TPlayerCaddieData = packed record
    var Id: Uint32;
    var IffId: Uint32;
    var Un: array [0..$10] of AnsiChar;
    function ToStr: AnsiString;
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

function TPlayerCaddieData.ToStr: AnsiString;
begin
  setLength(result, sizeof(TPlayerCaddieData));
  move(self, result[1], sizeof(TPlayerCaddieData));
end;

end.
