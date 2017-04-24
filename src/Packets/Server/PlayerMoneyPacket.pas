unit PlayerMoneyPacket;

interface

uses PacketReader, PacketWriter, GameServerPlayer;

type
  TPlayerMoneyPacket = class (TPacketWriter)
    public
      constructor CreateForPlayer(player: TGameServerPlayer);
      destructor Destroy;
  end;

implementation

constructor TPlayerMoneyPacket.CreateForPlayer;
begin
  inherited Create;
  self.WriteStr(#$C8#$00);
  self.WriteUInt64(player.data.playerInfo2.pangs);
  self.WriteUInt64(player.Cookies);
end;

destructor TPlayerMoneyPacket.Destroy;
begin
  inherited;
end;

end.
