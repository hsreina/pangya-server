{*******************************************************}
{                                                       }
{       Pangya Server                                   }
{                                                       }
{       Copyright (C) 2015 Shad'o Soft tm               }
{                                                       }
{*******************************************************}

unit PlayerItem;

interface

uses PacketData, PlayerGenericData;

type

  TPlayerItemData = packed record // $C4
    var base: TPlayerItemBase;
    var Un1: array [0..$49] of AnsiChar;
    var UccCode: array [0 .. $7] of AnsiChar;
    var Un2: array [0..$69] of AnsiChar;
  end;

  TPlayerItem = class (TPlayerGenericData<TPlayerItemData>)
    public
      constructor Create;
  end;

implementation

uses ConsolePas;

constructor TPlayerItem.Create;
var
  uccCode: AnsiString;
begin
  inherited;
  uccCode := '11111111';
  move(uccCode[1], m_data.UccCode[0], 8);
  m_data.Un1[$21] := #$2;
  m_data.Un2[2] := #$1;
end;

end.
