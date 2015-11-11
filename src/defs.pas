unit defs;

interface

uses PacketData;

type
  TPlayerUID = record
    var id: integer;
    var login: AnsiString;
    procedure SetId(id: integer);
  end;

implementation

procedure TPlayerUID.SetId(id: Integer);
begin
  self.id := id;
end;

end.
