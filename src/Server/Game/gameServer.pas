unit GameServer;

interface

uses Client, GamePlayer, Server, ClientPacket, SysUtils;

type

  TGameClient = TClient<TGamePlayer>;

  TGameServer = class (TServer<TGamePlayer>)
    protected
    private
      procedure Init; override;
      procedure OnClientConnect(const client: TGameClient); override;
      procedure OnClientDisconnect(const client: TGameClient); override;
      procedure OnReceiveClientData(const client: TGameClient; const clientPacket: TClientPacket); override;
      procedure OnStart; override;

      procedure HandlePlayerLogin(const client: TGameClient; const clientPacket: TClientPacket);
  end;

implementation

uses Logging, PangyaPacketsDef;

procedure TGameServer.Init;
begin
  self.SetPort(7997);
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
      else
      begin
        self.Log(Format('Unknow packet Id %x', [Word(packetID)]), TLogType_err);
      end;
    end;
  end;
end;

procedure TGameServer.HandlePlayerLogin(const client: TGameClient; const clientPacket: TClientPacket);
var
  login: AnsiString;
  UID: UInt32;
  checkA: AnsiString;
  checkB: AnsiString;
  checkC: UInt32;
  clientVersion: AnsiString;
begin
  self.Log('TGameServer.HandlePlayerLogin', TLogType_not);

  login := clientPacket.GetStr;
  clientPacket.GetCardinal(UID);
  clientPacket.Skip(6);
  checkA := clientPacket.GetStr;
  clientVersion := clientPacket.GetStr;

  ClientPacket.getCardinal(checkc);
  checkc := self.Deserialize(checkc);
  self.Log(Format('check c dec : %x, %d', [checkc, checkc]));

  ClientPacket.seek(4, 1);

  checkb := ClientPacket.getStr();
  self.Log(Format('Check b  : %s', [checkb]));
end;

end.
