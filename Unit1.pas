(*
 TrackLab - Tebe/Madteam
 changes: 27.04.2014 / 03.01.2015 / 12.09.2017

03.01.2015
- dla Perlin Noise dodana Amplituda

19.05.2015
- dla Sinus dodana amplituda typu real
- zapis do ASM na podstawie zakresu wartosci dta b(), a(), t(), f()

*)

unit Unit1;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, ShlObj,
  Dialogs, ExtCtrls, StdCtrls, BMDSpinEdit, Menus, IniFiles, ComCtrls, PlsmCloud;

type

 tTrack = (_liss, _cycl, _circ, _sinu, _perl);

  TForm1 = class(TForm)
    Image1: TImage;
    PageControl1: TPageControl;
    TabSheet1: TTabSheet;
    TabSheet3: TTabSheet;
    amp_x: TBMDSpinEdit;
    amp_y: TBMDSpinEdit;
    okres_x: TBMDSpinEdit;
    okres_y: TBMDSpinEdit;
    faza: TBMDSpinEdit;
    kat_drgan: TBMDSpinEdit;
    length: TBMDSpinEdit;
    tor: TBMDSpinEdit;
    kol: TBMDSpinEdit;
    exc: TBMDSpinEdit;
    krok: TBMDSpinEdit;
    l_krok: TBMDSpinEdit;
    Label1: TLabel;
    MainMenu1: TMainMenu;
    File1: TMenuItem;
    Open1: TMenuItem;
    Save1: TMenuItem;
    N1: TMenuItem;
    Exit1: TMenuItem;
    OpenDialog1: TOpenDialog;
    SaveDialog1: TSaveDialog;
    TabSheet4: TTabSheet;
    Amount: TBMDSpinEdit;
    bSave: TButton;
    Save2: TMenuItem;
    DAT1: TMenuItem;
    ASM1: TMenuItem;
    TabSheet2: TTabSheet;
    cRadius: TBMDSpinEdit;
    ptrack: TRadioGroup;
    TabSheet5: TTabSheet;
    asin0: TBMDSpinEdit;
    osin0: TBMDSpinEdit;
    lsin0: TBMDSpinEdit;
    sin0: TCheckBox;
    asin1: TBMDSpinEdit;
    asin2: TBMDSpinEdit;
    asin3: TBMDSpinEdit;
    osin1: TBMDSpinEdit;
    osin2: TBMDSpinEdit;
    osin3: TBMDSpinEdit;
    lsin1: TBMDSpinEdit;
    lsin2: TBMDSpinEdit;
    lsin3: TBMDSpinEdit;
    sin1: TCheckBox;
    sin2: TCheckBox;
    sin3: TCheckBox;
    cStyle: TRadioGroup;
    Button1: TButton;
    Image2: TImage;
    pAmplitude: TBMDSpinEdit;
    RichEdit1: TRichEdit;
    RichEdit2: TRichEdit;
    PopupMenu1: TPopupMenu;
    DEC1: TMenuItem;
    HEX1: TMenuItem;
    Label2: TLabel;
    Button2: TButton;
    procedure Button1Click(Sender: TObject);
    procedure lengthChange(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure Exit1Click(Sender: TObject);
    procedure Save1Click(Sender: TObject);
    procedure Open1Click(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure PageControl1Change(Sender: TObject);
    procedure bSaveClick(Sender: TObject);
    procedure DAT1Click(Sender: TObject);
    procedure ASM1Click(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure ptrackClick(Sender: TObject);
    procedure cRadiusChange(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure Image2Click(Sender: TObject);
    procedure Image2MouseMove(Sender: TObject; Shift: TShiftState; X,
      Y: Integer);
    procedure DEC1Click(Sender: TObject);
    procedure HEX1Click(Sender: TObject);
    procedure Button2Click(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  Form1: TForm1;

  tabx, taby : array [-2048..2048] of integer;

  ile: integer = 256;

  xc, yc, fcnt: integer;

  pt: TPoint;

  path, fsav: string;

  plasma: TBitmap;

  lisHelp: Boolean = false;

const
 title = 'TrackLab 2.2 (12.09.2107)';

implementation

{$R *.dfm}


function GetSpecialFolderPath(const Folder: Integer): string;
var
  Path: array[0..MAX_PATH] of Char;
begin
  SHGetSpecialFolderPath(0, Path, Folder , False);
  Result := Path;
end;


procedure read_ini(var INI: TINIFile);
begin

  form1.PageControl1.ActivePageIndex := INI.ReadInteger('track','type',0);
  form1.length.Position := INI.ReadInteger('track','length', 256);

  form1.amp_x.Position := INI.ReadInteger('lissajous','amp_x', 32);
  form1.amp_y.Position := INI.ReadInteger('lissajous','amp_y', 32);
  form1.okres_x.Position := INI.ReadInteger('lissajous','per_x', 24);
  form1.okres_y.Position := INI.ReadInteger('lissajous','per_y', 16);
  form1.faza.Position := INI.ReadInteger('lissajous','phash', 180);
  form1.kat_drgan.Position := INI.ReadInteger('lissajous','angle', 90);
  form1.l_krok.Value := INI.ReadFloat  ('lissajous','step', 0.19);

  form1.cRadius.Position := INI.ReadInteger('circle','rad', 64);

  form1.pAmplitude.Position := INI.ReadInteger('perlin','amp', 32);
  form1.amount.Position := INI.ReadInteger('perlin','amo', 100);
  form1.ptrack.ItemIndex := INI.ReadInteger('perlin','trc', form1.ptrack.ItemIndex);

  form1.kol.Position := INI.ReadInteger('cyclic','cir_r', 40);
  form1.tor.Position := INI.ReadInteger('cyclic','rad_t', 100);
  form1.exc.Position := INI.ReadInteger('cyclic','ecc_r', 60);
  form1.krok.Value   := INI.ReadFloat  ('cyclic','step', 2.85);
  form1.cStyle.ItemIndex := INI.ReadInteger ('cyclic','type', form1.cStyle.ItemIndex);

  form1.asin0.Value := INI.ReadFloat('sinus','amp0', 8);
  form1.asin1.Value := INI.ReadFloat('sinus','amp1', 16);
  form1.asin2.Value := INI.ReadFloat('sinus','amp2', 24);
  form1.asin3.Value := INI.ReadFloat('sinus','amp3', 32);
  form1.osin0.Position := INI.ReadInteger('sinus','ofs0', 0);
  form1.osin1.Position := INI.ReadInteger('sinus','ofs1', 0);
  form1.osin2.Position := INI.ReadInteger('sinus','ofs2', 0);
  form1.osin3.Position := INI.ReadInteger('sinus','ofs3', 0);
  form1.lsin0.Value := INI.ReadFloat('sinus','frq0', 1);
  form1.lsin1.Value := INI.ReadFloat('sinus','frq1', 2);
  form1.lsin2.Value := INI.ReadFloat('sinus','frq2', 3);
  form1.lsin3.Value := INI.ReadFloat('sinus','frq3', 4);
  form1.sin0.Checked := INI.ReadBool('sinus','chk0', true);
  form1.sin1.Checked := INI.ReadBool('sinus','chk1', false);
  form1.sin2.Checked := INI.ReadBool('sinus','chk2', false);
  form1.sin3.Checked := INI.ReadBool('sinus','chk3', false);

  form1.PageControl1.Pages[form1.PageControl1.ActivePageIndex].Refresh;

end;


procedure save_ini(var INI: TINIFile; idx: integer);
begin

  INI.WriteInteger('track','type',form1.PageControl1.ActivePageIndex);
  INI.WriteInteger('track','length',form1.length.Position);

  case tTrack(idx) of
   _liss:
      begin
       INI.WriteInteger('lissajous','amp_x',form1.amp_x.Position);
       INI.WriteInteger('lissajous','amp_y',form1.amp_y.Position);
       INI.WriteInteger('lissajous','per_x',form1.okres_x.Position);
       INI.WriteInteger('lissajous','per_y',form1.okres_y.Position);
       INI.WriteInteger('lissajous','phash',form1.faza.Position);
       INI.WriteInteger('lissajous','angle',form1.kat_drgan.Position);
       INI.WriteFloat  ('lissajous','step',form1.l_krok.Value);
      end;

   _cycl:
      begin
       INI.WriteInteger('cyclic','cir_r',form1.kol.Position);
       INI.WriteInteger('cyclic','rad_t',form1.tor.Position);
       INI.WriteInteger('cyclic','ecc_r',form1.exc.Position);
       INI.WriteFloat  ('cyclic','step',form1.krok.Value);
       INI.WriteInteger('cyclic','type',form1.cStyle.ItemIndex);
      end;

   _circ:
      begin
       INI.WriteInteger('circle','cir_r',form1.cRadius.Position);
      end;

   _sinu:
      begin
       INI.WriteFloat('sinus','amp0',form1.asin0.Value);
       INI.WriteFloat('sinus','amp1',form1.asin1.Value);
       INI.WriteFloat('sinus','amp2',form1.asin2.Value);
       INI.WriteFloat('sinus','amp3',form1.asin3.Value);

       INI.WriteInteger('sinus','ofs0',form1.osin0.Position);
       INI.WriteInteger('sinus','ofs1',form1.osin1.Position);
       INI.WriteInteger('sinus','ofs2',form1.osin2.Position);
       INI.WriteInteger('sinus','ofs3',form1.osin3.Position);

       INI.WriteFloat('sinus','frq0',form1.lsin0.Value);
       INI.WriteFloat('sinus','frq1',form1.lsin1.Value);
       INI.WriteFloat('sinus','frq2',form1.lsin2.Value);
       INI.WriteFloat('sinus','frq3',form1.lsin3.Value);

       INI.WriteBool('sinus','chk0',form1.sin0.Checked);
       INI.WriteBool('sinus','chk1',form1.sin1.Checked);
       INI.WriteBool('sinus','chk2',form1.sin2.Checked);
       INI.WriteBool('sinus','chk3',form1.sin3.Checked);
      end;

   _perl:
      begin
       INI.WriteInteger('perlin','amp',form1.pAmplitude.Position);
       INI.WriteInteger('perlin','amo',form1.Amount.Position);
       INI.WriteInteger('perlin','trc',form1.ptrack.ItemIndex);
      end;
  end;

end;


procedure SaveButton;
var tp: char;
begin

 case tTrack(form1.PageControl1.ActivePageIndex) of
  _liss: tp:='l';
  _cycl: tp:='c';
  _perl: tp:='p';
  _circ: tp:='r';
  _sinu: tp:='s';
 end;

 str(fcnt:3, fsav);
 if fsav[1]=' ' then fsav[1]:='0';
 if fsav[2]=' ' then fsav[2]:='0';

 if form1.dat1.Checked then
  fsav:='track'+fsav+'_'+tp+'.dat'
 else
  fsav:='track'+fsav+'_'+tp+'.asm';

 form1.bSave.Caption:='SAVE  '+fsav;

end;


procedure sort(var x,y: string);
var max_x, max_y, min_x, min_y, i: integer;
    a, b: integer;
begin

max_x:=0; max_y:=0;
min_x:=$ffff; min_y:=$ffff;
 for i:=0 to ile-1 do begin
  if tabx[i]>max_x then max_x:=tabx[i];
  if tabx[i]<min_x then min_x:=tabx[i];
  if taby[i]>max_y then max_y:=taby[i];
  if taby[i]<min_y then min_y:=taby[i];
 end;

 a:=0;
 b:=0;

 x:='';
 y:='';

 for i:=0 to ile-1 do begin
  tabx[i]:=tabx[i]-min_x;

  if tTrack(form1.PageControl1.ActivePageIndex) in [_perl] then
   taby[i]:=round((taby[i]-min_y) * form1.pAmplitude.Position/(max_y-min_y))
  else
   taby[i]:=taby[i]-min_y;

  if tabx[i]>a then a:=tabx[i];
  if taby[i]>b then b:=taby[i];

  if i>0 then begin
   x:=x+' ';
   y:=y+' ';
  end;

  if form1.HEX1.Checked then begin
   x:=x+IntToHex(tabx[i], 2);
   y:=y+IntToHex(taby[i], 2);
  end else begin
   x:=x+IntToStr(tabx[i]);
   y:=y+IntToStr(taby[i]);
  end;

 end;

 Form1.RichEdit1.Clear;
 Form1.RichEdit2.Clear;

 if form1.HEX1.Checked then begin
  form1.label1.Caption:=format('HEX <0..%x>',[a]);
  form1.label2.Caption:=format('HEX <0..%x>',[b]);
 end else begin
  form1.label1.Caption:=format('DEC <0..%d>',[a]);
  form1.label2.Caption:=format('DEC <0..%d>',[b]);
 end;

end;


{****************** C Y K L *********************}


procedure cykl;
var k, w, i, tor,kol,exc, znak, wsp: integer;
    alfa,beta,xm,xp,ym,yp,x,y: double;
    krok: double;
begin

{
tor - promien toru
kol - promien okregu
exc - mimosrodowosc
krok - dlugosc kroku
}

tor:=form1.tor.Position;
kol:=form1.kol.Position;
exc:=form1.exc.Position;
krok:=form1.krok.Value;

if form1.cStyle.ItemIndex=0 then begin
 wsp:=tor-kol;
 znak:=1;
end else begin
 wsp:=tor+kol;
 znak:=-1;
end;

alfa:=0;
beta:=0;

for i:=0 to ile-1 do begin

 xm:=wsp*cos(alfa*pi/180);
 xp:=exc*cos((alfa-znak*beta)*pi/180);
 x:=xp-xm;

 ym:=wsp*sin(alfa*pi/180);
 yp:=exc*sin((alfa-znak*beta)*pi/180);
 y:=ym-yp;

 k:=round(xc+x); w:=round(yc+y);

 alfa:=alfa+krok;
 beta:=alfa*tor/kol;

 tabx[i]:=k; taby[i]:=w;
end;

end;


{****************** L I S S *********************}

procedure liss;
var ax,ay,tx,ty,fi,kat,dx,dy:integer;
    omega,p,dt,x,y, t:real;
    i,k,w: integer;
    krok: double;
begin

{
 ax - amplituda X
 ay - amplituda Y
 tx - okres drgan X
 ty - okres drgan Y
 fi - przesuniecie fazowe
 kat- kat miedzy plaszczyznami drgan
}

ax:=form1.amp_x.Position;
ay:=form1.amp_y.Position;
tx:=form1.okres_x.Position;
ty:=form1.okres_y.Position;
fi:=form1.faza.Position;
kat:=form1.kat_drgan.Position;

krok:=form1.l_krok.Value;

dx:=0+ax; dy:=ay;

omega:=kat*pi/180; p:=fi*pi/180;
dt:=(tx+ty)/(ax+ay); t:=0;

 for i:=0 to ile-1 do begin
  x:=ax*sin(2*pi*t/tx);
  y:=ay*sin(2*pi*t/ty+p);
  x:=x+y*cos(omega);
  y:=y*sin(omega);

  w:=round(x+dx);
  k:=round(y+dy);

  tabx[i]:=k; taby[i]:=w;

  t:=t+krok;
 end;

end;


procedure circ;
var a, radius, ang, stp: double;
    i: integer;
begin

 radius:=form1.cRadius.Position;
 ang:=0;
 stp:=360/ile;

      for i := 0 to ile-1 do begin
        a   := ang * pi/180;
        tabx[i]:=Round(radius * Cos(a));
        taby[i]:=Round(radius * Sin(a));

        ang:=ang+stp;

      end;

end;


{******************  S I N U S  *********************}

procedure sinu;
var i: integer;
    w, k0,k1,k2,k3: double;
begin

 k0:=(360/ile)*form1.lsin0.Value;
 k1:=(360/ile)*form1.lsin1.Value;
 k2:=(360/ile)*form1.lsin2.Value;
 k3:=(360/ile)*form1.lsin3.Value;

 for i := 0 to ile-1 do begin
  tabx[i]:=i;

  w:=0;
  if form1.sin0.Checked then w:=w+form1.asin0.Value*sin((form1.osin0.Position+i*k0)*pi/180);
  if form1.sin1.Checked then w:=w+form1.asin1.Value*sin((form1.osin1.Position+i*k1)*pi/180);
  if form1.sin2.Checked then w:=w+form1.asin2.Value*sin((form1.osin2.Position+i*k2)*pi/180);
  if form1.sin3.Checked then w:=w+form1.asin3.Value*sin((form1.osin3.Position+i*k3)*pi/180);

  taby[i]:=round(w);
 end;

end;


{****************** P L A S M A   C L O U D S  *********************}

procedure read_track;
var i: integer;
    x,y: string;
begin

 case form1.ptrack.ItemIndex of
  0: begin liss; sort(x,y) end;
  1: begin cykl; sort(x,y) end;
  2: begin circ; sort(x,y) end;
  3: begin sinu; sort(x,y) end;
 end;

 for i := 0 to ile-1 do begin
  taby[i]:=GetRValue(plasma.Canvas.Pixels[256 + tabx[i], 256 + taby[i]]);
  tabx[i]:=i;
 end;

 sort(x,y);

 form1.RichEdit2.Visible:=false;

 form1.RichEdit1.Lines.Add(y);
 form1.RichEdit1.Visible:=true;
 form1.RichEdit1.Height:=194;

 form1.Label1.Caption:=form1.Label2.Caption;
end;


procedure perl;
begin

 DoPlasma(form1.Amount.Position, plasma);

 read_track;

end;


procedure Preview;
var i: integer;
    bmp: TBitmap;
begin

 bmp:=TBitmap.Create;
 bmp.PixelFormat:=pf32bit;
 bmp.SetSize(form1.Image1.Width, form1.Image1.Height);

 with bmp.canvas do begin
  Brush.Color:=0;
  FillRect(Rect(0,0,form1.Image1.Width,form1.Image1.Height));
 end;

 with bmp.canvas do
  for i := 0 to ile-1 do
   pixels[tabx[i], taby[i]]:=clWhite;

 form1.Image1.Picture.Bitmap:=bmp;

 bmp.Free;

end;


procedure valType(var mx: integer; var tps: string; var tph: byte);
begin

  if mx>$FFFFFF then begin tps:='f'; tph:=8 end else   // dword
   if mx>$FFFF then begin tps:='t'; tph:=6 end else    // triple
    if mx>$FF then begin tps:='a'; tph:=4 end else     // word
     begin tps:='b'; tph:=2 end;                       // byte

end;


procedure save;
var i,j, mx: integer;
    a: byte;
    tx: textfile;
    tps: string;
    tph: byte;
begin

 if form1.DAT1.Checked then begin

   i:=FileCreate(fsav, fmOpenWrite);

   if tTrack(form1.PageControl1.ActivePageIndex) in [_liss, _cycl, _circ] then
    for j := 0 to ile-1 do begin
     a:=tabx[j];

     FileWrite(i, a, 1);
    end;

   for j := 0 to ile-1 do begin
    a:=taby[j];

    FileWrite(i, a, 1);
   end;

   FileClose(i);

 end;


 if form1.ASM1.Checked then begin

  assignfile(tx, fsav); rewrite(tx);

  writeln(tx, '; Length: ', form1.length.Position);

  case tTrack(form1.PageControl1.ActivePageIndex) of
   _liss: writeln(tx, '; Lissajous (',form1.amp_x.Position,',',form1.amp_y.Position,',',form1.okres_x.Position,',',form1.okres_y.Position,',',form1.faza.Position,',',form1.kat_drgan.Position,',',form1.l_krok.Value:2:3,')');
   _cycl: writeln(tx, '; Cyclic curves (',form1.kol.Position,',',form1.tor.Position,',',form1.exc.Position,',',form1.cStyle.ItemIndex,',',form1.krok.Value:2:3,')');
   _circ: writeln(tx, '; Circle (',form1.cRadius.Position,')');

   _sinu: begin
           if form1.sin0.Checked then writeln(tx, '; Sinus #0 (',form1.asin0.Value:2:2,',',form1.osin0.Position,',',form1.lsin0.Value:2:3,')');
           if form1.sin1.Checked then writeln(tx, '; Sinus #1 (',form1.asin1.Value:2:2,',',form1.osin1.Position,',',form1.lsin1.Value:2:3,')');
           if form1.sin2.Checked then writeln(tx, '; Sinus #2 (',form1.asin2.Value:2:2,',',form1.osin2.Position,',',form1.lsin2.Value:2:3,')');
           if form1.sin3.Checked then writeln(tx, '; Sinus #3 (',form1.asin3.Value:2:2,',',form1.osin3.Position,',',form1.lsin3.Value:2:3,')');
          end;

   _perl: writeln(tx, '; Perlin noise (',form1.amount.Position,',',form1.pAmplitude.Position,',',form1.ptrack.ItemIndex,')');
  end;

//  writeln(tx, '; ',fsav);

  if tTrack(form1.PageControl1.ActivePageIndex) in [_liss, _cycl, _circ] then begin

   mx:=0;                                         // typ danych
   for i := 0 to ile-1 do
    if tabx[i]>mx then mx:=tabx[i];

   valType(mx, tps, tph);

   write(tx, #13#10'track0');
   write(tx, ' dta ', tps);
   for i := 0 to ile-1 do begin

    if i mod 32=0 then write(tx, '\', #13#10, ' '{, tps});

    if i=0 then
     write(tx, '($',IntToHex(tabx[i], tph))
    else
     write(tx, ',$',IntToHex(tabx[i], tph));

   end;

   writeln(tx, ')');

  end;

   mx:=0;                                         // typ danych
   for i := 0 to ile-1 do
    if taby[i]>mx then mx:=taby[i];

   valType(mx, tps, tph);

   write(tx, #13#10'track1');
   write(tx, ' dta ', tps);
   for i := 0 to ile-1 do begin

    if i mod 32=0 then write(tx, '\', #13#10, ' ');

    if i=0 then
     write(tx, '($',IntToHex(taby[i], tph))
    else
     write(tx, ',$',IntToHex(taby[i], tph));

   end;

  writeln(tx, ')');

  flush(tx);

  closefile(tx);

 end;


 inc(fcnt);

 SaveButton;

end;


procedure ScrollToEnd(ARichEdit: TRichEdit);
var
  isSelectionHidden: Boolean;
begin
  with ARichEdit do
  begin
    SelStart := Perform( EM_LINEINDEX, {Lines.Count} 0, 0);//Set caret at end
    isSelectionHidden := HideSelection;
    try
      HideSelection := False;
      Perform( EM_SCROLLCARET, 0, 0);  // Scroll to caret
    finally
      HideSelection := isSelectionHidden;
    end;
  end;
end;


procedure TForm1.Button1Click(Sender: TObject);
// START
var x,y: string;
begin

 image2.Visible:=false;

 RichEdit1.Height:=90;
 RichEdit2.Height:=90;

 RichEdit1.Visible:=false;
 RichEdit2.Visible:=false;

 case tTrack(PageControl1.ActivePageIndex) of
  _liss: begin liss; sort(x,y); image2.Visible:=lisHelp; RichEdit1.Lines.Add(x); RichEdit2.Lines.Add(y); RichEdit1.Visible:=not lisHelp; RichEdit2.Visible:=not lisHelp end;
  _cycl: begin cykl; sort(x,y); RichEdit1.Lines.Add(x); RichEdit2.Lines.Add(y); RichEdit1.Visible:=true; RichEdit2.Visible:=true end;
  _circ: begin circ; sort(x,y); RichEdit1.Lines.Add(x); RichEdit2.Lines.Add(y); RichEdit1.Visible:=true; RichEdit2.Visible:=true end;
  _sinu: begin sinu; sort(x,y); RichEdit1.Lines.Add(y); RichEdit1.Visible:=true; RichEdit1.Height:=194; Label1.Caption:=Label2.Caption end;
  _perl: begin perl; sort(x,y); RichEdit1.Lines.Add(y); RichEdit1.Visible:=true; RichEdit1.Height:=194; Label1.Caption:=Label2.Caption end;

 end;

 Label1.Visible := RichEdit1.Visible;
 Label2.Visible := RichEdit2.Visible;

 Preview;

 bSave.Enabled:=true;

 RichEdit1.ScrollBars:=ssNone;
 ScrollToEnd(RichEdit1);
 RichEdit1.ScrollBars:=ssVertical;

 RichEdit2.ScrollBars:=ssNone;
 ScrollToEnd(RichEdit2);
 RichEdit2.ScrollBars:=ssVertical;
end;


procedure TForm1.Button2Click(Sender: TObject);
begin
 lisHelp:=not lisHelp;

 RichEdit1.Visible:=not lisHelp;
 RichEdit2.Visible:=not lisHelp;

 label1.Visible:=not lisHelp;
 label2.Visible:=not lisHelp;

 image2.Visible:=lisHelp;

 Button1Click(self);

end;


procedure TForm1.cRadiusChange(Sender: TObject);
begin
 Button1Click(nil);
end;


procedure TForm1.bSaveClick(Sender: TObject);
begin

 save;

end;


procedure TForm1.DAT1Click(Sender: TObject);
begin
 asm1.Checked:=false;
 dat1.Checked:=true;

 SaveButton;
end;


procedure TForm1.ASM1Click(Sender: TObject);
begin
 dat1.Checked:=false;
 asm1.Checked:=true;

 SaveButton;
end;


procedure TForm1.Exit1Click(Sender: TObject);
begin
 Form1.Close;
end;


procedure TForm1.FormClose(Sender: TObject; var Action: TCloseAction);
var INI: TINIFile;
begin

 INI := TINIFile.Create(path+'track_lab.ini');

 INI.WriteString('last_path','path',OpenDialog1.FileName);
 INI.WriteBool('save','dat',dat1.Checked);
 INI.WriteBool('save','asm',asm1.Checked);

 save_ini(INI, ord(_liss));
 save_ini(INI, ord(_cycl));
 save_ini(INI, ord(_circ));
 save_ini(INI, ord(_sinu));
 save_ini(INI, ord(_perl));

 INI.Free;

end;


procedure TForm1.FormCreate(Sender: TObject);
begin
 doublebuffered:=true;

 FormatSettings.DecimalSeparator := ',';
 FormatSettings.ThousandSeparator := '.';

 path:=GetSpecialFolderPath(CSIDL_APPDATA);            // [USER]/Application Data/
 path:=IncludeTrailingPathDelimiter(path);

 path:=path+'TrackLab\';
 if not(DirectoryExists(path)) then CreateDir(path);

 OpenDialog1.InitialDir:=ExtractFilePath(Application.ExeName);
 SaveDialog1.InitialDir:=ExtractFilePath(Application.ExeName);

 image1.Picture.Bitmap.PixelFormat:=pf32bit;

 xc:=image1.Width shr 1;
 yc:=image1.Height shr 1;

 caption:=title+' - Tebe/Madteam';

 plasma:=TBitmap.Create;
 plasma.PixelFormat:=pf32bit;
 plasma.SetSize(form1.Image1.Width, form1.Image1.Height);

end;


procedure TForm1.FormDestroy(Sender: TObject);
begin
 plasma.Free;
end;


procedure TForm1.FormShow(Sender: TObject);
var INI: TINIFile;
    pth: string;
begin
 INI := TINIFile.Create(path+'track_lab.ini');

 pth:=INI.ReadString('last_path','path', path);

 OpenDialog1.InitialDir:=ExtractFilePath(pth);
 SaveDialog1.InitialDir:=ExtractFilePath(pth);

 OpenDialog1.FileName:=pth;

 read_ini(INI);

 dat1.Checked:=INI.ReadBool('save','dat',true);
 asm1.Checked:=INI.ReadBool('save','asm',false);

 INI.Free;

 SaveButton;

end;


procedure TForm1.Image2Click(Sender: TObject);
begin

 if PtInRect(Rect(70*0+25,43*0+11,70*0+87,43*0+49), Point(pt.x,pt.y)) then begin faza.Position:=90; kat_drgan.Position:=90; okres_x.Position:=3; okres_y.Position:=3 end;
 if PtInRect(Rect(70*1+25,43*0+11,70*1+87,43*0+49), Point(pt.x,pt.y)) then begin faza.Position:=90; kat_drgan.Position:=90; okres_x.Position:=3; okres_y.Position:=4 end;
 if PtInRect(Rect(70*2+25,43*0+11,70*2+87,43*0+49), Point(pt.x,pt.y)) then begin faza.Position:=90; kat_drgan.Position:=90; okres_x.Position:=3; okres_y.Position:=5 end;
 if PtInRect(Rect(70*3+25,43*0+11,70*3+87,43*0+49), Point(pt.x,pt.y)) then begin faza.Position:=90; kat_drgan.Position:=90; okres_x.Position:=3; okres_y.Position:=6 end;

 if PtInRect(Rect(70*0+25,43*1+11,70*0+87,43*1+49), Point(pt.x,pt.y)) then begin faza.Position:=90; kat_drgan.Position:=90; okres_x.Position:=4; okres_y.Position:=3 end;
 if PtInRect(Rect(70*1+25,43*1+11,70*1+87,43*1+49), Point(pt.x,pt.y)) then begin faza.Position:=90; kat_drgan.Position:=90; okres_x.Position:=4; okres_y.Position:=4 end;
 if PtInRect(Rect(70*2+25,43*1+11,70*2+87,43*1+49), Point(pt.x,pt.y)) then begin faza.Position:=90; kat_drgan.Position:=90; okres_x.Position:=4; okres_y.Position:=5 end;
 if PtInRect(Rect(70*3+25,43*1+11,70*3+87,43*1+49), Point(pt.x,pt.y)) then begin faza.Position:=90; kat_drgan.Position:=90; okres_x.Position:=4; okres_y.Position:=6 end;

 if PtInRect(Rect(70*0+25,43*2+11,70*0+87,43*2+49), Point(pt.x,pt.y)) then begin faza.Position:=90; kat_drgan.Position:=90; okres_x.Position:=5; okres_y.Position:=3 end;
 if PtInRect(Rect(70*1+25,43*2+11,70*1+87,43*2+49), Point(pt.x,pt.y)) then begin faza.Position:=90; kat_drgan.Position:=90; okres_x.Position:=5; okres_y.Position:=4 end;
 if PtInRect(Rect(70*2+25,43*2+11,70*2+87,43*2+49), Point(pt.x,pt.y)) then begin faza.Position:=90; kat_drgan.Position:=90; okres_x.Position:=5; okres_y.Position:=5 end;
 if PtInRect(Rect(70*3+25,43*2+11,70*3+87,43*2+49), Point(pt.x,pt.y)) then begin faza.Position:=90; kat_drgan.Position:=90; okres_x.Position:=5; okres_y.Position:=6 end;

 if PtInRect(Rect(70*0+25,43*3+11,70*0+87,43*3+49), Point(pt.x,pt.y)) then begin faza.Position:=90; kat_drgan.Position:=90; okres_x.Position:=6; okres_y.Position:=3 end;
 if PtInRect(Rect(70*1+25,43*3+11,70*1+87,43*3+49), Point(pt.x,pt.y)) then begin faza.Position:=90; kat_drgan.Position:=90; okres_x.Position:=6; okres_y.Position:=4 end;
 if PtInRect(Rect(70*2+25,43*3+11,70*2+87,43*3+49), Point(pt.x,pt.y)) then begin faza.Position:=90; kat_drgan.Position:=90; okres_x.Position:=6; okres_y.Position:=5 end;
 if PtInRect(Rect(70*3+25,43*3+11,70*3+87,43*3+49), Point(pt.x,pt.y)) then begin faza.Position:=90; kat_drgan.Position:=90; okres_x.Position:=6; okres_y.Position:=6 end;

 Button1Click(self);

end;



procedure TForm1.Image2MouseMove(Sender: TObject; Shift: TShiftState; X,
  Y: Integer);
begin
 pt:=Point(x,y);
end;

procedure TForm1.lengthChange(Sender: TObject);
begin
 ile:=length.Position;

 Button1Click(nil);
end;


procedure TForm1.PageControl1Change(Sender: TObject);
begin
 Button1Click(nil);

 SaveButton;
end;


procedure TForm1.ptrackClick(Sender: TObject);
begin
 read_track;

 Preview;

 bSave.Enabled:=true;
end;


procedure TForm1.Open1Click(Sender: TObject);
var INI: TINIFile;
begin

 if form1.OpenDialog1.Execute then begin

  INI := TINIFile.Create(form1.OpenDialog1.FileName);

  read_ini(INI);

 end;

 caption:=title+' - '+OpenDialog1.FileName;

 Button1Click(self);

 invalidate;

end;


procedure save_track;
var INI: TINIFile;
begin

 if form1.SaveDialog1.Execute then begin

  INI := TINIFile.Create(form1.SaveDialog1.FileName);

  save_ini(INI, form1.PageControl1.ActivePageIndex);

  INI.Free;

 end;

end;


procedure TForm1.Save1Click(Sender: TObject);
begin

 case tTrack(PageControl1.ActivePageIndex) of
  _liss: SaveDialog1.Title:='Save Lissajous';
  _cycl: SaveDialog1.Title:='Save Cyclic curves';
  _circ: SaveDialog1.Title:='Save Circle';
  _sinu: SaveDialog1.Title:='Save Sinus';
  _perl: SaveDialog1.Title:='Save Perlin noise';
 end;

 save_track;

end;


procedure TForm1.DEC1Click(Sender: TObject);
begin
 DEC1.Checked:=true;
 HEX1.Checked:=false;

 Button1Click(nil);
end;


procedure TForm1.HEX1Click(Sender: TObject);
begin
 HEX1.Checked:=true;
 DEC1.Checked:=false;

 Button1Click(nil);
end;

end.

