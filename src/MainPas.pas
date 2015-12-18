unit MainPas;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, LoginServer, Server, Logging, CryptLib,
  gameServer, SyncUser, SyncServer, Vcl.StdCtrls, ShellApi, DataChecker;

type
  TMain = class(TForm)
    Button1: TButton;
    procedure FormShow(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
  private
    var m_loginServer: TLoginServer;
    var m_gameServer: TGameServer;
    var m_synServer: TSyncServer;
    var m_cryptLib: TCryptLib;
    var m_dataChecker: TDataChecker;

    procedure OnServerLog(sender: TObject; msg: string; logType: TLogType);
  public
    procedure AcceptFiles(var msg: TMessage); message WM_DROPFILES;
  end;

var
  Main: TMain;

implementation

{$R *.dfm}

uses ConsolePas, Buffer, utils;

procedure TMain.FormDestroy(Sender: TObject);
begin
  m_loginServer.Free;
  m_gameServer.Free;
  m_synServer.Free;
  m_cryptLib.Free;
  m_dataChecker.Free;
end;

procedure TMain.AcceptFiles(var msg: TMessage);
const
  cnMaxFileNameLen = 255;
var
  i, nCount: integer;
  acFileName: array [0 .. cnMaxFileNameLen] of char;
  outdata: AnsiString;
begin
  nCount := DragQueryFile(msg.WParam, $FFFFFFFF, acFileName, cnMaxFileNameLen);

  for i := 0 to nCount - 1 do
  begin
    DragQueryFile(msg.WParam, i, acFileName, cnMaxFileNameLen);
    outdata := GetDataFromFile(acFileName);
    console.writeDump(outdata);
    console.log('send to game 0');
    m_gameServer.SendDebugData(outdata);
  end;

  DragFinish(msg.WParam);
end;

procedure TMain.FormShow(Sender: TObject);
begin

  DragAcceptFiles(Handle, true);

  Console.Show;
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

  m_loginServer := TLoginServer.Create(m_cryptLib);
  m_gameServer := TGameServer.Create(m_cryptLib);
  m_synServer := TSyncServer.Create(m_cryptLib);

  m_synServer.Debug;

  if not m_cryptLib.init then
  begin
    Console.Log('CryptLib init Failed', C_RED);
    Exit;
  end else
  begin
    Console.Log('CryptLib init Ok', C_GREEN);
  end;

  m_synServer.OnLog := self.OnServerLog;
  m_loginServer.OnLog := self.OnServerLog;
  m_gameServer.OnLog := self.OnServerLog;

  m_synServer.Start;
  m_loginServer.Start;
  m_gameServer.Start;
end;

procedure TMain.OnServerLog(sender: TObject; msg: string; logType: TLogType);
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
