{*******************************************************}
{                                                       }
{       Pangya Server                                   }
{                                                       }
{       Copyright (C) 2015 Shad'o Soft tm               }
{                                                       }
{*******************************************************}

unit PlayersList;

interface

uses
  Generics.Collections, GameServerPlayer;

type
  TPlayersList = class (TList<TGameClient>)
    public
      constructor Create;
      destructor Destroy; override;
      function GetByConnectionId(connectionId: UInt32): TGameClient;
      function GetById(Id: UInt32): TGameClient;
  end;

implementation

uses GameServerExceptions;

constructor TPlayersList.Create;
begin
  inherited;
end;

destructor TPlayersList.Destroy;
begin
  inherited;
end;

function TPlayersList.GetByConnectionId(connectionId: Cardinal): TGameClient;
var
  gameClient: TGameClient;
begin
  for gameClient in self do
  begin
    if gameClient.Data.Data.playerInfo1.ConnectionId = connectionId then
    begin
      Exit(gameClient);
    end;
  end;
  raise NotFoundException.CreateFmt('Player with connectionId %x not found', [connectionId]);
end;

function TPlayersList.GetById(Id: Cardinal): TGameClient;
var
  gameClient: TGameClient;
begin
  for gameClient in self do
  begin
    if gameClient.Data.Data.playerInfo1.PlayerID = id then
    begin
      Exit(gameClient);
    end;
  end;
  raise NotFoundException.CreateFmt('Player with id %x not found', [id]);
end;

end.
