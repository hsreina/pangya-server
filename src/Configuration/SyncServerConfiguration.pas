{*******************************************************}
{                                                       }
{       Pangya Server                                   }
{                                                       }
{       Copyright (C) 2018 Shad'o Soft tm               }
{                                                       }
{*******************************************************}

unit SyncServerConfiguration;

interface

type
  TSyncServerConfiguration = class
    private
      var m_port: UInt16;
    public
      constructor Create;
      destructor Destroy; override;
      property Port: UInt16 read m_port;
  end;

implementation

uses
  IniFiles;

constructor TSyncServerConfiguration.Create;
var
  iniFile: TIniFile;
begin
  inherited;
  iniFile := TIniFile.Create('../config/server.ini');
  m_port := iniFile.ReadInteger('sync', 'port', 7998);
end;

destructor TSyncServerConfiguration.Destroy;
begin
  inherited;
end;

end.
