unit PlayerCharacter;

interface

uses PacketData, PlayerGenericData;

type

  TPlayerCharacterData = packed record
    var IffId: Uint32;
    var Id: Uint32;
    var Un: array [0..$1F8] of AnsiChar;
  end;

  TPlayerCharacter = class (TPlayerGenericData<TPlayerCharacterData>)
    public
      procedure SetIffId(iffId: UInt32);
      procedure SetID(id: UInt32);
  end;

implementation

procedure TPlayerCharacter.SetIffId(iffId: Cardinal);
begin
  self.m_data.IffId := IffId;
end;

procedure TPlayerCharacter.SetID(id: Cardinal);
begin
  self.m_data.Id := id;
end;

end.
