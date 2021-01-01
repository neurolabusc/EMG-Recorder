object MobiRecordForm: TMobiRecordForm
  Left = 371
  Top = 217
  Width = 990
  Height = 465
  Caption = 'MobiRecordForm'
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  Menu = MainMenu1
  OldCreateOrder = False
  OnClose = FormClose
  OnCreate = FormCreate
  OnDestroy = FormDestroy
  OnResize = FormResize
  OnShow = FormShow
  PixelsPerInch = 96
  TextHeight = 13
  object Image1: TImage
    Left = 0
    Top = 24
    Width = 982
    Height = 376
    Align = alClient
  end
  object TimeImage: TImage
    Left = 0
    Top = 0
    Width = 982
    Height = 24
    Align = alTop
  end
  object AxSerialSource1: TSerialSource
    Left = 64
    Top = 48
    Width = 192
    Height = 192
    TabOrder = 0
    Visible = False
    ControlData = {
      69534D54DD3F9511386ADF428DD2C6C670815E06C3000000B700000002000000
      0000C20100000000000000000006000000010000000D53657269616C20446576
      696365000048420000000000000000695143410C53657269616C20496E707574
      0653657269616C0000000039424CF91EF7E84CA30454E0F9A9AC300000000001
      0000001400000001000000000000000400020000000000000000000100000010
      000000000000009C00000004000200000000000000000010070000D8130000D8
      130000}
  end
  object StatusBar1: TStatusBar
    Left = 0
    Top = 400
    Width = 982
    Height = 19
    Panels = <
      item
        Width = 300
      end
      item
        Width = 320
      end
      item
        Width = 50
      end>
  end
  object Timer1: TTimer
    Enabled = False
    Interval = 100
    OnTimer = Timer1Timer
    Left = 48
    Top = 24
  end
  object MainMenu1: TMainMenu
    Left = 136
    Top = 24
    object File1: TMenuItem
      Caption = 'File'
      object Savedata1: TMenuItem
        Caption = 'Save data...'
        ShortCut = 16467
        OnClick = Savedata1Click
      end
      object Exit1: TMenuItem
        Caption = 'Exit'
        OnClick = Exit1Click
      end
    end
    object Edit1: TMenuItem
      Caption = 'Edit'
      object Acquire1: TMenuItem
        AutoCheck = True
        Caption = 'Acquire'
        ShortCut = 16451
        OnClick = Acquire1Click
      end
    end
    object View1: TMenuItem
      Caption = 'View'
      object Vertical1: TMenuItem
        Caption = 'Preferences...'
        ShortCut = 16464
        OnClick = Vertical1Click
      end
      object Horizontal1: TMenuItem
        Caption = 'Horizontal scale'
        object ZoomIn1: TMenuItem
          Caption = 'Zoom in'
          ShortCut = 16456
          OnClick = ZoomIn1Click
        end
        object Zoomout1: TMenuItem
          Caption = 'Zoom out'
          ShortCut = 49224
          OnClick = Zoomout1Click
        end
      end
      object Rescale1: TMenuItem
        Caption = 'Rescale'
        ShortCut = 112
        OnClick = Rescale1Click
      end
      object Audio1: TMenuItem
        AutoCheck = True
        Caption = 'Audio'
        ShortCut = 16449
        OnClick = Audio1Click
      end
    end
    object Events1: TMenuItem
      Caption = 'Events'
      object Showevent: TMenuItem
        AutoCheck = True
        Caption = 'Show events'
        OnClick = ShoweventClick
      end
      object Verticalscale1: TMenuItem
        Caption = 'Vertical scale'
        OnClick = Verticalscale1Click
      end
      object Horizontalscale1: TMenuItem
        Caption = 'Horizontal scale'
        object Zoomin2: TMenuItem
          Caption = 'Zoom in'
          OnClick = Zoomin2Click
        end
        object Zoomout2: TMenuItem
          Caption = 'Zoom out'
          OnClick = Zoomout2Click
        end
      end
      object Samples1: TMenuItem
        Caption = 'Samples'
        OnClick = Samples1Click
      end
    end
    object Help1: TMenuItem
      Caption = 'Help'
      object About1: TMenuItem
        Caption = 'About'
        OnClick = About1Click
      end
    end
  end
  object SaveDialog1: TSaveDialog
    DefaultExt = '*.vhdr'
    Filter = 'BrainVision|*.vhdr|TMS32|*.S00'
    Left = 8
    Top = 24
  end
  object RescaleTimer: TTimer
    Enabled = False
    OnTimer = RescaleTimerTimer
    Left = 88
    Top = 24
  end
end
