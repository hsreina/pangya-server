unit Types.ShotData;

interface

uses Types.Vector3;

type
  TShotData = packed record
    connectionId: UInt32;
    pos: TVector3;
    fallType: UInt8;
    un: array [0..1] of UTF8Char;
    pangs: integer;
    bonusPangs: integer;
    un1: array [0..$1C] of UTF8Char;
  end;

implementation

end.
