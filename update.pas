unit update;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, ExtCtrls, StdCtrls, xmldom, XMLIntf, Sockets, msxmldom, XMLDoc,
  ComCtrls, oxmldom, ExtActns;

type
  TFUpdate = class(TForm)
    IBackDrop: TImage;
    IExit: TImage;
    LCV: TLabel;
    LDV: TLabel;
    LSoftVer: TLabel;
    LDatVer: TLabel;
    XMLD: TXMLDocument;
    LNewSoftVer: TLabel;
    LNewDatVer: TLabel;
    IUpdate: TImage;
    DownloadProgress: TProgressBar;
    LFile: TLabel;
    LBytes: TLabel;
    updateXML: TXMLDocument;
    procedure FormCreate(Sender: TObject);
    procedure IExitClick(Sender: TObject);
    procedure FormActivate(Sender: TObject);
    procedure IUpdateClick(Sender: TObject);
    procedure RemoveSong(id : string; links,lists : boolean);
    function BetterDownloadFile(strRemoteFileName, strLocalFileName : string) : integer;
  private
    procedure URL_OnDownloadProgress
        (Sender: TDownLoadURL;
         Progress, ProgressMax: Cardinal;
         StatusCode: TURLDownloadStatus;
         StatusText: String; var Cancel: Boolean) ;
  public
    dataFile : TXMLDocument;
    data : IXMLNode;
    updateme : boolean;
    { Public declarations }
  end;

var
  FUpdate: TFUpdate;


implementation

uses main;

{$R *.dfm}

procedure TFUpdate.FormCreate(Sender: TObject);
begin
  FUpdate.Width:=400;
  FUpdate.Height:=234;
  IBackDrop.Width:=400;
  IBackDrop.Height:=234;
  IBackDrop.Top:=0;
  IBackDrop.Left:=0;
  IBackDrop.Picture.LoadFromFile('Images/littlebd.jpg');
  IExit.Picture.LoadFromFile('Images/newexit.jpg');
  IExit.Width:=50;
  IExit.Height:=50;
  IExit.Left:=FUpdate.Width-60;
  IExit.Top:=FUpdate.Height-85;
  IUpdate.Picture.LoadFromFile('Images/update.jpg');
  IUpdate.Width:=50;
  IUpdate.Height:=50;
  IUpdate.Left:=(IExit.Left-IExit.Width)-10;
  IUpdate.Top:=FUpdate.Height-85;

end;

procedure TFUpdate.IExitClick(Sender: TObject);
begin
  if (fileexists('temp.xml')) then deletefile('temp.xml');
  if (fileexists('update.xml')) then deletefile('update.xml');
  close;
end;

procedure TFUpdate.URL_OnDownloadProgress;
begin
   DownloadProgress.Max:=ProgressMax;
   DownloadProgress.Position:=Progress;
   LBytes.Caption:=IntToStr(Progress)+'/'+IntToStr(ProgressMax);
   LBytes.Left:=393-LBytes.Width;
   LBytes.update;
end;

function TFUpdate.BetterDownloadFile(strRemoteFileName, strLocalFileName : string) : integer;
var res : integer;
    datequery : string;
begin
  res:=0;
  with TDownloadURL.Create(self) do begin
    try
      URL:=Main.updateserver+'/'+Main.updatedir+'/'+strRemoteFileName;
      DateTimeToString(datequery, 'yymmddhhnnss', now);
      URL:= URL + '?d='+datequery;
      FileName := strLocalFileName;
      OnDownloadProgress := URL_OnDownloadProgress;
      ExecuteTarget(nil);
    except
      res:=999
    end;
   Free;
  end;
  BetterDownloadFile:=res;
end;

function notNumerical(c : char) : boolean;
begin
  if (c<'0') or (c>'9') then notNumerical:=true
  else notNumerical:=false;
end;

procedure TFUpdate.FormActivate(Sender: TObject);
var newDatVer,newSoftVer : string;
    result : integer;
    versionName : string;
    currentV : string;

begin

  IUpdate.Visible:=false;
  IExit.Visible:=false;
  data:=dataFile.ChildNodes['songs'];
  LFile.Caption:='Downloading File: Version Information';
  while (fileexists('temp.xml')) do deletefile('temp.xml');
  result:=BetterDownloadFile('XML/'+Main.debugFile+'version.xml', 'temp.xml');
  if (result=999) then IExit.Visible:=true;
  if (result=0) then begin
    XMLD.LoadFromFile('temp.xml');
    versionName:='latest';
    currentV:=LDatVer.Caption;
    if (notNumerical(currentV[1])) then
      versionName:=lowercase('latest'+currentV[1]);
    newDatVer:=XMLD.ChildNodes['version'].ChildValues[versionName];
    newSoftVer:=XMLD.ChildNodes['version'].ChildValues['soft'];
    LNewDatVer.Left:=LDatVer.Left+LDatVer.Width+10;
    LNewSoftVer.Left:=LSoftVer.Left+LSoftVer.Width+10;
    if (newDatVer<>LDatVer.Caption) then begin
      LNewDatVer.Caption:='>> '+newDatVer;
      LNewDatVer.Font.Color:=clRed;
    end else begin
      LNewDatVer.Caption:='OK';
      LNewDatVer.Font.Color:=clBlack;
    end;
    if (newSoftVer<>LSoftVer.Caption) then begin
      LNewSoftVer.Caption:='>> '+newSoftVer;
      LNewSoftVer.Font.Color:=clRed;
    end else begin
      LNewSoftVer.Caption:='OK';
      LNewSoftVer.Font.Color:=clBlack;
    end;
    IUpdate.Visible:=not((LNewSoftVer.Caption='OK') and (LNewDatVer.Caption='OK'));
    IExit.Visible:=true;
    if (updateme) then begin
      updateme:=false;
      if (IUpdate.Visible) then IUpdateClick(Sender);
    end;
  end;
end;



procedure TFUpdate.RemoveSong(id : string; links,lists : boolean);
var linksNode,listsNode,theList,ids : IXMLNode;
    j,k : integer;
    found : boolean;
    LinkFile,LinkType : string;

begin
  if (lists) then begin
    listsNode:=data.ChildNodes['lists'];
  // Remove from lists
    for j:=0 to listsNode.ChildNodes.Count-1 do begin
      theList:=listsNode.ChildNodes[j];
      ids:=theList.ChildNodes['ids'];
      found:=false;
      k:=0;
      while (k<ids.ChildNodes.count) and ( not found) do begin
        if (ids.ChildNodes[k].NodeValue=id) then found:=true
        else inc(k);
      end;
      if (found) then ids.ChildNodes.Delete(k);
    end;
  end;

  // Locate song XML data

  found:=false;
  k:=0;
  while (k<data.ChildNodes.Count) and ( not found) do begin
    if (data.ChildNodes[k].NodeName='song') then begin
      if (data.ChildNodes[k].ChildValues['officeno']=id) then found:=true
      else inc(k);
    end else inc(k);
  end;

  // Remove links.

  if (links) then begin
    linksNode:= data.ChildNodes[k].ChildNodes['links'];
    for j:=0 to linksNode.ChildNodes.Count-1 do begin
      Linktype:=linksNode.ChildNodes[j].ChildValues['type'];
      LinkFile:=linksNode.ChildNodes[j].ChildValues['file'];
      deletefile('Songs\'+linktype+'\'+LinkFile);
    end;
  end;

  // Remove song from XML.
  if (found) then data.ChildNodes.Delete(k);

end;


procedure TFUpdate.IUpdateClick(Sender: TObject);
var updatefile : string;
    sparenode,anothernode,newnode,tracklinks,track,linksNode,node,parent,listsNode,theList,ids : IXMLNode;
    i,j,k : integer;
    found,replaceID : boolean;
    oldname,newname,listname,oldid,verifyid,s,newtype,newfile,LinkType,newid,LinkFile,verid,newverid,id,list : string;


begin
  IUpdate.Visible:=false;
  IExit.Visible:=false;
  // Update BFREE.EXE
  if (pos('>>',LNewSoftVer.Caption)>0) then begin
    LCV.font.Color:=clRed;
    LCV.update;
    LFile.Caption:='Downloading File: BFREE Software '+LNewSoftVer.Caption;
    LFile.Update;
    while (fileexists('bfree.old')) do deletefile('bfree.old');
    while (fileexists('bfree.tmp')) do deletefile('bfree.tmp');
    betterdownloadfile('Files/'+Main.debugFile+'bfree.exe', 'bfree.tmp');
    renamefile('bfree.exe','bfree.old');
    renamefile('bfree.tmp','bfree.exe');
    winexec('bfree.exe /U',SW_MAXIMIZE);
    close;
    FMain.close;
  end

  // Update Data

  else if (pos('>>',LNewDatVer.Caption)>0) then begin
    LDV.font.Color:=clRed;
    LDV.update;
    repeat
      updatefile:=Main.debugFile+'up.'+LDatVer.Caption+'.xml';
      LFile.Caption:='Download File: '+updatefile;
      if fileexists('update.xml') then deletefile('update.xml');
      betterdownloadfile('XML/'+updatefile, 'update.xml');
      updateXML.LoadFromFile('update.xml');
      parent := updateXML.ChildNodes['update'];
      verid:=updateXML.ChildNodes['update'].ChildValues['fromid'];
      newverid:=updateXML.ChildNodes['update'].ChildValues['toid'];
      for i:=2 to parent.ChildNodes.Count-1 do begin
        Node:=parent.ChildNodes[i];

/////////////////////////////////////////////////////////////////
// addsong <song>                                              //
/////////////////////////////////////////////////////////////////
        replaceID:=false;
        if Node.LocalName='addsong' then begin
          // Check if song already exists
          newid:=Node.ChildNodes['song'].ChildValues['officeno'];
          found:=false;
          j:=0;
          while (j<data.ChildNodes.Count) and (not found) do begin
            if (data.ChildNodes[j].NodeName='song') then begin
              if (data.ChildNodes[j].ChildValues['officeno']=newid) then begin
                RemoveSong(newid,true,true); // Kill it, and all its links!
                found:=true;
              end;
            end;
            inc(j);
          end;
           // next line fails.
          s:=Node.ChildNodes['song'].ChildValues['title'];
          j:=0;
          found:=false;
          while (j<data.ChildNodes.Count) and (not found) do begin
            if (data.ChildNodes[j].NodeName='song') then begin
              if (FMain.gt(data.ChildNodes[j].ChildValues['title'],s)) then
                found:=true
              else inc(j);
            end else inc(j);
          end;
          track:= data.AddChild('song','',false,j);
          newnode:=track.AddChild('title');
          newnode.NodeValue:=s;
          newnode:=track.AddChild('alttitle');
          newnode.NodeValue:=Node.ChildNodes['song'].ChildValues['alttitle'];
          newnode:=track.AddChild('officeno');
          newnode.NodeValue:=Node.ChildNodes['song'].ChildValues['officeno'];
          newnode:=track.AddChild('author');
          newnode.NodeValue:=Node.ChildNodes['song'].ChildValues['author'];
          newnode:=track.AddChild('copdate');
          newnode.NodeValue:=Node.ChildNodes['song'].ChildValues['copdate'];;
          newnode:=track.AddChild('copyright');
          newnode.NodeValue:=Node.ChildNodes['song'].ChildValues['copyright'];
          newnode:=track.AddChild('text');
          newnode.NodeValue:=Node.ChildNodes['song'].ChildValues['text'];
          if (track.nodename<>'song') then begin
            messagedlg(track.nodename,mtError,[mbOk],0);
          end;
          tracklinks:=track.addChild('links','');

          linksNode:=Node.ChildNodes['song'].ChildNodes['links'];
          for j:=0 to linksNode.ChildNodes.Count-1 do begin
            linkType:=linksNode.ChildNodes[j].ChildValues['type'];
            linkFile:=linksNode.ChildNodes[j].ChildValues['file'];
            newnode:=tracklinks.AddChild('link');
            anotherNode:=newnode.AddChild('type');
            anotherNode.NodeValue:=linkType;
            anotherNode:=newnode.AddChild('file');
            anotherNode.NodeValue:=linkFile;
            LFile.Caption:='Downloading File: '+linkFile;
            LFile.Update;
            if ((uppercase(copy(linkFile,1,7))='HTTP://') or (uppercase(copy(linkFile,1,8))='HTTPS://')) then begin
              // Don't download - it's a link
            end else begin
              betterdownloadfile('Files/'+linkFile, 'Songs/'+linkType+'/'+LinkFile);
            end;
          end;

/////////////////////////////////////////////////////////////////
// updaterecord <song>                                         //
/////////////////////////////////////////////////////////////////

        end else if Node.LocalName='updaterecord' then begin
           // Check if song already exists
          oldid:=Node.ChildNodes['song'].ChildValues['officeno'];
          newid:=oldid;
          if (pos('#', oldid) > 0) then begin
            newid:= copy(oldid,pos('#',oldid)+1,length(oldid));
            oldid:= copy(oldid,1,pos('#',oldid)-1);
            replaceID:=true;
          end;
          found:=false;
          j:=0;
          while (j<data.ChildNodes.Count) and (not found) do begin
            if (data.ChildNodes[j].NodeName='song') then begin
              if (not replaceID) then begin
                if (data.ChildNodes[j].ChildValues['officeno']=oldid) then begin
                  RemoveSong(newid,false,false); // Only remove XML
                  found:=true;
                end;
              end else begin
                if ((data.ChildNodes[j].ChildValues['officeno']=oldid) and
                    (data.ChildNodes[j].ChildValues['title']=Node.ChildNodes['song'].ChildValues['title']) and
                    (data.ChildNodes[j].ChildValues['alttitle']=Node.ChildNodes['song'].ChildValues['alttitle']) and
                    (data.ChildNodes[j].ChildValues['author']=Node.ChildNodes['song'].ChildValues['author']) and
                    (data.ChildNodes[j].ChildValues['copyright']=Node.ChildNodes['song'].ChildValues['copyright']) and
                    (data.ChildNodes[j].ChildValues['text']=Node.ChildNodes['song'].ChildValues['text']) and                    
                    (data.ChildNodes[j].ChildValues['copdate']=Node.ChildNodes['song'].ChildValues['copdate'])) then begin
                   data.ChildNodes[j].ChildNodes['officeno'].NodeValue:=newid;
                   found:=true;
                end;
              end;
            end;
            inc(j);
          end;
          if (not replaceID) then begin
             // next line fails.
            s:=Node.ChildNodes['song'].ChildValues['title'];
            j:=0;
            found:=false;
            while (j<data.ChildNodes.Count) and (not found) do begin
              if (data.ChildNodes[j].NodeName='song') then begin
                if (FMain.gt(data.ChildNodes[j].ChildValues['title'],s)) then
                  found:=true
                else inc(j);
              end else inc(j);
            end;
            track:= data.AddChild('song','',false,j);
            newnode:=track.AddChild('title');
            newnode.NodeValue:=s;
            newnode:=track.AddChild('alttitle');
            newnode.NodeValue:=Node.ChildNodes['song'].ChildValues['alttitle'];
            newnode:=track.AddChild('officeno');
            newnode.NodeValue:=newid;
            newnode:=track.AddChild('author');
            newnode.NodeValue:=Node.ChildNodes['song'].ChildValues['author'];
            newnode:=track.AddChild('copdate');
            newnode.NodeValue:=Node.ChildNodes['song'].ChildValues['copdate'];;
            newnode:=track.AddChild('copyright');
            newnode.NodeValue:=Node.ChildNodes['song'].ChildValues['copyright'];
            newnode:=track.AddChild('text');
            newnode.NodeValue:=Node.ChildNodes['song'].ChildValues['text'];
            tracklinks:=track.addChild('links','');

            linksNode:=Node.ChildNodes['song'].ChildNodes['links'];
            for j:=0 to linksNode.ChildNodes.Count-1 do begin
              linkType:=linksNode.ChildNodes[j].ChildValues['type'];
              linkFile:=linksNode.ChildNodes[j].ChildValues['file'];
              newnode:=tracklinks.AddChild('link');
              anotherNode:=newnode.AddChild('type');
              anotherNode.NodeValue:=linkType;
              anotherNode:=newnode.AddChild('file');
              anotherNode.NodeValue:=linkFile;
            end;
          end;

/////////////////////////////////////////////////////////////////
// <verify>id</verify>                                         //
//    Find song with officeno = id                             //
//    I think it removes duplicates/corrects old sorting eror  //
//    Probably just legacy                                     //
/////////////////////////////////////////////////////////////////

        end else if Node.LocalName='verify' then begin
          verifyid:=Node.NodeValue;
          found:=false;
          j:=0;
          while (j<data.ChildNodes.Count) and (not found) do begin
            if (data.ChildNodes[j].NodeName='song') then begin
              if (data.ChildNodes[j].ChildValues['officeno']=verifyid) then begin
                sparenode:=data.ChildNodes[j].CloneNode(true);
                data.ChildNodes.Delete(j);
                s:=sparenode.ChildValues['title'];
                found:=true;
              end;
            end;
            inc(j);
          end;

          j:=0;
          found:=false;
          while (j<data.ChildNodes.Count) and (not found) do begin
            if (data.ChildNodes[j].NodeName='song') then begin
              if (FMain.gt(data.ChildNodes[j].ChildValues['title'],s)) then
                found:=true
              else inc(j);
            end else inc(j);
          end;
          data.ChildNodes.Insert(j,sparenode);


/////////////////////////////////////////////////////////////////
// addsongtolist <id> <list>                                   //
/////////////////////////////////////////////////////////////////

        end else if Node.LocalName='addsongtolist' then begin
          list:=Node.ChildValues['list'];
          listsNode:=data.ChildNodes['lists'];
          j:=0;
          while (listsNode.ChildNodes[j].ChildValues['name']<>list) do inc(j);
          for k:=0 to Node.ChildNodes.Count-1 do begin
            if (Node.ChildNodes[k].nodeName='id') then begin
             id:=Node.ChildNodes[k].nodeValue;
             anothernode:=listsNode.ChildNodes[j].ChildNodes['ids'].AddChild('id');
             anothernode.NodeValue:=id;
            end;
          end;

/////////////////////////////////////////////////////////////////
// removesongfromlist <id> <list>                              //
/////////////////////////////////////////////////////////////////

        end else if Node.LocalName='removesongfromlist' then begin
          list:=Node.ChildValues['list'];
          listsNode:=data.ChildNodes['lists'];
          j:=0;
          found:=false;
          repeat
            if (j<listsNode.ChildNodes.Count) then begin
              if (listsNode.ChildNodes[j].ChildValues['name']<>list) then inc(j)
              else found:=true;
            end;
          until ((found) or (j>=listsNode.ChildNodes.Count));
          if (j<listsNode.ChildNodes.Count) then begin
            theList:=listsNode.ChildNodes[j].ChildNodes['ids'];
            for k:=0 to Node.ChildNodes.Count-1 do begin
              if (Node.ChildNodes[k].nodeName='id') then begin
                id:=Node.ChildNodes[k].NodeValue;
                j:=0;
                found:=false;
                while (not found) and (j<theList.ChildNodes.count) do begin
                  oldid:=theList.ChildNodes[j].nodeValue;
                  if (oldid=id) then begin
                    found:=true;
                    theList.ChildNodes.Delete(j);
                  end;
                  inc(j);
                end;
              end;
            end;
          end;

/////////////////////////////////////////////////////////////////
// removesong <id>                                             //
/////////////////////////////////////////////////////////////////

        end else if Node.LocalName='removesong' then begin
          id:=Node.ChildValues['id'];
          RemoveSong(id,true,true);

/////////////////////////////////////////////////////////////////
// addlink <id> <link> <type> <file>                           //
/////////////////////////////////////////////////////////////////

        end else if Node.LocalName='addlink' then begin
          id:=Node.ChildValues['id'];
          Node:=Node.ChildNodes['link'];
          newtype := Node.ChildValues['type'];
          newfile := Node.ChildValues['file'];
          found:=false;
          k:=0;
          while (k<data.ChildNodes.Count) and ( not found) do begin
            if (data.ChildNodes[k].NodeName='song') then begin
              if (data.ChildNodes[k].ChildValues['officeno']=id) then begin
                found:=true;
                break;
              end else inc(k);
            end else inc(k);
          end;
          if (found) then begin
            linksNode:=data.ChildNodes[k].ChildNodes['links'];
            j:=0;
            found:=false;
            while (j<linksNode.ChildNodes.Count) and (not found) do begin
              linktype:=LinksNode.ChildNodes[j].ChildValues['type'];
              if (LinkType=newtype) then begin
                found:=true;
                linkfile:=LInksNode.ChildNodes[j].ChildValues['file'];
                deletefile('Songs\'+LinkType+'\'+LinkFile);
              end else inc(j);
            end;

            if (newtype <> 'MP3') then begin
              LFile.Caption:='Downloading File: '+newfile;
              LFile.Update;
              betterdownloadfile('Files/'+newFile, 'Songs/'+newtype+'/'+newfile);
            end;
            track:=data.ChildNodes[k].ChildNodes['links'].AddChild('link');
            anothernode:=track.addChild('type');
            anothernode.nodevalue:=newtype;
            anothernode:=track.addChild('file');
            anothernode.nodevalue:=newfile;
          end;

/////////////////////////////////////////////////////////////////
// getfile <type> <file>                                       //
/////////////////////////////////////////////////////////////////

        end else if Node.LocalName='getfile' then begin
          newtype := Node.ChildValues['type'];
          newfile := Node.ChildValues['file'];
          LFile.Caption:='Downloading File: '+newfile;
          LFile.Update;
          betterdownloadfile('Files/'+newFile, 'Songs/'+newtype+'/'+newfile);

/////////////////////////////////////////////////////////////////
// removelink <id> <type> <file>                               //
/////////////////////////////////////////////////////////////////

        end else if Node.LocalName='removelink' then begin
          id:=Node.ChildValues['id'];
          LinkType:=Node.ChildValues['type'];
          LinkFile:=Node.ChildValues['file'];
          DeleteFile('Songs\'+LinkType+'\'+LinkFile);
          // Find the Song
          found:=false;
          k:=0;
          while (k<data.ChildNodes.Count) and ( not found) do begin
            if (data.ChildNodes[k].NodeName='song') then begin
              if (data.ChildNodes[k].ChildValues['officeno']=id) then
                found:=true
              else inc(k);
            end else inc(k);
          end;

          // Remove link node.

          linksNode:= data.ChildNodes[k].ChildNodes['links'];
          j:=0;
          found:=false;
          while (not found) and (j<linksNode.ChildNodes.Count) do begin
            if (linkType=linksNode.ChildNodes[j].ChildValues['type']) then found:=true
            else inc(j);
          end;
          if (found) then linksNode.ChildNodes.Delete(j);

/////////////////////////////////////////////////////////////////
// <createlist>name</createlist>                               //
/////////////////////////////////////////////////////////////////

        end else if Node.LocalName='createlist' then begin
          listname:=Node.NodeValue;
          listsNode:=data.ChildNodes['lists'];
          theList:=listsNode.AddChild('list','',false);
          track:=theList.addChild('name');
          track.NodeValue:=listname;
          track:=theList.AddChild('ids','',false);

/////////////////////////////////////////////////////////////////
// <removelist>name</removelist>                               //
/////////////////////////////////////////////////////////////////

        end else if Node.LocalName='removelist' then begin
          listname:=Node.NodeValue;
          listsNode:=data.ChildNodes['lists'];
          found:=false;
          j:=0;
          while (j<listsNode.ChildNodes.Count) and (not found) do begin
            if (listsNode.ChildNodes[j].ChildNodes['name'].nodeValue=listname) then begin
              found:=true;
              listsNode.ChildNodes.Delete(j);
            end;
            inc(j);
          end;

/////////////////////////////////////////////////////////////////
// renamelist <oldname> <newname>                              //
/////////////////////////////////////////////////////////////////

        end else if Node.LocalName='renamelist' then begin
          oldname:=Node.ChildValues['oldname'];
          newname:=Node.ChildValues['newname'];
          listsNode:=data.ChildNodes['lists'];
          found:=false;
          j:=0;
          while (j<listsNode.ChildNodes.Count) and (not found) do begin
            if (listsNode.ChildNodes[j].ChildNodes['name'].nodeValue=oldname) then begin
              found:=true;
              listsNode.ChildNodes[j].ChildNodes['name'].NodeValue:=newname;
            end;
            inc(j);
          end;

/////////////////////////////////////////////////////////////////
// renameid <from> <to>                                        //
/////////////////////////////////////////////////////////////////

        end else if Node.LocalName='renameid' then begin
          id:=Node.ChildValues['from'];
          newid:=Node.ChildValues['to'];

          listsNode:=data.ChildNodes['lists'];
          // Rename in lists
          for j:=0 to listsNode.ChildNodes.Count-1 do begin
            theList:=listsNode.ChildNodes[j];
            ids:=theList.ChildNodes['ids'];
            k:=0;
            while (k<ids.ChildNodes.count) do begin
              if (ids.ChildNodes[k].NodeValue=id) then ids.ChildNodes[k].NodeValue:=newid;
              inc(k);
            end;
          end;

          // Locate song XML data

          k:=0;
          while (k<data.ChildNodes.Count) do begin
            if (data.ChildNodes[k].NodeName='song') then begin
              if (data.ChildNodes[k].ChildValues['officeno']=id) then data.ChildNodes[k].ChildNodes['officeno'].NodeValue:=newid;
            end;
            inc(k);
          end;
        end;
      end;

      data:=dataFile.ChildNodes['songs'];
      data.ChildNodes['version'].NodeValue:=newverid;
      dataFile.Encoding:='UTF-8';
      dataFile.SaveToFile('Songs\man.xml');
      LDatVer.Caption:=newverid;
      LDatVer.Update;
    until ('>> '+newverid=LNewDatVer.Caption);
    close;
  end;
end;
{Command set for updates
  addlink            <id>      <type>   <link>   <file>
  addsong            <song>
  addsongtolist      <id>      <list>
  createlist(name)
  getfile            <type>    <file>
  removesong         <id>
  removesongfromlist <id>      <list>
  removelink         <id>      <type>   <file>
  removelist(name)
  renameid           <from>    <to>
  renamelist         <oldname> <newname>
  updaterecord       <song>
  verify(id)
}
end.

