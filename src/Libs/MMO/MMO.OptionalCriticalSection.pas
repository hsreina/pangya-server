unit MMO.OptionalCriticalSection;

interface

uses
  SyncObjs;

type
  TOptionalCriticalSection = class
    private
      var m_criticalSection: TCriticalSection;
      var m_enabled: Boolean;
    public
      constructor Create(enabled: Boolean);
      destructor Destroy; override;
      procedure Enter;
      procedure Leave;
  end;

implementation

constructor TOptionalCriticalSection.Create(enabled: Boolean);
begin
  inherited Create;
  m_criticalSection := TCriticalSection.Create;
  m_enabled := enabled;
end;

destructor TOptionalCriticalSection.Destroy;
begin
  m_criticalSection.Free;
  inherited;
end;

procedure TOptionalCriticalSection.Enter;
begin
  if m_enabled then
  begin
    m_criticalSection.Enter;
  end;
end;

procedure TOptionalCriticalSection.Leave;
begin
  if m_enabled then
  begin
    m_criticalSection.Leave;
  end;
end;

end.
