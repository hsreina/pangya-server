{*******************************************************}
{                                                       }
{       Pangya Server                                   }
{                                                       }
{       Copyright (C) 2015 Shad'o Soft tm               }
{                                                       }
{*******************************************************}

unit ClientPacket;

interface

uses Buffer, SysUtils, PangyaBuffer;

type
  TClientPacket = class (TPangyaBuffer)
    public
      function ToStr: AnsiString;
      function GetRemainingData: AnsiString;
      procedure Log;
  end;

implementation

uses ConsolePas;

function TClientPacket.ToStr;
var
  previousOffset: integer;
  Size: integer;
begin
  previousOffset := self.Seek(0, 1);
  self.Seek(0, 0);
  size := self.GetSize;
  SetLength(Result, size);
  self.Read(Result[1], size);
  self.Seek(previousOffset, 0);
end;

function TClientPacket.GetRemainingData;
var
  previousOffset: integer;
  Size: integer;
begin
  previousOffset := self.Seek(0, 1);
  size := self.GetSize - previousOffset;
  SetLength(Result, size);
  self.Read(Result[1], size);
  self.Seek(previousOffset, 0);
end;

procedure TClientPacket.Log;
begin
  Console.WriteDump(self.ToStr);
end;

end.
