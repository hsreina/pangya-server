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
  IffManager.IffEntry, Generics.Collections, SysUtils, IffManager.IffEntrybase;

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
      function Load(filePath: string): Boolean;
      function GetByIffId(iffId: UInt32): TIffEntrybase;
  end;

implementation

uses ConsolePas;

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

function TIffEntryList<PartData, DataClass>.Load(filePath: string): Boolean;
var
  handler: Integer;
  buff: PAnsiChar;
  entry: DataClass;
begin

  handler := fileOpen(filePath, fmOpenRead);

  fileRead(handler, m_entriesCount, 2);
  fileSeek(handler, 6, 1);
  console.Log(Format('m_count : %d', [m_entriesCount]));

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
end;

procedure TIffEntryList<PartData, DataClass>.GuardAgainstUnloadedData;
begin
  if not m_loaded then
  begin
    raise Exception.Create('Not loaded');
  end;
end;

end.
