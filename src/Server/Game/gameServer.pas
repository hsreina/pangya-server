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
      procedure HandlePlayerJoinLobby(const client: TGameClient; const clientPacket: TClientPacket);
      procedure HandlePlayerBuyItem(const client: TGameClient; const clientPacket: TClientPacket);
      procedure HandlePlayerChangeEquipment(const client: TGameClient; const clientPacket: TClientPacket);
      procedure HandlePlayerUnknow0140(const client: TGameClient; const clientPacket: TClientPacket);


    public
      constructor Create(cryptLib: TCryptLib);
      destructor Destroy; override;
  end;

implementation

uses Logging, PangyaPacketsDef, ConsolePas, Buffer, utils, PacketData, defs;

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
    WriteStr('173.179.168.96'),
    false
  );
end;

procedure TGameServer.OnClientDisconnect(const client: TGameClient);
var
  player: TGamePlayer;
begin
  self.Log('TGameServer.OnDisconnectClient', TLogType_not);
  player := client.Data;
  if not (player = nil) then
  begin
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
  login := clientPacket.GetStr;
  client.UID.login := login;
  client.UID.id := 0;
  self.Sync(client, clientPacket);
end;

procedure TGameServer.HandlePlayerJoinLobby(const client: TGameClient; const clientPacket: TClientPacket);
var
  lobbyId: byte;
begin
  self.Log('TGameServer.HandlePlayerJoinLobby', TLogType_not);

  if false = clientPacket.GetByte(lobbyId) then
  begin
    Exit;
  end;

  client.Send(#$95#$00 + AnsiChar(lobbyId) + #$01#$00);
  client.Send(#$4E#$00#$01);
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
  clientPacket.GetByte(rental);
  clientPacket.GetWord(count);

  randomId := random(134775813);

  for I := 1 to count do
  begin
    clientPacket.GetBuffer(shopItem.un1, sizeof(TShopItemDesc));

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
    self.Write(client.Data.data.pangs, 8) +
    #$00#$00#$00#$00#$00#$00#$00#$00
  );

  client.Send(
    #$C8#$00 +
    self.Write(client.Data.data.pangs, 8) +
    #$C4#$09#$00#$00#$00#$00#$00#$00
  );

  // Pangs and cookies info
  client.Send(
    #$68#$00#$00#$00#$00#$00 +
    self.Write(client.Data.data.pangs, 8) +
    self.Write(client.Data.Cookies, 8)
  );

end;

procedure TGameServer.HandlePlayerChangeEquipment(const client: TGameClient; const clientPacket: TClientPacket);
var
  packetData: TPacketData;
  itemType: byte;
  IffId: UInt32;
begin
  self.Log('TGameServer.HandlePlayerChangeEquipment', TLogType_not);

  clientPacket.GetByte(itemType);

  case itemType of
    0: begin
      console.Log('character data', C_ORANGE);
      clientPacket.GetCardinal(IffId);
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
  if (clientPacket.getBuffer(packetID, 2)) then
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
      CGPID_PLAYER_BUY_ITEM:
      begin
        self.HandlePlayerBuyItem(client, clientPacket);
      end;
      CGPID_PLAYER_CHANGE_EQUIP:
      begin
        self.HandlePlayerChangeEquipment(client, clientPacket);
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
begin
  self.Log('TGameServer.PlayerSync', TLogType_not);
  // Then forward the data
  client.Send(clientPacket.GetRemainingData);
end;

// TODO: create a virtual method from that in the parent class
procedure TGameServer.ServerPlayerAction(const clientPacket: TClientPacket; const client: TGameClient);
var
  actionId: TSSAPID;
begin
  self.Log('TGameServer.PlayerSync', TLogType_not);
  if clientPacket.GetBuffer(actionId, 2) then
  begin
    case actionId of
      SSAPID_SEND_LOBBIES_LIST:
      begin
        client.Send(LobbiesList);
      end;
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
  if (clientPacket.getBuffer(packetID, 2)) then
  begin

    clientPacket.GetInteger(playerUID.id);
    playerUID.login := clientPacket.GetStr;

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
