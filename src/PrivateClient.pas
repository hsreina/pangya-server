unit PrivateClient;

interface

uses
  ScktComp, Buffer;

type
  TPrivateClient = class
    private
      var m_socket: TCustomWinSocket;
    public
      constructor Create(Socket: TCustomWinSocket);
      destructor Destroy; override;
  end;


implementation

constructor TPrivateClient.Create(Socket: TCustomWinSocket);
begin

end;

destructor TPrivateClient.Destroy;
begin
  inherited;
end;

end.
