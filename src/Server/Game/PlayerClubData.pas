{*******************************************************}
{                                                       }
{       Pangya Server                                   }
{                                                       }
{       Copyright (C) 2015 Shad'o Soft tm               }
{                                                       }
{*******************************************************}

unit PlayerClubData;

interface

uses ClubStats;

type

  TPlayerClubData = packed record
    Id: UInt32;
    IffId: UInt32;
    Un1: array [0..$9] of UTF8Char;
    Stats: TClubStats;
    function ToStr: RawByteString;
  end;

implementation

function TPlayerClubData.ToStr: RawByteString;
begin
  setLength(result, sizeof(TPlayerClubData));
  move(self, result[1], sizeof(TPlayerClubData));
end;

end.
