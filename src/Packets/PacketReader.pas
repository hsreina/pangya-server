unit PacketReader;

interface

uses Packet, Types.PangyaBytes;

type
  TPacketReader = class(TPacket)
    private
      function Write(const src; const count: UInt32): Boolean;
      function WriteStr(const src: RawByteString): Boolean; overload;
      function WriteStr(const src: RawByteString; count: UInt32): Boolean; overload;
      function WriteStr(const src: RawByteString; count: UInt32; overflow: UTF8Char): Boolean; overload;
    public
      constructor CreateFromRawByteString(const src: RawByteString); overload;
      constructor CreateFromPangyaBytes(const src: TPangyaBytes); overload;
      destructor Destroy; override;
      function ReadUInt8(var dst: UInt8): Boolean;
      function ReadUInt16(var dst: UInt16): Boolean;
      function ReadUInt32(var dst: UInt32): Boolean;
      function ReadInt32(var dst: Int32): Boolean;
      function ReadUInt64(var dst: UInt64): Boolean;
      function ReadInt64(var dst: Int64): Boolean;
      function Read(var dst; const count: UInt32): Boolean;
      function ReadDouble(var dst: Double): boolean;
      function ReadStr(var dst: RawByteString; count: UInt32): Boolean;
      function ReadPStr(var dst: RawByteString): Boolean;
  end;

implementation

constructor TPacketReader.CreateFromRawByteString(const src: RawByteString);
begin
  inherited Create;
  WriteStr(src);
  Seek(0, 0);
end;

constructor TPacketReader.CreateFromPangyaBytes(const src: TPangyaBytes);
begin
  inherited Create;
  Write(src[0], Length(src));
  Seek(0, 0);
end;

destructor TPacketReader.Destroy;
begin
  inherited;
end;

function TPacketReader.ReadUInt8(var dst: UInt8): Boolean;
begin
  Exit(Read(dst, 1));
end;

function TPacketReader.ReadUInt16(var dst: UInt16): Boolean;
begin
  Exit(Read(dst, 2));
end;

function TPacketReader.ReadUInt32(var dst: UInt32): Boolean;
begin
  Exit(Read(dst, 4));
end;

function TPacketReader.ReadInt32(var dst: Int32): Boolean;
begin
  Exit(Read(dst, 4));
end;

function TPacketReader.ReadUInt64(var dst: UInt64): Boolean;
begin
  Exit(Read(dst, 8));
end;

function TPacketReader.ReadInt64(var dst: Int64): Boolean;
begin
  Exit(Read(dst, 8));
end;

function TPacketReader.Read(var dst; const count: Cardinal): Boolean;
begin
  Result := m_data.Read(dst, count) = count;
end;

function TPacketReader.ReadDouble(var dst: Double): boolean;
begin
  Exit(Read(dst, 4));
end;

function TPacketReader.ReadStr(var dst: RawByteString; count: UInt32): Boolean;
begin
  SetLength(dst, count);
  Exit(Read(dst[1], count));
end;

function TPacketReader.ReadPStr(var dst: RawByteString): Boolean;
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

function TPacketReader.Write(const src; const count: Cardinal): Boolean;
begin
  Result := m_data.Write(src, count) = count;
end;

function TPacketReader.WriteStr(const src: RawByteString): Boolean;
begin
  Exit(WriteStr(src, Length(src)));
end;

function TPacketReader.WriteStr(const src: RawByteString; count: UInt32): Boolean;
begin
  Exit(WriteStr(src, count, #$00));
end;

function TPacketReader.WriteStr(const src: RawByteString; count: UInt32; overflow: UTF8Char): Boolean;
var
  dataSize: UInt32;
  remainingDataSize: integer;
  remainningData: RawByteString;
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

end.
