{*******************************************************}
{                                                       }
{       Pangya Server                                   }
{                                                       }
{       Copyright (C) 2015 Shad'o Soft tm               }
{                                                       }
{*******************************************************}

unit GameServer;

interface

uses Client, GameServerPlayer, Server, SysUtils, LobbiesList, CryptLib,
  SyncableServer, PacketsDef, Lobby, Game, IniFiles,
  IffManager, ServerOptions, Packet, PacketReader, PacketWriter;

type

  TGameClient = TClient<TGameServerPlayer>;

  TGameServer = class (TSyncableServer<TGameServerPlayer>)
    protected
      procedure Init; override;
      procedure OnClientConnect(const client: TGameClient); override;
      procedure OnClientDisconnect(const client: TGameClient); override;
      procedure OnReceiveClientData(const client: TGameClient; const packetReader: TPacketReader); override;

      procedure OnReceiveSyncData(const packetReader: TPacketReader); override;
      procedure OnConnect(sender: TObject); override;

      procedure OnDestroyClient(const client: TGameClient); override;
      procedure OnStart; override;
    private

      // Should move those function to TSyncableServer?
      procedure Sync(const client: TGameClient; const packetReader: TPacketReader); overload;
      procedure SyncPlayerAction(const client: TGameClient; const packet: TPacket);
      procedure HandlerSyncServerPlayerSync(const packetReader: TPacketReader; const client: TGameClient);
      procedure HandleSyncServerPlayerAction(const packetReader: TPacketReader; const client: TGameClient);
      procedure SendServerList(const packetReader: TPacketReader; const client: TGameClient);
      procedure OnConnectSuccess(sender: TObject); override;

      procedure SavePlayer(const client: TGameClient);

      var m_lobbies: TLobbiesList;

      var m_host: RawByteString;
      var m_port: Integer;
      var m_name: RawByteString;

      var m_iffManager: TIffManager;
      var m_serverOptions: TServerOptions;

      function LobbiesList: RawByteString;

      procedure HandleLobbyRequests(const lobby: TLobby; const packetId: TCGPID; const client: TGameClient; const packetReader: TPacketReader);
      procedure HandleGameRequests(const game: TGame; const packetId: TCGPID; const client: TGameClient; const packetReader: TPacketReader);

      procedure HandlePlayerLogin(const client: TGameClient; const packetReader: TPacketReader);
      procedure HandleDebugCommands(const client: TGameClient; const packetReader: TPacketReader; msg: RawByteString);
      procedure HandlerPlayerWhisper(const client: TGameClient; const packetReader: TPacketReader);
      procedure HandlePlayerSendMessage(const client: TGameClient; const packetReader: TPacketReader);
      procedure HandlePlayerRequestServerTime(const client: TGameClient; const packetReader: TPacketReader);
      procedure HandlerPlayerException(const client: TGameClient; const packetReader: TPacketReader);
      procedure HandlePlayerJoinLobby(const client: TGameClient; const packetReader: TPacketReader);
      procedure HandlePlayerBuyItem(const client: TGameClient; const packetReader: TPacketReader);
      procedure HandlePlayerRequestIdentity(const client: TGameClient; const packetReader: TPacketReader);
      procedure HandlePlayerRequestServerList(const client: TGameClient; const packetReader: TPacketReader);
      procedure HandlePlayerUpgrade(const client: TGameClient; const packetReader: TPacketReader);
      procedure HandlePlayerNotice(const client: TGameClient; const packetReader: TPacketReader);
      procedure HandlePlayerLeaveGrandPrix(const client: TGameClient; const packetReader: TPacketReader);
      procedure HandlePlayerEnterGrandPrix(const client: TGameClient; const packetReader: TPacketReader);
      procedure HandlePlayerJoinMultiplayerGamesList(const client: TGameClient; const packetReader: TPacketReader);
      procedure HandlePlayerLeaveMultiplayerGamesList(const client: TGameClient; const packetReader: TPacketReader);
      procedure HandlePlayerOpenRareShop(const client: TGameClient; const packetReader: TPacketReader);
      procedure HandlePlayerRequestMessengerList(const client: TGameClient; const packetReader: TPacketReader);
      procedure HandlePlayerGMCommand(const client: TGameClient; const packetReader: TPacketReader);
      procedure HandlePlayerUnknow00EB(const client: TGameClient; const packetReader: TPacketReader);
      procedure HandlePlayerOpenScratchyCard(const client: TGameClient; const packetReader: TPacketReader);
      procedure HandlePlayerSetAssistMode(const client: TGameClient; const packetReader: TPacketReader);
      procedure HandlePlayerRequestGuildListSearch(const client: TGameClient; const packetReader: TPacketReader);
      procedure HandlePlayerCharMastery(const client: TGameClient; const packetReader: TPacketReader);
      procedure HandlePlayerCreateGuild(const client: TGameClient; const packetReader: TPacketReader);
      procedure HandlePlayerCheckGuildName(const client: TGameClient; const packetReader: TPacketReader);
      procedure HandlePlayerRequestJoinGuild(const client: TGameClient; const packetReader: TPacketReader);
      procedure HandlePlayerRequestGuildList(const client: TGameClient; const packetReader: TPacketReader);
      procedure HandlePlayerUnknow0140(const client: TGameClient; const packetReader: TPacketReader);
      procedure HandlePlayerEnterScratchyCardSerial(const client: TGameClient; const packetReader: TPacketReader);
      procedure HandlePlayerRequestAchievements(const client: TGameClient; const packetReader: TPacketReader);
      procedure HandlePlayerSendInvite(const client: TGameClient; const packetReader: TPacketReader);
      procedure HandlePlayerGiveUpDailyQuest(const client: TGameClient; const packetReader: TPacketReader);
      procedure HandlePlayerAcceptDailyQuest(const client: TGameClient; const packetReader: TPacketReader);
      procedure HandlePlayerRecycleItem(const client: TGameClient; const packetReader: TPacketReader);
      procedure HandlePlayerRequestDailyQuest(const client: TGameClient; const packetReader: TPacketReader);
      procedure HandlePlayerRequestInbox(const client: TGameClient; const packetReader: TPacketReader);
      procedure HandlePlayerDeleteItem(const client: TGameClient; const packetReader: TPacketReader);
      procedure HandlerPlayerPangsTransaction(const client: TGameClient; const packetReader: TPacketReader);
      procedure HandlePlayerRequestLockerPage(const client: TGameClient; const packetReader: TPacketReader);
      procedure HandlePlayerRequestLockerPangs(const client: TGameClient; const packetReader: TPacketReader);
      procedure HandlePlayerChangeLockerPassword(const client: TGameClient; const packetReader: TPacketReader);
      procedure HandlerPlayerRequestLockerAccess(const client: TGameClient; const packetReader: TPacketReader);
      procedure HandlePlayerRequestLocker(const client: TGameClient; const packetReader: TPacketReader);
      procedure HandlePlayerSetMascotText(const client: TGameClient; const packetReader: TPacketReader);
      procedure HandlerPlayerClearQuest(const client: TGameClient; const packetReader: TPacketReader);
      procedure HandlerPlayerDeleteMail(const client: TGameClient; const packetReader: TPacketReader);
      procedure HandlerPlayerSendMail(const client: TGameClient; const packetReader: TPacketReader);
      procedure HandlePlayerRequestOfflinePlayerInfo(const client: TGameClient; const packetReader: TPacketReader);
      procedure HandlePlayerMoveInboxGift(const client: TGameClient; const packetReader: TPacketReader);
      procedure HandlePlayerRequestInboxDetails(const client: TGameClient; const packetReader: TPacketReader);
      procedure HandlePlayerRequestCookiesCount(const client: TGameClient; const packetReader: TPacketReader);
      procedure HandlePlayerRequestDailyReward(const client: TGameClient; const packetReader: TPacketReader);
      procedure HandlePlayerPlayBongdariShop(const client: TGameClient; const packetReader: TPacketReader);
      procedure HandlePlayerRequestInfo(const client: TGameClient; const packetReader: TPacketReader);

      procedure SendToGame(const client: TGameClient; data: RawByteString); overload;
      procedure SendToGame(const client: TGameClient; data: TPacket); overload;
      procedure SendToLobby(const client: TGameClient; data: RawByteString); overload;
      procedure SendToLobby(const client: TGameClient; data: TPacket); overload;

      function TryGetPlayerById(Id: UInt32; var player: TGameClient): Boolean;
      function GetPlayerByNickname(nickname: RawByteString): TGameClient;

      procedure RegisterServer;

    public
      constructor Create(cryptLib: TCryptLib; iffManager: TIffManager);
      destructor Destroy; override;
  end;

implementation

uses Logging, ConsolePas, utils, PacketData, defs,
        PlayerCharacter, GameServerExceptions,
  PlayerAction, Types.Vector3, PlayerData, BongdatriShop, PlayerEquipment,
  PlayerQuest, PlayerMascot, IffManager.IffEntryBase, IffManager.SetItem,
  IffManager.HairStyle, PlayerItem, PlayerGenericData, PlayerItems,
  PlayerMoneyPacket;

constructor TGameServer.Create(cryptLib: TCryptLib; iffManager: TIffManager);
begin
  inherited create('GameServer', cryptLib);
  Console.Log('TGameServer.Create');
  m_lobbies := TLobbiesList.Create;
  m_iffManager := iffManager;
  m_serverOptions := TServerOptions.Create;
end;

destructor TGameServer.Destroy;
begin
  m_lobbies.Free;
  m_serverOptions.Free;
  inherited;
end;

function TGameServer.LobbiesList: RawByteString;
begin
  Result := #$4D#$00 + m_lobbies.Build;
end;

procedure TGameServer.Init;
var
  iniFile: TIniFile;
begin
  iniFile := TIniFile.Create('../config/server.ini');

  m_port := iniFile.ReadInteger('game', 'port', 7997);
  self.SetPort(m_port);

  m_host := iniFile.ReadString('game', 'host', '127.0.0.1');

  m_name := iniFile.ReadString('game', 'name', 'GameServer');

  self.SetSyncPort(
    iniFile.ReadInteger('sync', 'port', 7998)
  );

  self.setSyncHost(
    iniFile.ReadString('sync', 'host', '127.0.0.1')
  );

  iniFile.Free;
end;

procedure TGameServer.OnClientConnect(const client: TGameClient);
var
  player: TGameServerPlayer;
  res: TPacketWriter;
  tmp: RawByteString;
begin
  self.Log('TGameServer.OnConnectClient', TLogType_not);

  res := TPacketWriter.Create;

  player := TGameServerPlayer.Create;
  client.Data := player;

  tmp := #$00#$3F#$00#$01#$01 +
    UTF8Char(client.GetKey()) +
    WritePStr(client.Host);

  res.WriteUint8(0);
  res.WritePStr(tmp);

  client.Send(res, false);

  res.Free;
end;

procedure TGameServer.OnClientDisconnect(const client: TGameClient);
var
  lobby: TLobby;
begin
  self.Log('TGameServer.OnDisconnectClient', TLogType_not);
  try
    lobby := m_lobbies.GetLobbyById(client.Data.Lobby);
    SavePlayer(client);
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

procedure TGameServer.OnConnectSuccess(sender: TObject);
begin
  Console.Log('TGameServer.OnConnectSuccess', C_BLUE);
  self.RegisterServer;
end;

procedure TGameServer.Sync(const client: TGameClient; const packetReader: TPacketReader);
begin
  self.Log('TGameServer.Sync', TLogType.TLogType_not);
  self.Sync(
    #$01#$00 + // SSPID_PLAYER_SYNC
    write(client.UID.id, 4) +
    writePStr(client.UID.login) +
    packetReader.ToStr
  );
end;

procedure TGameServer.SyncPlayerAction(const client: TGameClient; const packet: TPacket);
begin
  self.Log('TGameServer.Sync', TLogType.TLogType_not);
  self.Sync(
    #$02#$00 + // PLAYER_ACTION
    write(client.UID.id, 4) +
    writePStr(client.UID.login) +
    packet.ToStr
  );
end;

procedure TGameServer.HandlePlayerLogin(const client: TGameClient; const packetReader: TPacketReader);
var
  login: RawByteString;
  UID: UInt32;
  checkA: RawByteString;
  checkB: RawByteString;
  checkC: UInt32;
  clientVersion: RawByteString;
begin
  self.Log('TGameServer.HandlePlayerLogin', TLogType_not);

  packetReader.ReadPStr(login);

  packetReader.ReadUInt32(UID);
  packetReader.Skip(6);
  packetReader.ReadPStr(checkA);
  packetReader.ReadPStr(clientVersion);

  packetReader.ReadUInt32(checkc);
  checkc := self.Deserialize(checkc);
  self.Log(Format('check c dec : %x, %d', [checkc, checkc]));

  packetReader.seek(4, 1);

  packetReader.ReadPStr(checkb);
  self.Log(Format('Check b  : %s', [checkb]));

  client.UID.login := login;
  client.UID.id := 0;



  self.Sync(client, packetReader);
end;

procedure TGameServer.HandleDebugCommands(const client: TGameClient; const packetReader: TPacketReader; msg: RawByteString);
var
  game: TGame;
begin
  game := self.m_lobbies.GetPlayerGame(client);
  // Speed ugly way for debug command
  if msg = ':start' then
  begin
    game.DebugStartGame(client, packetReader);
  end
  else if msg = ':next' then
  begin
    game.GoToNextHole;
  end
  else if msg = ':dump' then
  begin
    WriteDataToFile('dump.dat',
      client.Data.Data.ToPacketData +
      m_serverOptions.ToPacketData
    );
  end else if msg = ':save' then
  begin
    SavePlayer(client);
  end;
end;

function TGameServer.GetPlayerByNickname(nickname: RawByteString): TGameClient;
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

function TGameServer.TryGetPlayerById(Id: UInt32; var player: TGameClient): Boolean;
var
  currentPlayer: TGameClient;
begin
  Result := false;
  for currentPlayer in Clients do
  begin
    if currentPlayer.Data.Data.playerInfo1.PlayerID = Id then
    begin
      player := currentPlayer;
      Exit(True);
    end;
  end;
end;

procedure TGameServer.HandlerPlayerWhisper(const client: TGameClient; const packetReader: TPacketReader);
var
  targetNickname: RawByteString;
  msg: RawByteString;
  res: TPacketWriter;
  target: TGameClient;
begin
  Console.Log('TGameeServer.HandlePlayerSendMessage', C_BLUE);
  {
    Whisper is supposed to work between servers
    we'll see that later
  }

  if not packetReader.ReadPStr(targetNickname) then
  begin
    Exit;
  end;

  if not packetReader.ReadPStr(msg) then
  begin
    Exit;
  end;

  Console.Log(Format('whisper to: %s', [targetNickname]));
  Console.Log(Format('whisper msg: %s', [msg]));

  target := GetPlayerByNickname(targetNickname);

  res := TPacketWriter.Create;

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

procedure TGameServer.HandlePlayerSendMessage(const client: TGameClient; const packetReader: TPacketReader);
var
  userNickname: RawByteString;
  msg: RawByteString;
  reply: TPacketWriter;
begin
  Console.Log('TGameeServer.HandlePlayerSendMessage', C_BLUE);
  packetReader.ReadPStr(userNickname);
  packetReader.ReadPStr(msg);

  reply := TPacketWriter.Create;
  reply.WriteStr(#$40#$00 + #$00);
  reply.WritePStr(userNickname);
  reply.WritePStr(msg);

  if (Length(msg) >= 1) and (msg[1] = ':') then
  begin
    self.HandleDebugCommands(client, packetReader, msg);
    Exit;
  end;

  SendToGame(client, reply);

  reply.Free;
end;

procedure TGameServer.HandlePlayerRequestServerTime(const client: TGameClient; const packetReader: TPacketReader);
begin
  Console.Log('TGameServer.HandlePlayerRequestServerTime', C_BLUE);

  Console.Log('Should analyse that better', C_ORANGE);

  // Should check more about that, it's used with the time displayed
  client.Send(
    #$BA#$00 +
    #$DF#$07#$0B#$00#$06#$00#$1C#$00#$15#$00#$1A#$00#$0D#$00#$01#$01
  );

end;

procedure TGameServer.HandlerPlayerException(const client: TGameClient; const packetReader: TPacketReader);
var
  msg: RawByteString;
begin
  self.Log('TGameServer.HandlerPlayerException', TLogType_not);
  packetReader.Log;
  packetReader.Skip(1);
  if packetReader.ReadPStr(msg) then
  begin
    Console.Error(Format('Exception : %s', [msg]));
  end;
end;

procedure TGameServer.HandlePlayerJoinLobby(const client: TGameClient; const packetReader: TPacketReader);
var
  lobbyId: UInt8;
  lobby: TLobby;
begin
  self.Log('TGameServer.HandlePlayerJoinLobby', TLogType_not);

  if false = packetReader.ReadUInt8(lobbyId) then
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

  client.Send(#$95#$00 + UTF8Char(lobbyId) + #$01#$00);
  client.Send(#$4E#$00 + #$01);
end;

procedure TGameServer.HandlePlayerBuyItem(const client: TGameClient; const packetReader: TPacketReader);
type
  TShopItemDesc = packed record
    un1: UInt32;
    IffId: TIffId;
    lifeTime: word; // days
    un2: array [0..1] of UTF8Char;
    qty: UInt32;
    un3: UInt32;
    un4: UInt32;
  end;
var
  rental: Byte;
  count: UInt16;
  I, J: integer;
  shopItem: TShopItemDesc;

  shopResult: RawByteString;
  successCount: uint16;
  test: TITEM_TYPE;
  itemId: UInt32;
  itemQty: UInt32;
  iffEntry: TIffEntrybase;
  iffEntry2: TIffEntrybase;
  itemSetDetails: TItemSetDetail;
  writeInfo: Boolean;
  character: TPlayerCharacter;
  totalCost: UInt32;
  packetWriter: TPacketWriter;
begin
  self.Log('TGameServer.HandlePlayerBuyItem', TLogType_not);

  shopResult := '';
  successCount := 0;
  {
    00000000  1D 00 00 01 00 FF FF FF  FF 13 40 14 08 00 00 FF    .....ˇˇˇˇ.@....ˇ
    00000010  FF 01 00 00 00 C4 09 00  00 00 00 00 00 00 00 00    ˇ....ƒ..........
    00000020  00                                                  .
  }
  packetReader.ReadUInt8(rental);
  packetReader.ReadUInt16(count);

  itemId := random($FFFFFFFF);

  for I := 1 to count do
  begin
    packetReader.Read(shopItem.un1, sizeof(TShopItemDesc));

    itemQty := shopItem.qty;

    if not self.m_iffManager.TryGetByIffId(shopItem.IffId.id, iffEntry) then
    begin
      client.Send(
        #$68#$00 +
        #$03#$00#$00#$00
      );
      Exit;
    end;

    if not client.Data.SubStractIffEntryPrice(iffEntry, itemQty) then
    begin
      Console.Log('player don''t have enough money!!', C_RED);
      Exit;
    end;

    Console.Log('item found');
    writeInfo := true;

    // TODO: Should work on another way to detect items

    case TITEM_TYPE(shopItem.IffId.typ) of
      ITEM_TYPE_CHARACTER:
      begin
        Console.Log('ITEM_TYPE_CHARACTER');
        with client.Data.Characters.Add(GetDataFromFile(Format('../data/c_%X.dat', [shopItem.IffId.id]))) do
        begin
          SetIffId(shopItem.IffId.id);
          SetId(itemId);
          client.Data.EquipCharacterById(GetId);
        end;
      end;
      ITEM_TYPE_FASHION:
      begin
        Console.Log('ITEM_TYPE_FASHION');
        with client.Data.Items.Add(shopItem.IffId.id) do
        begin
          itemId := getId;
          SetQty(1);
        end;
      end;
      ITEM_TYPE_CLUB:
      begin
        Console.Log('ITEM_TYPE_CLUB');
        with client.Data.Items.Add(shopItem.IffId.id) do
        begin
          itemId := getId;
          SetQty(1);
          itemQty := GetQty;
        end;
      end;
      ITEM_TYPE_AZTEC:
      begin
        Console.Log('ITEM_TYPE_AZTEC');
        with client.Data.Items.GetOrAddByIffId(shopItem.IffId.id) do
        begin
          itemId := getId;
          AddQty(itemQty);
          itemQty := GetQty;
        end;
      end;
      ITEM_TYPE_ITEM1:
      begin
        Console.Log('ITEM_TYPE_ITEM1');
        with client.Data.Items.GetOrAddByIffId(shopItem.IffId.id) do
        begin
          itemId := getId;
          AddQty(itemQty);
          itemQty := GetQty;
        end;
      end;
      ITEM_TYPE_ITEM2:
      begin
        Console.Log('ITEM_TYPE_ITEM2');
        with client.Data.Items.GetOrAddByIffId(shopItem.IffId.id) do
        begin
          itemId := getId;
          AddQty(itemQty);
          itemQty := GetQty;
        end;
      end;
      ITEM_TYPE_CADDIE:
      begin
        Console.Log('ITEM_TYPE_CADDIE');
        with client.Data.Caddies.GetOrAddByIffId(shopItem.IffId.id) do
        begin
          itemId := getId;
        end;
      end;
      ITEM_TYPE_CADDIE_ITEM:
      begin
        Console.Log('ITEM_TYPE_CADDIE_ITEM');
      end;
      ITEM_TYPE_ITEM_SET:
      begin
        Console.Log('ITEM_TYPE_ITEM_SET');
        with TSetItemDataClass(iffEntry) do
        begin
          for J := 0 to GetCount - 1 do
          begin
            itemSetDetails := GetItem(J);

            if m_iffManager.TryGetByIffId(itemSetDetails.IffId, iffEntry2) then
            begin
              with client.Data.Items.Add(shopItem.IffId.id) do
              begin
                itemId := getId;
                SetQty(1);
                inc(successCount);
                itemQty := GetQty;

                shopResult := shopResult +
                  self.Write(itemSetDetails.IffId, 4) + // IffId
                  self.Write(itemId, 4) + // Id
                  self.Write(shopItem.lifeTime, 2) + // time
                  #$00 +
                  self.Write(itemQty, 4) + // qty left
                  #$00#$00#$00#$00#$00#$00#$00#$00#$00#$00#$00#$00#$00 +
                  #$00#$00#$00#$00#$00#$00#$00#$00#$00#$00;
              end;
            end;
          end;
        end;
        writeInfo := false;
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
      ITEM_TYPE_HAIR_COLOR1,
      ITEM_TYPE_HAIR_COLOR2:
      begin
        Console.Log('ITEM_TYPE_HAIR_COLOR');
        with THairStyleDataClass(IffEntry) do
        begin
          if client.Data.Characters.TryGetByIffId(GetCharacterIffId, character) then
          begin
            character.SetHairColor(GetColor);
            if client.Data.Data.witems.CharacterId = character.GetId then
            begin
              client.Data.EquipCharacterById(character.GetId);
            end;
          end;
        end;
      end;
      ITEM_TYPE_MASCOT:
      begin
        Console.Log('ITEM_TYPE_MASCOT');
        with client.Data.Mascots.Add(shopItem.IffId.id) do
        begin
          itemId := getId;
        end;
      end;
      ITEM_TYPE_FURNITURE:
      begin
        Console.Log('ITEM_TYPE_FURNITURE');
        with client.Data.Mascots.Add(shopItem.IffId.id) do
        begin
          itemId := getId;
        end;
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

    if writeInfo then
    begin
      inc(successCount);
      shopResult := shopResult +
        self.Write(shopItem.IffId, 4) + // IffId
        self.Write(itemId, 4) + // Id
        self.Write(shopItem.lifeTime, 2) + // time
        #$00 +
        self.Write(itemQty, 4) + // qty left
        #$00#$00#$00#$00#$00#$00#$00#$00#$00#$00#$00#$00#$00 +
        #$00#$00#$00#$00#$00#$00#$00#$00#$00#$00;
    end;
  end;

  // shop result
  client.Send(
    #$AA#$00 +
    self.Write(successCount, 2) +
    shopResult +
    self.Write(client.Data.data.playerInfo2.pangs, 8) +
    #$00#$00#$00#$00#$00#$00#$00#$00
  );

  packetWriter := TPlayerMoneyPacket.CreateForPlayer(client.data);
  client.Send(packetWriter);
  packetWriter.Free;

  {
    0x01: purchase failed
    0x02: you do not have enough pang
    0x03: wrong item code
    0x04: you already have that item
    0x09: check the time limit of your item
    0x0b: please check sale times
    0x10: you are using a timed item
    0x11: you are using a consumable item
    0x12: you cannot purchase any more items
    0x13: item is not for sale
    0x15: you are purchasing too many items at once
    0x17: you do not have enough points
    0x18: points update failed
    0x22: you cannot own this item any more
    0x23: purchase cannot be made due to traffic. please try again
    0x24: you already have that item
    0x2A: you already have this item in Dolphini's locker
    0x2B: you cannot purchase that item at your level
    0x2D: you cannot purchase because channeling service have ended
  }

  // Pangs and cookies info
  client.Send(
    #$68#$00 +
    #$00#$00#$00#$00 +
    self.Write(client.Data.data.playerInfo2.pangs, 8) +
    self.Write(client.Data.Cookies, 8)
  );

end;

procedure TGameServer.HandlePlayerRequestIdentity(const client: TGameClient; const packetReader: TPacketReader);
var
  mode: UInt32;
  playerName: RawByteString;
begin
  Console.Log('TGameServer.HandlePlayerRequestIdentity', C_BLUE);
  packetReader.ReadUInt32(mode);
  packetReader.ReadPStr(playerName);

  Console.Log(Format('playerName : %s', [playerName]));

  case mode of
    $80: begin
      // log something
      client.data.IsAdmin := false;
    end;
    $FFFFFFFF: begin
      client.data.IsAdmin := true;
    end;
  end;

  // TODO: should check if player can really do that
  client.Send(
    #$9A#$00 +
    Write(mode, 4)
  );

end;

procedure TGameServer.HandlePlayerRequestServerList(const client: TGameClient; const packetReader: TPacketReader);
var
  packetWriter: TPacketWriter;
begin
  Console.Log('TGameServer.HandlePlayerRequestServerList', C_BLUE);
  // Request server list to sync server
  packetWriter := TPacketWriter.Create;
  packetWriter.WriteAction(TSSAPID.SEND_SERVER_LIST);
  self.SyncPlayerAction(client, packetWriter);
  packetWriter.Free;
end;

procedure TGameServer.HandlePlayerUpgrade(const client: TGameClient; const packetReader: TPacketReader);
type

  TActionType = (
    actionType_upgrade = 1,
    actionType_downgrade = 2
  );

  TPacketHeader = packed record
    action: UInt8;
    upType: UInt8;
    itemId: UInt32;
  end;
var
  header: TPacketHeader;
  actionType: TActionType;
  res: TPacketWriter;
begin
  Console.Log('TGameServer.HandlePlayerUpgrade', C_BLUE);

  if not packetReader.Read(header, SizeOf(TPacketHeader)) then
  begin
    Console.Log('Failed to read header', C_RED);
    Exit;
  end;

  actionType := actionType_upgrade;

  case header.action of
    0: // character upgrade
    begin  
      actionType := actionType_upgrade;
    end;
    1: // club upgrade
    begin
      actionType := actionType_upgrade;
    end;
    2: // charcater downgrade
    begin
      actionType := actionType_downgrade;
    end;
    3: // club downgrade
    begin
      actionType := actionType_downgrade;
    end;
    else begin
      Console.Log('Unknow action');
    end;
  end;
  
  res := TPacketWriter.Create;

  // upgrade result
  res.WriteStr(#$A5#$00);
  res.Write(actionType, 1); // upgrade type (upgrade|downgrade)
  res.Write(header, SizeOf(TPacketHeader));
  res.WriteStr(#$34#$08#$00#$00#$00#$00#$00#$00);

  client.Send(res);

  res.Clear;

  // Pangs and cookies info
  res.WriteStr(#$A5#$00);
  res.WriteUInt64(client.Data.data.playerInfo2.pangs);
  res.WriteUInt64(client.Data.Cookies);

  client.Send(res);

  res.Free;
end;

procedure TGameServer.HandlePlayerNotice(const client: TGameClient; const packetReader: TPacketReader);
var
  notice: RawByteString;
begin
  Console.Log('TGameServer.HandlePlayerNotice', C_BLUE);

  if not client.data.IsAdmin then
  begin
    Exit;
  end;

  // TODO: should check if the player can do that
  if packetReader.ReadPStr(notice) then
  begin
    m_lobbies.Send(
      #$41#$00 +
      WritePStr(notice)
    );
  end;
end;

procedure TGameServer.HandlePlayerLeaveGrandPrix(const client: TGameClient; const packetReader: TPacketReader);
begin
  Console.Log('TGameServer.HandlePlayerLeaveGrandPrix', C_BLUE);

  {
    Should Send me leaving
    46 00 02 01 ...
  }

  client.Send(
    #$51#$02 +
    #$00#$00#$00#$00
  );

end;

procedure TGameServer.HandlePlayerEnterGrandPrix(const client: TGameClient; const packetReader: TPacketReader);
begin
  Console.Log('TGameServer.HandlePlayerEnterGrandPrix', C_BLUE);

  {
    Should Send
    46 00 04 03 ...
    47 00 02 00 FF FF ...
    then myself
    46 00 01 01 ...

  }


  client.Send(
    #$50#$02 +
    #$00#$00#$00#$00 +
    #$01#$00#$00#$00 +
    #$03#$00#$00#$00#$01#$00 +
    #$00#$00#$00#$01#$00#$00#$02#$00#$00#$00#$00#$00#$84#$42
  );

end;

procedure TGameServer.HandlePlayerJoinMultiplayerGamesList(const client: TGameClient; const packetReader: TPacketReader);
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

procedure TGameServer.HandlePlayerLeaveMultiplayerGamesList(const client: TGameClient; const packetReader: TPacketReader);
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

procedure TGameServer.HandlePlayerOpenRareShop(const client: TGameClient; const packetReader: TPacketReader);
begin
  Console.Log('TGameServer.HandlePlayerOpenRareShop', C_BLUE);
  client.Send(#$0B#$01#$FF#$FF#$FF#$FF#$FF#$FF#$FF#$FF#$00#$00#$00#$00);
end;

procedure TGameServer.HandlePlayerRequestMessengerList(const client: TGameClient; const packetReader: TPacketReader);
var
  packet: TPacketWriter;
begin
  Console.Log('TGameServer.HandlePlayerRequestMessengerList', C_BLUE);

  packet := TPacketWriter.Create;
  
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

procedure TGameServer.HandlePlayerGMCommand(const client: TGameClient; const packetReader: TPacketReader);
var
  command: UInt16;
  tmpUInt32: UInt32;
  tmpUInt16: UInt16;
  tmpUInt8: UInt8;
  tmp1UInt8: UInt8;
  tmpPStr: RawByteString;
  game: TGame;
begin
  Console.Log('TGameServer.HandlePlayerGMCommand', C_BLUE);

  if not client.data.IsAdmin then
  begin
    Exit;
  end;

  try
    game := m_lobbies.GetPlayerGame(client);
  except
    Console.Log('Failed to get player game');
    Exit;
  end;

  if not packetReader.ReadUInt16(command) then
  begin
    Console.Log(Format('Unknow Command %d', [command]), C_RED);
    Exit;
  end;

  case command of
    $3: begin // visible (on|off)

    end;
    $4: begin // whisper (on|off)

    end;
    $5: begin // channel (on|off)

    end;
    $8: begin // open
      if (packetReader.ReadPStr(tmpPStr)) then
      begin
        Console.Log(Format('open %s', [tmpPStr]));
      end;
    end;
    $9: begin // close
      if (packetReader.ReadPStr(tmpPStr)) then
      begin
        Console.Log(Format('close %s', [tmpPStr]));
      end;
    end;
    $E: begin // wind (speed - dir)
      if packetReader.ReadUInt8(tmpUInt8) and packetReader.ReadUInt8(tmp1UInt8) then
      begin
        Console.Log(Format('wind %d, %d', [tmpUInt8, tmp1UInt8]));
      end;
    end;
    $A: begin // kick
      if (packetReader.ReadUInt32(tmpUInt32)) then
      begin
        console.Log(Format('kick %d', [tmpUInt32]));
      end;
    end;
    $F: begin // weather (fine|rain|snow|cloud)
      if (packetReader.ReadUInt8(tmpUInt8)) then
      begin
        console.Log(Format('weather %d', [tmpUInt8]));
        game.Send(#$9E#$00 + UTF8Char(tmpUInt8) + #$00#$00);
      end;
    end;
    $1C: begin // setmission
      if (packetReader.ReadUInt32(tmpUInt32)) then
      begin
        console.Log(Format('setmission %d', [tmpUInt8]));
      end;
    end;
    $1F: begin // matchmap
      console.Log('matchmap');
      if (packetReader.ReadUInt32(tmpUInt32)) then
      begin
        console.Log(Format('matchmap %d', [tmpUInt8]));
      end;
    end;
  end;

end;

procedure TGameServer.HandlePlayerUnknow00EB(const client: TGameClient; const packetReader: TPacketReader);
begin
  Console.Log('TGameServer.HandlePlayerUnknow0140', C_BLUE);
  // Should send that to all players
  client.Send(
    #$96#$01 +
    #$4E#$01#$00#$00 + #$00#$00#$80#$3F + #$00#$00#$80#$3F +
    #$00#$00#$80#$3F + #$00#$00#$80#$3F + #$00#$00#$80#$3F
  );
end;

procedure TGameServer.HandlePlayerOpenScratchyCard(const client: TGameClient; const packetReader: TPacketReader);
begin
  Console.Log('TGameServer.HandlePlayerOpenScratchyCard', C_BLUE);
  client.Send(#$EB#$01#$00#$00#$00#$00#$00);
end;

procedure TGameServer.HandlePlayerCharMastery(const client: TGameClient; const packetReader: TPacketReader);
var
  packetWriter: TPacketWriter;
begin
  Console.Log('TGameServer.HandlePlayerCharMastery', C_BLUE);
  packetReader.Log;
             //hsreina
  {
  client.Send(
    #$16#$02#$D2#$6E#$FE#$58#$01#$00#$00#$00#$02#$84#$00#$40#$6C#$4A +
    #$C7#$00#$00#$00#$00#$00#$00#$03#$00#$00#$00#$04#$00#$00#$00#$01 +
    #$00#$00#$00#$00#$00#$00#$00#$00#$00#$00#$00#$00#$00#$00#$00#$00 +
    #$00#$00#$00#$00#$00#$00#$00#$00#$00#$00#$00#$00
  );
  }

  {
  client.Send(
    #$2E#$02#$00#$00#$00#$00
  );
  }
  {
  client.Send(
    #$20#$02#$00#$00#$00#$00#$00#$00#$00#$00
  );
  }

  packetWriter := TPlayerMoneyPacket.CreateForPlayer(client.data);
  client.Send(packetWriter);
  packetWriter.Free;

  {
  client.Send(
    #$16#$02#$D3#$6E#$FE#$58#$01#$00#$00#$00#$C9#$00#$00#$00#$04#$B9 +
    #$00#$00#$00#$00#$00#$00#$00#$00#$00#$00#$00#$00#$00#$00#$00#$00 +
    #$00#$00#$00#$01#$00#$00#$00#$00#$00#$00#$00#$00#$00#$00#$00#$00 +
    #$00#$00#$00#$00#$00#$00#$00#$00#$00#$00#$00#$00
  );
  }

  // confirm action
  client.Send(
    #$6F#$02#$00#$00#$00#$00#$00#$00#$00#$00
  );

end;

procedure TGameServer.HandlePlayerRequestGuildListSearch(const client: TGameClient; const packetReader: TPacketReader);
var
  keyword: RawByteString;
  un1: UInt32;
  res: TPacketWriter;
begin
  Console.Log('TGameServer.HandlePlayerRequestGuildListSearch', C_BLUE);
  packetReader.ReadUInt32(un1);
  packetReader.ReadPStr(keyword);
  Console.Log(Format('keyword : %s', [keyword]));

  res := TPacketWriter.Create;

  res.WriteStr(#$BD#$01);
  res.WriteUInt32(1); // success or not?
  res.WriteInt32(1); // page number
  res.WriteUInt32(1); // total elements in search

  res.WriteUInt16(1); // number of entries (max $f)

  // loop this

  res.WriteUInt32(1); // guild ID
  res.WriteStr('guild name', 13, #$00);
  res.WriteStr(#$00#$00#$00#$00);
  res.WriteUInt32(1); // pangs
  res.WriteUInt32(2); // points
  res.WriteUInt32(3); // number of players
  res.WriteStr(#$DF#$07#$0B#$00#$00#$00#$05#$00#$09#$00#$09#$00#$00#$00#$00#$00);
  res.WriteStr('description', 16 * 6, #$00);
  res.WriteStr(#$00#$00#$00#$00#$00#$00#$00#$00#$00);
  res.WriteUInt32(1); // leader Id?
  res.WriteStr('leader name', $16, #$00);
  res.WriteStr(#$47#$55#$49#$4C#$44#$4D#$41#$52#$4B#$00#$00#$00);

  // to this

  client.Send(res);
  res.Free;
end;

procedure TGameServer.HandlePlayerCreateGuild(const client: TGameClient; const packetReader: TPacketReader);
var
  name: RawByteString;
  description: RawByteString;
  res: TPacketWriter;
begin
  Console.Log('TGameServer.HandlePlayerCreateGuild', C_BLUE);
  packetReader.ReadPStr(name);
  packetReader.ReadPStr(description);
  Console.Log(Format('Name: %s', [name]));
  Console.Log(Format('Description: %s', [description]));

  // On success, should remove the item to create guild

  res := TPacketWriter.Create;

  res.WriteStr(#$B5#$01);
  res.WriteUInt32(1); // status

  client.Send(res);

  res.Free;

end;

procedure TGameServer.HandlePlayerCheckGuildName(const client: TGameClient; const packetReader: TPacketReader);
var
  guildName: RawByteString;
  res: TPacketWriter;
begin
  Console.Log('TGameServer.HandlePlayerCheckGuildName', C_BLUE);
  packetReader.ReadPStr(guildName);
  Console.Log(Format('guildName : %s', [guildName]));

  res := TPacketWriter.Create;
  res.WriteStr(#$B6#$01);
  res.WriteUInt32(1); // status
  res.WritePStr(guildName);

  client.Send(res);

  res.Free;

end;

procedure TGameServer.HandlePlayerRequestJoinGuild(const client: TGameClient; const packetReader: TPacketReader);
var
  un1: UInt32;
  applicationMessage: RawByteString;
begin
  console.Log('TGameServer.HandlePlayerRequestJoinGuild', C_BLUE);
  packetReader.ReadUInt32(un1);
  packetReader.ReadPStr(applicationMessage);
  console.Log(Format('un1 %x', [un1]));
  console.Log(Format('Application message : %s', [applicationMessage]));

end;

procedure TGameServer.HandlePlayerRequestGuildList(const client: TGameClient; const packetReader: TPacketReader);
var
  page: UInt32;
  res: TPacketWriter;
begin
  Console.Log('TGameServer.HandlePlayerRequestGuildList', C_BLUE);
  packetReader.ReadUInt32(page);
  Console.Log(Format('page : %x', [page]));

  res := TPacketWriter.Create;

  res.WriteStr(#$BC#$01);
  res.WriteUInt32(1); // success or not?
  res.WriteInt32(page); // page number
  res.WriteUInt32(1); // total elements in search

  res.WriteUInt16(1); // number of entries (max $f)

  // loop this

  res.WriteUInt32(1); // guild ID
  res.WriteStr('guild name', 13, #$00);
  res.WriteStr(#$00#$00#$00#$00);
  res.WriteUInt32(1); // pangs
  res.WriteUInt32(2); // points
  res.WriteUInt32(3); // number of players
  res.WriteStr(#$DF#$07#$0B#$00#$00#$00#$05#$00#$09#$00#$09#$00#$00#$00#$00#$00);
  res.WriteStr('description', 16 * 6, #$00);
  res.WriteStr(#$00#$00#$00#$00#$00#$00#$00#$00#$00);
  res.WriteUInt32(1); // leader Id?
  res.WriteStr('leader name', $16, #$00);
  res.WriteStr(#$47#$55#$49#$4C#$44#$4D#$41#$52#$4B#$00#$00#$00);

  // to this

  client.Send(res);
  res.Free;
end;

procedure TGameServer.HandlePlayerSetAssistMode(const client: TGameClient; const packetReader: TPacketReader);
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

procedure TGameServer.HandlePlayerUnknow0140(const client: TGameClient; const packetReader: TPacketReader);
begin
  self.Log('TGameServer.HandlePlayerUnknow0140', TLogType_not);
  client.Send(#$0E#$02#$00#$00#$00#$00#$00#$00#$00#$00);
end;

procedure TGameServer.HandlePlayerEnterScratchyCardSerial(const client: TGameClient; const packetReader: TPacketReader);
const
  validSerialSize = 13;
var
  serial: RawByteString;
  serialSize: Uint32;
begin
  Console.Log('TGameServer.HandlePlayerEnterScratchyCardSerial', C_BLUE);

  packetReader.Log;

  if not packetReader.ReadUInt32(serialSize) then
  begin
    Exit;
  end;

  if not (serialSize = validSerialSize) then
  begin
    Exit;
  end;

  setLength(serial, validSerialSize);

  if not packetReader.Read(serial[1], validSerialSize) then
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

procedure TGameServer.HandlePlayerRequestAchievements(const client: TGameClient; const packetReader: TPacketReader);
var
  something: UInt32;
  achievementsData: RawByteString;
begin
  Console.Log('TGameServer.HandlePlayerRequestAchievements', C_BLUE);

  packetReader.Log;

  if not packetReader.ReadUInt32(something) then
  begin
    Console.Error('Faield to read something');
    Exit;
  end;

  console.Log(Format('something %x', [something]));

  achievementsData := GetDataFromFile('../data/achievements.dbg');

  if Length(achievementsData) = 0 then
  begin
    Console.Log('missing achievement data', C_RED);
  end;

  // Achievements
  client.Send(achievementsData);

  client.Send(#$2C#$02 + #$00#$00#$00#$00);
end;

procedure TGameServer.HandlePlayerSendInvite(const client: TGameClient; const packetReader: TPacketReader);
begin
  Console.Log('TGameServer.HandlePlayerSendInvite', C_BLUE);
  packetReader.Log;
  Console.Log('Should implement that', C_ORANGE);
end;

procedure TGameServer.HandlePlayerGiveUpDailyQuest(const client: TGameClient; const packetReader: TPacketReader);
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

procedure TGameServer.HandlePlayerAcceptDailyQuest(const client: TGameClient; const packetReader: TPacketReader);
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

procedure TGameServer.HandlePlayerRecycleItem(const client: TGameClient; const packetReader: TPacketReader);
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
  packetWriter: TPacketWriter;
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
  if not packetReader.ReadUInt32(count) then
  begin
    Exit;
  end;

  for I := 1 to count do
  begin
    packetReader.Read(itemInfo, SizeOf(TRecycleItemInfo));
    console.Log('recycle info : ');
    console.Log(Format('IffId %x', [itemInfo.IffId]));
    console.Log(Format('Id %x', [itemInfo.Id]));
    console.Log(Format('Un %x', [itemInfo.Un]));
  end;

  packetWriter := TPlayerMoneyPacket.CreateForPlayer(client.data);
  client.Send(packetWriter);
  packetWriter.Free;

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

procedure TGameServer.HandlePlayerRequestDailyQuest(const client: TGameClient; const packetReader: TPacketReader);
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

procedure TGameServer.HandlePlayerRequestInbox(const client: TGameClient; const packetReader: TPacketReader);
var
  res: TPacketWriter;
begin
  Console.Log('TGameServer.HandlePlayerRequestInbox', C_BLUE);
  res := TPacketWriter.Create;

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

procedure TGameServer.HandlePlayerDeleteItem(const client: TGameClient; const packetReader: TPacketReader);
var
  itemIffId: UInt32;
  count: UInt32;
  res: TPacketWriter;
  playerItem: TPlayerItem;
  status: UInt8;
  itemId: UInt32;
  playerItems: TPlayerItems;
begin
  Console.Log('TGameServer.HandlePlayerDeleteItem', C_BLUE);

  if not packetReader.ReadUInt32(itemIffId) or not packetReader.ReadUInt32(count) then
  begin
    Exit;
  end;

  Console.Log(Format('Delete: %x, %d', [itemIffId, count]));

  playerItems := client.Data.Items;

  res := TPacketWriter.Create;
  res.WriteStr(#$C5#$00);
  if client.Data.Items.TryGetByIffId(itemIffId, playerItem) then
  begin
    if playerItem.RemQty(count) then
    begin
      status := 1;
      itemId := playerItem.GetId;

      // If there no more items, remove it from the list
      if playerItem.GetQty = 0 then
      begin
        playerItems.Remove(playerItem);
      end;
    end;
  end;

  res.WriteUInt8(status);
  res.WriteUInt32(itemIffId);
  res.WriteUInt32(count);
  res.WriteUInt32(itemId);

  client.Send(res);

  res.Free;
end;

procedure TGameServer.HandlerPlayerPangsTransaction(const client: TGameClient; const packetReader: TPacketReader);
type
  TACTION_TYPE = (
    ACTION_TYPE_REMOVE = 0,
    ACTION_TYPE_ADD = 1
  );
var
  action: TACTION_TYPE;
  pangsAmount: UInt64;
begin
  Console.Log('TGameServer.HandlerPlayerPangsTransaction', C_BLUE);

  packetReader.Log;

  if not packetReader.Read(action, 1) then
  begin
    Exit;
  end;

  if not packetReader.ReadUInt64(pangsAmount) then
  begin
    Exit;
  end;

  case action of
    ACTION_TYPE_REMOVE:
    begin
      console.Log(Format('Should remove %d pangs', [pangsAmount]));
    end;
    ACTION_TYPE_ADD:
    begin
      console.Log(Format('Should add %d pangs', [pangsAmount]));
    end;
  end;

  // you entered a higher amount than allowed
  client.Send(#$71#$01#$78#$00#$00#$00);

  // entered value greater than what you have
  //client.Send(#$71#$01#$6F#$00#$00#$00);

end;

procedure TGameServer.HandlePlayerRequestLockerPage(const client: TGameClient; const packetReader: TPacketReader);
begin
  Console.Log('TGameServer.HandlePlayerRequestLockerPage', C_BLUE);
  client.Send(
    #$6D#$01 +
    #$03#$00 + // Pages
    #$02#$00 + // current page
    #$00 // count
    // + list of TPlayerLockerItemData
    );
end;

procedure TGameServer.HandlePlayerRequestLockerPangs(const client: TGameClient; const packetReader: TPacketReader);
var
  pangs: UInt64;
  res: TPacketWriter;
begin
  Console.Log('TGameServer.HandlePlayerChangeLockerPassword', C_BLUE);

  pangs := 99999999;

  res := TPacketWriter.Create;
  res.WriteStr(#$72#$01);
  res.WriteUInt64(pangs);

  client.Send(res);

  res.Free;
end;

procedure TGameServer.HandlePlayerChangeLockerPassword(const client: TGameClient; const packetReader: TPacketReader);
var
  oldPassword: RawByteString;
  newPassword: RawByteString;
begin
  Console.Log('TGameServer.HandlePlayerChangeLockerPassword', C_BLUE);

  if not packetReader.ReadPStr(oldPassword) then
  begin
    Console.Error('Failed to read old password');
  end;

  if not packetReader.ReadPStr(newPassword) then
  begin
    Console.Error('Failed to read new password');
  end;

  Console.Log(Format('old: %s; new: %s', [oldPassword, newPassword]));

end;

procedure TGameServer.HandlerPlayerRequestLockerAccess(const client: TGameClient; const packetReader: TPacketReader);
var
  password: RawByteString;
begin
  Console.Log('TGameServer.HandlerPlayerRequestLockerAccess', C_BLUE);
  if not packetReader.ReadPStr(password) then
  begin
    Exit;
  end;
  console.log(Format('Access code: %s', [password]));

  client.Send(#$6C#$01#$00#$00#$00#$00);

end;

procedure TGameServer.HandlePlayerRequestLocker(const client: TGameClient; const packetReader: TPacketReader);
begin
  Console.Log('TGameServer.HandlePlayerRequestLocker', C_BLUE);
  client.Send(#$70#$01#$00#$00#$00#$00#$4C#$00#$00#$00);
end;

procedure TGameServer.HandlePlayerSetMascotText(const client: TGameClient; const packetReader: TPacketReader);
var
  mascotId: UInt32;
  text: RawByteString;
  mascot: TPlayerMascot;
  res: TPacketWriter;
begin
  Console.Log('TGameServer.HandlePlayerSetMascotText', C_BLUE);
  if not packetReader.ReadUInt32(mascotId) or not packetReader.ReadPStr(text) then
  begin
    Exit;
  end;

  try
    mascot := client.Data.Mascots.getById(mascotId);
  except
    on E: NotFoundException do
    begin
      res := TPacketWriter.Create;
      res.WriteStr(#$E2#$00 + #$01);
      res.WriteUInt32(mascotId);
      client.Send(res);
      res.Free;
      Exit;
    end;
  end;

  if client.Data.Data.playerInfo2.pangs < 100 then
  begin
    // Not enough pang
    res := TPacketWriter.Create;
    res.WriteStr(#$E2#$00 + #$03);
    res.WriteUInt32(mascotId);
    client.Send(res);
    res.Free;
    Exit;
  end;

  dec(client.Data.Data.playerInfo2.pangs, 100);

  mascot.setText(text);

  res := TPacketWriter.Create;

  res.WriteStr(#$E2#$00 + #$04);
  res.WriteUInt32(mascotId);
  res.WritePStr(text);
  res.WriteUInt64(client.Data.Data.playerInfo2.pangs);

  client.Send(res);

  res.Free;
end;

procedure TGameServer.HandlerPlayerClearQuest(const client: TGameClient; const packetReader: TPacketReader);
type
  TQuestData = packed record
    pos: word;
    value: cardinal;
  end;
var
  res: TPacketWriter;
  questData: TQuestData;
  playerQuests: TPlayerQuest;
  newQuestStatus: UInt32;
begin
  Console.Log('TGameServer.HandlerPlayerClearQuest', C_BLUE);

  if not packetReader.Read(questData, SizeOf(TQuestData)) then
  begin
    Exit;
  end;

  playerQuests := client.Data.Quests;

  newQuestStatus := playerQuests.GetQuestData(questData.pos) + questData.value;

  playerQuests.SetQuestData(
    questData.pos,
    newQuestStatus
  );

  res := TPacketWriter.Create;

  res.WriteStr(
    #$1F#$01 +
    #$00#$01
  );

  res.WriteUInt32(newQuestStatus);

  client.Send(res);

  res.Free;
end;

procedure TGameServer.HandlerPlayerDeleteMail(const client: TGameClient; const packetReader: TPacketReader);
var
  mailTo: RawByteString;
  mailBody: RawByteString;
  un1, un2: UInt32;
  res: TPacketWriter;
begin
  Console.Log('TGameServer.HandlerPlayerDeleteMail', C_BLUE);
  packetReader.ReadUInt32(un1);
  packetReader.ReadUInt32(un2);
  Console.Log(Format('un1: %x, un2: %x', [un1, un2]));

  res := TPacketWriter.Create;

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

procedure TGameServer.HandlerPlayerSendMail(const client: TGameClient; const packetReader: TPacketReader);
var
  mailTo: RawByteString;
  mailBody: RawByteString;
  un1, un2: UInt32;
  packetWriter: TPacketWriter;
begin
  Console.Log('TGameServer.HandlerPlayerSendMail', C_BLUE);

  packetReader.ReadUInt32(un1);
  packetReader.ReadUInt32(un2);
  Console.Log(Format('un1: %x, un2: %x', [un1, un2]));

  if not packetReader.ReadPStr(mailTo) then
  begin
    Exit;
  end;

  packetReader.Skip(2);

  if not packetReader.ReadPStr(mailBody) then
  begin
    Exit;
  end;

  console.Log(Format('mailTo : %s', [mailto]));
  console.Log(Format('mailBody : %s', [mailBody]));

  packetWriter := TPlayerMoneyPacket.CreateForPlayer(client.data);
  client.Send(packetWriter);
  packetWriter.Free;

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

procedure TGameServer.HandlePlayerRequestOfflinePlayerInfo(const client: TGameClient; const packetReader: TPacketReader);
var
  nick: RawByteString;
  res: TPacketWriter;
begin
  Console.Log('TGameServer.HandlePlayerRequestOfflinePlayerInfo', C_BLUE);

  packetReader.Skip(1);

  if not packetReader.ReadPStr(nick) then
  begin
    Exit;
  end;

  console.Log(Format('search nickname %s', [nick]));

  res := TPacketWriter.Create;

  res.WriteStr(#$A1#$00);
  res.WriteUInt8(0); // response type 0 ok 2 not found

  // player unique Id
  res.WriteUInt32(client.Data.Data.playerInfo1.PlayerID);
  // Player info without the gameId
  res.Write(client.Data.Data.playerInfo1.login[0], SizeOf(TPlayerInfo1) - 2);

  client.Send(res);

  res.Free;
end;

procedure TGameServer.HandlePlayerMoveInboxGift(const client: TGameClient; const packetReader: TPacketReader);
var
  inboxId: UInt32;
  res: TPacketWriter;
begin
  Console.Log('TGameServer.HandlePlayerMoveInboxGift', C_BLUE);
  packetReader.Log;

  if not packetReader.ReadUInt32(inboxId) then
  begin
    Exit;
  end;

  res := TPacketWriter.Create;

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

procedure TGameServer.HandlePlayerRequestInboxDetails(const client: TGameClient; const packetReader: TPacketReader);
var
  inboxId: UInt32;
  res: TPacketWriter;
begin
  Console.Log('TGameServer.HandlePlayerRequestInboxDetails', C_BLUE);
  if not packetReader.ReadUInt32(inboxId) then
  begin
    Exit;
  end;

  res := TPacketWriter.Create;

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

procedure TGameServer.HandlePlayerRequestCookiesCount(const client: TGameClient; const packetReader: TPacketReader);
var
  res: TPacketWriter;
begin
  Console.Log('TGameServer.PlayerRequestDailyReward', C_BLUE);
  res := TPacketWriter.Create;
  res.WriteStr(WriteAction(TSGPID.PLAYER_COOKIES));
  res.WriteInt64(client.Data.Cookies);
  client.Send(res);
  res.Free;
end;

procedure TGameServer.HandlePlayerRequestDailyReward(const client: TGameClient; const packetReader: TPacketReader);
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

procedure TGameServer.HandlePlayerPlayBongdariShop(const client: TGameClient; const packetReader: TPacketReader);
const
  ballCount: UInt32 = 1;
  transactionCount: UInt32 = 1;
var
  res: TPacketWriter;
  res2: TPacketWriter;
  bongdariResultItem: TBongdariResultItem;
  bongdariTransactionResult: TBongdariTransactionResult;
  I: UInt32;
begin
  Console.Log('TGameServer.HandlePlayerPlayBongdariShop', C_BLUE);

  res := TPacketWriter.Create;
  res2 := TPacketWriter.Create;

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

procedure TGameServer.HandlePlayerRequestInfo(const client: TGameClient; const packetReader: TPacketReader);
var
  res: TPacketWriter;
  playerId: UInt32;
  un1: UInt8;
  targetPlayer: TGameClient;
begin
  Console.Log('TGameServer.HandlePlayerRequestInfo', C_BLUE);


  if not packetReader.ReadUInt32(playerId) then
  begin
    Exit;
  end;

  if not packetReader.ReadUInt8(un1) then
  begin
    Exit;
  end;

  if not TryGetPlayerById(playerId, targetPlayer) then
  begin
    Exit;
  end;

  // Always send current player for now
  res := TPacketWriter.Create;

  // Player infos
  res.WriteStr(#$57#$01);
  res.WriteUInt8(un1);
  res.WriteUInt32(playerId);
  res.Write(targetPlayer.Data.Data.playerInfo1, SizeOf(TPlayerInfo1));
  res.WriteUInt32(0); // have some more data at the end
  client.Send(res);
  res.Clear;

  // Equiped character
  res.WriteStr(#$5E#$01);
  res.WriteUInt32(playerId);
  res.Write(targetPlayer.Data.Data.equipedCharacter, SizeOf(TPlayerCharacterData));
  client.Send(res);
  res.Clear;

  // Equiped character
  res.WriteStr(#$56#$01);
  res.WriteUInt8(un1);
  res.WriteUInt32(playerId);
  res.Write(targetPlayer.Data.Data.witems, SizeOf(TPlayerEquipment));
  client.Send(res);
  res.Clear;

  // Player info 2
  res.WriteStr(#$58#$01);
  res.WriteUInt8(un1);
  res.WriteUInt32(playerId);
  res.Write(targetPlayer.Data.Data.playerInfo2, SizeOf(TPlayerInfo2));
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

procedure TGameServer.HandleLobbyRequests(const lobby: TLobby; const packetId: TCGPID; const client: TGameClient; const packetReader: TPacketReader);
var
  playerGame: TGame;
begin
  case packetId of
    TCGPID.PLAYER_MESSAGE:
    begin
      self.HandlePlayerSendMessage(client, packetReader);
    end;
    TCGPID.PLAYER_WHISPER:
    begin
      self.HandlerPlayerWhisper(client, packetReader);
    end;
    TCGPID.PLAYER_CREATE_GAME:
    begin
      lobby.HandlePlayerCreateGame(client, packetReader);
    end;
    TCGPID.PLAYER_JOIN_GAME:
    begin
      lobby.HandlePlayerJoinGame(client, packetReader);
    end;
    TCGPID.ADMIN_JOIN_GAME:
    begin
      lobby.HandleAdminJoinGame(client, packetReader);
    end;
    TCGPID.PLAYER_BUY_ITEM:
    begin
      self.HandlePlayerBuyItem(client, packetReader);
    end;
    TCGPID.PLAYER_REQUEST_IDENTITY:
    begin
      self.HandlePlayerRequestIdentity(client, packetReader);
    end;
    TCGPID.PLAYER_REQUEST_SERVERS_LIST:
    begin
      self.HandlePlayerRequestServerList(client, packetReader);
    end;
    TCGPID.PLAYER_UPGRADE:
    begin
      self.HandlePlayerUpgrade(client, packetReader);
    end;
    TCGPID.PLAYER_NOTICE:
    begin
      self.HandlePlayerNotice(client, packetReader);
    end;
    TCGPID.PLAYER_ENTER_GRAND_PRIX:
    begin
      self.HandlePlayerEnterGrandPrix(client, packetReader);
    end;
    TCGPID.PLAYER_LEAVE_GRAND_PRIX:
    begin
      self.HandlePlayerLeaveGrandPrix(client, packetReader);
    end;
    TCGPID.PLAYER_JOIN_MULTIPLAYER_GAME_LIST:
    begin
      self.HandlePlayerJoinMultiplayerGamesList(client, packetReader);
    end;
    TCGPID.PLAYER_LEAVE_MULTIPLAYER_GAME_LIST:
    begin
      self.HandlePlayerLeaveMultiplayerGamesList(client, packetReader);
    end;
    TCGPID.PLAYER_REQUEST_MESSENGER_LIST:
    begin
      self.HandlePlayerRequestMessengerList(client, packetReader);
    end;
    TCGPID.PLAYER_GM_COMMAND:
    begin
      self.HandlePlayerGMCommand(client, packetReader);
    end;
    TCGPID.PLAYER_OPEN_RARE_SHOP:
    begin
      self.HandlePlayerOpenRareShop(client, packetReader);
    end;
    TCGPID.PLAYER_UN_00EB:
    begin
      self.HandlePlayerUnknow00EB(client, packetReader);
    end;
    TCGPID.PLAYER_OPEN_SCRATCHY_CARD:
    begin
      self.HandlePlayerOpenScratchyCard(client, packetReader);
    end;
    TCGPID.PLAYER_UN_0140:
    begin
      self.HandlePlayerUnknow0140(client, packetReader);
    end;
    TCGPID.PLAYER_REQUEST_INFO:
    begin
      self.HandlePlayerRequestInfo(client, packetReader);
    end;
    TCGPID.PLAYER_PLAY_BONGDARI_SHOP:
    begin
      self.HandlePlayerPlayBongdariShop(client, packetReader);
    end;
    TCGPID.PLAYER_REQUEST_ACHIEVEMENTS:
    begin
      self.HandlePlayerRequestAchievements(client, packetReader);
    end;
    TCGPID.PLAYER_ENTER_SCRATCHY_SERIAL:
    begin
      self.HandlePlayerEnterScratchyCardSerial(client, packetReader);
    end;
    TCGPID.PLAYER_REQUEST_DAILY_QUEST:
    begin
      self.HandlePlayerRequestDailyQuest(client, packetReader);
    end;
    TCGPID.PLAYER_RECYCLE_ITEM:
    begin
      self.HandlePlayerRecycleItem(client, packetReader);
    end;
    TCGPID.PLAYER_ACCEPT_DAILY_QUEST:
    begin
      self.HandlePlayerAcceptDailyQuest(client, packetReader);
    end;
    TCGPID.PLAYER_GIVEUP_DAILY_QUEST:
    begin
      self.HandlePlayerGiveUpDailyQuest(client, packetReader);
    end;
    TCGPID.PLAYER_SEND_INVITE:
    begin
      self.HandlePlayerSendInvite(client, packetReader);
    end;
    TCGPID.PLAYER_REQUEST_DAILY_REWARD:
    begin
      self.HandlePlayerRequestDailyReward(client, packetReader);
    end;
    TCGPID.PLAYER_REQUEST_COOKIES_COUNT:
    begin
      self.HandlePlayerRequestCookiesCount(client, packetReader);
    end;
    TCGPID.PLAYER_REQUEST_INBOX:
    begin
      self.HandlePlayerRequestInbox(client, packetReader);
    end;
    TCGPID.PLAYER_REQUEST_INBOX_DETAILS:
    begin
      self.HandlePlayerRequestInboxDetails(client, packetReader);
    end;
    TCGPID.PLAYER_MOVE_INBOX_GIFT:
    begin
      self.HandlePlayerMoveInboxGift(client, packetReader);
    end;
    TCGPID.PLAYER_REQUEST_OFFLINE_PLAYER_INFO:
    begin
      self.HandlePlayerRequestOfflinePlayerInfo(client, packetReader);
    end;
    TCGPID.PLAYER_SEND_MAIL:
    begin
      self.HandlerPlayerSendMail(client, packetReader);
    end;
    TCGPID.PLAYER_DELETE_MAIL:
    begin
      self.HandlerPlayerDeleteMail(client, packetReader);
    end;
    TCGPID.PLAYER_CLEAR_QUEST:
    begin
      self.HandlerPlayerClearQuest(client, packetReader);
    end;
    TCGPID.PLAYER_SET_MASCOT_TEXT:
    begin
      self.HandlePlayerSetMascotText(client, packetReader);
    end;
    TCGPID.PLAYER_REQUEST_LOCKER:
    begin
      self.HandlePlayerRequestLocker(client, packetReader);
    end;
    TCGPID.PLAYER_REQUEST_LOCKER_ACCESS:
    begin
      self.HandlerPlayerRequestLockerAccess(client, packetReader);
    end;
    TCGPID.PLAYER_CHANGE_LOCKER_PASSWORD:
    begin
      self.HandlePlayerChangeLockerPassword(client, packetReader);
    end;
    TCGPID.PLAYER_REQUEST_LOCKER_PANGS:
    begin
      self.HandlePlayerRequestLockerPangs(client, packetReader);
    end;
    TCGPID.PLAYER_REQUEST_LOCKER_PAGE:
    begin
      self.HandlePlayerRequestLockerPage(client, packetReader);
    end;
    TCGPID.PLAYER_LOCKER_PANGS_TRANSACTION:
    begin
      self.HandlerPlayerPangsTransaction(client, packetReader);
    end;
    TCGPID.PLAYER_DELETE_ITEM:
    begin
      self.HandlePlayerDeleteItem(client, packetReader);
    end;
    TCGPID.ENTER_GRAND_PRIX_EVENT:
    begin
      lobby.HandlePlayerEnterGrandPrixEvent(client, packetReader);
    end;
    TCGPID.PLAYER_SET_ASSIST_MODE:
    begin
      self.HandlePlayerSetAssistMode(client, packetReader);
    end;
    TCGPID.PLAYER_GUILD_LIST:
    begin
      self.HandlePlayerRequestGuildList(client, packetReader);
    end;
    TCGPID.PLAYER_GUILD_CREATE:
    begin
      self.HandlePlayerCreateGuild(client, packetReader);
    end;
    TCGPID.PLAYER_GUILD_CHECK_NAME:
    begin
      self.HandlePlayerCheckGuildName(client, packetReader);
    end;
    TCGPID.PLAYER_GUILD_REQUEST_JOIN:
    begin
      self.HandlePlayerRequestJoinGuild(client, packetReader);
    end;
    TCGPID.PLAYER_GUILD_LIST_SEARCH:
    begin
      self.HandlePlayerRequestGuildListSearch(client, packetReader);
    end;
    TCGPID.PLAYER_CHAR_MASTERY:
    begin
      self.HandlePlayerCharMastery(client, packetReader);
    end
    else begin
      try
        playerGame := lobby.GetPlayerGame(client);
        self.HandleGameRequests(playerGame, packetId, client, packetReader);
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

procedure TGameServer.HandleGameRequests(const game: TGame; const packetId: TCGPID; const client: TGameClient; const packetReader: TPacketReader);
begin
  game.HandleRequests(game, packetId, client, packetReader);
end;

procedure TGameServer.OnReceiveClientData(const client: TGameClient; const packetReader: TPacketReader);
var
  player: TGameServerPlayer;
  packetId: TCGPID;
  playerLobby: TLobby;
begin
  self.Log('TGameServer.OnReceiveClientData', TLogType_not);
  packetReader.Log;

  player := client.Data;
  if (packetReader.Read(packetID, 2)) then
  begin
    case packetID of
      TCGPID.PLAYER_LOGIN:
      begin
        self.HandlePlayerLogin(client, packetReader);
      end;
      TCGPID.PLAYER_JOIN_LOBBY:
      begin
        self.HandlePlayerJoinLobby(client, packetReader);
      end;
      TCGPID.PLAYER_EXCEPTION:
      begin
        self.HandlerPlayerException(client, packetReader);
      end;
      TCGPID.PLAYER_REQUEST_SERVER_TIME:
      begin
        self.HandlePlayerRequestServerTime(client, packetReader);
      end
      else
      begin
        try
          playerLobby := m_lobbies.GetPlayerLobby(client);
          self.HandleLobbyRequests(playerLobby, packetId, client, packetReader);
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
procedure TGameServer.HandlerSyncServerPlayerSync(const packetReader: TPacketReader; const client: TGameClient);
var
  actionId: TSGPID;
begin
  self.Log('TGameServer.HandlerSyncServerPlayerSync', TLogType_not);
  client.Send(packetReader.GetRemainingData);
end;

procedure TGameServer.SendServerList(const packetReader: TPacketReader; const client: TGameClient);
var
  packetWriter: TPacketWriter;
begin
  Console.Log('TGameServer.SendServerList', C_BLUE);

  packetWriter := TPacketWriter.Create;
  packetWriter.WriteStr(#$9F#$00);
  packetWriter.WriteStr(packetReader.GetRemainingData);
  packetWriter.WriteStr(m_lobbies.Build);
  client.Send(packetWriter);

  packetWriter.Free;
end;

procedure TGameServer.HandleSyncServerPlayerAction(const packetReader: TPacketReader; const client: TGameClient);
var
  actionId: TSSAPID;
  buffer: RawByteString;
  d: RawByteString;
  mascot: TPlayerMascot;
begin
  self.Log('TGameServer.HandleSyncServerPlayerAction', TLogType_not);
  if packetReader.Read(actionId, 2) then
  begin
    case actionId of
      TSSAPID.SEND_LOBBIES_LIST:
      begin
        client.Send(LobbiesList);
      end;
      TSSAPID.SEND_SERVER_LIST:
      begin
        SendServerList(packetReader, client);
      end;
      TSSAPID.PLAYER_MAIN_SAVE:
      begin
        buffer := packetReader.GetRemainingData;
        client.Data.Data.Load(buffer);
        client.Data.Data.playerInfo1.ConnectionId := client.ID + 1;
        client.Send(
          WriteAction(TSGPID.PLAYER_MAIN_DATA) +
          #$00 +
          WritePStr('824.00') +
          WritePStr(ExtractFilename(ParamStr(0))) +
          client.Data.Data.ToPacketData +
          m_serverOptions.ToPacketData
        );

      end;
      TSSAPID.PLAYER_CHARACTERS:
      begin
        Console.Log('Characters');
        client.Data.Characters.Load(packetReader.GetRemainingData);
        client.Send(
          WriteAction(TSGPID.PLAYER_CHARACTERS_DATA) +
          client.Data.Characters.ToPacketData
        );
      end;
      TSSAPID.PLAYER_ITEMS:
      begin
        Console.Log('Items');
        client.Data.Items.Load(packetReader.GetRemainingData);
        client.Send(
          WriteAction(TSGPID.PLAYER_ITEMS_DATA) +
          client.Data.items.ToPacketData
        );
      end;
      TSSAPID.PLAYER_CADDIES:
      begin
        Console.Log('caddies');
        client.Data.Caddies.Load(packetReader.GetRemainingData);
        client.Send(
          WriteAction(TSGPID.PLAYER_CADDIES_DATA) +
          client.Data.Caddies.ToPacketData
        );
      end;
      TSSAPID.PLAYER_MASCOTS:
      begin
        Console.Log('mascots');
        client.Data.Mascots.Load(packetReader.GetRemainingData);

        console.WriteDump(
          WriteAction(TSGPID.PLAYER_MASCOTS_DATA) +
          client.Data.Mascots.ToPacketData
        );

        client.Send(
          WriteAction(TSGPID.PLAYER_MASCOTS_DATA) +
          client.Data.Mascots.ToPacketData
        );
      end;
      TSSAPID.PLAYER_COOKIES:
      begin
        Console.Log('cookies');
        packetReader.ReadInt64(client.Data.Cookies);
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

procedure TGameServer.RegisterServer;
var
  res: TPacketWriter;
begin
  res := TPacketWriter.Create;
  res.WriteUInt16(0);
  res.WriteUInt8(2); // Login server
  res.WritePStr(m_name);
  res.WriteInt32(m_port);
  res.WritePStr(m_host);
  self.Sync(res);
  res.Free;
end;

procedure TGameServer.OnConnect(sender: TObject);
begin
  self.Log('TGameServer.OnConnect', TLogType_not);
end;

procedure TGameServer.OnReceiveSyncData(const packetReader: TPacketReader);
var
  packetId: TSSPID;
  playerUID: TPlayerUID;
  client: TGameClient;
begin
  self.Log('TLoginServer.OnReceiveSyncData', TLogType_not);
  if not (packetReader.Read(packetID, 2)) then
  begin
    Exit;
  end;

  packetReader.ReadUInt32(playerUID.id);
  packetReader.ReadPStr(playerUID.login);

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
    TSSPID.PLAYER_SYNC:
    begin
      self.HandlerSyncServerPlayerSync(packetReader, client);
    end;
    TSSPID.PLAYER_ACTION:
    begin
      self.HandleSyncServerPlayerAction(packetReader, client);
    end;
    else
    begin
      self.Log(Format('Unknow packet Id %x', [Word(packetID)]), TLogType_err);
    end;
  end;
end;

procedure TGameServer.SendToGame(const client: TGameClient; data: RawByteString);
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

procedure TGameServer.SendToGame(const client: TGameClient; data: TPacket);
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
  if not (game.Id = $FFFF) then
  begin
    game.Send(data);
  end;
end;

procedure TGameServer.SendToLobby(const client: TGameClient; data: RawByteString);
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

procedure TGameServer.SendToLobby(const client: TGameClient; data: TPacket);
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

procedure TGameServer.SavePlayer(const client: TGameClient);
var
  packetWriter: TPacketWriter;
begin
  Console.Log('TGameServer.SavePlayer', C_BLUE);

  packetWriter := TPacketWriter.Create;

  packetWriter.WriteStr(
    WriteAction(TSSAPID.PLAYER_ITEMS) + client.Data.Items.ToPacketData
  );
  self.SyncPlayerAction(client, packetWriter);
  packetWriter.Clear;

  packetWriter.WriteStr(
    WriteAction(TSSAPID.PLAYER_CHARACTERS) + client.Data.Characters.ToPacketData
  );
  self.SyncPlayerAction(client, packetWriter);
  packetWriter.Clear;

  packetWriter.WriteStr(
    WriteAction(TSSAPID.PLAYER_CADDIES) + client.Data.Caddies.ToPacketData
  );
  self.SyncPlayerAction(client, packetWriter);
  packetWriter.Clear;

  packetWriter.WriteStr(
    WriteAction(TSSAPID.PLAYER_MASCOTS) + client.Data.Mascots.ToPacketData
  );
  self.SyncPlayerAction(client, packetWriter);
  packetWriter.Clear;

  packetWriter.WriteStr(
    WriteAction(TSSAPID.PLAYER_MAIN_SAVE) + client.Data.Data.ToPacketData
  );
  self.SyncPlayerAction(client, packetWriter);
  packetWriter.Clear;

  packetWriter.Free;
end;

end.
