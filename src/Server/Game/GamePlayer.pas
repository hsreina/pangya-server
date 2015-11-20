unit GamePlayer;

interface

uses PlayerData, PlayerCharacters;

type
  TGamePlayer = class
    private
      var m_lobby: UInt8;
      var m_data: TPlayerData;
      var m_characters: TPlayerCharacters;
      function FGetPlayerData: PPlayerData;
    public
      property Lobby: Uint8 read m_lobby write m_lobby;
      property Data: PPlayerData read FGetPlayerData;
      property Characters: TPlayerCharacters read m_characters;

      function GameInformation: AnsiString;
      function LobbyInformations: AnsiString;

      var Cookies: UInt64;

      constructor Create;
      destructor Destroy; override;
  end;

implementation

uses ClientPacket, PlayerCharacter;

constructor TGamePlayer.Create;
begin
  inherited;
  m_characters := TPlayerCharacters.Create;
  m_lobby := $FF;
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
var
  packet: TClientPacket;
begin

  packet := TClientPacket.Create;

  packet.WriteUInt32(Data.playerInfo1.ConnectionId);
  packet.Write(Data.playerInfo1.nickname[0], 22);

  packet.WriteStr(
    #$00#$00#$00#$00#$00#$00#$00#$00#$00#$00#$00#$00#$00#$00#$00#$00 +
    #$00#$01#$00#$00#$00#$00#$06 +
    #$01 +
    #$80#$39
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
    #$00 +
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
    #$00#$00#$00#$00#$00#$00#$00#$00#$00#$00#$00#$00#$00#$00#$00#$00 +
    #$00#$00#$00#$00#$00#$00#$00#$00#$00#$00#$00#$00#$00#$00#$00#$00 +
    #$00#$00#$00#$00#$00#$00#$00#$00#$00#$00#$00
  );

  packet.Write(Data.equipedCharacter.IffId, SizeOf(TPlayerCharacterData));

  packet.WriteStr(#$00);

  Result := packet.ToStr;

  packet.free;
end;

function TGamePlayer.LobbyInformations: AnsiString;
var
  packet: TClientPacket;
begin

  packet := TClientPacket.Create;

  packet.WriteUInt32(Data.playerInfo1.PlayerID);
  packet.WriteUInt32(Data.playerInfo1.ConnectionId);

  packet.WriteStr(
    #$64#$00#$68#$73 +
    #$5F#$72#$65#$69#$00#$00#$00#$00#$00#$00#$00#$00#$00#$00#$00#$00 +
    #$00#$00#$00#$00#$00#$00#$00#$00#$00#$00#$00#$00#$00#$E8#$03#$00 +
    #$00#$02#$00#$00#$00#$00#$67#$75#$69#$6C#$64#$6D#$61#$72#$6B#$00 +
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
