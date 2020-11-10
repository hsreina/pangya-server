unit NullLogger;

interface

uses AbstractLogger, LogLevel;

type
  TNullLogger = class(TAbstractLogger)
  public
    procedure Log(const ALevel: TLogLevel; const AMessage: string); overload; override;
  end;

implementation

procedure TNullLogger.Log(const ALevel: TLogLevel; const AMessage: string);
begin

end;


end.
