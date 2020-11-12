unit MemorialShop;

interface

uses LoggerInterface, GameClient, PacketReader, IffManager,
  IffManager.IffEntryBase, PacketWriter;

type
  TMemorialShop = class
  private
    var m_logger: ILoggerInterface;
    var m_iffManager: TIffManager;
    procedure InternalHandlePlayerPlayMemorialShop(const AClient: TGameClient; const APacketReader: TPacketReader; const APacketWriter: TPacketWriter);
  public
    constructor Create(const ALogger: ILoggerInterface; const AIffManager: TIffManager);
    procedure HandlePlayerPlayMemorialShop(const AClient: TGameClient; const APacketReader: TPacketReader);
  end;

implementation

uses PlayerItem;

constructor TMemorialShop.Create(const ALogger: ILoggerInterface; const AIffManager: TIffManager);
begin
  Inherited Create;
  m_logger := ALogger;
  m_iffManager := AIffManager;
end;

procedure TMemorialShop.InternalHandlePlayerPlayMemorialShop(const AClient: TGameClient; const APacketReader: TPacketReader; const APacketWriter: TPacketWriter);
var
  IffId: UInt32;
  iffEntry: TIffEntryBase;
  coinItem: TPlayerItem;
  item: TPlayerItem;
const
  itemToAddIffId: UInt32 = $1800000B;
  qtyWin = 1;
begin

  if not APacketReader.ReadUInt32(IffId) then
  begin
    m_logger.Error('Failed to read IffId');
    APacketWriter.WriteUInt32(1);
    Exit;
  end;
  m_logger.Debug('IffId: 0x%x', [IffId]);

  if not m_iffManager.TryGetByIffId(IffId, iffEntry) then
  begin
    m_logger.Error('Item not found in Iff');
    APacketWriter.WriteUInt32(2);
    Exit;
  end;
  m_logger.Debug('Coin Name: %s', [iffEntry.Name]);

  if not AClient.Data.Items.TryGetByIffId(iffId, coinItem) then
  begin
    m_logger.Error('Player do not own this item');
    APacketWriter.WriteUInt32(3);
    Exit;
  end;

  APacketWriter.WriteUInt32(0);

  item := AClient.Data.Items.GetOrAddByIffId(itemToAddIffId);
  item.AddQty(qtyWin);

  APacketWriter.WriteUInt32(1);
  APacketWriter.WriteUInt32(1);
  APacketWriter.WriteUInt32(item.IffId);
  APacketWriter.WriteUInt32(item.Id);
  APacketWriter.WriteUInt32(1);

  // Should send a transaction with player items

end;

procedure TMemorialShop.HandlePlayerPlayMemorialShop(const AClient: TGameClient; const APacketReader: TPacketReader);
var
  packetWriter: TPacketWriter;
begin
  m_logger.Info('TMemorialShop.HandlePlayerPlayMemorialShop');
  packetWriter := TPacketWriter.Create;
  try
    packetWriter.WriteStr(#$64#$02);
    InternalHandlePlayerPlayMemorialShop(AClient, APacketReader, packetWriter);
    AClient.Send(packetWriter);
  finally
    packetWriter.Free;
  end;
end;

end.
