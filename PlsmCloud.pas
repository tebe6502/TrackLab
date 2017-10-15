unit PlsmCloud;

interface

uses Windows, Graphics, SysUtils, Math;

type
  Txy = array [0..0] of integer; //For dynamic 2d array for D3 (Marble)
  PTxy = ^Txy;

var
  level : integer; //level used in recursive divide function
  grad : integer;  //Smoothness of Plasma
  Wd : integer;    //Stupid Width
  xval : PTxy;

  procedure DoPlasma(Amount: integer; var b: TBitmap);

implementation


{This is used with the PTxy type to use x,y to calc index into 1d array}
function idx(x,y,W: integer): integer;
begin
  Result := y * W + x;
end;


{Part of plasma recursive shifting}
function MShift(xa, ya, x, y, xb, yb:integer; Plsm : PTxy): integer;
var
  rand : integer;
begin
  rand := random(grad) shr level;
  if (random(2) = 0) then //randomly make a negative value
    rand := -rand;
  rand := (((Plsm[idx(xa,ya,Wd)]) + (Plsm[idx(xb,yb,Wd)]) + 1) shr 1) + rand;
  if rand < 1 then
    rand := 1;
  if rand > 255 then
    rand := 255;
  Plsm[idx(x,y,Wd)] := rand;
  MShift := rand;
end;


{Part of PLasma fractal recursive division.}
procedure divide(x1,y1,x2,y2:integer; Plsm : PTxy);
var
  x, y, i, v : integer;
begin
  if (((x2 - x1) < 2) and ((y2 - y1) < 2)) then exit;
  inc(level);
  x := (x1 + x2) shr 1;
  y := (y1 + y2) shr 1;

  v := Plsm[idx(x, y1,Wd)];
  if v = 0 then
    v := MShift(x1, y1, x, y1, x2, y1, Plsm);
  i := v;

  v := Plsm[idx(x2, y,Wd)];
  if v = 0 then
    v := MShift(x2, y1, x2, y, x2, y2, Plsm);
  i := i + v;

  v := Plsm[idx(x, y2,Wd)];
  if v = 0 then
    v := MShift(x1, y2, x, y2, x2, y2, Plsm);
  i := i + v;

  v := Plsm[idx(x1, y,Wd)];
  if v = 0 then
    v := MShift(x1, y1, x1, y, x1, y2, Plsm);
  i := i + v;

  if (Plsm[idx(x, y,Wd)]) = 0 then
    Plsm[idx(x, y,Wd)] := (i + 2) shr 2;
  divide(x1,y1,x,y,Plsm);
  divide(x,y1,x2,y,Plsm);
  divide(x,y,x2,y2,Plsm);
  divide(x1,y,x,y2,Plsm);
  dec(level);
end;


{Call this to fill a PTxy with values (plasma creation)}
procedure MakePlasma(BRay : PTxy; Smoothness : integer; w : integer;
  h : integer);
var
  a, b, x, y: integer;
  rand : byte;
  xmax, ymax : integer;
begin
  randomize;
  xmax := w div 2;
  ymax := abs(h div 2);
  grad := smoothness;
  for a := 0 to w-1 do
    for b := 0 to h-1 do
      BRay[idx(a, b,Wd)] := 0; //Draw blackness
  rand := random(255);
  BRay[idx(0,0,Wd)] := rand;  //Seed the corners
  rand := random(255);
  BRay[idx(xmax,0,Wd)] := rand;
  rand := random(255);
  BRay[idx(0,ymax,Wd)] := rand;
  rand := random(255);
  BRay[idx(xmax,ymax,Wd)] := rand;
  level := 0;
  divide(0,0,xmax,ymax,BRay);   //Do the plasma on upper left corner

  for y := 0 to ymax do
    BRay[idx((2*xmax)-1, y,Wd)] := BRay[idx(0, y,Wd)];  //Do other quads
  level := 0;
  divide(xmax, 0, (2*xmax)-1, ymax, BRay);
  for x := 0 to (2*xmax)-1 do
    BRay[idx(x, (2*ymax)-1,Wd)] := BRay[idx(x, 0,Wd)];
  level := 0;
  divide(xmax, ymax, (2*xmax)-1, (2*ymax)-1,BRay);
  for y := ymax to (2*ymax)-1 do
    BRay[idx(0, y,Wd)] := BRay[idx((2*xmax)-1, y,Wd)];
  level := 0;
  divide(0, ymax, xmax, (2*ymax)-1,BRay);
end;


procedure DoPlasma(Amount: integer; var b: TBitmap);
var
  pb : PByteArray;
  x, y : integer;
begin
//  Screen.Cursor := crHourGlass;
//  CopyMe(ud,b);

  GetMem(xval, b.Width * b.Height * SizeOf(integer));
  Wd := b.Width;
  MakePlasma(xval, Amount, b.Width, b.Height);
  for y := 0 to b.Height-1 do begin
    pb := b.ScanLine[y];
    for x := 0 to b.Width-1 do begin
      pb[x*4+2] := xval[idx(x,y,b.Width)];
      pb[x*4+1] := xval[idx(x,y,b.Width)];
      pb[x*4+0] := xval[idx(x,y,b.Width)];
    end;
  end;
  FreeMem(xval, b.Width * b.Height * SizeOf(integer));

//  imSine.Picture.Assign(b);
//  Screen.Cursor := crDefault;
end;


end.
