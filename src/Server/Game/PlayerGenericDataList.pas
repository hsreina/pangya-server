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

    function Add(PacketData: TPacketData): PlayerDataClass; overload;
    function Add(IffId: UInt32): PlayerDataClass; overload;

    procedure Remove(entry: PlayerDataClass);

    function ToPacketData: TPacketData;

    function getById(Id: Uint32): PlayerDataClass;
    function getByIffId(IffId: Uint32): PlayerDataClass;

    procedure Load(PacketData: TPacketData);

    procedure Clear;
  end;

implementation

uses ConsolePas, SysUtils, GameServerExceptions;

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

function TPlayerGenericDataList<DataType, PlayerDataClass, GenericCounter>.Add(IffId: UInt32): PlayerDataClass;
var
  playerData: PlayerDataClass;
begin
  playerData := PlayerDataClass.Create;

  // For now, just set a random Id
  playerData.setId(Random($FFFFFFFF));
  playerData.setIffId(IffId);

  m_dataList.Add(playerData);
  Exit(playerData);
end;

function TPlayerGenericDataList<DataType, PlayerDataClass, GenericCounter>.Add(PacketData: TPacketData): PlayerDataClass;
var
  playerData: PlayerDataClass;
begin
  playerData := PlayerDataClass.Create;
  playerData.Load(PacketData);
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
    data.Write(dataCount, 1);
  end
  else if TypeInfo(GenericCounter) = TypeInfo(TDoubleCounter) then
  begin
    data.Write(dataCount, 2);
    data.Write(dataCount, 2);
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
    ClientPacket.Read(count, 1);
  end
  else if TypeInfo(GenericCounter) = TypeInfo(TDoubleCounter) then
  begin
    ClientPacket.Read(count, 2);
    ClientPacket.Read(count, 2);
  end;

  setlength(tmp, sizeof(DataType));

  for i := 1 to count do
  begin
    if ClientPacket.Read(tmp[1], sizeof(DataType)) then
    begin
      playerData := self.Add(tmp);
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

function TPlayerGenericDataList<DataType, PlayerDataClass, GenericCounter>.
  getById(Id: Uint32): PlayerDataClass;
var
  entry: PlayerDataClass;
begin
  // TODO: Should optimize that to something else
  for entry in m_dataList do
  begin
    if entry.getId = Id then
    begin
      Exit(entry);
    end;
  end;
  raise NotFoundException.CreateFmt('Item with Id (%d) not found', [Id]);
end;

function TPlayerGenericDataList<DataType, PlayerDataClass, GenericCounter>.
  getByIffId(IffId: Uint32): PlayerDataClass;
var
  entry: PlayerDataClass;
begin
  // TODO: Should optimize that to something else
  for entry in m_dataList do
  begin
    if entry.getIffId = IffId then
    begin
      Exit(entry);
    end;
  end;
  raise NotFoundException.CreateFmt('Item with IffId (%d) not found', [IffId]);
end;

end.
