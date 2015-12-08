unit DataChecker;

interface

type
  TDataChecker = class
    procedure Validate;
  end;

implementation

uses
  PlayerCharacter, System.SysUtils, PlayerData, PlayerClubData, ShotData;

procedure TDataChecker.Validate;
const
  playerCharacterDataSize = SizeOf(TPlayerCharacterData);
  playerDataSize = SizeOf(TPlayerData);
  playerInfo2Size = SizeOf(TPlayerInfo2);
  playerEqipedItemsSize = SizeOf(TPlayerEquipedItems);
  playerClubDataSize = SizeOf(TPlayerClubData);
  shotDataSize = SizeOf(TShotData);
begin

  if not (playerClubDataSize = $1C) then
  begin
    raise Exception.CreateFmt('TPlayerClubData Invalid Size (%x)', [playerClubDataSize]);
  end;

  if not (playerCharacterDataSize = $201) then
  begin
    raise Exception.CreateFmt('TPlayerCharacter Invalid Size (%x)', [playerCharacterDataSize]);
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

  if not (shotDataSize = $38) then
  begin
    raise Exception.CreateFmt('TShotData Invalid Size (%x)', [shotDataSize]);
  end;

end;

end.
