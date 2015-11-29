unit Game;

interface

uses
  Generics.Collections, GamePlayer, defs, PangyaBuffer, utils, ClientPacket, SysUtils;

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
      constructor Create;
      destructor Destroy; override;
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
      function GameInformation: AnsiString;
      function GameResume: AnsiString;

      procedure Send(data: AnsiString); overload;
      procedure Send(data: TPangyaBuffer); overload;

      function playersData: AnsiString;

      procedure HandlePlayerChangeGameSettings(const client: TGameClient; const clientPacket: TClientPacket);

  end;

implementation

uses GameServerExceptions, Buffer, ConsolePas;

constructor TGameGenericEvent.Create;
begin
  inherited Create;
end;

destructor TGameGenericEvent.Destroy;
begin
  inherited;
end;

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
var
  gamePlayer: TGameClient;
  playerIndex: integer;
begin
  if m_players.Count >= m_gameInfo.maxPlayers then
  begin
    raise GameFullException.CreateFmt('Game (%d) is full', [Id]);
  end;

  playerIndex := m_players.Add(player);
  player.Data.Data.playerInfo1.game := m_id;

  if m_id = 0 then
  begin
    Exit;
  end;

  // tmp fix, should create the list of player when a player leave the game
  player.Data.GameSlot := playerIndex + 1;

  player.Data.Action.clear;

  m_onUpdateGame.Trigger(self);

  // my player info to others in game
  self.Send(
    #$48#$00 + #$01#$FF#$FF +
    player.Data.GameInformation
  );

  // game informations for me
  player.Send(
    #$49#$00 + #$00#$00 +
    self.GameInformation
  );

  // game settings resume
  self.Send(
    #$4A#$00 +
    #$FF#$FF +
    self.GameResume
  );

  // player lobby informations
  self.Send(
    #$46#$00 +
    #$03#$01 +
    player.Data.LobbyInformations
  );

  // Other player in game information to me
  for gamePlayer in m_players do
  begin
    player.Send(
      #$48#$00 + #$07#$FF#$FF +
      AnsiChar(playerCount) +
      gamePlayer.Data.GameInformation
    );
  end;

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

  if m_id = 0 then
  begin
    Exit;
  end;

  self.Send(
    #$48#$00 + #$02 + #$FF#$FF +
    player.Data.GameInformation(0)
  );

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

function TGame.GameInformation: AnsiString;
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
    #$00#$00#$00#$00
  );

  packet.WriteUInt32(m_gameInfo.naturalMode);

  packet.WriteStr(
    #$00#$00#$00#$00 +
    #$00#$00#$00#$00 +
    #$00#$00#$00#$00 +
    #$00#$00#$00#$00
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
  packet.WriteUInt32(m_gameInfo.naturalMode);
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

function TGame.playersData: AnsiString;
var
  player: TGameClient;
  clientPacket: TClientPacket;
  playersCount: integer;
begin
  clientPacket := TClientPacket.Create;
  playersCount := m_players.Count;

  clientPacket.WriteUInt8(playersCount);
  for player in m_players do
  begin
    clientPacket.WriteStr(player.Data.GameInformation);
    clientPacket.WriteStr(#$00);
  end;

  Result := clientPacket.ToStr;
  clientPacket.Free;
end;

procedure TGame.HandlePlayerChangeGameSettings(const client: TGameClient; const clientPacket: TClientPacket);
var
  nbOfActions: UInt8;
  action: UInt8;
  i: UInt8;
  tmpStr: AnsiString;
  tmpUInt8: UInt8;
  tmpUInt16: UInt16;
  tmpUInt32: UInt32;
  gameInfo: TPlayerCreateGameInfo;
  currentPlayersCount: UInt16;
begin
  Console.Log('TGame::HandlePlayerChangeGameSettings', C_BLUE);

  clientPacket.Skip(2);

  if not clientPacket.ReadUInt8(nbOfActions) then
  begin
    Console.Log('Failed to read nbOfActions', C_RED);
    Exit;
  end;

  gameInfo := m_gameInfo;
  currentPlayersCount := self.PlayerCount;

  for i := 1 to nbOfActions do begin

    if not clientPacket.ReadUInt8(action) then begin
      console.log('Failed to read action', C_RED);
      break;
    end;

    case action of
      0: begin
        clientPacket.ReadPStr(tmpStr);
        // TODO: Should Check the size maybe
        m_name := tmpStr;
      end;
      1: begin
        clientPacket.ReadPStr(tmpStr);
        // TODO: Should Check the size maybe
        m_password := tmpStr;
      end;
      3: begin
        clientPacket.ReadUInt8(tmpUInt8);
        gameInfo.map := tmpUInt8;
      end;
      4: begin
        clientPacket.ReadUInt8(tmpUInt8);
        gameInfo.holeCount := tmpUInt8;
      end;
      5: begin
        clientPacket.ReadUInt8(tmpUInt8);
        gameInfo.Mode := TGAME_MODE(tmpUInt8);
      end;
      6: begin
        clientPacket.ReadUInt8(tmpUInt8);
        gameInfo.turnTime := tmpUInt8 * 1000;
      end;
      7: begin
        clientPacket.ReadUInt8(tmpUInt8);
        if tmpUInt8 > currentPlayersCount then
        begin
          gameInfo.maxPlayers := tmpUInt8;
        end;
      end;
      14: begin
        clientPacket.ReadUInt32(tmpUInt32);
      end
      else begin
        Console.Log(Format('Unknow action %d', [action]));
      end;
    end;
  end;

  self.Send(
    #$4A#$00 +
    #$FF#$FF +
    self.GameResume
  );

  // Send lobby update
  self.m_onUpdateGame.Trigger(self);

end;

end.
