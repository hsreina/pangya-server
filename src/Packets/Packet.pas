unit Packet;

interface

uses
  Classes;

type
  TPacket = class abstract
    private
    protected
      var m_data: TMemoryStream;
    public
      constructor Create;
      destructor Destroy; override;

      procedure Skip(count: integer);
      function Seek(offset, origin: integer): integer;
      function GetSize: UInt32;

      function ToStr: AnsiString;
      function GetRemainingData: AnsiString;
      procedure Log;
  end;

implementation

uses ConsolePas;

constructor TPacket.Create;
begin
  inherited;
  m_data := TMemoryStream.Create;
end;

destructor TPacket.Destroy;
begin
  m_data.Free;
  inherited;
end;

procedure TPacket.Skip(count: integer);
begin
  Seek(count, 1);
end;

function TPacket.Seek(offset, origin: integer): integer;
begin
  Exit(m_data.Seek(offset, origin));
end;

function TPacket.GetSize;
begin
  Result := m_data.Size;
end;

function TPacket.ToStr;
var
  previousOffset: integer;
  Size: integer;
begin
  previousOffset := m_data.Seek(0, 1);
  m_data.Seek(0, 0);
  size := m_data.Size;
  SetLength(Result, size);
  m_data.Read(Result[1], size);
  m_data.Seek(previousOffset, 0);
end;

function TPacket.GetRemainingData;
var
  previousOffset: integer;
  Size: integer;
begin
  previousOffset := m_data.Seek(0, 1);
  size := m_data.Size - previousOffset;
  SetLength(Result, size);
  m_data.Read(Result[1], size);
  m_data.Seek(previousOffset, 0);
end;

procedure TPacket.Log;
begin
  Console.WriteDump(self.ToStr);
end;

end.
