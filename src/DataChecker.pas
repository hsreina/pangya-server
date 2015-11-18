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
  playerInfo2Size = SizeOf(TPlayerInfo2);
  playerEqipedItemsSize = SizeOf(TPlayerEquipedItems);
begin
  if not (playerCharacterSize = $201) then
  begin
    raise Exception.CreateFmt('TPlayerCharacter Invalid Size (%x)', [playerCharacterSize]);
  end;

  if not (playerDataSize = $30C5) then
  begin
    raise Exception.CreateFmt('TPlayerData Invalid Size (%x)', [playerDataSize]);
  end;

  if not (playerInfo2Size = $EF) then
  begin
    raise Exception.CreateFmt('TPlayerInfo2 Invalid Size (%x)', [playerInfo2Size]);
  end;

  if not (playerEqipedItemsSize = $74) then
  begin
    raise Exception.CreateFmt('TPlayerEquipedItems Invalid Size (%x)', [playerEqipedItemsSize]);
  end;


end;

end.
