{*******************************************************}
{                                                       }
{       Pangya Server                                   }
{                                                       }
{       Copyright (C) 2015 Shad'o Soft tm               }
{                                                       }
{*******************************************************}

unit LoginPlayer;

interface

type
  TLoginPlayer = class
    private
      var m_debug: RawByteString;
    public
      constructor Create;
      destructor Destroy; override;
  end;

implementation

constructor TLoginPlayer.Create;
begin
  inherited;
  m_debug := 'test?';
end;

destructor TLoginPlayer.Destroy;
begin
  inherited;
end;

end.
