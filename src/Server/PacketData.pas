{*******************************************************}
{                                                       }
{       Pangya Server                                   }
{                                                       }
{       Copyright (C) 2015 Shad'o Soft tm               }
{                                                       }
{*******************************************************}

unit PacketData;

interface

type
  TPacketData = AnsiString;
  IPacketData = interface
    ['{FB968063-796C-4021-9C46-E3800E275BFA}']
    function Build: TPacketData;
  end;

implementation

end.
