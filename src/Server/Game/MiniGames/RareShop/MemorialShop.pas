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

uses PlayerItem, Transaction;

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
  transaction: TTransaction;
const
  itemToAddIffId: UInt32 = $1800000B;
  qtyWin = 2;
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

  transaction := TTransaction.Create(m_logger, m_iffManager, AClient);
  try

    if not transaction.TryAddItemByIffId(iffId, -1, item) then
    begin
      m_logger.Error('Failed to remove player coin');
      APacketWriter.WriteUInt32(4);
      Exit;
    end;

    if not transaction.TryAddItemByIffId(itemTOAddIffId, qtyWin, item) then
    begin
      m_logger.Error('Failed to add item to the player');
      APacketWriter.WriteUInt32(5);
      Exit;
    end;

  finally
    transaction.Free;
  end;

  APacketWriter.WriteUInt32(0); // No Error

  APacketWriter.WriteUInt32(1); // item count is one, it will be a rare item specified by the rateType if more then we don't care about rare type

  APacketWriter.WriteUInt32(1); // rare type : 3 gold
  APacketWriter.WriteUInt32(item.IffId); // IffId
  APacketWriter.WriteUInt32(3); // count
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
