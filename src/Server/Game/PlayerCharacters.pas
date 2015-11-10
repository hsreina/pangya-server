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

      function ToPacketData: TPacketData;
  end;

implementation

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

  for playerCharacter in m_characters do
  begin
    data.Write(playerCharacter.ToPacketData);
  end;

  Result := data.ToStr;

  data.Free;
end;

end.
