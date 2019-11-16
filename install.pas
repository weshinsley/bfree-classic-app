unit install;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, ExtCtrls, ComCtrls, ShellCtrls, StdCtrls, Grids,
  DirOutln, xmldom, XMLIntf, msxmldom, XMLDoc, SHlObj, ComObj, ActiveX;

type
  TFInstall = class(TForm)
    IInstall: TImage;
    IExit: TImage;
    EDir: TEdit;
    ShellTreeView1: TShellTreeView;
    PB: TProgressBar;
    XMLDocument1: TXMLDocument;
    procedure FormCreate(Sender: TObject);
    procedure IExitClick(Sender: TObject);
    procedure ShellTreeView1Change(Sender: TObject; Node: TTreeNode);
    procedure IInstallClick(Sender: TObject);
    procedure FileCopy(const FromFile, ToFile: string);
  private
    { Private declarations }

  public
    dataFile : TXMLDocument;
    data : IXMLNode;
  end;

var
  FInstall: TFInstall;


implementation

uses main;

{$R *.dfm}

procedure CreateLink(path: String);
var
  IObject    : IUnknown;
  ISLink     : IShellLink;
  IPFile     : IPersistFile;
  PIDL       : PItemIDList;
  InFolder   : array[0..MAX_PATH] of Char;
  TargetName : String;
  LinkName   : WideString;
begin
  TargetName := path+'\bfree.exe';
  IObject := CreateComObject(CLSID_ShellLink);
  ISLink  := IObject as IShellLink;
  IPFile  := IObject as IPersistFile;

  with ISLink do begin
    SetPath(pChar(TargetName));
    SetWorkingDirectory
	   (pChar(ExtractFilePath(TargetName)));
  end;

  // if we want to place a link on the Desktop
  SHGetSpecialFolderLocation
     (0, CSIDL_DESKTOPDIRECTORY, PIDL);
  SHGetPathFromIDList
     (PIDL, InFolder);

  LinkName := InFolder + '\BFree.lnk';
  IPFile.Save(PWChar(LinkName), false);
end;

function getfilesize(s : string) : longint;
var f : file;
    l : longint;
    fm : integer;
begin
  fm:=filemode;
  filemode:=fmOpenRead;
  assignfile(f,s);
  reset(f,1);
  l:=filesize(f);
  closefile(f);
  getfilesize:=l;
  filemode:=fm;
end;

procedure UnReadOnlify(s: string);
var attrs : word;
begin
  attrs:=FileGetAttr(s);
  FileSetAttr(s,attrs and (not faREadOnly));
end;

procedure TFInstall.FileCopy(const FromFile, ToFile: string);
 var
  FromF, ToF: file;
  fm,NumRead, NumWritten: integer;
  Buf: array[1..65535] of Char;

begin
  fm:=filemode;
  filemode:=fmOpenRead;
  AssignFile(FromF, FromFile);
  Reset(FromF, 1);		{ Record size = 1 }
  filemode:=fmOpenWrite;
  AssignFile(ToF, ToFile);	{ Open output file }
  Rewrite(ToF, 1);		{ Record size = 1 }
  repeat
    BlockRead(FromF, Buf, SizeOf(Buf), NumRead);
    BlockWrite(ToF, Buf, NumRead, NumWritten);
    PB.Position:=PB.Position+NumRead;
    PB.Update;
  until (NumRead = 0) or (NumWritten <> NumRead);
  CloseFile(FromF);
  CloseFile(ToF);
  FileMode:=fm;
end;


procedure TFInstall.FormCreate(Sender: TObject);
begin
  IExit.Width:=50;
  IExit.Height:=50;
  IInstall.Width:=IExit.Width;
  IInstall.Height:=IExit.Height;
  EDir.Text:='C:\Program Files\BFree';
  if (fileexists('images/Install.jpg')) then Iinstall.Picture.LoadFromFile('images/install.jpg');
  IExit.Picture.LoadFromFile('images/newexit.jpg');


end;

procedure TFInstall.IExitClick(Sender: TObject);
begin
  close;
end;
          
procedure TFInstall.ShellTreeView1Change(Sender: TObject; Node: TTreeNode);
begin
  EDir.Text:=ShellTreeView1.Path;
end;

procedure TFInstall.IInstallClick(Sender: TObject);
var path : string;
    thefile : string;
    size : longint;
    links : IXMLNode;
    link : IXMLNode;
    i,j : integer;
begin
  PB.Position:=0;
  PB.Max:=999999;
  Path:=Edir.Text;
  if copy(PAth,length(Path),1)='\' then Path:=copy(Path,1,length(Path)-1);
  if messagedlg('Are you sure you want to install into '+EDir.Text+'?',mtConfirmation,[mbYes,mbCancel],0)=mrYes then begin
    if (not DirectoryExists(Path)) then ForceDirectories(Path);
    size:=getfilesize('bfree.iexe');
    size:=size+getfilesize('songs\man.ixml');
    size:=size+getfilesize('images\adobe.jpg');
    size:=size+getfilesize('images\article.jpg');
    size:=size+getfilesize('images\backdrop.jpg');
    size:=size+getfilesize('images\BFree.jpg');
    size:=size+getfilesize('images\chords.jpg');
    size:=size+getfilesize('images\header.jpg');
    size:=size+getfilesize('images\install.jpg');
    size:=size+getfilesize('images\littlebd.jpg');
    size:=size+getfilesize('images\midi.jpg');
    size:=size+getfilesize('images\minimise.jpg');
    size:=size+getfilesize('images\mp3.jpg');
    size:=size+getfilesize('images\newexit.jpg');
    size:=size+getfilesize('images\print.jpg');
    size:=size+getfilesize('images\printer.jpg');
    size:=size+getfilesize('images\resetsearch.jpg');
    size:=size+getfilesize('images\search.jpg');
    size:=size+getfilesize('images\sheet.jpg');
    size:=size+getfilesize('images\sprinter.jpg');
    size:=size+getfilesize('images\update.jpg');
    size:=size+getfilesize('images\winamp.jpg');
    size:=size+getfilesize('images\_article.jpg');
    size:=size+getfilesize('images\_chords.jpg');
    size:=size+getfilesize('images\_midi.jpg');
    size:=size+getfilesize('images\_mp3.jpg');
    size:=size+getfilesize('images\_printer.jpg');
    size:=size+getfilesize('images\_sheet.jpg');
    size:=size+getfilesize('images\_sprinter.jpg');
    data:=dataFile.ChildNodes['songs'];
    for i:=0 to data.childNodes.count-1 do begin
      links:=data.ChildNodes[i].ChildNodes['links'];
      for j:=0 to links.childNodes.count-1 do begin
        link:=links.childNodes[j];
        thefile:=link.ChildValues['type']+'\'+link.ChildValues['file'];
        size:=size+getfilesize('songs\'+thefile);
      end;
    end;
    PB.max:=size;
    PB.position:=0;
    FileCopy('bfree.iexe',Path+'\bfree.exe');
    UnReadOnlify(Path+'\bfree.exe');
    ForceDirectories(Path+'\images');
    ForceDirectories(Path+'\songs\MP3');
    ForceDirectories(Path+'\songs\Chords');
    ForceDirectories(Path+'\songs\Midi');
    ForceDirectories(Path+'\songs\Sheet');
    ForceDirectories(Path+'\songs\Article');
    FileCopy('songs\man.ixml',Path+'\songs\man.xml');
    UnReadOnlify(Path+'\songs\man.xml');
    FileCopy('images\adobe.jpg',Path+'\images\adobe.jpg');
    FileCopy('images\article.jpg',Path+'\images\article.jpg');
    FileCopy('images\backdrop.jpg',Path+'\images\backdrop.jpg');
    FileCopy('images\BFree.jpg',Path+'\images\BFree.jpg');
    FileCopy('images\chords.jpg',Path+'\images\chords.jpg');
    FileCopy('images\header.jpg',Path+'\images\header.jpg');
    FileCopy('images\install.jpg',Path+'\images\install.jpg');
    FileCopy('images\littlebd.jpg',Path+'\images\littlebd.jpg');
    FileCopy('images\midi.jpg',Path+'\images\midi.jpg');
    FileCopy('images\minimise.jpg',Path+'\images\minimise.jpg');
    FileCopy('images\mp3.jpg',Path+'\images\mp3.jpg');
    FileCopy('images\newexit.jpg',Path+'\images\newexit.jpg');
    FileCopy('images\print.jpg',Path+'\images\print.jpg');
    FileCopy('images\printer.jpg',Path+'\images\printer.jpg');
    FileCopy('images\resetsearch.jpg',Path+'\images\resetsearch.jpg');
    FileCopy('images\search.jpg',Path+'\images\search.jpg');
    FileCopy('images\sheet.jpg',Path+'\images\sheet.jpg');
    FileCopy('images\sprinter.jpg',Path+'\images\sprinter.jpg');
    FileCopy('images\update.jpg',Path+'\images\update.jpg');
    FileCopy('images\winamp.jpg',Path+'\images\winamp.jpg');
    FileCopy('images\_article.jpg',Path+'\images\_article.jpg');
    FileCopy('images\_chords.jpg',Path+'\images\_chords.jpg');
    FileCopy('images\_midi.jpg',Path+'\images\_midi.jpg');
    FileCopy('images\_mp3.jpg',Path+'\images\_mp3.jpg');
    FileCopy('images\_printer.jpg',Path+'\images\_printer.jpg');
    FileCopy('images\_sheet.jpg',Path+'\images\_sheet.jpg');
    FileCopy('images\_sprinter.jpg',Path+'\images\_sprinter.jpg');

    for i:=0 to data.childNodes.count-1 do begin
      links:=data.ChildNodes[i].ChildNodes['links'];
      for j:=0 to links.childNodes.count-1 do begin
        link:=links.childNodes[j];
        thefile:=link.ChildValues['type']+'\'+link.ChildValues['file'];
        FileCopy('songs\'+thefile,Path+'\songs\'+thefile);
        UnReadOnlify(Path+'\songs\'+thefile);
      end;
    end;
    CreateLink(Path);
    messagedlg('Installation Successful. BFree short-cut is on desktop. Relaunching installed version',mtConfirmation,[mbOk],0);
    setcurrentdir(path);
    winexec(pchar(path+'\bfree.exe'),SW_MAXIMIZE);
    close;
    FMain.close;
  end;
end;
end.


