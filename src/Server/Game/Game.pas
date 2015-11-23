unit Game;

interface

uses
  Generics.Collections, GamePlayer, defs, PangyaBuffer, utils;

type

  TPlayerCreateGameInfo = packed record
    un1: UInt8;
    turnTime: UInt32;
    gameTime: UInt32;
    maxPlayers: UInt8;
    gameType: TGAME_TYPE;
    holeCount: byte;
    map: UInt8;
    mode: TGAME_MODE;
    naturalMode: cardinal;
  end;

  TGame = class;

  TGameEvent = TEvent<TGame>;

  TGameGenericEvent = class
    private
      var m_event: TGameEvent;
    public
      procedure Trigger(game: TGame);
      property Event: TGameEvent read m_event write m_event;
  end;

  TGame = class
    private
      var m_id: UInt16;
      var m_players: TList<TGameClient>;

      var m_name: AnsiString;
      var m_password: AnsiString;
      var m_gameInfo: TPlayerCreateGameInfo;
      var m_artifact: UInt32;
      var m_gameStarted: Boolean;

      var m_gameKey: array [0 .. $F] of ansichar;

      var m_onUpdateGame: TGameGenericEvent;

      procedure generateKey;

      function FGetPlayerCount: UInt16;

    public
      property Id: UInt16 read m_id write m_id;
      property PlayerCount: Uint16 read FGetPlayerCount;

      constructor Create(name, password: AnsiString; gameInfo: TPlayerCreateGameInfo; artifact: UInt32; onUpdate: TGameEvent);
      destructor Destroy; override;
      function AddPlayer(player: TGameClient): Boolean;
      function RemovePlayer(player: TGameClient): Boolean;
      function LobbyInformation: AnsiString;
      function GameInformation: AnsiString;
      function GameResume: AnsiString;

      procedure Send(data: AnsiString); overload;
      procedure Send(data: TPangyaBuffer); overload;
  end;

implementation

uses GameServerExceptions, ClientPacket, Buffer;

procedure TGameGenericEvent.Trigger(game: TGame);
begin
  if Assigned(m_event) then
  begin
    m_event(game);
  end;
end;

constructor TGame.Create(name, password: AnsiString; gameInfo: TPlayerCreateGameInfo; artifact: UInt32; onUpdate: TGameEvent);
begin
  m_onUpdateGame := TGameGenericEvent.Create;
  m_onUpdateGame.Event := onUpdate;
  m_name := name;
  m_password := password;
  m_gameInfo := gameInfo;
  m_artifact := artifact;
  m_players := TList<TGameClient>.Create;
  m_gameStarted := false;
  generateKey;
end;

destructor TGame.Destroy;
begin
  inherited;
  m_players.Free;
  m_onUpdateGame.Free;
end;

function TGame.AddPlayer(player: TGameClient): Boolean;
begin
  if m_players.Count >= m_gameInfo.maxPlayers then
  begin
    raise GameFullException.CreateFmt('Game (%d) is full', [Id]);
  end;
  m_players.Add(player);
  player.Data.Data.playerInfo1.game := m_id;
  m_onUpdateGame.Trigger(self);
  Exit(true);
end;

function TGame.RemovePlayer(player: TGameClient): Boolean;
begin
  if m_players.Remove(player) = -1 then
  begin
    raise PlayerNotFoundException.CreateFmt('Game (%d) can''t remove player with id %d', [player.Data.Data.playerInfo1.PlayerID]);
    Exit(false);
  end;
  player.Data.Data.playerInfo1.game := $FFFF;
  m_onUpdateGame.Trigger(self);
  Exit(true);
end;

procedure TGame.generateKey;
var
  I: Integer;
begin
  randomize;
  for I := 0 to length(m_gameKey) - 1 do begin
    m_gameKey[I] := ansichar(random($F));
  end;
end;

function TGame.LobbyInformation: AnsiString;
var
  packet: TClientPacket;
  pl: integer;
  plTest: boolean;
  val: UInt8;
  testResult: UInt8;
begin
  packet := TClientPacket.Create;

  packet.WriteStr(
    m_name, 27, #$00
  );

  packet.WriteStr(
    #$00#$00#$00#$00#$00#$00#$00#$00#$00#$00#$00#$00#$00#$00#$00 +
    #$00#$00#$00#$00#$00#$00#$00#$00#$00#$00#$00#$00#$00#$00#$00#$00 +
    #$00#$00#$00#$00#$00#$00
  );

  pl := Length(m_password);
  plTest := pl > 0;

  packet.WriteUInt8(TGeneric.Iff(plTest, 0, 1));
  packet.WriteUInt8(TGeneric.Iff(m_gameStarted, 0, 1));
  packet.WriteUInt8(0); // ?? 1 change to orange
  packet.WriteUInt8(m_gameInfo.maxPlayers);
  packet.WriteUInt8(UInt8(m_players.Count));
  packet.Write(m_gameKey[0], 16);
  packet.WriteStr(#$00#$1E);
  packet.WriteUInt8(m_gameInfo.holeCount);
  packet.WriteUInt8(UInt8(m_gameInfo.gameType));
  packet.WriteUInt16(m_id);
  packet.WriteUInt8(UInt8(m_gameInfo.mode));
  packet.WriteUInt8(m_gameInfo.map);
  packet.WriteUInt32(m_gameInfo.turnTime);
  packet.WriteUInt32(m_gameInfo.gameTime);

  packet.WriteStr(
    #$00#$00#$00#$00#$00 +
    #$00#$00#$00#$00#$00#$00#$00#$00#$00#$00#$00#$00#$00#$00#$00#$00 +
    #$00#$00#$00#$00#$00#$00#$00#$00#$00#$00#$00#$00#$00#$00#$00#$00 +
    #$00#$00#$00#$00#$00#$00#$00#$00#$00#$00#$00#$00#$00#$00#$00#$00 +
    #$00#$00#$00#$00#$00#$00#$00#$00#$00#$00#$00#$00#$00#$00#$00#$00 +
    #$00#$00#$00#$64#$00#$00#$00#$64#$00#$00#$00 +
    #$00#$00#$00#$00 + // game created by player id
    #$FF +
    #$00#$00#$00#$00 +
    #$00#$00#$00#$00 + // natural mode
    #$00#$00#$00#$00 +
    #$00#$00#$00#$00 +
    #$00#$00#$00#$00 +
    #$00#$00#$00#$00
  );

  Result := packet.ToStr;

  packet.Free;
end;

function TGame.GameInformation: AnsiString;
var
  packet: TClientPacket;
begin
  packet := TClientPacket.Create;

  packet.WriteStr(
    m_name, 27, #$00
  );

  packet.WriteStr(
    #$00#$00#$00#$00#$00 +
    #$00#$00#$00#$00#$00#$00#$00#$00#$00#$00#$00#$00 +
    #$00#$00#$00#$00#$00#$00#$00#$00#$00#$00#$00#$00#$00#$00#$00#$00 +
    #$00#$00#$00#$00#$00
  );

  packet.WriteUInt8(1); // password
  packet.WriteUInt8(0); // joinable game flag maybe switched


  packet.WriteUInt8(m_gameInfo.maxPlayers);
  packet.WriteUInt8(UInt8(m_players.Count));

  packet.Write(m_gameKey[0], 16);

  packet.WriteStr(
    #$00#$1E +
    AnsiChar(m_gameInfo.holeCount)
  );

  packet.WriteUInt8(Uint8(m_gameInfo.gameType));
  packet.WriteUInt16(m_id);
  packet.WriteUInt8(0); // ??
  packet.WriteUInt8(m_gameInfo.map);
  packet.WriteUInt32(m_gameInfo.turnTime);
  packet.WriteUInt32(m_gameInfo.gameTime);

  packet.WriteStr(
    #$00#$00#$00#$00#$00#$00#$00 +
    #$00#$00#$00#$00#$00#$00#$00#$00#$00#$00#$00#$00#$00#$00#$00#$00 +
    #$00#$00#$00#$00#$00#$00#$00#$00#$00#$00#$00#$00#$00#$00#$00#$00 +
    #$00#$00#$00#$00#$00#$00#$00#$00#$00#$00#$00#$00#$00#$00#$00#$00 +
    #$00#$00#$00#$00#$00#$00#$00#$00#$00#$00#$00#$00#$00#$00#$00#$00 +
    #$00#$64#$00#$00#$00#$64#$00#$00#$00 +
    #$00#$00#$00#$00 + // game created by player id
    #$FF#$00#$00 +
    #$00#$00#$00#$00#$00#$00#$00#$00#$00#$00#$00#$00#$00#$00#$00#$00 +
    #$00#$00#$00#$00#$00#$00
  );

  Result := packet.ToStr;

  packet.Free;
end;

function TGame.GameResume: AnsiString;
var
  packet: TClientPacket;
begin
  packet := TClientPacket.Create;

  packet.WriteUInt8(UInt8(m_gameInfo.gameType));
  packet.WriteUInt8(m_gameInfo.map);
  packet.WriteUInt8(m_gameInfo.holeCount);
  packet.WriteUInt8(UInt8(m_gameInfo.mode));
  packet.WriteStr(#$00#$00#$00#$00);
  packet.WriteUInt8(m_gameInfo.maxPlayers);
  packet.WriteStr(#$1E#$00);
  packet.WriteUInt32(m_gameInfo.turnTime);
  packet.WriteUInt32(m_gameInfo.gameTime);
  packet.WriteStr(#$00#$00#$00#$00#$00);
  packet.WritePStr(m_name);

  Result := packet.ToStr;
  packet.Free;
end;

procedure TGame.Send(data: AnsiString);
var
  client: TGameClient;
begin
  for client in m_players do
  begin
    client.Send(data);
  end;
end;

procedure TGame.Send(data: TPangyaBuffer);
var
  client: TGameClient;
begin
  for client in m_players do
  begin
    client.Send(data);
  end;
end;

function TGame.FGetPlayerCount: UInt16;
begin
  Exit(Uint16(m_players.Count));
end;

end.
