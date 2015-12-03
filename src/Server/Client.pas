unit Client;

interface

uses
  ScktComp, ClientPacket, CryptLib, defs, PangyaBuffer, SysUtils, utils;

type

  TClient<ClientType> = class
    protected
      var m_buffout: TPangyaBuffer;
      var m_socket: TCustomWinSocket;
      var m_key: Byte;
      var m_cryptLib: TCryptLib;
      function FGetHost: AnsiString;
    public
      constructor Create(Socket: TCustomWinSocket; cryptLib: TCryptLib);
      destructor Destroy; override;

      function GetKey: Byte;
      procedure Send(data: TPangyaBuffer); overload;
      procedure Send(data: AnsiString); overload;
      procedure Send(data: AnsiString; encrypt: Boolean); overload;
      function HasUID(playerUID: TPlayerUID): Boolean;

      procedure Disconnect;

      property Host: AnsiString read FGetHost;

      var Data: ClientType;
      var UID: TPlayerUID;
      var ID: integer;
  end;

implementation

uses ConsolePas;

function TClient<ClientType>.FGetHost: AnsiString;
begin
  Exit('www.google.com');
  //Exit(m_socket.RemoteHost);
end;

procedure TClient<ClientType>.Send(data: TPangyaBuffer);
var
  oldPos: Integer;
  size: integer;
  buff: AnsiString;
begin
  oldPos := data.Seek(0, 1);
  data.Seek(0, 0);
  size := data.GetSize;
  data.ReadStr(buff, size);
  self.Send(buff);
  data.Seek(oldPos, 0);
end;

procedure TClient<ClientType>.Send(data: AnsiString);
begin
  self.Send(data, true);
end;

procedure TClient<ClientType>.Send(data: AnsiString; encrypt: Boolean);
var
  encrypted: AnsiString;
begin
  if encrypt then
  begin
    if (UID.login = 'Sync') then
    begin
      encrypted := m_cryptLib.ClientEncrypt(data, m_key, 0);
      m_buffout.WriteStr(encrypted);
    end else
    begin
      Console.Log(Format('Send to %d %s', [UID.id, UID.login]));
      Console.WriteDump(data);
      encrypted := m_cryptLib.ServerEncrypt(data, m_key);
      m_buffout.WriteStr(encrypted);
    end;
  end else
  begin
    m_buffout.WriteStr(data);
  end;
end;

constructor TClient<ClientType>.Create(Socket: TCustomWinSocket; cryptLib: TCryptLib);
var
  rnd: Byte;
begin
  //rnd := Byte(Random(255));
  m_key := 2;
  m_cryptLib := cryptLib;
  m_socket := socket;
  m_buffout := TPangyaBuffer.Create;
end;

destructor TClient<ClientType>.Destroy;
begin
  inherited;
  m_buffout.Free;
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
  m_socket.Close;
end;

end.
