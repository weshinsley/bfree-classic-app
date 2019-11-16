program BFree;

uses
  Forms,
  main in 'main.pas' {FMain},
  bfreeprint in 'bfreeprint.pas' {FPrint},
  update in 'update.pas' {FUpdate},
  install in 'install.pas' {FInstall};

{$R *.res}

begin
  Application.Initialize;
  Application.Title := 'BFree 2 Praise';
  Application.CreateForm(TFMain, FMain);
  Application.CreateForm(TFPrint, FPrint);
  Application.CreateForm(TFUpdate, FUpdate);
  Application.CreateForm(TFInstall, FInstall);
  Application.Run;
end.
