{*******************************************************}
{                                                       }
{       Pangya Server                                   }
{                                                       }
{       Copyright (C) 2015 Shad'o Soft tm               }
{                                                       }
{*******************************************************}

unit IffManager;

interface

uses IffManager.Part, IffManager.IffEntry, IffManager.IffEntrybase,
  IffManager.Item, IffManager.Ball, IffManager.Caddie, IffManager.ClubSet,
  IffManager.Club;

type

  TIffManager = class
    private
      var m_loader: Boolean;
      var m_part: TPart;
      var m_item: TItem;
      var m_ball: TBall;
      var m_caddie: TCaddie;
      var m_clubSet: TClubSet;
      var m_club: TClub;
    public
      constructor Create;
      destructor Destroy; override;
      property Part: TPart read m_part;
      property Item: TItem read m_item;
      property Ball: TBall read m_ball;
      property Caddie: TCaddie read m_caddie;
      property ClubSet: TClubSet read m_clubSet;
      property Club: TClub read m_club;
      function Load: Boolean;
      function GetByIffId(iffId: UInt32): TIffEntryBase;
  end;

implementation

uses GameServerExceptions;

constructor TIffManager.Create;
begin
  inherited;
  m_loader := false;
  m_part := TPart.Create;
  m_item := TItem.Create;
  m_ball := TBall.Create;
  m_caddie := TCaddie.Create;
  m_clubSet := TClubSet.Create;
  m_club := TClub.Create;
end;

destructor TIffManager.Destroy;
begin
  inherited;
  m_part.Free;
  m_item.Free;
  m_ball.Free;
  m_caddie.Free;
  m_clubSet.Free;
  m_club.Free;
end;

function TIffManager.Load: Boolean;
begin
  Result :=
    m_part.Load('../data/pangya_gb.iff/Part.iff') and
    m_item.Load('../data/pangya_gb.iff/Item.iff') and
    m_ball.Load('../data/pangya_gb.iff/Ball.iff') and
    m_caddie.Load('../data/pangya_gb.iff/Caddie.iff') and
    m_clubSet.Load('../data/pangya_gb.iff/ClubSet.iff') and
    m_club.Load('../data/pangya_gb.iff/Club.iff');
end;

function TIffManager.GetByIffId(iffId: Cardinal): TIffEntryBase;
var
  res: Boolean;
begin
  res :=
    m_part.TryGetByIffId(iffId, Result) or
    m_item.TryGetByIffId(iffId, Result) or
    m_ball.TryGetByIffId(iffId, Result) or
    m_caddie.TryGetByIffId(iffId, Result) or
    m_clubSet.TryGetByIffId(iffId, Result) or
    m_club.TryGetByIffId(iffId, Result);
  if not res then
  begin
    raise NotFoundException.CreateFmt('Item with Id %x', [iffId]);
  end;
end;

end.
