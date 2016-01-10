{*******************************************************}
{                                                       }
{       Pangya Server                                   }
{                                                       }
{       Copyright (C) 2015 Shad'o Soft tm               }
{                                                       }
{*******************************************************}

unit PlayerQuest;

interface

type
  TPlayerQuest = class
    private
      var m_questData: array [0..2] of UInt32;
      procedure GuardAgainstInvalidIndex(index: UInt16);
    public
      constructor Create;
      destructor Destroy; override;
      function GetQuestData(index: UInt16): UInt32;
      procedure SetQuestData(index: UInt16; value: UInt32);
  end;

implementation

uses GameServerExceptions;

constructor TPlayerQuest.Create;
begin
  inherited;
  FillChar(m_questData, SizeOf(UInt32) * Length(m_questData), 0);
end;

destructor TPlayerQuest.Destroy;
begin
  inherited;
end;

function TPlayerQuest.GetQuestData(index: UInt16): UInt32;
begin
  GuardAgainstInvalidIndex(index);
  Exit(m_questData[index]);
end;

procedure TPlayerQuest.SetQuestData(index: UInt16; value: UInt32);
begin
  GuardAgainstInvalidIndex(index);
  m_questData[index] := value;
end;

procedure TPlayerQuest.GuardAgainstInvalidIndex(index: UInt16);
begin
  if index >= Length(m_questData) then
  begin
    raise InvalidIndexException.Create('Invalid index');
  end;
end;

end.
