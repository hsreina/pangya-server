{*******************************************************}
{                                                       }
{       Pangya Server                                   }
{                                                       }
{       Copyright (C) 2015 Shad'o Soft tm               }
{                                                       }
{*******************************************************}

unit IffManager.HairStyle;

interface

uses
  IffManager.IffEntry, IffManager.IffEntryList;

type

  THairStyleData = packed Record // $AC
    var base: TIffbase;
    var un1: array [0..$17] of UTF8Char;
    var Color: UInt8;
    var Character: UInt8;
    var un2: array [0..$1] of UTF8Char;
  End;

  THairStyleDataClass = class (TIffEntry<THairStyleData>)
    public
      constructor Create(data: PUTF8Char);
      function GetColor: UInt8;
      function GetCharacterIffId: UInt32;
  end;

  THairStyle = class (TIffEntryList<THairStyleData, THairStyleDataClass>)
    private
    public
  end;

implementation

constructor THairStyleDataClass.Create(data: PUTF8Char);
begin
  inherited;
end;

function THairStyleDataClass.GetColor: UInt8;
begin
  Result := m_data.Color;
end;

function THairStyleDataClass.GetCharacterIffId: UInt32;
begin
  Result := $04000000 + m_data.Character;
end;

end.
