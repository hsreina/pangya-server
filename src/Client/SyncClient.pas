{*******************************************************}
{                                                       }
{       Pangya Server                                   }
{                                                       }
{       Copyright (C) 2015 Shad'o Soft tm               }
{                                                       }
{*******************************************************}

unit SyncClient;

interface

uses ScktComp, Buffer, ExtCtrls, CryptLib, Logging, ClientPacket;

type

  TSyncClientReadEvent = procedure (sender: TObject; const clientPacket: TClientPacket) of object;
  TSyncClientConnectEvent = procedure (sender: TObject) of object;

  TSyncClient = class (TLogging)
    protected
    private
      var m_clientSocket: TClientSocket;
      var m_buffin: TBuffer;
      var m_buffout: TBuffer;
      var m_timer: TTimer;
      var m_cryptLib: TCryptLib;
      var m_key: Byte;
      var m_haveKey: Boolean;

      var FOnRead: TSyncClientReadEvent;
      procedure TriggerOnRead(const clientPacket: TClientPacket);

      var FOnConnect: TSyncClientConnectEvent;
      procedure TriggerOnConnect;


      procedure OnTimer(Sender: TObject);

      procedure OnClientLookup(Sender: TObject; Socket: TCustomWinSocket);
      procedure OnClientConnecting(Sender: TObject; Socket: TCustomWinSocket);
      procedure OnClientConnect(Sender: TObject; Socket: TCustomWinSocket);
      procedure OnClientDisconnect(Sender: TObject; Socket: TCustomWinSocket);
      procedure OnClientRead(Sender: TObject; Socket: TCustomWinSocket);
      procedure OnClientWrite(Sender: TObject; Socket: TCustomWinSocket);
      procedure OnClientError(Sender: TObject; Socket: TCustomWinSocket; ErrorEvent: TErrorEvent; var ErrorCode: Integer);

      procedure HandleReadKey(clientPacket: TClientPacket);

    public
      constructor Create(cryptLib: TCryptLib);
      destructor Destroy; override;

      property OnRead: TSyncClientReadEvent read FOnRead write FOnRead;
      property OnConnect: TSyncClientConnectEvent read FOnConnect write FOnConnect;

      procedure SetPort(port: integer);
      procedure SetHost(host: string);
      procedure Start;
      procedure Stop;
      procedure Send(data: AnsiString); overload;
      procedure Send(data: AnsiString; encrypt: Boolean); overload;
    end;

  implementation

uses ConsolePas;

procedure TSyncClient.OnTimer(Sender: TObject);
var
  y: integer;
begin
  if m_buffout.GetLength > 0 then
  begin
    y := m_clientSocket.Socket.SendText(m_buffout.GetData);
    m_buffout.Delete(0, y);
  end;
end;

constructor TSyncClient.Create(cryptLib: TCryptLib);
begin
  m_haveKey := false;
  m_key := 3;
  m_clientSocket := TClientSocket.Create(nil);
  m_cryptLib := cryptLib;

  m_clientSocket.OnLookup := self.OnClientLookup;
  m_clientSocket.OnConnecting := self.OnClientConnecting;
  m_clientSocket.OnConnect := self.OnClientConnect;
  m_clientSocket.OnDisconnect := self.OnClientDisconnect;
  m_clientSocket.OnRead := self.OnClientRead;
  m_clientSocket.OnWrite := self.OnClientWrite;
  m_clientSocket.OnError := self.OnClientError;

  m_timer := TTimer.Create(nil);
  m_timer.OnTimer := self.OnTimer;
  m_timer.Interval := 30;
  m_buffin := TBuffer.Create;
  m_buffout := TBuffer.Create;
end;

destructor TSyncClient.Destroy;
begin
  m_timer.Free;
  m_buffin.Free;
  m_buffout.Free;
  m_clientSocket.Free;
end;

procedure TSyncClient.SetPort(port: Integer);
begin
  m_clientSocket.Port := port;
end;

procedure TSyncClient.Start;
begin
  self.Log('TSyncClient.Start', TLogType_not);
  m_clientSocket.Active := true;
  m_timer.Enabled := true;
end;

procedure TSyncClient.Stop;
begin
  self.Log('TSyncClient.Stop', TLogType_not);
  m_timer.Enabled := false;
  m_clientSocket.Active := false;
end;

procedure TSyncClient.SetHost(host: string);
begin
  m_clientSocket.Host := host;
end;

procedure TSyncClient.Send(data: AnsiString);
begin
  self.Send(data, true);
end;

procedure TSyncClient.Send(data: AnsiString; encrypt: Boolean);
begin
  self.Log('TSyncClient.Send', TLogType_not);
  if encrypt then
  begin
    m_buffout.Write(m_cryptLib.ClientEncrypt(data, m_key, 0));
  end else
  begin
    m_buffout.Write(data);
  end;
end;

procedure TSyncClient.OnClientLookup(Sender: TObject; Socket: TCustomWinSocket);
begin
  self.Log('TSyncClient.OnClientLookup', TLogType_not);
end;

procedure TSyncClient.OnClientConnecting(Sender: TObject; Socket: TCustomWinSocket);
begin
  self.Log('TSyncClient.OnClientConnecting', TLogType_not);
end;

procedure TSyncClient.OnClientConnect(Sender: TObject; Socket: TCustomWinSocket);
begin
  self.Log('TSyncClient.OnClientConnect', TLogType_not);
end;

procedure TSyncClient.OnClientDisconnect(Sender: TObject; Socket: TCustomWinSocket);
begin
  self.Log('TSyncClient.OnClientDisconnect', TLogType_not);
end;

procedure TSyncClient.HandleReadKey(clientPacket: TClientPacket);
begin
  clientPacket.Skip(4);
  if not clientPacket.ReadUInt8(m_key) then
  begin
    Console.Log('Failed to get Key', C_RED);
    Exit;
  end;
  m_haveKey := true;
end;

procedure TSyncClient.OnClientRead(Sender: TObject; Socket: TCustomWinSocket);
var
  size: integer;
  realPacketSize: UInt32;
  buffer: AnsiString;
  clientPacket: TClientPacket;
begin
  self.Log('TSyncClient.OnClientRead', TLogType_not);
  size := 0;

  m_buffin.Write(Socket.ReceiveText);

  if (m_buffin.GetLength > 2) then
  begin
    move(m_buffin.GetData[2], size, 2);
  end else
  begin
    Exit;
  end;

  realPacketSize := size + 4;
  while m_buffin.GetLength >= realPacketSize  do
  begin
    buffer := m_buffin.Read(0, realPacketSize);
    m_buffin.Delete(0, realPacketSize);


    if not m_haveKey then
    begin
      clientPacket := TClientPacket.Create(buffer);
      HandleReadKey(clientPacket);
      self.TriggerOnConnect;
    end else
    begin
      buffer := m_cryptLib.ClientDecrypt(buffer, m_key);
      clientPacket := TClientPacket.Create(buffer);
      TriggerOnRead(clientPacket);
    end;

    clientPacket.Free;

    if (m_buffin.GetLength > 2) then
    begin
      move(m_buffin.GetData[2], size, 2);
      realPacketSize := size + 4;
    end else
    begin
      Exit;
    end;
  end;
end;

procedure TSyncClient.OnClientWrite(Sender: TObject; Socket: TCustomWinSocket);
begin
  self.Log('TSyncClient.OnClientWrite', TLogType_not);
end;

procedure TSyncClient.OnClientError(Sender: TObject; Socket: TCustomWinSocket;
  ErrorEvent: TErrorEvent; var ErrorCode: Integer);
begin
  self.Log('TSyncClient.OnClientError', TLogType_not);
  ErrorCode := 0;
end;

procedure TSyncClient.TriggerOnRead(const clientPacket: TClientPacket);
begin
  if Assigned(FOnRead) then
  begin
    FOnRead(self, clientPacket);
  end;
end;

procedure TSyncClient.TriggerOnConnect;
begin
  if Assigned(FOnConnect) then
  begin
    FOnConnect(self);
  end;
end;

end.
