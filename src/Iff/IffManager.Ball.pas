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
    var un: array [0..$287] of AnsiChar;
  End;

  TBallDataClass = class (TIffEntry<TBallData>)
    public
      constructor Create(data: PAnsiChar);
  end;

  TBall = class (TIffEntryList<TBallData, TBallDataClass>)
    private
    public
  end;

implementation

uses ConsolePas;

constructor TBallDataClass.Create(data: PAnsiChar);
begin
  inherited;
end;

end.
