unit PlayerCharacter;

interface

uses PacketData;

type

  TPlayerCharacterData = packed record
    var IffId: Uint32;
    var Id: Uint32;
    var Un: array [0..$1F8] of AnsiChar;
  end;

  TPlayerCharacter = class
    private
      var m_data: TPlayerCharacterData;
    public
      constructor Create;
      destructor Destroy; override;

      procedure Clear;
      function ToPacketData: TPacketData;
      function Load(packetData: TPacketData): Boolean;
      function GetData: TPlayerCharacterData;
  end;

implementation

uses
  ConsolePas;

constructor TPlayerCharacter.Create;
begin
  Console.Log('TPlayerCharacter.Create', C_BLUE);
end;

destructor TPlayerCharacter.Destroy;
begin
  Console.Log('TPlayerCharacter.Destroy', C_BLUE);
end;

procedure TPlayerCharacter.Clear;
begin
  FillChar(m_data.IffId, SizeOf(TPlayerCharacter), 0);
end;

function TPlayerCharacter.ToPacketData: TPacketData;
begin
  setLength(result, sizeof(TPlayerCharacterData));
  move(m_data.IffId, result[1], sizeof(TPlayerCharacterData));
end;

function TPlayerCharacter.Load(packetData: AnsiString): Boolean;
const
  sizeOfCharacter = SizeOf(TPlayerCharacterData);
begin
  if not (Length(packetData) = sizeOfCharacter) then
  begin
    Exit(False);
  end;

  move(packetData[1], m_data.IffId, sizeOfCharacter);

  Exit(True);
end;

function TPlayerCharacter.GetData: TPlayerCharacterData;
begin
  Exit(m_data);
end;

end.
