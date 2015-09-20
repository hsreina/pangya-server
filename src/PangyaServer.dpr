program PangyaServer;

uses
  Vcl.Forms,
  MainPas in 'MainPas.pas' {Main},
  LoginServer in 'LoginServer.pas',
  Server in 'Server.pas',
  ConsolePas in 'ConsolePas.pas' {Console},
  Logging in 'Logging.pas',
  Client in 'Client.pas',
  CryptLib in 'CryptLib.pas',
  Buffer in 'Buffer.pas',
  LoginPlayer in 'LoginPlayer.pas',
  ServerClient in 'ServerClient.pas',
  ClientPacket in 'ClientPacket.pas',
  PangyaPacketsDef in 'PangyaPacketsDef.pas',
  gameServer in 'gameServer.pas',
  GamePlayer in 'GamePlayer.pas';

{$R *.res}

begin
  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  Application.CreateForm(TMain, Main);
  Application.CreateForm(TConsole, Console);
  Application.Run;
end.
