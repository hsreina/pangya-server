unit Lobby;

interface

uses PacketData, GamePlayer, Generics.Collections, GamesList, Game, PangyaBuffer;

type

  TPLayerList = TList<TGameClient>;

  TLobby = class
    private
      var m_id: UInt8;
      var m_players: TPLayerList;
      var m_games: TGamesList;
      var m_maxPlayers: UInt16;
      var m_nullGame: TGame;

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
      procedure Send(data: AnsiString); overload;
      procedure Send(data: TPangyaBuffer); overload;

      property Players: TPLayerList read m_players;
      property NullGame: TGame read m_nullGame;

      function CreateGame(name, password: AnsiString; gameInfo: TPlayerCreateGameInfo; artifact: UInt32): TGame;
      procedure DestroyGame(game: Tgame);

      procedure JoinMultiplayerGamesList(client: TgameClient);
      procedure LeaveMultiplayerGamesList(client: TgameClient);

      constructor Create;
      destructor Destroy; override;
  end;

implementation

uses ClientPacket, ConsolePas, GameServerExceptions;

constructor TLobby.Create;
var
  gameInfo: TPlayerCreateGameInfo;
begin
  inherited;
  m_players := TList<TGameClient>.Create;
  m_games := TGamesList.Create;

  m_games.OnCreateGame.Event := self.OnCreateGame;
  m_games.OnDestroyGame.Event := self.OnDestroyGame;

  m_nullGame := m_games.CreateGame('null game', '', gameInfo, 0, self.OnUpdateGame);
  m_maxPlayers := 20;
end;

destructor TLobby.Destroy;
begin
  inherited;
  m_players.Free;
  m_games.Free;
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
  packet: TClientPacket;
begin
  packet := TClientPacket.Create;

  packet.WriteStr('test', 20, #$00);
  packet.WriteStr(
    #$00#$01#$00#$00#$01#$00#$00#$00#$00 +
    #$00#$00#$00#$00#$00#$00#$00#$00#$00#$00#$00#$08#$10#$06#$07#$1A +
    #$00#$00#$00#$00#$00#$00#$00#$01#$14#$00#$00#$64#$02#$00#$1A#$00 +
    #$00#$00#$00
  );

  packet.WriteUInt16(UInt16(m_maxPlayers));
  packet.WriteUInt16(UInt16(m_players.Count));
  packet.WriteUInt8(m_id);

  packet.WriteStr(
    #$00 +
    #$00 + // Seem to be restrictions on the lobby
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

procedure TLobby.Send(data: AnsiString);
var
  client: TGameClient;
begin
  for client in m_players do
  begin
    client.Send(data);
  end;
end;

procedure TLobby.Send(data: TPangyaBuffer);
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

end;

procedure TLobby.OnPlayerLeaveGame(game: TGame; player: TGameClient);
begin

end;

procedure TLobby.OnCreateGame(game: TGame);
begin
  if game.Id = 0 then
  begin
    Exit;
  end;

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

function TLobby.CreateGame(name, password: AnsiString; gameInfo: TPlayerCreateGameInfo; artifact: UInt32): TGame;
begin
  Exit(m_games.CreateGame(name, password, gameInfo, artifact, self.OnUpdateGame));
end;

procedure TLobby.DestroyGame(game: Tgame);
begin
  m_games.DestroyGame(game);
end;

procedure TLobby.JoinMultiplayerGamesList(client: TGameClient);
var
  p: TGameClient;
  playersinlist: integer;
  outData: AnsiString;
  firstPacket: Boolean;
begin

  playersInList := 0;
  outData := '';
  firstPacket := true;
  for p in m_players do
  begin

    if not P.Data.InGameList then
    begin
      continue;
    end;

    outData := outData + p.Data.LobbyInformations;
    inc(playersinlist);
    if playersinlist >= 8 then
    begin
      if firstPacket then
      begin
        outdata := #$46#$00 + #$04
          + ansichar(playersinlist) + outdata;
        firstPacket := false;
      end else
      begin
        outdata := #$46#$00 + #$05
          + ansichar(playersinlist) + outdata;
      end;
      client.Send(outdata);
      playersinlist := 0;
      outdata := '';
    end;
  end;

  if playersinlist > 0 then begin
    outdata := #$46#$00 + #$05 +
      ansichar(playersinlist) +
      outdata;
      client.Send(outdata);
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

end.
