{*******************************************************}
{                                                       }
{       Pangya Server                                   }
{                                                       }
{       Copyright (C) 2015 Shad'o Soft tm               }
{                                                       }
{*******************************************************}

unit IffManager.Character;

interface

uses
  IffManager.IffEntry, IffManager.IffEntryList;

type

  TCharacterData = packed Record // $18C
    var base: TIffbase;
    var un1: array [0..$FB] of UTF8Char;
  End;

  TCharacterDataClass = class (TIffEntry<TCharacterData>)
    public
      constructor Create(data: PUTF8Char);
  end;

  TCharacter = class (TIffEntryList<TCharacterData, TCharacterDataClass>)
    private
  end;

implementation

constructor TCharacterDataClass.Create(data: PUTF8Char);
begin
  inherited;
end;

end.
