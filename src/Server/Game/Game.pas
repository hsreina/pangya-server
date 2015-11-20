unit Game;

interface

uses
  Generics.Collections, GamePlayer, defs;

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

  TGame = class
    private
      var m_id: UInt16;
      var m_players: TList<TGamePlayer>;
      var m_maxPlayer: Uint32;

      var m_name: AnsiString;
      var m_password: AnsiString;
      var m_gameInfo: TPlayerCreateGameInfo;
      var m_artifact: UInt32;

      var m_gameKey: array [0 .. $F] of ansichar;

      procedure generateKey;

    public
      property Id: UInt16 read m_id write m_id;
      constructor Create(name, password: AnsiString; gameInfo: TPlayerCreateGameInfo; artifact: UInt32);
      destructor Destroy; override;
      function AddPlayer(player: TGamePlayer): Boolean;
      function RemovePlayer(player: TGamePlayer): Boolean;
      function LobbyInformation: AnsiString;
      function GameInformation: AnsiString;
  end;

implementation

uses GameServerExceptions, ClientPacket;

constructor TGame.Create(name, password: AnsiString; gameInfo: TPlayerCreateGameInfo; artifact: UInt32);
begin
  m_name := name;
  m_password := password;
  m_gameInfo := gameInfo;
  m_artifact := artifact;
  m_players := TList<TGamePlayer>.Create;
  generateKey;
  m_maxPlayer := 2;
end;

destructor TGame.Destroy;
begin
  inherited;
  m_players.Free;
end;

function TGame.AddPlayer(player: TGamePlayer): Boolean;
begin
  if m_players.Count >= m_maxPlayer then
  begin
    raise GameFullException.CreateFmt('Game (%d) is full', [Id]);
  end;
  m_players.Add(player);
  player.Data.playerInfo1.game := m_id;
  Exit(true);
end;

function TGame.RemovePlayer(player: TGamePlayer): Boolean;
begin
  if m_players.Remove(player) = -1 then
  begin
    raise PlayerNotFoundException.CreateFmt('Game (%d) can''t remove player with id %d', [player.Data.playerInfo1.PlayerID]);
    Exit(false);
  end;
  player.Data.playerInfo1.game := $FFFF;
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
begin
  packet := TClientPacket.Create;

  packet.WriteStr(
    m_name, 27, #$00
  );

  packet.WriteStr(
    #$00#$00#$00#$00#$00#$00#$00#$00#$00#$00#$00#$00#$00#$00#$00 +
    #$00#$00#$00#$00#$00#$00#$00#$00#$00#$00#$00#$00#$00#$00#$00#$00 +
    #$00#$00#$00#$00#$00#$00#$00#$01#$00#$14#$01#$30#$55#$C9#$66#$6D +
    #$9C#$64#$61#$B3#$C0#$2C#$24#$05#$E0#$17#$0C#$00#$1E#$01#$02#$64 +
    #$00#$00#$10#$40#$9C#$00#$00#$00#$00#$00#$00#$00#$00#$00#$00#$00 +
    #$00#$00#$00#$00#$00#$00#$00#$00#$00#$00#$00#$00#$00#$00#$00#$00 +
    #$00#$00#$00#$00#$00#$00#$00#$00#$00#$00#$00#$00#$00#$00#$00#$00 +
    #$00#$00#$00#$00#$00#$00#$00#$00#$00#$00#$00#$00#$00#$00#$00#$00 +
    #$00#$00#$00#$00#$00#$00#$00#$00#$00#$00#$00#$00#$00#$00#$00#$00 +
    #$00#$00#$00#$64#$00#$00#$00#$64#$00#$00#$00 +
    #$00#$00#$00#$00 + // game created by player id
    #$FF +
    #$00#$00#$00#$00#$00#$00#$00#$00#$00#$00#$00#$00#$00#$00#$00#$00 +
    #$00#$00#$00#$00#$00#$00#$00#$00
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
    #$00#$00#$00#$00#$00 +
    #$01 + // password game flag
    #$00 + // joinable game flag
    AnsiChar(m_gameInfo.maxPlayers) +
    #$01// player count
  );

  packet.Write(m_gameKey[0], 16);

  packet.WriteStr(
    #$00#$1E +
    AnsiChar(m_gameInfo.holeCount) +
    #$02 // game type
  );

  packet.WriteUInt16(m_id);

  packet.WriteStr(
    #$00 +
    AnsiChar(m_gameInfo.map) // map
  );

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

end.
