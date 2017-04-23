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

{$IFDEF MSWINDOWS}
  Windows,
{$ENDIF}
  SysUtils,
  Classes,
  System.UITypes;

type

  TColor = -$7FFFFFFF-1..$7FFFFFFF;

  TConsole = class
  private
    { Private declarations }
  public
    { Public declarations }
    function Log(data: string; p_color: cardinal): ansistring; overload;
    function Log: ansistring; overload;
    function Log(data: string): ansistring; overload;
    function Log(data: string; pColor: TColor): ansistring; overload;
    function Log(data: string; pColor: TColor; bold: boolean): ansistring; overload;
    procedure Error(data: string);
    procedure WriteDump(data: UTF8String);
  end;

var
  Console: TConsole;

const
  C_TAB: char       = #$09;
  C_NL: string      = #13#10;
  C_BLACK           = TColors.Black;
  C_GREEN           = TColors.Green;
  C_RED             = TColors.Red;
  C_BLUE            = TColors.Blue;
  C_FUSH            = TColors.Fuchsia;
  C_ORANGE          = $008CFF;

implementation

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
    0 : wColor := C_BLACK;
    1 : wColor := C_GREEN;
    2 : wColor := C_RED;
    else wColor := C_BLACK;
  end;

  log(data, wColor);
end;

function TConsole.Log(data: string): ansistring;
begin
  result := log(data, TColors.SysWindowText);
end;

function TConsole.log(data: string; pColor: TColor): ansistring;
begin
  result := log(data, pColor, false);
end;

{$IFDEF MSWINDOWS}
function GetConsoleAttributes(pColor: TColor): Word;
begin
  case pColor of
    TColors.Red:
      Exit(FOREGROUND_RED);
    TColors.Blue:
      Exit(FOREGROUND_RED or FOREGROUND_GREEN or FOREGROUND_INTENSITY);
    TColors.Green:
      Exit(FOREGROUND_GREEN or FOREGROUND_INTENSITY);
    else
      Exit(
        FOREGROUND_RED or
        FOREGROUND_GREEN or
        FOREGROUND_BLUE
      );
  end;
end;
{$ENDIF}

// Uggly temporary fix to log from other threads
function TConsole.log(data: string; pColor: TColor; bold: boolean): ansistring;
var
  currentThreadId: UInt32;
begin

{$IFDEF MSWINDOWS}
  currentThreadId := GetCurrentThreadId;

  if not (currentThreadId = MainThreadID) Then
  begin
    TThread.Synchronize(TThread.CurrentThread,
    procedure
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
      //result := data;
      {$ENDIF}
    end);
  end else
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
    //result := data;
    {$ENDIF}
  end;
{$ELSE}
  WriteLn(data);
{$ENDIF}
end;

procedure TConsole.writeDump(data: UTF8String);
var
  nlog: UTF8String;
  offset: UInt32;
  x, y: integer;
  value, pos: byte;
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
    if pos = 0 then
      nlog := nlog + IntToHex(offset, 8) + '  ';
    PUTF8Char(@value)[0] := data[x];
    nlog := nlog + IntToHex(value, 2) + ' ';
    if pos = 7 then
    begin
      nlog := nlog + ' ';
      inc(pos);
    end
    else
      inc(pos);
    if pos = 16 then
    begin
      nlog := nlog + '   ';
      for y := 1 to 16 do
      begin
        if integer(data[y + offset]) < 32 then
          nlog := nlog + '.'
        else
          nlog := nlog + data[y + offset];
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
        end
        else
        begin
          nlog := nlog + '   ';
        end;
      end;

    nlog := nlog + '   ';
    for y := 1 to 16 - (16 - (length(data) - offset)) do
    begin
      if integer(data[y + offset]) < 32 then
        nlog := nlog + '.'
      else
        nlog := nlog + data[y + offset];
    end;
    log(nlog);
    nlog := '';
  end;
  log;
end;

end.
