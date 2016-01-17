{*******************************************************}
{                                                       }
{       Pangya Server                                   }
{                                                       }
{       Copyright (C) 2015 Shad'o Soft tm               }
{                                                       }
{*******************************************************}

unit ConsolePas;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, ComCtrls, Menus;

type

  TConsoleColor = (
    CColor_red = clRed,
    CColor_green = clGreen,
    CColor_blue = clBlue,
    CColor_fushia = clFuchsia,
    CColor_orange = $008CFF
  );

  TConsoleOnCloseEvent = procedure of Object;
  PConsole = ^TConsole;
  TConsole = class(TForm)
    DebugInfo: TRichEdit;
    MainMenu1: TMainMenu;
    Log1: TMenuItem;
    Clear1: TMenuItem;
    Close1: TMenuItem;
    procedure Clear1Click(Sender: TObject);
    procedure Close1Click(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure FormShow(Sender: TObject);
  private
    { Private declarations }
    procedure SetTitle(title: string);
    function GetTitle: string;
    var m_displayed: boolean;
  protected
    FOnClose : TConsoleOnCloseEvent;
  public
    { Public declarations }
    function Log(data: string; p_color: cardinal): ansistring; overload;
    function Log: ansistring; overload;
    function Log(data: string): ansistring; overload;
    function Log(data: string; pColor: Tcolor): ansistring; overload;
    function Log(data: string; pColor: TColor; bold: boolean): ansistring; overload;
    procedure Error(data: string);
    function WriteDump(data:ansistring): ansistring;
    procedure Clear;
    property Title: string read getTitle write setTitle;
    property OnClose: TConsoleOnCloseEvent read FOnClose write FOnClose;
  end;

var
  Console: TConsole;

const
  C_TAB: char       = #$09;
  C_NL: string      = #13#10;
  C_BLACK           = clBlack;
  C_GREEN           = clGreen;
  C_RED             = clRed;
  C_BLUE            = clBlue;
  C_FUSH            = clFuchsia;
  C_ORANGE          = $008CFF;

implementation

{$R *.dfm}

procedure TConsole.clear;
begin
  DebugInfo.Clear;
end;

procedure TConsole.Clear1Click(Sender: TObject);
begin
  Clear;
end;

procedure TConsole.Close1Click(Sender: TObject);
begin
  close;
end;

procedure TConsole.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  m_displayed := false;
  if Assigned(FOnClose) then begin
    FOnClose;
  end;
end;

procedure TConsole.FormShow(Sender: TObject);
begin
  left := Screen.WorkAreaRect.Left;
  top := Screen.WorkAreaRect.Bottom - height;
  m_displayed := true;
end;

function TConsole.log: ansistring;
begin
  result := log('');
end;

procedure TConsole.Error(data: string);
begin
  self.Log(data, C_RED);
end;

function TConsole.log(data: string; p_color: cardinal): ansistring;
var
  wColor: TColor;
begin
  case p_color of
    0 : wColor := clBlack;
    1 : wColor := clGreen;
    2 : wColor := clRed;
    else wColor := clBlack;
  end;

  log(data, wColor);
end;

function TConsole.Log(data: string): ansistring;
begin
  result := log(data, clWindowText);
end;

function TConsole.log(data: string; pColor: TColor): ansistring;
begin
  result := log(data, pColor, false);
end;

function GetConsoleAttributes(pColor: TColor): Word;
begin
  case pColor of
    clRed:
      Exit(FOREGROUND_RED);
    clBlue:
      Exit(FOREGROUND_RED or FOREGROUND_GREEN or FOREGROUND_INTENSITY);
    clGreen:
      Exit(FOREGROUND_GREEN or FOREGROUND_INTENSITY);
    else
      Exit(
        FOREGROUND_RED or
        FOREGROUND_GREEN or
        FOREGROUND_BLUE
      );
  end;
end;

function TConsole.log(data: string; pColor: TColor; bold: boolean): ansistring;
var
  logFile: TextFile;
begin

  {$IFDEF CONSOLE}
  SetConsoleTextAttribute(
    GetStdHandle(STD_OUTPUT_HANDLE),
    GetConsoleAttributes(pColor)
  );

  WriteLn(data);
  {$ELSE}
  with DebugInfo do
  begin
    SelStart := GetTextLen; // move to the end
    SelAttributes.Color := pColor;
    if bold then
    begin
      SelAttributes.Style := [fsBold];
    end;
    SelText := data + C_NL;
  end;
  result := data;
  {$ENDIF}

  //AssignFile(logFile, 'log.txt');
  //Append(logFile);
  //WriteLn(logFile, data);
  //CloseFile(logFile);

end;

function TConsole.writeDump(data:ansistring): ansistring;
var
  nlog:ansistring;
  offset:DWORD;
  x,y:integer;
  value,pos:byte;
begin
  with DebugInfo do
  begin
    nlog := '';
    pos := 0;
    offset := 0;
    log;
    nlog := '  offset   0  1  2  3  4  5  6  7   8  9  A  B  C  D  E  F';
    log(nlog, $00A5A5A5);
    nlog := '';

    for x := 1 to length(data) do
    begin
      if pos = 0 then nlog := nlog + inttohex(offset, 8) + '  ';
    pansichar(@value)[0] := data[x];
    nlog := nlog + inttohex(value, 2) + ' ';
    if pos = 7 then
    begin
      nlog := nlog + ' ';
      inc(pos);
    end else inc(pos);
    if pos = 16 then
    begin
      nlog := nlog+'   ';
      for y := 1 to 16 do
      begin
        if integer(data[y + offset]) < 32 then nlog := nlog + '.'
        else nlog := nlog + data[y + offset];
      end;
      log(nlog);
      nlog := '';

      offset := offset + 16;
      pos := 0;
    end;
  end;

  if length(data) < offset + 16 then
  begin
    if (16 - (length(data) - offset)) > 0 then
      for y := 0 to (15 - (length(data) - offset)) do
      begin
        if y = 8 then
        begin
          nlog := nlog + '    ';
        end else
        begin
          nlog := nlog + '   ';
        end;
      end;

    nlog := nlog+'   ';
    for y := 1 to 16 - (16 - (length(data) - offset)) do
    begin
      if integer(data[y + offset]) < 32 then nlog := nlog + '.'
      else nlog := nlog + data[y + offset];
    end;
    log(nlog);
    nlog := '';
  end;
  log;
end;

end;

procedure TConsole.setTitle(title: string);
begin
  caption := title;
end;

function TConsole.getTitle: string;
begin
  result := caption;
end;

end.
