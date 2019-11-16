object FPrint: TFPrint
  Left = 365
  Top = 365
  BorderIcons = [biSystemMenu, biMinimize]
  BorderStyle = bsSingle
  Caption = 'Printing Pages'
  ClientHeight = 104
  ClientWidth = 210
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  OldCreateOrder = False
  PixelsPerInch = 96
  TextHeight = 13
  object Gauge1: TGauge
    Left = 0
    Top = 64
    Width = 209
    Height = 28
    Progress = 0
  end
  object LToPrint: TLabel
    Left = 8
    Top = 0
    Width = 150
    Height = 25
    Caption = 'Pages To Print: '
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -21
    Font.Name = 'Tahoma'
    Font.Style = []
    ParentFont = False
  end
  object BPrintSetup: TButton
    Left = 8
    Top = 32
    Width = 89
    Height = 25
    Caption = 'Print Setup'
    TabOrder = 0
  end
  object BPrint: TButton
    Left = 112
    Top = 32
    Width = 91
    Height = 25
    Caption = 'Begin Printing'
    TabOrder = 1
  end
end
