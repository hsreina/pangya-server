unit PlayerData;

interface

uses PlayerCharacter, PacketData;

type
  PPlayerData = ^TPlayerData;

  // $248

  TPlayerEquipedItems = packed record
    caddieId: UInt32;
    characterId: UInt32;
  end;

  TPlayerData = packed record

    var un0001: array [0..$159] of AnsiChar;
    var pangs: Uint64; // $160

    var un0003: array [0..$E5] of AnsiChar;

    var witems: TPlayerEquipedItems;

    var un0002: array [0..$2ABF] of AnsiChar;

    var equipedCharacter: TPlayerCharacterData;
    var un0000: array [0..$1B3] of AnsiChar;

    procedure Clear;
    function ToPacketData: TPacketData;
    procedure Load(packetData: TPacketData);
  end;

implementation

procedure TPlayerData.Clear;
begin
  FillChar(self.un0001, SizeOf(TPlayerData), 0);
end;

function TPlayerData.ToPacketData: TPacketData;
begin
  setLength(result, sizeof(TPlayerData));
  move(un0001[0], result[1], sizeof(TPlayerData));
end;

procedure TPlayerData.Load(packetData: AnsiString);
begin
  move(packetData[1], self.un0001[0], SizeOf(TPlayerData));
end;

end.
