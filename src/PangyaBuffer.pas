{*******************************************************}
{                                                       }
{       Pangya Server                                   }
{                                                       }
{       Copyright (C) 2015 Shad'o Soft tm               }
{                                                       }
{*******************************************************}

unit PangyaBuffer;

interface

uses
  Classes, System.SyncObjs, SysUtils, PangyaPacketsDef;

type
  TPangyaBuffer = class
    private
      var m_data: TMemoryStream;
      var m_bufferLock: TCriticalSection;
      procedure Init;
    public
      constructor Create; overload;
      constructor Create(const src: AnsiString); overload;
      destructor Destroy; override;

      procedure Lock;
      procedure Unlock;

      function WriteUInt8(const src: UInt8): Boolean;
      function ReadUInt8(var dst: UInt8): Boolean;

      function WriteUInt16(const src: UInt16): Boolean;
      function ReadUInt16(var dst: UInt16): Boolean;

      function WriteUInt32(const src: UInt32): Boolean;
      function ReadUInt32(var dst: UInt32): Boolean;

      function WriteInt32(const src: Int32): Boolean;
      function ReadInt32(var dst: Int32): Boolean;

      function WriteUInt64(const src: UInt64): Boolean;
      function ReadUInt64(var dst: UInt64): Boolean;

      function WriteInt64(const src: Int64): Boolean;
      function ReadInt64(var dst: Int64): Boolean;

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

      function WriteAction(actionId: TSGPID): Boolean; overload;
      function WriteAction(actionId: TSSPID): Boolean; overload;
      function WriteAction(actionId: TSSAPID): Boolean; overload;
      function WriteAction(actionId: TCGPID): Boolean; overload;

      procedure Skip(count: integer);
      function Seek(offset, origin: integer): integer;
      function GetSize: UInt32;
      procedure Delete(offset: UInt32; length: UInt32);
      function ToStream: TStream;

      procedure Clear;
  end;

implementation

constructor TPangyaBuffer.Create;
begin
  inherited;
  Init;
end;

constructor TPangyaBuffer.Create(const src: AnsiString);
begin
  inherited Create;
  init;
  WriteStr(src);
  Seek(0, 0);
end;

procedure TPangyaBuffer.Init;
begin
  m_bufferLock := TCriticalSection.Create;
  m_data := TMemoryStream.Create;
end;

destructor TPangyaBuffer.Destroy;
begin
  inherited;
  m_data.Free;
  m_bufferLock.Free;
end;

procedure TPangyaBuffer.Lock;
begin
  m_bufferLock.Enter;
end;

procedure TPangyaBuffer.Unlock;
begin
  m_bufferLock.Leave;
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

function TPangyaBuffer.WriteInt32(const src: Int32): Boolean;
begin
  Exit(Write(src, 4));
end;

function TPangyaBuffer.ReadInt32(var dst: Int32): Boolean;
begin
  Exit(Read(dst, 4));
end;

function TPangyaBuffer.WriteUInt64(const src: UInt64): Boolean;
begin
  Exit(Write(src, 8));
end;

function TPangyaBuffer.ReadUInt64(var dst: UInt64): Boolean;
begin
  Exit(Read(dst, 8));
end;

function TPangyaBuffer.WriteInt64(const src: Int64): Boolean;
begin
  Exit(Write(src, 8));
end;

function TPangyaBuffer.ReadInt64(var dst: Int64): Boolean;
begin
  Exit(Read(dst, 8));
end;

function TPangyaBuffer.Write(const src; const count: Cardinal): Boolean;
begin
  Result := m_data.Write(src, count) = count;
end;

function TPangyaBuffer.Read(var dst; const count: Cardinal): Boolean;
begin
  Result := m_data.Read(dst, count) = count;
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

function TPangyaBuffer.WriteAction(actionId: TSGPID): Boolean;
begin
  Exit(Write(actionId, 2));
end;

function TPangyaBuffer.WriteAction(actionId: TSSPID): Boolean;
begin
  Exit(Write(actionId, 2));
end;

function TPangyaBuffer.WriteAction(actionId: TSSAPID): Boolean;
begin
  Exit(Write(actionId, 2));
end;

function TPangyaBuffer.WriteAction(actionId: TCGPID): Boolean;
begin
  Exit(Write(actionId, 2));
end;

procedure TPangyaBuffer.Skip(count: integer);
begin
  Seek(count, 1);
end;

function TPangyaBuffer.Seek(offset, origin: integer): integer;
begin
  Exit(m_data.Seek(offset, origin));
end;

function TPangyaBuffer.GetSize;
begin
  Result := m_data.Size;
end;

procedure TPangyaBuffer.Delete(offset: UInt32; length: UInt32);
var
  tmp: TMemoryStream;
  pos: Int64;
  offsetAndLen: Int64;
  leftSize: Int64;
  dataSize: Int64;
begin
  dataSize := m_data.Size;

  if offset > dataSize then
  begin
    Exit;
  end;

  if offset + length > dataSize then
  begin
    length := dataSize - offset;
  end;

  offsetAndLen := offset + length;
  leftSize := dataSize - offsetAndLen;

  pos := m_data.Seek(0, 1);
  tmp := TMemoryStream.Create;
  m_data.Seek(offsetAndLen, 0);
  tmp.CopyFrom(m_data, leftSize);
  m_data.Seek(offset, 0);
  m_data.Write(tmp.Memory, leftSize);

  m_data.SetSize(dataSize - length);
  m_data.Seek(pos, 0);
  tmp.Free;
end;

function TPangyaBuffer.ToStream: TStream;
begin
  Result := TMemoryStream.Create;
  Seek(0, 0);
  Result.CopyFrom(m_data, m_data.Size);
  Result.Seek(0, 0);
  Clear;
end;

procedure TPangyaBuffer.Clear;
begin
  m_data.Clear;
end;

end.
