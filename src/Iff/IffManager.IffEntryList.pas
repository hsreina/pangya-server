{*******************************************************}
{                                                       }
{       Pangya Server                                   }
{                                                       }
{       Copyright (C) 2015 Shad'o Soft tm               }
{                                                       }
{*******************************************************}

unit IffManager.IffEntryList;

interface

uses
  IffManager.IffEntry, Generics.Collections, SysUtils, IffManager.IffEntrybase,
  IffManager.DataCheck, System.Zip;

type

  TIffEntryList<PartData: record; DataClass: TIffEntry<PartData>, constructor> = class
    private
      var m_entriesCount: UInt16;
      var m_entries: TList<DataClass>;
      var m_loaded: Boolean;

      procedure GuardAgainstUnloadedData;
    public
      constructor Create;
      destructor Destroy; override;
      function Load(filePath: string): Boolean; overload;
      function PatchAndSave(filePath: string): Boolean;
      function Load(const zip: TZipFile; const filename: string): Boolean; overload;
      function GetByIffId(iffId: UInt32): TIffEntrybase;
      function TryGetByIffId(iffid: UInt32; var entry: TIffEntrybase): Boolean;
      property IsLoaded: Boolean read m_loaded;
  end;

implementation

uses GameServerExceptions, Classes;

constructor TIffEntryList<PartData, DataClass>.Create;
begin
  inherited;
  m_loaded := false;
  m_entries := TList<DataClass>.Create;
end;

destructor TIffEntryList<PartData, DataClass>.Destroy;
var
  entry: DataClass;
begin
  inherited;
  for entry in m_entries do
  begin
    entry.Free;
  end;
  m_entries.Free;
end;

function TIffEntryList<PartData, DataClass>.Load(const zip: TZipFile; const filename: string): Boolean;
var
  totalSize: UInt32;
  bytes: TBytes;
  memoryStream: TMemoryStream;
  buff: PUTF8Char;
begin
  zip.Read(filename, bytes);
  totalSize := Length(bytes);

  with TMemoryStream.Create do
  try
    Write(bytes, totalSize);
    Seek(Int64(0), 0);

    Read(m_entriesCount, 2);

    if not (totalSize = m_entriesCount * SizeOf(PartData) + 8) then
    begin
      Exit(false);
    end;

    Seek(Int64(6), 1);

    // Should check the data Size
    buff := allocMem(SizeOf(PartData));

    while Read(buff^, SizeOf(PartData)) > 0 do
    begin
      m_entries.Add(TIffEntry<PartData>.Create(buff));
    end;

    freeMem(buff, SizeOf(PartData));

    m_loaded := true;
    Result := true;
  finally
    Free;
  end;
end;

function TIffEntryList<PartData, DataClass>.Load(filePath: string): Boolean;
var
  handler: Integer;
  buff: PUTF8Char;
  entry: DataClass;
  totalSize: UInt32;
begin

  handler := fileOpen(filePath, fmOpenRead);

  totalSize := FileSeek(handler, 0, 2);
  FileSeek(handler, 0, 0);

  fileRead(handler, m_entriesCount, 2);

  if not (totalSize = m_entriesCount * SizeOf(PartData) + 8) then
  begin
    FileClose(handler);
    Exit(false);
  end;

  fileSeek(handler, 6, 1);

  // Should check the data Size
  buff := allocMem(SizeOf(PartData));

  while fileRead(handler, buff^, SizeOf(PartData)) > 0 do
  begin
    m_entries.Add(TIffEntry<PartData>.Create(buff));
  end;

  freeMem(buff, SizeOf(PartData));
  fileClose(handler);

  m_loaded := true;

  Result := true;
end;

function TIffEntryList<PartData, DataClass>.PatchAndSave(filePath: string): Boolean;
var
  handler: Integer;
  entry: DataClass;
  buffer: TBytes;
  entriesCount: UInt32;
  fs: TFileStream;
  flags: UInt16;
const
  sign: UInt32 = $d;
begin
  flags := fmOpenReadWrite;

  if not FileExists(filePath) then
  begin
    flags := flags or fmCreate;
  end;

  entriesCount := m_entries.Count;
  with TFileStream.Create(filepath, flags) do
  try
    Write(entriesCount, 4);
    Write(sign, 4);
    for entry in m_entries do
    begin

      if entry.IsEnabled then
      begin
        entry.SetItemFlag(1);
        entry.SetMinLVL($0);
        entry.SetShopPrice($0);
        entry.SetPriceType($60);
      end;
      entry.LoadToBytes(buffer);
      Write(buffer[0], entry.GetDataSize);
    end;
  finally
    Free;
  end;

  Result := true;
end;

function TIffEntryList<PartData, DataClass>.GetByIffId(iffId: Cardinal): TIffEntrybase;
var
  entry: DataClass;
begin
  GuardAgainstUnloadedData;
  for entry in m_entries do
  begin
    if entry.GetIffId = iffId then
    begin
      Exit(entry);
    end;
  end;
  raise NotFoundException.CreateFmt('item with IffId %x not found', [iffId]);
end;

function TIffEntryList<PartData, DataClass>.TryGetByIffId(iffid: UInt32; var entry: TIffEntrybase): Boolean;
begin
  Result := true;
  try
    entry := GetByIffId(iffId);
  Except
    Result := false;
  end;
end;

procedure TIffEntryList<PartData, DataClass>.GuardAgainstUnloadedData;
begin
  if not m_loaded then
  begin
    raise Exception.Create('Not loaded');
  end;
end;

end.
