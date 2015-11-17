unit GamePlayer;

interface

uses PlayerData;

type
  TGamePlayer = class
    private
      var m_lobby: UInt16;
      var FData: TPlayerData;
      function FGetPlayerData: PPlayerData;
    public
      property Lobby: UInt16 read m_lobby write m_lobby;
      property Data: PPlayerData read FGetPlayerData;

      var Cookies: UInt64;

      constructor Create;
      destructor Destroy; override;
  end;

implementation

constructor TGamePlayer.Create;
begin
  inherited;
  m_lobby := $FF;
end;

destructor TGamePlayer.Destroy;
begin
  inherited;
end;

function TGamePlayer.FGetPlayerData;
begin
  Exit(@FData);
end;

end.
