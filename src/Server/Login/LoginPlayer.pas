unit LoginPlayer;

interface

type
  TLoginPlayer = class
    private
      var m_debug: AnsiString;
    public
      constructor Create;
      destructor Destroy; override;
  end;

implementation

constructor TLoginPlayer.Create;
begin
  inherited;
  m_debug := 'test?';
end;

destructor TLoginPlayer.Destroy;
begin
  inherited;
end;

end.
