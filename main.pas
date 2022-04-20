unit main;

interface

uses 
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, jpeg, ExtCtrls, StdCtrls, xmldom, XMLIntf, msxmldom,
  XMLDoc, oxmldom, shellapi, OleCtrls, Grids, Registry,
  CheckLst, ComObj, Sockets;

type
  TFMain = class(TForm)
    IHeader: TImage;
    IPic: TImage;
    XMan: TXMLDocument;
    LVersion: TLabel;
    CBLists: TComboBox;
    IChords: TImage;
    IMidi: TImage;
    ISheet: TImage;
    IArticle: TImage;
    IMP3: TImage;
    IWinAmp: TImage;
    IAdobe: TImage;
    SGSongs: TStringGrid;
    CLBPrint: TCheckListBox;
    IPrint: TImage;
    ESearch: TEdit;
    ISearch: TImage;
    IExit: TImage;
    IGChords: TImage;
    IGArticle: TImage;
    IGMidi: TImage;
    IGMP3: TImage;
    IGSheet: TImage;
    IPrintChords: TImage;
    IPrintSheet: TImage;
    IPrintArticle: TImage;
    IGPrintArticle: TImage;
    IGPrintSheet: TImage;
    IGPrintChords: TImage;
    IMinimise: TImage;
    IResetSearch: TImage;
    TcpClient: TTcpClient;
    IUpdate: TImage;
    IInstall: TImage;
    CBAll: TCheckBox;
    LShowAll: TLabel;
    procedure FormCreate(Sender: TObject);
    procedure LoadSongList(listno : integer);
    function GetFileName(OfficeNo,link : string) : string;
    procedure CBListsChange(Sender: TObject);
    procedure UpdateIcons();
    function GetSongForID(office : String) : IXMLNode;
    procedure SGSongsMouseUp(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure SGSongsKeyUp(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure ISheetClick(Sender: TObject);
    procedure IMP3Click(Sender: TObject);
    procedure IArticleClick(Sender: TObject);
    procedure IMidiClick(Sender: TObject);
    procedure IChordsClick(Sender: TObject);
    procedure IWinAmpClick(Sender: TObject);
    procedure FormActivate(Sender: TObject);
    procedure SGSongsMouseWheelDown(Sender: TObject; Shift: TShiftState;
      MousePos: TPoint; var Handled: Boolean);
    procedure SGSongsMouseWheelUp(Sender: TObject; Shift: TShiftState;
      MousePos: TPoint; var Handled: Boolean);
    procedure IPrintClick(Sender: TObject);
    procedure ISearchClick(Sender: TObject);
    function Squash(s : string) : string;
    function gt(s1 : String; s2 : String) : boolean;
    procedure IExitClick(Sender: TObject);
    procedure ESearchKeyPress(Sender: TObject; var Key: Char);
    procedure SGSongsKeyPress(Sender: TObject; var Key: Char);
    procedure IAdobeClick(Sender: TObject);
    procedure IPrintArticleClick(Sender: TObject);
    procedure IPrintChordsClick(Sender: TObject);
    procedure IPrintSheetClick(Sender: TObject);
    procedure ESearchClick(Sender: TObject);
    procedure IMinimiseClick(Sender: TObject);
    procedure IResetSearchClick(Sender: TObject);
    procedure IUpdateClick(Sender: TObject);
    procedure SortBy(c : integer);
    procedure IInstallClick(Sender: TObject);
    procedure CBAllClick(Sender: TObject);

  private
    { Private declarations }
  public
    ChordPrint : boolean;
    SheetPrint : boolean;
    ArticlePrint : boolean;
    ArticleCount : integer;
    ChordCount : integer;
    SheetCount : integer;
    ListName : String;
    OfficeNos : array of String;
    FirstSongDisplayed : longint;
    { Public declarations }
    OrderBy,Direction : byte;
    CurrentOfficeNo : String;
    SearchResults : array of string;
    icons : array[1..5] of boolean;

  end;

var
  FMain: TFMain;
  FirstTime : boolean;
  debugFile : string;
  ManVer : string;
  lockEvents : integer;
  updateserver : string;
  updatedir : string;
                   
const SoftwareVersion : String = '2.44';
      IconOrigDim : real = 62.5;
      v_year : String='2022';

implementation

uses bfreeprint, update, Install;

{$R *.dfm}

function TFMain.Squash(s : string) : string;
var t,c : string;
    i : integer;
begin
  t:='';
  for i:=1 to length(s) do begin
    c:=uppercase(s[i]);
    if ((c>='A') and (c<='Z')) or ((c>='0') and (c<='9')) then t:=t+c;
  end;
  Squash:=t;
end;

function TFMain.gt(s1 : String; s2 : String) : boolean;
begin
  gt:=(squash(s1)>squash(s2));
end;

procedure TFMain.LoadSongList(listno : integer);
var i,j,k : integer;
    Links,SongsNode,Link,Song,List : IXmlNode;
    AltTitle,Title,OfficeNo,Author,Date,Copyright : string;
    KeepList : TStringlist;

begin
  k:=0;
  SheetCount:=0;
  ChordCount:=0;
  ArticleCount:=0;
  SongsNode:=XMan.ChildNodes['songs'];
  setlength(OfficeNos,0);
  KeepList:=TStringList.create;
  if (not CBAll.checked) then begin
    List:=SongsNode.ChildNodes['lists'].ChildNodes[listno].ChildNodes['ids'];
    for i:=0 to List.ChildNodes.Count-1 do
      KeepList.Add(list.ChildNodes[i].NodeValue);
    SGSongs.RowCount:=KeepList.Count+1;
  end else SGSongs.RowCount:=SongsNode.ChildNodes.Count-1;
  if (SGSongs.RowCount>1) then begin
    SGSongs.FixedRows:=1;
    for i:=2 to SongsNode.ChildNodes.Count-1 do begin
      Song:=SongsNode.ChildNodes[i];
      if Song.nodename='song' then begin
        OfficeNo:=Song.ChildValues['officeno'];
        if (CBAll.Checked) or ((not CBAll.Checked) and (KeepList.IndexOf(OfficeNo)>=0)) then begin
          inc(k);
          Title:=Song.ChildValues['title'];
          AltTitle:=''; Author:=''; Date:=''; Copyright:='';
          if Song.GetChildValue('alttitle')<>null then AltTitle:=Song.GetChildValue('alttitle');
          if Song.GetChildValue('author')<> null then author:=Song.GetChildValue('author');
          if Song.GetChildValue('copdate')<> null then date:=Song.GetChildValue('copdate');
          if Song.GetChildValue('copyright')<> null then copyright:=Song.GetChildValue('copyright');
          SGSongs.Cells[0,k]:=Title;
          SGSongs.Cells[1,k]:=AltTitle;
          SGSongs.Cells[2,k]:=Author;
          SGSongs.Cells[3,k]:=Date;
          SGSongs.Cells[4,k]:=Copyright;
          if length(officeNos)<=k then setlength(OfficeNos,k+1);
          OfficeNos[k]:=OfficeNo;
          Links:=Song.ChildNodes['links'];
          j:=0;
          while (j<Links.ChildNodes.Count) do begin
            Link:=Links.ChildNodes.get(j);
            if uppercase(Link.ChildValues['type'])='SHEET' then inc(SheetCount);
            if uppercase(Link.ChildValues['type'])='CHORDS' then inc(ChordCount);
            if uppercase(Link.ChildValues['type'])='ARTICLE' then inc(ArticleCount);
            inc(j);
          end;
          if (not CBAll.checked) then begin
            KeepList.Delete(KeepList.IndexOf(OfficeNo));
          end;                 
        end;
      end;
    end;
    SGSongs.Row:=1;
    if (length(OfficeNos)>=1) then CurrentOfficeNo:=OfficeNos[1];
  end;
  KeepList.Free;
  UpdateIcons;
end;

procedure TFMain.FormCreate(Sender: TObject);
var WS : real;
    Attrs : integer;
begin
  lockEvents:=0;
  FirstTime:=true;
  if (fileexists('bfree.old')) then deletefile('bfree.old');
  if (fileexists('bfree.tmp')) then deletefile('bfree.tmp');
  debugFile:='';
  updateserver:='https://www.teapotrecords.co.uk';
  updatedir:='bfree';

  if (paramstr(1)='/debugwes') or (paramstr(1)='/DEBUGWES') then begin
    chdir('C:\Program Files\BFree');
  end;

  WS:=Screen.width/1280;
  OrderBy:=0;
  Direction:=0;
  SheetPrint:=false;
  ChordPrint:=false;
  ListName:='All Documents';
  FMain.width:=Screen.width;
  FMain.height:=Screen.height;
  IHeader.Picture.LoadFromFile('images/header.jpg');
  IHeader.width:=Screen.width;
  IHeader.height:=trunc(100*WS);
  IHeader.top:=0;
  IHeader.left:=0;
  IMP3.Picture.LoadFromFile('images/mp3.jpg');
  IMidi.Picture.LoadFromFile('images/midi.jpg');
  ISheet.Picture.LoadFromFile('images/sheet.jpg');
  IChords.Picture.LoadFromFile('images/chords.jpg');
  IArticle.Picture.LoadFromFile('images/article.jpg');
  IGMP3.Picture.LoadFromFile('images/_mp3.jpg');
  IGMidi.Picture.LoadFromFile('images/_midi.jpg');
  IGSheet.Picture.LoadFromFile('images/_sheet.jpg');
  IGChords.Picture.LoadFromFile('images/_chords.jpg');
  IGArticle.Picture.LoadFromFile('images/_article.jpg');
  IPrintChords.Picture.LoadFromFile('images/sprinter.jpg');
  IPrintArticle.Picture.LoadFromFile('images/sprinter.jpg');
  IPrintSheet.Picture.LoadFromFile('images/sprinter.jpg');
  IGPrintChords.Picture.LoadFromFile('images/_sprinter.jpg');
  IGPrintArticle.Picture.LoadFromFile('images/_sprinter.jpg');
  IGPrintSheet.Picture.LoadFromFile('images/_sprinter.jpg');
  IAdobe.Picture.LoadFromFile('images/adobe.jpg');
  IUpdate.Picture.LoadFromFile('images/update.jpg');
  if (fileexists('images/install.jpg')) then IInstall.Picture.LoadFromFile('images/install.jpg');
  IWinAmp.Picture.LoadFromFile('images/winamp.jpg');
  IPrint.Picture.LoadFromFile('images/print.jpg');
  ISearch.Picture.LoadFromFile('images/search.jpg');
  IResetSearch.Picture.LoadFromFile('images/resetsearch.jpg');
  IExit.Picture.LoadFromFile('images/newexit.jpg');
  IMinimise.Picture.LoadFromFile('images/minimise.jpg');
  IMinimise.Width:=trunc(21*WS);
  IMinimise.Height:=trunc(24*WS);
  IMinimise.Left:=trunc((Screen.width-Iminimise.Width)-(10*Ws));
  IMinimise.Top:=trunc(10*ws);

  IMP3.Width:=trunc(IconOrigDim*WS);
  IWinAmp.Width:=IMP3.Width;
  IAdobe.Width:=IMP3.Width;
  IWinamp.Height:=IMP3.Width;
  IAdobe.Height:=IMP3.Width;
  IMP3.Hint:='Play MP3';
  ISheet.Hint:='Display Sheet Music';
  IMidi.Hint:='Play MIDI file';
  IArticle.Hint:='Display article';
  IChords.Hint:='Display words and chords';
  IGMP3.Hint:='No MP3 for this song';
  IGSheet.Hint:='No Sheet Music for this song';
  IGMidi.Hint:='No MIDI file for this song';
  IGArticle.Hint:='No article for this song';
  IGChords.Hint:='No words and chords for this song';
  IGPrintChords.Hint:='No words and chords for this song';
  IGPrintArticle.Hint:='No article for this song';
  IGPrintSheet.Hint:='No sheet music for this song';
  IPrintChords.Hint:='Print words and chords';
  IPrintArticle.Hint:='Print article';
  IPrintSheet.Hint:='Print sheet music';
  IInstall.Hint:='Install onto hard drive (enables online update)';
  IUpdate.Hint:='Check for online updates';


  IMIdi.Width:=IMP3.Width;
  ISheet.Width:=IMP3.Width;
  IChords.Width:=IMP3.Width;
  IArticle.Width:=IMP3.Width;

  IGMp3.Width:=IMP3.Width;
  IGSheet.Width:=IMP3.Width;
  IGMIdi.Width:=IMP3.Width;
  IGSheet.Width:=IMP3.Width;
  IGChords.Width:=IMP3.Width;
  IGArticle.Width:=IMP3.Width;
  IGArticle.Height:=IMP3.Width;
  IGMIdi.Height:=IMP3.Width;
  IGSheet.Height:=IMP3.Width;
  IGChords.Height:=IMP3.Width;
  IGMP3.Height:=IMP3.Width;
  IPrintChords.Width:=IMP3.Width div 2;
  IPrintArticle.Width:=IPrintChords.width;
  IPrintSheet.Width:=IPrintChords.width;
  IPrintChords.Height:=IPrintChords.width;
  IPrintArticle.Height:=IPrintChords.width;
  IPrintSheet.Height:=IPrintChords.width;
  IGPrintChords.Width:=IPrintChords.width;
  IGPrintArticle.Width:=IPrintChords.width;
  IGPrintSheet.Width:=IPrintChords.width;
  IGPrintChords.Height:=IPrintChords.width;
  IGPrintArticle.Height:=IPrintChords.width;
  IGPrintSheet.Height:=IPrintChords.width;
  IArticle.Height:=IMP3.Width;
  IMIdi.Height:=IMP3.Width;
  ISheet.Height:=IMP3.Width;
  IChords.Height:=IMP3.Width;
  IMP3.Height:=IMP3.Width;
  IPic.Picture.LoadFromFile('images/backdrop.jpg');
  IPic.width:=Screen.width;
  IPic.height:=trunc(750*WS);
  IPic.top:=IHeader.Height+trunc(IconOrigDim*WS);
  IPic.left:=0;
  IChords.Top:=IPic.Top-trunc(30*WS);
  ISheet.Top:=IChords.Top;
  IMP3.Top:=IChords.Top;
  IArticle.Top:=IChords.Top;
  IMidi.Top:=IChords.Top;
  IGChords.Top:=IChords.Top;
  IGSheet.Top:=IChords.Top;
  IGMP3.Top:=IChords.Top;
  IGArticle.Top:=IChords.Top;
  IGMidi.Top:=IChords.Top;
  SGSongs.Top:=IPic.top+trunc(100*WS);
  SGSongs.Width:=Screen.width-trunc(120*WS);
  SGSongs.Left:=trunc((Screen.width/2)-(SGSongs.width/2));
  SGSongs.Height:=Screen.height-trunc(406*WS);
  IAdobe.Top:=SGSongs.Top+SGSongs.Height+trunc(15*WS);
  IWinAmp.Top:=IAdobe.top;
  IWinAmp.Left:=SGSongs.Left;
  IAdobe.Left:=IWinAmp.Left+IWinAmp.Width+trunc(10*WS);
  IUpdate.Left:=IAdobe.Left+IWinAmp.Width+trunc(10*WS);
  if (not fileexists('Apps\winamp30.exe')) then begin
    IWinAmp.Visible:=false;
    IUpdate.Left:=IAdobe.Left;
    IInstall.Left:=IAdobe.Left;
    IAdobe.Left:=IWinAmp.Left;
  end;

  if (not fileexists('Apps\acrobat601.exe')) then begin
    IAdobe.Visible:=false;
    IUpdate.Left:=IAdobe.Left;
    IInstall.left:=IAdobe.left;
  end;


  IChords.Left:=SGSongs.Left+SGSongs.Width-IChords.Width;
  ISheet.Left:=(IChords.Left-ISheet.Width)-trunc(10*WS);
  IArticle.Left:=(ISheet.Left-IArticle.Width)-trunc(10*WS);
  IMidi.Left:=(IArticle.Left-IMidi.Width)-trunc(10*WS);
  IMP3.Left:=(IMidi.Left-IMP3.Width)-trunc(10*WS);
  IPrintArticle.Left:=IArticle.Left+IGPrintChords.Width;
  IPrintChords.Left:=IChords.left+IGPrintChords.Width;
  IPrintSheet.Left:=ISheet.left+IGPrintChords.Width;
  IGPrintArticle.Left:=IArticle.left+IGPrintChords.Width;
  IGPrintChords.Left:=IChords.left+IGPrintChords.Width;
  IGPrintSheet.Left:=ISheet.left+IGPrintChords.Width;
  IGChords.Left:=IChords.left;
  IGArticle.Left:=IArticle.left;
  IGMidi.Left:=IMidi.left;
  IGMP3.Left:=IMP3.left;
  IGSheet.Left:=ISheet.left;
  IArticle.Visible:=true;
  IMP3.Visible:=true;
  IMidi.Visible:=true;
  ISheet.Visible:=true;
  IChords.Visible:=true;
  IGArticle.Visible:=true;
  IGChords.Visible:=true;
  IGSheet.Visible:=true;
  IGMidi.Visible:=true;
  IGMP3.Visible:=true;
  IGMP3.bringtoFront;
  IGArticle.BringToFront;
  IGChords.BringToFront;
  IGSheet.BringToFront;
  IGMidi.BringToFront;
  IPrintChords.Top:=iChords.top+IChords.height+trunc(5*WS);
  IPrintSheet.Top:=IPrintChords.top;
  IPrintArticle.Top:=IPrintChords.top;
  IGPrintChords.Top:=IPrintChords.top;
  IGPrintSheet.Top:=IPrintChords.top;
  IGPrintArticle.Top:=IPrintChords.top;
  LVersion.Font.Size:=trunc(10*WS);
  LVersion.Left:=trunc((Screen.width/2)-(LVersion.width/2));
  LVersion.Top:=Screen.Height-(LVersion.Height+1);
  CBLists.width:=trunc(250*WS);
  CBLists.Left:=trunc((Screen.Width/2)-(CBLists.Width/2));
  CBLists.top:=IPic.Top-trunc(35*WS);
  CBLists.font.size:=trunc(14*WS);

  LShowAll.font.size:=trunc(14*WS);
  LShowAll.width:=trunc(133*WS);

  LShowAll.left:=(trunc(Screen.Width/2)-trunc(LShowAll.Width/2))-6;
  LShowAll.top:=IPic.top+trunc(5*WS);


  CBAll.width:=14;
  CBAll.Height:=16;
  CBAll.top:=IPic.top+trunc(10*WS);
  CBAll.left:=LShowAll.left+LShowAll.width+12;

  CLBPrint.ItemHeight:=trunc(23*WS);
  CLBPrint.font.size:=trunc(12*WS);
  CLBPrint.top:=CBLists.Top;
  CLBPrint.Left:=SgSongs.left;
  CLBPrint.width:=CBLists.width;
  CLBPrint.Height:=trunc(96*WS);

  IPrint.Width:=CLBPrint.Height;
  IPrint.Height:=IPrint.Width;
  IPrint.Top:=CBLists.Top;
  IPrint.left:=CLBPRint.Left+CLBPrint.Width+trunc(10*WS);
  ISearch.width:=trunc(31*WS);
  IResetSearch.width:=ISearch.width;
  ISearch.height:=ISearch.width;
  IResetSearch.height:=ISearch.height;
  ESearch.height:=ISearch.height;
  SGSongs.visible:=false;
  SGSongs.cells[0,0]:='Title';
  SGSongs.cells[1,0]:='Alternative Title';
  SGSongs.cells[2,0]:='Author';
  SGSongs.cells[3,0]:='Date';
  SGSongs.cells[4,0]:='Copyright';
  SGSongs.ColWidths[0]:=trunc(SGSongs.Width/5);
  SGSongs.ColWidths[1]:=trunc(SGSongs.Width/5);
  SGSongs.ColWidths[2]:=trunc(SGSongs.Width/5);
  SGSongs.ColWidths[3]:=trunc(SGSongs.Width/12);
  SGSongs.ColWidths[4]:=trunc(SGSongs.Width/3.4);
  ESearch.Left:=SGSongs.left;
  ESearch.Top:=IPrint.Top+IPrint.height+trunc(10*WS);
  ESearch.Width:=CLBPrint.Width+IPrint.Width+trunc(10*WS)-ISearch.Width;
  ISearch.Left:=ESearch.Left+Esearch.Width;
  ISearch.top:=ESearch.top;
  IResetSearch.Top:=ESearch.top;
  IResetSearch.Left:=ISearch.Left+ISearch.width;

  IExit.Width:=trunc(IconOrigDim*WS);
  IExit.Height:=trunc(IconOrigDim*WS);
  IExit.Top:=SGSongs.top+SGSongs.height+trunc(15*WS);
  IExit.Left:=SGSongs.Left+SGSongs.Width-IExit.Width;
  IUpdate.Width:=trunc(IconOrigDim*WS);
  IUpdate.Height:=trunc(IconOrigDim*WS);
  IInstall.Width:=IUpdate.Width;
  IInstall.Height:=IUpdate.Height;

  Attrs := FileGetAttr('Songs\man.xml');
  if (Attrs and faReadOnly>0) and (FileExists('Songs\man.xml')) then begin
    IInstall.Visible:=true;
    IUpdate.Visible:=false;
  end else begin
    IUpdate.Visible:=true;
    IInstall.Visible:=false;
  end;

  IUpdate.Top:=SGSongs.top+SGSongs.height+trunc(15*WS);
  IInstall.Top:=IUpdate.Top;
  IInstall.Left:=IUpdate.Left;
  ESearch.Font.Size:=trunc(14*WS);

end;

procedure TFMain.CBListsChange(Sender: TObject);
var i : integer;
    Song : IXMLNode;
    Title,AltTitle,Author,Date,Copyright : string;
begin
  if (CBLists.ItemIndex<CBLists.Items.Count-1) or (CBAll.checked) then LoadSongList(CBLists.ItemIndex) else begin
    SGSongs.RowCount:=1+length(SearchResults);
    for i:=0 to length(SearchResults)-1 do begin
      Song:=GetSongForId(SearchResults[i]);
      Title:=Song.ChildValues['title'];
      AltTitle:=''; Author:=''; Date:=''; Copyright:='';
        if Song.GetChildValue('alttitle')<>null then AltTitle:=Song.GetChildValue('alttitle');
        if Song.GetChildValue('author')<> null then author:=Song.GetChildValue('author');
        if Song.GetChildValue('copdate')<> null then date:=Song.GetChildValue('copdate');
        if Song.GetChildValue('copyright')<> null then copyright:=Song.GetChildValue('copyright');
      SGSongs.Cells[0,i+1]:=Title;
      SGSongs.Cells[1,i+1]:=AltTitle;
      SGSongs.Cells[2,i+1]:=Author;
      SGSongs.Cells[3,i+1]:=Date;
      SGSongs.Cells[4,i+1]:=Copyright;
      OfficeNos[i+1]:=SearchResults[i];
    end;
  end;
  SGSongs.SetFocus;
  UpdateIcons;  
end;

function TFMain.GetFileName(OfficeNo,link : string) : string;
var SongNode,LinksNode,LinkNode : IXMLNode;
    sorted : boolean;
    i : integer;
    s : string;
begin
  SongNode:=GetSongForID(OfficeNo);
  LinksNode:=SongNode.ChildNodes['links'];
  sorted:=false;
  i:=0;
  while (not sorted) do begin
    LinkNode:=LinksNode.ChildNodes[i];
    if (LinkNode.ChildValues['type']=link) then sorted:=true;
    inc(i);
  end;
  s:=LinkNode.ChildValues['file'];
  GetFileName:=s;
end;


function TFMain.GetSongForID(office : String) : IXMLNode;
var sorted : boolean;
    i : integer;
    SongsNode,SongNode : IXMLNode;
    S : string;
begin
  SongNode:=nil;
  i:=1;
  SongsNode:=XMan.ChildNodes['songs'];
  sorted:=false;
  repeat
    if (i<SongsNode.ChildNodes.Count) then begin
      SongNode:=SongsNode.ChildNodes[i];
      if (SongNode.nodeName='song') then begin
        s:=SongNode.ChildValues['officeno'];
        sorted:=(SongNode.ChildValues['officeno']=office);
      end else SongNode:=nil;
      inc(i);
    end;
  until sorted or (i>=SongsNode.ChildNodes.Count);
  GetSongForID:=SongNode;
end;

procedure TFMain.UpdateIcons();
var SongNode,LinksNode,LinkNode : IXMLNode;
    i : integer;
    MP3Type,MidiType,SheetType,ChordType,ArtType : boolean;
begin
  SongNode:=GetSongForId(CurrentOfficeNo);
  MP3Type:=false;
  MidiType:=false;
  SheetType:=false;
  ChordType:=false;
  ArtType:=false;

  if (SongNode<>nil) then begin
    LinksNode:=SongNode.ChildNodes['links'];
    i:=0;
    while (i<LinksNode.ChildNodes.Count) do begin
      LinkNode:=LinksNode.ChildNodes[i];
      if (LinkNode.ChildValues['type']='MP3') then Mp3Type:=true;
      if (LinkNode.ChildValues['type']='Midi') then MidiType:=true;
      if (LinkNode.ChildValues['type']='Chords') then ChordType:=true;
      if (LinkNode.ChildValues['type']='Article') then ArtType:=true;
      if (LinkNode.ChildValues['type']='Sheet') then SheetType:=true;
      inc(i);
    end;
  end;
  if Mp3Type and (not icons[5]) then begin
    IMP3.BringToFront;
    icons[5]:=true;
  end else if (not MP3Type) and (icons[5]) then begin
    icons[5]:=false;
    IGMP3.BringToFront;
  end;
  if MidiType and (not icons[4]) then begin
    IMidi.BringToFront;
    icons[4]:=true;
  end else if (not MidiType) and (icons[4]) then begin
    IGMidi.BringToFront;
    icons[4]:=false;
  end;
  if SheetType and (not icons[3]) then begin
    ISheet.BringToFront;
    IPrintSheet.BringToFront;
    icons[3]:=true;
  end else if (not SheetType) and (icons[3]) then begin
    IGSheet.BringToFront;
    IGPrintSheet.BringToFront;
    icons[3]:=false;
  end;
  if ArtType and (not icons[2]) then begin
    IArticle.BringToFront;
    IPrintArticle.BringToFront;
    icons[2]:=true;
  end else if (not ArtType) and (icons[2]) then begin
    IGArticle.BringToFront;
    IGPrintArticle.BringToFront;
    icons[2]:=false;
  end;
  if ChordType and (not icons[1])then begin
    IChords.BringToFront;
    IPrintChords.BringToFront;
    icons[1]:=true;
  end else if (not ChordType) and icons[1] then begin
    IGChords.BringToFront;
    IGPrintChords.BringToFront;
    icons[1]:=false;
  end;
end;

procedure TFMain.SortBy(c : integer);
var i,index,j,k,l : integer;
    temp : string;
    sorted : boolean;
begin
  // Top row clicked.
  if (OrderBy=c) then Direction:=1-Direction;
  OrderBy:=c;
  for i:=1 to SGSongs.RowCount-1 do begin
    index:=i;
    for j:=i+1 to SGSongs.RowCount-1 do begin
      if (gt(SGSongs.cells[OrderBy,j],SGSongs.cells[OrderBy,index])) and (direction=1) then index:=j;
      if (not (gt(SGSongs.cells[OrderBy,j],SGSongs.cells[OrderBy,index]))) and (direction=0) then index:=j;
    end;
    for j:=0 to 4 do begin
      temp:=SGSongs.cells[j,index];
      SGSongs.cells[j,index]:=SGSongs.cells[j,i];
      SGSongs.cells[j,i]:=temp;
    end;
    temp:=OfficeNos[index];
    OfficeNos[index]:=OfficeNos[i];
    OfficeNos[i]:=temp;
  end;
  i:=0;
  while (i<SGSongs.RowCount-2) do begin
    inc(i);
    if (SGSongs.cells[OrderBy,i]=SGSongs.cells[OrderBy,i+1]) then begin
      j:=i+2;
      while (SGSongs.cells[OrderBy,j]=SGSongs.cells[OrderBy,i]) and (j<SGSongs.RowCount) do inc(j);
      dec(j);
      repeat
        sorted:=true;
        for k:=i to j-1 do begin
          if gt(SGSongs.cells[0,k],SGSongs.cells[0,k+1]) then begin
            for l:=0 to 4 do begin
              temp:=SGSongs.cells[l,k];
              SGSongs.cells[l,k]:=SGSongs.cells[l,k+1];
              SGSongs.cells[l,k+1]:=temp;
            end;
            temp:=OfficeNos[k];
            OfficeNos[k]:=OfficeNos[k+1];
            OfficeNos[k+1]:=temp;
            sorted:=false;
          end;
        end;
      until sorted=true;
      i:=j+1;
    end;
  end;
end;

procedure TFMain.SGSongsMouseUp(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
var rc,cc,r,c,i : integer;

begin
  if (SGSongs.RowCount>1) then begin
    Screen.cursor:=crHourGlass;
    rc:=0; i:=0;
    while (rc<y) do begin
      rc:=rc+SGSongs.RowHeights[i];
      inc(i);
    end;
    r:=i-1;
    cc:=0; i:=0;
    while (cc<x) do begin
      cc:=cc+SGSongs.ColWidths[i];
      inc(i);
    end;
    c:=i-1;

  // Now r,c is row and column starting from 0.

    if (r=0) then SortBy(c);
    r:=SGSongs.Selection.Top;
    CurrentOfficeNo:=OfficeNos[r];
    UpdateIcons;
    Screen.cursor:=crArrow;
  end;
  SGSongs.update;
  UpdateIcons;
end;


procedure TFMain.SGSongsKeyUp(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
  if (SGSongs.RowCount>1) then begin
    CurrentOfficeNo:=OfficeNos[SGSongs.Selection.Top];
    UpdateIcons;
    if (Key=VK_RETURN) then begin
      if icons[1] then IChordsClick(Sender) else
      if icons[5] then IMP3Click(Sender) else
      if icons[4] then IMidiClick(Sender) else
      if icons[2] then ISheetClick(Sender) else
      if icons[3] then IArticleClick(Sender);
    end;
  end;
end;

procedure TFMain.ISheetClick(Sender: TObject);
begin
  ShellExecute(Application.Handle,nil,pchar('Songs\Sheet\'+GetFileName(CurrentOfficeNo,'Sheet')),nil,nil,SW_Show);
end;

procedure TFMain.IMP3Click(Sender: TObject);
var s : string;
begin
  s:=GetFileName(CurrentOfficeNo,'MP3');
  if ((uppercase(copy(s,1,7))='HTTP://') or (uppercase(copy(s,1,8))='HTTPS://')) then begin
    ShellExecute(Application.Handle,nil,pchar(s),nil,nil,SW_Show);
  end else begin
    ShellExecute(Application.Handle,nil,pchar('Songs\MP3\'+s),nil,nil,SW_Show);
  end;
end;

procedure TFMain.IArticleClick(Sender: TObject);
begin
  ShellExecute(Application.Handle,nil,pchar('Songs\Article\'+GetFileName(CurrentOfficeNo,'Article')),nil,nil,SW_Show);
end;

procedure TFMain.IMidiClick(Sender: TObject);
begin
  ShellExecute(Application.Handle,nil,pchar('Songs\Midi\'+GetFileName(CurrentOfficeNo,'Midi')),nil,nil,SW_Show);
end;

procedure TFMain.IChordsClick(Sender: TObject);
begin
  ShellExecute(Application.Handle,nil,pchar('Songs\Chords\'+GetFileName(CurrentOFficeNo,'Chords')),nil,nil,SW_SHOw);
end;

procedure TFMain.IWinAmpClick(Sender: TObject);
begin
  ShellExecute(Application.Handle,nil,pchar('Apps\WinAmp30.exe'),nil,nil,SW_SHOw);
end;

procedure initialise();
var F : TextFile;
begin
  if (not DirectoryExists('songs')) then mkdir('songs');
  if (not DirectoryExists('songs\Article')) then mkdir('songs\Article');
  if (not DirectoryExists('songs\Chords')) then mkdir('songs\Chords');
  if (not DirectoryExists('songs\Midi')) then mkdir('songs\Midi');
  if (not DirectoryExists('songs\MP3')) then mkdir('songs\MP3');
  if (not DirectoryExists('songs\Sheet')) then mkdir('songs\Sheet');
  if (not FileExists('songs\man.xml')) then begin
    assignfile(F,'songs\man.xml');
    rewrite(F);
    writeln(F,'<?xml version="1.0" encoding="UTF-8"?><songs><version>A0</version><lists></lists></songs>');
    flush(F);
    closeFile(F);
  end;

end;


procedure TFMain.FormActivate(Sender: TObject);
var i : byte;
    ListsTag,ListTag : IXMLNode;
begin
  initialise();
  lockEvents:=0;
  XMan.LoadFromFile('Songs\man.xml');
  ManVer:=XMan.ChildNodes['songs'].ChildValues['version'];
  LVersion.Caption:='BFree Manual © '+v_year+' Teapot Records. Software '+debugFile+'v'+  SoftwareVersion+', Manual v'+XMan.ChildNodes['songs'].ChildValues['version']+'. All Rights Reserved';
  CBLists.Items.Clear;
  inc(lockEvents);
  CBAll.Checked:=true;
  CBLists.Enabled:=false;
  ListsTag:=XMan.ChildNodes['songs'].ChildNodes['lists'];
  i:=0;
  while (i<ListsTag.ChildNodes.count) do begin
    ListTag:=ListsTag.ChildNodes[i];
    CBLists.Items.Add(ListTag.ChildValues['name']);
    inc(i);
  end;
  LoadSongList(0);
  CBLists.Items.Add('Search Results');
  CBLists.ItemIndex:=0;
  dec(lockEvents);
  FUpdate.LSoftVer.Caption:=SoftwareVersion;
  FUPdate.LDatVer.Caption:=XMan.ChildNodes['songs'].ChildValues['version'];
  for i:=1 to 5 do icons[i]:=false;
  FMain.Update;
  SGSongs.Visible:=true;
  SGSongs.setFocus();
  if (paramstr(1)='/U') and (firsttime) then begin
    firsttime:=false;
    IUpdateClick(Sender);
  end;
  updateIcons;

end;

procedure TFMain.SGSongsMouseWheelDown(Sender: TObject; Shift: TShiftState;
  MousePos: TPoint; var Handled: Boolean);

begin
  if SGSongs.Selection.Top<Sgsongs.RowCount-2 then begin
    CurrentOfficeNo:=OfficeNos[SGSongs.Selection.Top+1];
    UpdateIcons;
  end;
end;

procedure TFMain.SGSongsMouseWheelUp(Sender: TObject; Shift: TShiftState;
  MousePos: TPoint; var Handled: Boolean);
begin
  if SGSongs.Selection.Top>1 then begin
    CurrentOfficeNo:=OfficeNos[SGSongs.Selection.Top-1];
    UpdateIcons;
  end;
end;

procedure TFMain.IPrintClick(Sender: TObject);
var SongsShown,TotalPages,SongsPerPage : integer;
begin
  SongsShown:=SGSongs.RowCount-1;
  SongsPerPage:=48;
  TotalPages:=0;
  FPrint.Mode:=FPrint.MULTI;
  FPrint.params:='0000';
  if (CLBPrint.Checked[0]) then begin FPrint.params[1]:='1'; TotalPages:=TotalPages+ChordCount; end;
  if (CLBPrint.Checked[1]) then begin FPrint.params[2]:='1'; TotalPages:=TotalPages+SheetCount; end;
  if (CLBPrint.Checked[2]) then begin FPrint.params[3]:='1'; TotalPages:=TotalPages+ArticleCount; end;
  if (CLBPrint.Checked[3]) then begin FPrint.params[4]:='1'; TotalPages:=(SongsShown div SongsPerPage);
    if (SongsShown mod SongsPerPage>0) then inc(TotalPages);
  end;
  FPrint.pages:=TotalPages;
  if TotalPages=0 then
    messagedlg('Nothing to print! Select chords/sheet/articles',mtError,[mbOk],0)
  else FPrint.ShowModal;
end;

procedure TFMain.ISearchClick(Sender: TObject);
var FoundList : array of string;
    i : integer;
    SongNode : IXMLNode;
    SongsNode : IXMLNode;
    Title,AltTitle,Author,CopDate,Copyright,remember,srch : string;
    count : integer;
    lyric : widestring;
    inList : boolean;
    ilCount : integer;
    getID : shortstring;
begin
  if (SGSongs.RowCount>1) then begin
  Screen.cursor:=crHourGlass;
  count:=0;
  setLength(FoundList,SGSongs.RowCount-1);
  srch:=squash(ESearch.text);
  remember:=ESearch.text;
  SGSongs.RowCount:=2;
  SongsNode:=Xman.ChildNodes['songs'];
  for i:=2 to SongsNode.ChildNodes.Count-1 do begin
    getID:=SongsNode.ChildNodes[i].ChildValues['officeno'];
    inList:=false;
    ilCount:=1;
    while (ilCount<length(OfficeNos)) and (not inList) do begin
      inList:=(OfficeNos[ilCount]=GetID);
      inc (ilCount);
    end;
    if inList then begin
    SongNode:=SongsNode.ChildNodes[i];
    ESearch.text:='Searching...'+IntToStr((i*100 div (length(OfficeNos)-1)))+'%';
    ESearch.update;

    lyric:=SongNode.ChildValues['text'];
    if pos(srch,lyric)>0 then begin
      foundList[count]:=GetID;
      inc(count);
      SGSongs.RowCount:=count+1;
      Title:=SongNode.ChildValues['title'];
      AltTitle:=''; Author:=''; CopDate:=''; Copyright:='';
      if SongNode.GetChildValue('alttitle')<>null then AltTitle:=SongNode.GetChildValue('alttitle');
      if SongNode.GetChildValue('author')<> null then author:=SongNode.GetChildValue('author');
      if SongNode.GetChildValue('copdate')<> null then copdate:=SongNode.GetChildValue('copdate');
      if SongNode.GetChildValue('copyright')<> null then copyright:=SongNode.GetChildValue('copyright');
      SGSongs.Cells[0,count]:=Title;
      SGSongs.Cells[1,count]:=AltTitle;
      SGSongs.Cells[2,count]:=Author;
      SGSongs.Cells[3,count]:=CopDate;
      SGSongs.Cells[4,count]:=Copyright;
      SGSongs.update;
      end;
    end;
  end;
  if count=0 then begin
    SGSongs.RowCount:=1;
    IGMidi.BringToFront;
    IGChords.BringToFront;
    IGSheet.BringToFront;
    IGArticle.BringToFront;
    IGMP3.BringToFront;
    IGPrintArticle.BringToFront;
    IGPrintSheet.BringToFront;
    IGPrintChords.BringToFront;
    Icons[1]:=false;
    Icons[2]:=false;
    Icons[3]:=false;
    Icons[4]:=false;
    Icons[5]:=false;
  end else begin
    setlength(officenos,count+1);
    for i:=0 to count-1 do officenos[i+1]:=foundlist[i];
    SGSongs.FixedRows:=1;
    setlength(SearchResults,SGSongs.RowCount-1);
    for i:=1 to SGSongs.RowCount-1 do SearchResults[i-1]:=OfficeNos[i];
    SGSongs.Row:=1;
    CurrentOfficeNo:=OfficeNos[1];
    UpdateIcons();
  end;
  ESearch.texT:=remember;
  CBLists.ItemIndex:=CBLists.Items.Count-1;
  Screen.cursor:=crArrow;
end;
end;

procedure TFMain.IExitClick(Sender: TObject);
begin
  close;
end;

procedure TFMain.ESearchKeyPress(Sender: TObject; var Key: Char);
begin
   if Key=chr(13) then begin Key:=#0; ISearchClick(Sender); end;
end;

procedure TFMain.SGSongsKeyPress(Sender: TObject; var Key: Char);
var i : integer;
    theSelection : TGridRect;
begin
  if (uppercase(Key)>='A') and (uppercase(Key)<='Z') then begin
    i:=1;
    while ((SgSongs.Cells[0,i]<uppercase(Key)) and (i<SGSongs.RowCount-1)) do inc(i);

    theSelection.top:=i;
    theSelection.bottom:=i;
    theSelection.left:=0;
    theSelection.Right:=4;
    SGSongs.Selection:=theSelection;
    SGSongs.TopRow:=i;
    SGSongs.Update;

  end;
end;

procedure TFMain.IAdobeClick(Sender: TObject);
begin
  ShellExecute(Application.Handle,nil,pchar('Apps\Acrobat601.exe'),nil,nil,SW_SHOw);
end;

procedure TFMain.IPrintArticleClick(Sender: TObject);
begin
  FPrint.mode:=FPrint.SINGLE;
  FPrint.FileName:='Songs\Article\'+GetFileName(CurrentOfficeNo,'Article');
  FPrint.showModal;
end;

procedure TFMain.IPrintChordsClick(Sender: TObject);
begin
  FPrint.mode:=FPrint.SINGLE;
  FPrint.FileName:='Songs\Chords\'+GetFileName(CurrentOfficeNo,'Chords');
  FPrint.showModal;
end;

procedure TFMain.IPrintSheetClick(Sender: TObject);
begin
  FPrint.mode:=FPrint.SINGLE;
  FPrint.FileName:='Songs\Sheet\'+GetFileName(CurrentOfficeNo,'Sheet');
  FPrint.showModal;
end;

procedure TFMain.ESearchClick(Sender: TObject);
begin
  ESearch.SelectAll;
end;

procedure TFMain.IMinimiseClick(Sender: TObject);
begin
  Application.minimize;
end;

procedure TFMain.IResetSearchClick(Sender: TObject);
begin
  if (CBLists.ItemIndex<>0) then begin
    CBLists.ItemIndex:=0;
    CBListsChange(Sender);
  end;
end;


procedure TFMain.IUpdateClick(Sender: TObject);
begin
  FUpdate.dataFile:=XMan;
  FUPdate.showmodal;
  FormActivate(Sender);
end;

procedure TFMain.IInstallClick(Sender: TObject);
begin
  FInstall.dataFile:=XMan;
  FInstall.showModal;
end;

procedure TFMain.CBAllClick(Sender: TObject);
begin
  if (lockEvents=0) then begin
    CBLists.Enabled:=true;
    CBListsChange(Sender);
    CBLists.Enabled:=(not CBAll.Checked);
  end;
end;

end.

