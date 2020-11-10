{*******************************************************}
{                                                       }
{       Pangya Server                                   }
{                                                       }
{       Copyright (C) 2015 Shad'o Soft tm               }
{                                                       }
{*******************************************************}

unit LoginServer;

interface

uses Client, LoginPlayer, SyncClient, Server, SyncableServer,
  CryptLib, PacketReader, PacketWriter, LoginServerConfiguration,
  LoggerInterface;

type

  TLoginClient = TClient<TLoginPlayer>;

  TLoginServer = class(TSyncableServer<TLoginPlayer>)
    protected
    private
      var m_serverConfiguration: TLoginServerConfiguration;

      procedure Init; override;
      procedure OnClientConnect(const client: TLoginClient); override;
      procedure OnClientDisconnect(const client: TLoginClient); override;
      procedure OnReceiveClientData(const client: TLoginClient; const packetReader: TPacketReader); override;

      procedure OnReceiveSyncData(const packetReader: TPacketReader); override;
      procedure OnConnect(sender: TObject); override;

      procedure OnDestroyClient(const client: TLoginClient); override;
      procedure OnStart; override;

      procedure OnConnectSuccess(sender: TObject);  override;
      procedure Sync(const client: TLoginClient; const packetReader: TPacketReader); overload;
      procedure PlayerSync(const packetReader: TPacketReader; const client: TLoginClient);
      procedure ServerPlayerAction(const packetReader: TPacketReader; const client: TLoginClient);

      procedure HandlePlayerServerSelect(const client: TLoginClient; const packetReader: TPacketReader);
      procedure HandlePlayerReconnect(const client: TLoginClient; const packetReader: TPacketReader);
      procedure HandlePlayerLogin(const client: TLoginClient; const packetReader: TPacketReader);

      procedure RegisterServer;
    public
      procedure Debug;
      constructor Create(const ALogger: ILoggerInterface; const ACryptLib: TCryptLib);
      destructor Destroy; override;
  end;

implementation

uses PacketsDef, SysUtils, defs;

constructor TLoginServer.Create(const ALogger: ILoggerInterface; const ACryptLib: TCryptLib);
begin
  inherited Create(ALogger, 'LoginServer', ACryptLib);
  m_serverConfiguration := TLoginServerConfiguration.Create;
end;

destructor TLoginServer.Destroy;
begin
  m_serverConfiguration.Free;
  inherited;
end;

procedure TLoginServer.Init;
begin
  self.SetPort(m_serverConfiguration.Port);
  self.SetSyncPort(m_serverConfiguration.SyncServerPort);
  self.setSyncHost(m_serverConfiguration.SyncServerHost);
end;

procedure TLoginServer.OnClientConnect(const client: TLoginClient);
var
  player: TLoginPlayer;
begin
  m_logger.Info('TLoginServer.OnConnectClient');
  player := TLoginPlayer.Create;
  client.Data := player;
  client.Send(#$00#$0B#$00#$00#$00#$00 + UTF8Char(client.GetKey) + #$00#$00#$00#$0F#$27#$00#$00, false);
end;

procedure TLoginServer.OnClientDisconnect(const client: TLoginClient);
begin
  m_logger.Debug('TLoginServer.OnDisconnectClient');
end;

procedure TLoginServer.OnStart;
begin
  m_logger.Info('TLoginServer.OnStart');
  self.StartSyncClient;
end;

procedure TLoginServer.PlayerSync(const packetReader: TPacketReader; const client: TLoginClient);
var
  playerUID: TPlayerUID;
  test: RawByteString;
begin
  m_logger.Info('TLoginServer.PlayerSync');
  // Then forward the data
  client.Send(packetReader.GetRemainingData);
end;

procedure TLoginServer.ServerPlayerAction(const packetReader: TPacketReader; const client: TLoginClient);
var
  actionId: TSSAPID;
begin
  m_logger.Info('TLoginServer.PlayerSync');
  if packetReader.Read(actionId, 2) then
  begin
    case actionId of
      TSSAPID.SEND_SERVER_LIST:
      begin
        //client.Send(ServersList);
      end;
      else
      begin
        m_logger.Error('Unknow action Id %x', [Word(actionId)]);
      end;
    end;
  end;
end;

procedure TLoginServer.OnDestroyClient(const client: TLoginClient);
begin
  client.Data.Free;
end;

procedure TLoginServer.OnConnect(sender: TObject);
begin
  m_logger.Info('TLoginServer.OnConnect');
end;

procedure TLoginServer.OnReceiveSyncData(const packetReader: TPacketReader);
var
  packetId: TSSPID;
  playerUID: TPlayerUID;
  client: TLoginClient;
begin
  m_logger.Info('TLoginServer.OnReceiveSyncData');
  if (packetReader.Read(packetID, 2)) then
  begin

    packetReader.ReadUInt32(playerUID.id);
    packetReader.ReadPStr(playerUID.login);

    client := self.GetClientByUID(playerUID);
    if client = nil then
    begin
      m_logger.Error('something went wrong client not found');
      Exit;
    end;

    if client.UID.id = 0 then
    begin
      client.UID.id := playerUID.id;
    end;
    m_logger.Debug('player UID : %s/%d', [playerUID.login, playerUID.id]);

    case packetId of
      TSSPID.PLAYER_SYNC:
      begin
        self.PlayerSync(packetReader, client);
      end;
      TSSPID.PLAYER_ACTION:
      begin
        self.ServerPlayerAction(packetReader, client);
      end;
      else
      begin
        m_logger.Error('Unknow packet Id %x', [Word(packetID)]);
      end;
    end;
  end;
end;

procedure TLoginServer.OnReceiveClientData(const client: TLoginClient; const packetReader: TPacketReader);
var
  packetId: TCLPID;
begin
  m_logger.Info('TLoginServer.OnReceiveClientData');

  if not (packetReader.Read(packetID, 2)) then
  begin
    Exit;
  end;

  case packetID of
    TCLPID.PLAYER_LOGIN:
    begin
      self.HandlePlayerLogin(client, packetReader);
    end;
    TCLPID.PLAYER_SELECT_SERVER:
    begin
      self.HandlePlayerServerSelect(client, packetReader);
    end;
    TCLPID.PLAYER_SET_NICKNAME:
    begin
      self.Sync(client, packetReader);
    end;
    TCLPID.PLAYER_CONFIRM:
    begin
      self.Sync(client, packetReader);
    end;
    TCLPID.PLAYER_SELECT_CHARCTER:
    begin
      self.Sync(client, packetReader);
    end;
    TCLPID.PLAYER_RECONNECT: // ??
    begin
      m_logger.Debug('CLPID_PLAYER_RECONNECT');
      self.HandlePlayerReconnect(client, packetReader);
    end
    else
    begin
      m_logger.Error('Unknow packet Id %x', [Word(packetID)]);
    end;
  end;
end;

procedure TLoginServer.OnConnectSuccess(sender: TObject);
begin
  m_logger.Info('TLoginServer.OnConnectSuccess');
  self.RegisterServer;
end;

procedure TLoginServer.Sync(const client: TLoginClient; const packetReader: TPacketReader);
begin
  m_logger.Info('TLoginServer.Sync');
  self.Sync(#$01#$00 + write(client.UID.id, 4) + WritePStr(client.UID.login) + packetReader.ToStr);
end;

procedure TLoginServer.RegisterServer;
var
  res: TPacketWriter;
begin
  res := TPacketWriter.Create;
  res.WriteUInt16(0);
  res.WriteUInt8(1); // Login server

  with m_serverConfiguration do
  begin
    res.WritePStr(Name);
    res.WriteUInt16(Port);
    res.WritePStr(Host);
  end;

  self.Sync(res);
  res.Free;
end;

procedure TLoginServer.HandlePlayerLogin(const client: TLoginClient; const packetReader: TPacketReader);
var
  login: RawByteString;
begin
  packetReader.ReadPStr(login);
  client.UID.login := login;
  client.UID.id := 0;
  self.Sync(client, packetReader);
end;

procedure TLoginServer.HandlePlayerServerSelect(const client: TLoginClient; const packetReader: TPacketReader);
begin
  m_logger.Info('TLoginServer.HandleConfirmNickname');
  packetReader.Log;
  // this code will be send by the client to the game server
  client.Send(#$03#$00 + #$00#$00#$00#$00 + WritePStr('1f766c8'));
end;

procedure TLoginServer.HandlePlayerReconnect(const client: TLoginClient; const packetReader: TPacketReader);
var
  userLogin, token: RawByteString;
  un: UInt32;
begin
  m_logger.Info('TLoginServer.HandlePlayerReconnect');

  packetReader.ReadPStr(userLogin);
  packetReader.ReadUInt32(un);
  packetReader.ReadPStr(token);

  m_logger.Debug('userLogin %s', [userLogin]);
  m_logger.Debug('un %d', [un]);
  m_logger.Debug('token %s', [token]);

  m_logger.Warning('should implement that');
end;

procedure TLoginServer.Debug;
begin
  self.Sync('cool');
end;

end.
