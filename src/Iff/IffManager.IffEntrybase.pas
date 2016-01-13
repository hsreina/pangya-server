{*******************************************************}
{                                                       }
{       Pangya Server                                   }
{                                                       }
{       Copyright (C) 2015 Shad'o Soft tm               }
{                                                       }
{*******************************************************}

unit IffManager.IffEntryBase;

interface

type
  TIffEntrybase = class
    public
      function GetIffId: UInt32; virtual; abstract;
      function IsEnabled: Boolean; virtual; abstract;
  end;

implementation

end.
