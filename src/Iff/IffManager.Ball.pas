{*******************************************************}
{                                                       }
{       Pangya Server                                   }
{                                                       }
{       Copyright (C) 2015 Shad'o Soft tm               }
{                                                       }
{*******************************************************}

unit IffManager.Ball;

interface

uses
  IffManager.IffEntry, IffManager.IffEntryList;

type

  TBallData = packed Record // $318
    var base: TIffbase;
    var un: array [0..$287] of UTF8Char;
  End;

  TBallDataClass = class (TIffEntry<TBallData>)
    public
      constructor Create(data: PUTF8Char);
  end;

  TBall = class (TIffEntryList<TBallData, TBallDataClass>)
    private
    public
  end;

implementation

constructor TBallDataClass.Create(data: PUTF8Char);
begin
  inherited;
end;

end.
