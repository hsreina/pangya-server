{*******************************************************}
{                                                       }
{       Pangya Server                                   }
{                                                       }
{       Copyright (C) 2015 Shad'o Soft tm               }
{                                                       }
{*******************************************************}

unit Server;

interface

uses Logging, Client, Generics.Collections, ExtCtrls, CryptLib,
  ServerClient, ClientPacket, SyncClient, defs, PacketData, SysUtils,
  SerialList, IdTcpServer, IdContext, IdGlobal, IdComponent,
  IdSchedulerOfThreadPool, SyncObjs, PangyaBuffer;

type

  {
    Base function of the servers like handling clients, receiving and decrypting packet
    and some other basic function to send back message to the game
  }

  PTClientPacketHeader = ^TClientPacketHeader;
  TClientPacketHeader = packed record
    var xx: UInt8;
    var size: UInt16;
    var yy: UInt8;
  end;

  TServer<ClientType> = class abstract (TLogging)
    private

      var m_clients: TSerialList<TServerClient<ClientType>>;
      var m_server: TIdTCPServer;
      var m_idSchedulerOfThreadPool: TIdSchedulerOfThreadPool;
      var m_lock: TCriticalSection;
      var m_cryptLib: TCryptLib;

      procedure ServerOnConnect(AContext: TIdContext);
      procedure ServerOnDisconnect(AContext: TIdContext);
      procedure ServerOnExecute(AContext: TIdContext);
      procedure ServerOnException(AContext: TIdContext; AException: Exception);
      procedure ServerOnStatus(ASender: TObject; const AStatus: TIdStatus; const AStatusText: string);

      function GetClientByContext(AContext: TIdContext): TServerClient<ClientType>;
      procedure SetContextData(AContext: TIdContext; data: TObject);
      function GetContextData(AContext: TIdContext): TObject;

    protected
      procedure SetPort(port: Integer);
      procedure Init; virtual; abstract;

      procedure OnClientConnect(const client: TClient<ClientType>); virtual; abstract;
      procedure OnClientDisconnect(const client: TClient<ClientType>); virtual; abstract;
      procedure OnReceiveClientData(const client: TClient<ClientType>; const clientPacket: TClientPacket); virtual; abstract;
      procedure OnStart; virtual; abstract;
      procedure OnDestroyClient(const client: TClient<ClientType>); virtual; abstract;

      function GetClientByUID(UID: TPlayerUID): TClient<ClientType>;

      function Write(const source; const count: UInt32): AnsiString;
      function WritePStr(const str: AnsiString): AnsiString;
      function FillStr(data: AnsiString; size: UInt32; withWhat: AnsiChar): AnsiString;

      function Deserialize(value: UInt32): UInt32;

      // Should replace this by something better
      property Clients: TSerialList<TServerClient<ClientType>> read m_clients;
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
  m_lock := TCriticalSection.Create;
  m_cryptLib := cryptLib;
  m_clients := TSerialList<TServerClient<ClientType>>.Create;
  m_server := TIdTCPServer.Create(nil);

  m_idSchedulerOfThreadPool := TIdSchedulerOfThreadPool.Create(nil);
  m_idSchedulerOfThreadPool.MaxThreads := 30;
  m_idSchedulerOfThreadPool.PoolSize := 30;

  m_server.MaxConnections := 30;
  m_server.ListenQueue := 30;

  m_server.OnExecute := ServerOnExecute;
  m_server.OnConnect := ServerOnConnect;
  m_server.OnDisconnect := ServerOnDisconnect;
  m_server.OnException := ServerOnException;
  m_server.OnStatus := ServerOnStatus;

  m_server.Scheduler := m_idSchedulerOfThreadPool;
end;

destructor TServer<ClientType>.Destroy;
begin
  inherited;
  m_server.Free;
  m_idSchedulerOfThreadPool.Free;
  m_clients.Free;
  m_lock.Free;
end;

procedure TServer<ClientType>.SetPort(port: Integer);
begin
  Console.Log('TServer.SetPort', C_BLUE);
  Console.Log(Format('Port : %d', [port]));
  self.m_server.DefaultPort := port;
end;

function TServer<ClientType>.Start: Boolean;
begin
  Log('TServer.Start', TLogType.TLogType_not);
  self.Init;
  try
    m_server.Active := true;
    Result := true;
    OnStart;
  except
    Result := false;
  end;
end;

{
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

procedure TServer<ClientType>.ServerDisconnect(Sender: TObject; Socket: TCustomWinSocket);
var
  client: TServerClient<ClientType>;
begin
  Log('TServer.serverDisconnect', TLogType.TLogType_not);
  client := GetClientBySocket(Socket);
  if client = nil then
  begin
    Console.Log('Client socket not found', C_RED);
    Exit;
  end;

  self.OnClientDisconnect(client);

  m_clients.Remove(client);

  OnDestroyClient(client);
  client.Free;
end;

procedure TServer<ClientType>.ServerError(Sender: TObject; Socket: TCustomWinSocket; ErrorEvent: TErrorEvent; var ErrorCode: Integer);
begin
  Log('TServer.serverError', TLogType.TLogType_not);
  errorCode := 0;
  Socket.Close;
  Socket.free;
end;
}

{
procedure TServer<ClientType>.OnTimer(Sender: TObject);
var
  Client: TServerClient<ClientType>;
begin
  for Client in m_clients do
  begin
    Client.HandleSend;
  end;
end;
}

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

function TServer<ClientType>.WritePStr(const str: AnsiString): AnsiString;
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
var
  client: TServerClient<ClientType>;
begin
  //Console.Log('SendDebugData', C_BLUE);
  //Console.WriteDump(data);
  m_clients.First.Send(data);
  for client in m_clients do
  begin
    client.Send(data);
  end;
end;

procedure TServer<ClientType>.ServerOnConnect(AContext: TIdContext);
var
  client: TServerClient<ClientType>;
begin
  m_lock.Enter;
  Console.Log('TServer<ClientType>.ServerOnConnect');
  if (m_clients.Count >= 10) then
  begin
    Console.Log('Server full', C_RED);
    AContext.Connection.Disconnect;
    Exit;
  end;

  client := TServerClient<ClientType>.Create(AContext, m_cryptLib);
  client.ID := m_clients.Add(client);
  SetContextData(AContext, client);
  OnClientConnect(client);
  m_lock.leave;
end;

procedure TServer<ClientType>.ServerOnDisconnect(AContext: TIdContext);
var
  client: TServerClient<ClientType>;
begin
  m_lock.Enter;
  //Console.Log('TServer<ClientType>.ServerOnDisconnect');

  client := GetClientByContext(AContext);
  if client = nil then
  begin
    Exit;
  end;

  SetContextData(AContext, nil);

  self.OnClientDisconnect(client);

  m_clients.Remove(client);

  OnDestroyClient(client);

  client.Free;
  m_lock.Leave;
end;

procedure TServer<ClientType>.ServerOnExecute(AContext: TIdContext);
var
  buffer: TIdBytes;
  decryptedBuffer: TPangyaBytes;
  pheader: PTClientPacketHeader;
  bufferSize: UInt32;
  dataSize: UInt32;
  clientPacket: TClientPacket;
  client: TServerClient<ClientType>;
begin

  with AContext.Connection.IOHandler do
  begin
    ReadBytes(buffer, SizeOf(TClientPacketHeader));
    pheader := @buffer[0];
    ReadBytes(buffer, pheader.size, true);
  end;

  m_lock.Enter;

  pheader := @buffer[0];

  bufferSize := Length(buffer);
  dataSize := pheader.size;
  if not (dataSize + 4 = bufferSize) then
  begin
    Console.Log('Something went wrong! Fix me', C_RED);
  end;

  client := self.GetClientByContext(AContext);

  if nil = client then
  begin
    Console.Log('Something went wrong v2! Fix me', C_RED);
  end;

  m_cryptLib.ClientDecrypt2(TPangyaBytes(buffer), decryptedBuffer, client.GetKey);

  clientPacket := TClientPacket.CreateFromPangyaBytes(decryptedBuffer);

  OnReceiveClientData(client, clientPacket);

  clientPacket.Free;

  m_lock.Leave;
end;

procedure TServer<ClientType>.ServerOnException(AContext: TIdContext;
  AException: Exception);
begin
  m_lock.Enter;
  //Console.Log('TServer<ClientType>.ServerOnException');
  m_lock.Leave;
end;

procedure TServer<ClientType>.ServerOnStatus(ASender: TObject;
  const AStatus: TIdStatus; const AStatusText: string);
begin
  m_lock.Enter;
  //Console.Log('TServer<ClientType>.ServerOnStatus');

  m_lock.Leave;
end;

function TServer<ClientType>.GetClientByContext(AContext: TIdContext): TServerClient<ClientType>;
var
  Client: TServerClient<ClientType>;
  contextObject: TObject;
begin

  contextObject := GetContextData(AContext);

  for Client in m_clients do
  begin
    if client = contextObject then
    begin
      Exit(client);
    end;
  end;

  Exit(nil);
end;

procedure TServer<ClientType>.SetContextData(AContext: TIdContext; data: TObject);
begin
  {$IFDEF USE_OBJECT_ARC}
  AContext.DataObject := data;
  {$ELSE}
  AContext.Data := data;
  {$ENDIF}
end;

function TServer<ClientType>.GetContextData(AContext: TIdContext): TObject;
begin
  {$IFDEF USE_OBJECT_ARC}
  Exit(AContext.DataObject);
  {$ELSE}
  Exit(AContext.Data);
  {$ENDIF}
end;

end.
