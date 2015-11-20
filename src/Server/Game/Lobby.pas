unit Lobby;

interface

uses PacketData, GamePlayer, Generics.Collections, GamesList;

type

  TLobby = class
    private
      var m_id: UInt8;
      var m_players: TList<TGamePlayer>;
      var m_games: TGamesList;
    public
      function Build: TPacketData;
      property Id: UInt8 read m_id write m_id;
      procedure AddPlayer(player: TGamePlayer);
      procedure RemovePlayer(player: TGamePlayer);
      property Games: TGamesList read m_games;
      constructor Create;
      destructor Destroy; override;
  end;

implementation

uses ClientPacket, ConsolePas;

constructor TLobby.Create;
begin
  inherited;
  m_players := TList<TGamePlayer>.Create;
  m_games := TGamesList.Create;
end;

destructor TLobby.Destroy;
begin
  inherited;
  m_players.Free;
  m_games.Free;
end;

procedure TLobby.AddPlayer(player: TGamePlayer);
begin
  m_players.Add(player);
  player.Lobby := m_id;
end;

procedure TLobby.RemovePlayer(player: TGamePlayer);
begin
  m_players.Remove(player);
  player.Lobby := $FF;
end;

function TLobby.Build: TPacketData;
var
  packet: TClientPacket;
begin
  packet := TClientPacket.Create;

  packet.WriteStr('test', 20, #$00);
  packet.WriteStr(
    #$00#$01#$00#$00#$01#$00#$00#$00#$00 +
    #$00#$00#$00#$00#$00#$00#$00#$00#$00#$00#$00#$08#$10#$06#$07#$1A +
    #$00#$00#$00#$00#$00#$00#$00#$01#$14#$00#$00#$64#$02#$00#$1A#$00 +
    #$00#$00#$00#$90#$01#$00#$00
  );

  packet.WriteUInt8(m_id);

  packet.WriteStr(
    #$00 +
    #$00 + // Seem to be restrictions on the lobby
    #$00#$00#$00#$00 +
    #$00#$00
  );

  Result := packet.ToStr;
  packet.Free;
end;

end.
