unit PlayerData;

interface

uses PlayerCharacter, PacketData, Math;

type
  PPlayerData = ^TPlayerData;

  // $248

  TPlayerEquipedItems = packed record
    caddieId: UInt32;
    characterId: UInt32;
  end;

  TPlayerData = packed record

    var game: UInt16;
    var login: array [0..$15] of AnsiChar;
    var nickname: array [0..$15] of AnsiChar;

    var un0001: array [0..$12B] of AnsiChar;
    var pangs: Uint64; // $160

    var un0003: array [0..$E5] of AnsiChar;

    var witems: TPlayerEquipedItems;

    var un0002: array [0..$2ABF] of AnsiChar;

    var equipedCharacter: TPlayerCharacterData;
    var un0000: array [0..$1B3] of AnsiChar;

    procedure Clear;
    function ToPacketData: TPacketData;
    procedure Load(packetData: TPacketData);
    procedure SetLogin(login: AnsiString);
    procedure SetNickname(nickname: AnsiString);
  end;

implementation

procedure TPlayerData.Clear;
begin
  FillChar(self.game, SizeOf(TPlayerData), 0);
end;

function TPlayerData.ToPacketData: TPacketData;
begin
  setLength(result, sizeof(TPlayerData));
  move(self.game, result[1], sizeof(TPlayerData));
end;

procedure TPlayerData.Load(packetData: AnsiString);
begin
  move(packetData[1], self.game, SizeOf(TPlayerData));
end;

procedure TPlayerData.SetLogin(login: AnsiString);
var
  size: Integer;
begin
  size := 16;
  FillChar(self.login[0], size, 0);
  size := Min($16, Length(login));
  move(login[1], self.login[0], size);
end;

procedure TPlayerData.SetNickname(nickname: AnsiString);
var
  size: Integer;
begin
  size := 16;
  FillChar(self.nickname[0], size, 0);
  size := Min($16, Length(nickname));
  move(nickname[1], self.nickname[0], size);
end;

end.
