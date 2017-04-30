program PangyaServerTests;
{

  Delphi DUnit Test Project
  -------------------------
  This project contains the DUnit test framework and the GUI/Console test runners.
  Add "CONSOLE_TESTRUNNER" to the conditional defines entry in the project options
  to use the console test runner.  Otherwise the GUI test runner will be used by
  default.

}

{$IFDEF CONSOLE_TESTRUNNER}
{$APPTYPE CONSOLE}
{$ENDIF}

uses
  DUnitTestRunner,
  TestCryptLib in 'TestCryptLib.pas',
  CryptLib in '..\CryptLib.pas',
  Utils in 'Tools\Utils.pas',
  Types.PangyaBytes in '..\Types\Types.PangyaBytes.pas';

{$R *.RES}

begin
  DUnitTestRunner.RunRegisteredTests;
end.

