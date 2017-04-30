unit TestCryptLib;

interface

uses
  TestFramework, CryptLib, windows;

type
  {
    To help to make the tests match expected results for the server and game,
    Encrypt functions use static data with static key 0
    Decrypt functions use dynamic data encryption with dynamic key and dynamic AnsiString data
  }
  TestTCryptLib = class(TTestCase)
  strict private
    var FCryptLib: TCryptLib;
    procedure CheckClientEncryptDecryptDataWithKey(data: AnsiString; key: UInt8);
    procedure CheckServerEncryptDecryptDataWithKey(data: AnsiString; key: UInt8);
  public
    procedure SetUp; override;
    procedure TearDown; override;
  published
    procedure TestClientDecrypt;
    procedure TestServerDecrypt;
    procedure TestClientEncrypt;
    procedure TestServerEncrypt;
    procedure TestClientDecrypt2;
  end;

implementation

uses
  SysUtils, Utils, Types.PangyaBytes;

const
  encryptedClientData: AnsiString =
    #$34#$22#$00#$00#$F0#$00#$00#$02#$C6#$00#$68#$67#$74#$6C#$04#$0A +
    #$0E#$4C#$1B#$00#$05#$4C#$13#$52#$6D#$6C#$64#$34#$1F#$31#$32#$3E +
    #$2E#$01#$1C#$07#$00#$01;

  decryptedClientData: AnsiString =
    #$00#$00#$02#$0D#$00#$68#$65#$79#$6C#$6C#$6F#$77#$20#$77#$6F#$72 +
    #$6C#$64#$3D#$1F#$00#$00#$09#$00#$31#$32#$37#$2E#$30#$2E#$30#$2E +
    #$31;

  decryptedServerData: AnsiString =
    #$96#$00#$FF#$E0#$F5#$05#$00#$00#$00#$00;

  encryptedServerData: AnsiString =
    #$EE#$13#$00#$FB#$00#$00#$00#$36#$1B#$96#$00#$F5#$FB#$63#$05#$FF +
    #$E0#$F5#$05#$11#$00#$00;

procedure TestTCryptLib.SetUp;
begin
  FCryptLib := TCryptLib.Create;
end;

procedure TestTCryptLib.TearDown;
begin
  FCryptLib.Free;
  FCryptLib := nil;
end;

procedure TestTCryptLib.TestClientDecrypt;
begin
  Check(FCryptLib.ClientDecrypt(encryptedClientData, 0) = decryptedClientData, 'Failed to decrypted client data');
end;

procedure TestTCryptLib.TestClientDecrypt2;
var
  buffinSize, buffoutSize: UInt32;
  buffin, buffout: TPangyaBytes;
  strBuffout: AnsiString;
begin
  buffinSize := Length(encryptedClientData);
  setLength(buffin, buffinSize);
  move(encryptedClientData[1], buffin[0], buffinSize);
  FCryptLib.ClientDecrypt2(buffin, buffout, 0);
  buffoutSize := Length(buffout);
  setLength(strBuffout, buffoutSize);
  move(buffout[0], strBuffout[1], buffoutSize);
  Check(strBuffout = decryptedClientData, 'Failed to decrypt client data');
end;

procedure TestTCryptLib.TestServerDecrypt;
begin
  Check(FCryptLib.ServerDecrypt(encryptedServerData, 0) = decryptedServerData, 'Failed to decrypted server data');
end;

procedure TestTCryptLib.TestClientEncrypt;
var
  I: Integer;
begin
  for I := 0 to $ff do
  begin

    CheckClientEncryptDecryptDataWithKey(GenerateRandomString(I + 1), I);
  end;
end;

procedure TestTCryptLib.CheckClientEncryptDecryptDataWithKey(data: AnsiString; key: Byte);
var
  encrypted: AnsiString;
  decrypted: AnsiString;
begin
  encrypted := FCryptLib.ClientEncrypt(data, key, 0);
  decrypted := FCryptLib.ClientDecrypt(encrypted, key);
  Check(decrypted = data, String.Format('client Encrypt/Decrypt with key %d failed', [key]));
end;

procedure TestTCryptLib.TestServerEncrypt;
var
  I: Integer;
begin
  for I := 0 to $ff do
  begin
    CheckServerEncryptDecryptDataWithKey(GenerateRandomString(I + 1), I);
  end;
end;

procedure TestTCryptLib.CheckServerEncryptDecryptDataWithKey(data: AnsiString; key: Byte);
var
  encrypted: AnsiString;
  decrypted: AnsiString;
begin
  encrypted := FCryptLib.ServerEncrypt(data, key);
  decrypted := FCryptLib.ServerDecrypt(encrypted, key);
  Check(decrypted = data, String.Format('client Encrypt/Decrypt with key %d failed', [key]));
end;

initialization
  // Register any test cases with the test runner
  RegisterTest(TestTCryptLib.Suite);
end.

