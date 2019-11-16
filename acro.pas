unit acro;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, OleCtrls, AcroPDFLib_TLB;

type
  TFAcro = class(TForm)
    Acro: TAcroPDF;
    procedure FormActivate(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  FAcro: TFAcro;

implementation

{$R *.dfm}

procedure TFAcro.FormActivate(Sender: TObject);
begin
  width:=Screen.width;
  height:=Screen.height;
  acro.top:=0;
  acro.Left:=0;
  acro.Width:=Screen.width;
  acro.Height:=Screen.height;
  acro.update;
  acro.Repaint;
  acro.refresh;
  acro.setPageMode('8');
  acro.visible:=true;
end;

end.
