{*******************************************************}
{                                                       }
{       Pangya Server                                   }
{                                                       }
{       Copyright (C) 2015 Shad'o Soft tm               }
{                                                       }
{*******************************************************}

unit IffManager.AuxPart;

interface

uses
  IffManager.IffEntry, IffManager.IffEntryList;

type

  TAuxPartData = packed Record // $CC
    var base: TIffbase;
    var un: array [0..$3B] of UTF8Char;
  End;

  TAuxPartDataClass = class (TIffEntry<TAuxPartData>)
    public
      constructor Create(data: PUTF8Char);
  end;

  TAuxPart = class (TIffEntryList<TAuxPartData, TAuxPartDataClass>)
    private
    public
  end;

implementation

constructor TAuxPartDataClass.Create(data: PUTF8Char);
begin
  inherited;
end;

end.
