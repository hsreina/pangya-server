unit PlayerCharacters;

interface

uses PlayerCharacter, Generics.Collections;

type
  TPlayerCharacters = class
    private
      m_characters: TList<TPlayerCharacter>;
    public
      constructor Create;
      destructor Destroy; override;
  end;

implementation

constructor TPlayerCharacters.Create;
var
  debug: TPlayerCharacter;
begin
  m_characters := TList<TPlayerCharacter>.Create;
  m_characters.Add(debug);
end;

destructor TPlayerCharacters.Destroy;
begin
  m_characters.Free;
end;

end.
