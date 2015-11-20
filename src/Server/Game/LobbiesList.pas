unit LobbiesList;

interface

uses
  Generics.Collections, Lobby, PacketData, GamePlayer;

type

  TLobbyList = TList<TLobby>;

  TLobbiesList = class
    protected
    private
      var m_lobbies: TLobbyList;
      procedure DestroyLobbies;
    public
      constructor Create;
      destructor Destroy; override;
      function GetLobbyById(lobbyId: Byte): TLobby;
      function GetPlayerLobby(player: TGamePlayer): TLobby;
      function Build: TPacketData;
  end;

implementation

constructor TLobbiesList.Create;
var
  lobby: TLobby;
  index: integer;
begin
  inherited;
  m_lobbies := TLobbyList.Create;
  lobby := TLobby.Create;
  lobby.Id := m_lobbies.Add(lobby);
end;

destructor TLobbiesList.Destroy;
begin
  inherited;
  DestroyLobbies;
  m_lobbies.Free;
end;

procedure TLobbiesList.DestroyLobbies;
var
  lobby: TLobby;
begin
  for lobby in m_lobbies do
  begin
    lobby.Free;
  end;
end;

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

function TLobbiesList.GetPlayerLobby(player: TGamePlayer): TLobby;
var
  lobby: TLobby;
begin
  Exit(self.GetLobbyById(player.Lobby));
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
