{*******************************************************}
{                                                       }
{       Pangya Server                                   }
{                                                       }
{       Copyright (C) 2015 Shad'o Soft tm               }
{                                                       }
{*******************************************************}

unit GameServerPlayer;

interface

uses PlayerData, PlayerCharacters, Client, PlayerAction, PlayerItems,
  PlayerCaddies, PlayerQuest, PlayerMascots, IffManager.IffEntryBase,
  PacketWriter;

type

  TGameServerPlayer = class;

  TGameInfo = packed record
    var GameSlot: UInt8;
    var LoadComplete: Boolean;
    var ShotReady: Boolean;
    var ShotSync: Boolean;
    var Holedistance: Single;
    var HoleComplete: Boolean;
    var ReadyForgame: Boolean;
    var Role: UInt8;
  end;

  TGameServerPlayer = class
    private
      var m_lobby: UInt8;
      var m_data: TPlayerData;
      var m_characters: TPlayerCharacters;
      var m_caddies: TPlayerCaddies;
      var m_mascots: TPlayerMascots;
      var m_items: TPlayerItems;
      var m_quest: TPlayerQuest;

      function FGetPlayerData: PPlayerData;
      function FReadIsAdmin: Boolean;
      procedure FWriteIsAdmin(isAdmin: Boolean);
    public
      var Cookies: Int64;
      var Action: TPlayerAction;

      function GameInformation: RawByteString; overload;
      function GameInformation(level: UInt8): RawByteString; overload;
      function LobbyInformations: RawByteString;

      function SubStractIffEntryPrice(iffEntry: TIffEntrybase; quandtity: UInt32): Boolean;
      function AddPangs(amount: UInt32): Boolean;
      function RemovePangs(amount: Uint32): Boolean;
      function AddCookies(amount: UInt32): Boolean;
      function RemoveCookies(amount: UInt32): Boolean;

      property Lobby: Uint8 read m_lobby write m_lobby;
      property Data: PPlayerData read FGetPlayerData;

      property Characters: TPlayerCharacters read m_characters;
      property Items: TPlayerItems read m_items;
      property Caddies: TPlayerCaddies read m_caddies;
      property Mascots: TPlayerMascots read m_mascots;
      property Quests: TPlayerQuest read m_quest;

      property IsAdmin: Boolean read FReadIsAdmin write FWriteIsAdmin;

      var InGameList: Boolean;
      var GameInfo: TGameInfo;

      procedure EquipCharacterById(Id: UInt32);
      procedure EquipMascotById(Id: UInt32);
      procedure EquipCaddieById(Id: UInt32);
      procedure EquipClubById(Id: UInt32);
      procedure EquipAztecByIffId(IffId: UInt32);

      constructor Create;
      destructor Destroy; override;
  end;

  TGameClient = TClient<TGameServerPlayer>;

implementation

uses PlayerCharacter, utils, PlayerEquipment, defs;

constructor TGameServerPlayer.Create;
begin
  inherited;
  m_characters := TPlayerCharacters.Create;
  m_items := TPlayerItems.Create;
  m_caddies := TPlayerCaddies.Create;
  m_mascots := TPlayerMascots.Create;
  m_lobby := $FF;
  InGameList := false;
  m_quest := TPlayerQuest.Create;
end;

destructor TGameServerPlayer.Destroy;
begin
  m_characters.Free;
  m_items.Free;
  m_caddies.Free;
  m_mascots.Free;
  m_quest.Free;
  inherited;
end;

function TGameServerPlayer.FGetPlayerData;
begin
  Exit(@m_data);
end;

function TGameServerPlayer.GameInformation: RawByteString;
begin
  Exit(GameInformation(2));
end;

function TGameServerPlayer.GameInformation(level: UInt8): RawByteString;
var
  packet: TPacketWriter;
begin

  packet := TPacketWriter.Create;

  packet.WriteUInt32(Data.playerInfo1.ConnectionId);

  if level >= 1 then
  begin

    packet.Write(Data.playerInfo1.nickname[0], 22);

    packet.WriteStr(
      #$00#$00#$00#$00#$00#$00#$00#$00#$00#$00#$00#$00#$00#$00#$00#$00 +
      #$00
    );

    packet.WriteUInt8(gameInfo.GameSlot);

    packet.WriteStr(
      #$00#$00#$00#$00
    );

    packet.WriteUInt32(data.witems.decorations.title);

    packet.WriteUInt32(Data.equipedCharacter.Data.IffId);

    // Not sure 100%
    packet.Write(data.witems.decorations, SizeOf(TDecorations));

    packet.WriteUInt8(self.GameInfo.Role);

    packet.WriteUInt8(
      TGeneric.Iff<UInt8>(gameInfo.ReadyForgame, 2, 0)
    );

    packet.Write(self.Data.playerInfo2.rank, 1);

    packet.WriteStr(
      #$00#$0A +
      #$00#$00#$00#$00 + // emblem
      #$00#$00#$00#$00 + // emblem
      #$34#$61#$65#$62 +
      #$00#$00#$00#$00
    );

    packet.WriteUInt32(Data.playerInfo1.PlayerID);

    packet.WriteStr(
      #$00#$00#$00#$00 + // shop flag
      #$00#$00
    );

    packet.WriteStr(
      Action.toRawByteString
    );

    packet.WriteStr(
      #$00#$00#$00#$00#$00#$00#$00#$00#$00#$00#$00 +
      #$00#$00#$00#$00#$00#$00#$00#$00#$00#$00#$00#$00#$00#$00#$00#$00 +
      #$00#$00#$00#$00#$00#$00#$00#$00#$00#$00#$00#$00#$00#$00#$00#$00 +
      #$00#$00#$00#$00#$00#$00#$00#$00#$00#$00#$00#$00#$00#$00#$00#$00 +
      #$00#$00#$00#$00#$00#$00#$00#$00#$00#$00#$00#$00#$00#$00#$00#$00 +
      #$00#$00#$00#$00#$00#$00#$00#$00#$00#$00#$00#$00#$00#$00#$00#$00 +
      #$00#$00#$00#$00#$00#$00#$00#$00#$00#$00#$00#$00#$00#$00#$00#$00 +
      #$00#$00#$00#$00#$00#$00#$00#$00#$00#$00#$00#$00#$00#$00#$00#$00 +
      #$00#$00#$00#$00#$00#$00#$00#$00#$00#$00#$00#$00#$00#$00#$00#$00 +
      #$00#$00#$00#$00#$00#$00#$00#$00#$00#$00#$00#$00#$00#$00#$00#$00 +
      #$00#$00#$00#$00#$00#$00#$00#$00#$00#$00#$00#$00#$00#$00#$00#$00 +
      #$00#$00#$00#$00#$00#$00#$00#$00#$00#$00#$00#$00#$00#$00#$00#$00 +
      #$00#$00#$00#$00#$00#$00#$00#$00#$00#$00#$00#$00#$00#$00#$00#$00 +
      #$00#$00#$00 +
      #$00#$00#$00#$00#$00#$00#$00#$00
    );



    if level >= 2 then
    begin
      packet.Write(Data.equipedCharacter.Data.IffId, SizeOf(TPlayerCharacterData));
    end;

  end;

  Result := packet.ToStr;

  packet.free;
end;

function TGameServerPlayer.LobbyInformations: RawByteString;
var
  packet: TPacketWriter;
  tmpGameId: UInt16;
begin

  // Tmp fix because I'm using the game 0 as lobby null game
  tmpGameId := m_data.playerInfo1.game;
  if tmpGameId = 0 then
  begin
    tmpGameId := $ffff;
  end;

  packet := TPacketWriter.Create;

  packet.WriteUInt32(Data.playerInfo1.PlayerID);
  packet.WriteUInt32(Data.playerInfo1.ConnectionId);
  packet.WriteUInt16(tmpGameId);
  packet.Write(Data.playerInfo1.nickname[0], 22);
  packet.Write(self.Data.playerInfo2.rank, 1);

  packet.WriteStr(
    #$00#$00#$00#$00#$00#$00#$00 +
    #$00#$E8#$03#$00 +
    #$00 +
    #$02 + // gender
    #$00#$00#$00#$00 + // guild ID
    #$67#$75#$69#$6C#$64#$6D#$61#$72#$6B#$00 +
    #$00#$00#$00#$00#$00#$00#$00#$00#$73#$65#$72#$76#$65#$72#$74#$65 +
    #$73#$74#$40#$4E#$54#$00#$00#$00#$00#$00#$00#$00#$00#$00#$00#$00 +
    #$00#$00#$00#$00#$00#$00#$00#$00#$00#$00#$00#$00#$00#$00#$00#$00 +
    #$00#$00#$00#$00#$00#$00#$00#$00#$00#$00#$00#$00#$00#$00#$00#$00 +
    #$00#$00#$00#$00#$00#$00#$00#$00#$00#$00#$00#$00#$00#$00#$00#$00 +
    #$00#$00#$00#$00#$00#$00#$00#$00#$00#$00#$00#$00#$00#$00#$00#$00 +
    #$00#$00#$00#$00#$00#$00#$00#$00#$00#$00#$00#$00#$00#$00#$00#$00 +
    #$00#$00#$00#$00#$00#$00#$00#$00#$00#$00#$00#$00#$00#$00#$00#$00 +
    #$00#$00#$00#$00#$00#$00#$00#$00
  );

  Result := packet.ToStr;

  packet.free;
end;

procedure TGameServerPlayer.EquipCharacterById(Id: Cardinal);
begin
  with self.m_characters.getById(Id) do
  begin
    Data.witems.CharacterId := GetId;
    Data.equipedCharacter := GetData;
  end;
end;

procedure TGameServerPlayer.EquipMascotById(Id: Cardinal);
begin
  with self.m_mascots.getById(Id) do
  begin
    Data.witems.mascotId := GetIffId;
    Data.equipedMascot := GetData;
  end;
end;

procedure TGameServerPlayer.EquipCaddieById(Id: Cardinal);
begin
  with self.m_caddies.getById(Id) do
  begin
    Data.witems.CaddieId := Id;
    Data.equipedCaddie := GetData;
  end;
end;

procedure TGameServerPlayer.EquipClubById(Id: Cardinal);
begin
  // TODO: Should check if the item is really a club
  with self.m_items.getById(Id) do
  begin
    Data.witems.ClubSetId := Id;
    Data.equipedClub.Id := Id;
    Data.equipedClub.IffId := GetIffId;
  end;
end;

procedure TGameServerPlayer.EquipAztecByIffId(IffId: Cardinal);
begin
  // TODO: Should check if the item is really a club
  with self.m_items.getByIffId(IffId) do
  begin
    Data.witems.AztecIffID := IffId;
  end;
end;

function TGameServerPlayer.SubStractIffEntryPrice(iffEntry: TIffEntrybase; quandtity: UInt32): Boolean;
var
  price: UInt32;
  priceType: TPRICE_TYPE;
begin
  price := iffEntry.getPrice * quandtity;
  case iffEntry.GetPriceType of
    PRICE_TYPE_PANG:
    begin
      Result := RemovePangs(price);
    end;
    PRICE_TYPE_COOKIE:
    begin
      Result := RemoveCookies(price);
    end;
  end;
end;

function TGameServerPlayer.AddPangs(amount: Cardinal): Boolean;
begin
  inc(data.playerInfo2.pangs, amount);
  Exit(true);
end;

function TGameServerPlayer.RemovePangs(amount: Cardinal): Boolean;
begin
  if data.playerInfo2.pangs - amount >= 0 then
  begin
    dec(data.playerInfo2.pangs, amount);
    Exit(true);
  end;
  Exit(False);
end;

function TGameServerPlayer.AddCookies(amount: Cardinal): Boolean;
begin
  inc(Cookies, amount);
end;

function TGameServerPlayer.RemoveCookies(amount: Cardinal): Boolean;
begin
  if Cookies - amount >= 0 then
  begin
    dec(Cookies, amount);
    Exit(true);
  end;
  Exit(false);
end;

procedure TGameServerPlayer.FWriteIsAdmin(isAdmin: Boolean);
begin
  m_data.playerInfo1.gmflag := TGeneric.Iff(isAdmin, $f, $0);
end;

function TGameServerPlayer.FReadIsAdmin: Boolean;
begin

end;

end.
