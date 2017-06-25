unit PacketWriter;

interface

uses Packet, PacketsDef;

type
  TPacketWriter = class(TPacket)
    public
      destructor Destroy; override;
      function WriteUInt8(const src: UInt8): Boolean;
      function WriteUInt16(const src: UInt16): Boolean;
      function WriteUInt32(const src: UInt32): Boolean;
      function WriteInt32(const src: Int32): Boolean;
      function WriteUInt64(const src: UInt64): Boolean;
      function WriteInt64(const src: Int64): Boolean;
      function Write(const src; const count: UInt32): Boolean;
      function WriteDouble(const src: Double): boolean;
      function WriteStr(const src: RawByteString): Boolean; overload;
      function WriteStr(const src: RawByteString; count: UInt32): Boolean; overload;
      function WriteStr(const src: RawByteString; count: UInt32; overflow: UTF8Char): Boolean; overload;
      function WritePStr(const src: RawByteString): Boolean;
      function WriteAction(actionId: TSGPID): Boolean; overload;
      function WriteAction(actionId: TSSPID): Boolean; overload;
      function WriteAction(actionId: TSSAPID): Boolean; overload;
      function WriteAction(actionId: TCGPID): Boolean; overload;
      procedure Clear;
  end;

implementation

destructor TPacketWriter.Destroy;
begin
  inherited;
end;

function TPacketWriter.WriteUInt8(const src: UInt8): Boolean;
begin
  Exit(Write(src, 1));
end;

function TPacketWriter.WriteUInt16(const src: UInt16): Boolean;
begin
  Exit(Write(src, 2));
end;

function TPacketWriter.WriteUInt32(const src: UInt32): Boolean;
begin
  Exit(Write(src, 4));
end;

function TPacketWriter.WriteInt32(const src: Int32): Boolean;
begin
  Exit(Write(src, 4));
end;

function TPacketWriter.WriteUInt64(const src: UInt64): Boolean;
begin
  Exit(Write(src, 8));
end;

function TPacketWriter.WriteInt64(const src: Int64): Boolean;
begin
  Exit(Write(src, 8));
end;

function TPacketWriter.Write(const src; const count: Cardinal): Boolean;
begin
  Result := m_data.Write(src, count) = count;
end;

function TPacketWriter.WriteDouble(const src: Double): boolean;
begin
  Exit(Write(src, 4));
end;

function TPacketWriter.WriteStr(const src: RawByteString): Boolean;
begin
  Exit(WriteStr(src, Length(src)));
end;

function TPacketWriter.WriteStr(const src: RawByteString; count: UInt32): Boolean;
begin
  Exit(WriteStr(src, count, #$00));
end;

function TPacketWriter.WriteStr(const src: RawByteString; count: UInt32; overflow: UTF8Char): Boolean;
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

function TPacketWriter.WritePStr(const src: RawByteString): Boolean;
var
  size: UInt16;
begin
  size := Length(src);
  WriteUInt16(size);
  Write(src[1], size);
end;

function TPacketWriter.WriteAction(actionId: TSGPID): Boolean;
begin
  Exit(Write(actionId, 2));
end;

function TPacketWriter.WriteAction(actionId: TSSPID): Boolean;
begin
  Exit(Write(actionId, 2));
end;

function TPacketWriter.WriteAction(actionId: TSSAPID): Boolean;
begin
  Exit(Write(actionId, 2));
end;

function TPacketWriter.WriteAction(actionId: TCGPID): Boolean;
begin
  Exit(Write(actionId, 2));
end;

procedure TPacketWriter.Clear;
begin
  m_data.Clear;
end;

end.
