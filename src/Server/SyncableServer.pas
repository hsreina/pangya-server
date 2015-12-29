{*******************************************************}
{                                                       }
{       Pangya Server                                   }
{                                                       }
{       Copyright (C) 2015 Shad'o Soft tm               }
{                                                       }
{*******************************************************}

unit SyncableServer;

interface

uses SyncClient, Server, CryptLib, ClientPacket, ScktComp;

type
  TSyncableServer<ClientType> = class abstract (TServer<ClientType>)
    protected
      procedure Sync(data: AnsiString);

      procedure SetSyncPort(port: Integer);
      procedure StartSyncClient;
      procedure StopSyncClient;
      procedure SetSyncHost(host: string);

      procedure OnReceiveSyncData(const clientPacket: TClientPacket); virtual; abstract;

    private
      var m_syncClient: TSyncClient;

      procedure OnClientRead(Sender: TObject; const clientPacket: TClientPacket);

    public
      constructor Create(cryptLib: TCryptLib);
      destructor Destroy; override;
  end;

implementation

uses Logging;

constructor TSyncableServer<ClientType>.Create(cryptLib: TCryptLib);
begin
  inherited;
  m_syncClient := TSyncClient.Create(cryptLib);
  m_syncClient.OnRead := self.OnClientRead;
end;

destructor TSyncableServer<ClientType>.Destroy;
begin
  inherited;
  m_syncClient.Free;
end;

procedure TSyncableServer<ClientType>.SetSyncPort(port: Integer);
begin
  self.Log('TSyncableServer<ClientType>.SetSyncPort', TLogType_not);
  m_syncClient.SetPort(port);
end;

procedure TSyncableServer<ClientType>.Sync(data: AnsiString);
begin
  self.Log('TSyncableServer<ClientType>.Sync', TLogType_not);
  m_syncClient.Send(data);
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
  m_syncClient.SetHost(host);
end;

procedure TSyncableServer<ClientType>.OnClientRead(Sender: TObject; const clientPacket: TClientPacket);
begin
  self.OnReceiveSyncData(clientPacket);
end;

end.
