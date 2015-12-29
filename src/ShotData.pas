{*******************************************************}
{                                                       }
{       Pangya Server                                   }
{                                                       }
{       Copyright (C) 2015 Shad'o Soft tm               }
{                                                       }
{*******************************************************}

unit ShotData;

interface

uses Vector3;

type
  TShotData = packed record
    connectionId: UInt32;
    pos: TVector3;
    fallType: UInt8;
    un: array [0..1] of ansichar;
    pangs: integer;
    bonusPangs: integer;
    un1: array [0..$1C] of AnsiChar;
  end;

implementation

end.
