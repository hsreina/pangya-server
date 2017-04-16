unit Utils;

interface

function GenerateRandomString(const ALength: Integer;
  const ACharSequence: AnsiString = 'abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ1234567890'
): AnsiString;

implementation

function GenerateRandomString(const ALength: Integer;
  const ACharSequence: AnsiString = 'abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ1234567890'
): AnsiString;
var
  C1, sequence_length: Integer;
begin
  sequence_length := Length(ACharSequence);
  SetLength(result, ALength);

  for C1 := 1 to ALength do
  begin
    result[C1] := ACharSequence[Random(sequence_length) + 1];
  end;
end;

end.
