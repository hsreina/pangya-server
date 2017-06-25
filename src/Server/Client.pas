{*******************************************************}
{                                                       }
{       Pangya Server                                   }
{                                                       }
{       Copyright (C) 2015 Shad'o Soft tm               }
{                                                       }
{*******************************************************}

unit Client;

interface

uses
  CryptLib, defs, SysUtils, utils, IdContext, Classes, Packet;

type

  TClient<ClientType> = class
    protected
      var m_key: Byte;
      var m_context: TIdContext;
      var m_cryptLib: TCryptLib;
      function FGetHost: RawByteString;
      var m_useIndy: Boolean;
    public
      constructor Create(const AContext: TIdContext; const cryptLib: TCryptLib); overload;
      destructor Destroy; override;

      function GetKey: Byte;
      procedure Send(data: TPacket; encrypt: Boolean = True); overload;
      procedure Send(data: RawByteString); overload;
      procedure Send(data: RawByteString; encrypt: Boolean); overload;
      function HasUID(playerUID: TPlayerUID): Boolean;

      procedure Disconnect;

      property Host: RawByteString read FGetHost;

      var Data: ClientType;
      var UID: TPlayerUID;
      var ID: integer;
  end;

implementation

uses ConsolePas;

function TClient<ClientType>.FGetHost: RawByteString;
begin
  Exit('www.google.com');
  //Exit(m_socket.RemoteHost);
end;

procedure TClient<ClientType>.Send(data: TPacket; encrypt: Boolean = True);
var
  size: integer;
begin
  size := data.GetSize;
  Send(data.ToStr, encrypt);
end;

procedure TClient<ClientType>.Send(data: RawByteString);
begin
  self.Send(data, true);
end;

procedure TClient<ClientType>.Send(data: RawByteString; encrypt: Boolean);
var
  encrypted: RawByteString;
  tmp: TMemoryStream;
begin

  if Length(data) = 0 then
  begin
    Console.Log('data too small');
    Exit;
  end;

  if encrypt then
  begin
    if (UID.login = 'Sync') then
    begin
      encrypted := m_cryptLib.ClientEncrypt(data, m_key, 0);
    end else
    begin
      encrypted := m_cryptLib.ServerEncrypt(data, m_key);
    end;
  end else
  begin
    encrypted := data;
  end;

  // tmp fix, with indy, we don't want anymore string as buffer
  tmp := TMemoryStream.Create;
  tmp.Write(encrypted[1], Length(encrypted));
  m_context.Connection.IOHandler.Write(tmp);
  tmp.free;
end;

constructor TClient<ClientType>.Create(const AContext: TIdContext; const cryptLib: TCryptLib);
var
  rnd: Byte;
begin
  inherited Create;
  m_context := AContext;
  m_useIndy := true;
  Randomize;
  rnd := Byte(Random(9));
  m_key := rnd;
  m_cryptLib := cryptLib;
end;

destructor TClient<ClientType>.Destroy;
begin
  inherited;
end;

function TClient<ClientType>.GetKey: Byte;
begin
  Result := m_key;
end;

function TClient<ClientType>.HasUID(playerUID: TPlayerUID): Boolean;
begin
  if (UID.id = 0) then
  begin
    Exit(playerUID.login = UID.login);
  end;

  Exit(playerUID.id = UID.id);
end;

procedure TClient<ClientType>.Disconnect;
begin
  m_context.Connection.Disconnect;
end;

end.
