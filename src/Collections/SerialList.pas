unit SerialList;

interface

uses
  Generics.Collections;

type
  TSerialList<T> = class (TList<T>)
    private
      var m_serial: UInt32;
      var m_lastInsertedIndex: integer;
    public
      constructor Create;
      destructor Destroy; override;
      function Add(const Value: T): Integer;
  end;

implementation

constructor TSerialList<T>.Create;
begin
  inherited;
  m_serial := 0;
end;

destructor TSerialList<T>.Destroy;
begin
  inherited;
end;

function TSerialList<T>.Add(const Value: T): Integer;
var
  realResult: integer;
begin
  m_lastInsertedIndex := inherited;
  Result := m_serial;
  Inc(m_serial);
end;

end.
