{*******************************************************}
{                                                       }
{       Pangya Server                                   }
{                                                       }
{       Copyright (C) 2015 Shad'o Soft tm               }
{                                                       }
{*******************************************************}

unit PlayerData;

interface

uses PlayerCharacter, PacketData, Math, PlayerClubData, PlayerCaddie, defs,
  PlayerEquipment, PlayerMascot;

type

  PPlayerInfo1 = ^TPlayerInfo1;
  TPlayerInfo1 = packed record
    var game: UInt16;
    var login: array [0..$15] of UTF8Char;
    var nickname: array [0..$15] of UTF8Char;

    var un0004: array [0..$20] of UTF8Char;
    var gmflag: UInt8; // with $f, gm magic will come true
    var un0005: array [0..$6] of UTF8Char;
    var ConnectionId: UInt32;
    var un0006: array [0..$1F] of UTF8Char;
    var charFlag: UInt8; // with $f, seem to disable the chat
    var un0007: array [0..$8A] of UTF8Char;
    var PlayerID: UInt32;
  end;

  PPlayerInfo2 = ^TPlayerInfo2;
  TPlayerInfo2 = packed record
    var un001: UInt32;
    var totalStroke: Int32;
    var totalPlayTime: UInt32; // seconds
    var avgStrokeTime: UInt32; // seconds
    var un0002: array [0..$B] of UTF8Char;
    var OBRate: UInt32; // 1 = 100%?
    var totalDistance: UInt32; // forgot the unit should fix it
    var totalHoles: UInt32;
    var un003: UInt32;
    var hio: UInt32;
    var un0001: array [0..$19] of UTF8Char;
    var experience: UInt32;
    var rank: TRank;
    var pangs: Int64;
    var un0003: array [0..$39] of UTF8Char;
    var quitRateY: UInt32; // right value
    var un0004: array [0..$1F] of UTF8Char;
    var gameComboX: UInt32; // left part of game combo
    var gameComboY: UInt32; // right part of game combo
    var quitRateX: UInt32; // left value
    var totalPangaBattlePangsWin: UInt64;
    var un0005: array [0..$25] of UTF8Char;
  end;

  PPlayerUnknowData1 = ^TPlayerUnknowData1;
  TPlayerUnknowData1 = packed record // size : $2B
    info: array [0..$2A] of UTF8Char;
  end;

  PPlayerData = ^TPlayerData;
  TPlayerData = packed record
    var playerInfo1: TPlayerInfo1;
    var playerInfo2: TPlayerInfo2;
    var un0003: array [0..$4D] of UTF8Char;
    var witems: TPlayerEquipment;
    var un0002: array [0..$2A53] of UTF8Char;

    var equipedCharacter: TPlayerCharacterData;
    var equipedCaddie: TPlayerCaddieData;
    var equipedClub: TPlayerClubData;

    var equipedMascot: TPlayerMascotData;

    procedure Clear;
    function ToPacketData: TPacketData;
    procedure Load(packetData: TPacketData);
    procedure SetLogin(login: RawByteString);
    procedure SetNickname(nickname: RawByteString);
  end;

implementation

procedure TPlayerData.Clear;
begin
  FillChar(self.playerInfo1.game, SizeOf(TPlayerData), 0);
end;

function TPlayerData.ToPacketData: TPacketData;
const
  sizeOfTPlayerData = SizeOf(TPlayerData);
begin
  setLength(result, sizeOfTPlayerData);
  move(self.playerInfo1.game, result[1], sizeOfTPlayerData);
end;

procedure TPlayerData.Load(packetData: TPacketData);
begin
  move(packetData[1], self.playerInfo1.game, SizeOf(TPlayerData));
end;

procedure TPlayerData.SetLogin(login: RawByteString);
var
  size: Integer;
begin
  size := 16;
  FillChar(self.playerInfo1.login[0], size, 0);
  size := Min($16, Length(login));
  move(login[1], self.playerInfo1.login[0], size);
end;

procedure TPlayerData.SetNickname(nickname: RawByteString);
var
  size: Integer;
begin
  size := 16;
  FillChar(self.playerInfo1.nickname[0], size, 0);
  size := Min($16, Length(nickname));
  move(nickname[1], self.playerInfo1.nickname[0], size);
end;

end.
