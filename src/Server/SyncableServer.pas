{*******************************************************}
{                                                       }
{       Pangya Server                                   }
{                                                       }
{       Copyright (C) 2015 Shad'o Soft tm               }
{                                                       }
{*******************************************************}

unit SyncableServer;

interface

uses SyncClient, Server, CryptLib, SysUtils, Packet, PacketReader;

type
  TSyncableServer<ClientType> = class abstract (TServer<ClientType>)
    protected
      procedure Sync(data: RawByteString); overload;
      procedure Sync(data: TPacket); overload;

      procedure SetSyncPort(port: Integer);
      procedure StartSyncClient;
      procedure StopSyncClient;
      procedure SetSyncHost(host: string);

      procedure OnReceiveSyncData(const packetReader: TPacketReader); virtual; abstract;
      procedure OnConnect(sender: TObject); virtual; abstract;
      procedure OnConnectSuccess(sender: TObject); virtual; abstract;

    private
      var m_syncClient: TSyncClient;

      procedure OnClientRead(Sender: TObject; const packetReader: TPacketReader);

    public
      constructor Create(const name: string; const cryptLib: TCryptLib);
      destructor Destroy; override;
  end;

implementation

uses Logging, ConsolePas;

constructor TSyncableServer<ClientType>.Create(const name: string; const cryptLib: TCryptLib);
begin
  inherited Create(cryptLib);
  m_syncClient := TSyncClient.Create(name + 'SyncableServer', cryptLib);
  m_syncClient.OnRead := self.OnClientRead;
  m_syncClient.OnConnect := OnConnect;
  m_syncClient.OnConnectSuccess := OnConnectSuccess;
end;

destructor TSyncableServer<ClientType>.Destroy;
begin
  m_syncClient.Free;
  inherited;
end;

procedure TSyncableServer<ClientType>.SetSyncPort(port: Integer);
begin
  Console.Log('TSyncableServer<ClientType>.SetSyncPort', C_BLUE);
  Console.Log(Format('port : %d', [port]));
  m_syncClient.SetPort(port);
end;

procedure TSyncableServer<ClientType>.Sync(data: RawByteString);
begin
  self.Log('TSyncableServer<ClientType>.Sync', TLogType_not);
  m_syncClient.Send(data);
end;

procedure TSyncableServer<ClientType>.Sync(data: TPacket);
begin
  self.Log('TSyncableServer<ClientType>.Sync', TLogType_not);
  m_syncClient.Send(data.ToStr);
end;

procedure TSyncableServer<ClientType>.StartSyncClient;
begin
  self.Log('TSyncableServer<ClientType>.StartSyncClient', TLogType_not);
  m_syncClient.OnLog := self.OnLog;
  m_syncClient.Start;
end;

procedure TSyncableServer<ClientType>.StopSyncClient;
begin
  self.Log('TSyncableServer<ClientType>.StopSyncClient', TLogType_not);
  m_syncClient.Stop;
end;

procedure TSyncableServer<ClientType>.SetSyncHost(host: string);
begin
  Console.Log('TSyncableServer<ClientType>.SetSyncHost', C_BLUE);
  Console.Log(Format('host : %s', [host]));
  m_syncClient.SetHost(host);
end;

procedure TSyncableServer<ClientType>.OnClientRead(Sender: TObject; const packetReader: TPacketReader);
begin
  self.OnReceiveSyncData(packetReader);
end;

end.
