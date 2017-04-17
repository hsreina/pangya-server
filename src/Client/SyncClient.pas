{*******************************************************}
{                                                       }
{       Pangya Server                                   }
{                                                       }
{       Copyright (C) 2015 Shad'o Soft tm               }
{                                                       }
{*******************************************************}

unit SyncClient;

interface

uses Buffer, ExtCtrls, CryptLib, Logging, ClientPacket, IdTcpClient,
  SyncClientReadThread, PangyaBuffer, Classes;

type

  TSyncClientReadEvent = procedure (sender: TObject; const clientPacket: TClientPacket) of object;
  TSyncClientConnectEvent = procedure (sender: TObject) of object;

  TSyncClient = class (TLogging)
    private
      var m_client: TIdTcpClient;
      var m_clientReadThread: TSyncClientReadThread;
      var m_cryptLib: TCryptLib;
      var m_key: Byte;
      var m_haveKey: Boolean;

      var FOnRead: TSyncClientReadEvent;
      procedure TriggerOnRead(const clientPacket: TClientPacket);

      var FOnConnect: TSyncClientConnectEvent;
      procedure TriggerOnConnect;

      procedure OnClientRead(const sender: TObject; const buffer: TPangyaBytes);
      procedure OnClientConnected(Sender: TObject);
      procedure OnClientDisconnected(Sender: TObject);
      procedure HandleReadKey(clientPacket: TClientPacket);

    public
      constructor Create(const name: string; const cryptLib: TCryptLib);
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

constructor TSyncClient.Create(const name: string; const cryptLib: TCryptLib);
begin
  m_client := TIdTcpClient.Create(nil);
  m_client.OnConnected := OnClientConnected;
  m_client.OnDisconnected := OnClientDisconnected;

  m_clientReadThread := TSyncClientReadThread.Create(name + 'SyncClient', m_client);
  m_clientReadThread.OnRead := OnClientRead;

  m_haveKey := false;
  m_cryptLib := cryptLib;
end;

destructor TSyncClient.Destroy;
begin
  inherited;
  m_client.Free;
  m_clientReadThread.Free;
end;

procedure TSyncClient.SetPort(port: Integer);
begin
  m_client.Port := port;
end;

procedure TSyncClient.Start;
begin
  m_client.Connect;
end;

procedure TSyncClient.Stop;
begin
  m_client.Disconnect;
end;

procedure TSyncClient.SetHost(host: string);
begin
  m_client.Host := host;
end;

procedure TSyncClient.Send(data: AnsiString);
begin
  self.Send(data, true);
end;

procedure TSyncClient.Send(data: AnsiString; encrypt: Boolean);
var
  tmp: TMemoryStream;
  dataToSend: AnsiString;
begin
  if encrypt then
  begin
    dataToSend := m_cryptLib.ClientEncrypt(data, m_key, 0);
  end else
  begin
    dataToSend := data;
  end;

  tmp := TMemoryStream.Create;
  tmp.Write(dataToSend[1], Length(dataToSend));
  m_client.IOHandler.Write(tmp);
  tmp.free;
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

procedure TSyncClient.OnClientRead(const sender: TObject; const buffer: TPangyaBytes);
var
  clientPacket: TClientPacket;
  decryptedBuffer: TPangyaBytes;
begin
  if not m_haveKey then
  begin
    clientPacket := TClientPacket.CreateFromPangyaBytes(buffer);
    HandleReadKey(clientPacket);
    clientPacket.Free;
  end else
  begin
    m_cryptLib.ClientDecrypt2(buffer, decryptedBuffer, m_key);
    clientPacket := TClientPacket.CreateFromPangyaBytes(decryptedBuffer);
    TriggerOnRead(clientPacket);
    clientPacket.Free;
  end;
end;

procedure TSyncClient.OnClientConnected(Sender: TObject);
begin
  TriggerOnConnect;
end;

procedure TSyncClient.OnClientDisconnected(Sender: TObject);
begin

end;

end.
