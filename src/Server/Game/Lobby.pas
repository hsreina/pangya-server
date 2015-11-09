unit Lobby;

interface

uses PacketData;

type

  TLobby = class (TInterfacedObject, IPacketData)
    private
      var FId: Integer;
    public
      function Build: TPacketData;
      property Id: Integer read FId write FId;
  end;

implementation

uses ClientPacket;

function TLobby.Build: TPacketData;
var
  packet: TClientPacket;
begin
  packet := TClientPacket.Create;

  packet.Write('test', 20, #$00);
  packet.Write(
    #$00#$01#$00#$00#$01#$00#$00#$00#$00 +
    #$00#$00#$00#$00#$00#$00#$00#$00#$00#$00#$00#$08#$10#$06#$07#$1A +
    #$00#$00#$00#$00#$00#$00#$00#$01#$14#$00#$00#$64#$02#$00#$1A#$00 +
    #$00#$00#$00#$90#$01#$00#$00 +
    #$01 + // Lobby ID
    #$00 +
    #$02 + // Seem to be restrictions on the lobby
    #$00#$00#$00#$00 +
    #$00#$00
  );

  Result := packet.ToStr;
  packet.Free;
end;

end.
