{*******************************************************}
{                                                       }
{       Pangya Server                                   }
{                                                       }
{       Copyright (C) 2015 Shad'o Soft tm               }
{                                                       }
{*******************************************************}

unit PlayerMascot;

interface

uses PlayerGenericData, Math;

type
  TPlayerMascotData = packed record
    var Id: Uint32;
    var IffId: Uint32;
    var Un1: array [0..$4] of ansichar;
    var Text: array [0..$F] of ansichar;
    var Un2: array [0..$20] of ansichar;
    function ToStr: AnsiString;
  end;

  TPlayerMascot = class (TPlayerGenericData<TPlayerMascotData>)
    public
      function GetIffId: UInt32; override;
      procedure SetIffId(iffId: UInt32); override;
      function GetId: UInt32; override;
      procedure SetId(id: UInt32); override;

      procedure setText(newText: AnsiString);
      constructor Create;
      destructor Destroy; override;
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

procedure TPlayerMascot.setText(newText: AnsiString);
begin
  move(newText[1], m_data.text[0], min(length(newText), 16));
end;

constructor TPlayerMascot.Create;
begin
  inherited;
  self.setText('PANGYA!');
end;

destructor TPlayerMascot.Destroy;
begin
  inherited;
end;

function TPlayerMascotData.ToStr: AnsiString;
begin
  setLength(result, sizeof(TPlayerMascotData));
  move(self, result[1], sizeof(TPlayerMascotData));
end;

function TPlayerMascot.GetIffId;
begin
  Result := m_data.IffId;
end;

function TPlayerMascot.GetId;
begin
  Result := m_data.Id;
end;

end.
