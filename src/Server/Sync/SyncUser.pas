{*******************************************************}
{                                                       }
{       Pangya Server                                   }
{                                                       }
{       Copyright (C) 2015 Shad'o Soft tm               }
{                                                       }
{*******************************************************}

unit SyncUser;

interface

type
  TSyncUser = class
    public
      constructor Create;
      destructor Destroy; override;
  end;

implementation

constructor TSyncUser.Create;
begin
  inherited;
end;

destructor TSyncUser.Destroy;
begin
  inherited;
end;

end.
