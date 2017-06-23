{*******************************************************}
{                                                       }
{       Pangya Server                                   }
{                                                       }
{       Copyright (C) 2015 Shad'o Soft tm               }
{                                                       }
{*******************************************************}

unit PlayerCharacter;

interface

uses PacketData, PlayerGenericData, GenericDataRecord;

type

  TPlayerCharacterBaseData = packed record
    var IffId: Uint32;
    var Id: Uint32;
    var HairColor: UInt8;
    var Un: array [0..$1F7] of UTF8Char;
  end;

  TPlayerCharacterData = TGenericDataRecord<TPlayerCharacterBaseData>;

  TPlayerCharacter = class (TPlayerGenericData<TPlayerCharacterData>)
    public
      procedure SetIffId(iffId: UInt32); override;
      function GetIffId: UInt32; override;
      procedure SetId(id: UInt32); override;
      function GetId: UInt32; override;
      procedure SetHairColor(color: UInt32);
  end;

implementation

procedure TPlayerCharacter.SetIffId(iffId: Cardinal);
begin
  self.m_data.Data.IffId := IffId;
end;

procedure TPlayerCharacter.SetId(id: Cardinal);
begin
  self.m_data.Data.Id := id;
end;

procedure TPlayerCharacter.SetHairColor(color: UInt32);
begin
  self.m_data.Data.hairColor := color;
end;

function TPlayerCharacter.GetIffId: UInt32;
begin
  Result := self.m_data.Data.IffId;
end;

function TPlayerCharacter.GetId: UInt32;
begin
  Result := self.m_data.Data.Id;
end;

end.
