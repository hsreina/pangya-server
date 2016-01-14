{*******************************************************}
{                                                       }
{       Pangya Server                                   }
{                                                       }
{       Copyright (C) 2015 Shad'o Soft tm               }
{                                                       }
{*******************************************************}

unit IffManager.DataCheck;

interface

type
  TDataCheck = class abstract
    public
      function GetDataSize: UInt32; virtual; abstract;
  end;

implementation

end.
