         unit unit1;
{$mode objfpc}{$H+}
interface
uses
 Classes, SysUtils, FileUtil, OpenGLContext, Forms, Controls, Graphics,
 Dialogs, StdCtrls, ExtCtrls, Gl, Glu, GLext {GraphType,} ;

type
 { TForm1 }
 TForm1 = class(TForm)
 OpenGLControl1: TOpenGLControl;
 Timer1: TTimer;

 procedure FormActivate(Sender: TObject);
 procedure FormCreate(Sender: TObject);
 procedure FormResize(Sender: TObject);
 procedure OpenGLControl1MouseMove(Sender: TObject; Shift: TShiftState; X,
 Y: Integer);
 procedure OpenGLControl1Paint(Sender: TObject);

 procedure Timer1Timer(Sender: TObject);



 private
 public
 end;
 f3d=record x,y,z:single end;
const maks=5;
var
 Form1: TForm1;
 k,k1:single;
 xpoz,ypoz,k2:integer;
 tablos:array of record x,y,z,m:single end;
 tex1,tex2,tex3:GLuint;
 bmp1,bmp2,bmp3:TBitmap;


 tab: array of record x,y,z:single end;

implementation
{$R *.lfm}
{ TForm1 }

function il_wek(vc,vl,vp:f3d):f3d;
  var w,a,b:f3d;
begin
  a.x:=vl.x-vc.x; a.y:=vl.y-vc.y; a.z:=vl.z-vc.z;
  b.x:=vp.x-vc.x; b.y:=vp.y-vc.y; b.z:=vp.z-vc.z;
  w.x:=a.y*b.z-a.z*b.y;
  w.y:=a.z*b.x-a.x*b.z;
  w.z:=a.x*b.y-a.y*b.x;
  il_wek:=w;
end;

function norm_wek(w:f3d):f3d;
  var d:double;
begin
  d:=sqrt(sqr(w.x)+sqr(w.y)+sqr(w.z));
  if d>0 then begin result.x:=w.x/d; result.y:=w.y/d; result.z:=w.z/d end
         else begin result.x:=0; result.y:=0; result.z:=0 end;
end;

procedure oswietlenie;
const
  AmbientLight: array[0..3] of GLfloat = (0.2, 0.3, 0.2, 1);
  DiffuseLight: array[0..3] of GLfloat = (0.8, 0.8, 0.8, 1);
  SpecularLight: array[0..3] of GLfloat = (0.9, 1, 0.9, 1);
  positionLight: array[0..3] of GLfloat = (0, 0, 1, 1);
begin
  glEnable(GL_LIGHTING);
  glEnable(GL_LIGHT0);
  glLightfv(GL_LIGHT0, GL_AMBIENT, AmbientLight);
  glLightfv(GL_LIGHT0, GL_DIFFUSE, DiffuseLight);
  glLightfv(GL_LIGHT0, GL_SPECULAR, SpecularLight);
  glLightfv(GL_LIGHT0, GL_POSITION, positionLight);

  glEnable(GL_COLOR_MATERIAL);
  glColorMaterial(GL_FRONT_AND_BACK, GL_AMBIENT_AND_DIFFUSE);
  glMaterialfv(GL_FRONT_AND_BACK, GL_SPECULAR, SpecularLight);
  glMaterialf(GL_FRONT_AND_BACK, GL_SHININESS, 32);
end;

procedure JpgBmp(nazwa:String; bmp:TBitmap);
 var pic:TPicture;
 begin
  pic:=TPicture.Create;
  try
    pic.LoadFromFile(nazwa);
    bmp.PixelFormat:=pf24bit;
    bmp.Width:=Pic.Graphic.Width;
    bmp.Height:=Pic.Graphic.Height;
    bmp.Canvas.Draw(0,0,Pic.Graphic);
  finally
    FreeAndNil(pic);
  end;
 end;

function CreateTexture(Width,Height:Integer; pData:Pointer):GLUInt;
var Texture:GLuint;
begin  glEnable(GL_TEXTURE_2D);
 glGenTextures(1,@Texture);
 glBindTexture(GL_TEXTURE_2D,Texture);
 glTexParameteri(GL_TEXTURE_2D,GL_TEXTURE_MIN_FILTER,GL_LINEAR);
 glTexParameteri(GL_TEXTURE_2D,GL_TEXTURE_MAG_FILTER,GL_LINEAR);
 glTexImage2D(GL_TEXTURE_2D,0,3,Width,Height,0,GL_BGR,GL_UNSIGNED_BYTE,pData);
 Result:=Texture;
end;

procedure LoadTexture(NazPliku:string;var bmp:TBitmap; var texture: GLuint);
 var st:string;
 pbuf:PInteger;
 begin
  if bmp<>nil then bmp.Free;
  bmp:=TBitmap.Create;
  st:=copy(NazPliku,Length(NazPliku)-2,3);
  if st='jpg' then JpgBmp(NazPliku,bmp)
  else bmp.LoadFromFile(NazPliku);
  pbuf:=PInteger(bmp.RawImage.Data);
  texture:=CreateTexture(bmp.Width,bmp.Height,pbuf);
 end;





procedure lodyga;
  var p:array [0..3] of f3d;
      norm,n:f3d;
begin
  with p[0] do begin x:=0.1; y:=0.1; z:=0 end;
  with p[1] do begin x:=-0.1; y:=0; z:=0 end;
  with p[2] do begin x:=0; y:=-0.1; z:=0 end;
  with p[3] do begin x:=0; y:=0; z:=1 end;

  glEnable(GL_TEXTURE_2D);
  glBindTexture(GL_TEXTURE_2D,tex1);
  glBegin(GL_TRIANGLES);
    norm:=il_wek(p[0],p[1],p[3]);
    n:=norm_wek(norm);
    glNormal3fv(@n);
    glColor3f(1,1,1);
    glTexCoord2f(0,0);
    glVertex3fv(@p[0]);
    glTexCoord2f(1,0);
    glVertex3fv(@p[1]);
    glTexCoord2f(0.5,1);
    glVertex3fv(@p[3]);

    norm:=il_wek(p[1],p[2],p[3]);
    n:=norm_wek(norm);
    glNormal3fv(@n);
    glTexCoord2f(0,0);
    glVertex3fv(@p[1]);
    glTexCoord2f(1,0);
    glVertex3fv(@p[2]);
    glTexCoord2f(0.5,1);
    glVertex3fv(@p[3]);

    norm:=il_wek(p[2],p[0],p[3]);
    n:=norm_wek(norm);
    glNormal3fv(@n);
    glTexCoord2f(0,0);
    glVertex3fv(@p[2]);
    glTexCoord2f(1,0);
    glVertex3fv(@p[0]);
    glTexCoord2f(0.5,1);
    glVertex3fv(@p[3]);
    glEnd;
    glDisable(GL_TEXTURE_2D);
end;

procedure kulka;
const
  kRadius = 0.08;
  kSlices = 20;
  kStacks = 20;
  kLeafCount = 50;
  kLeafLength = 0.3;
  kLeafWidth = 0.1;
var
  i, j: Integer;
  angle, angle2, leafAngle: Double;
begin

  glEnable(GL_TEXTURE_2D);
  glBindTexture(GL_TEXTURE_2D, tex2);
  glTexParameterf(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_CLAMP_TO_EDGE);
  glTexParameterf(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_CLAMP_TO_EDGE);
  glTexEnvi(GL_TEXTURE_ENV, GL_TEXTURE_ENV_MODE, GL_MODULATE);

  glBegin(GL_TRIANGLE_FAN);
  glTexCoord2f(0.5, 0.5);
  glVertex3f(0, 0, 0);

  for i := 0 to kSlices do
  begin
    angle := 2 * Pi * i / kSlices;
    glNormal3f(Sin(angle), Cos(angle), 0);
    glTexCoord2f(Sin(angle) * 0.5 + 0.5, Cos(angle) * 0.5 + 0.5);
    glVertex3f(kRadius * Sin(angle), kRadius * Cos(angle), 0);
  end;

  glEnd();

  glBegin(GL_TRIANGLE_STRIP);
  for j := 1 to kStacks - 1 do
  begin
    angle2 := Pi * j / kStacks;
    for i := 0 to kSlices do
    begin
      angle := 2 * Pi * i / kSlices;
      glTexCoord2f(i / kSlices, j / kStacks);
      glVertex3f(kRadius * Sin(angle) * Sin(angle2),
        kRadius * Cos(angle) * Sin(angle2),
        kRadius * Cos(angle2));
      glTexCoord2f(i / kSlices, (j + 1) / kStacks);
      glVertex3f(kRadius * Sin(angle) * Sin(angle2 + Pi / kStacks),
        kRadius * Cos(angle) * Sin(angle2 + Pi / kStacks),
        kRadius * Cos(angle2 + Pi / kStacks));
    end;
  end;
  glEnd();


  glBindTexture(GL_TEXTURE_2D, tex3);
  glTexParameterf(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_CLAMP_TO_EDGE);
  glTexParameterf(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_CLAMP_TO_EDGE);
  glTexEnvi(GL_TEXTURE_ENV, GL_TEXTURE_ENV_MODE, GL_MODULATE);

  glEnable(GL_BLEND);
  glBlendFunc(GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);
  glColor4f(1, 0.5, 0.5, 0.5);

  glBegin(GL_TRIANGLES);
  for i := 0 to kLeafCount - 1 do
  begin
    leafAngle := 2 * Pi * i / kLeafCount;
    glTexCoord2f(0.5, 0.5);
    glVertex3f(kRadius * Sin(leafAngle), kRadius * Cos(leafAngle), 0);
    glTexCoord2f(1, 0);
    glVertex3f(kRadius * Sin(leafAngle) + kLeafLength * Cos(leafAngle),
  kRadius * Cos(leafAngle) - kLeafLength * Sin(leafAngle),
  0);
glTexCoord2f(0, 1);
glVertex3f(kRadius * Sin(leafAngle) - kLeafWidth * Sin(leafAngle),
  kRadius * Cos(leafAngle) - kLeafWidth * Cos(leafAngle),
  0);
  end;
  glEnd();

  glDisable(GL_BLEND);
  glDisable(GL_TEXTURE_2D);
  end;


var petalAngle: Double = 0;

procedure kwiatek;

begin
glBindTexture(GL_TEXTURE_2D, tex3);
lodyga;
glPushMatrix;
glTranslatef(0, 0, 1);
glRotatef(petalAngle, 0, 0, 1);
kulka;
glPopMatrix;
petalAngle := petalAngle + 3.5;
end;




procedure TForm1.FormActivate(Sender: TObject);
begin
 LoadTexture('trawa.jpg',bmp1,tex1);
 LoadTexture('flower.jpg',bmp2,tex2);
 LoadTexture('plat.jpg',bmp3,tex3);

end;



procedure TForm1.OpenGLControl1MouseMove(Sender: TObject; Shift: TShiftState;
  X, Y: Integer);
begin
  xpoz:=x; ypoz:=y;
  OpenGLControl1Paint(self);
end;


procedure TForm1.FormResize(Sender: TObject);
begin
  OpenGLControl1.SwapBuffers
end;

procedure TForm1.FormCreate(Sender: TObject);
begin
  k1:=0;
  OpenGLControl1.AutoResizeViewport:=true;
end;

procedure TForm1.OpenGLControl1Paint(Sender: TObject);

begin
  glMatrixMode(GL_PROJECTION);
  glLoadIdentity;
  gluPerspective(xpoz/15+1,Width/Height,0.1,1000);

  glMatrixMode(GL_MODELVIEW);
  glLoadIdentity;
  gluLookAt(30,0,0,0,0,0.5,0,0,1);
  OpenGLControl1.Invalidate;
  glClearColor(0.5,0.6,0.5,1);
  glClear(GL_COLOR_BUFFER_BIT or GL_DEPTH_BUFFER_BIT);
  glEnable(GL_DEPTH_test);

  glEnable(GL_COLOR_MATERIAL);

  oswietlenie;
  glRotatef(k1,0,0,1);
  glRotatef(ypoz,0,1,0);
  glRotatef(xpoz,0,0,1);

  lodyga;
  kwiatek;
  OpenGLControl1.SwapBuffers;


end;

procedure TForm1.Timer1Timer(Sender: TObject);
begin
  inc(k2);
  if k2>359 then k2:=0;

  OpenGLControl1Paint(self);

end;


end.

