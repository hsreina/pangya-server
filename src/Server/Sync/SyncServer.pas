{*******************************************************}
{                                                       }
{       Pangya Server                                   }
{                                                       }
{       Copyright (C) 2015 Shad'o Soft tm               }
{                                                       }
{*******************************************************}

unit SyncServer;

interface

uses Client, SyncUser, Server, ClientPacket, CryptLib, SysUtils, defs,
  Database, IniFiles, PangyaPacketsDef, Generics.Collections, System.TypInfo;

type

  TSyncClient = TClient<TSyncUser>;

  TSyncServer = class (TServer<TSyncUser>)
    protected
    private

      var m_database: TDatabase;

      procedure Init; override;
      procedure OnClientConnect(const client: TSyncClient); override;
      procedure OnClientDisconnect(const client: TSyncClient); override;
      procedure OnReceiveClientData(const client: TSyncClient; const clientPacket: TClientPacket); override;
      procedure OnDestroyClient(const client: TSyncClient); override;
      procedure OnStart; override;

      procedure OnReceiveLoginClientData(const packetId: TSSPID; const client: TSyncClient; const clientPacket: TClientPacket);
      procedure OnReceiveGameClientData(const packetId: TSSPID; const client: TSyncClient; const clientPacket: TClientPacket);

      procedure SendToGame(const client: TSyncClient; const playerUID: TPlayerUID; const data: AnsiString);
      procedure PlayerAction(const client: TSyncClient; const playerUID: TPlayerUID; const data: AnsiString);

      procedure SyncLoginPlayer(const client: TSyncClient; const clientPacket: TClientPacket);
      procedure SyncGamePlayer(const client: TSyncClient; const clientPacket: TClientPacket);

      procedure HandlePlayerSelectCharacter(const client: TSyncClient; const clientPacket: TClientPacket; const playerUID: TPlayerUID);
      procedure HandlePlayerConfirmNickname(const client: TSyncClient; const clientPacket: TClientPacket; const playerUID: TPlayerUID);
      procedure HandleLoginPlayerLogin(const client: TSyncClient; const clientPacket: TClientPacket; const playerUID: TPlayerUID);
      procedure HandlePlayerSetNickname(const client: TSyncClient; const clientPacket: TClientPacket; const playerUID: TPlayerUID);

      procedure LoginGamePlayer(const client: TSyncClient; const playerUID: TPlayerUID);
      function CreatePlayer(login: AnsiString; password: AnsiString): integer;

      procedure InitPlayerData(playerId: integer);

      procedure HandleGamePlayerLogin(const client: TSyncClient; const clientPacket: TClientPacket; const playerUID: TPlayerUID);
      procedure RegisterServer(const client: TSyncClient; const clientPacket: TClientPacket);

      function GameServerList: AnsiString;

    public
      constructor Create(cryptLib: TCryptLib);
      destructor Destroy; override;
      procedure Debug;
  end;

implementation

uses Logging, ConsolePas, PlayerCharacters, PlayerCharacter,
  PacketData, utils, PlayerData, PlayerItems, PlayerItem, PlayerCaddies,
  PlayerMascots, PlayerEquipment;

constructor TSyncServer.Create(cryptLib: TCryptLib);
begin
  inherited;
  m_database := TDatabase.Create;
  Randomize;
end;

destructor TSyncServer.Destroy;
begin
  inherited;
  m_database.Free;
end;

procedure TSyncServer.Init;
var
  iniFile: TIniFile;
begin

  iniFile := TIniFile.Create('../config/server.ini');

  self.SetPort(
    iniFile.ReadInteger('sync', 'port', 7998)
  );

  m_database.Init;

  iniFile.Free;
end;

procedure TSyncServer.OnClientConnect(const client: TSyncClient);
var
  user: TSyncUser;
  res: TClientPacket;
begin
  self.Log('TSyncServer.OnClientConnect', TLogType_not);
  client.UID.login := 'Sync';
  user := TSyncUser.Create;
  client.Data := user;

  res := TClientPacket.Create;
  res.WriteStr(#$00#$01#$00#$00);
  res.WriteUInt8(client.GetKey);
  client.Send(res, false);
  res.Free;
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
  client.Send(#$01#$00 + Write(playerUID.id, 4) + WritePStr(playerUID.login) + data);
end;

procedure TSyncServer.PlayerAction(const client: TSyncClient; const playerUID: TPlayerUID; const data: AnsiString);
begin
  self.Log('TSyncServer.PlayerAction', TLogType_not);
  client.Send(#$02#$00 + Write(playerUID.id, 4) + WritePStr(playerUID.login) + data);
end;

procedure TSyncServer.HandlePlayerSelectCharacter(const client: TSyncClient; const clientPacket: TClientPacket; const playerUID: TPlayerUID);
var
  characterId: UInt32;
  hairColor: UInt16;
  playerCharacters: TPlayerCharacters;
  playerCharacter: TPlayerCharacter;
  characterData: TPacketData;
  playerData: TPlayerData;
begin
  self.Log('TSyncServer.HandlePlayerSelectCharacter', TLogType_not);

  clientPacket.ReadUInt32(characterId);
  clientPacket.ReadUint16(hairColor);

  self.Log(Format('chracterId : %x', [characterId]));
  self.Log(Format('hairColor : %x', [hairColor]));

  playerCharacters := TPlayerCharacters.Create;
  playerCharacter := playerCharacters.Add(characterId);

  characterData := GetDataFromFile(Format('../data/c_%x.dat', [characterId]));
  Console.Log(Format('Load "../data/c_%x.dat"', [characterId]));
  if not playerCharacter.Load(characterData) then
  begin
    Console.Log(Format('character data not found %x', [characterId]), C_RED);
    Exit;
  end;

  playerCharacter.SetID(Random(9999999999));
  playerCharacter.SetHairColor(hairColor);

  m_database.SavePlayerCharacters(playerUID.id, playerCharacters);

  playerData.Load(m_database.GetPlayerMainSave(playerUID.id));

  playerData.equipedCharacter := playerCharacter.GetData;
  playerData.witems.characterId := playerData.equipedCharacter.Data.Id;

  m_database.SavePlayerMainSave(playerUID.id, playerData);

  playerCharacters.Free;

  // validate character
  self.SendToGame(client, playerUID, #$11#$00#$00);

  self.LoginGamePlayer(client, playerUID);
end;

procedure TSyncServer.HandlePlayerConfirmNickname(const client: TSyncClient; const clientPacket: TClientPacket; const playerUID: TPlayerUID);
var
  nickname: AnsiString;
begin
  self.Log('TSyncServer.HandlePlayerConfirmNickname', TLogType_not);
  clientPacket.ReadPStr(nickname);

  if m_database.NicknameAvailable(nickname) then
  begin
    self.SendToGame(client, playerUID, #$0E#$00#$00#$00#$00#$00 + WritePStr(nickname));
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

  clientPacket.ReadPStr(login);
  clientPacket.ReadPStr(md5Password);

  self.Log(Format('login : %s', [login]));
  self.Log(Format('password : %s', [md5Password]));

  userId := m_database.DoLogin(login, md5Password);

  // player already in use, would you like do DC
  // server : 01 00 E2 F3 D1 4D 00 00  00
  // client : 04 00

  if 0 = userId then
  begin
    userId := CreatePlayer(login, md5Password);
    if 0 = userId then
    begin
      self.SendToGame(client, playerUID, #$01#$00#$E2#$72#$D2#$4D#$00#$00#$00);
      Exit;
    end;
    self.InitPlayerData(userId);
  end;

  playerUID.SetId(userId);
  self.LoginGamePlayer(client, playerUID);
end;


// TODO: make it better
{
  this code create the initial player save data.
  should be enough to start basic gameplay
}
procedure TSyncServer.InitPlayerData(playerId: integer);
var
  items: TPlayerItems;
  caddies: TPlayerCaddies;
  mascots: TPlayerMascots;
  item: TPlayerItem;
  playerData: TPlayerData;
begin
  items := TPlayerItems.Create;
  caddies := TPlayerCaddies.Create;
  mascots := TPlayerMascots.create;

  playerData.Load(m_database.GetPlayerMainSave(playerId));

  // basic club
  item := items.Add($10000012);
  playerData.witems.clubSetId := item.GetId;

  with items.Add($1A000264) do
  begin
    SetQty(50);
  end;

  // banana for debug purpose
  with items.Add($18000001) do
  begin
    SetQty(50);
  end;

  with playerData.equipedClub do
  begin
    IffId := item.GetIffId;
    Id := item.GetId;
  end;

  // basic aztec
  with items.Add($14000000) do
  begin
    playerData.witems.aztecIffID := GetIffId;
  end;

  // Add a debug mascot
  with mascots.Add($40000000) do
  begin
    playerData.equipedMascot := GetData;
    playerData.witems.mascotId := GetId;
  end;

  m_database.SavePlayerItems(playerId, items);
  m_database.SavePlayerCaddies(playerId, caddies);
  m_database.SavePlayerMascots(playerId, mascots);

  m_database.SavePlayerMainSave(playerid, playerData);

  items.Free;
  caddies.Free;
  mascots.Free
end;

function TSyncServer.CreatePlayer(login: AnsiString; password: AnsiString): integer;
var
  playerData: TPlayerData;
begin
  playerData.Clear;
  playerData.SetLogin(login);

  // Setup initial player data here
  with playerData.playerInfo2 do
  begin
    rank := TRANK.INFINITY_LEGEND_A;
    pangs := 99999999;
    experience := 99999999;
  end;

  Result := m_database.CreatePlayer(login, password, playerData);
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
  playerData: TPlayerData;
  cookies: UInt64;
begin
  Console.Log('TSyncServer.HandleGamePlayerLogin', C_BLUE);

  clientPacket.ReadPStr(login);

  playerId := m_database.GetPlayerId(login);
  playerUID.SetId(playerId);

  if 0 = playerId then
  begin
    Console.Log('Should do something here', C_RED);
    Exit;
  end;

  clientPacket.ReadUInt32(UID);
  clientPacket.Skip(6);
  clientPacket.ReadPStr(checkA);
  clientPacket.ReadPStr(clientVersion);

  ClientPacket.ReadUInt32(checkc);
  checkc := self.Deserialize(checkc);
  self.Log(Format('check c dec : %x, %d', [checkc, checkc]));

  ClientPacket.seek(4, 1);

  ClientPacket.ReadPStr(checkb);
  self.Log(Format('Check b  : %s', [checkb]));

  // we'll store that in the db or in memory one day
  if not (checkA = '178d22e') or not (checkb = '1f766c8') then
  begin
    client.Disconnect;
    Exit;
  end;

  playerData.Load(m_database.GetPlayerMainSave(playerId));

  playerData.playerInfo1.PlayerID := playerId;

  // Send Main player data
  self.PlayerAction(
    client,
    playerUID,
    WriteAction(SSAPID_PLAYER_MAIN_SAVE) + playerData.ToPacketData
  );

  // player items
  self.PlayerAction(
    client,
    playerUID,
    WriteAction(SSAPID_PLAYER_ITEMS) + m_database.GetPlayerItems(playerUID.id)
  );

  // player characters
  self.PlayerAction(
    client,
    playerUID,
    WriteAction(SSAPID_PLAYER_CHARACTERS) + m_database.GetPlayerCharacters(playerUID.id)
  );

  // player caddies
  self.PlayerAction(
    client,
    playerUID,
    WriteAction(SSAPID_PLAYER_CADDIES) + m_database.GetPlayerCaddies(playerUID.id)
  );

  // player mascots
  self.PlayerAction(
    client,
    playerUID,
    WriteAction(SSAPID_PLAYER_MASCOTS) + m_database.GetPlayerMascots(playerUID.id)
  );

  cookies := 99999999;

  // player cookies
  self.PlayerAction(
    client,
    playerUID,
    WriteAction(SSAPID_PLAYER_COOKIES) + Write(cookies, 8)
  );

  // Send Lobbies list
  self.PlayerAction(client, playerUID, #$02#$00);
end;

procedure TSyncServer.HandlePlayerSetNickname(const client: TSyncClient; const clientPacket: TClientPacket; const playerUID: TPlayerUID);
var
  nickname: AnsiString;
  playerData: TPlayerData;
begin
  Console.Log('TLoginServer.HandleConfirmNickname', C_BLUE);
  clientPacket.ReadPStr(nickname);
  self.Log(Format('nickname : %s', [nickname]));

  playerData.Load(m_database.GetPlayerMainSave(playerUID.id));
  playerData.SetNickname(nickname);
  m_database.SavePlayerMainSave(playerUID.id, playerData);

  m_database.SetNickname(playerUID.id, nickname);

  self.SendToGame(client, playerUID, #$06#$00 + WritePStr(nickname));

  LoginGamePlayer(client, playerUID);
end;

procedure TSyncServer.LoginGamePlayer(const client: TSyncClient; const playerUID: TPlayerUID);
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

  self.SendToGame(client, playerUID, #$10#$00 + WritePStr('178d22e'));

  // Should send server list
  self.SendToGame(client, playerUID, Self.GameServerList);

  // this is an action who can be performed from the sync server to any other server
  //self.PlayerAction(client, playerUID, #$01#$00);
end;

procedure TSyncServer.SyncGamePlayer(const client: TSyncClient; const clientPacket: TClientPacket);
var
  playerUID: TPlayerUID;
  packetId: TCGPID;
begin
  self.Log('TSyncServer.SyncGamePlayer', TLogType_not);

  clientPacket.ReadUInt32(playerUID.id);
  clientPacket.ReadPStr(playerUID.login);

  self.Log(Format('Player UID : %s', [playerUID.login]));

  if clientPacket.Read(packetId, 2) then
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

  clientPacket.ReadUInt32(playerUID.id);
  clientPacket.ReadPStr(playerUID.login);

  self.Log(Format('Player UID : %s', [playerUID.login]));

  if clientPacket.Read(packetId, 2) then
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

procedure TSyncServer.OnDestroyClient(const client: TSyncClient);
begin
  client.Data.Free;
end;

procedure TSyncServer.OnReceiveLoginClientData(const packetId: TSSPID; const client: TSyncClient; const clientPacket: TClientPacket);
begin
  case packetID of
    SSPID_PLAYER_SYNC:
    begin
      self.SyncLoginPlayer(client, clientPacket);
    end;
    else
    begin
      self.Log(Format('Unknow packet Id %x', [Word(packetID)]), TLogType_err);
    end;
  end;
end;

procedure TSyncServer.OnReceiveGameClientData(const packetId: TSSPID; const client: TSyncClient; const clientPacket: TClientPacket);
begin
  case packetID of
    SSPID_PLAYER_SYNC:
    begin
      self.SyncGamePlayer(client, clientPacket);
    end;
    else
    begin
      self.Log(Format('Unknow packet Id %x', [Word(packetID)]), TLogType_err);
    end;
  end;
end;

procedure TSyncServer.RegisterServer(const client: TSyncClient; const clientPacket: TClientPacket);
var
  clientType: TSYNC_CLIENT_TYPE;
begin
  Console.Log('TSyncServer.RegisterServer', C_BLUE);
  if
    not clientPacket.Read(clientType, 1) or
    not clientPacket.ReadPStr(client.Data.Name) or
    not clientPacket.ReadInt32(client.Data.Port) or
    not clientPacket.ReadPStr(client.Data.Host)
  then
  begin
    Exit;
  end;

  client.Data.ClientType := clientType;
  client.Data.Registred := true;

  Console.Log(Format('Server type : %s', [GetEnumName(TypeInfo(TSYNC_CLIENT_TYPE), Integer(clientType))]));
  Console.Log(Format('Server name : %s', [client.Data.Name]));
  Console.Log(Format('Server host : %s', [client.Data.host]));
  Console.Log(Format('Server port : %d', [client.Data.port]));

end;

procedure TSyncServer.OnReceiveClientData(const client: TSyncClient; const clientPacket: TClientPacket);
var
  packetId: TSSPID;
  server: UInt8;
begin
  self.Log('TSyncServer.OnReceiveClientData', TLogType_not);

  if not clientPacket.Read(packetID, 2) then
  begin
    Exit;
  end;

  if client.Data.Registred then
  begin
    case client.Data.ClientType of
      SYNC_CLIENT_TYPE_LOGIN:
      begin
        self.OnReceiveLoginClientData(packetId, client, clientPacket);
      end;
      SYNC_CLIENT_TYPE_GAME:
      begin
        self.OnReceiveGameClientData(packetId, client, clientPacket);
      end;
    end;
  end else
  begin
    case packetID of
      TSSPID.SSPID_REGISTER_SERVER:
      begin
        self.RegisterServer(client, clientPacket);
      end;
    end;
  end;


  {
  if (clientPacket.ReadUInt8(server) and clientPacket.Read(packetID, 2)) then
  begin
    if server = 1 then
    begin
      self.OnReceiveLoginClientData(packetId, client, clientPacket);
    end else
    if server = 2 then
    begin
      self.OnReceiveGameClientData(packetId, client, clientPacket);
    end;
  end;
  }
end;

procedure TSyncServer.Debug;
begin
end;

function TSyncServer.GameServerList: AnsiString;
var
  port: UInt32;
  packet: TClientPacket;
  serversList: TList<TSyncClient>;
  client: TSyncClient;
begin
  port := 7997;

  serversList := TList<TSyncClient>.Create;

  for client in self.Clients do
  begin
    with client.Data do
    begin
      if Registred and (ClientType = TSYNC_CLIENT_TYPE.SYNC_CLIENT_TYPE_GAME) then
      begin
        serversList.Add(client);
      end;
    end;
  end;

  // Could retrieve this from the Sync server
  packet := TClientPacket.Create;

  packet.WriteStr(
    #$02#$00 +
    #$01 // Number of servers
  );

  for client in serversList do
  begin

    packet.WriteStr(client.Data.Name, 16, #$00);

    packet.WriteStr(
      #$00#$00#$00#$00 +
      #$00#$00#$00#$00 +
      #$00#$00#$00#$00 +
      #$00#$00#$00#$00 +
      #$00#$00#$00#$00 +
      #$00#$00#$00#$00 +
      #$7F#$00#$00#$01 + // unique ID?
      #$40#$06#$00#$00 +
      #$45#$00#$00#$00
    );

    packet.WriteStr(client.Data.Host, 15, #$00);

    packet.WriteStr(#$00#$00#$00);

    packet.Write(client.Data.Port, 2);

    packet.WriteStr(
      #$00#$00 +
      #$00#$00#$08#$00 + //  kind of server status
      {
        $8 : 19 yo to enter the server
        $10 : invisible
        $800 : grand prix skin
      }
      #$08#$00#$00#$00 + // Wings
      #$00#$00#$00#$00 +
      #$64#$00#$00#$00 +
      #$03 + // server icon
      #$00 // 1 seem to remove the name
    );

  end;



  Result := packet.ToStr;

  Console.WriteDump(Result);

  serversList.Free;
  packet.Free;
end;

end.
