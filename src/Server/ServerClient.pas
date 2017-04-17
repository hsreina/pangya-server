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
      //var m_buffin: TBuffer;
      var m_context: TIdContext;
    public
      constructor Create(const Socket: TCustomWinSocket; const cryptLib: TCryptLib); overload;
      constructor Create(const AContext: TIdContext; const cryptLib: TCryptLib); overload;
      destructor Destroy; override;
      function HasSocket(Socket: TCustomWinSocket): Boolean;
  end;

implementation

constructor TServerClient<ClientType>.Create(const Socket: TCustomWinSocket; const cryptLib: TCryptLib);
begin
  inherited;
end;

constructor TServerClient<ClientType>.Create(const AContext: TIdContext; const cryptLib: TCryptLib);
begin
  inherited;
end;

destructor TServerClient<ClientType>.Destroy;
begin
  inherited;
end;

function TServerClient<ClientType>.HasSocket(Socket: TCustomWinSocket): Boolean;
begin
  Exit(m_socket = Socket);
end;

end.
