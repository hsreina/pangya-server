{*******************************************************}
{                                                       }
{       Pangya Server                                   }
{                                                       }
{       Copyright (C) 2015 Shad'o Soft tm               }
{                                                       }
{*******************************************************}

unit Game;

interface

uses
  Generics.Collections, GameServerPlayer, defs, utils, SysUtils,
  GameHoleInfo, Types.Vector3, System.TypInfo, PlayersList, GameHoles, PacketsDef,
  Packet, PacketReader, PacketWriter;

type

  TPlayerCreateGameInfo = packed record
    un1: UInt8;
    turnTime: UInt32;
    gameTime: UInt32;
    maxPlayers: UInt8;
    gameType: TGAME_TYPE;
    holeCount: byte;
    map: UInt8;
    mode: TGAME_MODE;
    naturalMode: UInt32;
  end;

  TGame = class;

  TGameEvent = TEvent<TGame>;

  TGameGenericEvent = class
    private
      var m_event: TGameEvent;
    public
      procedure Trigger(game: TGame);
      property Event: TGameEvent read m_event write m_event;
      constructor Create;
      destructor Destroy; override;
  end;

  TGamePlayerEvent = TEvent2<TGame, TGameClient>;

  TGamePlayerGenericEvent = class
    private
      var m_event: TGamePlayerEvent;
    public
      procedure Trigger(game: TGame; player: TGameClient);
      property Event: TGamePlayerEvent read m_event write m_event;
      constructor Create;
      destructor Destroy; override;
  end;

  TGameCreateArgs = record
    var Name: RawByteString;
    var Password: RawByteString;
    var GameInfo: TPlayerCreateGameInfo;
    var Artifact: UInt32;
    var GrandPrix: UInt32;
  end;

  TGame = class
    private
      var m_id: UInt16;
      var m_players: TPlayersList;
      var m_name: RawByteString;
      var m_password: RawByteString;
      var m_gameInfo: TPlayerCreateGameInfo;
      var m_artifact: UInt32;
      var m_gameStarted: Boolean;
      var m_rain_drop_ratio: UInt8;
      var m_gameKey: array [0 .. $F] of UTF8Char;

      var m_grandPrix: Boolean;

      //var m_game_holes: TList<TGameHoleInfo>;
      var m_gameHoles: TGameHoles;

      //var m_currentHole: UInt8;

      var m_onUpdateGame: TGameGenericEvent;
      var m_onPlayerJoinGame: TGamePlayerGenericEvent;
      var m_onPlayerLeaveGame: TGamePlayerGenericEvent;

      var m_currentHolePos: TVector3;
      var m_holeComplete: Boolean;

      procedure generateKey;
      function FGetPlayerCount: UInt16;
      procedure TriggerGameUpdated;
      procedure DecryptShot(data: PUTF8Char; size: UInt32);
      procedure SendGameResult;

      procedure ReorderPlayers(setRoomMaster: Boolean);
      procedure SendWind;

      function playersData: RawByteString;

      procedure HandlePlayerLoadingInfo(const client: TGameClient; const packetReader: TPacketReader);
      procedure HandlePlayerHoleInformations(const client: TGameClient; const packetReader: TPacketReader);
      procedure HandlePlayerLoadOk(const client: TGameClient; const packetReader: TPacketReader);
      procedure HandlePlayerReady(const client: TGameClient; const packetReader: TPacketReader);
      procedure HandlePlayerChangeGameSettings(const client: TGameClient; const packetReader: TPacketReader);
      procedure HandlePlayer1stShotReady(const client: TGameClient; const packetReader: TPacketReader);
      procedure HandlePlayerActionShot(const client: TGameClient; const packetReader: TPacketReader);
      procedure HandlePlayerActionRotate(const client: TGameClient; const packetReader: TPacketReader);
      procedure HandlePlayerActionHit(const client: TGameClient; const packetReader: TPacketReader);
      procedure HandlePlayerActionChangeClub(const client: TGameClient; const packetReader: TPacketReader);
      procedure HandlePlayerFastForward(const client: TGameClient; const packetReader: TPacketReader);
      procedure HandlePlayerChangeEquipment(const client: TGameClient; const packetReader: TPacketReader);
      procedure HandlePlayerChangeEquipment2(const client: TGameClient; const packetReader: TPacketReader);
      procedure HandlePlayerPowerShot(const client: TGameClient; const packetReader: TPacketReader);
      procedure HandlePlayerUseItem(const client: TGameClient; const packetReader: TPacketReader);
      procedure HandlePlayerShotData(const client: TGameClient; const packetReader: TPacketReader);
      procedure HandlePlayerShotSync(const client: TGameClient; const packetReader: TPacketReader);
      procedure HandlerPlayerHoleComplete(const client: TGameClient; const packetReader: TPacketReader);
      procedure HandleMasterKickPlayer(const client: TGameClient; const packetReader: TPacketReader);
      procedure HandlePlayerAction(const client: TGameClient; const packetReader: TPacketReader);
      procedure HandlePlayerMoveAztec(const client: TGameClient; const packetReader: TPacketReader);
      procedure HandlePlayerPauseGame(const client: TGameClient; const packetReader: TPacketReader);
      procedure HandlePlayerLeaveGame(const client: TGameClient; const packetReader: TPacketReader);

      procedure HandlerPlayerEnterShop(const client: TGameClient; const packetReader: TPacketReader);
      procedure HandlePlayerShopBuyItem(const client: TGameClient; const packetReader: TPacketReader);
      procedure HandlePlayerRequestShopIncome(const client: TGameClient; const packetReader: TPacketReader);
      procedure HandlePlayerRequestShopVisitorsCount(const client: TGameClient; const packetReader: TPacketReader);
      procedure HandlePlayerEditShopItems(const client: TGameClient; const packetReader: TPacketReader);
      procedure HandlePlayerCloseShop(const client: TGameClient; const packetReader: TPacketReader);
      procedure HandlePlayerEditShopName(const client: TGameClient; const packetReader: TPacketReader);
      procedure HandlePlayerEditShop(const client: TGameClient; const packetReader: TPacketReader);
      procedure HandlePlayerStartGame(const client: TGameClient; const packetReader: TPacketReader);

    public
      property Id: UInt16 read m_id write m_id;
      property PlayerCount: Uint16 read FGetPlayerCount;

      property OnPlayerJoinGame: TGamePlayerGenericEvent read m_onPlayerJoinGame;
      property OnPlayerLeaveGame: TGamePlayerGenericEvent read m_onPlayerLeaveGame;

      constructor Create(args: TGameCreateArgs; onUpdate: TGameEvent);
      destructor Destroy; override;

      function AddPlayer(player: TGameClient): Boolean;
      function RemovePlayer(player: TGameClient): Boolean;
      function GameInformation: RawByteString;
      function GameResume: RawByteString;
      procedure GoToNextHole;
      procedure Send(data: RawByteString); overload;
      procedure Send(data: TPacket); overload;

      procedure HandleRequests(const game: TGame; const packetId: TCGPID; const client: TGameClient; const packetReader: TPacketReader);

      procedure DebugStartGame(const client: TGameClient; const packetReader: TPacketReader);

  end;

implementation

uses GameServerExceptions, ConsolePas,
  PlayerGenericData, PlayerAction, PlayerCharacter, PlayerEquipment,
  PlayerShopItem, Types.ShotData;

constructor TGameGenericEvent.Create;
begin
  inherited Create;
end;

destructor TGameGenericEvent.Destroy;
begin
  inherited;
end;

procedure TGameGenericEvent.Trigger(game: TGame);
begin
  if Assigned(m_event) then
  begin
    m_event(game);
  end;
end;

constructor TGamePlayerGenericEvent.Create;
begin
  inherited Create;
end;

destructor TGamePlayerGenericEvent.Destroy;
begin
  inherited;
end;

procedure TGamePlayerGenericEvent.Trigger(game: TGame; player: TGameClient);
begin
  if Assigned(m_event) then
  begin
    m_event(game, player);
  end;
end;

constructor TGame.Create(args: TGameCreateArgs; onUpdate: TGameEvent);
var
  I: Integer;
begin
  inherited Create;
  Console.Log('TGame.Create', C_BLUE);
  m_onUpdateGame := TGameGenericEvent.Create;
  m_onPlayerJoinGame := TGamePlayerGenericEvent.Create;
  m_onPlayerLeaveGame := TGamePlayerGenericEvent.Create;

  Console.Log(Format('mode : %s', [GetEnumName(TypeInfo(TGAME_MODE), Integer(args.GameInfo.mode))]));
  Console.Log(Format('type : %s', [GetEnumName(TypeInfo(TGAME_TYPE), Integer(args.GameInfo.gameType))]));

  m_onUpdateGame.Event := onUpdate;
  m_name := args.Name;
  m_password := args.Password;
  m_gameInfo := args.GameInfo;
  m_artifact := args.Artifact;
  m_players := TPlayersList.Create;
  m_gameStarted := false;
  m_rain_drop_ratio := 10;

  m_grandPrix := args.GrandPrix = 1;

  generateKey;
  m_gameHoles := TGameHoles.Create;
end;

destructor TGame.Destroy;
var
  holeInfo: TGameHoleInfo;
begin
  m_players.Free;
  m_onUpdateGame.Free;
  m_onPlayerJoinGame.Free;
  m_onPlayerLeaveGame.Free;
  m_gameHoles.Free;
  inherited;
end;

function TGame.AddPlayer(player: TGameClient): Boolean;
var
  gamePlayer: TGameClient;
  playerIndex: integer;
  res: TPacketWriter;
  gameId: UInt16;
  playersCount: UInt32;
begin
  playersCount := m_players.Count;

  if m_players.Count >= m_gameInfo.maxPlayers then
  begin
    raise GameFullException.CreateFmt('Game (%d) is full', [Id]);
  end;

  playerIndex := m_players.Add(player);

  // The game 0 is the lobby
  if m_id = 0 then
  begin
    gameId := $FFFF;
  end else
  begin
    gameId := m_id;
  end;

  player.Data.Data.playerInfo1.game := gameId;

  if m_id = 0 then
  begin
    Exit;
  end;

  // tmp fix, should create the list of player when a player leave the game
  with player.Data.gameInfo do
  begin
    ReadyForgame := false;
  end;

  player.Data.Action.clear;

  ReorderPlayers(false);

  // game informations for me
  player.Send(
    #$49#$00 + #$00#$00 +
    self.GameInformation
  );

  self.TriggerGameUpdated;

  m_onUpdateGame.Trigger(self);

  m_onPlayerJoinGame.Trigger(self, player);

  res := TPacketWriter.Create;

  res.WriteStr(#$48#$00 + #$00#$FF#$FF);
  res.WriteUInt8(UInt8(m_players.Count));
  // Other player in game information to me
  for gamePlayer in m_players do
  begin
    res.WriteStr(gamePlayer.Data.GameInformation);
  end;
  res.WriteUInt8(0); // <- seem important

  self.Send(res);

  res.Free;

  {
  player.Send(
    #$48#$00#$00#$FF#$FF#$01 +
    player.Data.GameInformation +
    #$00
  );

  // my player info to others in game
  {
  self.Send(
    #$48#$00 + #$01#$FF#$FF +
    player.Data.GameInformation
  );
  }

  Exit(true);
end;

function TGame.RemovePlayer(player: TGameClient): Boolean;
var
  client: TGameClient;
begin
  if m_players.Remove(player) = -1 then
  begin
    raise PlayerNotFoundException.CreateFmt('Game (%d) can''t remove player with id %d', [self.m_id, player.Data.Data.playerInfo1.PlayerID]);
    Exit(false);
  end;

  player.Data.Data.playerInfo1.game := $FFFF;

  if m_id = 0 then
  begin
    Exit;
  end;

  ReorderPlayers(true);

  self.Send(
    #$48#$00 + #$02 + #$FF#$FF +
    player.Data.GameInformation(0)
  );

  m_onPlayerLeaveGame.Trigger(self, player);

  m_onUpdateGame.Trigger(self);

  Exit(true);
end;

procedure TGame.ReorderPlayers(setRoomMaster: Boolean);
var
  player: TGameClient;
  index: UInt8;
  res: TPacketWriter;
begin
  index := 0;
  for player in m_players do
  begin
    if index = 0 then
    begin
      player.Data.GameInfo.Role := TGeneric.Iff(m_grandPrix, $20, 8);
      if setRoomMaster then
      begin
        // Send the new master
        res := TPacketWriter.Create;
        res.WriteStr(#$7C#$00);
        res.WriteUint32(player.Data.Data.playerInfo1.ConnectionId);
        res.WriteStr(#$FF#$FF);
        self.Send(res);
        res.Free;
      end;
    end else
    begin
      player.Data.GameInfo.Role := 1;
    end;
    inc(index);
    player.Data.GameInfo.GameSlot := index;
  end;
end;

procedure TGame.generateKey;
var
  I: Integer;
begin
  randomize;
  for I := 0 to length(m_gameKey) - 1 do begin
    m_gameKey[I] := UTF8Char(random($F));
  end;
end;

function TGame.GameInformation: RawByteString;
var
  packet: TPacketWriter;
  pl: integer;
  plTest: boolean;
  val: UInt8;
  testResult: UInt8;
  gameType: UInt8;
  specialFlag: UInt8;
begin
  packet := TPacketWriter.Create;

  packet.WriteStr(
    m_name, 33, #$00
  );

  packet.WriteStr(
    #$00#$00#$00#$00#$00#$00#$00#$00#$00 +
    #$00#$00#$00#$00#$00#$00#$00#$00#$00#$00#$00#$00#$00#$00#$00#$00 +
    #$00#$00#$00#$00#$00#$00
  );

  gameType := UInt8(m_gameInfo.gameType);
  if m_gameinfo.gameType = TGAME_TYPE.GAME_TYPE_CHIP_IN_PRACTICE then
  begin
    gameType := $0B;
    specialFlag := $0E; // Chip in practice
  end else
  begin
    specialFlag := $FF;
  end;

  // Grand prix
  // specialFlag := $14;

  pl := Length(m_password);
  plTest := pl > 0;

  packet.WriteUInt8(TGeneric.Iff(plTest, 0, 1));
  packet.WriteUInt8(TGeneric.Iff(m_gameStarted, 0, 1));
  packet.WriteUInt8(0); // ?? 1 change to orange
  packet.WriteUInt8(m_gameInfo.maxPlayers);
  packet.WriteUInt8(UInt8(m_players.Count));
  packet.Write(m_gameKey[0], 16);
  packet.WriteStr(#$00#$1E);
  packet.WriteUInt8(m_gameInfo.holeCount);
  packet.WriteUInt8(gameType);
  packet.WriteUInt16(m_id);
  packet.WriteUInt8(UInt8(m_gameInfo.mode));
  packet.WriteUInt8(m_gameInfo.map);
  packet.WriteUInt32(m_gameInfo.turnTime);
  packet.WriteUInt32(m_gameInfo.gameTime);

  packet.WriteStr(
    #$00#$00#$00#$00#$00 +
    #$00#$00#$00#$00#$00#$00#$00#$00#$00#$00#$00#$00#$00#$00#$00#$00 +
    #$00#$00#$00#$00#$00#$00#$00#$00#$00#$00#$00#$00#$00#$00#$00#$00 +
    #$00#$00#$00#$00#$00#$00#$00#$00#$00#$00#$00#$00#$00#$00#$00#$00 +
    #$00#$00#$00#$00#$00#$00#$00#$00#$00#$00#$00#$00#$00#$00#$00#$00 +
    #$00#$00#$00#$64#$00#$00#$00#$64#$00#$00#$00 +
    #$00#$00#$00#$00 // game created by player id
  );

  packet.WriteUInt8(specialFlag);

  packet.WriteUInt32(self.m_artifact);
  packet.WriteUInt32(m_gameInfo.naturalMode);

  packet.WriteStr(
    #$00#$00#$00#$00 +
    #$00#$00#$00#$00 +
    #$00#$00#$00#$00 +
    #$00#$00#$00#$00
  );

  Result := packet.ToStr;

  packet.Free;
end;

function TGame.GameResume: RawByteString;
var
  packet: TPacketWriter;
  gameType: UInt8;
begin
  packet := TPacketWriter.Create;

  gameType := UInt8(m_gameInfo.gameType);
  if m_gameinfo.gameType = TGAME_TYPE.GAME_TYPE_CHIP_IN_PRACTICE then
  begin
    gameType := $0b;
  end;

  packet.WriteUInt8(gameType);
  packet.WriteUInt8(m_gameInfo.map);
  packet.WriteUInt8(m_gameInfo.holeCount);
  packet.WriteUInt8(UInt8(m_gameInfo.mode));
  packet.WriteUInt32(m_gameInfo.naturalMode);
  packet.WriteUInt8(m_gameInfo.maxPlayers);
  packet.WriteStr(#$1E#$00);
  packet.WriteUInt32(m_gameInfo.turnTime);
  packet.WriteUInt32(m_gameInfo.gameTime);
  packet.WriteStr(#$00#$00#$00#$00#$00);
  packet.WritePStr(m_name);

  Result := packet.ToStr;
  packet.Free;
end;

procedure TGame.Send(data: RawByteString);
var
  client: TGameClient;
begin
  for client in m_players do
  begin
    client.Send(data);
  end;
end;

procedure TGame.Send(data: TPacket);
var
  client: TGameClient;
begin
  for client in m_players do
  begin
    client.Send(data);
  end;
end;

function TGame.FGetPlayerCount: UInt16;
begin
  Exit(Uint16(m_players.Count));
end;

function TGame.playersData: RawByteString;
var
  player: TGameClient;
  clientPacket: TPacketWriter;
  playersCount: integer;
begin
  clientPacket := TPacketWriter.Create;
  playersCount := m_players.Count;

  clientPacket.WriteUInt8(playersCount);
  for player in m_players do
  begin
    clientPacket.WriteStr(player.Data.GameInformation);
    clientPacket.WriteStr(#$00);
  end;

  Result := clientPacket.ToStr;
  clientPacket.Free;
end;

procedure TGame.HandlePlayerLoadingInfo(const client: TGameClient; const packetReader: TPacketReader);
var
  progress: UInt8;
  res: TPacketWriter;
begin
  Console.Log('TGame.HandlePlayerLoadingInfo', C_BLUE);
  packetReader.ReadUInt8(progress);

  console.Log(Format('percent loaded: %d', [progress * 10]));

  res := TPacketWriter.Create;

  res.WriteStr(WriteAction(TSGPID.PLAYER_LOADING_INFO));
  res.WriteUInt32(client.Data.Data.playerInfo1.ConnectionId);
  res.WriteUInt8(progress);

  self.Send(res);

  res.Free;
end;

procedure TGame.HandlePlayerHoleInformations(const client: TGameClient; const packetReader: TPacketReader);
type
  TData = packed record
    un1: array [0..9] of UTF8Char;
    a, b, // start pos?
    x, z: Single; // hole position
  end;
var
  data: TData;
begin
  // Should validate this between players
  Console.Log('TGame.HandlePlayerHoleInformations', C_BLUE);
  Console.Log('Should do that', C_ORANGE);
  packetReader.Read(data, sizeOf(TData));
  Console.Log(Format('a: %f, b: %f, c:%f, d: %f', [data.a, data.b, data.x, data.z]), C_RED);

  m_currentHolePos.x := data.x;
  m_currentHolePos.z := data.z;
end;

procedure Tgame.SendWind;
var
  res: TPacketWriter;
begin
  with self.m_gameHoles.CurrentHole do
  begin
    res := TPacketWriter.Create;
    res.WriteStr(#$5B#$00);
    res.WriteUInt16(Wind.windpower);
    res.WriteUInt8(byte(random(255)));
    res.WriteStr(#$00#$01);

    self.Send(res);

    res.Free;
  end;
end;

procedure TGame.HandlePlayerLoadOk(const client: TGameClient; const packetReader: TPacketReader);
var
  reply: TPacketWriter;
  AllPlayersReady: Boolean;
  numberOfPlayerRdy: UInt8;
  player: TGameClient;
begin
  Console.Log('TGame.HandlePlayerLoadOk', C_BLUE);
  AllPlayersReady := false;
  numberOfPlayerRdy := 0;

  with client.Data.gameInfo do
  begin
    LoadComplete := true;
    Holedistance := 99999999;
    HoleComplete := false;
  end;

  for player in m_players do
  begin
    with player.Data.gameInfo do
    begin
      if LoadComplete then
      begin
        Inc(numberOfPlayerRdy)
      end;
    end;
  end;

  if not (numberOfPlayerRdy = m_players.Count) then
  begin
    Exit;
  end;

  m_holeComplete := false;

  // Weather informations
  self.Send(#$9E#$00 + #$00#$00#$00);

  self.SendWind;

  reply := TPacketWriter.Create;

  reply.WriteStr(#$53#$00);
  reply.WriteUInt32(client.Data.Data.playerInfo1.ConnectionId);

  // Who play
  self.Send(reply);

  reply.Free;

  self.Send(
    #$15#$01#$0D#$00#$57#$5F#$42#$49#$47#$42#$4F#$4E#$47#$44#$41#$52 +
    #$49#$01#$00#$00#$01#$02#$00#$00#$02#$02#$00#$00#$01#$00#$00#$01 +
    #$03#$01#$00#$00#$02#$00#$01#$00#$01#$01#$02#$02#$00#$01#$02#$01 +
    #$00#$00#$00#$00#$02#$00#$01#$01#$00#$00#$00#$02#$03#$01#$00#$00 +
    #$03#$02#$00#$01#$01#$01#$01#$01#$01#$00#$02#$00#$03#$01#$00#$00 +
    #$01#$00#$00#$01#$00#$02#$00#$01#$00#$00#$00#$02#$00#$02#$00#$01 +
    #$00#$01#$00#$01#$00#$00#$03#$02#$01#$01#$00#$00#$00#$00#$01#$00 +
    #$00#$00#$01#$00#$00
  );

  self.Send(
    #$15#$01#$0D#$00#$52#$5F#$42#$49#$47#$42#$4F#$4E#$47#$44#$41#$52 +
    #$49#$00#$00#$01#$02#$01#$01#$00#$01#$02#$02#$01#$02#$00#$00#$00 +
    #$01#$02#$02#$02#$00#$01#$00#$00#$00#$00#$02#$02#$01#$02#$00#$00 +
    #$00#$00#$00#$02#$00#$00#$02#$00#$00#$00#$00#$00#$00#$00#$01#$00 +
    #$02#$00#$01#$01#$00#$00#$01#$02#$00#$02#$02#$00#$00#$01#$01#$01 +
    #$00#$03#$02#$00#$02#$01#$00#$00#$00#$02#$02#$00#$02#$02#$00#$02 +
    #$00#$02#$02#$02#$01#$00#$01#$00#$00#$00#$00#$00#$02#$00#$02#$02 +
    #$01#$00#$02#$00#$01
  );

  self.Send(
    #$15#$01#$0F#$00#$43#$4C#$55#$42#$53#$45#$54#$5F#$4D#$49#$52#$41 +
    #$43#$4C#$45#$01#$01#$02#$03#$01#$02#$01#$01#$01#$02#$02#$01#$03 +
    #$01#$03#$03#$01#$01#$01#$01#$02#$01#$03#$02#$01#$02#$03#$03#$01 +
    #$03#$01#$02#$01#$03#$02#$03#$02#$02#$03#$02#$03#$02#$03#$03#$03 +
    #$02#$03#$03#$02#$02#$01#$01#$02#$02#$02#$02#$01#$03#$03#$03#$03 +
    #$01#$03#$02#$01#$01#$03#$02#$01#$01#$02#$02#$02#$01#$01#$03#$03 +
    #$02#$02#$03#$03#$01#$02#$03#$02#$01#$01#$01#$02#$03#$03#$02#$02 +
    #$02#$03#$01#$01#$03#$02#$03
  );

end;

procedure TGame.HandlePlayerReady(const client: TGameClient; const packetReader: TPacketReader);
var
  status: UInt8;
  connectionId: UInt32;
  reply: TPacketWriter;
begin
  Console.Log('TGame.HandlePlayerReady', C_BLUE);

  packetReader.ReadUInt8(status);

  client.Data.GameInfo.ReadyForgame := status > 0;

  reply := TPacketWriter.Create;

  reply.WriteStr(#$78#$00);
  reply.WriteUInt32(client.Data.Data.playerInfo1.ConnectionId);
  reply.WriteUInt8(status);

  self.Send(reply);

  reply.Free
end;

procedure TGame.DebugStartGame(const client: TGameClient; const packetReader: TPacketReader);
begin
  self.HandlePlayerStartGame(client, packetReader);
end;

procedure TGame.HandlePlayerStartGame(const client: TGameClient; const packetReader: TPacketReader);
var
  res: TPacketWriter;
  player: TGameClient;
  gameHoleInfo: TGameHoleInfo;
begin
  Console.Log('TGame.HandlePlayerStartGame', C_BLUE);

  m_gameStarted := true;

  self.Send(#$77#$00 + #$64#$00#$00#$00); // ??

  res := TPacketWriter.Create;

  res.WriteStr(#$76#$00 + #$00);
  res.WriteUInt8(UInt8(PlayerCount));

  m_gameHoles.Init(
    self.m_gameInfo.mode,
    self.m_gameInfo.map,
    self.m_gameInfo.holeCount
  );

  for player in m_players do
  begin
    with player.Data do
    begin
      gameInfo.ShotReady := false;
      gameInfo.LoadComplete := false;
      gameInfo.ShotSync := false;
      res.WriteStr(Data.ToPacketData);
    end;
  end;

  self.Send(res);

  res.Clear;

  res.WriteStr(WriteAction(TSGPID.GAME_PLAY_INFO));
  res.WriteUInt8(self.m_gameInfo.map);
  res.WriteStr(#$00#$00);
  res.WriteUInt8(self.m_gameInfo.holeCount);
  res.WriteStr(#$00#$00#$00#$00);
  res.WriteInt32(self.m_gameInfo.turnTime);
  res.WriteInt32(self.m_gameInfo.gameTime);

  // Holes informations
  for gameHoleInfo in m_gameHoles.Holes do
  begin
    res.WriteStr(
      #$DA#$09#$FA#$2A#$00
    );
    res.WriteUInt8(gameHoleInfo.Map);
    res.WriteUInt8(gameHoleInfo.Hole);
  end;

  if m_gameinfo.gameType = TGAME_TYPE.GAME_TYPE_CHIP_IN_PRACTICE then
  begin
    self.Send(res);
    res.Free;
    Exit;
  end;

  // Coins info
  res.WriteStr(
    #$E5#$09#$00#$00#$05#$01#$00#$00#$00#$00#$00#$00#$00#$00#$00#$00 +
    #$00#$00#$00#$00#$00#$00#$00#$41#$31#$00#$00#$00#$00#$00#$00#$00 +
    #$00#$00#$00#$00#$00#$04#$00#$00#$00#$00#$00#$00#$00#$68#$12#$C4 +
    #$5A#$00#$00#$00#$00#$14#$00#$00#$00#$01#$00#$41#$31#$5C#$5F#$BD +
    #$43#$50#$CD#$8A#$C2#$2B#$BF#$04#$44#$03#$00#$00#$00#$00#$00#$00 +
    #$00#$D7#$D5#$C4#$5A#$00#$00#$00#$00#$14#$00#$00#$00#$01#$00#$41 +
    #$31#$FE#$D4#$AE#$41#$93#$D8#$BA#$C2#$04#$4E#$0B#$44#$03#$00#$00 +
    #$00#$00#$00#$00#$00#$56#$07#$C5#$5A#$00#$00#$00#$00#$14#$00#$00 +
    #$00#$01#$00#$41#$31#$C9#$B6#$96#$43#$DD#$A4#$8E#$C2#$D1#$82#$3D +
    #$C3#$03#$00#$00#$00#$00#$00#$00#$00#$C4#$9E#$C5#$5A#$00#$00#$00 +
    #$00#$14#$00#$00#$00#$01#$00#$41#$31#$AE#$F7#$C5#$43#$EC#$11#$90 +
    #$C2#$02#$0B#$E0#$43#$03#$00#$00#$00#$03#$01#$00#$00#$00#$00#$00 +
    #$00#$00#$00#$00#$00#$00#$00#$00#$00#$00#$00#$00#$41#$31#$00#$00 +
    #$00#$00#$00#$00#$00#$00#$00#$00#$00#$00#$04#$00#$00#$00#$00#$00 +
    #$00#$00#$D5#$60#$EC#$38#$00#$00#$00#$00#$14#$00#$00#$00#$02#$01 +
    #$41#$31#$B0#$F2#$8C#$42#$CB#$61#$11#$C3#$3F#$75#$1A#$43#$03#$00 +
    #$00#$00#$00#$00#$00#$00#$32#$63#$EC#$38#$00#$00#$00#$00#$14#$00 +
    #$00#$00#$02#$01#$41#$31#$6D#$E7#$9D#$41#$F6#$C8#$02#$C3#$17#$D9 +
    #$0F#$C2#$03#$00#$00#$00#$05#$01#$00#$00#$00#$71#$41#$AA#$AB#$00 +
    #$00#$00#$00#$14#$00#$00#$00#$03#$02#$41#$31#$89#$41#$F8#$41#$D5 +
    #$98#$1C#$43#$C5#$30#$98#$C3#$02#$00#$00#$00#$00#$00#$00#$00#$96 +
    #$99#$AA#$AB#$00#$00#$00#$00#$14#$00#$00#$00#$03#$02#$41#$31#$4C +
    #$B7#$A2#$C2#$71#$3D#$8F#$C1#$56#$5E#$F0#$43#$03#$00#$00#$00#$00 +
    #$00#$00#$00#$E0#$13#$AB#$AB#$00#$00#$00#$00#$14#$00#$00#$00#$03 +
    #$02#$41#$31#$46#$B6#$99#$C1#$08#$6C#$90#$42#$A2#$05#$14#$C3#$03 +
    #$00#$00#$00#$00#$00#$00#$00#$A7#$93#$AB#$AB#$00#$00#$00#$00#$14 +
    #$00#$00#$00#$03#$02#$41#$31#$98#$AE#$88#$C2#$8F#$C2#$1B#$C1#$C7 +
    #$5B#$C4#$43#$03#$00#$00#$00#$00#$00#$00#$00#$5F#$BD#$AB#$AB#$00 +
    #$00#$00#$00#$14#$00#$00#$00#$03#$02#$41#$31#$C5#$60#$D0#$C2#$9A +
    #$19#$0B#$42#$0A#$97#$CA#$42#$03#$00#$00#$00#$00#$00#$00#$00#$00 +
    #$00#$00#$00#$00#$00#$00#$00#$00#$00#$00
  );

  self.Send(res);

  self.Send(#$6A#$01#$93#$6C#$00#$00);

  res.Free;
end;

procedure TGame.HandlePlayerChangeGameSettings(const client: TGameClient; const packetReader: TPacketReader);
var
  nbOfActions: UInt8;
  action: UInt8;
  i: UInt8;
  tmpStr: RawByteString;
  tmpUInt8: UInt8;
  tmpUInt16: UInt16;
  tmpUInt32: UInt32;
  currentPlayersCount: UInt16;
begin
  Console.Log('TGame.HandlePlayerChangeGameSettings', C_BLUE);

  packetReader.Skip(2);

  if not packetReader.ReadUInt8(nbOfActions) then
  begin
    Console.Log('Failed to read nbOfActions', C_RED);
    Exit;
  end;

  currentPlayersCount := self.PlayerCount;

  for i := 1 to nbOfActions do begin

    if not packetReader.ReadUInt8(action) then begin
      console.log('Failed to read action', C_RED);
      break;
    end;

    case action of
      0: begin
        if packetReader.ReadPStr(tmpStr) then
        begin
          // TODO: Should Check the size maybe
          m_name := tmpStr;
        end;
      end;
      1: begin
        if packetReader.ReadPStr(tmpStr) then
        begin
          // TODO: Should Check the size maybe
          m_password := tmpStr;
        end;
      end;
      2: begin
        if packetReader.ReadUInt8(tmpUInt8) then
        begin
          m_gameInfo.gameType := TGAME_TYPE(tmpUInt8);
        end;
      end;
      3: begin
        if packetReader.ReadUInt8(tmpUInt8) then
        begin
          m_gameInfo.map := tmpUInt8;
        end;
      end;
      4: begin
        if packetReader.ReadUInt8(tmpUInt8) then
        begin
          m_gameInfo.holeCount := tmpUInt8;
        end;
      end;
      5: begin
        if packetReader.ReadUInt8(tmpUInt8) then
        begin
          m_gameInfo.Mode := TGAME_MODE(tmpUInt8);
        end;
      end;
      6: begin
        if packetReader.ReadUInt8(tmpUInt8) then
        begin
          m_gameInfo.turnTime := tmpUInt8 * 1000;
        end;
      end;
      7: begin
        if packetReader.ReadUInt8(tmpUInt8) then
        begin
          if tmpUInt8 > currentPlayersCount then
          begin
            m_gameInfo.maxPlayers := tmpUInt8;
          end;
        end;
      end;
      14: begin
        if packetReader.ReadUInt32(tmpUInt32) then
        begin
          m_gameInfo.naturalMode := tmpUInt32;
        end;
      end
      else begin
        Console.Log(Format('Unknow action %d', [action]));
      end;
    end;
  end;

  self.TriggerGameUpdated;
end;

procedure TGame.TriggerGameUpdated;
begin
  // game update
  self.Send(
    #$4A#$00 +
    #$FF#$FF +
    self.GameResume
  );

  // Send lobby update
  self.m_onUpdateGame.Trigger(self);
end;

procedure TGame.HandlePlayer1stShotReady;
var
  player: TGameClient;
  numberOfPlayerRdy: UInt8;
begin
  Console.Log('TGame.HandlePlayerChangeGameSettings', C_BLUE);

  numberOfPlayerRdy := 0;

  for player in m_players do
  begin
    if player.Data.gameInfo.LoadComplete then
    begin
      Inc(numberOfPlayerRdy)
    end;
  end;

  if not (numberOfPlayerRdy = m_players.Count) then
  begin
    Exit;
  end;

  self.Send(WriteAction(TSGPID.PLAYER_1ST_SHOT_READY));
end;

procedure TGame.HandlePlayerActionShot(const client: TGameClient; const packetReader: TPacketReader);
type
  TInfo = packed record
    un1: array [0..$3D] of UTF8Char;
  end;
var
  shotType: UInt16;
  shotInfo: TInfo;
  res: TPacketWriter;
begin
  Console.Log('TGame.HandlePlayerActionShot', C_BLUE);

  packetReader.Log;

  packetReader.ReadUInt16(shotType);

  res := TPacketWriter.Create;
  res.WriteStr(WriteAction(TSGPID.PLAYER_ACTION_SHOT));
  res.WriteUInt32(client.Data.Data.playerInfo1.ConnectionId);

  if shotType = 1 then
  begin
    packetReader.Skip(9);
    packetReader.Read(shotInfo, SizeOf(TInfo));
    res.Write(shotInfo, SizeOf(TInfo));
  end else
  begin
    packetReader.Read(shotInfo, SizeOf(TInfo));
    res.Write(shotInfo, SizeOf(TInfo));
  end;

  res.Log;

  self.Send(res);

  res.Free;
end;

procedure TGame.HandlePlayerActionRotate(const client: TGameClient; const packetReader: TPacketReader);
var
  angle: Double;
  res: TPacketWriter;
begin
  Console.Log('TGame.HandlePlayerActionRoate', C_BLUE);
  Console.Log(Format('Angle : %f', [angle]));

  packetReader.ReadDouble(angle);
  res := TPacketWriter.Create;

  res.WriteStr(WriteAction(TSGPID.PLAYER_ACTION_ROTATE));
  res.WriteUInt32(client.Data.Data.playerInfo1.ConnectionId);
  res.WriteDouble(angle);

  self.Send(res);

  res.Free;
end;

procedure TGame.HandlePlayerActionHit(const client: TGameClient; const packetReader: TPacketReader);
begin
  Console.Log('TGame.HandlePlayerActionHit', C_BLUE);

end;

procedure TGame.HandlePlayerActionChangeClub(const client: TGameClient; const packetReader: TPacketReader);
var
  clubType: TCLUB_TYPE;
  res: TPacketWriter;
begin
  Console.Log('TGame.HandlePlayerActionChangeClub', C_BLUE);
  if not packetReader.Read(clubType, 1) then
  begin
    Exit;
  end;

  res := TPacketWriter.Create;

  res.WriteStr(WriteAction(TSGPID.PLAYER_ACTION_CHANGE_CLUB));
  res.WriteUInt32(client.Data.Data.playerInfo1.ConnectionId);
  res.Write(clubType, 1);

  self.Send(res);

  res.Free;
end;

procedure TGame.DecryptShot(data: PUTF8Char; size: UInt32);
var
  x: Integer;
begin
  for x := 0 to size-1 do
  begin
    data[x] := UTF8Char(byte(data[x]) xor byte(m_gameKey[x mod 16]));
  end;
end;

procedure TGame.HandlePlayerFastForward(const client: TGameClient; const packetReader: TPacketReader);
var
  res: TPacketWriter;
begin
  Console.Log('TGame.HandlePlayerFastForward', C_BLUE);
  {
    offset   0  1  2  3  4  5  6  7   8  9  A  B  C  D  E  F
  00000000  65 00 00 00 40 40                                   e...@@
  }

  res := TPacketWriter.Create;

  res.WriteStr(#$C7#$00);
  res.WriteStr(#$00#$00#$40#$40); // same as sent packet
  res.WriteUInt32(client.Data.Data.playerInfo1.ConnectionId);
  self.Send(res);
  res.Free;
end;

procedure TGame.HandlePlayerChangeEquipment2(const client: TGameClient; const packetReader: TPacketReader);
var
  itemType: UInt8;
  IffId, Id: UInt32;
  characterData: TPlayerCharacterData;
  equipedItem: TPlayerEquipedItems;
  decorations: TDecorations;
  character: TPlayerCharacter;
  ok: Boolean;
begin
  Console.Log('TGame.HandlePlayerChangeEquipment2', C_BLUE);

  Ok := False;

  packetReader.ReadUint8(itemType);

  case itemType of
    0: begin
      if packetReader.Read(characterData, SizeOf(TPlayerCharacterData)) then
      begin
        if (client.Data.Characters.TryGetById(characterData.Data.Id, character)) then
        begin
          client.Data.Data.equipedCharacter := characterData;
          character.Load(characterData.ToPacketData);
        end;

        client.Send(
          #$6B#$00 +
          #$04 + // no clue about it for now
          UTF8Char(itemType) + // the above action?
          characterData.ToPacketData
        );
        Ok := true;
      end;
    end;
    2: begin
      Console.Log('look like equiped items');
      if packetReader.Read(equipedItem, SizeOf(TPlayerEquipedItems)) then
      begin
        client.Data.Data.witems.items := equipedItem;
        client.Send(
          #$6B#$00 +
          #$04 + // no clue about it for now
          UTF8Char(itemType) + // the above action?
          equipedItem.ToPacketData
        );
      end;
    end;
    4: begin // Decoration
      Console.Log('Look like decorations');
      if packetReader.Read(decorations, SizeOf(TDecorations)) then
      begin
        client.Data.Data.witems.decorations := decorations;
      end;
    end;
    5: begin
      if packetReader.ReadUint32(Id) then
      begin
        client.Data.EquipCharacterById(Id);
      end;
    end
    else;
    begin
      Console.Log(Format('Unknow item type %x', [itemType]), C_RED);
      packetReader.Log;
      Exit;
    end;
  end;

  if ok then
  begin
    if self.Id > 0 then
    begin
      // Update game profile
      self.Send(
        #$48#$00 + #$03 + #$FF#$FF +
        client.Data.GameInformation(1)
      );
    end;
  end;
end;

procedure TGame.HandlePlayerShopBuyItem(const client: TGameClient; const packetReader: TPacketReader);
var
  ownerId: UInt32;
  item: TPlayerShopItem;
  res: TPacketWriter;
begin
  Console.Log('TGame.HandlePlayerShopBuyItem', C_BLUE);
  packetReader.Log;

  packetReader.ReadUInt32(ownerId);
  console.Log(Format('ownerId : %x', [ownerId]));

  if not packetReader.Read(item, SizeOf(TPlayerShopItem)) then
  begin
    Exit;
  end;


  res := TPacketWriter.Create;

  // Shop result
  res.WriteStr(
    #$EC#$00 +
    #$01#$00#$00#$00 + // result
    #$00#$5D#$15#$00#$00#$00#$00#$00#$00 +

    #$00#$00#$00#$00 + // item shop id
    #$01#$00#$00#$18#$F7#$6A#$5D#$04#$01#$00#$00#$00#$00 +
    #$00#$00#$02#$00#$00#$00#$00#$00#$00#$00#$00#$00#$00#$00#$00#$00 +
    #$00#$00#$00#$00#$00#$00#$00#$00#$00#$00#$00#$00#$00#$00#$00#$00 +
    #$00#$00#$00#$00#$00#$00#$00#$00#$00#$00#$00#$00#$00#$00#$00#$00 +
    #$00#$00#$00#$00#$00#$00#$00#$00#$00#$00#$00#$00#$00#$00#$00#$00 +
    #$00#$00#$00#$00#$00#$00#$00#$00#$00#$00#$00#$00#$00#$00#$00#$00 +
    #$00#$00#$00#$00#$00#$00#$11#$F0#$CE#$B6#$11#$20#$00#$00#$00#$00 +
    #$00#$00#$00#$00#$00#$00#$00#$00#$00#$00#$00#$00#$00#$00#$00#$00 +
    #$00#$00#$00#$00#$00#$00#$00#$00#$00#$00#$00#$00#$00#$00#$00#$00 +
    #$00#$00#$00#$00#$00#$00#$00#$00#$00#$00#$00#$00#$00#$00#$00#$00 +
    #$00#$00#$00#$00#$00#$00#$00 +

    #$00#$00#$00#$00#$01#$3C#$17#$53#$02 +
    #$01#$00#$00#$18#$00#$00#$00#$00#$01#$00#$00#$00#$00#$00#$00#$00 +
    #$00#$00#$00#$85#$00#$00#$00#$00#$00#$00#$00#$00#$00#$00#$00#$00 +
    #$00#$00#$00#$00#$32#$00#$00#$00#$00#$00#$00#$00#$00#$00#$00#$00 +
    #$00#$00#$00#$00#$00#$00#$00#$00#$00#$00#$00#$00#$00#$00#$00#$00 +
    #$00#$00#$00#$00#$00#$00#$00#$00#$00#$00#$00#$00#$00#$00#$00#$00 +
    #$00#$00#$00#$00#$00#$00#$00#$00#$00#$00#$00#$00#$00#$00#$00#$00 +
    #$00#$00#$00#$00#$00#$00#$00#$00#$00#$00#$00#$00#$00#$00#$00#$00 +
    #$00#$00#$00#$00#$00#$00#$00#$00#$00#$00#$00#$00#$00#$00#$00#$00 +
    #$00#$00#$00#$00#$00#$00#$00#$00#$00#$00#$00#$00#$00#$00#$00#$00 +
    #$00#$00#$00#$00#$00#$00#$00#$00#$00#$00#$00#$00#$00#$00#$00#$00 +
    #$00#$00#$00#$00#$00#$00#$00#$00#$00#$00#$00#$00#$00#$00#$00#$00 +
    #$00#$00#$00#$00#$00#$00#$00#$00#$FF#$FF#$FF#$FF#$00#$00#$00#$00
  );


  client.Send(res);

  res.Clear;

  // decreasing items
  res.WriteStr(
    #$ED#$00 +
    #$05#$00#$68#$73#$72#$65#$69 +
    #$C0#$95#$12#$00 + // player id

    #$00#$00#$00#$00 +
    #$01#$00#$00#$18#$F7#$6A#$5D#$04#$01#$00#$00#$00#$00#$00#$00 +
    #$02#$00#$00#$00#$00#$00#$00#$00#$00#$00#$00#$00#$00#$00#$00#$00 +
    #$00#$00#$00#$00#$00#$00#$00#$00#$00#$00#$00#$00#$00#$00#$00#$00 +
    #$00#$00#$00#$00#$00#$00#$00#$00#$00#$00#$00#$00#$00#$00#$00#$00 +
    #$00#$00#$00#$00#$00#$00#$00#$00#$00#$00#$00#$00#$00#$00#$00#$00 +
    #$00#$00#$00#$00#$00#$00#$00#$00#$00#$00#$00#$00#$00#$00#$00#$00 +
    #$00#$00#$00#$00#$11#$F0#$CE#$B6#$11#$20#$00#$00#$00#$00#$00#$00 +
    #$00#$00#$00#$00#$00#$00#$00#$00#$00#$00#$00#$00#$00#$00#$00#$00 +
    #$00#$00#$00#$00#$00#$00#$00#$00#$00#$00#$00#$00#$00#$00#$00#$00 +
    #$00#$00#$00#$00#$00#$00#$00#$00#$00#$00#$00#$00#$00#$00#$00#$00 +
    #$00#$00#$00#$00#$00#$00#$00#$00#$00 +

    #$01#$00#$00#$00
  );

  client.Send(res);

  res.Free;
end;

procedure TGame.HandlePlayerRequestShopIncome(const client: TGameClient; const packetReader: TPacketReader);
var
  res: TPacketWriter;
begin
  Console.Log('TGame.HandlePlayerRequestShopIncome', C_BLUE);
  res := TPacketWriter.Create;

  res.WriteStr(#$EA#$00);
  res.WriteUInt32(1); // return code
  res.WriteUInt64(99); // income

  client.Send(res);

  res.Free;
end;

procedure TGame.HandlerPlayerEnterShop(const client: TGameClient; const packetReader: TPacketReader);
var
  playerId: UInt32;
  res: TPacketWriter;
begin
  Console.Log('TGame.HandlerPlayerEnterShop', C_BLUE);
  if not packetReader.ReadUInt32(playerId) then
  begin
    Exit;
  end;

  res := TPacketWriter.Create;

  res.WriteStr(
    #$E6#$00
  );

  res.WriteUInt32(1); // result

  res.WriteStr(
    #$68#$73#$72#$65#$69#$00#$61#$43#$61#$74 +
    #$28#$65#$36#$34#$29#$00#$00#$54#$69#$6D#$65#$00
  );

  res.WritePStr('shop name');

  res.WriteUInt32(12231); // shop owner id
  res.WriteUInt32(1); // Number of items

  res.WriteStr(
    #$00#$00#$00#$00 + // item id in shop
    #$01#$00#$00#$18 + // item IffId
    #$11#$11#$11#$11 + // Id
    #$02#$00#$00#$00 + // count
    #$00#$00#$00 +
    #$02#$00#$00#$00 + // price
    #$00#$00#$00#$00#$00#$00 +
    #$00#$00#$00#$00#$00#$00#$00#$00#$00#$00#$00#$00#$00#$00#$00#$00 +
    #$00#$00#$00#$00#$00#$00#$00#$00#$00#$00#$00#$00#$00#$00#$00#$00 +
    #$00#$00#$00#$00#$00#$00#$00#$00#$00#$00#$00#$00#$00#$00#$00#$00 +
    #$00#$00#$00#$00#$00#$00#$00#$00#$00#$00#$00#$00#$00#$00#$00#$00 +
    #$00#$00#$00#$00#$00#$00#$00#$00#$00#$00#$11#$F0#$CE#$B6#$11#$20 +
    #$00#$00#$00#$00#$00#$00#$00#$00#$00#$00#$00#$00#$00#$00#$00#$00 +
    #$00#$00#$00#$00#$00#$00#$00#$00#$00#$00#$00#$00#$00#$00#$00#$00 +
    #$00#$00#$00#$00#$00#$00#$00#$00#$00#$00#$00#$00#$00#$00#$00#$00 +
    #$00#$00#$00#$00#$00#$00#$00#$00#$00#$00#$00#$00#$00#$00#$00
  );

  client.Send(res);

  res.Free;
end;

procedure TGame.HandlePlayerMoveAztec(const client: TGameClient; const packetReader: TPacketReader);
var
  pos: TVector3;
  res: TPacketWriter;
begin
  Console.Log('TGame.HandlePlayerMoveAztec', C_BLUE);
  if not packetReader.Read(pos, SizeOf(TVector3)) then
  begin
    Exit;
  end;

  res := TPacketWriter.Create;

  res.WriteStr(#$60#$00);
  res.Write(pos, SizeOf(TVector3));
  self.Send(res);

  res.Free;
end;

procedure TGame.HandlePlayerPauseGame(const client: TGameClient; const packetReader: TPacketReader);
var
  status: UInt8;
  res: TPacketWriter;
begin
  Console.Log('TGame.HandlePlayerPausegame', C_BLUE);
  if not packetReader.ReadUInt8(status) then
  begin
    Exit;
  end;

  res := TPacketWriter.Create;

  res.WriteStr(#$8B#$00);
  res.WriteUInt32(client.Data.Data.playerInfo1.ConnectionId);
  res.WriteUInt8(status);

  self.Send(res);

  res.Free;
end;

procedure TGame.HandlePlayerRequestShopVisitorsCount(const client: TGameClient; const packetReader: TPacketReader);
var
  res: TPacketWriter;
begin
  Console.Log('TGame.HandlePlayerRequestShopVisitorCount', C_BLUE);
  res := TPacketWriter.Create;

  res.WriteStr(#$E9#$00);
  res.WriteUInt32(1); // return code
  res.WriteUInt32(1); // count

  client.Send(res);

  res.Free;
end;

procedure TGame.HandlePlayerEditShopItems(const client: TGameClient; const packetReader: TPacketReader);
var
  entries: array of TPlayerShopItem;
  count: UInt32;
  entry: TPlayerShopItem;
  res: TPacketWriter;
begin
  Console.Log('TGame.HandlePlayerEditShopItems', C_BLUE);

  if not packetReader.ReadUInt32(count) then
  begin
    Exit;
  end;

  // TODO: should check if count is not too crazy
  setLength(entries, count);

  if not packetReader.Read(entries[0], count * SizeOf(TPlayerShopItem)) then
  begin
    Exit;
  end;

  res := TPacketWriter.Create;

  res.WriteStr(#$EB#$00);
  res.WriteUInt32(1);
  with client.Data.Data.playerInfo1 do
  begin
    res.Write(nickname[0], $16);
    res.WriteUInt32(PlayerID);
  end;

  res.WriteUInt32(count);
  res.Write(entries[0], count * SizeOf(TPlayerShopItem));

  res.Log;

  // TODO: Should Send that to all player in this game
  client.Send(res);

  res.Free;

end;

procedure TGame.HandlePlayerCloseShop(const client: TGameClient; const packetReader: TPacketReader);
var
  res: TPacketWriter;
begin
  Console.Log('TGame.HandlePlayerCloseShop', C_BLUE);

  res := TPacketWriter.Create;

  res.WriteStr(#$E4#$00);
  res.WriteUInt32(1); // return code

  with client.Data.Data.playerInfo1 do
  begin
    res.WritePStr(client.Data.Data.playerInfo1.nickname);
    res.WriteUInt32(client.Data.Data.playerInfo1.PlayerID);
  end;

  client.Send(res);

  res.Free;
end;

procedure TGame.HandlePlayerEditShopName(const client: TGameClient; const packetReader: TPacketReader);
var
  shopName: RawByteString;
  res: TPacketWriter;
begin
  Console.Log('TGame.HandlePlayerEditShopName', C_BLUE);
  if not packetReader.ReadPStr(shopName) then
  begin
    Exit;
  end;

  res := TPacketWriter.Create;
  res.WriteStr(#$E8#$00);
  res.WriteUInt32(1);
  res.WritePStr(shopname);

  with client.Data.Data.playerInfo1 do
  begin
    res.WriteUInt32(PlayerId);
    res.WritePStr(nickname);
  end;

  self.Send(res);

  res.Free;
end;

procedure TGame.HandlePlayerEditShop(const client: TGameClient; const packetReader: TPacketReader);
var
  res: TPacketWriter;
begin
  Console.Log('TGame.HandlePlayerEditShop', C_BLUE);

  res := TPacketWriter.Create;

  if m_gameInfo.gameType = GAME_TYPE_CHAT_ROOM then
  begin

    res.WriteStr(#$E5#$00);
    res.WriteUInt32(1); // return code

    with client.Data.Data.playerInfo1 do
    begin
      res.WritePStr(client.Data.Data.playerInfo1.nickname);
      res.WriteUInt32(client.Data.Data.playerInfo1.PlayerID);
    end;

  end else
  begin
    res.WriteStr(#$E5#$00);
    res.WriteUInt32($1B);
  end;


  client.Send(res);

  res.Free;

end;

procedure TGame.HandlePlayerChangeEquipment(const client: TGameClient; const packetReader: TPacketReader);
type
  THeader = packed record
    Action: UInt8;
    Id: Uint32;
  end;
var
  header: THeader;
  res: TPacketWriter;
  ok: Boolean;
  equipment: TGenericPacketData;
begin
  Console.Log('TGame.HandlePlayerChangeEquipment', C_BLUE);
  if not packetReader.Read(header, SizeOf(THeader)) then
  begin
    Exit;
  end;
  Console.Log(Format('action : %x', [header.Action]));
  Console.Log(Format('id : %x', [header.Id]));

  ok := true;

  res := TPacketWriter.Create;
  res.WriteStr(#$4B#$00);
  res.WriteUInt32(0);
  res.WriteUInt8(header.Action);
  res.WriteUInt32(client.Data.Data.playerInfo1.ConnectionId);

  case header.Action of
    1: begin // Caddie
      Console.Log('Caddie');
      client.Data.EquipCaddieById(header.Id);

      // Equiped caddie data
      res.WriteStr(
        client.Data.Data.equipedCaddie.ToStr
      );
    end;
    2: begin
      Console.Log('Aztec');
      client.Data.EquipAztecByIffId(header.Id);
      res.WriteUint32(header.Id);
    end;
    3: begin
      Console.Log('Club');
      client.Data.EquipClubById(header.Id);
      res.WriteStr(
        client.Data.Data.equipedClub.ToStr
      );
    end;
    4: begin
      Console.Log('Character');
      client.Data.EquipCharacterById(header.Id);
      res.WriteStr(
        client.Data.Data.equipedCharacter.ToPacketData
      );
    end;
    5: begin
      Console.Log('mascot');
      client.Data.EquipMascotById(header.id);
      res.WriteStr(client.Data.Data.equipedMascot.ToStr);
    end
    else begin
      Console.Log(Format('Unknow action %x', [header.Action]));
      ok := false;
    end;
  end;

  if ok then
  begin
    self.Send(res);
    if self.Id > 0 then
    begin
      // Update game profile
      self.Send(
        #$48#$00 + #$03 + #$FF#$FF +
        client.Data.GameInformation(0)
      );
    end;
  end;
  res.Free;
end;

procedure TGame.HandlePlayerPowerShot(const client: TGameClient; const packetReader: TPacketReader);
var
  action: UInt8;
  res: TPacketWriter;
begin
  Console.Log('TGame.HandlePlayerPowerShot', C_BLUE);
  if not packetReader.ReadUInt8(action) then
  begin
    Exit;
  end;

  res := TPacketWriter.Create;
  res.WriteStr(#$58#$00);
  res.WriteUInt32(client.Data.Data.playerInfo1.ConnectionId);
  res.WriteUInt8(action);
  self.Send(res);
  res.Free;
end;

procedure TGame.HandlePlayerUseItem(const client: TGameClient; const packetReader: TPacketReader);
type
  TReply = packed record
    IffId: UInt32;
    Id: UInt32;
    connectionId: UInt32;
  end;
var
  IffId: UInt32;
  res: TPacketWriter;
  reply: TReply;
begin
  Console.Log('TGame.HandlePlayerUseItem', C_BLUE);
  if not packetReader.ReadUInt32(IffId) then
  begin
    Exit;
  end;

  // Should check if the player have this item

  res := TPacketWriter.Create;
  res.WriteStr(#$5A#$00);
  res.WriteUInt32(IffId);
  res.WriteUInt32(1); // item Id
  res.WriteUInt32(client.Data.Data.playerInfo1.ConnectionId);
  self.Send(res);

  res.Free;
end;

procedure TGame.HandlePlayerShotData(const client: TGameClient; const packetReader: TPacketReader);
var
  shotData: TShotData;
  str: RawByteString;
  res: TPacketWriter;
begin
  console.Log('TGame.HandlePlayerShotData', C_BLUE);

  client.Data.gameInfo.ShotSync := false;

  packetReader.Read(shotData, SizeOf(TShotData));
  DecryptShot(@shotData, SizeOf(TShotData));

  res := TPacketWriter.Create;
  res.WriteStr(#$64#$00);
  res.Write(shotData, SizeOf(TShotData));
  self.Send(res);
  res.Free;

  if not (client.Data.Data.playerInfo1.ConnectionId = shotData.connectionId) then
  begin
    Exit;
  end;

  client.Data.GameInfo.holedistance :=
    abs(sqrt(sqr(m_currentHolePos.x - shotData.pos.x) + sqr(m_currentHolePos.z - shotData.pos.z)));

  console.Log(Format('hole distance : %f', [client.Data.GameInfo.holedistance]), C_RED);
end;

procedure TGame.HandlePlayerShotSync(const client: TGameClient; const packetReader: TPacketReader);
var
  player: TGameClient;
  nextPlayer: TGameClient;
  numberOfPlayerRdy: UInt8;
  res: TPacketWriter;
begin
  Console.Log('TGame.HandlePlayerShotSync', C_BLUE);
  client.Data.gameInfo.ShotSync := true;
  numberOfPlayerRdy := 0;

  for player in m_players do
  begin
    if player.Data.gameInfo.ShotSync then
    begin
      Inc(numberOfPlayerRdy)
    end;
  end;

  if not (numberOfPlayerRdy = m_players.Count) then
  begin
    Exit;
  end;

  if self.m_holeComplete then
  begin
    self.GoToNextHole;
  end else
  begin
    // Should update Wind
    // 5B 00 06 00 4A 00 01

    nextPlayer := nil;
    for player in m_players do
    begin
      if player.Data.GameInfo.HoleComplete then
      begin
        continue;
      end;
      if nil = nextPlayer then
      begin
        nextPlayer := player;
      end else if player.Data.GameInfo.Holedistance > nextPlayer.Data.GameInfo.Holedistance then
      begin
        nextPlayer := player;
      end;
    end;

    if not (nil = nextPlayer) then
    begin
      self.SendWind;
      res := TPacketWriter.Create;
      res.WriteStr(WriteAction(TSGPID.PLAYER_NEXT));
      res.WriteInt32(nextPlayer.Data.Data.playerInfo1.ConnectionId);
      self.Send(res);
      res.Free;
    end;

  end;
end;

procedure TGame.HandlerPlayerHoleComplete(const client: TGameClient; const packetReader: TPacketReader);
var
  numberOfPlayerRdy: UInt8;
  player: TGameClient;
begin
  Console.Log('TGame.HandlerPlayerHoleComplete', C_BLUE);
  client.Data.GameInfo.HoleComplete := true;

  numberOfPlayerRdy := 0;
  for player in m_players do
  begin
    if player.Data.gameInfo.HoleComplete then
    begin
      Inc(numberOfPlayerRdy);
    end;
  end;

  if not (numberOfPlayerRdy = m_players.Count) then
  begin
    Exit;
  end;

  m_holeComplete := true;
end;

procedure TGame.GoToNextHole;
begin
  Console.Log('TGame.GoToNextHole', C_BLUE);
  if self.m_gameHoles.GoToNext then
  begin
    self.Send(#$65#$00);
  end else
  begin
    self.SendGameResult;
  end;
end;

procedure TGame.SendGameResult;
var
  player: TGameClient;
  res: TPacketWriter;
  index: UInt8;
begin
  res := TPacketWriter.Create;
  index := 0;

  res.WriteStr(#$66#$00);
  res.WriteUInt8(m_players.Count);

  for player in m_players do
  begin

    inc(index);

    res.WriteUInt32(player.Data.Data.playerInfo1.ConnectionId);
    res.WriteUInt8(index);
    res.WriteUInt8(2); // total point
    res.WriteUInt8(5); // course shot count
    res.WriteUInt16(1000); // player xp
    res.WriteStr(
      #$67#$00#$00#$00 + // pangs
      #$00#$00#$00#$00 +
      #$D2#$00#$00#$00 + // pang bonus
      #$00#$00#$00#$00 +

      #$00#$00#$00#$00 +
      #$00#$00#$00#$00
    );

  end;

  self.Send(res);

  res.Free;

  m_gameStarted := false;
end;

procedure TGame.HandleMasterKickPlayer(const client: TGameClient; const packetReader: TPacketReader);
var
  playerId: UInt32;
  playerToKick: TGameClient;
begin
  Console.Log('TGame.HandleMasterKickPlayer', C_BLUE);

  if not packetReader.ReadUInt32(playerId) then
  begin
    Exit;
  end;

  if not (client.Data.GameInfo.Role = 8) then
  begin
    Console.Log('player is not a master', C_RED);
    Exit;
  end;

  Console.Log('should kick out the player', C_RED);

  try
    playerToKick := m_players.GetById(playerId);
  Except
    on e: NotFoundException do
    begin
      Console.Log(e.Message, C_RED);
      Exit;
    end;
  end;

  // TODO: kick the player out of the game
  Console.Log('Should kick the player now', C_RED);

end;

procedure TGame.HandlePlayerAction(const client: TGameClient; const packetReader: TPacketReader);
var
  action: TPLAYER_ACTION;
  subAction: TPLAYER_ACTION_SUB;
  pos: TVector3;
  tmp: RawByteString;
  animationName: RawByteString;
  gamePlayer: TGameServerPlayer;
  test: TPlayerAction;
  res: TPacketWriter;
begin
  Console.Log('TGame.HandlePlayerAction', C_BLUE);
  Console.Log(Format('ConnectionId : %x', [client.Data.Data.playerInfo1.ConnectionId]));

  if self.Id = 0 then
  begin
    Exit;
  end;

  tmp := packetReader.GetRemainingData;

  if not packetReader.Read(action, 1) then
  begin
    Console.Log('Failed to read player action', C_RED);
    Exit;
  end;

  res := TPacketWriter.Create;
  res.WriteStr(#$C4#$00);
  res.WriteUInt32(client.Data.Data.playerInfo1.ConnectionId);
  res.WriteStr(tmp);

  gamePlayer := client.Data;

  case action of
    // This action is used in vs mode
    // The original version seem to don't have initial value loaded when player join the game
    // Should check about that
    TPLAYER_ACTION.PLAYER_ACTION_NULL: begin
      console.log('rotate?');
      // Just forward the data
    end;
    TPLAYER_ACTION.PLAYER_ACTION_APPEAR: begin

      console.log('Player appear');
      if not packetReader.Read(gamePlayer.Action.pos.x, 12) then begin
        console.log('Failed to read player appear position', C_RED);
        Exit;
      end;

      with client.Data.Action do begin
        console.log(Format('pos : %f, %f, %f', [pos.x, pos.y, pos.z]));
      end;

    end;
    TPLAYER_ACTION.PLAYER_ACTION_SUB: begin

      console.log('player sub action');

      if not packetReader.Read(subAction, 1) then begin
        console.log('Failed to read sub action', C_RED);
      end;

      client.Data.Action.lastAction := byte(subAction);

      case subAction of
        TPLAYER_ACTION_SUB.PLAYER_ACTION_SUB_STAND: begin
          console.log('stand');
        end;
        TPLAYER_ACTION_SUB.PLAYER_ACTION_SUB_SIT: begin
          console.log('sit');
        end;
        TPLAYER_ACTION_SUB.PLAYER_ACTION_SUB_SLEEP: begin
          console.log('sleep');
        end else begin
          console.log('Unknow sub action : ' + IntToHex(byte(subAction), 2));
          Exit;
        end;
      end;
    end;
    TPLAYER_ACTION.PLAYER_ACTION_MOVE: begin

        console.log('player move');

        if not packetReader.Read(pos.x, 12) then begin
          console.log('Failed to read player moved position', C_RED);
          Exit;
        end;

        client.Data.Action.pos.x := client.Data.Action.pos.x + pos.x;
        client.Data.Action.pos.y := client.Data.Action.pos.y + pos.y;
        client.Data.Action.pos.z := pos.z;

        with client.Data.Action do begin
          console.log(Format('pos : %f, %f, %f', [pos.x, pos.y, pos.z]));
        end;
    end;
    TPLAYER_ACTION.PLAYER_ACTION_ANIMATION: begin
      console.log('play animation');
      packetReader.ReadPStr(animationName);
      console.log('Animation : ' + animationName);
    end else begin
      console.log('Unknow action ' + inttohex(byte(action), 2));
    end;
  end;

  self.Send(res);
  res.Free;
end;

procedure TGame.HandlePlayerLeaveGame(const client: TGameClient; const packetReader: TPacketReader);
begin
  Console.Log('TGameServer.HandlePlayerLeaveGame', C_BLUE);

  self.RemovePlayer(client);
  //playerLobby.NullGame.AddPlayer(client);

  {
    // Game lobby info
    // if player count reach 0
    client.Send(
      #$47#$00#$01#$02#$FF#$FF +
      game.LobbyInformation
    );

    // if player count reach 0
    client.Send(
      #$47#$00#$01#$03#$FF#$FF +
      game.LobbyInformation
    );

  }

  client.Send(#$4C#$00#$FF#$FF);

end;

procedure TGame.HandleRequests(const game: TGame; const packetId: TCGPID; const client: TGameClient; const packetReader: TPacketReader);
begin
  case packetId of
    TCGPID.PLAYER_CHANGE_GAME_SETTINGS:
    begin
      game.HandlePlayerChangeGameSettings(client, packetReader);
    end;
    TCGPID.PLAYER_READY:
    begin
      game.HandlePlayerReady(client, packetReader);
    end;
    TCGPID.PLAYER_START_GAME:
    begin
      game.HandlePlayerStartGame(client, packetReader);
    end;
    TCGPID.PLAYER_LOADING_INFO:
    begin
      game.HandlePlayerLoadingInfo(client, packetReader);
    end;
    TCGPID.PLAYER_LOAD_OK:
    begin
      game.HandlePlayerLoadOk(client, packetReader);
    end;
    TCGPID.PLAYER_HOLE_INFORMATIONS:
    begin
      game.HandlePlayerHoleInformations(client, packetReader);
    end;
    TCGPID.PLAYER_1ST_SHOT_READY:
    begin
      game.HandlePlayer1stShotReady(client, packetReader);
    end;
    TCGPID.PLAYER_ACTION_SHOT:
    begin
      game.HandlePlayerActionShot(client, packetReader);
    end;
    TCGPID.PLAYER_ACTION_ROTATE:
    begin
      game.HandlePlayerActionRotate(client, packetReader);
    end;
    TCGPID.PLAYER_ACTION_HIT:
    begin
      game.HandlePlayerActionHit(client, packetReader);
    end;
    TCGPID.PLAYER_ACTION_CHANGE_CLUB:
    begin
      game.HandlePlayerActionChangeClub(client, packetReader);
    end;
    TCGPID.PLAYER_USE_ITEM:
    begin
      game.HandlePlayerUseItem(client, packetReader);
    end;
    TCGPID.PLAYER_SHOTDATA:
    begin
      game.HandlePlayerShotData(client, packetReader);
    end;
    TCGPID.PLAYER_SHOT_SYNC:
    begin
      game.HandlePlayerShotSync(client, packetReader);
    end;
    TCGPID.PLAYER_HOLE_COMPLETE:
    begin
      game.HandlerPlayerHoleComplete(client, packetReader);
    end;
    TCGPID.PLAYER_FAST_FORWARD:
    begin
      game.HandlePlayerFastForward(client, packetReader);
    end;
    TCGPID.PLAYER_POWER_SHOT:
    begin
      game.HandlePlayerPowerShot(client, packetReader);
    end;
    TCGPID.PLAYER_ACTION:
    begin
      game.HandlePlayerAction(client, packetReader);
    end;
    TCGPID.MASTER_KICK_PLAYER:
    begin
      game.HandleMasterKickPlayer(client, packetReader);
    end;
    TCGPID.PLAYER_CHANGE_EQUIP:
    begin
      game.HandlePlayerChangeEquipment2(client, packetReader);
    end;
    TCGPID.PLAYER_CHANGE_EQUPMENT_A:
    begin
      game.HandlePlayerChangeEquipment(client, packetReader);
    end;
    TCGPID.PLAYER_CHANGE_EQUPMENT_B:
    begin
      game.HandlePlayerChangeEquipment(client, packetReader);
    end;
    TCGPID.PLAYER_EDIT_SHOP:
    begin
      game.HandlePlayerEditShop(client, packetReader);
    end;
    TCGPID.PLAYER_EDIT_SHOP_NAME:
    begin
      game.HandlePlayerEditShopName(client, packetReader);
    end;
    TCGPID.PLAYER_CLOSE_SHOP:
    begin
      game.HandlePlayerCloseShop(client, packetReader);
    end;
    TCGPID.PLAYER_EDIT_SHOP_ITEMS:
    begin
      game.HandlePlayerEditShopItems(client, packetReader);
    end;
    TCGPID.PLAYER_REQUEST_SHOP_VISITORS_COUNT:
    begin
      game.HandlePlayerRequestShopVisitorsCount(client, packetReader);
    end;
    TCGPID.PLAYER_PAUSE_GAME:
    begin
      game.HandlePlayerPauseGame(client, packetReader);
    end;
    TCGPID.PLAYER_MOVE_AZTEC:
    begin
      game.HandlePlayerMoveAztec(client, packetReader);
    end;
    TCGPID.PLAYER_ENTER_SHOP:
    begin
      game.HandlerPlayerEnterShop(client, packetReader);
    end;
    TCGPID.PLAYER_REQUEST_INCOME:
    begin
      game.HandlePlayerRequestShopIncome(client, packetReader);
    end;
    TCGPID.PLAYER_BUY_SHOP_ITEM:
    begin
      game.HandlePlayerShopBuyItem(client, packetReader);
    end;
    TCGPID.PLAYER_LEAVE_GAME:
    begin
      game.HandlePlayerLeaveGame(client, packetReader);
    end;
    else begin
      Console.Log(Format('Unknow packet Id %x', [Word(packetID)]), C_RED);
    end;
  end;
end;

end.
