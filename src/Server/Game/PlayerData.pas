unit PlayerData;

interface

uses PlayerCharacter, PacketData;

type
  PPlayerData = ^TPlayerData;
  TPlayerData = packed record
    var un0001: array [0..$17F] of AnsiChar;
    var pangs: Uint64;
    var un0002: array [0..$2BAB] of AnsiChar;
    var equipedCharacter: TPlayerCharacter;
    var un0000: array [0..$1B3] of AnsiChar;

    function ToPacketData: TPacketData;
    procedure Load(packetData: TPacketData);
  end;

implementation

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
