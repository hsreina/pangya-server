unit DataChecker;

interface

type
  TDataChecker = class
    procedure Validate;
  end;

implementation

uses
  PlayerCharacter, System.SysUtils, PlayerData;

procedure TDataChecker.Validate;
const
  playerCharacterSize = SizeOf(TPlayerCharacterData);
  playerDataSize = SizeOf(TPlayerData);
begin
  if not (playerCharacterSize = $201) then
  begin
    raise Exception.CreateFmt('TPlayerCharacter Invalid Size (%x)', [playerCharacterSize]);
  end;

  if not (playerDataSize = $30E9) then
  begin
    raise Exception.CreateFmt('TPlayerData Invalid Size (%x)', [playerDataSize]);
  end;


end;

end.
