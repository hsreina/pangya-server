{*******************************************************}
{                                                       }
{       Pangya Server                                   }
{                                                       }
{       Copyright (C) 2015 Shad'o Soft tm               }
{                                                       }
{*******************************************************}

unit SyncableServer;

interface

uses SyncClient, Server, CryptLib, SysUtils, Packet, PacketReader,
  LoggerInterface;

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
      constructor Create(const ALogger: ILoggerInterface; const name: string; const cryptLib: TCryptLib);
      destructor Destroy; override;
  end;

implementation

constructor TSyncableServer<ClientType>.Create(const ALogger: ILoggerInterface; const name: string; const cryptLib: TCryptLib);
begin
  inherited Create(ALogger, cryptLib);
  m_syncClient := TSyncClient.Create(ALogger, name + 'SyncableServer', cryptLib);
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
  m_logger.Info('TSyncableServer<ClientType>.SetSyncPort');
  m_logger.Debug('port : %d', [port]);
  m_syncClient.SetPort(port);
end;

procedure TSyncableServer<ClientType>.Sync(data: RawByteString);
begin
  m_logger.Info('TSyncableServer<ClientType>.Sync');
  m_syncClient.Send(data);
end;

procedure TSyncableServer<ClientType>.Sync(data: TPacket);
begin
  m_logger.Info('TSyncableServer<ClientType>.Sync');
  m_syncClient.Send(data.ToStr);
end;

procedure TSyncableServer<ClientType>.StartSyncClient;
begin
  m_logger.Info('TSyncableServer<ClientType>.StartSyncClient');
  m_syncClient.Start;
end;

procedure TSyncableServer<ClientType>.StopSyncClient;
begin
  m_logger.Info('TSyncableServer<ClientType>.StopSyncClient');
  m_syncClient.Stop;
end;

procedure TSyncableServer<ClientType>.SetSyncHost(host: string);
begin
  m_logger.Info('TSyncableServer<ClientType>.SetSyncHost');
  m_logger.Debug('host : %s', [host]);
  m_syncClient.SetHost(host);
end;

procedure TSyncableServer<ClientType>.OnClientRead(Sender: TObject; const packetReader: TPacketReader);
begin
  self.OnReceiveSyncData(packetReader);
end;

end.
