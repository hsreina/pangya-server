{*******************************************************}
{                                                       }
{       Pangya Server                                   }
{                                                       }
{       Copyright (C) 2015 Shad'o Soft tm               }
{                                                       }
{*******************************************************}

unit Types.Vector3;

interface

type
  TVector3 = packed record
    x, y, z: Single;

    class operator Add(const Left, Right: TVector3): TVector3;
    class operator Subtract(const Left, Right: TVector3): TVector3;

    function distance(playerPos: TVector3): single;
    function length: single;
  end;

implementation

function TVector3.distance(playerPos: TVector3): single;
begin
  result := (self - playerPos).length;
end;

function TVector3.length;
begin
  Result := Sqrt(x * x + y * y);
end;

class operator TVector3.Add(const Left, Right: TVector3): TVector3;
begin
   Result.x := Left.x + Right.x;
   Result.y := Left.y + Right.y;
end;

class operator TVector3.Subtract(const Left, Right: TVector3): TVector3;
begin
   Result.x := Left.x - Right.x;
   Result.y := Left.y - Right.y;
end;

end.
