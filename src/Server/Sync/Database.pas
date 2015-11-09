unit Database;

interface

uses
  FireDAC.Stan.Intf, FireDAC.Stan.Option,
  FireDAC.Stan.Error, FireDAC.UI.Intf, FireDAC.Phys.Intf, FireDAC.Stan.Def,
  FireDAC.Stan.Pool, FireDAC.Stan.Async, FireDAC.Phys, Data.DB,
  FireDAC.Comp.Client, FireDAC.Stan.ExprFuncs, FireDAC.Phys.SQLiteDef,
  FireDAC.Phys.SQLite, FireDAC.ConsoleUI.Wait, FireDac.Dapt, sysUtils;

type
  TDatabase = class
    private
      m_connection: TFDConnection;
      m_physDriver: TFDPhysSQLiteDriverLink;
      m_query: TFDQuery;
    public

      constructor Create;
      destructor Destroy; override;

      function DoLogin(userName: AnsiString; password: AnsiString): Boolean;
      function NicknameAvailable(nickname: AnsiString): Boolean;
      function SetNickname(playerUID: AnsiString; nickname: AnsiString): Boolean;
      function PlayerHaveNicknameSet(playerUID: AnsiString): Boolean;
      function PlayerHaveAnInitialCharacter(playerUID: AnsiString): Boolean;

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
begin
  try
    m_connection.Open;
    Console.Log('connection success');

    m_connection.ExecSQL('CREATE TABLE IF NOT EXISTS "player" ("id" INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL , "login" varchar(16) NOT NULL, "password" varchar(32) NOT NULL, "nickname" varchar(16));');
    m_connection.ExecSQL('CREATE TABLE IF NOT EXISTS "character" ("id" INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL, "player_id" INTEGER NOT NULL, "data" BLOB NOT NULL);');
    //m_connection.ExecSQL('INSERT INTO "player" ("login","password","nickname") VALUES ("hsreina", "5F4DCC3B5AA765D61D8327DEB882CF99", "hsreina");');

    if PlayerHaveAnInitialCharacter('hsreina') then
    begin
      Console.Log('Yes', C_GREEN);
    end else
    begin
      Console.Log('No', C_RED);
    end;

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

function TDatabase.SetNickname(playerUID: AnsiString; nickname: AnsiString): Boolean;
var
  query: TFDQuery;
begin
  query := TFDQuery.Create(nil);
  try
    query.Connection := m_connection;
    query.SQL.Text := 'UPDATE player SET nickname = :nickname WHERE login= :playerUID';
    query.ParamByName('nickname').AsAnsiString := nickname;
    query.ParamByName('playerUID').AsAnsiString := playerUID;
    query.ExecSQL();
    Exit(query.RowsAffected = 1);
  finally
    query.Close;
    query.DisposeOf;
  end;
end;

function TDatabase.DoLogin(userName: AnsiString; password: AnsiString): Boolean;
var
  query: TFDQuery;
begin
  query := TFDQuery.Create(nil);
  try
    // Define the SQL Query
    query.Connection := m_connection;
    query.SQL.Text := 'SELECT 1 FROM player WHERE login = :login AND password = :password LIMIT 1';
    Console.Log(Format('query : %s', [query.SQL.Text]), C_RED);
    query.ParamByName('login').AsAnsiString := userName;
    query.ParamByName('password').AsAnsiString := password;
    query.Open();

    Exit(query.RowsAffected > 0);

    //outputMemo.Text := '';
    // Add the field names from the table.
    //outputMemo.Lines.Add(String.Format('|%8s|%25s|%25s|', [' ID ', ' NAME ',
      //' DEPARTMENT ']));
    // Add one line to the memo for each record in the table.
    while not query.Eof do
    begin
      Console.Log(Format('login=>%s', [query.FieldByName('login').AsString]));
      //outputMemo.Lines.Add(String.Format('|%8d|%-25|%-25s|',
      //  [query.FieldByName('ID').AsInteger, query.FieldByName('Name').AsString,
      //  query.FieldByName('Department').AsString]));
      query.Next;
    end;

  finally
    query.Close;
    query.DisposeOf;
  end;

end;

end.
