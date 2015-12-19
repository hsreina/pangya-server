unit PlayerCharacter;

interface

uses PacketData, PlayerGenericData, GenericDataRecord;

type

  TPlayerCharacterBaseData = packed record
    var IffId: Uint32;
    var Id: Uint32;
    var HairColor: UInt8;
    var Un: array [0..$1F7] of AnsiChar;
  end;

  TPlayerCharacterData = TGenericDataRecord<TPlayerCharacterBaseData>;

  TPlayerCharacter = class (TPlayerGenericData<TPlayerCharacterData>)
    public
      procedure SetIffId(iffId: UInt32);
      procedure SetID(id: UInt32);
      procedure SetHairColor(color: UInt32);
  end;

implementation

procedure TPlayerCharacter.SetIffId(iffId: Cardinal);
begin
  self.m_data.Data.IffId := IffId;
end;

procedure TPlayerCharacter.SetID(id: Cardinal);
begin
  self.m_data.Data.Id := id;
end;

procedure TPlayerCharacter.SetHairColor(color: UInt32);
begin
  self.m_data.Data.hairColor := color;
end;

end.
