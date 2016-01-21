{*******************************************************}
{                                                       }
{       Pangya Server                                   }
{                                                       }
{       Copyright (C) 2015 Shad'o Soft tm               }
{                                                       }
{*******************************************************}

unit ClubStats;

interface

type
  PClubStats = ^TClubStats;
  TClubStats = packed record
    upgradeStats: array [0..$4] of word; // power, control, accurancy, spin, curve
  end;

implementation

end.
