unit PlayerData;

interface

uses PlayerCharacter, PacketData, Math, PlayerClubData, PlayerCaddie, defs;

type

  PPlayerEquipedItems = ^TPlayerEquipedItems;
  TPlayerEquipedItems = packed record
    caddieId: UInt32;
    characterId: UInt32;
    clubSetId: UInt32;
    aztecIffID: UInt32;

    var un3: UInt32;
    var un4: UInt32;
    var un5: UInt32;
    var un6: UInt32;
    var un7: UInt32;
    var un8: UInt32;
    var un9: UInt32;
    var un10: UInt32;
    var un11: UInt32;
    var un12: UInt32;

    var un13: UInt32;
    var un14: UInt32;
    var un15: UInt32;
    var un16: UInt32;
    var un17: UInt32;
    var un18: UInt32;

    var un19: UInt32;
    var un20: UInt32;
    var un21: UInt32;
    var un22: UInt32;
    var un23: UInt32;
    var un24: UInt32;
    var un25: UInt32;
    var un26: UInt32;
    var un27: UInt32;
  end;

  PPlayerInfo1 = ^TPlayerInfo1;
  TPlayerInfo1 = packed record
    var game: UInt16;
    var login: array [0..$15] of AnsiChar;
    var nickname: array [0..$15] of AnsiChar;

    var un0004: array [0..$20] of AnsiChar;
    var gmflag: UInt8; // with $f, gm magic will come true
    var un0005: array [0..$6] of AnsiChar;
    var ConnectionId: UInt32;
    var un0006: array [0..$1F] of AnsiChar;
    var charFlag: UInt8; // with $f, seem to disable the chat
    var un0007: array [0..$8A] of AnsiChar;
    var PlayerID: UInt32;
  end;

  PPlayerInfo2 = ^TPlayerInfo2;
  TPlayerInfo2 = packed record
    var un001: UInt32;
    var totalStroke: Int32;
    var totalPlayTime: UInt32; // seconds
    var avgStrokeTime: UInt32; // seconds
    var un0002: array [0..$B] of AnsiChar;
    var OBRate: UInt32; // 1 = 100%?
    var totalDistance: UInt32; // forgot the unit should fix it
    var totalHoles: UInt32;
    var un003: UInt32;
    var hio: UInt32;
    var un0001: array [0..$19] of AnsiChar;
    var experience: UInt32;
    var rank: TRank;
    var pangs: Int64;
    var un0003: array [0..$39] of AnsiChar;
    var quitRateY: UInt32; // right value
    var un0004: array [0..$1F] of AnsiChar;
    var gameComboX: UInt32; // left part of game combo
    var gameComboY: UInt32; // right part of game combo
    var quitRateX: UInt32; // left value
    var totalPangaBattlePangsWin: UInt64;
    var un0005: array [0..$25] of AnsiChar;
  end;

  PPlayerUnknowData1 = ^TPlayerUnknowData1;
  TPlayerUnknowData1 = packed record // size : $2B
    info: array [0..$2A] of ansichar;
  end;

  PPlayerData = ^TPlayerData;
  TPlayerData = packed record
    var playerInfo1: TPlayerInfo1;
    var playerInfo2: TPlayerInfo2;
    var un0003: array [0..$4D] of AnsiChar;
    var witems: TPlayerEquipedItems;
    var un0002: array [0..$2A53] of AnsiChar;

    var equipedCharacter: TPlayerCharacterData;
    var equipedCaddie: TPlayerCaddieData;
    var equipedClub: TPlayerClubData;

    var un0000: array [0..$4E] of AnsiChar;

    // now sound like something related to guilds
    var un0001: array [0..$12F] of AnsiChar;

    procedure Clear;
    function ToPacketData: TPacketData;
    function Debug1: TPacketData;
    procedure Load(packetData: TPacketData);
    procedure SetLogin(login: AnsiString);
    procedure SetNickname(nickname: AnsiString);
  end;

implementation

procedure TPlayerData.Clear;
begin
  FillChar(self.playerInfo1.game, SizeOf(TPlayerData), 0);
end;

function TPlayerData.ToPacketData: TPacketData;
begin
  setLength(result, sizeof(TPlayerData));
  move(self.playerInfo1.game, result[1], sizeof(TPlayerData));
end;

function TPlayerData.Debug1: TPacketData;
begin
  setLength(result, $2F95);
  move(self.playerInfo1.game, result[1], $2F95);
end;

procedure TPlayerData.Load(packetData: AnsiString);
begin
  move(packetData[1], self.playerInfo1.game, SizeOf(TPlayerData));
end;

procedure TPlayerData.SetLogin(login: AnsiString);
var
  size: Integer;
begin
  size := 16;
  FillChar(self.playerInfo1.login[0], size, 0);
  size := Min($16, Length(login));
  move(login[1], self.playerInfo1.login[0], size);
end;

procedure TPlayerData.SetNickname(nickname: AnsiString);
var
  size: Integer;
begin
  size := 16;
  FillChar(self.playerInfo1.nickname[0], size, 0);
  size := Min($16, Length(nickname));
  move(nickname[1], self.playerInfo1.nickname[0], size);
end;

end.
