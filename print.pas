unit print;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, Gauges;

type
  TFPrint = class(TForm)
    Gauge1: TGauge;
    LToPrint: TLabel;
    BPrintSetup: TButton;
    BPrint: TButton;
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  FPrint: TFPrint;

implementation

{$R *.dfm}

end.
