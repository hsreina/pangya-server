{*******************************************************}
{                                                       }
{       Pangya Server                                   }
{                                                       }
{       Copyright (C) 2015 Shad'o Soft tm               }
{                                                       }
{*******************************************************}

unit PlayerItem;

interface

uses PacketData, PlayerGenericData, ClubStats, PlayerClubData;

type

  TPlayerItemData = packed record // $C4
    var base: TPlayerItemBase;
    var un0: UInt32;
    var qty: UInt32;
    var Un1: array [0..$41] of UTF8Char;
    var UccCode: array [0 .. $7] of UTF8Char;
    var Un2: array [0..$69] of UTF8Char;
  end;

  TPlayerItem = class (TPlayerGenericData<TPlayerItemData>)
    public
      constructor Create;
      function GetClubForEquip: TPlayerClubData;
      procedure SetQty(const AQty: UInt32); override;
      procedure AddQty(const AQty: UInt32); override;
      function RemQty(const AQty: UInt32): Boolean; override;
      function GetQty: UInt32; override;
  end;

implementation

uses ConsolePas;

constructor TPlayerItem.Create;
var
  uccCode: RawByteString;
begin
  inherited;
  //uccCode := '11111111';
  //move(uccCode[1], m_data.UccCode[0], 8);
  //m_data.Un1[$21] := #$2;
  //m_data.Un2[2] := #$1;
end;

// Tmp uggly style
function TPlayerItem.GetClubForEquip: TPlayerClubData;
var
  pstat: PClubStats;
begin
  pstat := @m_data.qty;
  Result.Id := self.GetId;
  Result.IffId := self.GetIffId;
  Result.Stats := pstat^;
end;

procedure TPlayerItem.SetQty(const AQty: UInt32);
begin
  m_data.qty := AQty;
end;

procedure TPlayerItem.AddQty(const AQty: UInt32);
begin
  Inc(m_data.qty, AQty);
end;

function TPlayerItem.RemQty(const AQty: UInt32): Boolean;
var
  qty: UInt32;
begin
  Result := false;
  qty := m_data.qty;
  if qty = 0 then
  begin
    Exit;
  end;
  if (qty - AQty) >= 0 then
  begin
    Dec(m_data.qty, AQty);
    Result := true;
  end;
end;

function TPlayerItem.GetQty: UInt32;
begin
  Result := m_data.qty;
end;

end.
