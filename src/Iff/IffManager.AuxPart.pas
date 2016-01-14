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
    var un: array [0..$C3] of AnsiChar;
  End;

  TAuxPartDataClass = class (TIffEntry<TAuxPartData>)
    public
      constructor Create(data: PAnsiChar);
  end;

  TAuxPart = class (TIffEntryList<TAuxPartData, TAuxPartDataClass>)
    private
    public
      function GetDataSize: UInt32; override;
  end;

implementation

uses ConsolePas;

constructor TAuxPartDataClass.Create(data: PAnsiChar);
begin
  inherited;
end;

function TAuxPart.GetDataSize: UInt32;
begin
  Result := $CC;
end;

end.
