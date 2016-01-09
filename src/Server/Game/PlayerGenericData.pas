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

  TPlayerItemBase = packed record
    var Id: Uint32;
    var IffId: Uint32;
  end;

  TPlayerGenericData<DataType: record> = class
    protected
      var m_data: DataType;
    public
      constructor Create;
      destructor Destroy; override;
      procedure Clear;
      function ToPacketData: AnsiString;
      function Load(packetData: AnsiString): Boolean;
      function GetData: DataType;
  end;

implementation

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

function TPlayerGenericData<DataType>.ToPacketData: AnsiString;
begin
  setLength(result, sizeof(DataType));
  move(m_data, result[1], sizeof(DataType));
end;

function TPlayerGenericData<DataType>.Load(packetData: AnsiString): Boolean;
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

end.
