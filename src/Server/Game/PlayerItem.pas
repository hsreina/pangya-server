{*******************************************************}
{                                                       }
{       Pangya Server                                   }
{                                                       }
{       Copyright (C) 2015 Shad'o Soft tm               }
{                                                       }
{*******************************************************}

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
      function GetIffId: UInt32; override;
      procedure SetIffId(iffId: UInt32); override;
      function GetId: UInt32; override;
      procedure SetId(id: UInt32); override;
  end;

implementation

procedure TPlayerItem.SetIffId(iffId: Cardinal);
begin
  self.m_data.IffId := IffId;
end;

function TPlayerItem.GetIffId: UInt32;
begin
  Exit(self.m_data.IffId);
end;

procedure TPlayerItem.SetID(id: Cardinal);
begin
  self.m_data.Id := id;
end;

function TPlayeritem.GetId: UInt32;
begin
  Exit(self.m_data.Id);
end;

end.
