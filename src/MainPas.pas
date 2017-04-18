{*******************************************************}
{                                                       }
{       Pangya Server                                   }
{                                                       }
{       Copyright (C) 2015 Shad'o Soft tm               }
{                                                       }
{*******************************************************}

unit MainPas;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, LoginServer, Server, Logging, CryptLib,
  gameServer, SyncUser, SyncServer, Vcl.StdCtrls, ShellApi, DataChecker,
  IffManager;

type
  TMain = class(TForm)
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure FormShow(Sender: TObject);
  private

    var m_loginServer: TLoginServer;
    var m_gameServer: TGameServer;
    var m_synServer: TSyncServer;
    var m_cryptLib: TCryptLib;
    var m_dataChecker: TDataChecker;
    var m_iffManager: TIffManager;

    procedure OnServerLog(sender: TObject; msg: string; logType: TLogType);
    procedure Init;
  public
    procedure AcceptFiles(var msg: TMessage); message WM_DROPFILES;
  end;

var
  Main: TMain;

implementation

{$R *.dfm}

uses ConsolePas, utils, IffManager.IffEntrybase;

procedure TMain.FormCreate(Sender: TObject);
begin
  DragAcceptFiles(Handle, true);
  {$IFDEF CONSOLE}
  Init;
  {$ENDIF}
end;

procedure TMain.FormDestroy(Sender: TObject);
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
end;

procedure TMain.FormShow(Sender: TObject);
begin
  {$IFDEF DEBUG}
  Console.Show;
  {$ENDIF}
  {$IFNDEF CONSOLE}
  Init;
  {$ENDIF}
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

procedure TMain.Init;
var
  iffEntry: TIffEntrybase;
  test: Boolean;
begin
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

  if not m_cryptLib.init then
  begin
    Console.Log('CryptLib init Failed', C_RED);
    Exit;
  end else
  begin
    Console.Log('CryptLib init Ok', C_GREEN);
  end;

  m_iffManager := TIffManager.Create;

  if not m_iffManager.Load then
  begin
    Console.Log('Failed to load Iffs!!', C_RED);
    Console.Log('You should have valid US pangya_gb.iff content in ../data/pangya_gb.iff directory');
    Exit;
  end;

  //m_iffManager.PatchAndSave;

{$IFDEF SYNC_SERVER}
  m_synServer := TSyncServer.Create(m_cryptLib);
  m_synServer.OnLog := self.OnServerLog;
  m_synServer.Debug;
  m_synServer.Start;
{$ENDIF}

{$IFDEF LOGIN_SERVER}
  m_loginServer := TLoginServer.Create(m_cryptLib);
  m_loginServer.OnLog := self.OnServerLog;
  m_loginServer.Start;
{$ENDIF}

{$IFDEF GAME_SERVER}
  m_gameServer := TGameServer.Create(m_cryptLib, m_iffManager);
  m_gameServer.OnLog := self.OnServerLog;
  m_gameServer.Start;
{$ENDIF}

end;

end.
