unit PlayerLockerItem;

interface

type
  TPlayerLockerItemData = packed record // $B0
    var Id: UInt32;
    var Un1: UInt32;
    var IffId: UInt32;
    var Un2: UInt32;
    var Count: UInt32;
    var Un3: array [0..$9B] of AnsiChar;
  end;

implementation

end.
