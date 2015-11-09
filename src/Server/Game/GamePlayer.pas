unit GamePlayer;

interface

uses Lobby, PlayerData;

type
  TGamePlayer = class
    private
      var FLobby: TLobby;
      var FData: TPlayerData;
      function FGetPlayerData: PPlayerData;
    public
      property Lobby: Tlobby read FLobby write FLobby;
      property Data: PPlayerData read FGetPlayerData;

      var Cookies: UInt64;

      constructor Create;
      destructor Destroy; override;
  end;

implementation

constructor TGamePlayer.Create;
begin

end;

destructor TGamePlayer.Destroy;
begin

end;

function TGamePlayer.FGetPlayerData;
begin
  Exit(@FData);
end;

end.
