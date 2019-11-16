unit bfreeprint;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, Gauges, xmldom, XMLIntf, msxmldom, XMLDoc, OleCtrls,
  Registry, Printers, Grids;

type
  TFPrint = class(TForm)
    Progress: TGauge;
    LToPrint: TLabel;
    BPrintSetup: TButton;
    BPrint: TButton;
    PrintSetup: TPrinterSetupDialog;
    procedure UpdateButtons;
    procedure FormActivate(Sender: TObject);
    procedure BPrintSetupClick(Sender: TObject);
    procedure BPrintClick(Sender: TObject);
    procedure PrintFile(fn : String);
    procedure FormCreate(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }

    params : string;
    pages : integer;
    done : integer;
    mode : byte;
    filename : string;
    SINGLE : byte;
    MULTI : byte;

  end;

var
  FPrint: TFPrint;
  PrintPath : string;

implementation

uses main;

{$R *.dfm}

procedure PrintStringGrid(Grid: TStringGrid; Title: string;
  Orientation: TPrinterOrientation);
var
  P, I, J, YPos, XPos, HorzSize, VertSize: Integer;
  TotalPages, Page, Line, HeaderSize, FooterSize, LineSize, FontHeight: Integer;
  mmx, mmy: Extended;
  Footer: string;
begin

  HeaderSize := 100;
  FooterSize := 200;
  LineSize := 36;
  FontHeight := 36;
  Printer.Orientation := Orientation;
  Printer.Title  := Title;
  Printer.BeginDoc;

  mmx := GetDeviceCaps(Printer.Canvas.Handle, PHYSICALWIDTH) /
    GetDeviceCaps(Printer.Canvas.Handle, LOGPIXELSX) * 25.4;
  mmy := GetDeviceCaps(Printer.Canvas.Handle, PHYSICALHEIGHT) /
    GetDeviceCaps(Printer.Canvas.Handle, LOGPIXELSY) * 25.4;

  VertSize := Trunc(mmy) * 10;
  HorzSize := Trunc(mmx) * 10;
  SetMapMode(Printer.Canvas.Handle, MM_LOMETRIC);

  //LineTotalahl festlegen
  Line := (VertSize - HeaderSize - FooterSize) div LineSize;
  //PagesTotalahl ermitteln
  if Grid.RowCount mod Line <> 0 then
    TotalPages := Grid.RowCount div Line + 1
  else
    TotalPages := Grid.RowCount div Line;

  Page := 1;
  //Grid Drucken
  for P := 1 to TotalPages do
  begin
    Printer.Canvas.Font.Height := 48;
    Printer.Canvas.TextOut((HorzSize div 2 - (Printer.Canvas.TextWidth(Title) div 2)),
      - 20,Title);
    Printer.Canvas.Pen.Width := 5;
    Printer.Canvas.MoveTo(0, - HeaderSize);
    Printer.Canvas.LineTo(HorzSize, - HeaderSize);
    Printer.Canvas.MoveTo(0, - VertSize + FooterSize);
    Printer.Canvas.LineTo(HorzSize, - VertSize + FooterSize);
    Printer.Canvas.Font.Height := 36;
    Footer := 'Page ' + IntToStr(Page) + ' of ' + IntToStr(TotalPages);
    Printer.Canvas.TextOut((HorzSize div 2 - (Printer.Canvas.TextWidth(Footer) div 2)),
      - VertSize + 150,Footer);
    Printer.Canvas.Font.Height := FontHeight;
    YPos := HeaderSize + 10;
    for I := 1 to Line do
    begin
      if (I=1) and (P=1) then
        Printer.Canvas.Font.Style:=Printer.CAnvas.Font.Style + [fsBold]
      else
        Printer.Canvas.Font.Style:=Printer.CAnvas.Font.Style - [fsBold];
     
      if Grid.RowCount >= I + (Page - 1) * Line then
      begin
        XPos := 0;
        for J := 0 to Grid.ColCount - 1 do
        begin
          Printer.Canvas.TextOut(XPos, - YPos,
            Grid.Cells[J, I + (Page - 1) * Line - 1]);
          XPos := XPos + Grid.ColWidths[J] * 3;
        end;
        YPos := YPos + LineSize;
      end;
    end;
    Inc(Page);
    if Page <= TotalPages then Printer.NewPage;
  end;
  Printer.EndDoc;
end;

procedure TFPrint.UpdateButtons;
begin
  LTOPrint.Caption:='Pages To Print:'+IntToStr(pages-done);
  Progress.Progress:=Done;
  Progress.update;
end;
procedure TFPrint.FormActivate(Sender: TObject);
begin
  if (Mode=SINGLE) then Pages:=1;
  Done:=0;
  UpdateButtons;
  Progress.MinValue:=0;
  Progress.MaxValue:=Pages;
  BPrintSetup.Enabled:=true;
  BPrint.Enabled:=true;
end;

procedure TFPrint.BPrintSetupClick(Sender: TObject);
begin
  PrintSetup.Execute;
end;

procedure TFPrint.PrintFile(fn : String);
begin
  WinExec(pchar(PrintPath+' "'+fn+'"'),SW_Hide);
  inc(Done);
  Updatebuttons;
end;

procedure TFPrint.BPrintClick(Sender: TObject);
var Songs,Song,Links,Link : IXMLNode;
    i,j : integer;
    Reg : TRegistry;
    Names : TStringList;
    title : string;

begin
  if (Mode=MULTI) then if (params[4]='1') then begin
    if FMain.CBAll.Checked then title:='All Songs'
    else title:=FMain.CBLists.Text;
    PrintStringGrid(FMain.SGSongs, title+', Manual Version '+Main.ManVer,poLandscape);
  end;

  Names:=TStringList.create;
  Reg:=TRegistry.create;
  Reg.RootKey:=HKEY_CLASSES_ROOT;
  Reg.OpenKey('AcroExch.Document\shell\open\command',False);
  Reg.GetValueNames(Names);
  if Names.count=0 then begin
    PrintPath:='c:\Program Files\Adobe\Acrobat 5.0\Reader\AcroRd32.exe /p /h';
  end else begin
    PrintPath:=Reg.ReadString(Names[0])+' /p /h';
  end;
  Reg.Free;
  Names.Free;
  while (pos('"%1"',PrintPath)>0) do
    delete(PrintPath,pos('"%1"',PrintPath),4);
  if (mode=MULTI) then begin
    if ((params[1]='1') or (params[2]='1') or (params[3]='1')) then begin
      Songs:=Fmain.Xman.ChildNodes.FindNode('songs');
      for i:=1 to FMain.SGSongs.RowCount-1 do begin
        j:=0;
        repeat
          Song:=Songs.ChildNodes[j+2];
          inc(j);
        until Song.ChildValues['officeno']=FMain.OfficeNos[i];
        Links:=Song.ChildNodes['links'];
        for j:=0 to links.ChildNodes.Count-1 do begin
          Link:=links.childNodes[j];
          if (params[1]='1') then if (Link.ChildValues['type']='Chords') then
            PrintFile('Songs\Chords\'+Link.ChildValues['file']);
          if (params[2]='1') then if (Link.ChildValues['type']='Sheet') then
            PrintFile('Songs\Sheet\'+Link.ChildValues['file']);
          if (params[3]='1') then if (Link.ChildValues['type']='Article') then
            PrintFile('Songs\Article\'+Link.ChildValues['file']);
        end;
      end;
    end;
  end else begin
    PrintFile(filename);
  end;
  close;
end;

procedure TFPrint.FormCreate(Sender: TObject);
begin
  SINGLE:=1;
  MULTI:=0;
end;

end.
