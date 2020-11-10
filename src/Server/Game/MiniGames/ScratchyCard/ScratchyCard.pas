unit ScratchyCard;

interface

uses LoggerInterface, PacketReader, GameClient, PlayerItem;

type
  TScratchyCard = class
  private
    var m_logger: ILoggerInterface;
    procedure DrawRandomPrizes(const client: TGameClient);
    function TryGetPlayerScratchyCard(const client: TGameClient; var data: TPlayerItem): boolean;
  public
    constructor Create(const ALogger: ILoggerInterface);
    procedure HandlePlayerOpenScratchyCard(const client: TGameClient; const packetReader: TPacketReader);
    procedure HandlerPlayerPlayScratchyCard(const client: TGameClient; const packetReader: TPacketReader);
    procedure HandlePlayerEnterScratchyCardSerial(const client: TGameClient; const packetReader: TPacketReader);
  end;

implementation

uses PacketWriter;

const ScratchyCardIffIds: array [0..1] of UInt32 = ($1A000030, $1A000033);

constructor TScratchyCard.Create(const ALogger: ILoggerInterface);
begin
  Inherited Create;
  m_logger := ALogger;
end;

procedure TScratchyCard.HandlePlayerOpenScratchyCard(const client: TGameClient; const packetReader: TPacketReader);
begin
  m_logger.Info('TGameServer.HandlePlayerOpenScratchyCard');
  client.Send(#$EB#$01#$00#$00#$00#$00#$00);
end;

function TScratchyCard.TryGetPlayerScratchyCard(const client: TGameClient; var data: TPlayerItem): boolean;
var
  iffId: UInt32;
begin
  for iffId in ScratchyCardIffIds do
  begin
    if client.Data.Items.TryGetByIffId(iffId, data) then
    begin
      Exit(True);
    end;    
  end;
  Exit(False);    
end;

procedure TScratchyCard.HandlerPlayerPlayScratchyCard(const client: TGameClient; const packetReader: TPacketReader);
var
  scratchyCardTicket, item: TPlayerItem;
  packetWriter: TPacketWriter;
begin
  m_logger.Info('TGameServer.HandlerPlayerPlayScratchyCard');

  if TryGetPlayerScratchyCard(client, scratchyCardTicket) then
  begin

    client.Data.Items.RemoveQty(scratchyCardTicket, 1);

    packetWriter := TPacketWriter.Create;
    try
      packetWriter.WriteStr(#$D5#$00);
      packetWriter.WriteUInt32(scratchyCardTicket.Id);
      client.Send(packetWriter);
    finally
      packetWriter.Free;
    end;

    DrawRandomPrizes(client);

  end else
  begin
    client.Send(
      #$DD#$00 +
      #$01#$00#$00#$00
    );
  end;

end;

procedure TScratchyCard.HandlePlayerEnterScratchyCardSerial(const client: TGameClient; const packetReader: TPacketReader);
const
  validSerialSize = 13;
var
  serial: RawByteString;
  serialSize: Uint32;
begin
  m_logger.Info('TGameServer.HandlePlayerEnterScratchyCardSerial');

  packetReader.Log;

  if not packetReader.ReadUInt32(serialSize) then
  begin
    Exit;
  end;

  if not (serialSize = validSerialSize) then
  begin
    Exit;
  end;

  setLength(serial, validSerialSize);

  if not packetReader.Read(serial[1], validSerialSize) the
  n
  begin
    Exit;
  end;

  m_logger.Debug('serial : %s', [serial]);


  // The server seem to alway answer that with any wrong serial
  // Serial seem broken in original Pangya
  client.Send(
    #$DE#$00 + #$16#$26#$26#$00
  );

  // Old server data was
//  client.Send(
//    #$DE#$00 +
//    #$00#$00#$00#$00 +
//    #$01#$00#$00#$00 + // return code 0 success, 1 used, 2 invalid, 3 expired etc...
//    #$00#$00#$00#$00
//  );

end;

procedure TScratchyCard.DrawRandomPrizes(const client: TGameClient);
var
  item: TPlayerItem;
  packetWriter: TPacketWriter;
const
  itemToAddIffId: UInt32 = $1800000B;
  qtyWin = 1;
begin

  item := client.Data.Items.GetOrAddByIffId(itemToAddIffId);
  item.AddQty(qtyWin);

  packetWriter := TPacketWriter.Create;
  try
    packetWriter.WriteStr(
      #$DD#$00 +
      #$00#$00#$00#$00 // Error code 0 = success
    );
    packetWriter.WriteUInt32(1);

    packetWriter.WriteUInt32(0);
    packetWriter.WriteUInt32(item.IffId);
    packetWriter.WriteUInt32(item.Id);
    packetWriter.WriteUInt32(qtyWin);
    packetWriter.WriteUInt32(1);

    client.Send(packetWriter);
  finally
    packetWriter.Free;
  end;
end;

end.
