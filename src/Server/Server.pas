unit Server;

interface

uses ScktComp, Logging, Client, Generics.Collections, ExtCtrls, CryptLib,
  ServerClient, ClientPacket, SyncClient, defs, PacketData;

type

  {
    Base function of the servers like handling clients, receiving and decrypting packet
    and some other basic function to send back message to the game
  }
  TServer<ClientType> = class abstract (TLogging)
    private

      var m_clients: TList<TServerClient<ClientType>>;
      var m_server: TServerSocket;
      var m_timer: TTimer;
      var m_cryptLib: TCryptLib;

      procedure ServerAccept(Sender: TObject; Socket: TCustomWinSocket);
      procedure ServerRead(Sender: TObject; Socket: TCustomWinSocket);
      procedure ServerConnect(Sender: TObject; Socket: TCustomWinSocket);
      procedure ServerDisconnect(Sender: TObject; Socket: TCustomWinSocket);
      procedure ServerError(Sender: TObject; Socket: TCustomWinSocket;
        ErrorEvent: TErrorEvent; var ErrorCode: Integer);

      procedure OnTimer(Sender: TObject);

      function GetClientBySocket(Socket: TCustomWinSocket): TServerClient<ClientType>;

    protected
      procedure SetPort(port: Integer);
      procedure Init; virtual; abstract;

      procedure OnClientConnect(const client: TClient<ClientType>); virtual; abstract;
      procedure OnClientDisconnect(const client: TClient<ClientType>); virtual; abstract;
      procedure OnReceiveClientData(const client: TClient<ClientType>; const clientPacket: TClientPacket); virtual; abstract;
      procedure OnStart; virtual; abstract;

      function GetClientByUID(UID: TPlayerUID): TClient<ClientType>;

      function Write(const source; const count: UInt32): AnsiString;
      function WriteStr(str: AnsiString): AnsiString;
      function FillStr(data: AnsiString; size: UInt32; withWhat: AnsiChar): AnsiString;

      function Deserialize(value: UInt32): UInt32;
    public
      constructor Create(cryptLib: TCryptLib);
      destructor Destroy; override;

      procedure SendDebugData(data: TPacketData);

      function Start: Boolean;
    end;

  implementation

uses Buffer, ConsolePas;

constructor TServer<ClientType>.Create(cryptLib: TCryptLib);
begin
  console.Log('TServer<ClientType>.Create');
  m_cryptLib := cryptLib;
  m_timer := TTimer.Create(nil);
  m_timer.OnTimer := OnTimer;
  m_timer.Interval := 30;
  m_clients := TList<TServerClient<ClientType>>.Create;
  m_server := TServerSocket.Create(nil);
  m_server.OnAccept := ServerAccept;
  m_server.OnClientRead := ServerRead;
  m_server.OnClientConnect := ServerConnect;
  m_server.OnClientDisconnect := ServerDisconnect;
  m_server.OnClientError := ServerError;
end;

destructor TServer<ClientType>.Destroy;
begin
  inherited;
  m_timer.Destroy;
  m_clients.Destroy;
  m_server.Destroy;
end;

procedure TServer<ClientType>.SetPort(port: Integer);
begin
  Log('TServer.SetPort', TLogType.TLogType_not);
  self.m_server.Port := port;
end;

function TServer<ClientType>.Start: Boolean;
begin
  Log('TServer.Start', TLogType.TLogType_not);
  self.Init;
  try
    self.m_server.Active := true;
    m_timer.Enabled := true;
    Result := true;
    OnStart;
  except
    Result := false;
  end;
end;

procedure TServer<ClientType>.ServerAccept(Sender: TObject; Socket: TCustomWinSocket);
var
  client: TServerClient<ClientType>;
  index: Integer;
begin
  Log('TServer.serverAccept', TLogType.TLogType_not);
  if (m_clients.Count < 10) then
  begin
    client := TServerClient<ClientType>.Create(Socket, m_cryptLib);
    m_clients.Add(client);
    self.OnClientConnect(client);
  end;
end;

procedure TServer<ClientType>.ServerRead(Sender: TObject; Socket: TCustomWinSocket);
var
  client: TServerClient<ClientType>;
  packetData: AnsiString;
  buffin: TBuffer;
  buffer: AnsiString;
  size: Uint32;
  clientPacket: TClientPacket;
  realPacketSize: UInt32;
begin
  Log('TServer.serverRead', TLogType.TLogType_not);
  client := GetClientBySocket(Socket);
  size := 0;

  if client = nil then
  begin
    Exit;
  end;
  client.ReceiveData(Socket.ReceiveText);

  buffin := client.GetBuffin;

  if (buffin.GetLength > 2) then
  begin
    move(buffin.GetData[2], size, 2);
    realPacketSize := size + 4;
  end else
  begin
    Exit;
  end;

  while buffin.GetLength >= realPacketSize  do
  begin
    buffer := buffin.Read(0, realPacketSize);
    buffin.Delete(0, realPacketSize);

    buffer := m_cryptLib.ClientDecrypt(buffer, client.GetKey);

    clientPacket := TClientPacket.Create(buffer);

    OnReceiveClientData(client, clientPacket);

    clientPacket.Free;

    if (buffin.GetLength > 2) then
    begin
      move(buffin.GetData[2], size, 2);
      realPacketSize := size + 4;
    end else
    begin
      Exit;
    end;
  end;
end;

procedure TServer<ClientType>.ServerConnect(Sender: TObject; Socket: TCustomWinSocket);
begin
  Log('TServer.serverConnect', TLogType.TLogType_not);

end;

procedure TServer<ClientType>.ServerDisconnect(Sender: TObject; Socket: TCustomWinSocket);
begin
  Log('TServer.serverDisconnect', TLogType.TLogType_not);

end;

procedure TServer<ClientType>.ServerError(Sender: TObject; Socket: TCustomWinSocket; ErrorEvent: TErrorEvent; var ErrorCode: Integer);
begin
  Log('TServer.serverError', TLogType.TLogType_not);
  errorCode := 0;
end;

procedure TServer<ClientType>.OnTimer(Sender: TObject);
var
  Client: TServerClient<ClientType>;
begin
  for Client in m_clients do
  begin
    Client.HandleSend;
  end;
end;

function TServer<ClientType>.GetClientBySocket(Socket: TCustomWinSocket): TServerClient<ClientType>;
var
  Client: TServerClient<ClientType>;
begin
  for Client in m_clients do
  begin
    if client.HasSocket(socket) then
    begin
      Exit(client);
    end;
  end;
end;

function TServer<ClientType>.GetClientByUID(UID: TPlayerUID): TClient<ClientType>;
var
  Client: TServerClient<ClientType>;
begin
  for Client in m_clients do
  begin
    if client.HasUID(UID) then
    begin
      Exit(client);
    end;
  end;
end;

function TServer<ClientType>.Write(const source; const count: UInt32): AnsiString;
begin
  setlength(result, count);
  move(source, result[1], count);
end;

function TServer<ClientType>.WriteStr(str: AnsiString): AnsiString;
var
  size: UInt32;
begin
  size := Length(str);
  Result :=  Write(size, 2) + str;
end;

function TServer<ClientType>.FillStr(data: AnsiString; size: UInt32; withWhat: AnsiChar): AnsiString;
begin
  while length(data) < size do
  begin
    data := data + withWhat;
  end;
  if length(data) > size then
  begin
    setlength(data, size);
  end;
  result := data;
end;

function TServer<ClientType>.Deserialize(value: UInt32): UInt32;
begin
  Result := self.m_cryptLib.Deserialize(value);
end;

procedure TServer<ClientType>.SendDebugData(data: TPacketData);
begin
  Console.Log('SendDebugData', C_BLUE);
  Console.WriteDump(data);
  m_clients.First.Send(data);
end;

end.
