{*******************************************************}
{                                                       }
{       Pangya Server                                   }
{                                                       }
{       Copyright (C) 2015 Shad'o Soft tm               }
{                                                       }
{*******************************************************}

unit WindInformation;

interface

type
  TWindInformation = packed record
    var windPower: UInt16;
    var windDirection: UInt16;
  end;

implementation

end.
