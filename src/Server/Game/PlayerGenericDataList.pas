{*******************************************************}
{                                                       }
{       Pangya Server                                   }
{                                                       }
{       Copyright (C) 2015 Shad'o Soft tm               }
{                                                       }
{*******************************************************}

unit PlayerGenericDataList;

interface

uses
  Generics.Collections, PacketData, ClientPacket, PlayerGenericData;

type

  // theses are just helper
  TMascotCounter = Packed record
    count: UInt8;
  end;

  TDoubleCounter = Packed record
    count1: UInt16;
    count2: UInt16;
  end;

  TPlayerGenericDataList<DataType: record;
    PlayerDataClass: TPlayerGenericData<DataType>, constructor; GenericCounter> = class
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

constructor TPlayerGenericDataList<DataType, PlayerDataClass, GenericCounter>.Create;
begin
  m_dataList := TList<PlayerDataClass>.Create;
end;

destructor TPlayerGenericDataList<DataType, PlayerDataClass, GenericCounter>.Destroy;
var
  character: PlayerDataClass;
begin
  for character in m_dataList do
  begin
    character.Free;
  end;
  m_dataList.Free;
end;

function TPlayerGenericDataList<DataType, PlayerDataClass, GenericCounter>.Add: PlayerDataClass;
var
  playerData: PlayerDataClass;
begin
  playerData := PlayerDataClass.Create;
  m_dataList.Add(playerData);
  Exit(playerData);
end;

procedure TPlayerGenericDataList<DataType, PlayerDataClass, GenericCounter>.Remove
  (entry: PlayerDataClass);
begin
  m_dataList.Remove(entry);
  entry.free;
end;

function TPlayerGenericDataList<DataType, PlayerDataClass, GenericCounter>.ToPacketData
  : TPacketData;
var
  data: TClientPacket;
  playerData: PlayerDataClass;
  dataCount: integer;
begin
  data := TClientPacket.Create;

  dataCount := m_dataList.Count;

  // TODO: should rethink that
  if TypeInfo(GenericCounter) = TypeInfo(TMascotCounter) then
  begin
    data.Write(dataCount, SizeOf(GenericCounter));
  end
  else if TypeInfo(GenericCounter) = TypeInfo(TDoubleCounter) then
  begin
    data.Write(dataCount, SizeOf(GenericCounter));
    data.Write(dataCount, SizeOf(GenericCounter));
  end;

  for playerData in m_dataList do
  begin
    data.WriteStr(playerData.ToPacketData);
  end;

  Result := data.ToStr;

  data.Free;
end;

procedure TPlayerGenericDataList<DataType, PlayerDataClass, GenericCounter>.Load
  (PacketData: TPacketData);
var
  ClientPacket: TClientPacket;
  playerData: PlayerDataClass;
  count: UInt16;
  i: integer;
  tmp: AnsiString;
begin
  ClientPacket := TClientPacket.Create(PacketData);

  count := 0;
  // TODO: should rethink that
  if TypeInfo(GenericCounter) = TypeInfo(TMascotCounter) then
  begin
    ClientPacket.Read(count, SizeOf(GenericCounter));
  end
  else if TypeInfo(GenericCounter) = TypeInfo(TDoubleCounter) then
  begin
    ClientPacket.Read(count, SizeOf(GenericCounter));
    ClientPacket.Read(count, SizeOf(GenericCounter));
  end;

  setlength(tmp, sizeof(DataType));

  for i := 1 to count do
  begin
    if ClientPacket.Read(tmp[1], sizeof(DataType)) then
    begin
      playerData := self.Add;
      playerData.Load(tmp);
    end;
  end;
  ClientPacket.Free;
end;

procedure TPlayerGenericDataList<DataType, PlayerDataClass, GenericCounter>.Clear;
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
