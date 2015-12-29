{*******************************************************}
{                                                       }
{       Pangya Server                                   }
{                                                       }
{       Copyright (C) 2015 Shad'o Soft tm               }
{                                                       }
{*******************************************************}

unit Buffer;

interface

type

TBuffer = class
private
  m_data: AnsiString;
  m_offset: UInt32;
public
  procedure Write(data: ansistring);
  function GetLength: UInt32;
  procedure Delete(offset, length: Uint32);

  function GetData: AnsiString;
  function Read(offset, length: Uint32): AnsiString;

  constructor Create;
  constructor CreateWithData(data: AnsiString);
  destructor Destroy; override;
end;

implementation

constructor TBuffer.CreateWithData(data: AnsiString);
begin
  m_data := data;
  m_offset := 0;
end;

constructor TBuffer.Create;
begin
  m_data := '';
  m_offset := 0;
end;

destructor TBuffer.Destroy;
begin
  inherited;
end;

procedure TBuffer.Write(data: AnsiString);
begin
  m_data := m_data + data;
end;

function TBuffer.GetLength: UInt32;
begin
  Exit(length(m_data));
end;

procedure TBuffer.Delete(offset: Cardinal; length: Cardinal);
begin
  system.delete(m_data, offset + 1, length);
end;

function TBuffer.GetData: AnsiString;
begin
  Result := m_data;
end;

function TBuffer.Read(offset: UInt32; length: UInt32): AnsiString;
begin
  Result := copy(m_data, offset + 1, length);
end;

end.
