{*******************************************************}
{                                                       }
{       Pangya Server                                    }
{                                                       }
{       Copyright (C) 2015 Shad'o Soft tm               }
{                                                       }
{*******************************************************}

program PangyaServer;

{$APPTYPE CONSOLE}
{$DEFINE CONSOLE}

uses
  {$IFDEF DEBUG}
  {$IFDEF MSWINDOWS}
  {$IFDEF CPUX32}
  FastMM4 in 'Libs\Fast\FastMM4.pas',
  FastMM4Messages in 'Libs\Fast\FastMM4Messages.pas',
  {$ENDIF}
  {$ENDIF }
  {$ENDIF }
  {$IFDEF RELEASE}
  msvcrtMM,
  {$ENDIF }
  SysUtils,
  ConsolePas in 'ConsolePas.pas',
  Logging in 'Logging.pas',
  CryptLib in 'CryptLib.pas',
  SyncClient in 'Client\SyncClient.pas',
  Client in 'Server\Client.pas',
  Server in 'Server\Server.pas',
  SyncableServer in 'Server\SyncableServer.pas',
  LoginPlayer in 'Server\Login\LoginPlayer.pas',
  LoginServer in 'Server\Login\LoginServer.pas',
  SyncUser in 'Server\Sync\SyncUser.pas',
  Database in 'Server\Sync\Database.pas',
  SyncServer in 'Server\Sync\SyncServer.pas',
  GameServerPlayer in 'Server\Game\GameServerPlayer.pas',
  GameServer in 'Server\Game\GameServer.pas',
  LobbiesList in 'Server\Game\LobbiesList.pas',
  Lobby in 'Server\Game\Lobby.pas',
  PlayerCharacter in 'Server\Game\PlayerCharacter.pas',
  PlayerCharacters in 'Server\Game\PlayerCharacters.pas',
  PlayerData in 'Server\Game\PlayerData.pas',
  utils in 'utils.pas',
  DataChecker in 'DataChecker.pas',
  Game in 'Server\Game\Game.pas',
  GamesList in 'Server\Game\GamesList.pas',
  GameServerExceptions in 'Server\Game\Exceptions\GameServerExceptions.pas',
  defs in 'defs.pas',
  PlayerAction in 'Server\Game\PlayerAction.pas',
  PlayerItems in 'Server\Game\PlayerItems.pas',
  PlayerItem in 'Server\Game\PlayerItem.pas',
  PlayerGenericData in 'Server\Game\PlayerGenericData.pas',
  PlayerGenericDataList in 'Server\Game\PlayerGenericDataList.pas',
  PlayerClubData in 'Server\Game\PlayerClubData.pas',
  PlayerCaddies in 'Server\Game\PlayerCaddies.pas',
  PlayerCaddie in 'Server\Game\PlayerCaddie.pas',
  GameHoleInfo in 'Server\Game\GameHoleInfo.pas',
  WindInformation in 'Server\Game\WindInformation.pas',
  PlayerMascots in 'Server\Game\PlayerMascots.pas',
  PlayerMascot in 'Server\Game\PlayerMascot.pas',
  GenericDataRecord in 'Server\Game\GenericDataRecord.pas',
  BongdatriShop in 'Server\Game\MiniGames\Bongdari\BongdatriShop.pas',
  PlayerEquipment in 'Server\Game\PlayerEquipment.pas',
  PlayerQuest in 'Server\Game\PlayerQuest.pas',
  PlayersList in 'Server\Game\PlayersList.pas',
  IffManager in 'Iff\IffManager.pas',
  IffManager.Part in 'Iff\IffManager.Part.pas',
  IffManager.SetItem in 'Iff\IffManager.SetItem.pas',
  IffManager.IffEntry in 'Iff\IffManager.IffEntry.pas',
  IffManager.IffEntryList in 'Iff\IffManager.IffEntryList.pas',
  IffManager.IffEntryBase in 'Iff\IffManager.IffEntryBase.pas',
  IffManager.Item in 'Iff\IffManager.Item.pas',
  IffManager.DataCheck in 'Iff\IffManager.DataCheck.pas',
  IffManager.Ball in 'Iff\IffManager.Ball.pas',
  IffManager.Caddie in 'Iff\IffManager.Caddie.pas',
  IffManager.ClubSet in 'Iff\IffManager.ClubSet.pas',
  IffManager.Club in 'Iff\IffManager.Club.pas',
  IffManager.Skin in 'Iff\IffManager.Skin.pas',
  IffManager.Mascot in 'Iff\IffManager.Mascot.pas',
  IffManager.AuxPart in 'Iff\IffManager.AuxPart.pas',
  GameHoles in 'Server\Game\GameHoles.pas',
  IffManager.Character in 'Iff\IffManager.Character.pas',
  PlayerLockerItem in 'Server\Game\PlayerLockerItem.pas',
  IffManager.HairStyle in 'Iff\IffManager.HairStyle.pas',
  PlayerShopItem in 'Server\Game\PlayerShopItem.pas',
  ClubStats in 'Server\Game\ClubStats.pas',
  ServerOptions in 'Server\Game\ServerOptions.pas',
  SerialList in 'Collections\SerialList.pas',
  SyncClientReadThread in 'Client\SyncClientReadThread.pas',
  Packet in 'Packets\Packet.pas',
  PacketReader in 'Packets\PacketReader.pas',
  PacketWriter in 'Packets\PacketWriter.pas',
  Types.PangyaBytes in 'Types\Types.PangyaBytes.pas',
  Types.ShotData in 'Types\Types.ShotData.pas',
  Types.Vector3 in 'Types\Types.Vector3.pas',
  PacketsDef in 'Packets\PacketsDef.pas',
  PacketData in 'Packets\PacketData.pas',
  ServerApp in 'ServerApp.pas',
  PlayerMoneyPacket in 'Packets\Server\PlayerMoneyPacket.pas',
  MMO.Lock in 'Libs\MMO\MMO.Lock.pas',
  MMO.OptionalCriticalSection in 'Libs\MMO\MMO.OptionalCriticalSection.pas',
  Types.PangyaTypes in 'Types\Types.PangyaTypes.pas';

var
  serverApp: TServerApp;
  command: string;

begin
{$IFDEF MSWINDOWS}
	ReportMemoryLeaksOnShutdown := DebugHook <> 0;
{$ENDIF}
  try
    serverApp := TServerApp.Create;

    serverApp.Start;

    while serverApp.IsRunning do
    begin
      Write('>');
      ReadLn(command);
      if not serverApp.ParseCommand(command) then
      begin
        Console.Log('Invalid command');
      end;
    end;

    serverApp.Stop;
    serverApp.Free;

  except
    on E: Exception do
    begin
      Console.Log(E.ClassName + ': ' + E.Message, C_RED);
      ReadLn;
    end;
  end;
end.
