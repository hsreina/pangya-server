unit PlayerCharacters;

interface

uses PlayerCharacter, Generics.Collections, PacketData, ClientPacket;

type

  TPlayerCharacters = class
    private
      m_characters: TList<TPlayerCharacter>;
    public
      constructor Create;
      destructor Destroy; override;

      function Add: TPlayerCharacter;
      procedure Remove(character: TPlayerCharacter);

      procedure Load(packetData: TPacketData);

      function ToPacketData: TPacketData;
  end;

implementation

uses ConsolePas, SysUtils;

constructor TPlayerCharacters.Create;
begin
  m_characters := TList<TPlayerCharacter>.Create;
end;

destructor TPlayerCharacters.Destroy;
var
  chracter: TPlayerCharacter;
begin
  for chracter in m_characters do
  begin
    chracter.Free;
  end;
  m_characters.Free;
end;

function TPlayerCharacters.Add: TPlayerCharacter;
var
  playerCharacter: TPlayerCharacter;
begin
  playerCharacter := TPlayerCharacter.Create;
  m_characters.Add(playerCharacter);
  Exit(playerCharacter);
end;

procedure TPlayerCharacters.Remove(character: TPlayerCharacter);
begin
  m_characters.Remove(character);
end;

function TPlayerCharacters.ToPacketData: TPacketData;
var
  data: TClientPacket;
  playerCharacter: TPlayerCharacter;
  charactersCount: integer;
begin
  data:= TClientPacket.Create;

  charactersCount := m_characters.Count;

  data.Write(charactersCount, 2);
  data.Write(charactersCount, 2);

  for playerCharacter in m_characters do
  begin
    data.WriteStr(playerCharacter.ToPacketData);
  end;

  Result := data.ToStr;

  data.Free;
end;

procedure TPlayerCharacters.Load(packetData: TPacketData);
var
  clientPacket: TClientPacket;
  playerCharacter: TPlayerCharacter;
  count1, count2: word;
  i: integer;
  tmp: AnsiString;
begin
  clientPacket := TClientPacket.Create(packetData);

  clientPacket.ReadUInt16(count1);
  clientPacket.ReadUInt16(count2);

  setlength(tmp, sizeof(TPlayerCharacterData));

  for I := 1 to count1 do
  begin
    if clientPacket.Read(tmp[1], sizeof(TPlayerCharacterData)) then
    begin
      playerCharacter := self.Add;
      playerCharacter.Load(tmp);
    end;
  end;

  clientPacket.Free;
end;

end.
