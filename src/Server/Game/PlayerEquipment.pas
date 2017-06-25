{*******************************************************}
{                                                       }
{       Pangya Server                                   }
{                                                       }
{       Copyright (C) 2015 Shad'o Soft tm               }
{                                                       }
{*******************************************************}

unit PlayerEquipment;

interface

type

  PPlayerEquipedItems = ^TPlayerEquipedItems;
  TPlayerEquipedItems = packed record
    var ItemIffId : array [0..9] of UInt32;
    function ToPacketData: RawByteString;
  end;

  TDecorations = packed record
    background: cardinal;
    frame: cardinal;
    sticker: cardinal;
    slot: cardinal;
    un25: cardinal;
    title: cardinal;
  end;

  PPlayerEquipment = ^TPlayerEquipment;
  TPlayerEquipment = packed record
    var CaddieId: UInt32;
    var CharacterId: UInt32;
    var ClubSetId: UInt32;
    var AztecIffID: UInt32;

    var Items: TPlayerEquipedItems;

    var un13: UInt32;
    var un14: UInt32;
    var un15: UInt32;
    var un16: UInt32;
    var un17: UInt32;
    var un18: UInt32;

    var decorations: TDecorations;

    var mascotId: UInt32;

    var un26: UInt32;
    var un27: UInt32;

    function ToPacketData: RawByteString;
  end;

implementation

function TPlayerEquipment.ToPacketData: RawByteString;
begin
  setLength(result, sizeof(TPlayerEquipment));
  move(caddieId, result[1], sizeof(TPlayerEquipment));
end;

function TPlayerEquipedItems.ToPacketData: RawByteString;
begin
  setLength(result, sizeof(TPlayerEquipedItems));
  move(ItemIffId[0], result[1], sizeof(TPlayerEquipedItems));
end;

end.
