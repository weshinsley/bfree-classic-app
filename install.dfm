object FInstall: TFInstall
  Left = 469
  Top = 198
  BorderStyle = bsDialog
  Caption = 'Select Directory'
  ClientHeight = 260
  ClientWidth = 282
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  OldCreateOrder = False
  OnCreate = FormCreate
  PixelsPerInch = 96
  TextHeight = 13
  object IInstall: TImage
    Left = 224
    Top = 8
    Width = 49
    Height = 49
    Hint = 'Install BFree'
    ParentShowHint = False
    ShowHint = True
    Stretch = True
    OnClick = IInstallClick
  end
  object IExit: TImage
    Left = 224
    Top = 184
    Width = 49
    Height = 49
    Hint = 'Back to Main Menu'
    ParentShowHint = False
    ShowHint = True
    Stretch = True
    OnClick = IExitClick
  end
  object EDir: TEdit
    Left = 8
    Top = 8
    Width = 209
    Height = 21
    TabOrder = 0
    Text = 'EDir'
  end
  object ShellTreeView1: TShellTreeView
    Left = 8
    Top = 32
    Width = 209
    Height = 201
    ObjectTypes = [otFolders]
    Root = 'rfDesktop'
    UseShellImages = True
    AutoRefresh = False
    Indent = 19
    ParentColor = False
    RightClickSelect = True
    ShowRoot = False
    TabOrder = 1
    OnChange = ShellTreeView1Change
  end
  object PB: TProgressBar
    Left = 8
    Top = 240
    Width = 209
    Height = 16
    Smooth = True
    TabOrder = 2
  end
  object XMLDocument1: TXMLDocument
    Left = 224
    Top = 64
    DOMVendorDesc = 'MSXML'
  end
end
