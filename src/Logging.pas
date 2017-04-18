{*******************************************************}
{                                                       }
{       Pangya Server                                   }
{                                                       }
{       Copyright (C) 2015 Shad'o Soft tm               }
{                                                       }
{*******************************************************}

unit Logging;

interface

type

  TLogType = (
    TLogType_msg,
    TLogType_wrn,
    TLogType_err,
    TLogType_not
  );

  TOnLogEvent = procedure(sender: TObject; msg: string; logType: TLogType) of object;

  TLogging = class abstract
    private
      var m_onLogEvent: TOnLogEvent;
    protected
      procedure Log(msg: string); overload;
      procedure Log(msg: string; logType: TLogType); overload;
    public
      property OnLog: TOnLogEvent read m_onLogEvent write m_onLogEvent;
  end;

implementation

procedure TLogging.Log(msg: string);
begin
  self.Log(msg, TLogType.TLogType_msg);
end;

procedure TLogging.Log(msg: string; logType: TLogType);
begin
  if (Assigned(self.m_onLogEvent)) then
  begin
    self.m_onLogEvent(self, msg, logType);
  end;
end;

end.


