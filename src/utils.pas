unit utils;

interface

uses
  SysUtils;

type
  TIfThen<T>= function(conditionResult: Boolean; IfValue, ElseValue: T): T;

function GetDataFromfile(filePath: string): AnsiString;
procedure WriteDataToFile(filePath: string; data: AnsiString);

implementation

function GetDataFromfile(filePath: string): AnsiString;
var
  x: THandle;
  size: Integer;
  data: AnsiString;
begin
  x := fileopen(filepath, $40);
  size := fileseek(x, 0, 2);
  fileseek(x, 0, 0);
  setlength(data, size);
  fileread(x, data[1], size);
  fileclose(x);
  Exit(data);
end;

procedure WriteDataToFile(filePath: string; data: AnsiString);
var
  x: THandle;
  size: Integer;
begin
  x := FileCreate(filepath);
  size := Length(data);
  FileWrite(x, data[1], size);
  fileclose(x);
end;

end.
