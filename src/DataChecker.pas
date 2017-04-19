{*******************************************************}
{                                                       }
{       Pangya Server                                   }
{                                                       }
{       Copyright (C) 2015 Shad'o Soft tm               }
{                                                       }
{*******************************************************}

unit DataChecker;

interface

uses PlayerCaddie, PlayerItem, PlayerLockerItem;

type
  TDataChecker = class
    procedure Validate;
  end;

implementation

uses
  PlayerCharacter, System.SysUtils, PlayerData, PlayerClubData,
  PlayerEquipment, PlayerMascot, PlayerShopItem, ConsolePas, ServerOptions,
  Types.ShotData;

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
  playerMascotSize = SizeOf(TPlayerMascotData);
  playerItemSize = SizeOf(TPlayerItemData);
  playerLockerItemSize = SizeOf(TPlayerLockerItemData);
  playerShopItemSize = SizeOf(TPlayerShopItem);
  serverOptionsSize = SizeOf(TServerOptionsData);
begin

  if not (playerShopItemSize = $AC) then
  begin
    raise Exception.CreateFmt('TPlayerShopItem Invalid Size (%x)', [playerShopItemSize]);
  end;

  if not (playerLockerItemSize = $B0) then
  begin
    raise Exception.CreateFmt('TPlayerLockerItemData Invalid Size (%x)', [playerLockerItemSize]);
  end;

  if not (playerItemSize = $C4) then
  begin
    raise Exception.CreateFmt('TPlayerItemData Invalid Size (%x)', [playerItemSize]);
  end;

  Console.Log(Format('SizeOf(playerMascotSize) %x', [playerMascotSize]));
  if not (playerMascotSize = $3E) then
  begin
    raise Exception.CreateFmt('TPlayerMascotData Invalid Size (%x)', [playerMascotSize]);
  end;

  // Seem to be 1C  // 26 - 1C
  if not (playerClubDataSize = $1C) then
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

  if not (playerDataSize = $2F84) then
  begin
    raise Exception.CreateFmt('TPlayerData Invalid Size (%x)', [playerDataSize]);
  end;

  if not (serverOptionsSize = $141) then
  begin
    raise Exception.CreateFmt('TServerOptionsData Invalid Size (%x)', [serverOptionsSize]);
  end;

end;

end.
