{*******************************************************}
{                                                       }
{       Pangya Server                                   }
{                                                       }
{       Copyright (C) 2015 Shad'o Soft tm               }
{                                                       }
{*******************************************************}

unit PlayerPos;

interface

uses Vector3;

type
  TPlayerPos = packed record
    x, y, z: Single;

    class operator Add(const Left, Right: TPlayerPos): TPlayerPos;
    class operator Subtract(const Left, Right: TPlayerPos): TPlayerPos;

    function distance(playerPos: TPlayerPos): single;
    function length: single;
  end;

implementation

function TPlayerPos.distance(playerPos: TPlayerPos): single;
begin
  result := (self - playerPos).length;
end;

function TPlayerPos.length;
begin
  Result := Sqrt(x * x + y * y);
end;

class operator TPlayerPos.Add(const Left, Right: TPlayerPos): TPlayerPos;
begin
   Result.x := Left.x + Right.x;
   Result.y := Left.y + Right.y;
end;

class operator TPlayerPos.Subtract(const Left, Right: TPlayerPos): TPlayerPos;
begin
   Result.x := Left.x - Right.x;
   Result.y := Left.y - Right.y;
end;

end.
