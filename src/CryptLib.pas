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
  TPangyaServerEncrypt = function(data: pansichar; size: integer; key: byte): header; cdecl;
  TPangyaDeserialize = function(value: UInt32): UInt32; cdecl;

  TCryptLib = class
    private
      var m_pangyaClientDecrypt: TPangyaClientDecrypt;
      var m_pangyaServerEncrypt: TPangyaServerEncrypt;
      var m_deserialize: TPangyaDeserialize;
      var m_init_ok: Boolean;
    public
      function ClientDecrypt(data: AnsiString; key:Byte): AnsiString;
      function ServerEncrypt(data: AnsiString; key:Byte): AnsiString;
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

function TCryptLib.ServerEncrypt(data: AnsiString; key: Byte): AnsiString;
var
  head: header;
begin
  head :=
    m_pangyaServerEncrypt(pansichar(data), length(data), key);
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

  m_pangyaServerEncrypt := GetProcAddress(hInst, '_pangya_server_encrypt');
  if @m_pangyaServerEncrypt = nil then
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
