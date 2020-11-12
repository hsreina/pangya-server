{*******************************************************}
{                                                       }
{       Pangya Server                                   }
{                                                       }
{       Copyright (C) 2015 Shad'o Soft tm               }
{                                                       }
{*******************************************************}

unit BongdatriShop;

interface

uses LoggerInterface, GameClient;

type

  TBONGDARI_BALL_TYPE = (
    BONGDARI_BALL_TYPE_BLUE = $00,
    BONGDARI_BALL_TYPE_GREEN = $01,
    BONGDARI_BALL_TYPE_RED = $02,
    BONGDARI_BALL_TYPE_NULL = $FFFFFFFF
  );

  TBongdariResultItem = packed record
    var BallType: UInt32;
    var IffId: UInt32;
    var Id: UInt32;
    var Quantity: UInt32;
    var Spec: UInt32;
  end;

  TBongdariTransactionResult = packed record
    var Un1: UInt8; // kind of often 2
    var IffId: UInt32;
    var Id: UInt32;
    var un2: UInt32; // 0
    var QtyBefore: UInt32; // Number of this item before the transaction
    var QtyAfter: UInt32; // Number of this item after the transaction
    var Qty: UInt32; // Number of items received
    var un3: UInt32; // 0
    var un4: UInt32; // 0
    var un5: UInt32; // 0
    var un6: UInt32; // 0
    var un7: UInt32; // 0
    var un8: UInt32; // 0
    var un9: Uint8; // 0
  end;

  TBongdariShop = class
  private
    var m_logger: ILoggerInterface;
  public
    constructor Create(const ALogger: ILoggerInterface);
    procedure HandlePlayerPlayBongdariShop(const client: TGameClient);
    procedure HandlePlayerOpenRareShop(const client: TGameClient);
  end;

implementation

uses PacketWriter;

constructor TBongdariShop.Create(const ALogger: ILoggerInterface);
begin
  Inherited Create;
  m_logger := ALogger;
end;

procedure TBongdariShop.HandlePlayerPlayBongdariShop(const client: TGameClient);
const
  ballCount: UInt32 = 1;
  transactionCount: UInt32 = 1;
var
  res: TPacketWriter;
  res2: TPacketWriter;
  bongdariResultItem: TBongdariResultItem;
  bongdariTransactionResult: TBongdariTransactionResult;
  I: UInt32;
begin
  m_logger.Info('TGameServer.HandlePlayerPlayBongdariShop');

  res := TPacketWriter.Create;
  res2 := TPacketWriter.Create;

  with bongdariTransactionResult do
  begin
    Un1 := 2;
    un2 := 0;
    un3 := 0;
    un4 := 0;
    un5 := 0;
    un6 := 0;
    un7 := 0;
    un8 := 0;
    un9 := 0;
  end;

  { // Pop a warning message
  client.Send(
    #$FB#$00 +
    #$FF#$FF#$FF#$FF +
    #$FD#$FF#$FF#$FF
  );
  }

  // res2 will be a kind of resume of the transaction
  res2.WriteStr(#$16#$02); // Packet id
  res2.WriteStr(#$3C#$96#$75#$56); // Transaction Id
  res2.WriteUInt32(transactionCount);

  res.WriteStr(#$1B#$02);
  res.WriteStr(#$00#$00#$00#$00#$15#$0E#$5B#$06);

  res.WriteUInt32(ballCount); // ball count

  for I := 1 to ballCount do
  begin
    bongdariResultItem.BallType := 2;
    bongdariResultItem.IffId := $18000008;
    bongdariResultItem.Id := $10101010;
    bongdariResultItem.Quantity := 1;
    bongdariResultItem.Spec := 0;
    res.Write(bongdariResultItem, SizeOf(TBongdariResultItem));

    bongdariTransactionResult.IffId := $18000008;
    bongdariTransactionResult.Id := $10101010;
    bongdariTransactionResult.QtyBefore := 0;
    bongdariTransactionResult.QtyAfter := 1;
    bongdariTransactionResult.Qty := 1;

    res2.Write(bongdariTransactionResult, SizeOf(TBongdariTransactionResult));
  end;

  with client.Data do
  begin
    res.WriteInt64(Data.playerInfo2.pangs);
    res.WriteInt64(Cookies);
  end;

  // Send the transaction details
  client.Send(res2);

  // Send bongdari game result
  client.Send(res);

  res.Free;
  res2.Free;
end;

procedure TBongdariShop.HandlePlayerOpenRareShop(const client: TGameClient);
var
  packetWriter: TPacketWriter;
begin
  m_logger.Info('TGameServer.HandlePlayerOpenRareShop');
  client.Send(
    #$0B#$01 +
    #$FF#$FF#$FF#$FF +
    #$FF#$FF#$FF#$FF +
    #$00#$00#$00#$00
  );
end;

end.
