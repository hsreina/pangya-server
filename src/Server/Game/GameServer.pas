{*******************************************************}
{                                                       }
{       Pangya Server                                   }
{                                                       }
{       Copyright (C) 2015 Shad'o Soft tm               }
{                                                       }
{*******************************************************}

unit GameServer;

interface

uses Client, GameServerPlayer, Server, ClientPacket, SysUtils, LobbiesList, CryptLib,
  SyncableServer, PangyaBuffer, PangyaPacketsDef, Lobby, Game;

type

  TGameClient = TClient<TGameServerPlayer>;

  TGameServer = class (TSyncableServer<TGameServerPlayer>)
    protected
    private
      procedure Init; override;
      procedure OnClientConnect(const client: TGameClient); override;
      procedure OnClientDisconnect(const client: TGameClient); override;
      procedure OnReceiveClientData(const client: TGameClient; const clientPacket: TClientPacket); override;
      procedure OnReceiveSyncData(const clientPacket: TClientPacket); override;
      procedure OnDestroyClient(const client: TGameClient); override;
      procedure OnStart; override;

      procedure Sync(const client: TGameClient; const clientPacket: TClientPacket); overload;
      procedure PlayerSync(const clientPacket: TClientPacket; const client: TGameClient);
      procedure ServerPlayerAction(const clientPacket: TClientPacket; const client: TGameClient);

      var m_lobbies: TLobbiesList;

      function LobbiesList: AnsiString;

      procedure HandleLobbyRequests(const lobby: TLobby; const packetId: TCGPID; const client: TGameClient; const clientPacket: TClientPacket);
      procedure HandleGameRequests(const game: TGame; const packetId: TCGPID; const client: TGameClient; const clientPacket: TClientPacket);

      procedure HandlePlayerLogin(const client: TGameClient; const clientPacket: TClientPacket);
      procedure HandleDebugCommands(const client: TGameClient; const clientPacket: TClientPacket; msg: AnsiString);
      procedure HandlerPlayerWhisper(const client: TGameClient; const clientPacket: TClientPacket);
      procedure HandlePlayerSendMessage(const client: TGameClient; const clientPacket: TClientPacket);
      procedure HandlePlayerJoinLobby(const client: TGameClient; const clientPacket: TClientPacket);
      procedure HandlePlayerCreateGame(const client: TGameClient; const clientPacket: TClientPacket);
      procedure HandlePlayerJoinGame(const client: TGameClient; const clientPacket: TClientPacket);
      procedure HandlePlayerLeaveGame(const client: TGameClient; const clientPacket: TClientPacket);
      procedure HandlePlayerBuyItem(const client: TGameClient; const clientPacket: TClientPacket);
      procedure HandlePlayerRequestIdentity(const client: TGameClient; const clientPacket: TClientPacket);
      procedure HandlePlayerRequestServerList(const client: TGameClient; const clientPacket: TClientPacket);
      procedure HandlePlayerUpgrade(const client: TGameClient; const clientPacket: TClientPacket);
      procedure HandlePlayerNotice(const client: TGameClient; const clientPacket: TClientPacket);
      procedure HandlePlayerChangeEquipment(const client: TGameClient; const clientPacket: TClientPacket);
      procedure HandlePlayerAction(const client: TGameClient; const clientPacket: TClientPacket);
      procedure HandlePlayerJoinMultiplayerGamesList(const client: TGameClient; const clientPacket: TClientPacket);
      procedure HandlePlayerLeaveMultiplayerGamesList(const client: TGameClient; const clientPacket: TClientPacket);
      procedure HandlePlayerOpenRareShop(const client: TGameClient; const clientPacket: TClientPacket);
      procedure handlePlayerRequestMessengerList(const client: TGameClient; const clientPacket: TClientPacket);
      procedure HandlePlayerGMCommaand(const client: TGameClient; const clientPacket: TClientPacket);
      procedure HandlePlayerUnknow00EB(const client: TGameClient; const clientPacket: TClientPacket);
      procedure HandlePlayerOpenScratchyCard(const client: TGameClient; const clientPacket: TClientPacket);
      procedure HandlePlayerSetAssistMode(const client: TGameClient; const clientPacket: TClientPacket);
      procedure HandlePlayerUnknow0140(const client: TGameClient; const clientPacket: TClientPacket);
      procedure HandlePlayerEnterScratchyCardSerial(const client: TGameClient; const clientPacket: TClientPacket);
      procedure HandlePlayerRequestAchievements(const client: TGameClient; const clientPacket: TClientPacket);
      procedure HandlePlayerSendInvite(const client: TGameClient; const clientPacket: TClientPacket);
      procedure HandlePlayerGiveUpDailyQuest(const client: TGameClient; const clientPacket: TClientPacket);
      procedure HandlePlayerAcceptDailyQuest(const client: TGameClient; const clientPacket: TClientPacket);
      procedure HandlePlayerRecycleItem(const client: TGameClient; const clientPacket: TClientPacket);
      procedure HandlePlayerRequestDailyQuest(const client: TGameClient; const clientPacket: TClientPacket);
      procedure HandlePlayerRequestInbox(const client: TGameClient; const clientPacket: TClientPacket);
      procedure HandlerPlayerClearQuest(const client: TGameClient; const clientPacket: TClientPacket);
      procedure HandlerPlayerDeleteMail(const client: TGameClient; const clientPacket: TClientPacket);
      procedure handlerPlayerSendMail(const client: TGameClient; const clientPacket: TClientPacket);
      procedure HandlePlayerRequestOfflinePlayerInfo(const client: TGameClient; const clientPacket: TClientPacket);
      procedure HandlePlayerMoveInboxGift(const client: TGameClient; const clientPacket: TClientPacket);
      procedure HandlePlayerRequestInboxDetails(const client: TGameClient; const clientPacket: TClientPacket);
      procedure HandlePlayerRequestCookiesCount(const client: TGameClient; const clientPacket: TClientPacket);
      procedure HandlePlayerRequestDailyReward(const client: TGameClient; const clientPacket: TClientPacket);
      procedure HandlePlayerPlayBongdariShop(const client: TGameClient; const clientPacket: TClientPacket);
      procedure HandlePlayerRequestInfo(const client: TGameClient; const clientPacket: TClientPacket);

      procedure SendToGame(const client: TGameClient; data: AnsiString); overload;
      procedure SendToGame(const client: TGameClient; data: TPangyaBuffer); overload;
      procedure SendToLobby(const client: TGameClient; data: AnsiString); overload;
      procedure SendToLobby(const client: TGameClient; data: TPangyaBuffer); overload;

      function GetPlayerByNickname(nickname: AnsiString): TGameClient;

    public
      constructor Create(cryptLib: TCryptLib);
      destructor Destroy; override;
  end;

implementation

uses Logging, ConsolePas, Buffer, utils, PacketData, defs,
        PlayerCharacter, GameServerExceptions,
  PlayerAction, Vector3, PlayerData, BongdatriShop, PlayerEquipment,
  PlayerQuest;

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
  player: TGameServerPlayer;
begin
  self.Log('TGameServer.OnConnectClient', TLogType_not);
  player := TGameServerPlayer.Create;
  client.Data := player;
  client.Send(
    #$00#$16#$00#$00#$3F#$00#$01#$01 +
    AnsiChar(client.GetKey()) +
    // no clue about that.
    WritePStr(client.Host),
    false
  );
end;

procedure TGameServer.OnClientDisconnect(const client: TGameClient);
var
  lobby: TLobby;
begin
  self.Log('TGameServer.OnDisconnectClient', TLogType_not);
  try
    lobby := m_lobbies.GetLobbyById(client.Data.Lobby);
    lobby.RemovePlayer(client);
  Except
    on E: Exception do
    begin
      Console.Log(E.Message, C_RED);
    end;
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
  self.Sync(#$02 + #$01#$00 + write(client.UID.id, 4) + writePStr(client.UID.login) + clientPacket.ToStr);
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

procedure TGameServer.HandleDebugCommands(const client: TGameClient; const clientPacket: TClientPacket; msg: AnsiString);
var
  game: TGame;
begin

  game := self.m_lobbies.GetPlayerGame(client);

  // Speed ugly way for debug command
  if msg = ':debug' then
  begin
    game.HandlePlayerStartGame(client, clientPacket);
  end
  else if msg = ':next' then
           
  begin
    game.GoToNextHole;
  end;
end;

function TGameServer.GetPlayerByNickname(nickname: AnsiString): TGameClient;
var
  player: TGameClient;
begin
  for player in Clients do
  begin
    if player.Data.Data.playerInfo1.nickname = nickname then
    begin
      Exit(player);
    end;
  end;
  Exit(nil);
end;

procedure TGameServer.HandlerPlayerWhisper(const client: TGameClient; const clientPacket: TClientPacket);
var
  targetNickname: AnsiString;
  msg: AnsiString;
  res: TClientPacket;
  target: TGameClient;
begin
  Console.Log('TGameeServer.HandlePlayerSendMessage', C_BLUE);
  {
    Whisper is supposed to work between servers
    we'll see that later
  }

  if not clientPacket.ReadPStr(targetNickname) then
  begin
    Exit;
  end;

  if not clientPacket.ReadPStr(msg) then
  begin
    Exit;
  end;

  Console.Log(Format('whisper to: %s', [targetNickname]));
  Console.Log(Format('whisper msg: %s', [msg]));

  target := GetPlayerByNickname(targetNickname);

  res := TClientPacket.Create;

  if not (target = nil) then
  begin

    // Must send that to the sender
    res.WriteStr(
      #$84#$00 + #$00
    );
    res.WritePStr(targetNickname);
    res.WritePStr(msg);
    client.Send(res);

    res.Clear;

    // And this to the target
    res.WriteStr(
      #$84#$00 + #$01
    );
    res.WritePStr(client.Data.Data.playerInfo1.nickname);
    res.WritePStr(msg);
    target.Send(res);
  end;

  res.Free;
end;

procedure TGameServer.HandlePlayerSendMessage(const client: TGameClient; const clientPacket: TClientPacket);
var
  userNickname: AnsiString;
  msg: AnsiString;
  reply: TPangyaBuffer;
begin
  Console.Log('TGameeServer.HandlePlayerSendMessage', C_BLUE);
  clientPacket.ReadPStr(userNickname);
  clientPacket.ReadPStr(msg);

  reply := TPangyaBuffer.Create;
  reply.WriteStr(#$40#$00 + #$00);
  reply.WritePStr(userNickname);
  reply.WritePStr(msg);

  if (Length(msg) >= 1) and (msg[1] = ':') then
  begin
    self.HandleDebugCommands(client, clientPacket, msg);
    Exit;
  end;

  SendToGame(client, reply);

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

  try
    lobby := m_lobbies.GetLobbyById(lobbyId);
  except
    on E: Exception do
    begin
      Console.Log(E.Message, C_RED);
      Exit;
    end;
  end;

  lobby.AddPlayer(client);

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
  currentGame: Tgame;
  d: AnsiString;
  res: TClientPacket;
begin
  Console.Log('TGameServer.HandlePlayerCreateGame', C_BLUE);
  clientPacket.Read(gameInfo.un1, SizeOf(TPlayerCreateGameInfo));

  clientPacket.ReadPStr(gameName);
  clientPacket.ReadPStr(gamePassword);
  clientPacket.ReadUInt32(artifact);

  try
    playerLobby := m_lobbies.GetPlayerLobby(client);
  except
    on E: Exception do
    begin
      Console.Log(E.Message, C_RED);
      Exit;
    end;
  end;

  // Lets pprevent game creation for some type of unimplemented games
  if
    not (gameInfo.gameType = TGAME_TYPE.GAME_TYPE_VERSUS_STROKE) AND
    not (gameInfo.gameType = TGAME_TYPE.GAME_TYPE_VERSUS_MATCH) AND
    not (gameInfo.gameType = TGAME_TYPE.GAME_TYPE_CHIP_IN_PRACTICE) AND
    not (gameInfo.gameType = TGAME_TYPE.GAME_TYPE_CHAT_ROOM)
  then
  begin
    res := TClientPacket.Create;
    // Can't create a game here
    res.WriteStr(#$49#$00);
    res.WriteUInt8(WriteGameCreateResult(TCREATE_GAME_RESULT.CREATE_GAME_CANT_CREATE));
    client.Send(res);
    res.Free;
    Exit;
  end;

  //

  try
    game := playerLobby.CreateGame(gamename, gamePassword, gameInfo, artifact);
    currentGame := m_lobbies.GetPlayerGame(client);
    currentGame.RemovePlayer(client);
    game.AddPlayer(client);
  except
    on E: Exception do
    begin
      Console.Log(E.Message, C_RED);
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

  // Lobby player informations
  client.Send(
    #$46#$00#$03#$01 +
    client.Data.LobbyInformations
  );
end;

procedure TGameServer.HandlePlayerJoinGame(const client: TGameClient; const clientPacket: TClientPacket);
var
  gameId: UInt16;
  password: AnsiString;
  game: TGame;
  playerLobby: TLobby;
begin
  Console.Log('TGameServer.HandlePlayerJoinGame', C_BLUE);
  {09 00 01 00 00 00  }
  if not clientPacket.ReadUInt16(gameId) then
  begin
    Console.Log('Failed to get game Id', C_RED);
    Exit;
  end;
  clientPacket.ReadPStr(password);

  try
    playerLobby := m_lobbies.GetPlayerLobby(client);
    game := playerLobby.GetGameById(gameId);
  Except
    on e: Exception do
    begin
      Console.Log('well, i ll move that in another place one day or another', C_RED);
      Exit;
    end;
  end;

  try
    game.AddPlayer(client);
  except
    on e: GameFullException do
    begin
      Console.Log(e.Message + ' should maybe tell to the user that the game is full?', C_RED);
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

  // Lobby player informations
  playerLobby.Send(
    #$46#$00#$03#$01 +
    client.Data.LobbyInformations
  );

end;

procedure TGameServer.HandlePlayerLeaveGame(const client: TGameClient; const clientPacket: TClientPacket);
var
  playergame: TGame;
  playerLobby: TLobby;
begin
  Console.Log('TGameServer.HandlePlayerLeaveGame', C_BLUE);

  try
    playerLobby := m_lobbies.GetPlayerLobby(client);
  except
    on e: Exception do
    begin
      Console.Log(E.Message, C_RED);
      Exit;
    end;
  end;

  try
    playerGame := playerLobby.GetPlayerGame(client);
  except
    on E: Exception do
    begin
      Console.Log(E.Message, C_RED);
      Exit;
    end;
  end;

  playerGame.RemovePlayer(client);
  playerLobby.NullGame.AddPlayer(client);

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

  // Lobby player informations
  {
  playerLobby.Send(
    #$46#$00#$03#$01 +
    client.Data.LobbyInformations
  );
  }

  client.Send(#$4C#$00#$FF#$FF);

end;

procedure TGameServer.HandlePlayerBuyItem(const client: TGameClient; const clientPacket: TClientPacket);
type
  TShopItemDesc = packed record
    un1: UInt32;
    IffId: TIffId;
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
  test: TITEM_TYPE;
begin
  self.Log('TGameServer.HandlePlayerBuyItem', TLogType_not);

  shopResult := '';
  successCount := 0;
  {
    00000000  1D 00 00 01 00 FF FF FF  FF 13 40 14 08 00 00 FF    .....ˇˇˇˇ.@....ˇ
    00000010  FF 01 00 00 00 C4 09 00  00 00 00 00 00 00 00 00    ˇ....ƒ..........
    00000020  00                                                  .
  }
  clientPacket.ReadUInt8(rental);
  clientPacket.ReadUInt16(count);

  randomId := random(134775813);

  for I := 1 to count do
  begin
    clientPacket.Read(shopItem.un1, sizeof(TShopItemDesc));

    case TITEM_TYPE(shopItem.IffId.typ) of
      ITEM_TYPE_CHARACTER:
      begin
        Console.Log('ITEM_TYPE_CHARACTER');
      end;
      ITEM_TYPE_FASHION:
      begin
        Console.Log('ITEM_TYPE_FASHION');
        with client.Data.Items.Add do
        begin
          SetIffId(shopItem.IffId.id);
          setId(Random(99999999));
        end;
      end;
      ITEM_TYPE_CLUB:
      begin
        Console.Log('ITEM_TYPE_CLUB');
        with client.Data.Items.Add do
        begin
          SetIffId(shopItem.IffId.id);
          setId(Random(99999999));
        end;
      end;
      ITEM_TYPE_AZTEC:
      begin
        Console.Log('ITEM_TYPE_AZTEC');
        with client.Data.Items.Add do
        begin
          SetIffId(shopItem.IffId.id);
          setId(Random(99999999));
        end;
      end;
      ITEM_TYPE_ITEM1:
      begin
        Console.Log('ITEM_TYPE_ITEM1');
        with client.Data.Items.Add do
        begin
          SetIffId(shopItem.IffId.id);
          setId(Random(99999999));
        end;
      end;
      ITEM_TYPE_ITEM2:
      begin
        Console.Log('ITEM_TYPE_ITEM2');
        with client.Data.Items.Add do
        begin
          SetIffId(shopItem.IffId.id);
          setId(Random(99999999));
        end;
      end;
      ITEM_TYPE_CADDIE:
      begin
        Console.Log('ITEM_TYPE_CADDIE');
      end;
      ITEM_TYPE_CADDIE_ITEM:
      begin
        Console.Log('ITEM_TYPE_CADDIE_ITEM');
        with client.Data.Caddies.Add do
        begin
          SetIffId(shopItem.IffId.id);
          setId(Random(99999999));
        end;
      end;
      ITEM_TYPE_ITEM_SET:
      begin
        Console.Log('ITEM_TYPE_ITEM_SET');
      end;
      ITEM_TYPE_CADDIE_ITEM2:
      begin
        Console.Log('ITEM_TYPE_CADDIE_ITEM2');
      end;
      ITEM_TYPE_SKIN:
      begin
        Console.Log('ITEM_TYPE_SKIN');
      end;
      ITEM_TYPE_TITLE:
      begin
        Console.Log('ITEM_TYPE_TITLE');
      end;
      ITEM_TYPE_HAIR_COLOR1:
      begin
        Console.Log('ITEM_TYPE_HAIR_COLOR1');
      end;
      ITEM_TYPE_HAIR_COLOR2:
      begin
        Console.Log('ITEM_TYPE_HAIR_COLOR2');
      end;
      ITEM_TYPE_MASCOT:
      begin
        Console.Log('ITEM_TYPE_MASCOT');
      end;
      ITEM_TYPE_FURNITURE:
      begin
        Console.Log('ITEM_TYPE_FURNITURE');
      end;
      ITEM_TYPE_CARD_SET:
      begin
        Console.Log('ITEM_TYPE_CARD_SET');
      end;
      ITEM_TYPE_UNKNOW:
      begin
        Console.Log('ITEM_TYPE_UNKNOW');
      end
      else
      begin
        Console.Log(Format('Unknow item type %x', [shopItem.IffId.typ]));
      end;
    end;

    inc(successCount);
    shopResult := shopResult +
      self.Write(shopItem.IffId, 4) + // IffId
      self.Write(randomId, 4) + // Id
      #$00#$00 + // time
      #$00 +
      #$01#$00#$00#$00 + // qty left
      #$00#$00#$00#$00#$00#$00#$00#$00#$00#$00#$00#$00#$00 +
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

  // Pangs and cookies info
  client.Send(
    #$C8#$00 +
    self.Write(client.Data.data.playerInfo2.pangs, 8) +
    self.Write(client.Data.Cookies, 8)
  );

  // Pangs and cookies info
  client.Send(
    #$68#$00#$00#$00#$00#$00 +
    self.Write(client.Data.data.playerInfo2.pangs, 8) +
    self.Write(client.Data.Cookies, 8)
  );

end;

procedure TGameServer.HandlePlayerRequestIdentity(const client: TGameClient; const clientPacket: TClientPacket);
var
  mode: UInt32;
  playerName: AnsiString;
begin
  Console.Log('TGameServer.HandlePlayerRequestIdentity', C_BLUE);
  clientPacket.ReadUInt32(mode);
  clientPacket.ReadPStr(playerName);

  // TODO: should check if player can really do that
  client.Send(
    #$9A#$00 +
    Write(mode, 4)
  );

end;

procedure TGameServer.HandlePlayerRequestServerList(const client: TGameClient; const clientPacket: TClientPacket);
begin
  Console.Log('TGameServer.HandlePlayerRequestServerList', C_BLUE);
  // Should ask this to the sync server?
  client.Send(
    #$9F#$00 +
    #$00 // Number of servers
  );
end;

procedure TGameServer.HandlePlayerUpgrade(const client: TGameClient; const clientPacket: TClientPacket);
type
  TPacketHeader = packed record
    action: UInt8;
    upType: UInt8;
    itemId: UInt8;
  end;
var
  header: TPacketHeader;
  actionType: UInt8;
begin
  Console.Log('TGameServer.HandlePlayerNotice', C_BLUE);

  if not clientPacket.Read(header, SizeOf(TPacketHeader)) then
  begin
    Console.Log('Failed to read header', C_RED);
    Exit;
  end;

  actionType := 0;

  case header.action of
    0: // character upgrade
    begin  
      actionType := 1;
    end;
    1: // club upgrade
    begin 
      actionType := 1;
    end;
    2: // charcater downgrade
    begin
      actionType := 2;
    end;
    3: // club downgrade
    begin
      actionType := 3;
    end;
    else begin
      Console.Log('Unknow action');
    end;
  end;
  

  // upgrade result
  client.Send(
    #$A5#$00 +
    AnsiChar(actionType) + // upgrade type (upgrade|downgrade)
    AnsiChar(header.action) +
    AnsiChar(header.upType) +
    Write(header.itemId, 4) + // item id
    #$A4#$06#$00#$00#$00#$00#$00#$00
  );

  // Pangs and cookies info
  client.Send(
    #$C8#$00 +
    self.Write(client.Data.data.playerInfo2.pangs, 8) +
    self.Write(client.Data.Cookies, 8)
  );

end;

procedure TGameServer.HandlePlayerNotice(const client: TGameClient; const clientPacket: TClientPacket);
var
  notice: AnsiString;
begin
  Console.Log('TGameServer.HandlePlayerNotice', C_BLUE);
  // TODO: should check if the player can do that
  if clientPacket.ReadPStr(notice) then
  begin
    m_lobbies.Send(
      #$41#$00 +
      WritePStr(notice)
    );
  end;
end;

procedure TGameServer.HandlePlayerChangeEquipment(const client: TGameClient; const clientPacket: TClientPacket);
var
  packetData: TPacketData;
  itemType: UInt8;
  IffId: UInt32;
  characterData: TPlayerCharacterData;
  equipedItem: TPlaterEquipedItems;
begin
  self.Log('TGameServer.HandlePlayerChangeEquipment', TLogType_not);

  clientPacket.ReadUint8(itemType);

  case itemType of
    0: begin
      console.Log('should fix that', C_ORANGE);
      if clientPacket.Read(characterData, SizeOf(TPlayerCharacterData)) then
      begin
        client.Data.Data.equipedCharacter := characterData;
        client.Send(
          #$6B#$00 +
          #$04 + // no clue about it for now
          AnsiChar(itemType) + // the above action?
          characterData.ToPacketData
        );
      end;
    end;
    2: begin
      Console.Log('look like equiped items');
      if clientPacket.Read(equipedItem, SizeOf(TPlaterEquipedItems)) then
      begin
        client.Data.Data.witems.items := equipedItem;
        client.Send(
          #$6B#$00 +
          #$04 + // no clue about it for now
          AnsiChar(itemType) + // the above action?
          equipedItem.ToPacketData
        );
      end;
    end;
    4: begin // Character
      Console.Log('Look like character');
    end
    else;
    begin
      Console.Log(Format('Unknow item type %x', [itemType]), C_RED);
      clientPacket.Log;
    end;
  end;
end;

procedure TGameServer.HandlePlayerAction(const client: TGameClient; const clientPacket: TClientPacket);
var
  action: TPLAYER_ACTION;
  subAction: TPLAYER_ACTION_SUB;
  game: TGame;
  pos: TVector3;
  res: AnsiString;
  animationName: AnsiString;
  gamePlayer: TGameServerPlayer;
  test: TPlayerAction;
begin
  Console.Log('TGameServer.HandlePlayerAction', C_BLUE);

  Console.Log(Format('ConnectionId : %x', [client.Data.Data.playerInfo1.ConnectionId]));

  res := clientPacket.GetRemainingData;

  if not clientPacket.Read(action, 1) then
  begin
    Console.Log('Failed to read player action', C_RED);
    Exit;
  end;

  try
    game := m_lobbies.GetPlayerGame(client);
  except
    on e: Exception do
    begin
      Console.Log(e.Message, C_RED);
      Exit;
    end;
  end;

  gamePlayer := client.Data;

  case action of
    TPLAYER_ACTION.PLAYER_ACTION_APPEAR: begin

      console.log('Player appear');
      if not clientPacket.Read(gamePlayer.Action.pos.x, 12) then begin
        console.log('Failed to read player appear position', C_RED);
        Exit;
      end;

      with client.Data.Action do begin
        console.log(Format('pos : %f, %f, %f', [pos.x, pos.y, pos.z]));
      end;

    end;
    TPLAYER_ACTION.PLAYER_ACTION_SUB: begin

      console.log('player sub action');

      if not clientPacket.Read(subAction, 1) then begin
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

        if not clientPacket.Read(pos.x, 12) then begin
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
      clientPacket.ReadPStr(animationName);
      console.log('Animation : ' + animationName);
    end else begin
      console.log('Unknow action ' + inttohex(byte(action), 2));
      Exit;
    end;
  end;

  SendToGame(client,
    #$C4#$00 +
    Write(client.Data.Data.playerInfo1.ConnectionId, 4) +
    res
  );
end;

procedure TGameServer.HandlePlayerJoinMultiplayerGamesList(const client: TGameClient; const clientPacket: TClientPacket);
var
  playerLobby: TLobby;
begin
  Console.Log('TGameServer.HandlePlayerJoinMultiplayerGamesList', C_BLUE);

  try
    playerLobby := m_lobbies.GetPlayerLobby(client);
  except
    on E: Exception do
    begin
      Console.Log(E.Message, C_RED);
      Exit;
    end;
  end;

  playerLobby.JoinMultiplayerGamesList(client);
end;

procedure TGameServer.HandlePlayerLeaveMultiplayerGamesList(const client: TGameClient; const clientPacket: TClientPacket);
var
  playerLobby: TLobby;
begin
  Console.Log('TGameServer.HandlePlayerLeaveMultiplayerGamesList', C_BLUE);

  try
    playerLobby := m_lobbies.GetPlayerLobby(client);
  except
    on E: Exception do
    begin
      Console.Log(E.Message, C_RED);
      Exit;
    end;
  end;

  playerLobby.LeaveMultiplayerGamesList(client);
end;

procedure TGameServer.HandlePlayerOpenRareShop(const client: TGameClient; const clientPacket: TClientPacket);
begin
  Console.Log('TGameServer.HandlePlayerOpenRareShop', C_BLUE);
  client.Send(#$0B#$01#$FF#$FF#$FF#$FF#$FF#$FF#$FF#$FF#$00#$00#$00#$00);
end;

procedure TGameServer.handlePlayerRequestMessengerList(const client: TGameClient; const clientPacket: TClientPacket);
var
  packet: TClientPacket;
begin
  Console.Log('TGameServer.handlePlayerRequestMessengerList', C_BLUE);

  packet := TClientPacket.Create;
  
  packet.WriteStr(
    #$FC#$00 + 
    #$01 + 
    #$4D#$53#$4E#$5F#$31#$00#$69#$00#$00#$50#$40#$32#$00 +
    #$00#$00#$00#$00#$60#$00#$00#$00#$50#$40#$32#$08#$50#$40#$32#$78 +
    #$01#$E7#$00#$00#$00#$00#$00#$00#$60#$00#$00#$F7#$04#$00#$00#$88 +
    #$13#$00#$00#$F9#$00#$00#$00
  );
  
  packet.WriteStr('127.0.0.1', 15, #$00);

  packet.WriteStr(
    #$00#$03#$04#$00#$D0#$1E#$00#$00#$00#$10#$00 +
    #$00#$00#$00#$00#$00#$00#$00#$00#$00#$00#$00#$00#$00#$00#$00
  );

  client.Send(packet);
  
  packet.free;
end;

procedure TGameServer.HandlePlayerGMCommaand(const client: TGameClient; const clientPacket: TClientPacket);
var
  command: UInt16;
  tmpUInt32: UInt32;
  tmpUInt16: UInt16;
  tmpUInt8: UInt8;
  game: TGame;
begin
  Console.Log('TGameServer.HandlePlayerGMCommaand', C_BLUE);

  try
    game := m_lobbies.GetPlayerGame(client);
  except
    Console.Log('Failed to get player game');
    Exit;
  end;

  if not clientPacket.ReadUInt16(command) then
  begin
    Console.Log(Format('Unknow Command %d', [command]), C_RED);
    Exit;
  end;

  case command of
    3: begin // visible (on|off)

    end;
    4: begin // whisper (on|off)

    end;
    5: begin // channel (on|off)

    end;
    $E: begin // wind (speed - dir)

    end;
    $A: begin // kick
      if (clientPacket.ReadUInt32(tmpUInt32)) then
      begin

      end;
    end;
    $F: begin // weather (fine|rain|snow|cloud)
      console.Log('weather');
      if (clientPacket.ReadUInt8(tmpUInt8)) then
      begin
        game.Send(#$9E#$00 + AnsiChar(tmpUInt8) + #$00#$00);
      end;
    end;
  end;

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

procedure TGameServer.HandlePlayerOpenScratchyCard(const client: TGameClient; const clientPacket: TClientPacket);
begin
  Console.Log('TGameServer.HandlePlayerOpenScratchyCard', C_BLUE);
  client.Send(#$EB#$01#$00#$00#$00#$00#$00);
end;

procedure TGameServer.HandlePlayerSetAssistMode(const client: TGameClient; const clientPacket: TClientPacket);
begin
  Console.log('TGameServer.HandlePlayerSetAssistMode');

  client.Send(
    #$16#$02 +
    #$D9#$C2#$53#$56 + // seem to increase
    #$01#$00#$00#$00 +
    #$02#$16#$00#$E0#$1B#$12 +
    #$49#$76#$06#$00#$00#$00#$00 +
    #$01#$00#$00#$00 +
    #$02#$00#$00#$00 +
    #$01#$00#$00#$00 +
    #$00#$00#$00#$00#$00#$00#$00#$00#$00#$00#$00#$00#$00 +
    #$00#$00#$00#$00#$00#$00#$00#$00#$00#$00#$00#$00
  );

  client.Send(
    #$6A#$02 + #$00#$00#$00#$00
  );
end;

procedure TGameServer.HandlePlayerUnknow0140(const client: TGameClient; const clientPacket: TClientPacket);
begin
  self.Log('TGameServer.HandlePlayerUnknow0140', TLogType_not);
  client.Send(#$0E#$02#$00#$00#$00#$00#$00#$00#$00#$00);
end;

procedure TGameServer.HandlePlayerEnterScratchyCardSerial(const client: TGameClient; const clientPacket: TClientPacket);
const
  validSerialSize = 13;
var
  serial: AnsiString;
  serialSize: Uint32;
begin
  Console.Log('TGameServer.HandlePlayerEnterScratchyCardSerial', C_BLUE);

  clientPacket.Log;

  if not clientPacket.ReadUInt32(serialSize) then
  begin
    Exit;
  end;

  if not (serialSize = validSerialSize) then
  begin
    Exit;
  end;

  setLength(serial, validSerialSize);

  if not clientPacket.Read(serial[1], validSerialSize) then
  begin
    Exit;
  end;

  Console.Log(Format('serial : %s', [serial]));

  // The server seem to alway answer that with any wrong serial
  // Serial seem broken in original Pangya
  client.Send(
    #$DE#$00 + #$16#$26#$26#$00
  );

  // Old server data was
  {
  client.Send(
    #$DE#$00 +
    #$00#$00#$00#$00 +
    #$00#$00#$00#$00 + // return code 0 success, 1 used, 2 invalid, 3 expired etc...
    #$00#$00#$00#$00
  );
  }

end;

procedure TGameServer.HandlePlayerRequestAchievements(const client: TGameClient; const clientPacket: TClientPacket);
begin
  Console.Log('TGameServer.HandlePlayerRequestInfo', C_BLUE);

  {
    supposed to send all achievement data here
    packet $022D (check the logs)
  }

  client.Send(#$2C#$02 + #$00#$00#$00#$00);
end;

procedure TGameServer.HandlePlayerSendInvite(const client: TGameClient; const clientPacket: TClientPacket);
begin
  Console.Log('TGameServer.HandlePlayerSendInvite', C_BLUE);
  ClientPacket.Log;
  Console.Log('Should implement that', C_ORANGE);
end;

procedure TGameServer.HandlePlayerGiveUpDailyQuest(const client: TGameClient; const clientPacket: TClientPacket);
begin
  Console.Log('TGameServer.HandlePlayerGiveUpDailyQuest', C_BLUE);
  {
    00000000  54 01 03 00 00 00 A2 6F  E0 02 A3 6F E0 02 A4 6F    T.....¢o‡.£o‡.§o
    00000010  E0 02                                               ‡.
  }

  client.Send(
    #$16#$02 +
    #$8F#$62#$77#$56 +
    #$03#$00#$00#$00 +

    #$02#$0A#$00#$40#$6C#$16 +
    #$C9#$F1#$03#$00#$00#$00#$00#$00#$00#$00#$00#$00#$00#$00#$00#$00 +
    #$00#$00#$00#$00#$00#$00#$00#$00#$00#$00#$00#$00#$00#$00#$00#$00 +
    #$00#$00#$00#$00#$00#$00#$00#$00#$00#$00#$00#$00 +

    #$02#$04#$00#$40 +
    #$6C#$17#$C9#$F1#$03#$00#$00#$00#$00#$00#$00#$00#$00#$00#$00#$00 +
    #$00#$00#$00#$00#$00#$00#$00#$00#$00#$00#$00#$00#$00#$00#$00#$00 +
    #$00#$00#$00#$00#$00#$00#$00#$00#$00#$00#$00#$00#$00#$00 +

    #$02#$04 +
    #$00#$40#$6C#$18#$C9#$F1#$03#$00#$00#$00#$00#$00#$00#$00#$00#$00 +
    #$00#$00#$00#$00#$00#$00#$00#$00#$00#$00#$00#$00#$00#$00#$00#$00 +
    #$00#$00#$00#$00#$00#$00#$00#$00#$00#$00#$00#$00#$00#$00#$00#$00
  );

  client.Send(
    #$28#$02 + #$00#$00#$00#$00 +
    #$03#$00#$00#$00 +
    #$A2#$6F#$E0#$02 +
    #$A3#$6F#$E0#$02 +
    #$A4#$6F#$E0#$02
  );

end;

procedure TGameServer.HandlePlayerAcceptDailyQuest(const client: TGameClient; const clientPacket: TClientPacket);
begin
  Console.Log('TGameServer.HandlePlayerAcceptDailyQuest', C_BLUE);
  {
    00000000  52 01 03 00 00 00 A2 6F  E0 02 A3 6F E0 02 A4 6F    R.....¢o‡.£o‡.§o
    00000010  E0 02                                               ‡.
  }

  client.Send(
    #$16#$02 + #$8D#$62#$77#$56 +
    #$03#$00#$00#$00 + // count

    #$02#$0A#$00#$40#$6C#$16 +
    #$C9#$F1#$03#$00#$00#$00#$00#$00#$00#$00#$00#$00#$00#$00#$00#$00 +
    #$00#$00#$00#$00#$00#$00#$00#$00#$00#$00#$00#$00#$00#$00#$00#$00 +
    #$00#$00#$00#$00#$00#$00#$00#$00#$00#$00#$00#$00 +

    #$02#$04#$00#$40 +
    #$6C#$17#$C9#$F1#$03#$00#$00#$00#$00#$00#$00#$00#$00#$00#$00#$00 +
    #$00#$00#$00#$00#$00#$00#$00#$00#$00#$00#$00#$00#$00#$00#$00#$00 +
    #$00#$00#$00#$00#$00#$00#$00#$00#$00#$00#$00#$00#$00#$00 +

    #$02#$04 +
    #$00#$40#$6C#$18#$C9#$F1#$03#$00#$00#$00#$00#$00#$00#$00#$00#$00 +
    #$00#$00#$00#$00#$00#$00#$00#$00#$00#$00#$00#$00#$00#$00#$00#$00 +
    #$00#$00#$00#$00#$00#$00#$00#$00#$00#$00#$00#$00#$00#$00#$00#$00
  );

  client.Send(
    #$26#$02 + #$00#$00#$00#$00 +
    #$03#$00#$00#$00 + // count

    #$01#$56#$00#$00#$78#$A2 +
    #$6F#$E0#$02#$03#$00#$00#$00#$01#$00#$00#$00#$22#$01#$80#$74#$0A +
    #$00#$40#$6C#$16#$C9#$F1#$03#$00#$00#$00#$00 +

    #$01#$BB#$00#$00#$78 +
    #$A3#$6F#$E0#$02#$03#$00#$00#$00#$01#$00#$00#$00#$7C#$01#$80#$74 +
    #$04#$00#$40#$6C#$17#$C9#$F1#$03#$00#$00#$00#$00 +

    #$01#$AE#$00#$00 +
    #$78#$A4#$6F#$E0#$02#$03#$00#$00#$00#$01#$00#$00#$00#$6F#$01#$80 +
    #$74#$04#$00#$40#$6C#$18#$C9#$F1#$03#$00#$00#$00#$00
  );

end;

procedure TGameServer.HandlePlayerRecycleItem(const client: TGameClient; const clientPacket: TClientPacket);
type
  TRecycleItemInfo = packed record
    IffId: UInt32;
    Id: UInt32;
    un: UInt32;
  end;
var
  count: UInt32;
  itemInfo: TRecycleItemInfo;
  I: Integer;
begin
  Console.Log('TGameServer.HandlePlayerRecycleItem', C_BLUE);
  {
      offset   0  1  2  3  4  5  6  7   8  9  A  B  C  D  E  F
    00000000  8D 01 01 00 00 00 01 00  00 18 51 10 84 00 01 00    ç.........Q.Ñ...
    00000010  00 00

  offset   0  1  2  3  4  5  6  7   8  9  A  B  C  D  E  F
00000000  8D 01 02 00 00 00 00 00  00 18 DD DC 74 07 01 00    ç.........›‹t...
00000010  00 00 01 00 00 18 BF 22  93 07 01 00 00 00          ......ø"ì.....
                                            ..
  }
  if not clientPacket.ReadUInt32(count) then
  begin
    Exit;
  end;

  for I := 1 to count do
  begin
    clientPacket.Read(itemInfo, SizeOf(TRecycleItemInfo));
    console.Log('recycle info : ');
    console.Log(Format('IffId %x', [itemInfo.IffId]));
    console.Log(Format('Id %x', [itemInfo.Id]));
    console.Log(Format('Un %x', [itemInfo.Un]));
  end;

  // Pangs and cookies info
  client.Send(
    #$C8#$00 +
    self.Write(client.Data.data.playerInfo2.pangs, 8) +
    self.Write(client.Data.Cookies, 8)
  );

  // again this transaction
  client.Send(
    #$16#$02 +
    #$2F#$01#$7A#$56 +
    #$02#$00#$00#$00 +
    #$02#$A7#$02#$00#$1A#$9F +
    #$95#$73#$06#$00#$00#$00#$00#$D0#$02#$00#$00#$DE#$02#$00#$00#$0E +
    #$00#$00#$00#$00#$00#$00#$00#$00#$00#$00#$00#$00#$00#$00#$00#$00 +
    #$00#$00#$00#$00#$00#$00#$00#$00#$00#$00#$00#$00 +
    #$02#$0F#$02#$00 +
    #$1A#$B0#$F7#$AC#$06#$00#$00#$00#$00#$11#$00#$00#$00#$10#$00#$00 +
    #$00#$FF#$FF#$FF#$FF#$00#$00#$00#$00#$00#$00#$00#$00#$00#$00#$00 +
    #$00#$00#$00#$00#$00#$00#$00#$00#$00#$00#$00#$00#$00#$00
  );


  // Receive Mileage bonus
  client.Send(
    #$74#$02 +
    #$00#$00#$00#$00 +
    #$0A#$00#$00#$00 +
    #$04#$00#$00#$00 // count
  );

  // Challenge complete
  // Get extra bonus mileage 1 time
  client.Send(
    #$2E#$02 +
    #$01#$00#$00#$00 +
    #$1B#$00#$80#$4D +
    #$E8#$08#$80#$74
  )

end;

procedure TGameServer.HandlePlayerRequestDailyQuest(const client: TGameClient; const clientPacket: TClientPacket);
begin
  Console.Log('TGameServer.HandlePlayerRequestDailyQuest', C_BLUE);
  client.Send(
    #$16#$02 +
    #$83#$62#$77#$56 +
    #$03#$00#$00#$00 + // count

    #$02#$56#$00#$00#$78#$A2 +
    #$6F#$E0#$02#$00#$00#$00#$00#$00#$00#$00#$00 +
    #$01#$00#$00#$00 +
    #$01#$00#$00#$00 +
    #$00#$00#$00#$00#$00#$00#$00#$00#$00#$00#$00#$00#$00 +
    #$00#$00#$00#$00#$00#$00#$00#$00#$00#$00#$00#$00 +

    #$02#$BB#$00#$00 +
    #$78#$A3#$6F#$E0#$02#$00#$00#$00#$00#$00#$00#$00#$00 +
    #$01#$00#$00#$00 +
    #$01#$00#$00#$00 +
    #$00#$00#$00#$00#$00#$00#$00#$00#$00#$00#$00 +
    #$00#$00#$00#$00#$00#$00#$00#$00#$00#$00#$00#$00#$00#$00 +

    #$02#$AE +
    #$00#$00#$78#$A4#$6F#$E0#$02#$00#$00#$00#$00#$00#$00#$00#$00 +
    #$01#$00#$00#$00 +
    #$01#$00#$00#$00 +
    #$00#$00#$00#$00#$00#$00#$00#$00#$00 +
    #$00#$00#$00#$00#$00#$00#$00#$00#$00#$00#$00#$00#$00#$00#$00#$00
  );

  client.Send(
    #$25#$02#$00#$00#$00#$00#$00#$60#$76#$56#$CD#$22#$2E#$54#$03#$00 +
    #$00#$00#$56#$00#$00#$78#$BB#$00#$00#$78#$AE#$00#$00#$78#$03#$00 +
    #$00#$00#$50#$7B#$D8#$02#$51#$7B#$D8#$02#$52#$7B#$D8#$02
  );
end;

procedure TGameServer.HandlePlayerRequestInbox(const client: TGameClient; const clientPacket: TClientPacket);
var
  res: TClientPacket;
begin
  Console.Log('TGameServer.HandlePlayerRequestInbox', C_BLUE);
  res := TClientPacket.Create;

  res.WriteStr(#$11#$02);
  res.WriteUInt32(0);
  res.WriteUInt32(1); // page number
  res.WriteUInt32(1); // page count
  res.WriteUInt32(1); // entries count

  res.WriteStr(
    #$01#$00#$00#$00 + // Email ID?
    #$40#$53#$47#$49 +
    #$00#$00#$00#$00#$00#$00 +
    #$00#$00#$00#$00#$00#$00#$00#$00#$00#$00#$00#$00#$00#$00#$00#$00 +
    #$00#$00#$00#$00#$00#$00#$00#$00#$00#$00#$00#$00#$00#$00#$00#$00 +
    #$00#$00#$00#$00#$00#$00#$00#$00#$00#$00#$00#$00#$00#$00#$00#$00 +
    #$00#$00#$00#$00#$00#$00#$00#$00#$00#$00#$00#$00#$00#$00#$00#$00 +
    #$00#$00#$00#$00#$00#$00#$00#$00#$00#$00#$00#$00#$00#$00#$00#$00 +
    #$00#$00#$00#$00#$00#$00#$00#$00#$00#$00#$00#$00#$00#$00#$00#$00 +
    #$00#$00#$00#$00#$00#$00#$00#$00#$00#$00#$00#$00#$00#$00#$00#$00 +
    #$00#$00#$00#$00#$00#$00#$01#$00#$00#$00#$00 +
    #$00#$00#$00#$00 + // 1 seem to be an item 0 a letter
    #$FF#$FF#$FF#$FF +
    #$00#$00#$00#$18 + // item Idd Id
    #$00 +
    #$03#$00#$00#$00 + // count
    #$00#$00#$00#$00 +
    #$00#$00#$00#$00#$00#$00#$00#$00#$00#$00#$00#$00#$00#$00#$00#$00 +
    #$FF#$FF#$FF#$FF#$00#$00#$00#$00#$30#$00#$00#$00#$00#$00#$00#$00 +
    #$00#$00#$00#$00#$00#$00
  );

  client.Send(res);
  res.Free;
end;

procedure TGameServer.HandlerPlayerClearQuest(const client: TGameClient; const clientPacket: TClientPacket);
type
  TQuestData = packed record
    pos: word;
    value: cardinal;
  end;
var
  res: TCLientPacket;
  questData: TQuestData;
  playerQuests: TPlayerQuest;
  newQuestStatus: UInt32;
begin
  Console.Log('TGameServer.HandlerPlayerClearQuest', C_BLUE);

  if not clientPacket.Read(questData, SizeOf(TQuestData)) then
  begin
    Exit;
  end;

  playerQuests := client.Data.Quests;

  newQuestStatus := playerQuests.GetQuestData(questData.pos) + questData.value;

  playerQuests.SetQuestData(
    questData.pos,
    newQuestStatus
  );

  res := TClientPacket.Create;

  res.WriteStr(
    #$1F#$01 +
    #$00#$01
  );

  res.WriteUInt32(newQuestStatus);

  client.Send(res);

  res.Free;
end;

procedure TGameServer.HandlerPlayerDeleteMail(const client: TGameClient; const clientPacket: TClientPacket);
var
  mailTo: AnsiString;
  mailBody: AnsiString;
  un1, un2: UInt32;
  res: TClientPacket;
begin
  Console.Log('TGameServer.HandlerPlayerDeleteMail', C_BLUE);
  clientPacket.ReadUInt32(un1);
  clientPacket.ReadUInt32(un2);
  Console.Log(Format('un1: %x, un2: %x', [un1, un2]));

  res := TClientPacket.Create;

  res.WriteStr(#$15#$02);

  // same as requestMail List
  res.WriteUInt32(0);
  res.WriteUInt32(1); // page number
  res.WriteUInt32(1); // page count
  res.WriteUInt32(1); // entries count

  res.WriteStr(
    #$01#$00#$00#$00 + // Email ID?
    #$40#$53#$47#$49 +
    #$00#$00#$00#$00#$00#$00 +
    #$00#$00#$00#$00#$00#$00#$00#$00#$00#$00#$00#$00#$00#$00#$00#$00 +
    #$00#$00#$00#$00#$00#$00#$00#$00#$00#$00#$00#$00#$00#$00#$00#$00 +
    #$00#$00#$00#$00#$00#$00#$00#$00#$00#$00#$00#$00#$00#$00#$00#$00 +
    #$00#$00#$00#$00#$00#$00#$00#$00#$00#$00#$00#$00#$00#$00#$00#$00 +
    #$00#$00#$00#$00#$00#$00#$00#$00#$00#$00#$00#$00#$00#$00#$00#$00 +
    #$00#$00#$00#$00#$00#$00#$00#$00#$00#$00#$00#$00#$00#$00#$00#$00 +
    #$00#$00#$00#$00#$00#$00#$00#$00#$00#$00#$00#$00#$00#$00#$00#$00 +
    #$00#$00#$00#$00#$00#$00#$01#$00#$00#$00#$00 +
    #$00#$00#$00#$00 +
    #$FF#$FF#$FF#$FF +
    #$00#$00#$00#$18 + // item Idd Id
    #$00 +
    #$03#$00#$00#$00 + // count
    #$00#$00#$00#$00 +
    #$00#$00#$00#$00#$00#$00#$00#$00#$00#$00#$00#$00#$00#$00#$00#$00 +
    #$FF#$FF#$FF#$FF#$00#$00#$00#$00#$30#$00#$00#$00#$00#$00#$00#$00 +
    #$00#$00#$00#$00#$00#$00
  );

  client.Send(res);
  res.Free;


end;

procedure TGameServer.handlerPlayerSendMail(const client: TGameClient; const clientPacket: TClientPacket);
var
  mailTo: AnsiString;
  mailBody: AnsiString;
  un1, un2: UInt32;
begin
  Console.Log('TGameServer.handlerPlayerSendMail', C_BLUE);

  clientPacket.ReadUInt32(un1);
  clientPacket.ReadUInt32(un2);
  Console.Log(Format('un1: %x, un2: %x', [un1, un2]));

  if not clientPacket.ReadPStr(mailTo) then
  begin
    Exit;
  end;

  clientPacket.Skip(2);

  if not clientPacket.ReadPStr(mailBody) then
  begin
    Exit;
  end;

  console.Log(Format('mailTo : %s', [mailto]));
  console.Log(Format('mailBody : %s', [mailBody]));

  // Should Send Pang left
  client.Send(
    #$C8#$00 +
    self.Write(client.Data.data.playerInfo2.pangs, 8) +
    self.Write(client.Data.Cookies, 8)
  );

  // Shound send a transaction result
  client.Send(
    #$16#$02 +
    #$61#$03#$3C#$56#$01#$00#$00#$00#$02#$10#$00#$00#$18#$D9 +
    #$C9#$04#$07#$00#$00#$00#$00#$00#$00#$00#$00#$03#$00#$00#$00 +
    #$03#$00#$00#$00 +
    #$00#$00#$00#$00#$00#$00#$00#$00#$00#$00#$00#$00#$00 +
    #$00#$00#$00#$00#$00#$00#$00#$00#$00#$00#$00#$00
  );

  client.Send(
    #$13#$02 +
    #$00#$00#$00#$00 // error id from iff
    // #$49#$40#$2C#$00 // mail failed, the item could not be attached
  );

  // 13 02 49 40 2C 00

end;

procedure TGameServer.HandlePlayerRequestOfflinePlayerInfo(const client: TGameClient; const clientPacket: TClientPacket);
var
  nick: AnsiString;
  res: TClientPacket;
begin
  Console.Log('TGameServer.HandlePlayerRequestOfflinePlayerInfo', C_BLUE);

  clientPacket.Skip(1);

  if not clientPacket.ReadPStr(nick) then
  begin
    Exit;
  end;

  console.Log(Format('search nickname %s', [nick]));

  res := TClientPacket.Create;

  res.WriteStr(#$A1#$00);
  res.WriteUInt8(0); // response type 0 ok 2 not found

  // player unique Id
  res.WriteUInt32(client.Data.Data.playerInfo1.PlayerID);
  // Player info without the gameId
  res.Write(client.Data.Data.playerInfo1.login[0], SizeOf(TPlayerInfo1) - 2);

  client.Send(res);

  res.Free;
end;

procedure TGameServer.HandlePlayerMoveInboxGift(const client: TGameClient; const clientPacket: TClientPacket);
var
  inboxId: UInt32;
  res: TClientPacket;
begin
  Console.Log('TGameServer.HandlePlayerMoveInboxGift', C_BLUE);
  clientPacket.Log;

  if not clientPacket.ReadUInt32(inboxId) then
  begin
    Exit;
  end;

  res := TClientPacket.Create;

  // Send transaction result
  res.WriteStr(
    #$16#$02 +
    #$61#$03#$3C#$56#$01#$00#$00#$00#$02#$10#$00#$00#$18#$D9 +
    #$C9#$04#$07#$00#$00#$00#$00#$00#$00#$00#$00#$03#$00#$00#$00 +
    #$03#$00#$00#$00 +
    #$00#$00#$00#$00#$00#$00#$00#$00#$00#$00#$00#$00#$00 +
    #$00#$00#$00#$00#$00#$00#$00#$00#$00#$00#$00#$00
  );

  client.Send(res);

  client.Send(
    #$14#$02 + #$00#$00#$00#$00
  );

  res.Free;
end;

procedure TGameServer.HandlePlayerRequestInboxDetails(const client: TGameClient; const clientPacket: TClientPacket);
var
  inboxId: UInt32;
  res: TClientPacket;
begin
  Console.Log('TGameServer.HandlePlayerRequestInboxDetails', C_BLUE);
  if not clientPacket.ReadUInt32(inboxId) then
  begin
    Exit;
  end;

  res := TClientPacket.Create;

  res.WriteStr(#$12#$02);
  res.WriteUInt32(0);
  res.WriteUInt32(inboxId);

  res.WritePStr('SERVER'); // Sender
  res.WritePStr('2014-10-03 18:40:009'); // sent date (plz keep this format)

  res.WritePStr('This is the text displayed in the message');

  res.WriteUInt8(1); // ?

  res.WriteUInt32(1); // items count

  // item details
  res.WriteStr(
    #$FF#$FF#$FF#$FF +
    #$33#$00#$00#$1A + // IffId
    #$00 +
    #$19#$00#$00#$00 + // count
    #$00#$00#$00#$00#$00#$00#$00#$00#$00#$00#$00#$00#$00#$00 +
    #$00#$00#$00#$00#$00#$00#$FF#$FF#$FF#$FF#$00#$00#$00#$00#$30#$00 +
    #$00#$00#$00#$00#$00#$00#$00#$00#$00#$00#$00#$00
  );

  client.Send(res);

  res.Free;
end;

procedure TGameServer.HandlePlayerRequestCookiesCount(const client: TGameClient; const clientPacket: TClientPacket);
var
  res: TClientPacket;
begin
  Console.Log('TGameServer.PlayerRequestDailyReward', C_BLUE);
  res := TClientPacket.Create;
  res.WriteStr(WriteAction(SFPID_PLAYER_COOKIES));
  res.WriteInt64(client.Data.Cookies);
  client.Send(res);
  res.Free;
end;

procedure TGameServer.HandlePlayerRequestDailyReward(const client: TGameClient; const clientPacket: TClientPacket);
begin
  Console.Log('TGameServer.PlayerRequestDailyReward', C_BLUE);
  client.Send(
    #$48#$02 +
    #$00#$00#$00#$00#$01#$08#$02#$00#$1A#$01#$00#$00#$00 +
    #$05#$00#$00#$18 + // item id
    #$03#$00#$00#$00 + // item count
    #$1E#$00#$00#$00 // days logged
  );
end;

procedure TGameServer.HandlePlayerPlayBongdariShop(const client: TGameClient; const clientPacket: TClientPacket);
const
  ballCount: UInt32 = 1;
  transactionCount: UInt32 = 1;
var
  res: TClientPacket;
  res2: TClientPacket;
  bongdariResultItem: TBongdariResultItem;
  bongdariTransactionResult: TBongdariTransactionResult;
  I: UInt32;
begin
  Console.Log('TGameServer.HandlePlayerPlayBongdariShop', C_BLUE);

  res := TClientPacket.Create;
  res2 := TClientPacket.Create;

  with bongdariTransactionResult do
  begin
    Un1 := 2;
    un2 := 0;
    un3 := 0;
    un4 := 0;
    un5 := 0;
    un6 := 0;
    un7 := 0;
    un8 := 0;
    un9 := 0;
  end;

  { // Pop a warning message
  client.Send(
    #$FB#$00 +
    #$FF#$FF#$FF#$FF +
    #$FD#$FF#$FF#$FF
  );
  }

  // res2 will be a kind of resume of the transaction
  res2.WriteStr(#$16#$02);
  res2.WriteStr(#$3C#$96#$75#$56);
  res2.WriteUInt32(transactionCount);

  res.WriteStr(#$1B#$02);
  res.WriteStr(#$00#$00#$00#$00#$15#$0E#$5B#$06);

  res.WriteUInt32(ballCount); // ball count

  for I := 1 to ballCount do
  begin
    bongdariResultItem.BallType := 2;
    bongdariResultItem.IffId := $18000008;
    bongdariResultItem.Id := $10101010;
    bongdariResultItem.Quantity := 1;
    bongdariResultItem.Spec := 0;
    res.Write(bongdariResultItem, SizeOf(TBongdariResultItem));


    bongdariTransactionResult.IffId := $18000008;
    bongdariTransactionResult.Id := $10101010;
    bongdariTransactionResult.QtyBefore := 0;
    bongdariTransactionResult.QtyAfter := 1;
    bongdariTransactionResult.Qty := 1;
    res2.Write(bongdariTransactionResult, SizeOf(TBongdariTransactionResult));

  end;

  with client.Data do
  begin
    res.WriteInt64(Data.playerInfo2.pangs);
    res.WriteInt64(Cookies);
  end;

  // Send the transaction details
  client.Send(res2);

  // Send bongdari game result
  client.Send(res);

  res.Free;
  res2.Free;
end;

procedure TGameServer.HandlePlayerRequestInfo(const client: TGameClient; const clientPacket: TClientPacket);
var
  res: TClientPacket;
  playerId: UInt32;
  un1: UInt8;
begin
  Console.Log('TGameServer.HandlePlayerRequestInfo', C_BLUE);

  if not clientPacket.ReadUInt32(playerId) then
  begin
    Exit;
  end;

  if not clientPacket.ReadUInt8(un1) then
  begin
    Exit;
  end;

  // Always send current player for now
  res := TClientPacket.Create;

  // Player infos
  res.WriteStr(#$57#$01);
  res.WriteUInt8(un1);
  res.WriteUInt32(playerId);
  res.Write(client.Data.Data.playerInfo1, SizeOf(TPlayerInfo1));
  res.WriteUInt32(0); // have some more data at the end
  client.Send(res);
  res.Clear;

  // Equiped character
  res.WriteStr(#$5E#$01);
  res.WriteUInt32(playerId);
  res.Write(client.Data.Data.equipedCharacter, SizeOf(TPlayerCharacterData));
  client.Send(res);
  res.Clear;

  // Equiped character
  res.WriteStr(#$56#$01);
  res.WriteUInt8(un1);
  res.WriteUInt32(playerId);
  res.Write(client.Data.Data.witems, SizeOf(TPlayerEquipment));
  client.Send(res);
  res.Clear;

  // Player info 2
  res.WriteStr(#$58#$01);
  res.WriteUInt8(un1);
  res.WriteUInt32(playerId);
  res.Write(client.Data.Data.playerInfo2, SizeOf(TPlayerInfo2));
  client.Send(res);
  res.Clear;

  // Guild informations
  res.WriteStr(#$5D#$01);
  res.WriteUInt32(playerId);
  res.WriteStr(
    #$00#$00#$00#$00#$00#$00#$00#$00#$00#$00 +
    #$00#$00#$00#$00#$00#$00#$00#$00#$00#$00#$00#$00#$00#$00#$00#$00 +
    #$00#$00#$00#$00#$00#$00#$00#$67#$75#$69#$6C#$64#$6D#$61#$72#$6B +
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
    #$00#$00#$00#$00#$00#$00#$00#$00#$00#$00#$00#$00#$00#$00#$00#$00 +
    #$00#$FF#$FF#$FF#$FF#$00#$00#$00#$00#$00#$00#$00#$00#$00#$00#$00 +
    #$00#$00#$00#$00#$00#$00#$00#$00#$00#$00#$00#$87#$E7#$00#$20#$0E +
    #$9E#$09#$50#$9C#$B9#$01#$64#$F6#$9F#$0E#$A8
  );
  client.Send(res);
  res.Clear;

  // Unknow
  res.WriteStr(#$5C#$01 + #$33);
  res.WriteUInt32(playerId);
  res.WriteStr(
    #$00#$00#$00#$00#$00#$00#$00#$00
  );
  client.Send(res);
  res.Clear;

  // Unknow
  res.WriteStr(#$5C#$01 + #$34);
  res.WriteUInt32(playerId);
  res.WriteStr(
    #$00#$00#$00#$00#$00#$00#$00#$00
  );
  client.Send(res);
  res.Clear;

  // Unknow
  res.WriteStr(#$5B#$01);
  res.WriteUInt8(un1);
  res.WriteUInt32(playerId);
  res.WriteStr(
    #$00#$00
  );
  client.Send(res);
  res.Clear;

  // Unknow
  res.WriteStr(#$5A#$01);
  res.WriteUInt8(un1);
  res.WriteUInt32(playerId);
  res.WriteStr(
    #$00#$00
  );
  client.Send(res);
  res.Clear;

  // Unknow
  res.WriteStr(#$59#$01);
  res.WriteUInt8(un1);
  res.WriteUInt32(playerId);
  res.WriteStr(
    #$00#$00#$00#$00#$00#$00#$00#$00#$00 +
    #$00#$00#$00#$00#$00#$00#$00#$00#$00#$00#$00#$00#$00#$00#$00#$00 +
    #$00#$00#$00#$00#$00#$00#$00#$00#$00#$00#$00#$00#$00#$00#$00#$00 +
    #$00#$00#$00#$00#$00#$00#$00#$00#$00#$00#$00#$00#$00#$00#$00#$00 +
    #$00#$00#$00#$00#$00#$00#$00#$00#$00#$00#$00#$00#$00#$00#$00#$00 +
    #$00#$00#$00#$00#$00
  );
  client.Send(res);
  res.Clear;

  // Unknow
  res.WriteStr(#$5C#$01);
  res.WriteUInt8(un1);
  res.WriteUInt32(playerId);
  res.WriteStr(
    #$00#$00#$00#$00#$00#$00#$00#$00
  );
  client.Send(res);
  res.Clear;

  // Unknow
  res.WriteStr(#$57#$02);
  res.WriteUInt8(un1);
  res.WriteUInt32(playerId);
  res.WriteStr(
    #$00#$00
  );
  client.Send(res);
  res.Clear;

  // Unknow
  res.WriteStr(#$89#$00 + #$01#$00#$00#$00);
  res.WriteUInt8(un1);
  res.WriteUInt32(playerId);
  client.Send(res);
  res.Clear;

  res.Free;
end;

procedure TGameServer.HandleLobbyRequests(const lobby: TLobby; const packetId: TCGPID; const client: TGameClient; const clientPacket: TClientPacket);
var
  playerGame: TGame;
begin
  case packetId of
    CGPID_PLAYER_MESSAGE:
    begin
      self.HandlePlayerSendMessage(client, clientPacket);
    end;
    CGPID_PLAYER_WHISPER:
    begin
      self.HandlerPlayerWhisper(client, clientPacket);
    end;
    CGPID_PLAYER_CREATE_GAME:
    begin
      self.HandlePlayerCreateGame(client, clientPacket);
    end;
    CGPID_PLAYER_JOIN_GAME:
    begin
      self.HandlePlayerJoinGame(client, clientPacket);
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
    CGPID_PLAYER_REQUEST_IDENTITY:
    begin
      self.HandlePlayerRequestIdentity(client, clientPacket);
    end;
    CGPID_PLAYER_REQQUEST_SERVERS_LIST:
    begin
      self.HandlePlayerRequestServerList(client, clientPacket);
    end;
    CGPID_PLAYER_UPGRADE:
    begin
      self.HandlePlayerUpgrade(client, clientPacket);
    end;
    CGPID_PLAYER_NOTICE:
    begin
      self.HandlePlayerNotice(client, clientPacket);
    end;
    CGPID_PLAYER_ACTION:
    begin
      self.HandlePlayerAction(client, clientPacket);
    end;
    CGPID_PLAYER_JOIN_MULTIPLAYER_GAME_LIST:
    begin
      self.HandlePlayerJoinMultiplayerGamesList(client, clientPacket);
    end;
    CGPID_PLAYER_LEAVE_MULTIPLAYER_GAME_LIST:
    begin
      self.HandlePlayerLeaveMultiplayerGamesList(client, clientPacket);
    end;
    CGPID_PLAYER_REQUEST_MESSENGER_LIST:
    begin
      self.handlePlayerRequestMessengerList(client, clientPacket);
    end;
    CGPID_PLAYER_GM_COMMAND:
    begin
      self.HandlePlayerGMCommaand(client, clientPacket);
    end;
    CGPID_PLAYER_OPEN_RARE_SHOP:
    begin
      self.HandlePlayerOpenRareShop(client, clientPacket);
    end;
    CGPID_PLAYER_UN_00EB:
    begin
      self.HandlePlayerUnknow00EB(client, clientPacket);
    end;
    CGPID_PLAYER_OPEN_SCRATCHY_CARD:
    begin
      self.HandlePlayerOpenScratchyCard(client, clientPacket);
    end;
    CGPID_PLAYER_UN_0140:
    begin
      self.HandlePlayerUnknow0140(client, clientPacket);
    end;
    CGPID_PLAYER_REQUEST_INFO:
    begin
      self.HandlePlayerRequestInfo(client, clientPacket);
    end;
    CGPID_PLAYER_PLAY_BONGDARI_SHOP:
    begin
      self.HandlePlayerPlayBongdariShop(client, clientPacket);
    end;
    CGPID_PLAYER_REQUEST_ACHIEVEMENTS:
    begin
      self.HandlePlayerRequestAchievements(client, clientPacket);
    end;
    CGPID_PLAYER_ENTER_SCRATCHY_SERIAL:
    begin
      self.HandlePlayerEnterScratchyCardSerial(client, clientPacket);
    end;
    CGPID_PLAYER_REQUEST_DAILY_QUEST:
    begin
      self.HandlePlayerRequestDailyQuest(client, clientPacket);
    end;
    CGPID_PLAYER_RECYCLE_ITEM:
    begin
      self.HandlePlayerRecycleItem(client, clientPacket);
    end;
    CGPID_PLAYER_ACCEPT_DAILY_QUEST:
    begin
      self.HandlePlayerAcceptDailyQuest(client, clientPacket);
    end;
    CGPID_PLAYER_GIVEUP_DAILY_QUEST:
    begin
      self.HandlePlayerGiveUpDailyQuest(client, clientPacket);
    end;
    CGPID_PLAYER_SEND_INVITE:
    begin
      self.HandlePlayerSendInvite(client, clientPacket);
    end;
    CGPID_PLAYER_REQUEST_DAILY_REWARD:
    begin
      self.HandlePlayerRequestDailyReward(client, clientPacket);
    end;
    CGPID_PLAYER_REQUEST_COOKIES_COUNT:
    begin
      self.HandlePlayerRequestCookiesCount(client, clientPacket);
    end;
    CGPID_PLAYER_REQUEST_INBOX:
    begin
      self.HandlePlayerRequestInbox(client, clientPacket);
    end;
    CGPID_PLAYER_REQUEST_INBOX_DETAILS:
    begin
      self.HandlePlayerRequestInboxDetails(client, clientPacket);
    end;
    CGPID_PLAYER_MOVE_INBOX_GIFT:
    begin
      self.HandlePlayerMoveInboxGift(client, clientPacket);
    end;
    CGPID_PLAYER_REQUEST_OFFLINE_PLAYER_INFO:
    begin
      self.HandlePlayerRequestOfflinePlayerInfo(client, clientPacket);
    end;
    CGPID_PLAYER_SEND_MAIL:
    begin
      self.handlerPlayerSendMail(client, clientPacket);
    end;
    CGPID_PLAYER_DELETE_MAIL:
    begin
      self.HandlerPlayerDeleteMail(client, clientPacket);
    end;
    CGPID_PLAYER_CLEAR_QUEST:
    begin
      self.HandlerPlayerClearQuest(client, clientpacket);
    end
    else begin
      try
        playerGame := lobby.GetPlayerGame(client);
        self.HandleGameRequests(playerGame, packetId, client, clientPacket);
      except
        on e: Exception do
        begin
          Console.Log(e.Message, C_RED);
          Exit;
        end;
      end;
    end;
  end;
end;

procedure TGameServer.HandleGameRequests(const game: TGame; const packetId: TCGPID; const client: TGameClient; const clientPacket: TClientPacket);
begin
  case packetId of
    CGPID_PLAYER_CHANGE_GAME_SETTINGS:
    begin
      game.HandlePlayerChangeGameSettings(client, clientPacket);
    end;
    CGPID_PLAYER_SET_ASSIST_MODE:
    begin
      self.HandlePlayerSetAssistMode(client, clientPacket);
    end;
    CGPID_PLAYER_READY:
    begin
      game.HandlePlayerReady(client, clientPacket);
    end;
    CGPID_PLAYER_START_GAME:
    begin
      game.HandlePlayerStartGame(client, clientPacket);
    end;
    CGPID_PLAYER_LOADING_INFO:
    begin
      game.HandlePlayerLoadingInfo(client, clientPacket);
    end;
    CGPID_PLAYER_LOAD_OK:
    begin
      game.HandlePlayerLoadOk(client, clientPacket);
    end;
    CGPID_PLAYER_HOLE_INFORMATIONS:
    begin
      game.HandlePlayerHoleInformations(client, clientPacket);
    end;
    CGPID_PLAYER_1ST_SHOT_READY:
    begin
      game.HandlePlayer1stShotReady(client, clientPacket);
    end;
    CGPID_PLAYER_ACTION_SHOT:
    begin
      game.HandlePlayerActionShot(client, clientPacket);
    end;
    CGPID_PLAYER_ACTION_ROTATE:
    begin
      game.HandlePlayerActionRotate(client, clientPacket);
    end;
    CGPID_PLAYER_ACTION_HIT:
    begin
      game.HandlePlayerActionHit(client, clientPacket);
    end;
    CGPID_PLAYER_ACTION_CHANGE_CLUB:
    begin
      game.HandlePlayerActionChangeClub(client, clientPacket);
    end;
    CGPID_PLAYER_USE_ITEM:
    begin
      game.HandlePlayerUseItem(client, clientPacket);
    end;
    CGPID_PLAYER_SHOTDATA:
    begin
      game.HandlePlayerShotData(client, clientPacket);
    end;
    CGPID_PLAYER_SHOT_SYNC:
    begin
      game.HandlePlayerShotSync(client, clientPacket);
    end;
    CGPID_PLAYER_HOLE_COMPLETE:
    begin
      game.HandlerPlayerHoleComplete(client, clientPacket);
    end;
    CGPID_PLAYER_FAST_FORWARD:
    begin
      game.HandlePlayerFastForward(client, clientPacket);
    end;
    CGPID_PLAYER_POWER_SHOT:
    begin
      game.HandlePlayerPowerShot(client, clientPacket);
    end;
    CGPID_PLAYER_CHANGE_EQUPMENT:
    begin
      game.HandlePlayerChangeEquipment(client, clientPacket);
    end
    else begin
      self.Log(Format('Unknow packet Id %x', [Word(packetID)]), TLogType_err);
    end;
  end;
end;

procedure TGameServer.OnReceiveClientData(const client: TGameClient; const clientPacket: TClientPacket);
var
  player: TGameServerPlayer;
  packetId: TCGPID;
  playerLobby: TLobby;
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
      CGPID_PLAYER_JOIN_LOBBY:
      begin
        self.HandlePlayerJoinLobby(client, clientPacket);
      end;
      else
      begin
        try
          playerLobby := m_lobbies.GetPlayerLobby(client);
          self.HandleLobbyRequests(playerLobby, packetId, client, clientPacket);
        except
          on e: Exception do
          begin
            Console.Log(e.Message, C_RED);
            Exit;
          end;
        end;
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
  d: AnsiString;
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
          WriteHeader(SGPID_PLAYER_MAIN_DATA) +
          #$00 +
          WritePStr('824.00') +
          WritePStr(ExtractFilename(ParamStr(0))) +
          client.Data.Data.ToPacketData
        );
      end;
      SSAPID_PLAYER_CHARACTERS:
      begin
        Console.Log('Characters');
        client.Data.Characters.Load(clientPacket.GetRemainingData);
        client.Send(
          WriteHeader(SGPID_PLAYER_CHARACTERS_DATA) +
          client.Data.Characters.ToPacketData
        );
      end;
      SSAPID_PLAYER_ITEMS:
      begin
        Console.Log('Items');
        client.Data.Items.Load(clientPacket.GetRemainingData);
        Console.WriteDump(client.Data.items.ToPacketData);
        client.Send(
          WriteHeader(SGPID_PLAYER_ITEMS_DATA) +
          client.Data.items.ToPacketData
        );
      end;
      SSAPID_PLAYER_CADDIES:
      begin
        Console.Log('Caddies');
        client.Data.Caddies.Load(clientPacket.GetRemainingData);
        Console.WriteDump(client.Data.Caddies.ToPacketData);
        client.Send(
          WriteHeader(SGPID_PLAYER_CADDIES_DATA) +
          client.Data.Caddies.ToPacketData
        );

        // mascot list
        client.Send(#$E1#$00#$00);
      end;
      SSAPID_PLAYER_COOKIES:
      begin
        clientPacket.ReadInt64(client.Data.Cookies);
        client.Send(#$96#$00 + Write(client.Data.Cookies, 8));
      end;
      else
      begin
        self.Log(Format('Unknow action Id %x', [Word(actionId)]), TLogType_err);
      end;
    end;
  end;

end;

procedure TGameServer.OnDestroyClient(const client: TGameClient);
begin
  client.Data.Free;
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

procedure TGameServer.SendToGame(const client: TGameClient; data: AnsiString);
var
  game: TGame;
begin
  try
    game := m_lobbies.GetPlayerGame(client);
  except
    on e: Exception do
    begin
      Console.Log(e.Message, C_RED);
      Exit;
    end;
  end;
  game.Send(data);
end;

procedure TGameServer.SendToGame(const client: TGameClient; data: TPangyaBuffer);
var
  game: TGame;
begin
  try
    game := m_lobbies.GetPlayerGame(client);
  except
    on e: Exception do
    begin
      Console.Log(e.Message, C_RED);
      Exit;
    end;
  end;
  game.Send(data);
end;

procedure TGameServer.SendToLobby(const client: TGameClient; data: AnsiString);
var
  lobby: TLobby;
begin
  try
    lobby := m_lobbies.GetPlayerLobby(client);
  except
    on e: Exception do
    begin
      Console.Log(e.Message, C_RED);
      Exit;
    end;
  end;
  lobby.Send(data);
end;

procedure TGameServer.SendToLobby(const client: TGameClient; data: TPangyaBuffer);
var
  lobby: TLobby;
begin
  try
    lobby := m_lobbies.GetPlayerLobby(client);
  except
    on e: Exception do
    begin
      Console.Log(e.Message, C_RED);
      Exit;
    end;
  end;
  lobby.Send(data);
end;

end.
