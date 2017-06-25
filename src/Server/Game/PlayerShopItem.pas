{*******************************************************}
{                                                       }
{       Pangya Server                                   }
{                                                       }
{       Copyright (C) 2015 Shad'o Soft tm               }
{                                                       }
{*******************************************************}

unit PlayerShopItem;

interface

type
  TPlayerShopItem = packed record // $AC
    var ShopItemId: UInt32;
    var IffId: UInt32;
    var Id: UInt32;
    var count: UInt32;
    var un1: array [0..2] of UTF8Char;
    var price: UInt32;
    var un2: array [0..$94] of UTF8Char;
  end;

implementation

end.
