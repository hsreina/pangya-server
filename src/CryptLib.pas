unit CryptLib;

interface

uses
  windows;

type

  pheader = ^header;
  header = packed record
    size: integer;
    data: pansichar;
  end;

  TPangyaClientDecrypt = function(data: pansichar; size: integer; key: byte): header; cdecl;
  TPangyaClientEncrypt = function(data: pansichar; size: integer; key: byte; packetid: byte): header; cdecl;
  TPangyaServerEncrypt = function(data: pansichar; size: integer; key: byte): header; cdecl;
  TPangyaServerDecrypt = function(data: pansichar; size: integer; key: byte): header; cdecl;
  TPangyaDeserialize = function(value: UInt32): UInt32; cdecl;

  TCryptLib = class
    private
      var m_pangyaClientDecrypt: TPangyaClientDecrypt;
      var m_pangyaClientEncrypt: TPangyaClientEncrypt;
      var m_pangyaServerEncrypt: TPangyaServerEncrypt;
      var m_pangyaServerDecrypt: TPangyaServerDecrypt;
      var m_deserialize: TPangyaDeserialize;
      var m_init_ok: Boolean;
    public
      function ClientDecrypt(data: AnsiString; key:Byte): AnsiString;
      function ClientEncrypt(data: AnsiString; key:Byte; packetid: byte): AnsiString;
      function ServerEncrypt(data: AnsiString; key:Byte): AnsiString;
      function ServerDecrypt(data: ansistring; key: byte): ansistring;
      function Deserialize(value: UInt32): UInt32;
      function Init: Boolean;
      constructor Create;
      destructor Destroy; override;
    end;

  implementation

function TCryptLib.ClientDecrypt(data: AnsiString; key: Byte): AnsiString;
var
  head: header;
begin
  head := m_pangyaClientDecrypt(pansichar(data), length(data), key);
  setLength(result, head.size);
  move(head.data[0], result[1], head.size);
end;

function TCryptLib.ClientEncrypt(data: ansistring; key: byte; packetid: byte): ansistring;
var
  head: header;
begin
  head := m_pangyaClientEncrypt(pansichar(data), length(data), key, packetid);
  setLength(result, head.size);
  move(head.data[0], result[1], head.size);
end;

function TCryptLib.ServerEncrypt(data: AnsiString; key: Byte): AnsiString;
var
  head: header;
begin
  head :=
    m_pangyaServerEncrypt(pansichar(data), length(data), key);
  setLength(result, head.size);
  move(head.data[0], result[1], head.size);
end;

function TCryptLib.ServerDecrypt(data: ansistring; key: byte): ansistring;
var
  head: header;
begin
  head :=
    m_pangyaServerDecrypt(pansichar(data), length(data), key);
  setLength(result, head.size);
  move(head.data[0], result[1], head.size);
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

  m_deserialize := GetProcAddress(hInst, '_deserialize');
  if @m_deserialize = nil then
  begin
    Exit(False);
  end;

  m_init_ok := true;

  result := m_init_ok;
end;

function TCryptLib.Deserialize(value: UInt32): UInt32;
begin
  Result := m_deserialize(value);
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
