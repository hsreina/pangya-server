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
  windows;

type

  TPangyaClientDecrypt = function(buffin: PAnsiChar; size: Integer; buffout: PPAnsiChar; buffoutSize: PInteger; key: Byte): Integer; cdecl;
  TPangyaClientEncrypt = function(buffin: PAnsiChar; size: Integer; buffout: PPAnsiChar; buffoutSize: PInteger; key: Byte; packetId: Byte): Integer; cdecl;
  TPangyaServerEncrypt = function(buffin: PAnsiChar; size: Integer; buffout: PPAnsiChar; buffoutSize: PInteger; key: Byte): Integer; cdecl;
  TPangyaServerDecrypt = function(buffin: PAnsiChar; size: Integer; buffout: PPAnsiChar; buffoutSize: PInteger; key: Byte): Integer; cdecl;
  TPangyaFree = procedure(buffout: PPansiChar); cdecl;
  TPangyaDeserialize = function(value: UInt32): UInt32; cdecl;

  TCryptLib = class
    private
      var m_pangyaClientDecrypt: TPangyaClientDecrypt;
      var m_pangyaClientEncrypt: TPangyaClientEncrypt;
      var m_pangyaServerEncrypt: TPangyaServerEncrypt;
      var m_pangyaServerDecrypt: TPangyaServerDecrypt;
      var m_pangyaFree: TPangyaFree;
      var m_pangyaDeserialize: TPangyaDeserialize;
      var m_init_ok: Boolean;
    public
      function ClientDecrypt(data: AnsiString; key: Byte): AnsiString;
      function ClientEncrypt(data: AnsiString; key: Byte; packetid: byte): AnsiString;
      function ServerEncrypt(data: AnsiString; key: Byte): AnsiString;
      function ServerDecrypt(data: ansistring; key: byte): ansistring;
      function Deserialize(value: UInt32): UInt32;
      function Init: Boolean;
      constructor Create;
      destructor Destroy; override;
    end;

  implementation

function TCryptLib.ClientDecrypt(data: AnsiString; key: Byte): AnsiString;
var
  buffout: PAnsiChar;
  buffoutSize: Integer;
  res: integer;
begin
  res := m_pangyaClientDecrypt(
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
    m_pangyaFree(@buffout);
  end;
end;

function TCryptLib.ClientEncrypt(data: AnsiString; key: byte; packetId: Byte): AnsiString;
var
  buffout: PAnsiChar;
  buffoutSize: Integer;
  res: integer;
begin
  res := m_pangyaClientEncrypt(
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
    m_pangyaFree(@buffout);
  end;
end;

function TCryptLib.ServerEncrypt(data: AnsiString; key: Byte): AnsiString;
var
  buffout: PAnsiChar;
  buffoutSize: Integer;
  res: integer;
begin
  res := m_pangyaServerEncrypt(
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
    m_pangyaFree(@buffout);
  end;
end;

function TCryptLib.ServerDecrypt(data: AnsiString; key: Byte): AnsiString;
var
  buffout: PAnsiChar;
  buffoutSize: Integer;
  res: integer;
begin
  res := m_pangyaServerDecrypt(
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
    m_pangyaFree(@buffout);
  end;
end;

function TCryptLib.Init;
var
  hInst: THandle;
begin

  if m_init_ok then
  begin
    Exit(true);
  end;

  result := false;

  hInst := LoadLibrary(pchar('pang.dll'));
  if hInst = 0 then
  begin
    Exit(result);
  end;

  m_pangyaClientDecrypt := GetProcAddress(hInst, '_pangya_client_decrypt');
  if @m_pangyaClientDecrypt = nil then
  begin
    Exit(result);
  end;

  m_pangyaClientEncrypt := GetProcAddress(hInst, '_pangya_client_encrypt');
  if @m_pangyaClientEncrypt = nil then
  begin
    Exit(result);
  end;

  m_pangyaServerEncrypt := GetProcAddress(hInst, '_pangya_server_encrypt');
  if @m_pangyaServerEncrypt = nil then
  begin
    Exit(False);
  end;

  m_pangyaServerDecrypt := GetProcAddress(hInst, '_pangya_server_decrypt');
  if @m_pangyaServerDecrypt = nil then
  begin
    Exit(False);
  end;

  m_pangyaFree := GetProcAddress(hInst, '_pangya_free');
  if @m_pangyaFree = nil then
  begin
    Exit(False);
  end;

  m_pangyaDeserialize := GetProcAddress(hInst, '_pangya_deserialize');
  if @m_pangyaDeserialize = nil then
  begin
    Exit(False);
  end;

  m_init_ok := true;

  result := m_init_ok;
end;

function TCryptLib.Deserialize(value: UInt32): UInt32;
begin
  Result := m_pangyaDeserialize(value);
end;

constructor TCryptLib.Create;
begin
  m_init_ok := false;
end;

destructor TCryptLib.Destroy;
begin
  inherited;
end;

end.
