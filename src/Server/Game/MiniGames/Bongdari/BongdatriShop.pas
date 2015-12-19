unit BongdatriShop;

interface

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

implementation

end.
