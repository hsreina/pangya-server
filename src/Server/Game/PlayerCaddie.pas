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
    var base: TPlayerItemBase;
    var Un: array [0..$10] of UTF8Char;
    function ToStr: RawByteString;
  end;

  TPlayerCaddie = class (TPlayerGenericData<TPlayerCaddieData>)
    public
      //function GetIffId: UInt32; override;
      //procedure SetIffId(iffId: UInt32); override;
      //function GetId: UInt32; override;
      //procedure SetId(id: UInt32); override;
  end;

implementation

{
procedure TPlayerCaddie.SetIffId(iffId: Cardinal);
begin
  self.m_data.IffId := IffId;
end;

function TPlayerCaddie.GetIffId;
begin
  Result := self.m_data.IffId;
end;

procedure TPlayerCaddie.SetID(id: Cardinal);
begin
  self.m_data.Id := id;
end;

function TPlayerCaddie.GetId;
begin
  Result := self.m_data.Id;
end;
}

function TPlayerCaddieData.ToStr: RawByteString;
begin
  setLength(result, sizeof(TPlayerCaddieData));
  move(self, result[1], sizeof(TPlayerCaddieData));
end;

end.
