unit SyncServer;

interface

uses Client, SyncUser, Server, ClientPacket, CryptLib, SysUtils, defs,
  Database;

type

  TSyncClient = TClient<TSyncUser>;

  TSyncServer = class (TServer<TSyncUser>)
    protected
    private

      m_database: TDatabase;

      procedure Init; override;
      procedure OnClientConnect(const client: TSyncClient); override;
      procedure OnClientDisconnect(const client: TSyncClient); override;
      procedure OnReceiveClientData(const client: TSyncClient; const clientPacket: TClientPacket); override;
      procedure OnStart; override;

      procedure SendToGame(const client: TSyncClient; const playerUID: TPlayerUID; const data: AnsiString);
      procedure PlayerAction(const client: TSyncClient; const playerUID: TPlayerUID; const data: AnsiString);

      procedure SyncLoginPlayer(const client: TSyncClient; const clientPacket: TClientPacket);
      procedure SyncGamePlayer(const client: TSyncClient; const clientPacket: TClientPacket);

      procedure HandlePlayerSelectCharacter(const client: TSyncClient; const clientPacket: TClientPacket; const playerUID: TPlayerUID);
      procedure HandlePlayerConfirmNickname(const client: TSyncClient; const clientPacket: TClientPacket; const playerUID: TPlayerUID);
      procedure HandleLoginPlayerLogin(const client: TSyncClient; const clientPacket: TClientPacket; const playerUID: TPlayerUID);
      procedure HandlePlayerSetNickname(const client: TSyncClient; const clientPacket: TClientPacket; const playerUID: TPlayerUID);

      procedure LoginPlayer(const client: TSyncClient; const playerUID: TPlayerUID);

      procedure HandleGamePlayerLogin(const client: TSyncClient; const clientPacket: TClientPacket; const playerUID: TPlayerUID);


    public
      constructor Create(cryptLib: TCryptLib);
      destructor Destroy; override;
  end;

implementation

uses Logging, PangyaPacketsDef, ConsolePas, PlayerCharacters, PlayerCharacter,
  PacketData, utils;

constructor TSyncServer.Create(cryptLib: TCryptLib);
begin
  inherited;
  m_database := TDatabase.Create;
end;

destructor TSyncServer.Destroy;
begin
  inherited;
end;

procedure TSyncServer.Init;
begin
  self.SetPort(7998);
  m_database.Init;
end;

procedure TSyncServer.OnClientConnect(const client: TSyncClient);
begin
  self.Log('TSyncServer.OnClientConnect', TLogType_not);
  client.UID.login := 'Sync';
end;

procedure TSyncServer.OnClientDisconnect(const client: TSyncClient);
begin
  self.Log('TSyncServer.OnClientDisconnect', TLogType_not);
end;

procedure TSyncServer.OnStart;
begin
  self.Log('TSyncServer.OnStart', TLogType_not);
end;

procedure TSyncServer.SendToGame(const client: TSyncClient; const playerUID: TPlayerUID; const data: AnsiString);
begin
  self.Log('TSyncServer.SendToGame', TLogType_not);
  client.Send(#$01#$00 + Write(playerUID.id, 4) + WriteStr(playerUID.login) + data);
end;

procedure TSyncServer.PlayerAction(const client: TSyncClient; const playerUID: TPlayerUID; const data: AnsiString);
begin
  self.Log('TSyncServer.PlayerAction', TLogType_not);
  client.Send(#$02#$00 + Write(playerUID.id, 4) + WriteStr(playerUID.login) + data);
end;

procedure TSyncServer.HandlePlayerSelectCharacter(const client: TSyncClient; const clientPacket: TClientPacket; const playerUID: TPlayerUID);
var
  characterId: UInt32;
  hairColor: UInt16;
  playerCharacters: TPlayerCharacters;
  playerCharacter: TPlayerCharacter;
  characterData: TPacketData;
begin
  self.Log('TSyncServer.HandlePlayerSelectCharacter', TLogType_not);

  clientPacket.GetCardinal(characterId);
  clientPacket.GetWord(hairColor);

  self.Log(Format('chracterId : %x', [characterId]));
  self.Log(Format('hairColor : %x', [hairColor]));

  playerCharacters := TPlayerCharacters.Create;
  playerCharacter := playerCharacters.Add;

  characterData := GetDataFromFile(Format('../data/c_%x.dat', [characterId]));
  Console.Log(Format('Load "../data/c_%x.dat"', [characterId]));
  if not playerCharacter.Load(characterData) then
  begin
    Console.Log(Format('character data not found %x', [characterId]), C_RED);
    Exit;
  end;

  m_database.SavePlayerCharacters(playerUID.id, playerCharacters);

  playerCharacters.Free;

  // validate character
  self.SendToGame(client, playerUID, #$11#$00#$00);

  self.LoginPlayer(client, playerUID);
end;

procedure TSyncServer.HandlePlayerConfirmNickname(const client: TSyncClient; const clientPacket: TClientPacket; const playerUID: TPlayerUID);
var
  nickname: AnsiString;
begin
  self.Log('TSyncServer.HandlePlayerConfirmNickname', TLogType_not);
  nickname := clientPacket.GetStr;

  if m_database.NicknameAvailable(nickname) then
  begin
    self.SendToGame(client, playerUID, #$0E#$00#$00#$00#$00#$00 + WriteStr(nickname));
  end else
  begin
    self.SendToGame(client, playerUID, #$0E#$00#$0B#$00#$00#$00#$21#$D2#$4D#$00);
  end;
end;

procedure TSyncServer.HandleLoginPlayerLogin(const client: TSyncClient; const clientPacket: TClientPacket; const playerUID: TPlayerUID);
var
  login: AnsiString;
  md5Password: AnsiString;
  userId: integer;
begin
  Console.Log('TSyncServer.HandleLoginPlayerLogin', C_BLUE);

  login := clientPacket.GetStr;
  md5Password := clientPacket.GetStr;

  self.Log(Format('login : %s', [login]));
  self.Log(Format('password : %s', [md5Password]));

  userId := m_database.DoLogin(login, md5Password);

  if 0 = userId then
  begin
    self.SendToGame(client, playerUID, #$01#$00#$E2#$72#$D2#$4D#$00#$00#$00);
    Exit;
  end;

  playerUID.SetId(userId);
  self.LoginPlayer(client, playerUID);
end;

procedure TSyncServer.HandleGamePlayerLogin(const client: TSyncClient; const clientPacket: TClientPacket; const playerUID: TPlayerUID);
var
  login: AnsiString;
  UID: UInt32;
  checkA: AnsiString;
  checkB: AnsiString;
  checkC: UInt32;
  clientVersion: AnsiString;
  I: integer;
  d: ansiString;
  playerId: integer;
begin
  Console.Log('TSyncServer.HandleGamePlayerLogin', C_BLUE);

  login := clientPacket.GetStr;

  playerId := m_database.GetPlayerId(login);
  playerUID.SetId(playerId);

  if 0 = playerId then
  begin
    Console.Log('Should do something here', C_RED);
    Exit;
  end;

  clientPacket.GetCardinal(UID);
  clientPacket.Skip(6);
  checkA := clientPacket.GetStr;
  clientVersion := clientPacket.GetStr;

  ClientPacket.getCardinal(checkc);
  checkc := self.Deserialize(checkc);
  self.Log(Format('check c dec : %x, %d', [checkc, checkc]));

  ClientPacket.seek(4, 1);

  checkb := ClientPacket.getStr();
  self.Log(Format('Check b  : %s', [checkb]));

  // main save
  self.SendToGame(client, playerUID, GetDataFromFile('../data/debug/sp21.dat'));

  d := #$70#$00 + m_database.GetPlayerCharacter(playerUID.id);

  WriteDataToFile('debug.dat', d);

  // characters
  self.SendToGame(client, playerUID, d);

  // Send Lobbies list
  self.PlayerAction(client, playerUID, #$02#$00);
end;

procedure TSyncServer.HandlePlayerSetNickname(const client: TSyncClient; const clientPacket: TClientPacket; const playerUID: TPlayerUID);
var
  nickname: AnsiString;
begin
  Console.Log('TLoginServer.HandleConfirmNickname', C_BLUE);
  nickname := clientPacket.GetStr;
  self.Log(Format('nickname : %s', [nickname]));

  m_database.SetNickname(playerUID.login, nickname);

  self.SendToGame(client, playerUID, #$06#$00 + WriteStr(nickname));

  LoginPlayer(client, playerUID);
end;

procedure TSyncServer.LoginPlayer(const client: TSyncClient; const playerUID: TPlayerUID);
begin
  Console.Log('TSyncServer.LoginPlayer', C_BLUE);

  if not m_database.PlayerHaveNicknameSet(playerUID.login) then
  begin
    self.SendToGame(client, playerUID, #$01#$00#$D8#$FF#$FF#$FF#$FF#$00#$00);
    Exit;
  end;

  if not m_database.PlayerHaveAnInitialCharacter(playerUID.login) then
  begin
    // Character selection menu
    self.SendToGame(client, playerUID, #$01#$00#$D9#$00#$00);
    Exit;
  end;

  self.SendToGame(client, playerUID, #$10#$00 + WriteStr('178d22e'));

  self.PlayerAction(client, playerUID, #$01#$00);
end;

procedure TSyncServer.SyncGamePlayer(const client: TSyncClient; const clientPacket: TClientPacket);
var
  playerUID: TPlayerUID;
  packetId: TCGPID;
begin
  self.Log('TSyncServer.SyncGamePlayer', TLogType_not);

  clientPacket.GetInteger(playerUID.id);
  playerUID.login := clientPacket.GetStr;

  self.Log(Format('Player UID : %s', [playerUID.login]));

  if clientPacket.GetBuffer(packetId, 2) then
  begin
    case packetId of
      CGPID_PLAYER_LOGIN:
      begin
        HandleGamePlayerLogin(client, clientPacket, playerUID);
      end;
      else
      begin
        self.Log(Format('Unknow packet Id %x', [Word(packetID)]), TLogType_err);
      end;
    end;
  end;
end;

procedure TSyncServer.SyncLoginPlayer(const client: TSyncClient; const clientPacket: TClientPacket);
var
  playerUID: TPlayerUID;
  packetId: TCLPID;
begin
  self.Log('TSyncServer.SyncLoginPlayer', TLogType_not);

  clientPacket.GetInteger(playerUID.id);
  playerUID.login := clientPacket.GetStr;

  self.Log(Format('Player UID : %s', [playerUID.login]));

  if clientPacket.GetBuffer(packetId, 2) then
  begin
    case packetId of
      CLPID_PLAYER_LOGIN:
      begin
        HandleLoginPlayerLogin(client, clientPacket, playerUID);
      end;
      CLPID_PLAYER_CONFIRM:
      begin
        self.HandlePlayerConfirmNickname(client, clientPacket, playerUID);
      end;
      CLPID_PLAYER_SELECT_CHARCTER:
      begin
        self.HandlePlayerSelectCharacter(client, clientpacket, playerUID);
      end;
      CLPID_PLAYER_SET_NICKNAME:
      begin
        self.HandlePlayerSetNickname(client, clientpacket, playerUID);
      end
      else
      begin
        self.Log(Format('Unknow packet Id %x', [Word(packetID)]), TLogType_err);
      end;
    end;
  end;
end;

procedure TSyncServer.OnReceiveClientData(const client: TSyncClient; const clientPacket: TClientPacket);
var
  packetId: TSSPID;
  server: Byte;
begin
  self.Log('TSyncServer.OnReceiveClientData', TLogType_not);
  if (clientPacket.GetByte(server) and clientPacket.getBuffer(packetID, 2)) then
  begin
    case packetID of
      SSPID_PLAYER_SYNC:
      begin
        if server = 1 then
        begin
          self.SyncLoginPlayer(client, clientPacket);
        end
        else
        if server = 2 then
        begin
          self.SyncGamePlayer(client, clientPacket);
        end;
      end;
      else
      begin
        self.Log(Format('Unknow packet Id %x', [Word(packetID)]), TLogType_err);
      end;
    end;
  end;
end;

end.
