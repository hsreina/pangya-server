unit ClientPacket;

interface

uses Buffer, SysUtils;

type
  TClientPacket = class
    private
      var m_packetData: ansistring;
      var m_index: cardinal;
      var m_size: word;
    public
      constructor Create(stringpacket: ansistring); overload;
      constructor Create; overload;

      function GetByte(var dst: byte): boolean;
      function GetWord(var dst: word): boolean;
      function GetCardinal(var dst: cardinal): boolean;
      function GetInteger(var dst: Integer): boolean;
      function GetBuffer(var dst; const size: integer): boolean;

      function GetStr: ansistring; overload;
      function GetStr(count: word): ansistring; overload;

      procedure Skip(count: integer);
      procedure Seek(offset, origin: integer);

      function GetRemainingSize: integer;
      function GetRemainingData: ansistring;

      function ToStr: ansistring;
      procedure Log;
  end;

implementation

uses ConsolePas;

constructor TClientPacket.Create;
begin
  m_index := 1;
  m_size := 0;
  m_packetData := '';
end;

constructor TClientPacket.Create(stringpacket: AnsiString);
begin
  m_index := 1;
  m_size := length(stringpacket);
  m_packetData := stringpacket;
end;

procedure TClientPacket.skip(count: integer);
begin
  seek(count, 1);
end;

procedure TClientPacket.seek(offset, origin: integer);
begin
  if origin = 0 then
  begin
    if offset < 0 then
    begin
      m_index := 0;
    end else if offset > m_size then
    begin
      m_index := m_size;
    end else
    begin
      m_index := offset;
    end;
  end else if origin = 1 then
  begin
    if offset > 0 then
    begin
      if (m_index + offset) > m_size then
      begin
        m_index := m_size;
      end else
      begin
        inc(m_index, offset);
      end;
    end else if offset < 0 then
    begin
      if (m_index + offset) < 0 then
      begin
        m_index := 0;
      end else
      begin
        inc(m_index, offset);
      end;
    end;
  end else if origin = 2 then
  begin
    if offset < 0 then
    begin
      m_index := m_size;
    end else if offset > m_size then
    begin
      m_index := 0;
    end else
    begin
      m_index := m_size - offset;
    end;
  end;
end;

procedure TClientPacket.log;
begin
  console.writeDump(m_packetData);
end;

function TClientPacket.GetByte(var dst: byte): boolean;
begin
  result := getBuffer(dst, sizeof(byte));
end;

function TClientPacket.GetWord(var dst: word): boolean;
begin
  result := getBuffer(dst, sizeof(word));
end;

function TClientPacket.GetCardinal(var dst: cardinal): boolean;
begin
  result := getBuffer(dst, sizeof(cardinal));
end;

function TClientPacket.GetInteger(var dst: Integer): boolean;
begin
  result := getBuffer(dst, sizeof(Integer));
end;

function TClientPacket.GetBuffer(var dst; const size: integer): boolean;
begin
  result := false;
  if ((m_index + size) <= (m_size + 1)) then
  begin
    move(m_packetData[m_index], dst, size);
    inc(m_index, size);
    result := true;
  end else
  begin
    console.log('TClientRecieivedPacket.getBuffer : out of bound', C_RED);
    console.log(
      'm_index(' + inttostr(m_index) +
      ') + size(' + inttostr(size) +
      ') <= m_size(' + inttostr(m_size) + ')'
    );
  end;
end;

function TClientPacket.GetStr: ansistring;
var
  count: word;
begin
  result := '';
  if (getWord(count)) then begin
    result := getStr(count);
  end;
end;

function TClientPacket.GetStr(count: word): ansistring;
begin
  setLength(result, count);
  getBuffer(result[1], count);
end;

function TClientPacket.GetRemainingSize: integer;
begin
  result := length(m_packetData) - m_index + 1;
end;

function TClientPacket.GetRemainingData: ansistring;
begin
  result := getStr(getRemainingSize);
end;

function TClientPacket.ToStr: ansistring;
begin
  result := m_packetData;
end;

end.
