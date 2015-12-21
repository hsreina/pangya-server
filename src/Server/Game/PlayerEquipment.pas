unit PlayerEquipment;

interface

type

  PPlaterEquipedItems = ^TPlaterEquipedItems;
  TPlaterEquipedItems = packed record
    var ItemIffId : array [0..9] of UInt32;
    function ToPacketData: AnsiString;
  end;

  PPlayerEquipment = ^TPlayerEquipment;
  TPlayerEquipment = packed record
    var CaddieId: UInt32;
    var CharacterId: UInt32;
    var ClubSetId: UInt32;
    var AztecIffID: UInt32;

    var Items: TPlaterEquipedItems;

    var un13: UInt32;
    var un14: UInt32;
    var un15: UInt32;
    var un16: UInt32;
    var un17: UInt32;
    var un18: UInt32;

    var un19: UInt32;
    var un20: UInt32;
    var un21: UInt32;
    var un22: UInt32;
    var un23: UInt32;
    var un24: UInt32;
    var un25: UInt32;
    var un26: UInt32;
    var un27: UInt32;

    function ToPacketData: AnsiString;
  end;

implementation

function TPlayerEquipment.ToPacketData: AnsiString;
begin
  setLength(result, sizeof(TPlayerEquipment));
  move(caddieId, result[1], sizeof(TPlayerEquipment));
end;

function TPlaterEquipedItems.ToPacketData: AnsiString;
begin
  setLength(result, sizeof(TPlaterEquipedItems));
  move(ItemIffId[0], result[1], sizeof(TPlaterEquipedItems));
end;

end.
