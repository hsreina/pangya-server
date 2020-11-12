{*******************************************************}
{                                                       }
{       Pangya Server                                   }
{                                                       }
{       Copyright (C) 2015 Shad'o Soft tm               }
{                                                       }
{*******************************************************}

unit LobbiesList;

interface

uses
  Generics.Collections, Lobby, PacketData, GameServerPlayer, Game, SerialList,
  LoggerInterface, Packet;

type

  TLobbyList = TSerialList<TLobby>;

  TLobbiesList = class
    protected
    private
      var m_lobbies: TLobbyList;
      procedure DestroyLobbies;
      function GetFirstLobby: TLobby;
    public
      constructor Create(const ALogger: ILoggerInterface);
      destructor Destroy; override;
      function GetLobbyById(const lobbyId: Byte): TLobby;
      function GetPlayerLobby(const player: TGameClient): TLobby;
      function TryGetPlayerLobby(const player: TGameClient; var lobby: TLobby): Boolean;
      function GetPlayerGame(const player: TGameClient): TGame;
      procedure Send(const data: RawByteString); overload;
      procedure Send(const AData: TPacket); overload;
      function Build: TPacketData;
      function GetFirstPlayer: TgameClient;
  end;

implementation

uses GameServerExceptions, PacketWriter;

constructor TLobbiesList.Create(const ALogger: ILoggerInterface);
var
  lobby: TLobby;
  index: integer;
begin
  inherited Create;
  m_lobbies := TLobbyList.Create;
  lobby := TLobby.Create(ALogger, 'lobby 1');
  lobby.Id := m_lobbies.Add(lobby);
end;

destructor TLobbiesList.Destroy;
begin
  DestroyLobbies;
  m_lobbies.Free;
  inherited;
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

function TLobbiesList.GetLobbyById(const lobbyId: Byte): TLobby;
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

function TLobbiesList.GetPlayerLobby(const player: TGameClient): TLobby;
begin
  Exit(self.GetLobbyById(player.Data.Lobby));
end;

function TLobbiesList.TryGetPlayerLobby(const player: TGameClient; var lobby: TLobby): Boolean;
begin
  try
    lobby := GetPlayerLobby(player);
  except
    Exit(False);
  end;
  Exit(True);
end;

function TLobbiesList.GetPlayerGame(const player: TGameClient): TGame;
var
  lobby: TLobby;
begin
  lobby := self.GetLobbyById(player.Data.Lobby);
  Exit(lobby.GetPlayerGame(player));
end;

function TLobbiesList.Build: TPacketData;
var
  lobby: TLobby;
  packetWriter: TPacketWriter;
begin
  packetWriter := TPacketWriter.Create;
  packetWriter.WriteUInt8(m_lobbies.Count);
  for lobby in m_lobbies do
  begin
    packetWriter.WriteStr(lobby.Build);
  end;
  Result := packetWriter.ToStr;
  packetWriter.Free;
end;

procedure TLobbiesList.Send(const data: RawByteString);
var
  lobby: TLobby;
begin
  for lobby in m_lobbies do
  begin
    lobby.Send(data);
  end;
end;

procedure TLobbiesList.Send(const AData: TPacket);
var
  lobby: TLobby;
begin
  for lobby in m_lobbies do
  begin
    lobby.Send(AData);
  end;
end;

function TLobbiesList.GetFirstLobby: TLobby;
var
  lobby: TLobby;
begin
  for lobby in m_lobbies do
  begin
    Exit(lobby);
  end;
  Exit(nil);
end;

function TLobbiesList.GetFirstPlayer: TGameClient;
var
  lobby: TLobby;
begin
  lobby := GetFirstLobby;
  if lobby = nil then
  begin
    Exit(nil);
  end;
  Exit(lobby.GetFirstPlayer);
end;

end.
