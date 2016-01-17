{*******************************************************}
{                                                       }
{       Pangya Server                                   }
{                                                       }
{       Copyright (C) 2015 Shad'o Soft tm               }
{                                                       }
{*******************************************************}

unit PlayerCharacters;

interface

uses PlayerCharacter, ClientPacket, PlayerGenericDataList;

type
  TPlayerCharacters = TPlayerGenericDataList<TPlayerCharacterData,
    TPlayerCharacter, TDoubleCounter>;

implementation

end.
