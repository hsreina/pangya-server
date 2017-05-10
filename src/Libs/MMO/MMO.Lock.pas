unit MMO.Lock;

interface

uses MMO.OptionalCriticalSection;

type

  TAnonymousProcedure = reference to procedure;

  TLock = class
    private
      var m_criticalSection: TOptionalCriticalSection;
    public
      constructor Create(enabled: Boolean);
      destructor Destroy; override;
      procedure Synchronize(const callback: TAnonymousProcedure);
  end;

implementation

constructor TLock.Create(enabled: Boolean);
begin
  inherited Create;
  m_criticalSection := TOptionalCriticalSection.Create(enabled);
end;

destructor TLock.Destroy;
begin
  m_criticalSection.Free;
  inherited;
end;

procedure TLock.Synchronize(const callback: TAnonymousProcedure);
begin
  m_criticalSection.Enter;
  try
    if Assigned(callback) then
    begin
      callback();
    end;
  finally
    m_criticalSection.Leave;
  end;
end;

end.
