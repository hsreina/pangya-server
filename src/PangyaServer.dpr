program PangyaServer;

uses
  {$IFDEF DEBUG}
  FastMM4 in 'Libs\Fast\FastMM4.pas',
  FastMM4Messages in 'Libs\Fast\FastMM4Messages.pas',
  {$ENDIF }
  {$IFDEF RELEASE}
  msvcrtMM,
  {$ENDIF}
  Vcl.Forms,
  MainPas in 'MainPas.pas' {Main},
  ConsolePas in 'ConsolePas.pas' {Console},
  Logging in 'Logging.pas',
  CryptLib in 'CryptLib.pas',
  Buffer in 'Buffer.pas',
  PangyaPacketsDef in 'PangyaPacketsDef.pas',
  SyncClient in 'Client\SyncClient.pas',
  Client in 'Server\Client.pas',
  ClientPacket in 'Server\ClientPacket.pas',
  Server in 'Server\Server.pas',
  ServerClient in 'Server\ServerClient.pas',
  SyncableServer in 'Server\SyncableServer.pas',
  LoginPlayer in 'Server\Login\LoginPlayer.pas',
  LoginServer in 'Server\Login\LoginServer.pas',
  SyncServer in 'Server\Sync\SyncServer.pas',
  SyncUser in 'Server\Sync\SyncUser.pas',
  Database in 'Server\Sync\Database.pas',
  PacketData in 'Server\PacketData.pas',
  GameServerPlayer in 'Server\Game\GameServerPlayer.pas',
  gameServer in 'Server\Game\gameServer.pas',
  LobbiesList in 'Server\Game\LobbiesList.pas',
  Lobby in 'Server\Game\Lobby.pas',
  PlayerCharacter in 'Server\Game\PlayerCharacter.pas',
  PlayerCharacters in 'Server\Game\PlayerCharacters.pas',
  PlayerData in 'Server\Game\PlayerData.pas',
  utils in 'utils.pas',
  PangyaBuffer in 'PangyaBuffer.pas',
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
  ShotData in 'ShotData.pas',
  Vector3 in 'Vector3.pas',
  PlayerMascots in 'Server\Game\PlayerMascots.pas',
  PlayerMascot in 'Server\Game\PlayerMascot.pas',
  GenericDataRecord in 'Server\Game\GenericDataRecord.pas',
  BongdatriShop in 'Server\Game\MiniGames\Bongdari\BongdatriShop.pas',
  PlayerEquipment in 'Server\Game\PlayerEquipment.pas';

{$R *.res}

begin
  ReportMemoryLeaksOnShutdown := DebugHook <> 0;

  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  Application.CreateForm(TMain, Main);
  Application.CreateForm(TConsole, Console);
  Application.Run;
end.
