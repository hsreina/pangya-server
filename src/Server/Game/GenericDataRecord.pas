unit GenericDataRecord;

interface

type
  // Stupid helper function for some places
  TGenericDataRecord<DataType> = packed record
    var Data: DataType;
    procedure Clear;
    function ToPacketData: AnsiString;
    function Load(packetData: AnsiString): Boolean;
  end;

implementation

procedure TGenericDataRecord<DataType>.Clear;
begin
  FillChar(Data, SizeOf(DataType), 0);
end;

function TGenericDataRecord<DataType>.ToPacketData: AnsiString;
begin
  setLength(result, sizeof(DataType));
  move(Data, result[1], sizeof(DataType));
end;

function TGenericDataRecord<DataType>.Load(packetData: AnsiString): Boolean;
const
  sizeOfData = SizeOf(DataType);
begin
  if not (Length(packetData) = sizeOfData) then
  begin
    Exit(False);
  end;

  move(packetData[1], Data, sizeOfData);

  Exit(True);
end;

end.
