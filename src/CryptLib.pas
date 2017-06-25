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
  SysUtils, Types.PangyaBytes, Types.PangyaTypes;

type

  TCryptLib = class
    private
      var m_init_ok: Boolean;
    public
      function ClientDecrypt(data: RawByteString; key: Byte): RawByteString;
      function ClientDecrypt2(const buffin: TPangyaBytes; var buffout: TPangyaBytes; const key: Byte): Boolean;
      function ClientEncrypt(data: RawByteString; key: Byte; packetid: byte): RawByteString;
      function ServerEncrypt(data: RawByteString; key: Byte): RawByteString;
      function ServerDecrypt(data: RawByteString; key: byte): RawByteString;
      function Deserialize(value: UInt32): UInt32;
      constructor Create;
      destructor Destroy; override;
    end;

implementation

{$IFDEF LINUX}
const LIBNAME = 'libpang.a';
const _pangya_client_decrypt = 'pangya_client_decrypt';
const _pangya_client_encrypt = 'pangya_client_encrypt';
const _pangya_server_encrypt = 'pangya_server_encrypt';
const _pangya_server_decrypt = 'pangya_server_decrypt';
const _pangya_free = 'pangya_free';
const _pangya_deserialize = 'pangya_deserialize';
{$ENDIF}
{$IFDEF MSWINDOWS}
{$IFDEF CPUX64}
const LIBNAME = 'pang64.dll';
{$ELSE}
const LIBNAME = 'pang.dll';
{$ENDIF}
const _pangya_client_decrypt = 'pangya_client_decrypt';
const _pangya_client_encrypt = 'pangya_client_encrypt';
const _pangya_server_encrypt = 'pangya_server_encrypt';
const _pangya_server_decrypt = 'pangya_server_decrypt';
const _pangya_free = 'pangya_free';
const _pangya_deserialize = 'pangya_deserialize';
{$ENDIF}
{$IFDEF MACOS}
const LIBNAME = 'pang.dylib';
const _pangya_client_decrypt = '__Z21pangya_client_decryptPhjPS_Pjh';
const _pangya_client_encrypt = '__Z21pangya_client_encryptPhjPS_Pjhh';
const _pangya_server_encrypt = '__Z21pangya_server_encryptPhjPS_Pjh';
const _pangya_server_decrypt = '__Z21pangya_server_decryptPhjPS_Pjh';
const _pangya_free = '__Z11pangya_freePPh';
const _pangya_deserialize = '__Z18pangya_deserializej';
{$ENDIF}

function pangyaClientDecrypt(buffin: PUTF8Char; size: UInt32;
  buffout: PPUTF8Char; buffoutSize: PUInt32; key: UInt8): UInt32;
  cdecl; external LIBNAME name _pangya_client_decrypt
  {$IFDEF LINUX}dependency LibCPP{$ENDIF};

function pangyaClientEncrypt(buffin: PUTF8Char; size: UInt32; buffout:
  PPUTF8Char; buffoutSize: PUInt32; key: UInt8; packetId: UInt8): UInt32;
  cdecl; external LIBNAME name _pangya_client_encrypt
  {$IFDEF LINUX}dependency LibCPP{$ENDIF};

function pangyaServerEncrypt(buffin: PUTF8Char; size: UInt32; buffout:
  PPUTF8Char; buffoutSize: PUInt32; key: UInt8): UInt32;
  cdecl; external LIBNAME name _pangya_server_encrypt
  {$IFDEF LINUX}dependency LibCPP{$ENDIF};

function pangyaServerDecrypt(buffin: PUTF8Char; size: UInt32;
  buffout: PPUTF8Char; buffoutSize: PUInt32; key: UInt8): UInt32;
  cdecl; external LIBNAME name _pangya_server_decrypt
  {$IFDEF LINUX}dependency LibCPP{$ENDIF};

procedure pangyaFree(buffout: PPUTF8Char);
  cdecl; external LIBNAME name _pangya_free
  {$IFDEF LINUX}dependency LibCPP{$ENDIF};

//function pangyaDeserialize(value: UInt32): UInt32;
//  cdecl; external LIBNAME name _pangya_deserialize
//  {$IFDEF LINUX}dependency LibCPP{$ENDIF};

function TCryptLib.ClientDecrypt(data: RawByteString; key: Byte): RawByteString;
var
  buffout: PUTF8Char;
  buffoutSize: UInt32;
  res: UInt32;
begin

  res := pangyaClientDecrypt(
    PUTF8Char(data),
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
  buffoutSize: UInt32;
  res: UInt32;
begin

  res := pangyaClientDecrypt(
    PUTF8Char(@buffin[0]),
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


function TCryptLib.ClientEncrypt(data: RawByteString; key: byte; packetId: Byte): RawByteString;
var
  buffout: PUTF8Char;
  buffoutSize: UInt32;
  res: UInt32;
begin

  res := pangyaClientEncrypt(
    PUTF8Char(data),
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

function TCryptLib.ServerEncrypt(data: RawByteString; key: Byte): RawByteString;
var
  buffout: PUTF8Char;
  buffoutSize: UInt32;
  res: UInt32;
begin

  res := pangyaServerEncrypt(
    PUTF8Char(data),
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

function TCryptLib.ServerDecrypt(data: RawByteString; key: Byte): RawByteString;
var
  buffout: PUTF8Char;
  buffoutSize: UInt32;
  res: UInt32;
begin

  res := pangyaServerDecrypt(
    PUTF8Char(data),
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
  Result := 0;//pangyaDeserialize(value);
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
