{*******************************************************}
{                                                       }
{       Pangya Server                                   }
{                                                       }
{       Copyright (C) 2015 Shad'o Soft tm               }
{                                                       }
{*******************************************************}

unit Server;

interface

uses Logging, Client, Generics.Collections, CryptLib,
  SyncClient, defs, PacketData, SysUtils,
  SerialList, IdTcpServer, IdContext, IdGlobal, IdComponent,
  IdSchedulerOfThreadPool, PacketReader, Types.PangyaBytes, MMO.Lock;

type

  {
    Base function of the servers like handling clients, receiving and decrypting packet
    and some other basic function to send back message to the game
  }

  TServer<ClientType> = class abstract (TLogging)
    private

      var m_clients: TSerialList<TClient<ClientType>>;
      var m_server: TIdTCPServer;
      var m_idSchedulerOfThreadPool: TIdSchedulerOfThreadPool;
      var m_lock: TLock;
      var m_cryptLib: TCryptLib;
      var m_maxPlayers: UInt32;

      procedure ServerOnConnect(AContext: TIdContext);
      procedure ServerOnDisconnect(AContext: TIdContext);
      procedure ServerOnExecute(AContext: TIdContext);
      procedure ServerOnException(AContext: TIdContext; AException: Exception);
      procedure ServerOnStatus(ASender: TObject; const AStatus: TIdStatus; const AStatusText: string);

      function GetClientByContext(AContext: TIdContext): TClient<ClientType>;
      procedure SetContextData(AContext: TIdContext; data: TObject);
      function GetContextData(AContext: TIdContext): TObject;

    protected
      procedure SetPort(port: Integer);
      procedure Init; virtual; abstract;

      procedure OnClientConnect(const client: TClient<ClientType>); virtual; abstract;
      procedure OnClientDisconnect(const client: TClient<ClientType>); virtual; abstract;
      procedure OnReceiveClientData(const client: TClient<ClientType>; const packetReader: TPacketReader); virtual; abstract;
      procedure OnStart; virtual; abstract;
      procedure OnDestroyClient(const client: TClient<ClientType>); virtual; abstract;

      function GetClientByUID(UID: TPlayerUID): TClient<ClientType>;

      function Write(const source; const count: UInt32): RawByteString;
      function WritePStr(const str: RawByteString): RawByteString;
      function FillStr(data: RawByteString; size: UInt32; withWhat: UTF8Char): RawByteString;

      function Deserialize(value: UInt32): UInt32;

      // Should replace this by something better
      property Clients: TSerialList<TClient<ClientType>> read m_clients;
    public
      constructor Create(cryptLib: TCryptLib);
      destructor Destroy; override;

      procedure SendDebugData(data: TPacketData);

      function Start: Boolean;
    end;

  implementation

uses ConsolePas, PacketsDef;

constructor TServer<ClientType>.Create(cryptLib: TCryptLib);
begin
  inherited Create;
  console.Log('TServer<ClientType>.Create');
  m_lock := TLock.Create(True);
  m_cryptLib := cryptLib;
  m_clients := TSerialList<TClient<ClientType>>.Create;
  m_server := TIdTCPServer.Create(nil);

  m_maxPlayers := 10;

  m_idSchedulerOfThreadPool := TIdSchedulerOfThreadPool.Create(nil);
  m_idSchedulerOfThreadPool.MaxThreads := m_maxPlayers;
  m_idSchedulerOfThreadPool.PoolSize := m_maxPlayers;

  m_server.MaxConnections := m_maxPlayers;
  m_server.ListenQueue := m_maxPlayers;

  m_server.OnExecute := ServerOnExecute;
  m_server.OnConnect := ServerOnConnect;
  m_server.OnDisconnect := ServerOnDisconnect;
  m_server.OnException := ServerOnException;
  m_server.OnStatus := ServerOnStatus;

  m_server.Scheduler := m_idSchedulerOfThreadPool;
end;

destructor TServer<ClientType>.Destroy;
begin
  m_server.Free;
  m_idSchedulerOfThreadPool.Free;
  m_clients.Free;
  m_lock.Free;
  inherited;
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

function TServer<ClientType>.GetClientByUID(UID: TPlayerUID): TClient<ClientType>;
var
  Client: TClient<ClientType>;
begin
  for Client in m_clients do
  begin
    if client.HasUID(UID) then
    begin
      Exit(client);
    end;
  end;
end;

function TServer<ClientType>.Write(const source; const count: UInt32): RawByteString;
begin
  setlength(result, count);
  move(source, result[1], count);
end;

function TServer<ClientType>.WritePStr(const str: RawByteString): RawByteString;
var
  size: UInt32;
begin
  size := Length(str);
  Result :=  Write(size, 2) + str;
end;

function TServer<ClientType>.FillStr(data: RawByteString; size: UInt32; withWhat: UTF8Char): RawByteString;
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
  client: TClient<ClientType>;
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
  client: TClient<ClientType>;
begin
  m_lock.Synchronize(procedure
  begin
    Console.Log('TServer<ClientType>.ServerOnConnect');
    if (m_clients.Count >= m_maxPlayers) then
    begin
      Console.Log('Server full', C_RED);
      AContext.Connection.Disconnect;
      Exit;
    end;

    client := TClient<ClientType>.Create(AContext, m_cryptLib);
    client.ID := m_clients.Add(client);
    SetContextData(AContext, client);
    OnClientConnect(client);
  end);
end;

procedure TServer<ClientType>.ServerOnDisconnect(AContext: TIdContext);
var
  client: TClient<ClientType>;
begin
  m_lock.Synchronize(procedure
  begin
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
  end);
end;

procedure TServer<ClientType>.ServerOnExecute(AContext: TIdContext);
var
  buffer: TIdBytes;
  decryptedBuffer: TPangyaBytes;
  pheader: PTClientPacketHeader;
  bufferSize: UInt32;
  dataSize: UInt32;
  packetReader: TPacketReader;
  client: TClient<ClientType>;
begin

  with AContext.Connection.IOHandler do
  begin
    ReadBytes(buffer, SizeOf(TClientPacketHeader));
    pheader := @buffer[0];
    ReadBytes(buffer, pheader.size, true);
  end;

  pheader := @buffer[0];

  bufferSize := Length(buffer);
  dataSize := pheader.size;
  if not (dataSize + 4 = bufferSize) then
  begin
    Console.Log('Something went wrong! Fix me', C_RED);
    AContext.Connection.Disconnect;
    Exit;
  end;

  client := self.GetClientByContext(AContext);

  if nil = client then
  begin
    Console.Log('Something went wrong v2! Fix me', C_RED);
    AContext.Connection.Disconnect;
    Exit;
  end;

  m_cryptLib.ClientDecrypt2(TPangyaBytes(buffer), decryptedBuffer, client.GetKey);

  packetReader := TPacketReader.CreateFromPangyaBytes(decryptedBuffer);

  m_lock.Synchronize(procedure
  begin
    OnReceiveClientData(client, packetReader);
  end);

  packetReader.Free;
end;

procedure TServer<ClientType>.ServerOnException(AContext: TIdContext;
  AException: Exception);
begin
  m_lock.Synchronize(procedure
  begin
    //Console.Log('TServer<ClientType>.ServerOnException');
  end);
end;

procedure TServer<ClientType>.ServerOnStatus(ASender: TObject;
  const AStatus: TIdStatus; const AStatusText: string);
begin
  m_lock.Synchronize(procedure
  begin
    //Console.Log('TServer<ClientType>.ServerOnStatus');
  end);
end;

function TServer<ClientType>.GetClientByContext(AContext: TIdContext): TClient<ClientType>;
var
  Client: TClient<ClientType>;
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
  { $IFDEF USE_OBJECT_ARC}
  {$IFDEF LINUX}
  AContext.DataObject := data;
  {$ELSE}
  AContext.Data := data;
  {$ENDIF}
end;

function TServer<ClientType>.GetContextData(AContext: TIdContext): TObject;
begin
  { $IFDEF USE_OBJECT_ARC}
  {$IFDEF LINUX}
  Exit(AContext.DataObject);
  {$ELSE}
  Exit(AContext.Data);
  {$ENDIF}
end;

end.
