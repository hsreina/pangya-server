unit GameServer;

interface

uses Client, GamePlayer, Server, ClientPacket, SysUtils, LobbiesList, CryptLib, SyncableServer;

type

  TGameClient = TClient<TGamePlayer>;

  TGameServer = class (TSyncableServer<TGamePlayer>)
    protected
    private
      procedure Init; override;
      procedure OnClientConnect(const client: TGameClient); override;
      procedure OnClientDisconnect(const client: TGameClient); override;
      procedure OnReceiveClientData(const client: TGameClient; const clientPacket: TClientPacket); override;
      procedure OnReceiveSyncData(const clientPacket: TClientPacket); override;
      procedure OnStart; override;

      procedure Sync(const client: TGameClient; const clientPacket: TClientPacket); overload;
      procedure PlayerSync(const clientPacket: TClientPacket; const client: TGameClient);
      procedure ServerPlayerAction(const clientPacket: TClientPacket; const client: TGameClient);

      var m_lobbies: TLobbiesList;

      function LobbiesList: AnsiString;

      procedure HandlePlayerLogin(const client: TGameClient; const clientPacket: TClientPacket);
      procedure HandlePlayerSendMessage(const client: TGameClient; const clientPacket: TClientPacket);
      procedure HandlePlayerJoinLobby(const client: TGameClient; const clientPacket: TClientPacket);
      procedure HandlePlayerCreateGame(const client: TGameClient; const clientPacket: TClientPacket);
      procedure HandlePlayerLeaveGame(const client: TGameClient; const clientPacket: TClientPacket);
      procedure HandlePlayerBuyItem(const client: TGameClient; const clientPacket: TClientPacket);
      procedure HandlePlayerChangeEquipment(const client: TGameClient; const clientPacket: TClientPacket);
      procedure HandlePlayerJoinMultiplayerGamesList(const client: TGameClient; const clientPacket: TClientPacket);
      procedure HandlePlayerLeaveMultiplayerGamesList(const client: TGameClient; const clientPacket: TClientPacket);
      procedure HandlePlayerUnknow00EB(const client: TGameClient; const clientPacket: TClientPacket);
      procedure HandlePlayerUnknow0140(const client: TGameClient; const clientPacket: TClientPacket);

    public
      constructor Create(cryptLib: TCryptLib);
      destructor Destroy; override;
  end;

implementation

uses Logging, PangyaPacketsDef, ConsolePas, Buffer, utils, PacketData, defs,
  PangyaBuffer, Lobby, PlayerCharacter, Game, GameServerExceptions;

constructor TGameServer.Create(cryptLib: TCryptLib);
begin
  inherited;
  Console.Log('TGameServer.Create');
  m_lobbies:= TLobbiesList.Create;
end;

destructor TGameServer.Destroy;
begin
  inherited;
  m_lobbies.Free;
end;

function TGameServer.LobbiesList: AnsiString;
begin
  Result := m_lobbies.Build;
end;

procedure TGameServer.Init;
begin
  self.SetPort(7997);
  self.SetSyncPort(7998);
  self.setSyncHost('127.0.0.1');
end;

procedure TGameServer.OnClientConnect(const client: TGameClient);
var
  player: TGamePlayer;
begin
  self.Log('TGameServer.OnConnectClient', TLogType_not);
  player := TGamePlayer.Create;
  client.Data := player;

  client.Send(
    #$00#$16#$00#$00#$3F#$00#$01#$01 +
    AnsiChar(client.GetKey()) +
    // no clue about that.
    WriteStr(client.Host),
    false
  );
end;

procedure TGameServer.OnClientDisconnect(const client: TGameClient);
var
  player: TGamePlayer;
  lobby: TLobby;
begin
  self.Log('TGameServer.OnDisconnectClient', TLogType_not);
  player := client.Data;
  if not (player = nil) then
  begin

    // Remove the player from the lobby
    if not player.Lobby = $FF then
    begin
      lobby := m_lobbies.GetLobbyById(player.Lobby);
      lobby.RemovePlayer(player);
    end;

    player.Free;
    player := nil;
  end;
end;

procedure TGameServer.OnStart;
begin
  self.Log('TGameServer.OnStart', TLogType_not);
  self.StartSyncClient;
end;

procedure TGameServer.Sync(const client: TGameClient; const clientPacket: TClientPacket);
begin
  self.Log('TGameServer.Sync', TLogType.TLogType_not);
  self.Sync(#$02 + #$01#$00 + write(client.UID.id, 4) + writeStr(client.UID.login) + clientPacket.ToStr);
end;

procedure TGameServer.HandlePlayerLogin(const client: TGameClient; const clientPacket: TClientPacket);
var
  login: AnsiString;
begin
  self.Log('TGameServer.HandlePlayerLogin', TLogType_not);
  clientPacket.ReadPStr(login);
  client.UID.login := login;
  client.UID.id := 0;
  self.Sync(client, clientPacket);
end;

procedure TGameServer.HandlePlayerSendMessage(const client: TGameClient; const clientPacket: TClientPacket);
var
  login: AnsiString;
  msg: AnsiString;
  reply: TPangyaBuffer;
begin
  Console.Log('TGameeServer.HandlePlayerSendMessage', C_BLUE);
  clientPacket.ReadPStr(login);
  clientPacket.ReadPStr(msg);

  reply := TPangyaBuffer.Create;
  reply.WriteStr(#$40#$00 + #$00);
  reply.WritePStr(login);
  reply.WritePStr(msg);
  client.Send(reply);

  reply.Free;
end;

procedure TGameServer.HandlePlayerJoinLobby(const client: TGameClient; const clientPacket: TClientPacket);
var
  lobbyId: UInt8;
  lobby: TLobby;
begin
  self.Log('TGameServer.HandlePlayerJoinLobby', TLogType_not);

  if false = clientPacket.ReadUInt8(lobbyId) then
  begin
    Console.Log('Failed to read lobby id', C_RED);
    Exit;
  end;

  lobby := m_lobbies.GetLobbyById(lobbyId);

  if nil = lobby then
  begin
    Console.Log('lobby doesn''t exists', C_RED);
    Exit;
  end;

  lobby.AddPlayer(client.Data);

  client.Send(#$95#$00 + AnsiChar(lobbyId) + #$01#$00);
  client.Send(#$4E#$00 + #$01);
end;

procedure TGameServer.HandlePlayerCreateGame(const client: TGameClient; const clientPacket: TClientPacket);
var
  gameInfo: TPlayerCreateGameInfo;
  gameName: AnsiString;
  gamePassword: AnsiString;
  artifact: UInt32;
  playerLobby: TLobby;
  game: TGame;
begin
  Console.Log('TGameServer.HandlePlayerBuyItem', C_BLUE);
  clientPacket.Read(gameInfo.un1, SizeOf(TPlayerCreateGameInfo));
  clientPacket.ReadPStr(gameName);
  clientPacket.ReadPStr(gamePassword);
  clientPacket.ReadUInt32(artifact);

  playerLobby := m_lobbies.GetPlayerLobby(client.Data);

  if playerLobby = nil then
  begin
    Console.Log('lobby not found for player', C_RED);
    Exit;
  end;

  try
    game := playerLobby.Games.CreateGame(gamename, gamePassword, gameInfo, artifact);
  except
    on E: LobbyGamesFullException do begin
      Console.Log(E.Message, C_RED);
      Exit;
    end;
  end;

  try
    game.AddPlayer(client.Data);
  except
    on E: GameFullException do begin
      Console.Log(E.Message, C_RED);
      Exit;
    end;
  end;

  // result
  client.Send(
    #$4A#$00 +
    #$FF#$FF +
    #$02 + // game type 02: CHat room
    AnsiChar(gameInfo.map) +
    AnsiChar(gameInfo.holeCount) +
    AnsiChar(gameInfo.mode) +
    #$00#$00#$00#$00 +
    AnsiChar(gameInfo.maxPlayers) +
    #$1E#$00 +
    self.Write(gameInfo.turnTime, 4) +
    self.Write(gameInfo.gameTime, 4) +
    #$00#$00#$00#$00#$00 +
    self.WriteStr(gameName)
  );

  // game game informations
  client.Send(
    #$49#$00 +
    #$00#$00 +
    game.GameInformation
  );

  client.Send(
      #$48#$00#$00#$FF#$FF#$01 +
      client.Data.GameInformation
  );

  // Game lobby info
  client.Send(
    #$47#$00#$01#$01#$FF#$FF +
    game.LobbyInformation
  );

  // Lobby player informations
  client.Send(
    #$46#$00#$03#$01 +
    client.Data.LobbyInformations
  );

end;

procedure TgameServer.HandlePlayerLeaveGame(const client: TGameClient; const clientPacket: TClientPacket);
var
  playerLobby: TLobby;
  playergame: TGame;
begin
  Console.Log('TGameServer.HandlePlayerLeaveGame', C_BLUE);
  playerLobby := m_lobbies.GetPlayerLobby(client.Data);

  if playerLobby = nil then
  begin
    Console.Log('lobby not found for player', C_RED);
    Exit;
  end;

  playerGame := playerLobby.Games.getPlayerGame(client.Data);

  if playerGame = nil then
  begin
    Console.Log('player game not found', C_RED);
    Exit;
  end;

  playerGame.RemovePlayer(client.Data);

end;

procedure TGameServer.HandlePlayerBuyItem(const client: TGameClient; const clientPacket: TClientPacket);
type
  TShopItemDesc = packed record
    un1: UInt32;
    IffId: UInt32;
    lifeTime: word;
    un2: array [0..1] of ansichar;
    qty: UInt32;
    un3: UInt32;
    un4: UInt32;
  end;
var
  rental: Byte;
  count: UInt16;
  I: integer;
  shopItem: TShopItemDesc;

  shopResult: TPacketData;
  successCount: uint16;
  randomId: Integer;
begin
  self.Log('TGameServer.HandlePlayerBuyItem', TLogType_not);

  shopResult := '';
  successCount := 0;
  {
    00000000  1D 00 00 01 00 FF FF FF  FF 13 40 14 08 00 00 FF    .....ÿÿÿÿ.@....ÿ
    00000010  FF 01 00 00 00 C4 09 00  00 00 00 00 00 00 00 00    ÿ....Ä..........
    00000020  00                                                  .
  }
  clientPacket.ReadUInt8(rental);
  clientPacket.ReadUInt16(count);

  randomId := random(134775813);

  for I := 1 to count do
  begin
    clientPacket.Read(shopItem.un1, sizeof(TShopItemDesc));

    inc(successCount);
    shopResult := shopResult +
      self.Write(shopItem.IffId, 4) + // IffId
      self.Write(randomId, 4) + // Id
      #$00#$00#$00#$01 +
      #$00#$00#$00#$00#$00#$00#$00#$00#$00#$00#$00#$00#$00#$00#$00#$00 +
      #$00#$00#$00#$00#$00#$00#$00#$00#$00#$00;
  end;

  // shop result
  client.Send(
    #$AA#$00 +
    self.Write(successCount, 2) +
    shopResult +
    self.Write(client.Data.data.playerInfo2.pangs, 8) +
    #$00#$00#$00#$00#$00#$00#$00#$00
  );

  client.Send(
    #$C8#$00 +
    self.Write(client.Data.data.playerInfo2.pangs, 8) +
    #$C4#$09#$00#$00#$00#$00#$00#$00
  );

  // Pangs and cookies info
  client.Send(
    #$68#$00#$00#$00#$00#$00 +
    self.Write(client.Data.data.playerInfo2.pangs, 8) +
    self.Write(client.Data.Cookies, 8)
  );

end;

procedure TGameServer.HandlePlayerChangeEquipment(const client: TGameClient; const clientPacket: TClientPacket);
var
  packetData: TPacketData;
  itemType: UInt8;
  IffId: UInt32;
begin
  self.Log('TGameServer.HandlePlayerChangeEquipment', TLogType_not);

  clientPacket.ReadUint8(itemType);

  case itemType of
    0: begin
      console.Log('character data', C_ORANGE);
      clientPacket.ReadUInt32(IffId);
      WriteDataToFile(Format('c_%x.dat', [IffId]), clientPacket.ToStr);
    end;
    1: begin
      Console.Log('Should implement that', C_ORANGE);
      clientPacket.Log;
    end;
    else
    begin
      Console.Log(Format('Unknow item type %x', [itemType]), C_RED);
      clientPacket.Log;
    end;
  end;
end;

procedure TGameServer.HandlePlayerJoinMultiplayerGamesList(const client: TGameClient; const clientPacket: TClientPacket);
begin
  Console.Log('TGameServer.HandlePlayerJoinMultiplayerGamesList', C_BLUE);
  client.Send(#$F5#$00);
end;

procedure TGameServer.HandlePlayerLeaveMultiplayerGamesList(const client: TGameClient; const clientPacket: TClientPacket);
begin
  Console.Log('TGameServer.HandlePlayerLeaveMultiplayerGamesList', C_BLUE);
  client.Send(#$F6#$00);
end;

procedure TGameServer.HandlePlayerUnknow00EB(const client: TGameClient; const clientPacket: TClientPacket);
begin
  Console.Log('TGameServer.HandlePlayerUnknow0140', C_BLUE);
  // Should send that to all players
  client.Send(
    #$96#$01 +
    #$4E#$01#$00#$00 + #$00#$00#$80#$3F + #$00#$00#$80#$3F +
    #$00#$00#$80#$3F + #$00#$00#$80#$3F + #$00#$00#$80#$3F
  );
end;

procedure TGameServer.HandlePlayerUnknow0140(const client: TGameClient; const clientPacket: TClientPacket);
begin
  self.Log('TGameServer.HandlePlayerUnknow0140', TLogType_not);
  client.Send(#$0E#$02#$00#$00#$00#$00#$00#$00#$00#$00);
end;

procedure TGameServer.OnReceiveClientData(const client: TGameClient; const clientPacket: TClientPacket);
var
  player: TGamePlayer;
  packetId: TCGPID;
begin
  self.Log('TGameServer.OnReceiveClientData', TLogType_not);
  clientPacket.Log;

  player := client.Data;
  if (clientPacket.Read(packetID, 2)) then
  begin
    case packetID of
      CGPID_PLAYER_LOGIN:
      begin
        self.HandlePlayerLogin(client, clientPacket);
      end;
      CGPID_PLAYER_MESSAGE:
      begin
        self.HandlePlayerSendMessage(client, clientPacket);
      end;
      CGPID_PLAYER_JOIN_LOBBY:
      begin
        self.HandlePlayerJoinLobby(client, clientPacket);
      end;
      CGPID_PLAYER_CREATE_GAME:
      begin
        self.HandlePlayerCreateGame(client, clientPacket);
      end;
      CGPID_PLAYER_LEAVE_GAME:
      begin
        self.HandlePlayerLeaveGame(client, clientPacket);
      end;
      CGPID_PLAYER_BUY_ITEM:
      begin
        self.HandlePlayerBuyItem(client, clientPacket);
      end;
      CGPID_PLAYER_CHANGE_EQUIP:
      begin
        self.HandlePlayerChangeEquipment(client, clientPacket);
      end;
      CGPID_PLAYER_JOIN_MULTIPLAYER_GAME_LIST:
      begin
        self.HandlePlayerJoinMultiplayerGamesList(client, clientPacket);
      end;
      CGPID_PLAYER_LEAV_MULTIPLAYER_GAME_LIST:
      begin
        self.HandlePlayerLeaveMultiplayerGamesList(client, clientPacket);
      end;
      CGPID_PLAYER_UN_00EB:
      begin
        self.HandlePlayerUnknow00EB(client, clientPacket);
      end;
      CGPID_PLAYER_UN_0140:
      begin
        self.HandlePlayerUnknow0140(client, clientPacket);
      end
      else
      begin
        self.Log(Format('Unknow packet Id %x', [Word(packetID)]), TLogType_err);
      end;
    end;
  end;
end;

// TODO: move that to parent class
procedure TGameServer.PlayerSync(const clientPacket: TClientPacket; const client: TGameClient);
var
  actionId: TSGPID;
begin
  self.Log('TGameServer.PlayerSync', TLogType_not);
  client.Send(clientPacket.GetRemainingData);
end;

procedure TGameServer.ServerPlayerAction(const clientPacket: TClientPacket; const client: TGameClient);
var
  actionId: TSSAPID;
  buffer: AnsiString;
begin
  self.Log('TGameServer.PlayerSync', TLogType_not);
  if clientPacket.Read(actionId, 2) then
  begin
    case actionId of
      SSAPID_SEND_LOBBIES_LIST:
      begin
        client.Send(LobbiesList);
      end;
      SSAPID_PLAYER_MAIN_SAVE:
      begin
        buffer := clientPacket.GetRemainingData;
        client.Data.Data.Load(buffer);
        client.Data.Data.playerInfo1.ConnectionId := client.ID;
        client.Send(
          #$44#$00 + #$00 +
          WriteStr('824.00') +
          WriteStr(ExtractFilename(ParamStr(0))) +
          buffer
        );
      end;
      SSAPID_PLAYER_CHARACTERS:
      begin
        Console.Log('Characters');
        client.Data.Characters.Load(clientPacket.GetRemainingData);
        Console.WriteDump(client.Data.Characters.ToPacketData);
        client.Send(
          #$70#$00 +
          client.Data.Characters.ToPacketData
        );
      end
      else
      begin
        self.Log(Format('Unknow action Id %x', [Word(actionId)]), TLogType_err);
      end;
    end;
  end;

end;

procedure TGameServer.OnReceiveSyncData(const clientPacket: TClientPacket);
var
  packetId: TSSPID;
  playerUID: TPlayerUID;
  client: TGameClient;
begin
  self.Log('TLoginServer.OnReceiveSyncData', TLogType_not);
  if (clientPacket.Read(packetID, 2)) then
  begin

    clientPacket.ReadUInt32(playerUID.id);
    clientPacket.ReadPStr(playerUID.login);

    client := self.GetClientByUID(playerUID);
    if client = nil then
    begin
      Console.Log('something went wrong client not found', C_RED);
      Exit;
    end;

    if client.UID.id = 0 then
    begin
      client.UID.id := playerUID.id;
    end;
    console.Log(Format('player UID : %s/%d', [playerUID.login, playerUID.id]));

    case packetId of
      SSPID_PLAYER_SYNC:
      begin
        self.PlayerSync(clientPacket, client);
      end;
      SSPID_PLAYER_ACTION:
      begin
        self.ServerPlayerAction(clientPacket, client);
      end;
      else
      begin
        self.Log(Format('Unknow packet Id %x', [Word(packetID)]), TLogType_err);
      end;
    end;
  end;
end;

end.
