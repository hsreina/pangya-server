unit Transaction;

interface

uses GameClient, IffManager, LoggerInterface, System.Generics.Collections,
  Types.IffId, PlayerItem;

type

  TTransactionItem = record
    IffId: TIffId;
    Id: UInt32;
    QuantityBefore: UInt32;
    Quantity: Int32;
    QuantityAfter: UInt32;
  end;

  TTransactionItemList = TList<TTransactionItem>;

  TTransaction = class
  private
    var fGameClient: TGameClient;
    var fIffManager: TIffManager;
    var fLogger: ILoggerInterface;
    var fItems: TTransactionItemList;
    var fTransactionSent: Boolean;
  public
    constructor Create(const ALogger: ILoggerInterface;
      const AIffManager: TIffManager; const AGameClient: TGameClient);
    destructor Destroy; override;
    function TryAddItemByIffId(const AIffId: TIffId; AQuantity: Int32;
      var item: TPlayerItem): Boolean;
    procedure Send;
  end;

const MaxItemCount = 1000;

implementation

uses IffManager.IffEntryBase, PlayerItems, PacketWriter, Math;

constructor TTransaction.Create(const ALogger: ILoggerInterface;
  const AIffManager: TIffManager; const AGameClient: TGameClient);
begin
  Inherited Create;
  fTransactionSent := False;
  fItems := TTransactionItemList.Create;
  fLogger := ALogger;
  fGameClient := AGameClient;
  fIffManager := AIffManager;
end;

destructor TTransaction.Destroy;
begin
  if (fItems.Count > 0) and (not fTransactionSent) then
  begin
    Send;
  end;
  fItems.Free;
  Inherited;
end;

function TTransaction.TryAddItemByIffId(const AIffId: TIffId;
  AQuantity: Int32; var item: TPlayerItem): Boolean;
var
  iffEntry: TIffEntryBase;
  transactionItem: TTransactionItem;
  playerItems: TPlayerItems;
  diff: Int64;
begin
  Result := False;

  if AQuantity = 0 then
  begin
    fLogger.Debug('does not make sence');
    Exit;
  end;

  if fTransactionSent then
  begin
    fLogger.Warning('Transaction already sent');
    Exit;
  end;

  if not fIffManager.TryGetByIffId(AIffId, iffEntry) then
  begin
    fLogger.Error('item not found in the iff 0x%x', [aIffId]);
    Exit;
  end;

  transactionItem.Quantity := AQuantity;
  playerItems := fGameClient.Data.Items;

  // Cap to MaxItem Count
  AQuantity := Min(AQuantity, MaxItemCount);

  if not playerItems.TryGetByIffId(AIffId, item) then
  begin
    fLogger.Debug('player don t have this item');
    if AQuantity < 0 then
    begin
      fLogger.Error('Trying to remove an item the user do not own');
      Exit;
    end else if AQuantity > MaxItemCount then
    begin
      fLogger.Error(
        'can t have that much items 0x%x/0x%x', [AQuantity, MaxItemCount]
      );
      Exit;
    end else if AQuantity > 0 then
    begin
      item := playerItems.Add(AIffId);
      item.SetQty(AQuantity);
      transactionItem.QuantityBefore := 0;
      transactionItem.QuantityAfter := AQuantity;
    end;
  end else
  begin
    fLogger.Debug('Player already own this item %x', [item.GetQty]);
    diff := item.GetQty + AQuantity;
    transactionItem.QuantityBefore := item.GetQty;
    if diff < 0 then
    begin
      fLogger.Error('player can t remove that much items');
      Exit;
    end else if diff = 0 then
    begin
      fLogger.Debug('player have not more of this item');
      playerItems.Remove(item);
      transactionItem.QuantityAfter := 0;
    end else if diff > MaxItemCount then
    begin
      fLogger.Error(
        'can t have that much items 0x%x/0x%x', [AQuantity, MaxItemCount]
      );
      Exit;
    end else
    begin
      fLogger.Debug('player have more items now');
      item.SetQty(diff);
      transactionItem.QuantityAfter := item.GetQty;
    end;
  end;
  transactionItem.IffId := AIffId;
  transactionItem.Id := item.Id;
  fItems.Add(transactionItem);
  Exit(True);
end;

procedure TTransaction.Send;
var
  item: TTransactionItem;
  packetWriter: TPacketWriter;
  itemCount: Integer;
begin
  if fTransactionSent then
  begin
    fLogger.Warning('Transaction already sent');
    Exit;
  end;

  itemCount := fItems.Count;
  if itemCount = 0 then
  begin
    fLogger.Warning('no transaction to send');
    Exit;
  end;

  packetWriter := TPacketWriter.Create;
  try
    packetWriter.WriteStr(#$16#$02);
    packetWriter.WriteUInt32(Random($4FFFFFFF)); // TransactionId (temporary random)
    packetWriter.WriteInt32(itemCount); // number of items in the transaction

    for item in fItems do
    begin

      packetWriter.WriteStr(#$02);
      packetWriter.WriteUInt32(item.IffId);
      packetWriter.WriteUInt32(item.Id);

      packetWriter.WriteUInt32(0); // 0 quandtity 1 time

      packetWriter.WriteUInt32(item.QuantityBefore);
      packetWriter.WriteUInt32(item.QuantityAfter);
      packetWriter.WriteInt32(item.Quantity);

      packetWriter.WriteStr(
        #$00#$00#$00#$00 +
        #$00#$00#$00#$00 +
        #$00#$00#$00#$00 +
        #$00#$00#$00#$00 +
        #$00#$00#$00#$00 +
        #$00#$00#$00#$00#$00
      );
    
    end;
    fGameClient.Send(packetWriter);
    fTransactionSent := True;
  finally
    packetWriter.Free;
  end;
end;

end.
