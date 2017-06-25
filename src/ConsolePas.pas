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
  System.UITypes, SyncObjs;

type

  TColor = -$7FFFFFFF-1..$7FFFFFFF;

  TConsole = class
  private
    { Private declarations }
    var m_lock: TCriticalSection;
  public
    { Public declarations }
    function Log(data: string; p_color: cardinal): RawByteString; overload;
    function Log: RawByteString; overload;
    function Log(data: string): RawByteString; overload;
    function Log(data: string; pColor: TColor): RawByteString; overload;
    function Log(data: string; pColor: TColor; bold: boolean): RawByteString; overload;
    procedure Error(data: string);
    procedure WriteDump(data: RawByteString);
    constructor Create;
    destructor Destroy; override;
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
  C_ORANGE          = TColors.Orange;

implementation

constructor TConsole.Create;
begin
  inherited;
  m_lock := TCriticalSection.Create;
end;

destructor TConsole.Destroy;
begin
  m_lock.Free;
  inherited;
end;

function TConsole.log: RawByteString;
begin
  result := log('');
end;

procedure TConsole.Error(data: string);
begin
  self.Log(data, C_RED);
end;

function TConsole.log(data: string; p_color: cardinal): RawByteString;
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

function TConsole.Log(data: string): RawByteString;
begin
  result := log(data, TColors.SysWindowText);
end;

function TConsole.log(data: string; pColor: TColor): RawByteString;
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
    TColors.Orange:
      Exit(FOREGROUND_RED or FOREGROUND_INTENSITY);
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
function TConsole.log(data: string; pColor: TColor; bold: boolean): RawByteString;
var
  currentThreadId: UInt32;
begin
  m_lock.Enter;
{$IFDEF MSWINDOWS}

  SetConsoleTextAttribute(
    GetStdHandle(STD_OUTPUT_HANDLE),
    GetConsoleAttributes(pColor)
  );

  WriteLn(data);

{$ELSE}
  WriteLn(data);
{$ENDIF}
  m_lock.Leave;
end;

procedure TConsole.writeDump(data: RawByteString);
var
  nlog: RawByteString;
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
    value := byte(data[x]);
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

initialization

  Console := TConsole.Create;

finalization

  Console.Free;

end.
