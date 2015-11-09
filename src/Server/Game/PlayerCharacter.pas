unit PlayerCharacter;

interface

uses PacketData;

type

  PTPlayerCharacter = ^TPlayerCharacter;

  TPlayerCharacter = packed record
    var IffId: Uint32;
    var Id: Uint32;

    var Un: array [0..$1F8] of AnsiChar;

    procedure Clear;
    function ToPacketData: TPacketData;
  end;

implementation

procedure TPlayerCharacter.Clear;
begin
  FillChar(self.IffId, SizeOf(TPlayerCharacter), 0);
end;

function TPlayerCharacter.ToPacketData: TPacketData;
begin
  setLength(result, sizeof(TPlayerCharacter));
  move(IffId, result[1], sizeof(TPlayerCharacter));
end;

end.
