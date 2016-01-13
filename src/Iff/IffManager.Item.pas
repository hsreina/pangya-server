unit IffManager.Item;

interface

uses
  IffManager.IffEntry, IffManager.IffEntryList;

type

  TItemData = packed Record // $E0
    var base: TIffbase;
    var un: array [0..$D7] of AnsiChar;
  End;

  TItemDataClass = class (TIffEntry<TItemData>)
    public
      constructor Create(data: PAnsiChar);
  end;

  TItem = class (TIffEntryList<TItemData, TItemDataClass>)
    private
    public
      function GetDataSize: UInt32;
  end;

implementation

uses ConsolePas;

constructor TItemDataClass.Create(data: PAnsiChar);
begin
  inherited;
end;

function TItem.GetDataSize: UInt32;
begin
  Result := $E0;
end;

end.
