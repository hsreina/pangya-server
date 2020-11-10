unit AbstractLogger;

interface

uses LoggerInterface, LogLevel;

type

  TAbstractLogger = class abstract(TInterfacedObject, ILoggerInterface)
  private
    procedure Log(const ALevel: TLogLevel; const AMessage: string; const AContext: array of const); overload;
  protected
    procedure Log(const ALevel: TLogLevel; const AMessage: string); overload; virtual; abstract;
  public
    procedure Emergency(const AMessage: string); overload; virtual;
    procedure Emergency(const AMessage: string; const AContext: array of const); overload; virtual;
    procedure Alert(const AMessage: string); overload; virtual;
    procedure Alert(const AMessage: string; const AContext: array of const); overload; virtual;
    procedure Critical(const AMessage: string); overload; virtual;
    procedure Critical(const AMessage: string; const AContext: array of const); overload; virtual;
    procedure Error(const AMessage: string); overload; virtual;
    procedure Error(const AMessage: string; const AContext: array of const); overload; virtual;
    procedure Warning(const AMessage: string); overload; virtual;
    procedure Warning(const AMessage: string; const AContext: array of const); overload; virtual;
    procedure Notice(const AMessage: string); overload; virtual;
    procedure Notice(const AMessage: string; const AContext: array of const); overload; virtual;
    procedure Info(const AMessage: string); overload; virtual;
    procedure Info(const AMessage: string; const AContext: array of const); overload; virtual;
    procedure Debug(const AMessage: string); overload; virtual;
    procedure Debug(const AMessage: string; const AContext: array of const); overload; virtual;
  end;

implementation

uses System.SysUtils;

procedure TAbstractLogger.Emergency(const AMessage: string);
begin
  Log(TLogLevel.Emergency, AMessage);
end;

procedure TAbstractLogger.Emergency(const AMessage: string; const AContext: array of const);
begin
  Log(TLogLevel.Emergency, AMessage, AContext);
end;

procedure TAbstractLogger.Alert(const AMessage: string);
begin
  Log(TLogLevel.Alert, AMessage);
end;

procedure TAbstractLogger.Alert(const AMessage: string; const AContext: array of const);
begin
  Log(TLogLevel.Alert, AMessage, AContext);
end;

procedure TAbstractLogger.Critical(const AMessage: string);
begin
  Log(TLogLevel.Critical, AMessage);
end;

procedure TAbstractLogger.Critical(const AMessage: string; const AContext: array of const);
begin
  Log(TLogLevel.Critical, AMessage, AContext);
end;

procedure TAbstractLogger.Error(const AMessage: string);
begin
  Log(TLogLevel.Error, AMessage);
end;

procedure TAbstractLogger.Error(const AMessage: string; const AContext: array of const);
begin
  Log(TLogLevel.Error, AMessage, AContext);
end;

procedure TAbstractLogger.Warning(const AMessage: string);
begin
  Log(TLogLevel.Warning, AMessage);
end;

procedure TAbstractLogger.Warning(const AMessage: string; const AContext: array of const);
begin
  Log(TLogLevel.Warning, AMessage, AContext);
end;

procedure TAbstractLogger.Notice(const AMessage: string);
begin
  Log(TLogLevel.Notice, AMessage);
end;

procedure TAbstractLogger.Notice(const AMessage: string; const AContext: array of const);
begin
  Log(TLogLevel.Notice, AMessage, AContext);
end;

procedure TAbstractLogger.Info(const AMessage: string);
begin
  Log(TLogLevel.Info, AMessage);
end;

procedure TAbstractLogger.Info(const AMessage: string; const AContext: array of const);
begin
  Log(TLogLevel.Info, AMessage, AContext);
end;

procedure TAbstractLogger.Debug(const AMessage: string);
begin
  Log(TLogLevel.Debug, AMessage);
end;

procedure TAbstractLogger.Debug(const AMessage: string; const AContext: array of const);
begin
  Log(TLogLevel.Debug, AMessage, AContext);
end;

procedure TAbstractLogger.Log(const ALevel: TLogLevel; const AMessage: string; const AContext: array of const);
begin
  Log(ALevel, String.Format(AMessage, AContext));
end;

end.
