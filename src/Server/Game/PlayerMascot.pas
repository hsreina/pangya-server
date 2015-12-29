{*******************************************************}
{                                                       }
{       Pangya Server                                   }
{                                                       }
{       Copyright (C) 2015 Shad'o Soft tm               }
{                                                       }
{*******************************************************}

unit PlayerMascot;

interface

uses PlayerGenericData;

type
  TPlayerMascotData = packed record
    var Id: Uint32;
    var IffId: Uint32;

  end;

  TPlayerMascot = class (TPlayerGenericData<TPlayerMascotData>)
    public
      procedure SetIffId(iffId: UInt32);
      procedure SetID(id: UInt32);
  end;

implementation

procedure TPlayerMascot.SetIffId(iffId: Cardinal);
begin
  self.m_data.IffId := IffId;
end;

procedure TPlayerMascot.SetID(id: Cardinal);
begin
  self.m_data.Id := id;
end;

end.
