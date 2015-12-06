unit GameHoleInfo;

interface

uses WindInformation;

type
  TGameHoleInfo = class
    public
      var Weather: UInt8;
      var Wind: TWindInformation;
      var Hole: UInt8;
      var Map: UInt8;
  end;

implementation

end.
