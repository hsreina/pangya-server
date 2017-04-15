object Console: TConsole
  Left = 0
  Top = 0
  Caption = 'Console'
  ClientHeight = 224
  ClientWidth = 655
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  Menu = MainMenu1
  OldCreateOrder = False
  OnClose = FormClose
  OnShow = FormShow
  PixelsPerInch = 96
  TextHeight = 13
  object DebugInfo: TRichEdit
    Left = 0
    Top = 0
    Width = 655
    Height = 224
    Align = alClient
    BorderStyle = bsNone
    Color = 15920102
    Ctl3D = True
    Font.Charset = ANSI_CHARSET
    Font.Color = clWindowText
    Font.Height = -11
    Font.Name = 'Lucida Console'
    Font.Style = []
    HideSelection = False
    HideScrollBars = False
    ParentCtl3D = False
    ParentFont = False
    ReadOnly = True
    ScrollBars = ssVertical
    TabOrder = 0
    Zoom = 100
  end
  object MainMenu1: TMainMenu
    Left = 8
    Top = 8
    object Log1: TMenuItem
      Caption = 'Log'
      object Clear1: TMenuItem
        Caption = 'Clear'
        OnClick = Clear1Click
      end
      object Close1: TMenuItem
        Caption = 'Close'
        OnClick = Close1Click
      end
    end
  end
end
