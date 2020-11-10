unit LoggerInterface;

interface

uses LogLevel;

type
  ILoggerInterface = interface(IInterface)
    ['{17B67909-721C-4229-A705-70FAD5B7833F}']
    // The system is unusable
    procedure Emergency(const AMessage: string); overload;
    procedure Emergency(const AMessage: string; const AContext: array of const); overload;
    // Immediate action is required
    procedure Alert(const AMessage: string); overload;
    procedure Alert(const AMessage: string; const AContext: array of const); overload;
    // Critical conditions
    procedure Critical(const AMessage: string); overload;
    procedure Critical(const AMessage: string; const AContext: array of const); overload;
    // Errors that do not require immediate attention but should be monitored
    procedure Error(const AMessage: string); overload;
    procedure Error(const AMessage: string; const AContext: array of const); overload;
    // Unusual or undesirable occurrences that are not errors
    procedure Warning(const AMessage: string); overload;
    procedure Warning(const AMessage: string; const AContext: array of const); overload;
    // Normal but significant events
    procedure Notice(const AMessage: string); overload;
    procedure Notice(const AMessage: string; const AContext: array of const); overload;
    // Interesting events
    procedure Info(const AMessage: string); overload;
    procedure Info(const AMessage: string; const AContext: array of const); overload;
    // Detailed information for debugging purposes
    procedure Debug(const AMessage: string); overload;
    procedure Debug(const AMessage: string; const AContext: array of const); overload;
  end;

implementation

end.
