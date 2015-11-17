unit LobbiesList;

interface

uses
  Generics.Collections, Lobby, PacketData;

type

  TLobbyList = TList<TLobby>;

  TLobbiesList = class
    protected
    private
      var m_lobbies: TLobbyList;
    public

      function GetLobbyById(lobbyId: Byte): TLobby;

      function Build: TPacketData;

      constructor Create;
      destructor Destroy; override;
  end;

implementation

function TLobbiesList.GetLobbyById(lobbyId: Byte): TLobby;
var
  lobby: TLobby;
begin
  for lobby in m_lobbies do
  begin
    if lobby.Id = lobbyId then
    begin
      Exit(lobby);
    end;
  end;
  Exit(nil);
end;

constructor TLobbiesList.Create;
var
  lobby: TLobby;
  index: integer;
begin
  m_lobbies := TLobbyList.Create;
  lobby := TLobby.Create;
  lobby.Id := m_lobbies.Add(lobby);
end;

destructor TLobbiesList.Destroy;
var
  lobby: TLobby;
begin
  for lobby in m_lobbies do
  begin
    lobby.Free;
  end;
  m_lobbies.Free;
end;

function TLobbiesList.Build: TPacketData;
var
  lobby: TLobby;
begin
  Result := #$4D#$00 + #$01;
  for lobby in m_lobbies do
  begin
    Result := Result + lobby.Build;
  end;
end;

end.
