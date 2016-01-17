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
    var un1: array [0..$FB] of AnsiChar;
  End;

  TCharacterDataClass = class (TIffEntry<TCharacterData>)
    public
      constructor Create(data: PAnsiChar);
  end;

  TCharacter = class (TIffEntryList<TCharacterData, TCharacterDataClass>)
    private
  end;

implementation

uses ConsolePas;

constructor TCharacterDataClass.Create(data: PAnsiChar);
begin
  inherited;
end;

end.
