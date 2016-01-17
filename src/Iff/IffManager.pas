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
  IffManager.Club, IffManager.Skin, IffManager.Mascot, IffManager.AuxPart,
  IffManager.SetItem, IffManager.Character;

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
      var m_skin: TSkin;
      var m_mascot: TMascot;
      var m_auxPart: TAuxPart;
      var m_SetItem: TSetItem;
      var m_character: TCharacter;
    public
      constructor Create;
      destructor Destroy; override;
      property Part: TPart read m_part;
      property Item: TItem read m_item;
      property Ball: TBall read m_ball;
      property Caddie: TCaddie read m_caddie;
      property ClubSet: TClubSet read m_clubSet;
      property Club: TClub read m_club;
      property Skin: TSkin read m_skin;
      property Mascot: TMascot read m_mascot;
      property AuxPart: TAuxPart read m_auxPart;
      property SetItem: TSetItem read m_setItem;
      property Character: TCharacter read m_character;

      function Load: Boolean;
      function TryGetByIffId(iffId: Cardinal; var res: TIffEntryBase): Boolean;
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
  m_skin := TSkin.Create;
  m_mascot := TMascot.Create;
  m_auxPart := TAuxPart.Create;
  m_SetItem := TSetItem.Create;
  m_character := TCharacter.Create;
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
  m_skin.Free;
  m_mascot.Free;
  m_auxPart.Free;
  m_SetItem.Free;
  m_character.Free;
end;

function TIffManager.Load: Boolean;
begin
  Result :=
    m_part.Load('../data/pangya_gb.iff/Part.iff') and
    m_item.Load('../data/pangya_gb.iff/Item.iff') and
    m_ball.Load('../data/pangya_gb.iff/Ball.iff') and
    m_caddie.Load('../data/pangya_gb.iff/Caddie.iff') and
    m_clubSet.Load('../data/pangya_gb.iff/ClubSet.iff') and
    m_club.Load('../data/pangya_gb.iff/Club.iff') and
    m_skin.Load('../data/pangya_gb.iff/Skin.iff') and
    m_mascot.Load('../data/pangya_gb.iff/Mascot.iff') and
    m_auxPart.Load('../data/pangya_gb.iff/AuxPart.iff') and
    m_SetItem.Load('../data/pangya_gb.iff/SetItem.iff') and
    m_character.Load('../data/pangya_gb.iff/Character.iff');
end;

function TIffManager.TryGetByIffId(iffId: Cardinal; var res: TIffEntryBase): Boolean;
begin
  try
    res := GetByIffId(iffId);
    Result := true;
  Except
    Result := false;
  end;
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
    m_club.TryGetByIffId(iffId, Result) or
    m_skin.TryGetByIffId(iffId, Result) or
    m_mascot.TryGetByIffId(iffId, Result) or
    m_auxPart.TryGetByIffId(iffId, Result) or
    m_SetItem.TryGetByIffId(iffId, Result) or
    m_character.TryGetByIffId(iffId, Result);
  if not res then
  begin
    raise NotFoundException.CreateFmt('Item with Id %x', [iffId]);
  end;
end;

end.
