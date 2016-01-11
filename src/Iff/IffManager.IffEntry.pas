{*******************************************************}
{                                                       }
{       Pangya Server                                   }
{                                                       }
{       Copyright (C) 2015 Shad'o Soft tm               }
{                                                       }
{*******************************************************}

unit IffManager.IffEntry;

interface

uses IffManager.IffEntrybase;

type

  PIffbase = ^TIffbase;
  TIffbase = packed record
    var enabled: UInt32;
    var iffId: UInt32;
  end;

  TIffEntry<EntryDataType: record> = class (TIffEntrybase)
    protected
      var m_data: EntryDataType;
      function GetBase: PIffbase;
    public
      constructor Create(data: PAnsiChar);
      destructor Destroy; override;
      function GetIffId: UInt32; override;
      function IsEnabled: Boolean; override;
  end;

implementation

constructor TIffEntry<EntryDataType>.Create(data: PAnsiChar);
begin
  inherited Create;
  move(data^, m_data, SizeOf(EntryDataType));
end;

destructor TIffEntry<EntryDataType>.Destroy;
begin
  inherited;
end;

function TIffEntry<EntryDataType>.GetIffId: UInt32;
begin
  Result := self.GetBase.iffId;
end;

function TIffEntry<EntryDataType>.GetBase: PIffbase;
begin
  Result := @m_data;
end;

function TIffEntry<EntryDataType>.IsEnabled: Boolean;
var
  base: PIffBase;
begin
  Result := self.GetBase.enabled = 1;
end;

end.
