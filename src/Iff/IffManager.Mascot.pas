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
    var un: array [0..$113] of AnsiChar;
  End;

  TMascotDataClass = class (TIffEntry<TMascotData>)
    public
      constructor Create(data: PAnsiChar);
  end;

  TMascot = class (TIffEntryList<TMascotData, TMascotDataClass>)
    private
    public
      function GetDataSize: UInt32; override;
  end;

implementation

uses ConsolePas;

constructor TMascotDataClass.Create(data: PAnsiChar);
begin
  inherited;
end;

function TMascot.GetDataSize: UInt32;
begin
  Result := $11C;
end;

end.
