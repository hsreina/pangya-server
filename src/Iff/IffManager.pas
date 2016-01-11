{*******************************************************}
{                                                       }
{       Pangya Server                                   }
{                                                       }
{       Copyright (C) 2015 Shad'o Soft tm               }
{                                                       }
{*******************************************************}

unit IffManager;

interface

uses IffManager.Part, IffManager.IffEntry, IffManager.IffEntrybase;

type

  TIffManager = class
    private
      var m_loader: Boolean;
      var m_part: TPart;
    public
      constructor Create;
      destructor Destroy; override;
      function Load: Boolean;
      function GetByIffId(IffId: UInt32): TIffEntryBase;
  end;

implementation

constructor TIffManager.Create;
begin
  inherited;
  m_loader := false;
  m_part := TPart.Create;
end;

destructor TIffManager.Destroy;
begin
  inherited;
  m_part.Free;
end;

function TIffManager.Load: Boolean;
begin
  Result :=
    m_part.Load('../data/pangya_gb.iff/Part.iff');
end;

function TIffManager.GetByIffId(IffId: Cardinal): TIffEntryBase;
begin
  Result := m_part.GetByIffId(IffId);
end;

end.
