{*******************************************************}
{                                                       }
{       Pangya Server                                   }
{                                                       }
{       Copyright (C) 2015 Shad'o Soft tm               }
{                                                       }
{*******************************************************}

unit IffManager.Part;

interface

uses
  IffManager.IffEntry, IffManager.IffEntryList;

type

  TPartData = packed Record // $220
    var base: TIffbase;
    var un: array [0..$18F] of UTF8Char;
  End;

  TPartDataClass = class (TIffEntry<TPartData>)
    public
      constructor Create(data: PUTF8Char);
  end;

  TPart = class (TIffEntryList<TPartData, TPartDataClass>)
    private
    public
  end;

implementation

constructor TPartDataClass.Create(data: PUTF8Char);
begin
  inherited;
end;

end.
