object FormExportarDados: TFormExportarDados
  Left = 0
  Top = 0
  BorderIcons = [biSystemMenu]
  BorderStyle = bsDialog
  Caption = 'Exportar Dados para Firebase'
  ClientHeight = 608
  ClientWidth = 900
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -12
  Font.Name = 'Segoe UI'
  Font.Style = []
  OldCreateOrder = True
  Position = poScreenCenter
  OnCreate = FormCreate
  OnShow = FormShow
  PixelsPerInch = 96
  TextHeight = 15
  object PanelTopo: TPanel
    Left = 0
    Top = 0
    Width = 900
    Height = 80
    Align = alTop
    BevelOuter = bvNone
    Padding.Left = 20
    Padding.Top = 15
    Padding.Right = 20
    Padding.Bottom = 15
    TabOrder = 0
    object lblTitulo: TLabel
      Left = 20
      Top = 15
      Width = 860
      Height = 50
      Align = alClient
      Alignment = taCenter
      Caption = 'Exportar Dados do Firebird para Firebase'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -24
      Font.Name = 'Segoe UI'
      Font.Style = [fsBold]
      ParentFont = False
      ExplicitWidth = 470
      ExplicitHeight = 32
    end
  end
  object PanelConfig: TPanel
    Left = 0
    Top = 80
    Width = 900
    Height = 100
    Align = alTop
    BevelOuter = bvNone
    Padding.Left = 20
    Padding.Top = 10
    Padding.Right = 20
    Padding.Bottom = 10
    TabOrder = 1
    object GroupBoxConfig: TGroupBox
      Left = 20
      Top = 10
      Width = 860
      Height = 80
      Align = alClient
      Caption = 'Configura'#231#245'es de Exporta'#231#227'o'
      TabOrder = 0
      object LabelAnoMatricula: TLabel
        Left = 16
        Top = 24
        Width = 106
        Height = 15
        Caption = 'Ano das Matr'#237'culas:'
        Font.Charset = DEFAULT_CHARSET
        Font.Color = clWindowText
        Font.Height = -12
        Font.Name = 'Segoe UI'
        Font.Style = [fsBold]
        ParentFont = False
      end
      object cmbAnoMatricula: TComboBox
        Left = 172
        Top = 20
        Width = 120
        Height = 23
        Style = csDropDownList
        TabOrder = 0
      end
      object chkSobrescrever: TCheckBox
        Left = 16
        Top = 50
        Width = 280
        Height = 17
        Caption = 'Sobrescrever registros existentes (update)'
        Checked = True
        State = cbChecked
        TabOrder = 1
      end
      object btnExportarTodos: TBitBtn
        Left = 320
        Top = 24
        Width = 200
        Height = 35
        Caption = 'Exportar Todos os Dados'
        TabOrder = 2
        OnClick = btnExportarTodosClick
      end
      object btnFechar: TBitBtn
        Left = 740
        Top = 24
        Width = 100
        Height = 35
        Caption = 'Fechar'
        TabOrder = 3
        OnClick = btnFecharClick
      end
    end
  end
  object PanelProgresso: TPanel
    Left = 0
    Top = 180
    Width = 900
    Height = 60
    Align = alTop
    BevelOuter = bvNone
    Padding.Left = 20
    Padding.Top = 10
    Padding.Right = 20
    Padding.Bottom = 10
    TabOrder = 2
    object LabelProgresso: TLabel
      Left = 20
      Top = 10
      Width = 860
      Height = 15
      Align = alTop
      Caption = 'Pronto'
      ExplicitWidth = 36
    end
    object ProgressBarTotal: TProgressBar
      Left = 20
      Top = 30
      Width = 860
      Height = 20
      Align = alBottom
      TabOrder = 0
    end
  end
  object PanelLog: TPanel
    Left = 0
    Top = 240
    Width = 900
    Height = 220
    Align = alTop
    BevelOuter = bvNone
    Padding.Left = 20
    Padding.Top = 10
    Padding.Right = 20
    Padding.Bottom = 10
    TabOrder = 3
    object GroupBoxLog: TGroupBox
      Left = 20
      Top = 10
      Width = 860
      Height = 200
      Align = alClient
      Caption = 'Log de Exporta'#231#227'o'
      TabOrder = 0
      object MemoLog: TMemo
        Left = 2
        Top = 17
        Width = 856
        Height = 181
        Align = alClient
        Font.Charset = DEFAULT_CHARSET
        Font.Color = clWindowText
        Font.Height = -11
        Font.Name = 'Consolas'
        Font.Style = []
        ParentFont = False
        ReadOnly = True
        ScrollBars = ssVertical
        TabOrder = 0
      end
    end
  end
  object PanelHistorico: TPanel
    Left = 0
    Top = 460
    Width = 900
    Height = 148
    Align = alClient
    BevelOuter = bvNone
    Padding.Left = 20
    Padding.Top = 10
    Padding.Right = 20
    Padding.Bottom = 20
    TabOrder = 4
    ExplicitHeight = 240
    object GroupBoxHistorico: TGroupBox
      Left = 20
      Top = 10
      Width = 860
      Height = 118
      Align = alClient
      Caption = 'Hist'#243'rico de Exporta'#231#245'es'
      TabOrder = 0
      ExplicitHeight = 210
      object DBGridHistorico: TDBGrid
        Left = 2
        Top = 17
        Width = 856
        Height = 99
        Align = alClient
        DataSource = DataSourceHistorico
        Options = [dgTitles, dgIndicator, dgColumnResize, dgColLines, dgRowLines, dgTabs, dgRowSelect, dgConfirmDelete, dgCancelOnExit, dgTitleClick, dgTitleHotTrack]
        TabOrder = 0
        TitleFont.Charset = DEFAULT_CHARSET
        TitleFont.Color = clWindowText
        TitleFont.Height = -12
        TitleFont.Name = 'Segoe UI'
        TitleFont.Style = []
      end
    end
  end
  object FDConnection: TFDConnection
    Params.Strings = (
      'Database=C:\ClickAcademico\CLICKACADEMICO.fdb'
      'User_Name=sysdba'
      'Password=masterkey'
      'Server=localhost'
      'DriverID=FB')
    LoginPrompt = False
    Left = 48
    Top = 560
  end
  object FDQueryExportacao: TFDQuery
    Connection = FDConnection
    Left = 144
    Top = 560
  end
  object FDQueryLog: TFDQuery
    Connection = FDConnection
    Left = 240
    Top = 560
  end
  object FDQueryInsertLog: TFDQuery
    Connection = FDConnection
    Left = 336
    Top = 560
  end
  object DataSourceHistorico: TDataSource
    DataSet = FDQueryLog
    Left = 432
    Top = 560
  end
end
