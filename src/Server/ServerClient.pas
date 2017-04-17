{*******************************************************}
{                                                       }
{       Pangya Server                                   }
{                                                       }
{       Copyright (C) 2015 Shad'o Soft tm               }
{                                                       }
{*******************************************************}

unit ServerClient;

interface

uses Client, Buffer, CryptLib, IdContext;

type
  TServerClient<ClientType> = class (TClient<ClientType>)
    private
      var m_context: TIdContext;
    public
      constructor Create(const AContext: TIdContext; const cryptLib: TCryptLib); overload;
      destructor Destroy; override;
  end;

implementation

constructor TServerClient<ClientType>.Create(const AContext: TIdContext; const cryptLib: TCryptLib);
begin
  inherited;
end;

destructor TServerClient<ClientType>.Destroy;
begin
  inherited;
end;

end.
