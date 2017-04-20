unit SyncClientReadThread;

interface

uses
  Classes, IdTcpClient, SyncObjs, Types.PangyaBytes;

type

  TSyncClientReadThreadReadEvent = procedure(const sender: TObject; const buffer: TPangyaBytes) of object;

  TSyncClientReadThread = class(TThread)
    private
      var m_client: TIdTCPClient;
      var m_lock: TCriticalSection;
      var m_onRead: TSyncClientReadThreadReadEvent;
      var m_name: string;
      procedure Execute; override;
      procedure TriggerRead(const buffer: TPangyaBytes);
    public
      constructor Create(const name: string; const client: TIdTcpClient);
      destructor Destroy; override;
      property OnRead: TSyncClientReadThreadReadEvent read m_onRead write m_onRead;
  end;

implementation

uses
  IdIOHandler, IdGlobal, PacketsDef, ConsolePas;

constructor TSyncClientReadThread.Create(const name: string; const client: TIdTCPClient);
begin
  inherited Create(False);
  m_name := name;
  m_client := client;
  m_lock := TCriticalSection.Create;
end;

destructor TSyncClientReadThread.Destroy;
begin
  m_lock.Free;
  inherited;
end;

procedure TSyncClientReadThread.Execute;
var
  ioHandler: TIdIOHandler;
  buffer: TIdBytes;
  pheader: PTClientPacketHeader;
  bufferSize: UInt32;
  dataSize: UInt32;
begin
  inherited;
  NameThreadForDebugging(m_name + 'ReadThread', self.ThreadID);

  while not Terminated do
  begin

    if not m_client.Connected then
    begin
      Sleep(100);
      continue;
    end;

    ioHandler := m_client.IOHandler;

    SetLength(buffer, 0);

    ioHandler.ReadBytes(buffer, SizeOf(TClientPacketHeader));
    pheader := @buffer[0];

    ioHandler.ReadBytes(buffer, pheader.size, true);
    pheader := @buffer[0];

    bufferSize := Length(buffer);
    dataSize := pheader.size;
    if not (dataSize + 4 = bufferSize) then
    begin
      Console.Log('Something went wrong! Fix me', C_RED);
      m_client.Disconnect;
      Exit;
    end;

    m_lock.Enter;
    TriggerRead(TPangyaBytes(buffer));
    m_lock.Leave;
  end;
end;

procedure TSyncClientReadThread.TriggerRead(const buffer: TPangyaBytes);
begin
  if Assigned(m_onRead) then
  begin
    m_onRead(self, buffer);
  end;
end;

end.
