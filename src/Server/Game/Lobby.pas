{*******************************************************}
{                                                       }
{       Pangya Server                                   }
{                                                       }
{       Copyright (C) 2015 Shad'o Soft tm               }
{                                                       }
{*******************************************************}

unit Lobby;

interface

uses PacketData, GameServerPlayer, Generics.Collections, GamesList, Game,
  SysUtils, Packet, PacketReader, PacketWriter, LoggerInterface;

type

  TPLayerList = TList<TGameClient>;

  TLobby = class
    private
      var m_id: UInt8;
      var m_players: TPLayerList;
      var m_games: TGamesList;
      var m_name: RawByteString;

      var m_maxPlayers: UInt16;
      var m_nullGame: TGame;
      var m_logger: ILoggerInterface;

      procedure OnCreateGame(game: TGame);
      procedure OnDestroyGame(game: TGame);
      procedure OnUpdateGame(game: TGame);

      procedure OnPlayerJoinGame(game: TGame; player: TGameClient);
      procedure OnPlayerLeaveGame(game: TGame; player: TGameClient);

    public
      function Build: TPacketData;
      property Id: UInt8 read m_id write m_id;

      procedure AddPlayer(player: TGameClient);
      procedure RemovePlayer(player: TGameClient);
      function GetGameById(gameId: Uint16): TGame;
      function GetPlayerGame(player: TGameClient): TGame;
      procedure Send(data: RawByteString); overload;
      procedure Send(data: TPacket); overload;

      property Players: TPLayerList read m_players;
      property NullGame: TGame read m_nullGame;

      function CreateGame(args: TGameCreateArgs): TGame;
      procedure DestroyGame(game: Tgame);

      procedure JoinMultiplayerGamesList(client: TgameClient);
      procedure LeaveMultiplayerGamesList(client: TgameClient);

      procedure HandlePlayerCreateGame(const client: TGameClient; const packetReader: TPacketReader);
      procedure HandlePlayerJoinGame(const client: TGameClient; const packetReader: TPacketReader);
      procedure HandleAdminJoinGame(const client: TGameClient; const packetReader: TPacketReader);
      procedure HandlePlayerEnterGrandPrixEvent(const client: TGameClient; const packetReader: TPacketReader);
      function GetFirstPlayer: TgameClient;

      constructor Create(const ALogger: ILoggerInterface; lobbyName: RawByteString);
      destructor Destroy; override;
  end;

implementation

uses GameServerExceptions, defs;

constructor TLobby.Create(const ALogger: ILoggerInterface; lobbyName: RawByteString);
var
  gameInfo: TPlayerCreateGameInfo;
  args: TGameCreateArgs;
begin
  inherited Create;
  m_logger := ALogger;
  m_players := TList<TGameClient>.Create;
  m_games := TGamesList.Create(ALogger);
  m_name := lobbyName;

  m_games.OnCreateGame.Event := self.OnCreateGame;
  m_games.OnDestroyGame.Event := self.OnDestroyGame;

  gameInfo.gameType := TGAME_TYPE.GAME_TYPE_VERSUS_STROKE;
  gameInfo.mode := TGAME_MODE.GAME_MODE_FRONT;
  gameInfo.maxPlayers := 255;

  args.Name := 'null game';
  args.Password := '';
  args.GameInfo := gameInfo;
  args.Artifact := 0;
  args.GrandPrix := 0;

  m_nullGame := m_games.CreateGame(args, self.OnUpdateGame);
  m_maxPlayers := 255;
end;

destructor TLobby.Destroy;
begin
  m_players.Free;
  m_games.Free;
  inherited;
end;

procedure TLobby.AddPlayer(player: TGameClient);
begin
  if m_players.Count >= m_maxPlayers then
  begin
    raise LobbyFullException.Create('Lobby full');
  end;
  m_players.Add(player);
  player.Data.Lobby := m_id;
  m_nullGame.AddPlayer(player);
end;

procedure TLobby.RemovePlayer(player: TGameClient);
var
  game: TGame;
begin
  m_players.Remove(player);
  player.Data.Lobby := $FF;
  game := m_games.GetGameById(player.Data.Data.playerInfo1.game);
  game.RemovePlayer(player);
end;

function TLobby.Build: TPacketData;
var
  packet: TPacketWriter;
begin
  packet := TPacketWriter.Create;

  packet.WriteStr(m_name, 20, #$00);
  packet.WriteStr(
    #$00#$01#$00#$00#$01#$00#$00#$00#$00 +
    #$00#$00#$00#$00#$00#$00#$00#$00#$00#$00#$00#$08#$10#$06#$07#$1A +
    #$00#$00#$00#$00#$00#$00#$00#$01#$14#$00#$00#$64#$02#$00#$1A#$00 +
    #$00#$00#$00
  );

  packet.WriteUInt16(m_maxPlayers);
  packet.WriteUInt16(m_players.Count);
  packet.WriteUInt8(m_id);

  packet.WriteStr(
    #$00 +
    #$00 + // Seem to be restrictions on the lobby $10 beginer and junior $20 junior and senior
    #$00#$00#$00#$00 +
    #$00#$00
  );

  Result := packet.ToStr;
  packet.Free;
end;

function TLobby.GetPlayerGame(player: TGameClient): TGame;
begin
  Exit(m_games.GetGameById(player.Data.Data.playerInfo1.game));
end;

function TLobby.GetGameById(gameId: Uint16): TGame;
begin
  Exit(m_games.GetGameById(gameId));
end;

procedure TLobby.Send(data: RawByteString);
var
  client: TGameClient;
begin
  for client in m_players do
  begin
    client.Send(data);
  end;
end;

procedure TLobby.Send(data: TPacket);
var
  client: TGameClient;
begin
  for client in m_players do
  begin
    client.Send(data);
  end;
end;

procedure TLobby.OnPlayerJoinGame(game: TGame; player: TGameClient);
begin
  self.Send(
    #$46#$00#$03#$01 +
    player.Data.LobbyInformations
  );
end;

procedure TLobby.OnPlayerLeaveGame(game: TGame; player: TGameClient);
begin
  self.Send(
    #$46#$00#$03#$01 +
    player.Data.LobbyInformations
  );
end;

procedure TLobby.OnCreateGame(game: TGame);
begin
  if game.Id = 0 then
  begin
    Exit;
  end;

  game.OnPlayerJoinGame.Event := self.OnPlayerJoinGame;
  game.OnPlayerLeaveGame.Event := self.OnPlayerLeaveGame;

  self.Send(
    #$47#$00#$01#$01#$FF#$FF +
    game.GameInformation
  );
end;

procedure TLobby.OnDestroyGame(game: TGame);
begin
  if game.Id = 0 then
  begin
    Exit;
  end;
  self.Send(
    #$47#$00#$01#$02#$FF#$FF +
    game.GameInformation
  );
end;

function TLobby.CreateGame(args: TGameCreateArgs): TGame;
begin
  Exit(m_games.CreateGame(args, self.OnUpdateGame));
end;

procedure TLobby.DestroyGame(game: Tgame);
begin
  m_games.DestroyGame(game);
end;

procedure TLobby.JoinMultiplayerGamesList(client: TGameClient);
var
  player: TGameClient;
  game: TGame;
  playersInList: UInt32;
  outData: RawByteString;
  firstPacket: Boolean;
  gamesInList: UInt32;
begin

  playersInList := 0;
  outData := '';
  firstPacket := true;
  for player in m_players do
  begin

    if not player.Data.InGameList then
    begin
      continue;
    end;

    outData := outData + player.Data.LobbyInformations;
    inc(playersinlist);
    if playersinlist >= 8 then
    begin
      if firstPacket then
      begin
        outdata := #$46#$00 + #$04
          + UTF8Char(playersinlist) + outdata;
        firstPacket := false;
      end else
      begin
        outdata := #$46#$00 + #$05
          + UTF8Char(playersinlist) + outdata;
      end;
      client.Send(outdata);
      playersinlist := 0;
      outdata := '';
    end;
  end;

  if playersinlist > 0 then begin
    outdata := #$46#$00 + #$05 +
      UTF8Char(playersinlist) +
      outdata;
      client.Send(outdata);
  end;

  gamesInList := 0;
  outData := '';
  firstPacket := true;

  for game in m_games.List do
  begin

    // Skip the default game
    if game.Id = 0 then
    begin
      Continue;
    end;

    outData := outData + game.GameInformation;
    inc(gamesInList);

    if gamesInList >= 8 then
    begin
      if firstPacket then begin
        outdata := #$47#$00 +
          UTF8Char(gamesInList) + #$00 + #$FF#$FF + outdata;
        firstPacket := false;
      end else begin
        outdata := #$47#$00 +
          UTF8Char(gamesInList) + #$00 + #$FF#$FF + outdata;
      end;
      self.Send(outdata);
      gamesInList := 0;
      outdata := '';
    end;
  end;

  if gamesInList > 0 then begin
    outdata := #$47#$0 +
      UTF8Char(gamesInList) + #$01 + #$FF#$FF + outdata;
      self.Send(outdata);
  end;


  self.Send(
    #$46#$00 + #$01#$01 +
    client.Data.LobbyInformations
  );

  client.Data.InGameList := true;
  client.Send(#$F5#$00);
end;

procedure TLobby.LeaveMultiplayerGamesList(client: TGameClient);
begin

  self.Send(
    #$46#$00 + #$02#$01 +
    client.Data.LobbyInformations
  );

  client.Data.InGameList := false;

  client.Send(#$F6#$00);
end;

procedure TLobby.OnUpdateGame(game: TGame);
begin
  if game.Id = 0 then
  begin
    Exit;
  end;

  if game.PlayerCount = 0 then
  begin
    self.DestroyGame(game);
  end else
  begin
    self.Send(
      #$47#$00#$01#$03#$FF#$FF +
      game.GameInformation
    );
  end;
end;

procedure TLobby.HandlePlayerCreateGame(const client: TGameClient; const packetReader: TPacketReader);
var
  gameInfo: TPlayerCreateGameInfo;
  gameName: RawByteString;
  gamePassword: RawByteString;
  artifact: UInt32;
  game: TGame;
  d: RawByteString;
  res: TPacketWriter;
  args: TGameCreateArgs;
begin
  m_logger.Info('TGameServer.HandlePlayerCreateGame');
  packetReader.Read(gameInfo.un1, SizeOf(TPlayerCreateGameInfo));

  packetReader.ReadPStr(gameName);
  packetReader.ReadPStr(gamePassword);
  packetReader.ReadUInt32(artifact);

  // Lets pprevent game creation for some type of unimplemented games
  if
    not (gameInfo.gameType = TGAME_TYPE.GAME_TYPE_VERSUS_STROKE) AND
    not (gameInfo.gameType = TGAME_TYPE.GAME_TYPE_VERSUS_MATCH) AND
    not (gameInfo.gameType = TGAME_TYPE.GAME_TYPE_CHIP_IN_PRACTICE) AND
    not (gameInfo.gameType = TGAME_TYPE.GAME_TYPE_CHAT_ROOM)
  then
  begin
    res := TPacketWriter.Create;
    // Can't create a game here
    res.WriteStr(#$49#$00);
    res.WriteUInt8(WriteGameCreateResult(TCREATE_GAME_RESULT.CREATE_GAME_CANT_CREATE));
    client.Send(res);
    res.Free;
    Exit;
  end;

  //
  try

    args.Name := gameName;
    args.Password := gamePassword;
    args.GameInfo := gameInfo;
    args.Artifact := artifact;
    args.GrandPrix := 0;

    game := self.CreateGame(args);
    game.AddPlayer(client);
  except
    on E: Exception do
    begin
      m_logger.Error(E.Message);
      Exit;
    end;
  end;

  // result
  client.Send(
    #$4A#$00 +
    #$FF#$FF +
    game.GameResume
  );

  // game game informations
  client.Send(
    #$49#$00 +
    #$00#$00 +
    game.GameInformation
  );

  // my player game info
  client.Send(
    #$48#$00#$00#$FF#$FF#$01 +
    client.Data.GameInformation +
    #$00
  );
end;

procedure TLobby.HandleAdminJoinGame(const client: TGameClient; const packetReader: TPacketReader);
begin
  m_logger.Info('TGameServer.HandleAdminJoinGame');
  HandlePlayerJoinGame(client, packetReader);
end;

procedure TLobby.HandlePlayerJoinGame(const client: TGameClient; const packetReader: TPacketReader);
var
  gameId: UInt16;
  password: RawByteString;
  game: TGame;
begin
  m_logger.Info('TGameServer.HandlePlayerJoinGame');
  {09 00 01 00 00 00  }
  if not packetReader.ReadUInt16(gameId) then
  begin
    m_logger.Error('Failed to get game Id');
    Exit;
  end;
  packetReader.ReadPStr(password);

  try
    game := GetGameById(gameId);
  Except
    on e: Exception do
    begin
      m_logger.Error('well, i ll move that in another place one day or another');
      Exit;
    end;
  end;

  try
    game.AddPlayer(client);
  except
    on e: GameFullException do
    begin
      m_logger.Error(e.Message + ' should maybe tell to the user that the game is full?');
      Exit;
    end;
  end;

  {
  // my player game info
  client.Send(
    #$48#$00 + #$00#$FF#$FF#$01 +
    client.Data.GameInformation
  );

  // Send my informations other player
  game.Send(
    #$48#$00 + #$01#$FF#$FF +
    client.Data.GameInformation
  );
  }

end;

procedure TLobby.HandlePlayerEnterGrandPrixEvent(const client: TGameClient; const packetReader: TPacketReader);
var
  res: TpacketReader;
  gameInfo: TPlayerCreateGameInfo;
  game: TGame;
  args: TGameCreateArgs;
begin
  m_logger.Info('TGameServer.HandlePlayerEnterGrandPrixEvent');

  gameInfo.gameType := TGAME_TYPE.GAME_TYPE_TOURNEY_TOURNEY;
  gameInfo.map := 0;
  gameInfo.holeCount := 3;
  gameInfo.mode := GAME_MODE_FRONT;
  gameInfo.naturalMode := 1;
  gameInfo.maxPlayers := $1E;
  gameInfo.turnTime := 0;
  gameInfo.gameTime := 0;

  args.Name := 'Comet Landing Practice Tournament';
  args.Password := '';
  args.GameInfo := gameInfo;
  args.Artifact := $1A000265;
  args.GrandPrix := 1;

  game := self.CreateGame(args);
  game.AddPlayer(client);

  res := TpacketReader.Create;

  //client.Send(#$53#$02#$00#$00#$00#$00);

  {
  res.WriteStr(
    #$47#$00#$01#$01#$FF#$FF#$43#$6F#$6D#$65#$74#$20#$4C#$61#$6E#$64 +
    #$69#$6E#$67#$20#$50#$72#$61#$63#$74#$69#$63#$65#$20#$54#$6F#$75 +
    #$72#$6E#$61#$6D#$65#$6E#$74#$00#$00#$00#$00#$00#$00#$00#$00#$00 +
    #$00#$00#$00#$00#$00#$00#$00#$00#$00#$00#$00#$00#$00#$00#$00#$00 +
    #$00#$00#$00#$00#$00#$00#$01#$01#$00#$1E#$00 +

    #$A7#$B0#$26#$DA#$D2#$6E#$12#$93#$0C#$05#$A2#$FA#$53#$0D#$9B#$64 + // game key
    #$00#$1E +
    #$03 + // hole count
    #$04 + // game type
    #$73 +
    #$00#$00#$00#$00#$00#$00#$00#$00#$00#$00#$00#$00#$00#$00#$00#$00 +
    #$00#$00#$00#$00#$00#$00#$00#$00#$00#$00#$00#$00#$00#$00#$00#$00 +
    #$00#$00#$00#$00#$00#$00#$00#$00#$00#$00#$00#$00#$00#$00#$00#$00 +
    #$00#$00#$00#$00#$00#$00#$00#$00#$00#$00#$00#$00#$00#$00#$00#$00 +
    #$00#$00#$00#$00#$00#$00#$00#$00#$00#$00#$00#$00#$00#$00#$00#$00 +
    #$00#$00#$00 +
    #$64#$00#$00#$00 +
    #$64#$00#$00#$00 +
    #$FF#$FF#$FF#$FF +
    #$14 +
    #$65#$02#$00#$1A#$01#$00#$00#$00#$00#$02#$00#$00#$00#$02#$00#$00 +
    #$00#$00#$00#$00#$01#$00#$00#$00
  );

  client.Send(res);

  res.Clear;
  res.WriteStr(
    #$4A#$00 +
    #$FF#$FF +
    #$04 + // game type
    #$00 + // map
    #$03 + // hole count
    #$00 + // mode
    #$01#$00#$00#$00 + // natural mode
    #$1E + // max players
    #$1E#$00 +
    #$00#$00#$00#$00 +
    #$00#$00#$00#$00 +
    #$00#$00#$00#$2C#$01 +

    #$21#$00#$43#$6F +
    #$6D#$65#$74#$20#$4C#$61#$6E#$64#$69#$6E#$67#$20#$50#$72#$61#$63 +
    #$74#$69#$63#$65#$20#$54#$6F#$75#$72#$6E#$61#$6D#$65#$6E#$74
  );

  client.Send(res);
  }

  {
  res.Clear;
  res.WriteStr(
    #$49#$00#$00#$00#$43#$6F#$6D#$65#$74#$20#$4C#$61#$6E#$64#$69#$6E +
    #$67#$20#$50#$72#$61#$63#$74#$69#$63#$65#$20#$54#$6F#$75#$72#$6E +
    #$61#$6D#$65#$6E#$74#$00#$00#$00#$00#$00#$00#$00#$00#$00#$00#$00 +
    #$00#$00#$00#$00#$00#$00#$00#$00#$00#$00#$00#$00#$00#$00#$00#$00 +
    #$00#$00#$00#$00#$01#$01#$00#$1E#$01#$A7#$B0#$26#$DA#$D2#$6E#$12 +
    #$93#$0C#$05#$A2#$FA#$53#$0D#$9B#$64#$00#$1E#$03#$04#$73#$00#$00 +
    #$00#$00#$00#$00#$00#$00#$00#$00#$00#$00#$00#$00#$2C#$00#$00#$00 +
    #$00#$00#$00#$00#$00#$00#$00#$00#$00#$00#$00#$00#$00#$00#$00#$00 +
    #$00#$00#$00#$00#$00#$00#$00#$00#$00#$00#$00#$00#$00#$00#$00#$00 +
    #$00#$00#$00#$00#$00#$00#$00#$00#$00#$00#$00#$00#$00#$00#$00#$00 +
    #$00#$00#$00#$00#$00#$00#$00#$00#$00#$00#$00#$00#$00#$00#$00#$00 +
    #$00#$64#$00#$00#$00#$64#$00#$00#$00#$FF#$FF#$FF#$FF#$14#$65#$02 +
    #$00#$1A#$01#$00#$00#$00#$00#$02#$00#$00#$00#$02#$00#$00#$00#$00 +
    #$00#$00#$01#$00#$00#$00
  );
  }

  client.Send(res);


  res.Free;
end;

function TLobby.GetFirstPlayer: TGameClient;
var
  gameCLient: TGameCLient;
begin
  for gameCLient in self.m_players do
  begin
    Exit(gameCLient);
  end;
  Exit(nil);
end;

end.
