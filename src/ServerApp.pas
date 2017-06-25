unit ServerApp;

interface

uses
  LoginServer,
  GameServer,
  SyncServer,
  CryptLib, DataChecker, IffManager, SysUtils, Logging;

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

      procedure OnServerLog(sender: TObject; msg: string; logType: TLogType);

    public
      constructor Create;
      destructor Destroy; override;
      function ParseCommand(command: String): Boolean;
      property IsRunning: Boolean read m_isRunning;
      procedure Start;
      procedure Stop;
  end;

implementation

uses ConsolePas;

constructor TServerApp.Create;
begin
  inherited;
  m_isRunning := true;

  Console.Log('PANGYA SERVER by HSReina', C_GREEN);

  m_dataChecker := TDataChecker.Create;

  try
    m_dataChecker.Validate;
  except
    on E : Exception do
    begin
      Console.Log(Format('Data validation failed : %s', [E.Message]), C_RED);
    end;
  end;

  m_cryptLib:= TCryptLib.Create;
  m_iffManager := TIffManager.Create;

  if not m_iffManager.Load then
  begin
    Console.Log('You should have valid US pangya_gb.iff content in ../data/pangya_gb.iff directory');
    raise Exception.Create('Failed to load Iff');
    Exit;
  end;

  //m_iffManager.PatchAndSave;

{$IFDEF SYNC_SERVER}
  m_synServer := TSyncServer.Create(m_cryptLib);
  m_synServer.OnLog := self.OnServerLog;
  //m_synServer.Debug;
{$ENDIF}

{$IFDEF LOGIN_SERVER}
  m_loginServer := TLoginServer.Create(m_cryptLib);
  m_loginServer.OnLog := self.OnServerLog;
{$ENDIF}

{$IFDEF GAME_SERVER}
  m_gameServer := TGameServer.Create(m_cryptLib, m_iffManager);
  m_gameServer.OnLog := self.OnServerLog;
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
    exit;
  end;

  Exit(False);
end;

procedure TServerApp.Start;
begin
{$IFDEF SYNC_SERVER}
  Sleep(1000);
  m_synServer.Start;
{$ENDIF}
{$IFDEF GAME_SERVER}
  Sleep(1000);
  m_gameServer.Start;
{$ENDIF}
{$IFDEF LOGIN_SERVER}
  Sleep(1000);
  m_loginServer.Start;
{$ENDIF}
end;

procedure TServerApp.Stop;
begin
end;

procedure TServerApp.OnServerLog(sender: TObject; msg: string; logType: TLogType);
var
  color: integer;
begin

  case logType of
    TLogType_msg: ;
    TLogType_wrn: color := C_ORANGE;
    TLogType_err: color := C_RED;
    TLogType_not: color := C_BLUE;
  end;

  Console.Log(msg, color);
end;

end.
