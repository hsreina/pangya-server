unit ServerOptions;

interface

uses PacketData;

type

  TServerOptionsData = packed record
    var un0001: array [0..$11] of UTF8Char;
    var un00FF: array [0..$05] of UTF8Char;
    var moreUnknow: Array [0..$03] of UTF8Char;
    var MaintenanceFlags: UInt64;
    var unknow6B: Byte;
    var moreUnknow2: UInt32;

    // this flag must be 8 to enable grand prix on the server for the player
    var aFlag: UInt8;

    // now sound like something related to guilds
    var un0004: array [0..$116] of UTF8Char;
  end;

  TServerOptions = class
    var m_data: TServerOptionsData;
    public
      constructor Create;
      destructor Destroy; override;
      function ToPacketData: TPacketData;
  end;

implementation

const

  MAINTENANCE_FLAG_PAPELSHOP = 1 shl 4;

  // VS
  MAINTENANCE_FLAG_VS_STROKE = 1 shl 6;
  MAINTENANCE_FLAG_VS_MATCH = 1 shl 7;

  // Tourney
  MAINTENANCE_FLAG_TOURNEY_TOURNEY = 1 shl 8;
  MAINTENANCE_FLAG_TOURNEY_SHORTGAME = 1 shl 9;
  MAINTENANCE_FLAG_TOURNEY_GUILD = 1 shl 10;

  // Battle
  MAINTENANCE_FLAG_BATTLE_PANGBATTLE = 1 shl 11;
  MAINTENANCE_FLAG_BATTLE_APPROACH = 1 shl 12;

  // Lounge
  MAINTENANCE_FLAG_LOUNGE = 1 shl 13;
  MAINTENANCE_FLAG_SCRATCHY = 1 shl 14;
  MAINTENANCE_FLAG_MAILBOX = 1 shl 18;

  MAINTENANCE_FLAG_MEMORIAL_SHOP = 1 shl 28;
  MAINTENANCE_FLAG_CHAR_MASTERY = 1 shl 30;

constructor TServerOptions.Create;
begin
  inherited;
  m_data.aFlag := 8; // 8 enable grand prix
  {
  m_data.MaintenanceFlags :=
    MAINTENANCE_FLAG_PAPELSHOP or
    MAINTENANCE_FLAG_VS_STROKE or
    MAINTENANCE_FLAG_VS_MATCH or
    MAINTENANCE_FLAG_TOURNEY_TOURNEY or
    MAINTENANCE_FLAG_TOURNEY_SHORTGAME or
    MAINTENANCE_FLAG_TOURNEY_GUILD or
    MAINTENANCE_FLAG_BATTLE_PANGBATTLE or
    MAINTENANCE_FLAG_BATTLE_APPROACH or
    MAINTENANCE_FLAG_LOUNGE or
    MAINTENANCE_FLAG_SCRATCHY or
    MAINTENANCE_FLAG_MAILBOX or
    MAINTENANCE_FLAG_MEMORIAL_SHOP or
    MAINTENANCE_FLAG_CHAR_MASTERY// or
    //UInt64(1 shl 32)
    ;
    }
end;

destructor TServerOptions.Destroy;
begin
  inherited;
end;

function TServerOptions.ToPacketData: TPacketData;
const
  sizeofTServerOptionsData = SizeOf(TServerOptionsData);
begin
  SetLength(Result, sizeofTServerOptionsData);
  move(m_data.un0001[0], result[1], sizeofTServerOptionsData);
end;

{
                                         E0 07 0C 00 06 00    ..........à.....
00002FB0  03 00 0D 00 0E 00 1B 00  87 02 02 00 FF FF FF FF    ........‡...ÿÿÿÿ
00002FC0  FF FF 00 00 00 00 00 00  00 00 00 00 00 00 3C 00    ÿÿ............<.
00002FD0  00 00 00 08 00 00 00 00  00 00 00 00 00 00 00 00    ................
00002FE0  00 00 00 00 00 00 00 00  00 00 00 00 00 00 00 00    ................
00002FF0  00 00 00 00 00 00 00 00  00 00 00 00 00 00 00 00    ................
00003000  00 00 00 00 00 00 00 00  00 00 00 00 00 00 00 00    ................
00003010  00 00 00 00 00 00 00 00  00 00 00 00 00 00 00 00    ................
00003020  00 00 00 00 00 00 00 00  00 00 00 00 00 00 00 00    ................
00003030  00 00 00 00 00 00 00 00  00 00 00 00 00 00 00 00    ................
00003040  00 00 00 00 00 00 00 00  00 00 00 00 00 00 00 00    ................
00003050  00 00 00 00 00 00 00 00  00 00 00 00 00 00 00 00    ................
00003060  00 00 00 00 00 00 00 00  00 00 00 00 00 00 00 00    ................
00003070  00 00 00 00 00 00 00 00  00 00 00 00 00 00 00 00    ................
00003080  00 00 00 00 00 00 00 00  00 00 00 00 00 00 00 00    ................
00003090  00 00 00 00 00 00 00 00  00 00 00 00 00 00 00 00    ................
000030A0  00 00 00 00 00 00 00 00  00 00 00 00 00 00 00 00    ................
000030B0  00 00 00 00 00 00 00 00  00 00 00 00 00 00 00 00    ................
000030C0  00 00 00 00 00 00 00 00  00 00 00 00 00 00 00 00    ................
000030D0  00 FF FF FF FF 00 00 00  00 00 00 00 00 00 00 00    .ÿÿÿÿ...........
000030E0  00 00 00 00 00 00 00 00  00 00 00                   ...........
}

end.
