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
  IffManager.SetItem, IffManager.Character, IffManager.HairStyle, System.Zip,
  SysUtils;

type

  TIffManager = class
    private
      var m_part: TPart;
      var m_item: TItem;
      var m_ball: TBall;
      var m_caddie: TCaddie;
      var m_clubSet: TClubSet;
      var m_skin: TSkin;
      var m_mascot: TMascot;
      var m_auxPart: TAuxPart;
      var m_SetItem: TSetItem;
      var m_character: TCharacter;
      var m_hairStyle: THairStyle;
    public
      constructor Create;
      destructor Destroy; override;
      property Part: TPart read m_part;
      property Item: TItem read m_item;
      property Ball: TBall read m_ball;
      property Caddie: TCaddie read m_caddie;
      property ClubSet: TClubSet read m_clubSet;
      property Skin: TSkin read m_skin;
      property Mascot: TMascot read m_mascot;
      property AuxPart: TAuxPart read m_auxPart;
      property SetItem: TSetItem read m_setItem;
      property Character: TCharacter read m_character;
      property HairStyle: THairStyle read m_hairStyle;

      function Load: Boolean;
      function PatchAndSave: Boolean;

      function TryGetByIffId(iffId: Cardinal; var res: TIffEntryBase): Boolean;
      function GetByIffId(iffId: UInt32): TIffEntryBase;
  end;

implementation

uses GameServerExceptions;

constructor TIffManager.Create;
begin
  inherited;
  m_part := TPart.Create;
  m_item := TItem.Create;
  m_ball := TBall.Create;
  m_caddie := TCaddie.Create;
  m_clubSet := TClubSet.Create;
  m_skin := TSkin.Create;
  m_mascot := TMascot.Create;
  m_auxPart := TAuxPart.Create;
  m_SetItem := TSetItem.Create;
  m_character := TCharacter.Create;
  m_hairStyle := THairStyle.Create;
end;

destructor TIffManager.Destroy;
begin
  m_part.Free;
  m_item.Free;
  m_ball.Free;
  m_caddie.Free;
  m_clubSet.Free;
  m_skin.Free;
  m_mascot.Free;
  m_auxPart.Free;
  m_SetItem.Free;
  m_character.Free;
  m_hairStyle.Free;
  inherited;
end;

function TIffManager.Load: Boolean;
var
  path: String;
  zip :TZipFile;
begin
  Result := False;
  path := '../data/pangya_gb.iff';

  // Should create a nice loader for that
  if directoryexists(path) then
  begin
    Result :=
      m_part.Load(path + '/Part.iff') and
      m_item.Load(path + '/Item.iff') and
      m_ball.Load(path + '/Ball.iff') and
      m_caddie.Load(path + '/Caddie.iff') and
      m_clubSet.Load(path + '/ClubSet.iff') and
      m_skin.Load(path + '/Skin.iff') and
      m_mascot.Load(path + '/Mascot.iff') and
      m_auxPart.Load(path + '/AuxPart.iff') and
      m_SetItem.Load(path + '/SetItem.iff') and
      m_character.Load(path + '/Character.iff') and
      m_hairStyle.Load(path + '/HairStyle.iff');
  end else if fileExists(path) then
  begin
    zip := TZipFile.Create;
    zip.Open(path, zmRead);

    Result :=
      m_part.Load(zip, 'Part.iff') and
      m_item.Load(zip, 'Item.iff') and
      m_ball.Load(zip, 'Ball.iff') and
      m_caddie.Load(zip, 'Caddie.iff') and
      m_clubSet.Load(zip, 'ClubSet.iff') and
      m_skin.Load(zip, 'Skin.iff') and
      m_mascot.Load(zip, 'Mascot.iff') and
      m_auxPart.Load(zip, 'AuxPart.iff') and
      m_SetItem.Load(zip, 'SetItem.iff') and
      m_character.Load(zip, 'Character.iff') and
      m_hairStyle.Load(zip, 'HairStyle.iff');

    zip.Free;
  end;

end;

function TIffManager.PatchAndSave: Boolean;
var
  path: string;
begin

  path := '../data/pangya_gb_patch.iff';

  Result :=
    m_part.PatchAndSave(path + '/Part.iff') and
    m_item.PatchAndSave(path + '/Item.iff') and
    m_ball.PatchAndSave(path + '/Ball.iff') and
    m_caddie.PatchAndSave(path + '/Caddie.iff') and
    m_clubSet.PatchAndSave(path + '/ClubSet.iff') and
    //m_skin.PatchAndSave(path + '/Skin.iff') and
    m_mascot.PatchAndSave(path + '/Mascot.iff') and
    //m_auxPart.PatchAndSave(path + '/AuxPart.iff') and
    m_SetItem.PatchAndSave(path + '/SetItem.iff') and
    //m_character.PatchAndSave(path + '/Character.iff') and
    m_hairStyle.PatchAndSave(path + '/HairStyle.iff');

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
    m_skin.TryGetByIffId(iffId, Result) or
    m_mascot.TryGetByIffId(iffId, Result) or
    m_auxPart.TryGetByIffId(iffId, Result) or
    m_SetItem.TryGetByIffId(iffId, Result) or
    m_character.TryGetByIffId(iffId, Result) or
    m_hairStyle.TryGetByIffId(iffId, Result);
  if not res then
  begin
    raise NotFoundException.CreateFmt('Item with Id %x', [iffId]);
  end;
end;

end.
