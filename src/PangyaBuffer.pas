unit PangyaBuffer;

interface

uses
  Classes;

type
  TPangyaBuffer = class
    private
      var m_data: TMemoryStream;
    public
      constructor Create; overload;
      constructor Create(const src: AnsiString); overload;
      destructor Destroy; override;

      function WriteUInt8(const src: UInt8): Boolean;
      function ReadUInt8(var dst: UInt8): Boolean;

      function WriteUInt16(const src: UInt16): Boolean;
      function ReadUInt16(var dst: UInt16): Boolean;

      function WriteUInt32(const src: UInt32): Boolean;
      function ReadUInt32(var dst: UInt32): Boolean;

      function Write(const src; const count: UInt32): Boolean;
      function Read(var dst; const count: UInt32): Boolean;

      function WriteDouble(const src: Double): boolean;
      function ReadDouble(var dst: Double): boolean;

      function WriteStr(const src: AnsiString): Boolean; overload;
      function WriteStr(const src: AnsiString; count: UInt32): Boolean; overload;
      function WriteStr(const src: AnsiString; count: UInt32; overflow: AnsiChar): Boolean; overload;
      function ReadStr(var dst: AnsiString; count: UInt32): Boolean;

      function WritePStr(const src: AnsiString): Boolean;
      function ReadPStr(var dst: AnsiString): Boolean;

      procedure Skip(count: integer);
      procedure Seek(offset, origin: integer);
      function GetSize: UInt32;
      function GetStream: TStream;
  end;

implementation

constructor TPangyaBuffer.Create;
begin
  m_data := TMemoryStream.Create;
end;

constructor TPangyaBuffer.Create(const src: AnsiString);
begin
  WriteStr(src);
end;

destructor TPangyaBuffer.Destroy;
begin
  m_data.Free;
end;

function TPangyaBuffer.WriteUInt8(const src: UInt8): Boolean;
begin
  Exit(Write(src, 1));
end;

function TPangyaBuffer.ReadUInt8(var dst: UInt8): Boolean;
begin
  Exit(Read(dst, 1));
end;

function TPangyaBuffer.WriteUInt16(const src: UInt16): Boolean;
begin
  Exit(Write(src, 2));
end;

function TPangyaBuffer.ReadUInt16(var dst: UInt16): Boolean;
begin
  Exit(Read(dst, 2));
end;

function TPangyaBuffer.WriteUInt32(const src: UInt32): Boolean;
begin
  Exit(Write(src, 4));
end;

function TPangyaBuffer.ReadUInt32(var dst: UInt32): Boolean;
begin
  Exit(Read(dst, 4));
end;

function TPangyaBuffer.Write(const src; const count: Cardinal): Boolean;
begin
  Exit(m_data.Write(src, count) = count);
end;

function TPangyaBuffer.Read(var dst; const count: Cardinal): Boolean;
begin
  Exit(m_data.Read(dst, count) = count);
end;

function TPangyaBuffer.WriteDouble(const src: Double): boolean;
begin
  Exit(Write(src, 4));
end;

function TPangyaBuffer.ReadDouble(var dst: Double): boolean;
begin
  Exit(Read(dst, 4));
end;

function TPangyaBuffer.WriteStr(const src: AnsiString): Boolean;
begin
  Exit(WriteStr(src, Length(src)));
end;

function TPangyaBuffer.WriteStr(const src: AnsiString; count: UInt32): Boolean;
begin
  Exit(WriteStr(src, count, #$00));
end;

function TPangyaBuffer.WriteStr(const src: AnsiString; count: UInt32; overflow: AnsiChar): Boolean;
var
  dataSize: UInt32;
  remainingDataSize: integer;
  remainningData: AnsiString;
begin
  dataSize := Length(src);
  if dataSize < count then
  begin
    Result := Write(src[1], dataSize);
    remainingDataSize :=  count - dataSize;
    remainningData := StringOfChar(overflow, remainingDataSize);
    Result := Result and Write(remainningData[1], remainingDataSize);
  end else begin
    Exit(Write(src[1], count));
  end;
end;

function TPangyaBuffer.ReadStr(var dst: AnsiString; count: UInt32): Boolean;
begin
  SetLength(dst, count);
  Exit(Read(dst[1], count));
end;

function TPangyaBuffer.WritePStr(const src: AnsiString): Boolean;
var
  size: UInt16;
begin
  size := Length(src);
  WriteUInt16(size);
  Write(src[1], size);
end;

function TPangyaBuffer.ReadPStr(var dst: AnsiString): Boolean;
var
  size: UInt16;
begin
  if not ReadUint16(size) then
  begin
    Exit(False);
  end;
  setLength(dst, size);
  Exit(Read(dst[1], size));
end;

procedure TPangyaBuffer.Skip(count: integer);
begin
  m_data.Seek(count, 1);
end;

procedure TPangyaBuffer.Seek(offset, origin: integer);
begin
  m_data.Seek(offset, origin);
end;

function TPangyaBuffer.GetSize;
begin
  Exit(m_data.Size);
end;

function TPangyaBuffer.GetStream;
begin
  Exit(m_data);
end;

end.
