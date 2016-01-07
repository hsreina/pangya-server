{*******************************************************}
{                                                       }
{       Pangya Server                                   }
{                                                       }
{       Copyright (C) 2015 Shad'o Soft tm               }
{                                                       }
{*******************************************************}

unit DataChecker;

interface

uses PlayerCaddie;

type
  TDataChecker = class
    procedure Validate;
  end;

implementation

uses
  PlayerCharacter, System.SysUtils, PlayerData, PlayerClubData, ShotData,
  PlayerEquipment;

procedure TDataChecker.Validate;
const
  playerCharacterDataSize = SizeOf(TPlayerCharacterData);
  playerDataSize = SizeOf(TPlayerData);
  playerInfo2Size = SizeOf(TPlayerInfo2);
  playerEqipedItemsSize = SizeOf(TPlayerEquipment);
  playerClubDataSize = SizeOf(TPlayerClubData);
  playerCaddieDataSize = SizeOf(TPlayerCaddieData);
  shotDataSize = SizeOf(TShotData);
  playerInfoSize = SizeOf(TPlayerInfo1);
begin

  if not (playerClubDataSize = $26) then
  begin
    raise Exception.CreateFmt('TPlayerClubData Invalid Size (%x)', [playerClubDataSize]);
  end;

  if not (playerCharacterDataSize = $201) then
  begin
    raise Exception.CreateFmt('TPlayerCharacter Invalid Size (%x)', [playerCharacterDataSize]);
  end;

  if not (playerEqipedItemsSize = $74) then
  begin
    raise Exception.CreateFmt('TPlayerEquipedItems Invalid Size (%x)', [playerEqipedItemsSize]);
  end;

  if not (shotDataSize = $38) then
  begin
    raise Exception.CreateFmt('TShotData Invalid Size (%x)', [shotDataSize]);
  end;

  if not (playerCaddieDataSize = $19) then
  begin
    raise Exception.CreateFmt('TPlayerCaddieData Invalid Size (%x)', [playerCaddieDataSize]);
  end;

  if not (playerInfoSize = $10B) then
  begin
    raise Exception.CreateFmt('TPlayerInfo1 Invalid Size (%x)', [playerInfoSize]);
  end;

  if not (playerInfo2Size = $EF) then
  begin
    raise Exception.CreateFmt('TPlayerInfo2 Invalid Size (%x)', [playerInfo2Size]);
  end;

  if not (playerDataSize = $30C5) then
  begin
    raise Exception.CreateFmt('TPlayerData Invalid Size (%x)', [playerDataSize]);
  end;

end;

end.
