unit Client;

interface

uses
  ScktComp, Buffer, ClientPacket, CryptLib;

type
  TClient<ClientType> = class
    protected
      var m_buffout: TBuffer;
      var m_socket: TCustomWinSocket;
      var m_key: Byte;
      var m_data: ClientType;
      var m_cryptLib: TCryptLib;
    public
      constructor Create(Socket: TCustomWinSocket; cryptLib: TCryptLib);
      destructor Destroy; override;
      function GetKey: Byte;
      procedure Send(data: AnsiString); overload;
      procedure Send(data: AnsiString; encrypt: Boolean); overload;
      property Data: ClientType read m_data write m_data;
  end;

implementation

uses ConsolePas;

procedure TClient<ClientType>.Send(data: AnsiString);
begin
  self.Send(data, true);
end;

procedure TClient<ClientType>.Send(data: AnsiString; encrypt: Boolean);
begin
  if encrypt then
  begin
    m_buffout.Write(m_cryptLib.ServerEncrypt(data, m_key));
  end else
  begin
    m_buffout.Write(data);
  end;
end;


constructor TClient<ClientType>.Create(Socket: TCustomWinSocket; cryptLib: TCryptLib);
begin
  m_key := 2;
  m_cryptLib := cryptLib;
  m_socket := socket;
  m_buffout := TBuffer.Create
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

end.
