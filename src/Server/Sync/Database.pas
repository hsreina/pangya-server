unit Database;

interface

uses
  FireDAC.Stan.Intf, FireDAC.Stan.Option,
  FireDAC.Stan.Error, FireDAC.UI.Intf, FireDAC.Phys.Intf, FireDAC.Stan.Def,
  FireDAC.Stan.Pool, FireDAC.Stan.Async, FireDAC.Phys, Data.DB,
  FireDAC.Comp.Client, FireDAC.Stan.ExprFuncs, FireDAC.Phys.SQLiteDef,
  FireDAC.Phys.SQLite, FireDAC.ConsoleUI.Wait, FireDac.Dapt, sysUtils,
  PacketData, PlayerCharacters, Classes, PlayerData;

type
  TDatabase = class
    private
      m_connection: TFDConnection;
      m_physDriver: TFDPhysSQLiteDriverLink;
      m_query: TFDQuery;
    public

      constructor Create;
      destructor Destroy; override;

      function DoLogin(userName: AnsiString; password: AnsiString): Integer;
      function GetPlayerId(userName: AnsiString): Integer;
      function NicknameAvailable(nickname: AnsiString): Boolean;
      function SetNickname(playerId: integer; nickname: AnsiString): Boolean;
      function PlayerHaveNicknameSet(playerUID: AnsiString): Boolean;
      function PlayerHaveAnInitialCharacter(playerUID: AnsiString): Boolean;

      procedure SavePlayerCharacters(playerId: integer; playerCharacters: TPlayerCharacters);
      function GetPlayerCharacter(playerId: integer): AnsiString;

      procedure SavePlayerMainSave(playerId: integer; playerData: TPlayerData);
      function GetPlayerMainSave(playerid: integer): AnsiString;
      function CreatePlayer(login, password: AnsiString; playerData: TPlayerData): Integer;

      procedure Init;
  end;

implementation

uses ConsolePas;

constructor TDatabase.Create;
var
  dbPath: string;
begin
  inherited;
  FFDGUIxProvider := 'Console';
  m_connection := TFDConnection.Create(nil);
  m_physDriver := TFDPhysSQLiteDriverLink.Create(nil);
  m_query := TFDQuery.Create(nil);

  dbPath := ExtractFilePath(ParamStr(0)) + '..\data\players.db';

  m_connection.DriverName := 'SQLITE';
  m_connection.Params.Values['Database'] := dbPath;
  m_connection.Params.Values['OpenMode'] := 'CreateUTF8';
  m_connection.Params.Values['DateTimeFormat'] := 'String';

  m_connection.Connected := true;

  m_query.Connection := m_connection;
end;

destructor TDatabase.Destroy;
begin
  inherited;
  m_connection.Free;
  m_physDriver.Free;
  m_query.Free;
end;

procedure TDatabase.Init;
var
  test: integer;
begin
  try
    m_connection.Open;
    Console.Log('connection success');

    m_connection.ExecSQL(
      'CREATE TABLE IF NOT EXISTS "player" ("id" INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL , "login" varchar(16) NOT NULL, "password" varchar(32) NOT NULL, "nickname" varchar(16), "cookies" INTEGER NOT NULL  DEFAULT 0, "data" BLOB NOT NULL);'
    );
    m_connection.ExecSQL(
      'CREATE TABLE IF NOT EXISTS "character" ("id" INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL, "player_id" INTEGER NOT NULL, "data" BLOB NOT NULL);'
    );
    //m_connection.ExecSQL('INSERT INTO "player" ("login","password","nickname") VALUES ("hsreina", "5F4DCC3B5AA765D61D8327DEB882CF99", "hsreina");');

  except
    on E: EDatabaseError do
    begin
      Console.Log('Exception raised with message' + E.Message, C_RED);
    end;
  end;
end;

function TDatabase.NicknameAvailable(nickname: AnsiString): Boolean;
var
  query: TFDQuery;
begin
  query := TFDQuery.Create(nil);
  try
    query.Connection := m_connection;
    query.SQL.Text := 'SELECT 1 FROM player WHERE nickname = :nickname LIMIT 1';
    query.ParamByName('nickname').AsAnsiString := nickname;
    query.Open();
    Exit(query.RowsAffected = 0);
  finally
    query.Close;
    query.DisposeOf;
  end;
end;

function TDatabase.PlayerHaveAnInitialCharacter(playerUID: AnsiString): Boolean;
var
  query: TFDQuery;
begin
  query := TFDQuery.Create(nil);
  try
    query.Connection := m_connection;
    query.SQL.Text := 'SELECT 1 FROM player u INNER JOIN character c ON c.player_id = u.id WHERE u.login = :playerUID LIMIT 1';
    query.ParamByName('playerUID').AsAnsiString := playerUID;
    query.Open();
    Exit(query.RowsAffected = 1);
  finally
    query.Close;
    query.DisposeOf;
  end;
end;

function TDatabase.PlayerHaveNicknameSet(playerUID: AnsiString): Boolean;
var
  query: TFDQuery;
begin
  query := TFDQuery.Create(nil);
  try
    query.Connection := m_connection;
    query.SQL.Text := 'SELECT 1 FROM player WHERE login = :playerUID AND (nickname IS NOT NULL AND nickname <> '''') LIMIT 1';
    query.ParamByName('playerUID').AsAnsiString := playerUID;
    query.Open();
    Exit(query.RowsAffected = 1);
  finally
    query.Close;
    query.DisposeOf;
  end;
end;

function TDatabase.SetNickname(playerId: integer; nickname: AnsiString): Boolean;
var
  query: TFDQuery;
begin
  query := TFDQuery.Create(nil);
  try
    query.Connection := m_connection;
    query.SQL.Text := 'UPDATE player SET nickname = :nickname WHERE id= :player_id';
    query.ParamByName('nickname').AsAnsiString := nickname;
    query.ParamByName('player_id').AsInteger := playerId;
    query.ExecSQL();
    Exit(query.RowsAffected = 1);
  finally
    query.Close;
    query.DisposeOf;
  end;
end;

function TDatabase.GetPlayerId(userName: AnsiString): Integer;
var
  query: TFDQuery;
begin
  Result := 0;
  query := TFDQuery.Create(nil);
  try
    query.Connection := m_connection;
    query.SQL.Text := 'SELECT id FROM player WHERE login = :login';
    Console.Log(Format('query : %s', [query.SQL.Text]), C_RED);
    query.ParamByName('login').AsAnsiString := userName;
    query.Open();

    if query.RowsAffected = 1 then
    begin
      Result := query.FieldByName('id').AsInteger;
    end;

  finally
    query.Close;
    query.DisposeOf;
  end;
end;


function TDatabase.DoLogin(userName: AnsiString; password: AnsiString): integer;
var
  query: TFDQuery;
begin
  Result := 0;
  query := TFDQuery.Create(nil);
  try
    query.Connection := m_connection;
    query.SQL.Text := 'SELECT id FROM player WHERE login = :login/* AND password = :password*/ LIMIT 1';
    Console.Log(Format('query : %s', [query.SQL.Text]), C_RED);
    query.ParamByName('login').AsAnsiString := userName;
    //query.ParamByName('password').AsAnsiString := password;
    query.Open();

    if query.RowsAffected = 1 then
    begin
      Result := query.FieldByName('id').AsInteger;
    end;

  finally
    query.Close;
    query.DisposeOf;
  end;
end;

procedure TDatabase.SavePlayerCharacters(playerId: integer; playerCharacters: TPlayerCharacters);
var
  query: TFDQuery;
begin
  query := TFDQuery.Create(nil);
  try
    query.Connection := m_connection;
    query.SQL.Text := 'INSERT OR REPLACE INTO "character" ("player_id", "data") VALUES (:player_id, :data)';
    query.ParamByName('data').AsBlob := playerCharacters.ToPacketData;
    query.ParamByName('player_id').AsInteger := playerId;
    query.ExecSQL;
  finally
    query.Close;
    query.DisposeOf;
  end;
end;

function TDatabase.GetPlayerCharacter(playerId: integer): AnsiString;
var
  query: TFDQuery;
begin
  query := TFDQuery.Create(nil);
  try
    query.Connection := m_connection;
    query.SQL.Text := 'SELECT "data" FROM "character" WHERE "player_id" = :player_id LIMIT 1;';
    query.ParamByName('player_id').AsInteger := playerId;
    query.Open();

    if query.RowsAffected = 1 then
    begin
      Result := query.FieldByName('data').AsString;
    end;

  finally
    query.Close;
    query.DisposeOf;
  end;
end;

procedure TDatabase.SavePlayerMainSave(playerId: integer; playerData: TPlayerData);
var
  query: TFDQuery;
begin
  query := TFDQuery.Create(nil);
  try
    query.Connection := m_connection;
    query.SQL.Text := 'UPDATE "player" SET data = :data WHERE id = :player_id;';
    query.ParamByName('data').AsBlob := playerData.ToPacketData;
    query.ParamByName('player_id').AsInteger := playerId;
    query.ExecSQL;
  finally
    query.Close;
    query.DisposeOf;
  end;
end;

function TDatabase.GetPlayerMainSave(playerid: integer): AnsiString;
var
  query: TFDQuery;
begin
  query := TFDQuery.Create(nil);
  try
    query.Connection := m_connection;
    query.SQL.Text := 'SELECT "data" FROM "player" WHERE "id" = :player_id LIMIT 1;';
    query.ParamByName('player_id').AsInteger := playerId;
    query.Open();

    if query.RowsAffected = 1 then
    begin
      Result := query.FieldByName('data').AsString;
    end;

  finally
    query.Close;
    query.DisposeOf;
  end;
end;

function TDatabase.CreatePlayer(login, password: AnsiString; playerData: TPlayerData): Integer;
var
  query: TFDQuery;
begin
  query := TFDQuery.Create(nil);
  try
    query.Connection := m_connection;
    query.SQL.Text := 'INSERT INTO "player" ("login", "password", "data") VALUES (:login, :password, :data)';
    query.ParamByName('login').AsString := login;
    query.ParamByName('password').AsString := password;
    query.ParamByName('data').AsBlob := playerData.ToPacketData;
    query.ExecSQL;

    Result := m_connection.GetLastAutoGenValue('player');

  finally
    query.Close;
    query.DisposeOf;
  end;
end;

end.
