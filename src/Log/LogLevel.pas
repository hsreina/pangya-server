unit LogLevel;

interface

type
  {$SCOPEDENUMS ON}
  TLogLevel = (
    Emergency = 0,
    Alert = 1,
    Critical = 2,
    Error = 3,
    Warning = 4,
    Notice = 5,
    Info = 6,
    Debug = 7
  );
  {$SCOPEDENUMS OFF}

implementation

end.
