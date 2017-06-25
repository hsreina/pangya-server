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
  CryptLib, IniFiles, PacketReader, PacketWriter;

type

  TLoginClient = TClient<TLoginPlayer>;

  TLoginServer = class(TSyncableServer<TLoginPlayer>)
    protected
    private
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

      var m_host: RawByteString;
      var m_port: Integer;
      var m_name: RawByteString;

    public
      procedure Debug;
      constructor Create(cryptLib: TCryptLib);
      destructor Destroy; override;
  end;

implementation

uses Logging, PacketsDef, ConsolePas, SysUtils, defs;

constructor TLoginServer.Create(cryptLib: TCryptLib);
begin
  inherited Create('LoginServer', cryptLib);
end;

destructor TLoginServer.Destroy;
begin
  inherited;
end;

procedure TLoginServer.Init;
var
  iniFile: TIniFile;
begin
  iniFile := TIniFile.Create('../config/server.ini');

  m_port := iniFile.ReadInteger('login', 'port', 10103);
  self.SetPort(m_port);

  m_host := iniFile.ReadString('login', 'host', '127.0.0.1');;

  m_name := iniFile.ReadString('login', 'name', 'LoginServer');;

  self.SetSyncPort(
    iniFile.ReadInteger('sync', 'port', 7998)
  );

  self.setSyncHost(
    iniFile.ReadString('sync', 'host', '127.0.0.1')
  );

  iniFile.Free;
end;

procedure TLoginServer.OnClientConnect(const client: TLoginClient);
var
  player: TLoginPlayer;
begin
  self.Log('TLoginServer.OnConnectClient', TLogType_not);
  player := TLoginPlayer.Create;
  client.Data := player;
  client.Send(#$00#$0B#$00#$00#$00#$00 + UTF8Char(client.GetKey) + #$00#$00#$00#$0F#$27#$00#$00, false);
end;

procedure TLoginServer.OnClientDisconnect(const client: TLoginClient);
begin
  self.Log('TLoginServer.OnDisconnectClient', TLogType_not);
end;

procedure TLoginServer.OnStart;
begin
  self.Log('TLoginServer.OnStart', TLogType_not);
  self.StartSyncClient;
end;

procedure TLoginServer.PlayerSync(const packetReader: TPacketReader; const client: TLoginClient);
var
  playerUID: TPlayerUID;
  test: RawByteString;
begin
  self.Log('TLoginServer.PlayerSync', TLogType_not);
  // Then forward the data
  client.Send(packetReader.GetRemainingData);
end;

procedure TLoginServer.ServerPlayerAction(const packetReader: TPacketReader; const client: TLoginClient);
var
  actionId: TSSAPID;
begin
  self.Log('TLoginServer.PlayerSync', TLogType_not);
  if packetReader.Read(actionId, 2) then
  begin
    case actionId of
      TSSAPID.SEND_SERVER_LIST:
      begin
        //client.Send(ServersList);
      end;
      else
      begin
        self.Log(Format('Unknow action Id %x', [Word(actionId)]), TLogType_err);
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
  self.Log('TLoginServer.OnConnect', TLogType_not);
end;

procedure TLoginServer.OnReceiveSyncData(const packetReader: TPacketReader);
var
  packetId: TSSPID;
  playerUID: TPlayerUID;
  client: TLoginClient;
begin
  self.Log('TLoginServer.OnReceiveSyncData', TLogType_not);
  if (packetReader.Read(packetID, 2)) then
  begin

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
        self.PlayerSync(packetReader, client);
      end;
      TSSPID.PLAYER_ACTION:
      begin
        self.ServerPlayerAction(packetReader, client);
      end;
      else
      begin
        self.Log(Format('Unknow packet Id %x', [Word(packetID)]), TLogType_err);
      end;
    end;
  end;
end;

procedure TLoginServer.OnReceiveClientData(const client: TLoginClient; const packetReader: TPacketReader);
var
  packetId: TCLPID;
begin
  self.Log('TLoginServer.OnReceiveClientData', TLogType_not);

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
      self.Log('CLPID_PLAYER_RECONNECT', TLogType.TLogType_not);
      self.HandlePlayerReconnect(client, packetReader);
    end
    else
    begin
      self.Log(Format('Unknow packet Id %x', [Word(packetID)]), TLogType_err);
    end;
  end;
end;

procedure TLoginServer.OnConnectSuccess(sender: TObject);
begin
  Console.Log('TLoginServer.OnConnectSuccess', C_BLUE);
  self.RegisterServer;
end;

procedure TLoginServer.Sync(const client: TLoginClient; const packetReader: TPacketReader);
begin
  self.Log('TLoginServer.Sync', TLogType.TLogType_not);
  self.Sync(#$01#$00 + write(client.UID.id, 4) + WritePStr(client.UID.login) + packetReader.ToStr);
end;

procedure TLoginServer.RegisterServer;
var
  res: TPacketWriter;
begin
  res := TPacketWriter.Create;
  res.WriteUInt16(0);
  res.WriteUInt8(1); // Login server
  res.WritePStr(m_name);
  res.WriteInt32(m_port);
  res.WritePStr(m_host);
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
  self.Log('TLoginServer.HandleConfirmNickname', TLogType_not);
  packetReader.Log;
  // this code will be send by the client to the game server
  client.Send(#$03#$00#$00#$00#$00#$00 + WritePStr('1f766c8'));
end;

procedure TLoginServer.HandlePlayerReconnect(const client: TLoginClient; const packetReader: TPacketReader);
var
  userLogin, token: RawByteString;
  un: UInt32;
begin
  Console.Log('TLoginServer.HandlePlayerReconnect', C_BLUE);

  packetReader.ReadPStr(userLogin);
  packetReader.ReadUInt32(un);
  packetReader.ReadPStr(token);

  console.Log(String.Format('userLogin %s', [userLogin]));
  console.Log(String.Format('un %d', [un]));
  console.Log(String.Format('token %s', [token]));

  console.Log('should implement that', C_ORANGE);
end;

procedure TLoginServer.Debug;
begin
  self.Sync('cool');
end;

end.
