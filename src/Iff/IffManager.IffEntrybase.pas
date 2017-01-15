{*******************************************************}
{                                                       }
{       Pangya Server                                   }
{                                                       }
{       Copyright (C) 2015 Shad'o Soft tm               }
{                                                       }
{*******************************************************}

unit IffManager.IffEntryBase;

interface

uses defs;

type
  TIffEntrybase = class
    public
      function GetIffId: UInt32; virtual; abstract;
      function IsEnabled: Boolean; virtual; abstract;
      function GetPrice: UInt32; virtual; abstract;
      function GetPriceType: TPRICE_TYPE; virtual; abstract;
  end;

implementation

end.
