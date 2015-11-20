unit GameServerExceptions;

interface

uses
  SysUtils;

type

  LobbyGamesFullException = class(Exception)

  end;

  GameFullException = class(Exception)

  end;

  PlayerNotFoundException = class(Exception)

  end;


implementation

end.
