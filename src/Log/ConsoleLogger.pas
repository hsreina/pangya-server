unit ConsoleLogger;

interface

uses AbstractLogger, LogLevel;

type
  TConsoleLogger = class(TAbstractLogger)
  public
    procedure Log(const ALevel: TLogLevel; const AMessage: string); overload; override;
  end;

implementation

uses ConsolePas;

procedure TConsoleLogger.Log(const ALevel: TLogLevel; const AMessage: string);
begin
  case ALevel of
    TLogLevel.Emergency:
    begin
      Console.Log(AMessage, C_RED);
    end;
    TLogLevel.Alert:
    begin
      Console.Log(AMessage, C_RED);
    end;
    TLogLevel.Critical:
    begin
      Console.Log(AMessage, C_RED);
    end;
    TLogLevel.Error:
    begin
      Console.Log(AMessage, C_RED);
    end;
    TLogLevel.Warning:
    begin
      console.Log(AMessage, C_ORANGE);
    end;
    TLogLevel.Notice:
    begin
      Console.Log(AMessage, C_GREEN);
    end;
    TLogLevel.Info:
    begin
      Console.Log(AMessage, C_BLUE);
    end;
    TLogLevel.Debug:
    begin
      Console.Log(AMessage);
    end;
  end;
end;

end.
