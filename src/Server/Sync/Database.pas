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
      destructor Destroy; virtual;
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

  dbPath := ExtractFilePath(ParamStr(0)) + '..\data\users.db';

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
    // Should create the db if it doesn't not exists
    if (not FileExists(m_connection.Params.Values['Database'])) then
    begin
      m_connection.ExecSQL('CREATE TABLE "User" ("uid" INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL , "login" varchar(16) NOT NULL, "nickname" varchar(16));');
    end;
  except
    on E: EDatabaseError do
    begin
      Console.Log('Exception raised with message' + E.Message, C_RED);
    end;
  end;
end;

end.
