object FormConsultarNotas: TFormConsultarNotas
  Left = 0
  Top = 0
  Caption = 'Consultar Notas'
  ClientHeight = 600
  ClientWidth = 1000
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  Position = poScreenCenter
  OnCreate = FormCreate
  OnDestroy = FormDestroy
  PixelsPerInch = 96
  TextHeight = 13
  object PanelTopo: TPanel
    Left = 0
    Top = 0
    Width = 1000
    Height = 60
    Align = alTop
    BevelOuter = bvNone
    Color = 7747013
    ParentBackground = False
    TabOrder = 0
    object lblTitulo: TLabel
      Left = 20
      Top = 15
      Width = 184
      Height = 32
      Caption = 'Consultar Notas'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWhite
      Font.Height = -24
      Font.Name = 'Segoe UI'
      Font.Style = [fsBold]
      ParentFont = False
    end
  end
  object PanelFiltros: TPanel
    Left = 0
    Top = 60
    Width = 1000
    Height = 120
    Align = alTop
    BevelOuter = bvNone
    Color = clWhite
    ParentBackground = False
    TabOrder = 1
    object GroupBoxFiltros: TGroupBox
      Left = 20
      Top = 10
      Width = 960
      Height = 100
      Caption = ' Filtros '
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -13
      Font.Name = 'Segoe UI'
      Font.Style = [fsBold]
      ParentFont = False
      TabOrder = 0
      object LabelAno: TLabel
        Left = 20
        Top = 30
        Width = 26
        Height = 17
        Caption = 'Ano:'
        Font.Charset = DEFAULT_CHARSET
        Font.Color = clWindowText
        Font.Height = -13
        Font.Name = 'Segoe UI'
        Font.Style = []
        ParentFont = False
      end
      object LabelTurma: TLabel
        Left = 150
        Top = 30
        Width = 40
        Height = 17
        Caption = 'Turma:'
        Font.Charset = DEFAULT_CHARSET
        Font.Color = clWindowText
        Font.Height = -13
        Font.Name = 'Segoe UI'
        Font.Style = []
        ParentFont = False
      end
      object cmbAno: TComboBox
        Left = 20
        Top = 50
        Width = 120
        Height = 25
        Font.Charset = DEFAULT_CHARSET
        Font.Color = clWindowText
        Font.Height = -13
        Font.Name = 'Segoe UI'
        Font.Style = []
        ParentFont = False
        TabOrder = 0
        OnChange = cmbAnoChange
      end
      object cmbTurma: TComboBox
        Left = 150
        Top = 50
        Width = 300
        Height = 25
        Font.Charset = DEFAULT_CHARSET
        Font.Color = clWindowText
        Font.Height = -13
        Font.Name = 'Segoe UI'
        Font.Style = []
        ParentFont = False
        TabOrder = 1
      end
      object btnCarregar: TBitBtn
        Left = 470
        Top = 45
        Width = 120
        Height = 35
        Caption = 'Carregar Notas'
        Font.Charset = DEFAULT_CHARSET
        Font.Color = clWindowText
        Font.Height = -13
        Font.Name = 'Segoe UI'
        Font.Style = [fsBold]
        ParentFont = False
        TabOrder = 2
        OnClick = btnCarregarClick
      end
      object btnFechar: TBitBtn
        Left = 840
        Top = 45
        Width = 100
        Height = 35
        Caption = 'Fechar'
        Font.Charset = DEFAULT_CHARSET
        Font.Color = clWindowText
        Font.Height = -13
        Font.Name = 'Segoe UI'
        Font.Style = []
        Kind = bkClose
        NumGlyphs = 2
        ParentFont = False
        TabOrder = 3
        OnClick = btnFecharClick
      end
    end
  end
  object PanelDados: TPanel
    Left = 0
    Top = 180
    Width = 1000
    Height = 400
    Align = alClient
    BevelOuter = bvNone
    Color = clWhite
    ParentBackground = False
    TabOrder = 2
    object GroupBoxPeriodos: TGroupBox
      Left = 20
      Top = 10
      Width = 200
      Height = 400
      Caption = ' Per'#237'odos '
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -13
      Font.Name = 'Segoe UI'
      Font.Style = [fsBold]
      ParentFont = False
      TabOrder = 0
      object lstPeriodos: TListBox
        Left = 10
        Top = 20
        Width = 180
        Height = 370
        Font.Charset = DEFAULT_CHARSET
        Font.Color = clWindowText
        Font.Height = -13
        Font.Name = 'Segoe UI'
        Font.Style = []
        ItemHeight = 17
        ParentFont = False
        TabOrder = 0
        OnClick = lstPeriodosClick
      end
    end
    object GroupBoxNotas: TGroupBox
      Left = 230
      Top = 10
      Width = 750
      Height = 400
      Caption = ' Notas Lan'#231'adas '
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -13
      Font.Name = 'Segoe UI'
      Font.Style = [fsBold]
      ParentFont = False
      TabOrder = 1
      object DBGridNotas: TDBGrid
        Left = 10
        Top = 20
        Width = 730
        Height = 370
        DataSource = DataSourceNotas
        Font.Charset = DEFAULT_CHARSET
        Font.Color = clWindowText
        Font.Height = -12
        Font.Name = 'Segoe UI'
        Font.Style = []
        ParentFont = False
        TabOrder = 0
        TitleFont.Charset = DEFAULT_CHARSET
        TitleFont.Color = clWindowText
        TitleFont.Height = -13
        TitleFont.Name = 'Segoe UI'
        TitleFont.Style = [fsBold]
      end
    end
  end
  object PanelProgresso: TPanel
    Left = 0
    Top = 580
    Width = 1000
    Height = 20
    Align = alBottom
    BevelOuter = bvNone
    ParentBackground = False
    TabOrder = 3
    object LabelProgresso: TLabel
      Left = 10
      Top = 2
      Width = 39
      Height = 17
      Caption = 'Pronto'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clGray
      Font.Height = -13
      Font.Name = 'Segoe UI'
      Font.Style = []
      ParentFont = False
    end
    object ProgressBar: TProgressBar
      Left = 200
      Top = 2
      Width = 790
      Height = 16
      TabOrder = 0
    end
  end
  object FDConnection: TFDConnection
    Params.Strings = (
      'DriverID=FB'
      'Server=localhost'
      'Database=C:\ClickAcademico\ClickAcademico.FDB'
      'User_Name=SYSDBA'
      'Password=masterkey'
      'Protocol=TCPIP'
      'Port=3050')
    LoginPrompt = False
    BeforeConnect = FDConnectionBeforeConnect
    Left = 880
    Top = 200
  end
  object FDMemTableNotas: TFDMemTable
    FieldDefs = <
      item
        Name = 'CODIGO_ALUNO'
        DataType = ftString
        Size = 20
      end
      item
        Name = 'NOME_ALUNO'
        DataType = ftString
        Size = 100
      end
      item
        Name = 'DISCIPLINA'
        DataType = ftString
        Size = 100
      end
      item
        Name = 'PERIODO'
        DataType = ftString
        Size = 50
      end
      item
        Name = 'NOTA'
        DataType = ftFloat
      end
      item
        Name = 'FALTAS'
        DataType = ftInteger
      end
      item
        Name = 'PROFESSOR'
        DataType = ftString
        Size = 100
      end
      item
        Name = 'DATA_LANCAMENTO'
        DataType = ftDateTime
      end>
    IndexDefs = <>
    FetchOptions.AssignedValues = [evMode]
    FetchOptions.Mode = fmAll
    ResourceOptions.AssignedValues = [rvSilentMode]
    ResourceOptions.SilentMode = True
    UpdateOptions.AssignedValues = [uvCheckRequired, uvAutoCommitUpdates]
    UpdateOptions.CheckRequired = False
    UpdateOptions.AutoCommitUpdates = True
    StoreDefs = True
    Left = 880
    Top = 260
  end
  object DataSourceNotas: TDataSource
    DataSet = FDMemTableNotas
    Left = 880
    Top = 320
  end
end
