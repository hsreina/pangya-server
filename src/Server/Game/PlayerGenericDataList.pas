unit PlayerGenericDataList;

interface

uses
  Generics.Collections, PacketData, ClientPacket, PlayerGenericData;

type
  TPlayerGenericDataList<DataType: record;
    PlayerDataClass: TPlayerGenericData<DataType>, constructor> = class
  private
    m_dataList: TList<PlayerDataClass>;
  public
    constructor Create;
    destructor Destroy; override;

    function Add: PlayerDataClass;
    procedure Remove(entry: PlayerDataClass);

    function ToPacketData: TPacketData;
    procedure Load(PacketData: TPacketData);

    procedure Clear;
  end;

implementation

uses ConsolePas, SysUtils;

constructor TPlayerGenericDataList<DataType, PlayerDataClass>.Create;
begin
  m_dataList := TList<PlayerDataClass>.Create;
end;

destructor TPlayerGenericDataList<DataType, PlayerDataClass>.Destroy;
var
  character: PlayerDataClass;
begin
  for character in m_dataList do
  begin
    character.Free;
  end;
  m_dataList.Free;
end;

function TPlayerGenericDataList<DataType, PlayerDataClass>.Add: PlayerDataClass;
var
  playerData: PlayerDataClass;
begin
  playerData := PlayerDataClass.Create;
  m_dataList.Add(playerData);
  Exit(playerData);
end;

procedure TPlayerGenericDataList<DataType, PlayerDataClass>.Remove
  (entry: PlayerDataClass);
begin
  m_dataList.Remove(entry);
  entry.free;
end;

function TPlayerGenericDataList<DataType, PlayerDataClass>.ToPacketData
  : TPacketData;
var
  data: TClientPacket;
  playerData: PlayerDataClass;
  dataCount: integer;
begin
  data := TClientPacket.Create;

  dataCount := m_dataList.Count;

  data.Write(dataCount, 2);
  data.Write(dataCount, 2);

  for playerData in m_dataList do
  begin
    data.WriteStr(playerData.ToPacketData);
  end;

  Result := data.ToStr;

  data.Free;
end;

procedure TPlayerGenericDataList<DataType, PlayerDataClass>.Load
  (PacketData: TPacketData);
var
  ClientPacket: TClientPacket;
  playerData: PlayerDataClass;
  count1, count2: word;
  i: integer;
  tmp: AnsiString;
begin
  ClientPacket := TClientPacket.Create(PacketData);

  ClientPacket.ReadUInt16(count1);
  ClientPacket.ReadUInt16(count2);
  setlength(tmp, sizeof(DataType));

  for i := 1 to count1 do
  begin
    if ClientPacket.Read(tmp[1], sizeof(DataType)) then
    begin
      playerData := self.Add;
      playerData.Load(tmp);
    end;
  end;
end;

procedure TPlayerGenericDataList<DataType, PlayerDataClass>.Clear;
var
  playerData: PlayerDataClass;
begin

  for playerData in m_dataList do
  begin
    playerData.Clear;
    playerData.free;
  end;

  playerData.Clear;
end;

end.
