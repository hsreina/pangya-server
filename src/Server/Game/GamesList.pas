unit GamesList;

interface

uses
  Generics.Collections, Game, GamePlayer;

type
  TGamesList = class
    private
      var m_games: TList<TGame>;
      var m_maxGames: UInt32;
    public
      constructor Create;
      destructor Destroy; override;
      function GetGameById(gameId: Byte): TGame;
      function getPlayerGame(player: TGamePlayer): TGame;
      procedure DestroyGames;
      function CreateGame(name, password: AnsiString; gameInfo: TPlayerCreateGameInfo; artifact: UInt32): TGame;
      procedure DestroyGame(game: Tgame);
  end;

implementation

uses GameServerExceptions;

constructor TGamesList.Create;
begin
  inherited;
  m_maxGames := 10;
  m_games := TList<TGame>.Create;
end;

destructor TGamesList.Destroy;
begin
  inherited;
  DestroyGames;
  m_games.Free;
end;

procedure TGamesList.DestroyGames;
var
  game: TGame;
begin
  for game in m_games do
  begin
    game.Free;
  end;
end;

function TGamesList.CreateGame(name, password: AnsiString; gameInfo: TPlayerCreateGameInfo; artifact: UInt32): TGame;
var
  game: TGame;
begin

  if m_games.Count >= m_maxGames then
  begin
    raise LobbyGamesFullException.CreateFmt('oups, too much game', []);
  end;

  game := TGame.Create(name, password, gameInfo, artifact);
  game.Id := m_games.Add(game);
  Result := game;
end;

procedure TGamesList.DestroyGame(game: TGame);
begin
  if not -1 = m_games.Remove(game) then begin
    game.Free;
  end;
end;

function TGamesList.GetGameById(gameId: Byte): TGame;
var
  game: TGame;
begin
  for game in m_games do
  begin
    if game.Id = gameId then
    begin
      Exit(game);
    end;
  end;
  Exit(nil);
end;

function TGamesList.getPlayerGame(player: TGamePlayer): TGame;
begin
  Exit(self.GetGameById(player.Data.playerInfo1.game));
end;

end.
