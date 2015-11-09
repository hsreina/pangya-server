unit Tools;

interface

function GetDataFromfile(filepath: AnsiString): AnsiString;

implementation

uses
  SysUtils;

function GetDataFromfile(filepath: AnsiString): AnsiString;
var
  x:THandle;
  size: Integer;
  data:ansistring;
begin
  x := fileopen(filepath,$40);
  size := fileseek(x,0,2);
  fileseek(x, 0, 0);
  setlength(data, size);
  fileread(x, data[1], size);
  fileclose(x);
  result := data;
end;


end.
