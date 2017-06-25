{*******************************************************}
{                                                       }
{       Pangya Server                                   }
{                                                       }
{       Copyright (C) 2015 Shad'o Soft tm               }
{                                                       }
{*******************************************************}

unit PlayerGenericData;

interface

type

  PPlayerItemBase = ^TPlayerItemBase;
  TPlayerItemBase = packed record
    var Id: Uint32;
    var IffId: Uint32;
  end;

  TGenericPacketData = class
    public
      function ToPacketData: RawByteString; virtual; abstract;
  end;

  TGenericPacketDatabase = class (TGenericPacketData)
    public
      function GetIffId: UInt32; virtual; abstract;
      procedure SetIffId(iffId: UInt32); virtual; abstract;
      function GetId: UInt32; virtual; abstract;
      procedure SetId(id: UInt32); virtual; abstract;
      function GetQty: UInt32; virtual; abstract;
      function GetLifeTime: UInt16; virtual; abstract;
  end;

  TPlayerGenericData<DataType: record> = class (TGenericPacketDatabase)
    private
      function GetBase: PPlayerItemBase;
    protected
      var m_data: DataType;
    public
      constructor Create;
      destructor Destroy; override;

      procedure Clear;
      function ToPacketData: RawByteString; override;
      function Load(packetData: RawByteString): Boolean;
      function GetData: DataType;

      function GetIffId: UInt32; override;
      procedure SetIffId(iffId: UInt32); override;
      function GetId: UInt32; override;
      procedure SetId(id: UInt32); override;
      function GetQty: UInt32; override;
      function GetLifeTime: UInt16; override;
  end;

implementation

function TPlayerGenericData<DataType>.GetQty: UInt32;
begin
  Result := 0;
end;

function TPlayerGenericData<DataType>.GetLifeTime: UInt16;
begin
  Result := 0;
end;

constructor TPlayerGenericData<DataType>.Create;
begin
  inherited;
  self.Clear;
end;

destructor TPlayerGenericData<DataType>.Destroy;
begin
  inherited;
end;

procedure TPlayerGenericData<DataType>.Clear;
begin
  FillChar(m_data, SizeOf(DataType), 0);
end;

function TPlayerGenericData<DataType>.ToPacketData: RawByteString;
begin
  setLength(result, sizeof(DataType));
  move(m_data, result[1], sizeof(DataType));
end;

function TPlayerGenericData<DataType>.Load(packetData: RawByteString): Boolean;
const
  sizeOfData = SizeOf(DataType);
begin
  if not (Length(packetData) = sizeOfData) then
  begin
    Exit(False);
  end;

  move(packetData[1], m_data, sizeOfData);

  Exit(True);
end;

function TPlayerGenericData<DataType>.GetData: DataType;
begin
  Exit(m_data);
end;

function TPlayerGenericData<DataType>.GetBase: PPlayerItemBase;
begin
  Result := @m_data;
end;

function TPlayerGenericData<DataType>.GetIffId: UInt32;
begin
  Result := self.GetBase.IffId;
end;

function TPlayerGenericData<DataType>.GetId: UInt32;
begin
  Result := self.GetBase.Id;
end;

procedure TPlayerGenericData<DataType>.SetId(Id: UInt32);
begin
  self.GetBase.Id := Id;
end;

procedure TPlayerGenericData<DataType>.SetIffId(IffId: UInt32);
begin
  self.GetBase.IffId := IffId;
end;

end.
