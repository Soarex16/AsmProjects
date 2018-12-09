{$S-;$I-;$R-;$Q-;$D-;$W-;$A-;$Y-}
uses dos;
var
  
  n, i, j: word;
  delta, cnt, dist, b: word;
  arr: array [1..9, 1..9] of word;

  r: registers;

procedure out(x: byte);
begin
  r.ah := 2;
  r.dl := x;
  msdos(r);
end;

procedure traverse(var idx: word);
begin
  cnt := 1;
	repeat
      inc(idx, delta);
      arr[i, j] := b;
      inc(b);
      inc(cnt);
	until cnt > dist; (* while ne proshagali ckolko nado*)
end;

begin
  (* print N= *)
  
  out(78); (* n *)
  out(61); (* = *)

  dec(r.ah); (* 02H - 1 = 1H - character input *)
  msdos(r);
  (* substract from input character ASCII code of 0 - substract from ah 48 *)
  n := r.ax - 304;
  
  
  (* fill matrix *)
  delta := 1;
  dist := n;
  
  b := 1;
  
  i := 1;
  j := 0;
  repeat
    traverse(j);
    dec(dist);
	  traverse(i);
	  delta := -delta;
  until b > n*n;
 
  (* print *)

  (* dec(n); *)
  r.ah := 2;
  r.dl := 10;
  msdos(r);

  i := 0;
  repeat
    if i mod n = 0 then
      out(10)
    else
      out(32);
    j := arr[i mod n][i div n];
    out(j div 10 + 48);
    out(j mod 10 + 48);
    inc(i);
  until i = n*n;
end.