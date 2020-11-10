unit ServerApp;

interface

uses
  LoginServer,
  GameServer,
  SyncServer,
  CryptLib, DataChecker, IffManager, SysUtils, LoggerInterface;

type
  TServerApp = class
    private
      var m_isRunning: Boolean;

      var m_loginServer: TLoginServer;
      var m_gameServer: TGameServer;
      var m_synServer: TSyncServer;
      var m_cryptLib: TCryptLib;
      var m_dataChecker: TDataChecker;
      var m_iffManager: TIffManager;
      var m_logger: ILoggerInterface;

    public
      constructor Create(const ALogger: ILoggerInterface);
      destructor Destroy; override;
      function ParseCommand(command: String): Boolean;
      property IsRunning: Boolean read m_isRunning;
      procedure Start;
      procedure Stop;
  end;

implementation

constructor TServerApp.Create(const ALogger: ILoggerInterface);
begin
  inherited Create;
  m_logger := ALogger;
  m_isRunning := true;

  m_logger.Notice('PANGYA SERVER by HSReina');

  m_dataChecker := TDataChecker.Create;

  try
    m_dataChecker.Validate;
  except
    on E : Exception do
    begin
      m_logger.Error('Data validation failed : %s', [E.Message]);
    end;
  end;

  m_cryptLib:= TCryptLib.Create;
  m_iffManager := TIffManager.Create;

  if not m_iffManager.Load then
  begin
    m_logger.Warning('You should have valid US pangya_gb.iff content in ../data/pangya_gb.iff directory');
    raise Exception.Create('Failed to load Iff');
    Exit;
  end;

  //m_iffManager.PatchAndSave;

{$IFDEF SYNC_SERVER}
  m_synServer := TSyncServer.Create(ALogger, m_cryptLib);
  //m_synServer.Debug;
{$ENDIF}

{$IFDEF LOGIN_SERVER}
  m_loginServer := TLoginServer.Create(ALogger, m_cryptLib);
{$ENDIF}

{$IFDEF GAME_SERVER}
  m_gameServer := TGameServer.Create(ALogger, m_cryptLib, m_iffManager);
{$ENDIF}

end;

destructor TServerApp.Destroy;
begin

{$IFDEF LOGIN_SERVER}
  m_loginServer.Free;
{$ENDIF}

{$IFDEF GAME_SERVER}
  m_gameServer.Free;
{$ENDIF}

{$IFDEF SYNC_SERVER}
  m_synServer.Free;
{$ENDIF}

  m_iffManager.Free;
  m_cryptLib.Free;
  m_dataChecker.Free;

  inherited;
end;

function TServerApp.ParseCommand(command: string): Boolean;
begin
  Result := true;
  if command = 'exit' then
  begin
    m_isRunning := false;
    Exit;
  end else if command = 'g' then
  begin
    m_gameServer.Debug;
    Exit;
  end;
  Exit(False);
end;

procedure TServerApp.Start;
begin
{$IFDEF SYNC_SERVER}
  Sleep(500);
  m_synServer.Start;
{$ENDIF}
{$IFDEF GAME_SERVER}
  Sleep(500);
  m_gameServer.Start;
{$ENDIF}
{$IFDEF LOGIN_SERVER}
  Sleep(500);
  m_loginServer.Start;
{$ENDIF}
end;

procedure TServerApp.Stop;
begin
end;

end.
