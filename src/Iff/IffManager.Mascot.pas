{*******************************************************}
{                                                       }
{       Pangya Server                                   }
{                                                       }
{       Copyright (C) 2015 Shad'o Soft tm               }
{                                                       }
{*******************************************************}

unit IffManager.Mascot;

interface

uses
  IffManager.IffEntry, IffManager.IffEntryList;

type

  TMascotData = packed Record // $11C
    var base: TIffbase;
    var un: array [0..$8B] of UTF8Char;
  End;

  TMascotDataClass = class (TIffEntry<TMascotData>)
    public
      constructor Create(data: PUTF8Char);
  end;

  TMascot = class (TIffEntryList<TMascotData, TMascotDataClass>)
    private
    public
  end;

implementation

constructor TMascotDataClass.Create(data: PUTF8Char);
begin
  inherited;
end;

end.
