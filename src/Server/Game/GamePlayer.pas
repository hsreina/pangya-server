unit GamePlayer;

interface

uses PlayerData, PlayerCharacters, Client, PlayerAction;

type

  TGamePlayer = class;

  TGamePlayer = class
    private
      var m_lobby: UInt8;
      var m_data: TPlayerData;
      var m_characters: TPlayerCharacters;
      function FGetPlayerData: PPlayerData;
    public
      var Cookies: UInt64;
      var Action: TPlayerAction;

      function GameInformation: AnsiString; overload;
      function GameInformation(level: UInt8): AnsiString; overload;
      function LobbyInformations: AnsiString;

      property Lobby: Uint8 read m_lobby write m_lobby;
      property Data: PPlayerData read FGetPlayerData;
      property Characters: TPlayerCharacters read m_characters;

      var GameSlot: UInt8;
      var InGameList: Boolean;

      constructor Create;
      destructor Destroy; override;
  end;

  TGameClient = TClient<TGamePlayer>;

implementation

uses ClientPacket, PlayerCharacter;

constructor TGamePlayer.Create;
begin
  inherited;
  m_characters := TPlayerCharacters.Create;
  m_lobby := $FF;
  InGameList := false;
end;

destructor TGamePlayer.Destroy;
begin
  inherited;
  m_characters.Free;
end;

function TGamePlayer.FGetPlayerData;
begin
  Exit(@m_data);
end;

function TGamePlayer.GameInformation: AnsiString;
begin
  Exit(GameInformation(1));
end;

function TGamePlayer.GameInformation(level: UInt8): AnsiString;
var
  packet: TClientPacket;
begin

  packet := TClientPacket.Create;

  packet.WriteUInt32(Data.playerInfo1.ConnectionId);

  if level >= 1 then
  begin

    packet.Write(Data.playerInfo1.nickname[0], 22);

    packet.WriteStr(
      #$00#$00#$00#$00#$00#$00#$00#$00#$00#$00#$00#$00#$00#$00#$00#$00 +
      #$00
    );

    packet.WriteUInt8(GameSlot);

    packet.WriteStr(
      #$00#$00#$00#$00 +
      #$06#$01#$80#$39
    );

    packet.WriteUInt32(Data.equipedCharacter.IffId);

    packet.WriteStr(
      #$00#$00 +
      #$00#$00#$00#$00#$00#$00#$00#$00#$00#$00#$00#$00#$00#$00#$00#$00 +
      #$00#$00#$06#$01#$80#$39#$08#$02#$0F +
      #$00#$0A +
      #$00#$00#$00#$00 + // emblem
      #$00#$00#$00#$00 + // emblem
      #$34#$61#$65#$62 +
      #$00#$00#$00#$00
    );

    packet.WriteUInt32(Data.playerInfo1.PlayerID);

    packet.WriteStr(
      #$00#$00#$00#$00 + // shop flag
      #$00#$00
    );
    packet.WriteStr(
      Action.toAnsiString
    );

    packet.WriteStr(
      #$00#$00#$00#$00#$00#$00#$00#$00#$00#$00#$00 +
      #$00#$00#$00#$00#$00#$00#$00#$00#$00#$00#$00#$00#$00#$00#$00#$00 +
      #$00#$00#$00#$00#$00#$00#$00#$00#$00#$00#$00#$00#$00#$00#$00#$00 +
      #$00#$00#$00#$00#$00#$00#$00#$00#$00#$00#$00#$00#$00#$00#$00#$00 +
      #$00#$00#$00#$00#$00#$00#$00#$00#$00#$00#$00#$00#$00#$00#$00#$00 +
      #$00#$00#$00#$00#$00#$00#$00#$00#$00#$00#$00#$00#$00#$00#$00#$00 +
      #$00#$00#$00#$00#$00#$00#$00#$00#$00#$00#$00#$00#$00#$00#$00#$00 +
      #$00#$00#$00#$00#$00#$00#$00#$00#$00#$00#$00#$00#$00#$00#$00#$00 +
      #$00#$00#$00#$00#$00#$00#$00#$00#$00#$00#$00#$00#$00#$00#$00#$00 +
      #$00#$00#$00#$00#$00#$00#$00#$00#$00#$00#$00#$00#$00#$00#$00#$00 +
      #$00#$00#$00#$00#$00#$00#$00#$00#$00#$00#$00#$00#$00#$00#$00#$00 +
      #$00#$00#$00#$00#$00#$00#$00#$00#$00#$00#$00#$00#$00#$00#$00#$00 +
      #$00#$00#$00#$00#$00#$00#$00#$00#$00#$00#$00#$00#$00#$00#$00#$00 +
      #$00#$00#$00#$00#$00#$00#$00#$00#$00#$00#$00
    );

    packet.Write(Data.equipedCharacter.IffId, SizeOf(TPlayerCharacterData));

  end;

  Result := packet.ToStr;

  packet.free;
end;

function TGamePlayer.LobbyInformations: AnsiString;
var
  packet: TClientPacket;
  tmpGameId: UInt16;
begin

  // Tmp fix because I'm using the game 0 as lobby null game
  tmpGameId := m_data.playerInfo1.game;
  if tmpGameId = 0 then
  begin
    tmpGameId := $ffFF;
  end;

  packet := TClientPacket.Create;

  packet.WriteUInt32(Data.playerInfo1.PlayerID);
  packet.WriteUInt32(Data.playerInfo1.ConnectionId);
  packet.WriteUInt16(tmpGameId);
  packet.Write(Data.playerInfo1.nickname[0], 22);

  packet.WriteStr(
    #$00 + // rank
    #$00#$00#$00#$00#$00#$00#$00 +
    #$00#$E8#$03#$00 +
    #$00 +
    #$02 + // gender
    #$00#$00#$00#$00 + // guild ID
    #$67#$75#$69#$6C#$64#$6D#$61#$72#$6B#$00 +
    #$00#$00#$00#$00#$00#$00#$00#$00#$73#$65#$72#$76#$65#$72#$74#$65 +
    #$73#$74#$40#$4E#$54#$00#$00#$00#$00#$00#$00#$00#$00#$00#$00#$00 +
    #$00#$00#$00#$00#$00#$00#$00#$00#$00#$00#$00#$00#$00#$00#$00#$00 +
    #$00#$00#$00#$00#$00#$00#$00#$00#$00#$00#$00#$00#$00#$00#$00#$00 +
    #$00#$00#$00#$00#$00#$00#$00#$00#$00#$00#$00#$00#$00#$00#$00#$00 +
    #$00#$00#$00#$00#$00#$00#$00#$00#$00#$00#$00#$00#$00#$00#$00#$00 +
    #$00#$00#$00#$00#$00#$00#$00#$00#$00#$00#$00#$00#$00#$00#$00#$00 +
    #$00#$00#$00#$00#$00#$00#$00#$00#$00#$00#$00#$00#$00#$00#$00#$00 +
    #$00#$00#$00#$00#$00#$00#$00#$00
  );

  Result := packet.ToStr;

  packet.free;

end;

end.
