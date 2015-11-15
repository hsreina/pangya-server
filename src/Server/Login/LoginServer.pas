unit LoginServer;

interface

uses Client, LoginPlayer, ClientPacket, SyncClient, Server, SyncableServer;

type

  TLoginClient = TClient<TLoginPlayer>;

  TLoginServer = class(TSyncableServer<TLoginPlayer>)
    protected
    private
      procedure Init; override;
      procedure OnClientConnect(const client: TLoginClient); override;
      procedure OnClientDisconnect(const client: TLoginClient); override;
      procedure OnReceiveClientData(const client: TLoginClient; const clientPacket: TClientPacket); override;
      procedure OnReceiveSyncData(const clientPacket: TClientPacket); override;
      procedure OnStart; override;

      procedure Sync(const client: TLoginClient; const clientPacket: TClientPacket); overload;
      procedure PlayerSync(const clientPacket: TClientPacket; const client: TLoginClient);
      procedure ServerPlayerAction(const clientPacket: TClientPacket; const client: TLoginClient);

      function ServersList: AnsiString;

      procedure HandlePlayerServerSelect(const client: TLoginClient; const clientPacket: TClientPacket);
      procedure HandlePlayerLogin(const client: TLoginClient; const clientPacket: TClientPacket);
    public
      procedure Debug;
  end;

implementation

uses Logging, PangyaPacketsDef, ConsolePas, SysUtils, defs;

procedure TLoginServer.Init;
begin
  self.SetPort(10103);
  self.SetSyncPort(7998);
  self.setSyncHost('127.0.0.1');
end;

procedure TLoginServer.OnClientConnect(const client: TLoginClient);
var
  player: TLoginPlayer;
begin
  self.Log('TLoginServer.OnConnectClient', TLogType_not);
  player := TLoginPlayer.Create;
  client.Data := player;
  client.Send(#$00#$0B#$00#$00#$00#$00 + ansichar(client.GetKey) + #$00#$00#$00#$0F#$27#$00#$00, false);
end;

procedure TLoginServer.OnClientDisconnect(const client: TLoginClient);
var
  player: TLoginPlayer;
begin
  self.Log('TLoginServer.OnDisconnectClient', TLogType_not);
  player := client.Data;
  if not (player = nil) then
  begin
    player.Free;
    player := nil;
  end;
end;

procedure TLoginServer.OnStart;
begin
  self.Log('TLoginServer.OnStart', TLogType_not);
  self.StartSyncClient;
end;

function TLoginServer.ServersList: AnsiString;
var
  port: UInt32;
  packet: TClientPacket;
begin
  port := 7997;

  packet := TClientPacket.Create;

  packet.WriteStr(
    #$02#$00 +
    #$01 // Number of servers
  );

  packet.WriteStr('server name', 16, #$00);

  packet.WriteStr(
    #$00#$00#$00#$00 +
    #$00#$00#$00#$00 +
    #$00#$00#$00#$00 +
    #$00#$00#$00#$00 +
    #$00#$00#$00#$00 +
    #$00#$00#$00#$00 +
    #$7F#$00#$00#$01 + // unique ID?
    #$40#$06#$00#$00 +
    #$45#$00#$00#$00
  );

  packet.WriteStr('127.0.0.1', 15, #$00);

  packet.WriteStr(#$00#$00#$00);

  packet.Write(port, 2);

  packet.WriteStr(
    #$00#$00#$00 +
    #$08#$00#$00 +
    #$08 + // Wings
    #$00#$00#$00#$00#$00#$00#$00#$64#$00#$00#$00 +
    #$03 + // icon
    #$00
  );

  Result := packet.ToStr;

  Console.WriteDump(Result);

  packet.Free;
end;

procedure TLoginServer.PlayerSync(const clientPacket: TClientPacket; const client: TLoginClient);
var
  playerUID: TPlayerUID;
  test: AnsiString;
begin
  self.Log('TLoginServer.PlayerSync', TLogType_not);
  // Then forward the data
  client.Send(clientPacket.GetRemainingData);
end;

procedure TLoginServer.ServerPlayerAction(const clientPacket: TClientPacket; const client: TLoginClient);
var
  actionId: TSSAPID;
begin
  self.Log('TLoginServer.PlayerSync', TLogType_not);
  if clientPacket.Read(actionId, 2) then
  begin
    case actionId of
      SSAPID_SEND_SERVER_LIST:
      begin
        client.Send(ServersList);
      end;
      else
      begin
        self.Log(Format('Unknow action Id %x', [Word(actionId)]), TLogType_err);
      end;
    end;
  end;
end;

procedure TLoginServer.OnReceiveSyncData(const clientPacket: TClientPacket);
var
  packetId: TSSPID;
  playerUID: TPlayerUID;
  client: TLoginClient;
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

procedure TLoginServer.OnReceiveClientData(const client: TLoginClient; const clientPacket: TClientPacket);
var
  player: TLoginPlayer;
  packetId: TCLPID;
begin
  self.Log('TLoginServer.OnReceiveClientData', TLogType_not);
  player := client.Data;
  if (clientPacket.Read(packetID, 2)) then
  begin
    case packetID of
      CLPID_PLAYER_LOGIN:
      begin
        self.HandlePlayerLogin(client, clientPacket);
      end;
      CLPID_PLAYER_SELECT_SERVER:
      begin
        self.HandlePlayerServerSelect(client, clientPacket);
      end;
      CLPID_PLAYER_SET_NICKNAME:
      begin
        self.Sync(client, clientPacket);
      end;
      CLPID_PLAYER_CONFIRM:
      begin
        self.Sync(client, clientPacket);
      end;
      CLPID_PLAYER_SELECT_CHARCTER:
      begin
        self.Sync(client, clientPacket);
      end;
      CLPID_PLAYER_RECONNECT: // ??
      begin
        self.Log('CLPID_PLAYER_RECONNECT', TLogType.TLogType_not);
      end
      else
      begin
        self.Log(Format('Unknow packet Id %x', [Word(packetID)]), TLogType_err);
      end;
    end;
  end;
end;

procedure TLoginServer.Sync(const client: TLoginClient; const clientPacket: TClientPacket);
begin
  self.Log('TLoginServer.Sync', TLogType.TLogType_not);
  self.Sync(#$01 + #$01#$00 + write(client.UID.id, 4) + writeStr(client.UID.login) + clientPacket.ToStr);
end;

procedure TLoginServer.HandlePlayerLogin(const client: TLoginClient; const clientPacket: TClientPacket);
var
  login: AnsiString;
begin
  clientPacket.ReadPStr(login);
  client.UID.login := login;
  client.UID.id := 0;
  self.Sync(client, clientPacket);
end;

procedure TLoginServer.HandlePlayerServerSelect(const client: TLoginClient; const clientPacket: TClientPacket);
begin
  self.Log('TLoginServer.HandleConfirmNickname', TLogType_not);
  clientPacket.Log;
  // this code will be send by the client to the game server
  client.Send(#$03#$00#$00#$00#$00#$00 + WriteStr('1f766c8'))
end;

procedure TLoginServer.Debug;
begin
  self.Sync('cool');
end;

end.
