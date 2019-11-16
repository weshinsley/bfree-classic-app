object FMain: TFMain
  Left = 538
  Top = 246
  ActiveControl = SGSongs
  BorderIcons = []
  BorderStyle = bsNone
  Caption = 'FMain'
  ClientHeight = 423
  ClientWidth = 637
  Color = clWhite
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  OldCreateOrder = False
  WindowState = wsMaximized
  OnActivate = FormActivate
  OnCreate = FormCreate
  PixelsPerInch = 96
  TextHeight = 13
  object IPic: TImage
    Left = 0
    Top = 104
    Width = 761
    Height = 473
    ParentShowHint = False
    ShowHint = True
    Stretch = True
  end
  object IHeader: TImage
    Left = 0
    Top = 0
    Width = 729
    Height = 105
    ParentShowHint = False
    ShowHint = True
    Stretch = True
  end
  object LVersion: TLabel
    Left = 8
    Top = 552
    Width = 528
    Height = 18
    Caption = 
      'BFree Manual '#169' 2013 Teapot Records Media Division. Software v2.3' +
      '8, All Rights Reserved'
    Color = clWhite
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clBlack
    Font.Height = -13
    Font.Name = 'Trebuchet MS'
    Font.Style = []
    ParentColor = False
    ParentFont = False
    Transparent = True
  end
  object IChords: TImage
    Left = 560
    Top = 112
    Width = 33
    Height = 41
    ParentShowHint = False
    ShowHint = True
    Stretch = True
    OnClick = IChordsClick
  end
  object IMidi: TImage
    Left = 464
    Top = 112
    Width = 41
    Height = 41
    ParentShowHint = False
    ShowHint = True
    Stretch = True
    OnClick = IMidiClick
  end
  object ISheet: TImage
    Left = 600
    Top = 112
    Width = 33
    Height = 41
    ParentShowHint = False
    ShowHint = True
    Stretch = True
    OnClick = ISheetClick
  end
  object IArticle: TImage
    Left = 512
    Top = 112
    Width = 41
    Height = 41
    ParentShowHint = False
    ShowHint = True
    Stretch = True
    OnClick = IArticleClick
  end
  object IMP3: TImage
    Left = 712
    Top = 112
    Width = 41
    Height = 41
    ParentShowHint = False
    ShowHint = True
    Stretch = True
    OnClick = IMP3Click
  end
  object IWinAmp: TImage
    Left = 8
    Top = 480
    Width = 49
    Height = 57
    Hint = 'Install WinAmp 3.0'
    ParentShowHint = False
    ShowHint = True
    Stretch = True
    OnClick = IWinAmpClick
  end
  object IAdobe: TImage
    Left = 72
    Top = 480
    Width = 49
    Height = 57
    Hint = 'Install Adobe Acrobat 6.0.1'
    ParentShowHint = False
    ShowHint = True
    Stretch = True
    OnClick = IAdobeClick
  end
  object IPrint: TImage
    Left = 96
    Top = 32
    Width = 49
    Height = 65
    Hint = 'Print All Songs on List'
    ParentShowHint = False
    ShowHint = True
    Stretch = True
    OnClick = IPrintClick
  end
  object ISearch: TImage
    Left = 160
    Top = 112
    Width = 17
    Height = 25
    Hint = 'Search lyrics for text'
    ParentShowHint = False
    ShowHint = True
    Stretch = True
    OnClick = ISearchClick
  end
  object IExit: TImage
    Left = 696
    Top = 456
    Width = 49
    Height = 49
    ParentShowHint = False
    ShowHint = True
    Stretch = True
    OnClick = IExitClick
  end
  object IGChords: TImage
    Left = 568
    Top = 120
    Width = 25
    Height = 25
    ParentShowHint = False
    ShowHint = True
    Stretch = True
  end
  object IGArticle: TImage
    Left = 520
    Top = 120
    Width = 25
    Height = 25
    ParentShowHint = False
    ShowHint = True
    Stretch = True
  end
  object IGMidi: TImage
    Left = 472
    Top = 120
    Width = 25
    Height = 25
    ParentShowHint = False
    ShowHint = True
    Stretch = True
  end
  object IGMP3: TImage
    Left = 720
    Top = 120
    Width = 25
    Height = 25
    ParentShowHint = False
    ShowHint = True
    Stretch = True
  end
  object IGSheet: TImage
    Left = 608
    Top = 120
    Width = 25
    Height = 25
    ParentShowHint = False
    ShowHint = True
    Stretch = True
  end
  object IPrintChords: TImage
    Left = 560
    Top = 160
    Width = 25
    Height = 25
    ParentShowHint = False
    ShowHint = True
    Stretch = True
    OnClick = IPrintChordsClick
  end
  object IPrintSheet: TImage
    Left = 600
    Top = 160
    Width = 25
    Height = 25
    ParentShowHint = False
    ShowHint = True
    Stretch = True
    OnClick = IPrintSheetClick
  end
  object IPrintArticle: TImage
    Left = 520
    Top = 160
    Width = 25
    Height = 25
    ParentShowHint = False
    ShowHint = True
    Stretch = True
    OnClick = IPrintArticleClick
  end
  object IGPrintArticle: TImage
    Left = 512
    Top = 160
    Width = 25
    Height = 25
    ParentShowHint = False
    ShowHint = True
    Stretch = True
  end
  object IGPrintSheet: TImage
    Left = 600
    Top = 176
    Width = 25
    Height = 25
    ParentShowHint = False
    ShowHint = True
    Stretch = True
  end
  object IGPrintChords: TImage
    Left = 560
    Top = 192
    Width = 25
    Height = 25
    ParentShowHint = False
    ShowHint = True
    Stretch = True
  end
  object IMinimise: TImage
    Left = 736
    Top = 8
    Width = 17
    Height = 19
    OnClick = IMinimiseClick
  end
  object IResetSearch: TImage
    Left = 184
    Top = 112
    Width = 17
    Height = 25
    Hint = 'Show All Songs'
    ParentShowHint = False
    ShowHint = True
    Stretch = True
    OnClick = IResetSearchClick
  end
  object IUpdate: TImage
    Left = 128
    Top = 480
    Width = 49
    Height = 49
    ParentShowHint = False
    ShowHint = True
    Stretch = True
    OnClick = IUpdateClick
  end
  object IInstall: TImage
    Left = 184
    Top = 480
    Width = 49
    Height = 49
    ParentShowHint = False
    ShowHint = True
    Stretch = True
    OnClick = IInstallClick
  end
  object LShowAll: TLabel
    Left = 296
    Top = 16
    Width = 132
    Height = 22
    Caption = 'Show All Songs'
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -19
    Font.Name = 'Arial'
    Font.Style = []
    ParentFont = False
    Transparent = True
  end
  object CBLists: TComboBox
    Left = 216
    Top = 40
    Width = 241
    Height = 32
    Style = csDropDownList
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -19
    Font.Name = 'Trebuchet MS'
    Font.Style = []
    ItemHeight = 24
    ParentFont = False
    TabOrder = 0
    OnChange = CBListsChange
  end
  object SGSongs: TStringGrid
    Left = 8
    Top = 192
    Width = 545
    Height = 217
    DefaultRowHeight = 18
    FixedColor = clWindow
    FixedCols = 0
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -13
    Font.Name = 'Arial'
    Font.Style = []
    Options = [goFixedVertLine, goFixedHorzLine, goVertLine, goHorzLine, goColSizing, goRowSelect]
    ParentFont = False
    TabOrder = 1
    OnKeyPress = SGSongsKeyPress
    OnKeyUp = SGSongsKeyUp
    OnMouseUp = SGSongsMouseUp
    OnMouseWheelDown = SGSongsMouseWheelDown
    OnMouseWheelUp = SGSongsMouseWheelUp
    ColWidths = (
      152
      115
      112
      64
      64)
  end
  object CLBPrint: TCheckListBox
    Left = 268
    Top = 72
    Width = 189
    Height = 96
    BiDiMode = bdRightToLeftNoAlign
    Flat = False
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -16
    Font.Name = 'Trebuchet MS'
    Font.Style = []
    ItemHeight = 22
    Items.Strings = (
      'Words & Chords'
      'Sheet Music'
      'Articles'
      'Index')
    ParentBiDiMode = False
    ParentFont = False
    TabOrder = 2
  end
  object ESearch: TEdit
    Left = 32
    Top = 112
    Width = 121
    Height = 30
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -19
    Font.Name = 'MS Trebuchet'
    Font.Style = []
    ParentFont = False
    TabOrder = 3
    Text = 'Search through lyrics of these songs'
    OnClick = ESearchClick
    OnKeyPress = ESearchKeyPress
  end
  object CBAll: TCheckBox
    Left = 264
    Top = 24
    Width = 14
    Height = 16
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -19
    Font.Name = 'MS Sans Serif'
    Font.Style = []
    ParentFont = False
    TabOrder = 4
    OnClick = CBAllClick
  end
  object XMan: TXMLDocument
    Active = True
    Top = 112
    DOMVendorDesc = 'Open XML'
  end
  object TcpClient: TTcpClient
    Left = 720
    Top = 512
  end
end
