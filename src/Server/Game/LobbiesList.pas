unit LobbiesList;

interface

uses
  Generics.Collections, Lobby, PacketData, GamePlayer, Game;

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
      function GetPlayerGame(player: TGamePlayer): TGame;
      function Build: TPacketData;
  end;

implementation

uses GameServerExceptions;

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
  raise LobbyNotFoundException.Create('Lobby not found');
end;

function TLobbiesList.GetPlayerLobby(player: TGamePlayer): TLobby;
begin
  Exit(self.GetLobbyById(player.Lobby));
end;

function TLobbiesList.GetPlayerGame(player: TGamePlayer): TGame;
var
  lobby: TLobby;
begin
  lobby := self.GetLobbyById(player.Lobby);
  lobby.Games.GetGameById(player.Data.playerInfo1.game);
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
