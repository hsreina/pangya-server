{*******************************************************}
{                                                       }
{       Pangya Server                                   }
{                                                       }
{       Copyright (C) 2015 Shad'o Soft tm               }
{                                                       }
{*******************************************************}

unit PlayerMascot;

interface

uses PlayerGenericData, Math;

type
  TPlayerMascotData = packed record
    var base: TPlayerItemBase;
    var Un1: array [0..$4] of UTF8Char;
    var Text: array [0..$F] of UTF8Char;
    var Un2: array [0..$20] of UTF8Char;
    function ToStr: RawByteString;
  end;

  TPlayerMascot = class (TPlayerGenericData<TPlayerMascotData>)
    public
      procedure setText(newText: RawByteString);
      constructor Create;
      destructor Destroy; override;
  end;

implementation


procedure TPlayerMascot.setText(newText: RawByteString);
begin
  newText := newText + #$00;
  move(newText[1], m_data.text[0], min(length(newText), 16));
end;

constructor TPlayerMascot.Create;
begin
  inherited;
  self.setText('PANGYA!');
end;

destructor TPlayerMascot.Destroy;
begin
  inherited;
end;

function TPlayerMascotData.ToStr: RawByteString;
begin
  setLength(result, sizeof(TPlayerMascotData));
  move(self, result[1], sizeof(TPlayerMascotData));
end;

end.
