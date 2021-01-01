object PrefsForm: TPrefsForm
  Left = 217
  Top = 90
  BorderStyle = bsDialog
  Caption = 'Prefs'
  ClientHeight = 241
  ClientWidth = 259
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  OldCreateOrder = False
  Position = poScreenCenter
  OnShow = FormShow
  PixelsPerInch = 96
  TextHeight = 13
  object Label1: TLabel
    Left = 8
    Top = 12
    Width = 91
    Height = 13
    Caption = 'High pass filter (Hz)'
  end
  object Label2: TLabel
    Left = 8
    Top = 60
    Width = 93
    Height = 13
    Caption = 'Max recording (sec)'
  end
  object Label3: TLabel
    Left = 8
    Top = 36
    Width = 86
    Height = 13
    Caption = 'Sample Rate (Hz))'
  end
  object Label4: TLabel
    Left = 8
    Top = 108
    Width = 78
    Height = 13
    Caption = 'Record       Filter'
  end
  object TriggerLabel: TLabel
    Left = 8
    Top = 84
    Width = 74
    Height = 13
    Caption = 'Trigger channel'
  end
  object HighPassHzEdit: TSpinEdit
    Left = 152
    Top = 8
    Width = 96
    Height = 22
    MaxValue = 0
    MinValue = 0
    TabOrder = 0
    Value = 0
  end
  object MaxRecordSecEdit: TSpinEdit
    Left = 152
    Top = 56
    Width = 96
    Height = 22
    MaxValue = 0
    MinValue = 0
    TabOrder = 1
    Value = 2048
  end
  object SampleRateHzEdit: TSpinEdit
    Left = 152
    Top = 32
    Width = 96
    Height = 22
    MaxValue = 0
    MinValue = 0
    TabOrder = 2
    Value = 1800
  end
  object CancelBtn: TButton
    Left = 8
    Top = 208
    Width = 75
    Height = 25
    Caption = 'Cancel'
    ModalResult = 2
    TabOrder = 3
  end
  object OKBtn: TButton
    Left = 168
    Top = 208
    Width = 75
    Height = 25
    Caption = 'OK'
    ModalResult = 1
    TabOrder = 4
    OnClick = OKBtnClick
  end
  object TriggerChannelEdit: TSpinEdit
    Left = 152
    Top = 80
    Width = 96
    Height = 22
    MaxValue = 0
    MinValue = 0
    TabOrder = 5
    Value = 2048
    OnChange = TriggerChannelEditChange
  end
end
