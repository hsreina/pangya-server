unit PlayerMacrosPacket;

interface

uses
  PacketReader, PacketWriter;

type
  TPlayerMacrosPacket = class (TPacketWriter)
    public
      constructor Create;
      destructor Destroy; override;
  end;

implementation

uses PacketsDef;

constructor TPlayerMacrosPacket.Create;
begin
  inherited;
  WriteAction(TSLPID.PLAYER_MACROS);
  WriteStr('test 1', 64);
  WriteStr('test 2', 64);
  WriteStr('test 3', 64);
  WriteStr('test 4', 64);
  WriteStr('test 5', 64);
  WriteStr('test 6', 64);
  WriteStr('test 7', 64);
  WriteStr('test 8', 64);
  WriteStr('test 9', 64);
end;

destructor TPlayerMacrosPacket.Destroy;
begin
  inherited;
end;

end.
