unit PlayerItem;

interface

uses PacketData, PlayerGenericData;

type

  TPlayerItemData = packed record
    var Id: Uint32;
    var IffId: Uint32;
    var Un: array [0..$BB] of AnsiChar;
  end;

  TPlayerItem = class (TPlayerGenericData<TPlayerItemData>)
    public
      procedure SetIffId(iffId: UInt32);
      procedure SetID(id: UInt32);
  end;

implementation

procedure TPlayerItem.SetIffId(iffId: Cardinal);
begin
  self.m_data.IffId := IffId;
end;

procedure TPlayerItem.SetID(id: Cardinal);
begin
  self.m_data.Id := id;
end;

end.
