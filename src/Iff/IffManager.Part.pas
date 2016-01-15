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
    var un: array [0..$18F] of AnsiChar;
  End;

  TPartDataClass = class (TIffEntry<TPartData>)
    public
      constructor Create(data: PAnsiChar);
  end;

  TPart = class (TIffEntryList<TPartData, TPartDataClass>)
    private
    public
  end;

implementation

uses ConsolePas;

constructor TPartDataClass.Create(data: PAnsiChar);
begin
  inherited;
end;

end.
