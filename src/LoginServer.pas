unit LoginServer;

interface

uses Server, Client, LoginClient, LoginPlayer, ClientPacket;

type

  TLoginClient = TClient<TLoginPlayer>;

  TLoginServer = class(TServer<TLoginPlayer>)
    protected
    private
      procedure Init; override;
      procedure OnClientConnect(const client: TLoginClient); override;
      procedure OnClientDisconnect(const client: TLoginClient); override;
      procedure OnReceiveClientData(const client: TLoginClient; const clientPacket: TClientPacket); override;

      function ServersList: AnsiString;
      procedure LogInPlayer(const client: TLoginClient);

      procedure HandlePlayerLogin(const client: TLoginClient; const clientPacket: TClientPacket);
      procedure HandleServerSelect(const client: TLoginClient; const clientPacket: TClientPacket);
      procedure HandleConfirmNickname(const client: TLoginClient; const clientPacket: TClientPacket);
      procedure HandleSetNickname(const client: TLoginClient; const clientPacket: TClientPacket);
      procedure HandleSelectCharacter(const client: TLoginClient; const clientPacket: TClientPacket);
    public
  end;

implementation

uses Logging, PangyaPacketsDef, ConsolePas, SysUtils;

procedure TLoginServer.Init;
begin
  self.SetPort(10103);
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

function TLoginServer.ServersList: AnsiString;
var
  port: UInt32;
begin
  port := 7997;
  Result :=
    #$02#$00 +
    #$01 +
    fillStr('server name', 16, #$00) +
    #$00#$00#$00#$00 +
    #$00#$00#$00#$00 +
    #$00#$00#$00#$00 +
    #$00#$00#$00#$00 +
    #$00#$00#$00#$00 +
    #$00#$00#$00#$00 +
    #$7F#$00#$00#$01 + // unique ID?
    #$40#$06#$00#$00 +
    #$45#$00#$00#$00 +
    fillStr('127.0.0.1', 15, #$00) +
    #$00#$00#$00 +
    Write(port, 2) +
    #$00#$00#$00 +
    #$08#$00#$00 +
    #$08 + // Wings
    #$00#$00#$00#$00#$00#$00#$00#$64#$00#$00#$00 +
    #$03 + // icon
    #$00;
end;

procedure TLoginServer.OnReceiveClientData(const client: TLoginClient; const clientPacket: TClientPacket);
var
  player: TLoginPlayer;
  packetId: TCLPID;
begin
  self.Log('TLoginServer.OnReceiveClientData', TLogType_not);
  player := client.Data;
  if (clientPacket.getBuffer(packetID, 2)) then
  begin
    case packetID of
      CLPID_PLAYER_LOGIN:
      begin
        self.HandlePlayerLogin(client, clientPacket);
      end;
      CLPID_PLAYER_SELECT_SERVER:
      begin
        self.HandleServerSelect(client, clientPacket);
      end;
      CLPID_PLAYER_SET_NICKNAME:
      begin
        self.HandleSetNickname(client, clientPacket);
      end;
      CLPID_PLAYER_CONFIRM:
      begin
        self.HandleConfirmNickname(client, clientPacket);
      end;
      CLPID_PLAYER_SELECT_CHARCTER:
      begin
        self.HandleSelectCharacter(client, clientPacket);
      end;
      else
      begin
        self.Log(Format('Unknow packet Id %x', [Word(packetID)]), TLogType_err);
      end;
    end;
  end;
end;

procedure TLoginServer.HandlePlayerLogin(const client: TLoginClient; const clientPacket: TClientPacket);
var
  login: AnsiString;
  password: AnsiString;
begin
  self.Log('TLoginServer.HandlePlayerLogin', TLogType_not);

  clientPacket.Log;

  login := clientPacket.GetStr;
  password := clientPacket.GetStr;

  self.Log(Format('Login : %s', [login]));
  self.Log(Format('Password : %s', [password]));

  client.Send(#$0F#$00#$01 + writeStr(login));

  // New player
  client.Send(#$01#$00#$D8#$FF#$FF#$FF#$FF#$00#$00);

  // Invalid Login/password
  //client.Send(#$01#$00#$E2#$72#$D2#$4D#$00#$00#$00);

  // Or logIn player
  //LogInPlayer(client);
end;

procedure TLoginServer.HandleServerSelect(const client: TLoginClient; const clientPacket: TClientPacket);
begin
  self.Log('TLoginServer.HandleConfirmNickname', TLogType_not);
  clientPacket.Log;
  // A code o_O
  client.Send(#$03#$00#$00#$00#$00#$00 + WriteStr('1f766c8'))
end;


procedure TLoginServer.HandleSetNickname(const client: TLoginClient; const clientPacket: TClientPacket);
var
  nickname: AnsiString;
begin
  self.Log('TLoginServer.HandleConfirmNickname', TLogType_not);
  nickname := clientPacket.GetStr;
  self.Log(Format('nickname : %s', [nickname]));
  client.Send(#$06#$00 + WriteStr(nickname));

  // Character selection ?
  client.Send(#$01#$00#$D9#$00#$00);
end;


procedure TLoginServer.HandleConfirmNickname(const client: TLoginClient; const clientPacket: TClientPacket);
var
  nickname: AnsiString;
begin
  self.Log('TLoginServer.HandleConfirmNickname', TLogType_not);
  nickname := clientPacket.GetStr;
  self.Log(Format('nickname %s', [nickname]));

  // nickname already in use
  //client.Send(#$0E#$00#$0B#$00#$00#$00#$21#$D2#$4D#$00);

  // nickname is available
  client.Send(#$0E#$00#$00#$00#$00#$00 + WriteStr(nickname));
end;

procedure TLoginServer.HandleSelectCharacter(const client: TLoginClient; const clientPacket: TClientPacket);
var
  characterId: UInt32;
  hairColor: UInt16;
begin
  self.Log('TLoginServer.HandleConfirmNickname', TLogType_not);
  clientPacket.Log;

  clientPacket.GetCardinal(characterId);
  clientPacket.GetWord(hairColor);

  self.Log(Format('chracterId : %x', [characterId]));
  self.Log(Format('hairColor : %x', [hairColor]));

  // validate character
  client.Send(#$11#$00#$00);

  LogInPlayer(client);
end;

procedure TLoginServer.LogInPlayer(const client: TLoginClient);
begin
  // Another code
  client.Send(#$10#$00 + WriteStr('178d22e'));

  // Servers list
  client.Send(ServersList);
end;

end.
