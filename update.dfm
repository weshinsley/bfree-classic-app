object FUpdate: TFUpdate
  Left = 460
  Top = 219
  BorderIcons = [biSystemMenu, biMinimize]
  BorderStyle = bsSingle
  Caption = 'Update BFree'
  ClientHeight = 239
  ClientWidth = 414
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  FormStyle = fsStayOnTop
  OldCreateOrder = False
  OnActivate = FormActivate
  OnCreate = FormCreate
  PixelsPerInch = 96
  TextHeight = 13
  object IBackDrop: TImage
    Left = 0
    Top = 0
    Width = 400
    Height = 233
  end
  object IExit: TImage
    Left = 288
    Top = 144
    Width = 73
    Height = 81
    OnClick = IExitClick
  end
  object LCV: TLabel
    Left = 8
    Top = 8
    Width = 123
    Height = 18
    Caption = 'Software Version:'
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -16
    Font.Name = 'Arial'
    Font.Style = []
    ParentFont = False
    Transparent = True
  end
  object LDV: TLabel
    Left = 8
    Top = 40
    Width = 130
    Height = 18
    Caption = 'Database Version:'
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -16
    Font.Name = 'Arial'
    Font.Style = []
    ParentFont = False
    Transparent = True
  end
  object LSoftVer: TLabel
    Left = 152
    Top = 8
    Width = 24
    Height = 19
    Caption = 'ver'
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -16
    Font.Name = 'Arial'
    Font.Style = [fsBold]
    ParentFont = False
    Transparent = True
  end
  object LDatVer: TLabel
    Left = 152
    Top = 40
    Width = 24
    Height = 19
    Caption = 'ver'
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -16
    Font.Name = 'Arial'
    Font.Style = [fsBold]
    ParentFont = False
    Transparent = True
  end
  object LNewSoftVer: TLabel
    Left = 240
    Top = 8
    Width = 4
    Height = 19
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clRed
    Font.Height = -16
    Font.Name = 'Arial'
    Font.Style = [fsBold]
    ParentFont = False
    Transparent = True
  end
  object LNewDatVer: TLabel
    Left = 240
    Top = 40
    Width = 4
    Height = 19
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clRed
    Font.Height = -16
    Font.Name = 'Arial'
    Font.Style = [fsBold]
    ParentFont = False
    Transparent = True
  end
  object IUpdate: TImage
    Left = 208
    Top = 144
    Width = 73
    Height = 81
    OnClick = IUpdateClick
  end
  object LFile: TLabel
    Left = 8
    Top = 80
    Width = 84
    Height = 13
    Caption = 'Downloading File:'
    Transparent = True
  end
  object LBytes: TLabel
    Left = 352
    Top = 120
    Width = 41
    Height = 13
    Caption = '150/200'
    Transparent = True
  end
  object DownloadProgress: TProgressBar
    Left = 8
    Top = 96
    Width = 382
    Height = 16
    Max = 385
    TabOrder = 0
  end
  object XMLD: TXMLDocument
    Options = [doNodeAutoCreate, doAttrNull]
    Left = 8
    Top = 200
    DOMVendorDesc = 'Open XML'
  end
  object updateXML: TXMLDocument
    Options = [doNodeAutoCreate, doAttrNull]
    Left = 72
    Top = 200
    DOMVendorDesc = 'Open XML'
  end
end
