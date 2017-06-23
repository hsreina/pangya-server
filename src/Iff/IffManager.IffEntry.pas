{*******************************************************}
{                                                       }
{       Pangya Server                                   }
{                                                       }
{       Copyright (C) 2015 Shad'o Soft tm               }
{                                                       }
{*******************************************************}

unit IffManager.IffEntry;

interface

uses IffManager.IffEntrybase, defs, SysUtils;

type

  PIffbase = ^TIffbase;
  TIffbase = packed record // $90
    var enabled: UInt32;
    var iffId: UInt32;
    var name: array [0..$27] of UTF8Char;
    var minLVL: Byte;
    var preview: array [0..$27] of UTF8Char;
    var un1: array [0..2] of UTF8Char;
    var itemPrice: UInt32;
    var discountPrice: UInt32;
    var usedPrice: UInt32;
    var priceType: UInt8; // Cookie , pangs, free
    var itemFlag: UInt8; // 0x01 in stock; 0x02 disable gift; 0x03 Special; 0x08 new; 0x10 hot;
    var timeFlag: UInt8;
    var time: UInt8;
    var tpItemCount: UInt32;
    var tpCount: UInt32;
    var un2: array [0..$1B] of UTF8Char;
  end;

  TIffEntry<EntryDataType: record> = class (TIffEntrybase)
    protected
      var m_data: EntryDataType;
      function GetBase: PIffbase;
      const m_dataSize = SizeOf(EntryDataType);
    public
      constructor Create(data: PUTF8Char);
      destructor Destroy; override;
      function GetIffId: UInt32; override;
      function IsEnabled: Boolean; override;
      procedure Enable;
      function GetPrice: UInt32; override;
      function GetPriceType: TPRICE_TYPE; override;
      procedure LoadToBytes(var bytes: TBytes);
      function GetDataSize: UInt32;
      procedure SetItemFlag(itemFlag: UInt8);
      procedure SetMinLVL(minLVL: UInt8);
      procedure SetShopPrice(price: UInt32);
      procedure SetPriceType(priceType: UInt32);
  end;

implementation

constructor TIffEntry<EntryDataType>.Create(data: PUTF8Char);
begin
  inherited Create;
  move(data^, m_data, m_dataSize);
end;

destructor TIffEntry<EntryDataType>.Destroy;
begin
  inherited;
end;

function TIffEntry<EntryDataType>.GetIffId: UInt32;
begin
  Result := self.GetBase.iffId;
end;

function TIffEntry<EntryDataType>.GetBase: PIffbase;
begin
  Result := @m_data;
end;

function TIffEntry<EntryDataType>.IsEnabled: Boolean;
var
  base: PIffBase;
begin
  Result := self.GetBase.enabled = 1;
end;

procedure TIffEntry<EntryDataType>.Enable;
begin
  self.GetBase.enabled := 1;
end;

function TIffEntry<EntryDataType>.GetPrice: UInt32;
begin
  Result := self.GetBase.itemPrice;
end;

function TIffEntry<EntryDataType>.GetPriceType: TPRICE_TYPE;
var
  priceType: UInt8;
begin
  priceType := GetBase.priceType;
  result := TPRICE_TYPE.PRICE_TYPE_UNKNOW;

  if (pricetype and $0) = $0 then begin
    result := TPRICE_TYPE.PRICE_TYPE_PANG;
  end;

  if (pricetype and $1) = $1 then begin
    result := TPRICE_TYPE.PRICE_TYPE_COOKIE;
  end;

  if (pricetype and $2) = $2 then begin
    result := TPRICE_TYPE.PRICE_TYPE_PANG;
  end;
end;

procedure TIffEntry<EntryDataType>.LoadToBytes(var bytes: TBytes);
begin
  setLength(bytes, m_dataSize);
  move(m_data, bytes[0], m_dataSize);
end;

function TIffEntry<EntryDataType>.GetDataSize: UInt32;
begin
  Result := m_dataSize;
end;

procedure TIffEntry<EntryDataType>.SetItemFlag(itemFlag: UInt8);
begin
  self.GetBase.itemFlag := itemFlag;
end;

procedure TIffEntry<EntryDataType>.SetMinLVL(minLVL: UInt8);
begin
  self.GetBase.minLVL := minLVL;
end;

procedure TIffEntry<EntryDataType>.SetShopPrice(price: UInt32);
begin
  self.GetBase.itemPrice := price;
end;

procedure TIffEntry<EntryDataType>.SetPriceType(priceType: UInt32);
begin
  self.GetBase.priceType := priceType;
end;

end.
