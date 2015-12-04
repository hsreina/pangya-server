unit GameHoleInfo;

interface

uses WindInformation;

type
  TGameHoleInfo = class
    public
      var Weather: UInt8;
      var Wind: TWindInformation;
  end;

implementation

end.
