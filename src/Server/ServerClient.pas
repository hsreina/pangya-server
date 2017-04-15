{*******************************************************}
{                                                       }
{       Pangya Server                                   }
{                                                       }
{       Copyright (C) 2015 Shad'o Soft tm               }
{                                                       }
{*******************************************************}

unit ServerClient;

interface

uses Client, Buffer, ScktComp, CryptLib, IdContext;

type
  TServerClient<ClientType> = class (TClient<ClientType>)
    private
      var m_buffin: TBuffer;
      var m_context: TIdContext;
    public
      constructor Create(const Socket: TCustomWinSocket; const cryptLib: TCryptLib); overload;
      constructor Create(const AContext: TIdContext; const cryptLib: TCryptLib); overload;
      destructor Destroy; override;
      function GetBuffin: TBuffer;
      function HasSocket(Socket: TCustomWinSocket): Boolean;
      procedure ReceiveData(data: AnsiString);
      procedure HandleSend;
  end;

implementation

procedure TServerClient<ClientType>.ReceiveData(data: AnsiString);
begin
  m_buffin.Write(data);
end;

constructor TServerClient<ClientType>.Create(const Socket: TCustomWinSocket; const cryptLib: TCryptLib);
begin
  inherited;
  m_buffin := TBuffer.Create;
end;

constructor TServerClient<ClientType>.Create(const AContext: TIdContext; const cryptLib: TCryptLib);
begin
  inherited;
  m_buffin := TBuffer.Create;
end;

destructor TServerClient<ClientType>.Destroy;
begin
  inherited;
  m_buffin.Free;
  m_buffin := nil;
end;

function TServerClient<ClientType>.GetBuffin: TBuffer;
begin
  Result := m_buffin;
end;

procedure TServerClient<ClientType>.handleSend;
begin
  if (m_buffout.GetSize > 0) then
  begin
    if not (m_buffin = nil) then
    begin
      m_socket.SendStream(m_buffout.ToStream);
    end;
  end;
end;

function TServerClient<ClientType>.HasSocket(Socket: TCustomWinSocket): Boolean;
begin
  Exit(m_socket = Socket);
end;

end.
