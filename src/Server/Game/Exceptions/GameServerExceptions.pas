{*******************************************************}
{                                                       }
{       Pangya Server                                   }
{                                                       }
{       Copyright (C) 2015 Shad'o Soft tm               }
{                                                       }
{*******************************************************}

unit GameServerExceptions;

interface

uses
  SysUtils;

type

  FullException = class(Exception)

  end;

  LobbyGamesFullException = class(FullException)

  end;

  GameFullException = class(FullException)

  end;

  LobbyFullException = class(FullException)

  end;

  NotFoundException = class(Exception)

  end;

  PlayerNotFoundException = class(NotFoundException)

  end;

  GameNotFoundException = class(NotFoundException)

  end;

  LobbyNotFoundException = class(NotFoundException)

  end;


implementation

end.
