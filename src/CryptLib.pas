{*******************************************************}
{                                                       }
{       Pangya Server                                   }
{                                                       }
{       Copyright (C) 2015 Shad'o Soft tm               }
{                                                       }
{*******************************************************}

unit CryptLib;

interface

uses
{$IFDEF MSWINDOWS}
  windows,
{$ENDIF}
  SysUtils, Types.PangyaBytes;

{$IFDEF LINUX}
const LIBNAME = 'libpang.a';
{$ENDIF}
{$IFDEF MSWINDOWS}
const LIBNAME = 'pang.dll';
{$ENDIF}
{$IFDEF MACOS}
const LIBNAME = 'pang.dylib';
{$ENDIF}

type

  TCryptLib = class
    private
      var m_init_ok: Boolean;
    public
      function ClientDecrypt(data: AnsiString; key: Byte): AnsiString;
      function ClientDecrypt2(const buffin: TPangyaBytes; var buffout: TPangyaBytes; const key: Byte): Boolean;
      function ClientEncrypt(data: AnsiString; key: Byte; packetid: byte): AnsiString;
      function ServerEncrypt(data: AnsiString; key: Byte): AnsiString;
      function ServerDecrypt(data: ansistring; key: byte): ansistring;
      function Deserialize(value: UInt32): UInt32;
      constructor Create;
      destructor Destroy; override;
    end;

implementation

function pangyaClientDecrypt(buffin: PAnsiChar; size: Integer;
  buffout: PPAnsiChar; buffoutSize: PInteger; key: Byte): Integer;
  cdecl; external LIBNAME name '_pangya_client_decrypt'
  {$IFDEF LINUX}dependency LibCPP{$ENDIF};

function pangyaClientEncrypt(buffin: PAnsiChar; size: Integer; buffout:
  PPAnsiChar; buffoutSize: PInteger; key: Byte; packetId: Byte): Integer;
  cdecl; external LIBNAME name '_pangya_client_encrypt'
  {$IFDEF LINUX}dependency LibCPP{$ENDIF};

function pangyaServerEncrypt(buffin: PAnsiChar; size: Integer; buffout:
  PPAnsiChar; buffoutSize: PInteger; key: Byte): Integer;
  cdecl; external LIBNAME name '_pangya_server_encrypt'
  {$IFDEF LINUX}dependency LibCPP{$ENDIF};

function pangyaServerDecrypt(buffin: PAnsiChar; size: Integer;
  buffout: PPAnsiChar; buffoutSize: PInteger; key: Byte): Integer;
  cdecl; external LIBNAME name '_pangya_server_decrypt'
  {$IFDEF LINUX}dependency LibCPP{$ENDIF};

procedure pangyaFree(buffout: PPansiChar);
  cdecl; external LIBNAME name '_pangya_free'
  {$IFDEF LINUX}dependency LibCPP{$ENDIF};

function pangyaDeserialize(value: UInt32): UInt32;
  cdecl; external LIBNAME name '_pangya_deserialize'
  {$IFDEF LINUX}dependency LibCPP{$ENDIF};

function TCryptLib.ClientDecrypt(data: AnsiString; key: Byte): AnsiString;
var
  buffout: PAnsiChar;
  buffoutSize: Integer;
  res: integer;
begin

  res := pangyaClientDecrypt(
    PAnsiChar(data),
    Length(data),
    @buffout,
    @buffoutSize,
    key
  );

  if res > 0 then
  begin
    setLength(result, buffoutSize);
    move(buffout[0], result[1], buffoutSize);
    pangyaFree(@buffout);
  end;
end;

function TCryptLib.ClientDecrypt2(const buffin: TPangyaBytes; var buffout: TPangyaBytes; const key: Byte): Boolean;
var
  decryptedBuffer: PByte;
  buffoutSize: Integer;
  res: integer;
begin

  res := pangyaClientDecrypt(
    PAnsiChar(@buffin[0]),
    Length(buffin),
    @decryptedBuffer,
    @buffoutSize,
    key
  );

  if res > 0 then
  begin
    setLength(buffout, buffoutSize);
    move(decryptedBuffer[0], buffout[0], buffoutSize);
    pangyaFree(@decryptedBuffer);
  end;
end;


function TCryptLib.ClientEncrypt(data: AnsiString; key: byte; packetId: Byte): AnsiString;
var
  buffout: PAnsiChar;
  buffoutSize: Integer;
  res: integer;
begin

  res := pangyaClientEncrypt(
    PAnsiChar(data),
    Length(data),
    @buffout,
    @buffoutSize,
    key,
    packetId
  );

  if res > 0 then
  begin
    setLength(result, buffoutSize);
    move(buffout[0], result[1], buffoutSize);
    pangyaFree(@buffout);
  end;
end;

function TCryptLib.ServerEncrypt(data: AnsiString; key: Byte): AnsiString;
var
  buffout: PAnsiChar;
  buffoutSize: Integer;
  res: integer;
begin

  res := pangyaServerEncrypt(
    PAnsiChar(data),
    Length(data),
    @buffout,
    @buffoutSize,
    key
  );

  if res > 0 then
  begin
    setLength(result, buffoutSize);
    move(buffout[0], result[1], buffoutSize);
    pangyaFree(@buffout);
  end;
end;

function TCryptLib.ServerDecrypt(data: AnsiString; key: Byte): AnsiString;
var
  buffout: PAnsiChar;
  buffoutSize: Integer;
  res: integer;
begin

  res := pangyaServerDecrypt(
    PAnsiChar(data),
    Length(data),
    @buffout,
    @buffoutSize,
    key
  );

  if res > 0 then
  begin
    setLength(result, buffoutSize);
    move(buffout[0], result[1], buffoutSize);
    pangyaFree(@buffout);
  end;
end;

function TCryptLib.Deserialize(value: UInt32): UInt32;
begin
  Result := pangyaDeserialize(value);
end;

constructor TCryptLib.Create;
begin
  inherited;
  m_init_ok := false;
end;

destructor TCryptLib.Destroy;
begin
  inherited;
end;

end.
