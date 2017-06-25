{*******************************************************}
{                                                       }
{       Pangya Server                                   }
{                                                       }
{       Copyright (C) 2015 Shad'o Soft tm               }
{                                                       }
{*******************************************************}

unit GameHoles;

interface

uses
  Generics.Collections, GameHoleInfo, defs;

type
  TGameHoles = class
    private
      var m_gameHoles: TList<TGameHoleInfo>;
      var m_rainDropRatio: UInt8;
      var m_currentHole: UInt8;
      var m_holeCount: UInt8;

      function FGetCurrentHole: TGameHoleInfo;

      procedure RandomizeWeather;
      procedure RandomizeWind;
      procedure InitGameHoles(gameMode: TGAME_MODE; map: UInt8);

    public
      constructor Create;
      destructor Destroy; override;
      procedure Init(gameMode: TGAME_MODE; map: UInt8; holeCount: UInt8);

      property CurrentHole: TGameHoleInfo read FGetCurrentHole;
      property Holes: TList<TGameHoleInfo> read m_gameHoles;
      function GoToNext: Boolean;
  end;

implementation

uses ConsolePas;

constructor TGameHoles.Create;
var
  I: UInt8;
begin
  inherited;

  m_holeCount := 0;
  m_rainDropRatio := 10;

  m_gameHoles := TList<TGameHoleInfo>.Create;

  for I := 1 to 18 do
  begin
    m_gameHoles.Add(TGameHoleInfo.Create);
  end;
end;

destructor TGameHoles.Destroy;
var
  holeInfo: TGameHoleInfo;
begin
  for holeInfo in m_gameHoles do
  begin
    TObject(holeInfo).Free;
  end;
  m_gameHoles.Free;
  inherited;
end;

procedure TGameHoles.RandomizeWeather;
var
  holeInfo: TGameHoleInfo;
  flagged: Boolean;
begin
  flagged := false;
  for holeInfo in m_gameHoles do
  begin
    if flagged then
    begin
      holeInfo.weather := 2;
      break;
    end;
    if random(100) <= m_rainDropRatio then
    begin
      holeInfo.weather := 1;
      flagged := true;
    end else
    begin
      holeInfo.weather := 0;
    end;
  end;
end;

procedure TGameHoles.RandomizeWind;
var
  holeInfo: TGameHoleInfo;
  flagged: Boolean;
begin
  flagged := false;
  for holeInfo in m_gameHoles do
  begin
    holeInfo.Wind.windpower := UInt8(random(9));
  end;
end;

procedure TGameHoles.InitGameHoles(gameMode: TGAME_MODE; map: UInt8);
var
  hole: UInt8;
  x, randomPosition, temp: Int32;
  holeInfo: TGameHoleInfo;
begin
  randomize;
  m_currentHole := 0;
  x := 0;
  case gameMode of
    TGAME_MODE.GAME_MODE_REPEAT : begin
      for x := 0 to 17 do begin
        m_gameHoles[x].Hole := x + 1;
      end;
    end;
    TGAME_MODE.GAME_MODE_FRONT : begin
      for x := 0 to 17 do begin
        m_gameHoles[x].Hole := x + 1;
      end;
    end;
    TGAME_MODE.GAME_MODE_BACK : begin
      for x := 0 to 17 do begin
        m_gameHoles[x].Hole := 18 - x;
      end;
    end;
    TGAME_MODE.GAME_MODE_RANDOM : begin
      for x := 0 to 17 do begin
        m_gameHoles[x].Hole := Int32(random(19));
      end;
    end;
    TGAME_MODE.GAME_MODE_SHUFFLE : begin
      for x := 0 to 17 do begin
        m_gameHoles[x].Hole := x + 1;
      end;
      for x := 0 to 17 do begin
        temp := m_gameHoles[x].Hole;
        randomposition := Int32(random(18));
        m_gameHoles[x].Hole := m_gameHoles[randomposition].Hole;
        m_gameHoles[randomposition].Hole := temp;
      end;
    end
    else begin
      console.log('Unregistred game mode', C_RED);
      for x := 0 to 17 do begin
        m_gameHoles[x].Hole := x + 1;
      end;
    end;
  end;

  for x := 0 to 17 do begin
    m_gameHoles[x].Map := map;
  end;
end;

procedure TGameHoles.Init(gameMode: TGAME_MODE; map: UInt8; holeCount: UInt8);
begin
  m_holeCount := holeCount;
  RandomizeWeather;
  RandomizeWind;
  InitGameHoles(gameMode, map);
end;

function TGameHoles.FGetCurrentHole: TGameHoleInfo;
begin
  Result := m_gameHoles[m_currentHole];
end;

function TGameHoles.GoToNext;
begin
  inc(m_currentHole);
  Result := m_currentHole < m_holeCount;
  if not Result then
  begin
    m_currentHole := 0;
  end;
end;

end.
