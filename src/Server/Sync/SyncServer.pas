unit SyncServer;

interface

uses Client, SyncUser, Server, ClientPacket, CryptLib, SysUtils, defs,
  Database;

type

  TSyncClient = TClient<TSyncUser>;

  TSyncServer = class (TServer<TSyncUser>)
    protected
    private

      m_database: TDatabase;

      procedure Init; override;
      procedure OnClientConnect(const client: TSyncClient); override;
      procedure OnClientDisconnect(const client: TSyncClient); override;
      procedure OnReceiveClientData(const client: TSyncClient; const clientPacket: TClientPacket); override;
      procedure OnStart; override;

      procedure SendToGame(const client: TSyncClient; const playerUID: TPlayerUID; const data: AnsiString);
      procedure PlayerAction(const client: TSyncClient; const playerUID: TPlayerUID; const data: AnsiString);

      procedure SyncLoginPlayer(const client: TSyncClient; const clientPacket: TClientPacket);
      procedure HandlePlayerLogin(const client: TSyncClient; const clientPacket: TClientPacket; const playerUID: TPlayerUID);
      procedure LoginPlayer(const client: TSyncClient; const playerUID: TPlayerUID);


    public
      constructor Create(cryptLib: TCryptLib);
      destructor Destroy; override;
  end;

implementation

uses Logging, PangyaPacketsDef, ConsolePas;

constructor TSyncServer.Create(cryptLib: TCryptLib);
begin
  inherited;

  m_database := TDatabase.Create;

end;

destructor TSyncServer.Destroy;
begin
  inherited;
end;

procedure TSyncServer.Init;
begin
  self.SetPort(7998);
  m_database.Init;
end;

procedure TSyncServer.OnClientConnect(const client: TSyncClient);
begin
  self.Log('TSyncServer.OnClientConnect', TLogType_not);
  client.UID := 'Sync';
end;

procedure TSyncServer.OnClientDisconnect(const client: TSyncClient);
begin
  self.Log('TSyncServer.OnClientDisconnect', TLogType_not);
end;

procedure TSyncServer.OnStart;
begin
  self.Log('TSyncServer.OnStart', TLogType_not);
end;

procedure TSyncServer.SendToGame(const client: TSyncClient; const playerUID: TPlayerUID; const data: AnsiString);
begin
  self.Log('TSyncServer.SendToGame', TLogType_not);
  client.Send(#$01#$00 + WriteStr(playerUID) + data);
end;

procedure TSyncServer.PlayerAction(const client: TSyncClient; const playerUID: TPlayerUID; const data: AnsiString);
begin
  self.Log('TSyncServer.PlayerAction', TLogType_not);
  client.Send(#$02#$00 + WriteStr(playerUID) + data);
end;

procedure TSyncServer.HandlePlayerLogin(const client: TSyncClient; const clientPacket: TClientPacket; const playerUID: TPlayerUID);
var
  login: AnsiString;
  md5Password: AnsiString;
begin
  self.Log('TSyncServer.HandlePlayerLogin', TLogType_not);
  login := clientPacket.GetStr;
  self.Log(Format('login : %s', [login]));
  md5Password := clientPacket.GetStr;
  self.Log(Format('password : %s', [md5Password]));


  //SendToGame(client, playerUID, #$0F#$00#$01 + writeStr(login));

  // New Player
  //SendToGame(client, playerUID, #$01#$00#$D8#$FF#$FF#$FF#$FF#$00#$00);

  //client.Send(#$0F#$00#$01 + writeStr(login));

  // New player
  //client.Send(#$01#$00#$D8#$FF#$FF#$FF#$FF#$00#$00);

  // Invalid Login/password
  //SendToGame(client, playerUID, #$01#$00#$E2#$72#$D2#$4D#$00#$00#$00);

  self.LoginPlayer(client, playerUID);
end;

procedure TSyncServer.LoginPlayer(const client: TSyncClient; const playerUID: TPlayerUID);
begin
  self.Log('TSyncServer.LoginPlayer', TLogType_not);
  SendToGame(client, playerUID, #$10#$00 + WriteStr('178d22e'));

  // Sender server list
  PlayerAction(client, playerUID, #$01#$00);
end;

procedure TSyncServer.SyncLoginPlayer(const client: TSyncClient; const clientPacket: TClientPacket);
var
  playerUID: TPlayerUID;
  packetId: TCLPID;
begin
  self.Log('TSyncServer.SyncLoginPlayer', TLogType_not);

  playerUID := clientPacket.GetStr;

  self.Log(Format('Player UID : %s', [playerUID]));

  if clientPacket.GetBuffer(packetId, 2) then
  begin
    case packetId of
      CLPID_PLAYER_LOGIN:
      begin
        HandlePlayerLogin(client, clientPacket, playerUID);
      end;
      else
      begin
        self.Log(Format('Unknow packet Id %x', [Word(packetID)]), TLogType_err);
      end;
    end;
  end;

end;

procedure TSyncServer.OnReceiveClientData(const client: TSyncClient; const clientPacket: TClientPacket);
var
  packetId: TSSPID;
begin
  self.Log('TSyncServer.OnReceiveClientData', TLogType_not);

  if (clientPacket.getBuffer(packetID, 2)) then
  begin
    case packetID of
      SSPID_LOGIN_PLAYER_SYNC:
      begin
        self.SyncLoginPlayer(client, clientPacket);
      end;
      else
      begin
        self.Log(Format('Unknow packet Id %x', [Word(packetID)]), TLogType_err);
      end;
    end;
  end;

end;

end.
