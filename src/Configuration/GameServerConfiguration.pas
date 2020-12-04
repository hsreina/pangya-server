{*******************************************************}
{                                                       }
{       Pangya Server                                   }
{                                                       }
{       Copyright (C) 2018 Shad'o Soft tm               }
{                                                       }
{*******************************************************}

unit GameServerConfiguration;

interface

type
  TGameServerConfiguration = class
    private
      var m_port: UInt16;
      var m_host: RawByteString;
      var m_name: RawByteString;
      var m_syncServerPort: UInt16;
      var m_syncServerHost: RawByteString;
      var m_clientBuildDate: UInt32;
      var m_clientVersion: RawByteString;
    public
      constructor Create;
      destructor Destroy; override;

      property Port: UInt16 read m_port;
      property Host: RawByteString read m_host;
      property Name: RawByteString read m_name;
      property SyncServerPort: UInt16 read m_syncServerPort;
      property SyncServerHost: RawByteString read m_syncServerHost;
      property ClientBuildDate: UInt32 read m_clientBuildDate;
      property ClientVersion: RawByteString read m_clientVersion;
  end;

implementation

uses
  IniFiles;

constructor TGameServerConfiguration.Create;
var
  iniFile: TIniFile;
begin
  inherited;
  iniFile := TIniFile.Create('../config/server.ini');
  try
    m_port := iniFile.ReadInteger('game', 'port', 7997);
    m_host := iniFile.ReadString('game', 'host', '127.0.0.1');
    m_name := iniFile.ReadString('game', 'name', 'GameServer');
    m_clientBuildDate := iniFile.ReadInteger('game', 'client_build_date', 2016110200);
    m_clientVersion := iniFile.ReadString('game', 'client_version', '852.00');
    m_syncServerPort := iniFile.ReadInteger('sync', 'port', 7998);
    m_syncServerHost := iniFile.ReadString('sync', 'host', '127.0.0.1');
  finally
    iniFile.Free;
  end;
end;

destructor TGameServerConfiguration.Destroy;
begin
  inherited;
end;

end.
