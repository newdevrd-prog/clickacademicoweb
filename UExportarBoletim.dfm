object FormExportarBoletim: TFormExportarBoletim
  Left = 0
  Top = 0
  Caption = 'Exportar Boletim para Firebase'
  ClientHeight = 600
  ClientWidth = 1000
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = True
  Position = poScreenCenter
  OnCreate = FormCreate
  OnDestroy = FormDestroy
  PixelsPerInch = 96
  TextHeight = 13
  object Splitter1: TSplitter
    Left = 0
    Top = 380
    Width = 1000
    Height = 5
    Cursor = crVSplit
    Align = alBottom
    ExplicitTop = 185
  end
  object PanelTop: TPanel
    Left = 0
    Top = 0
    Width = 1000
    Height = 80
    Align = alTop
    BevelOuter = bvNone
    Color = clWhite
    ParentBackground = False
    TabOrder = 0
    object lblTitulo: TLabel
      Left = 20
      Top = 15
      Width = 406
      Height = 25
      Caption = 'Exportar Boletim dos Alunos - Firebase'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clNavy
      Font.Height = -21
      Font.Name = 'Tahoma'
      Font.Style = [fsBold]
      ParentFont = False
    end
    object lblAnoLetivo: TLabel
      Left = 180
      Top = 15
      Width = 55
      Height = 13
      Caption = 'Ano Letivo:'
    end
    object lblProgresso: TLabel
      Left = 180
      Top = 30
      Width = 138
      Height = 13
      Caption = 'Exportando: 0 de 0 registros'
      Visible = False
    end
    object btnExportar: TButton
      Left = 20
      Top = 45
      Width = 150
      Height = 30
      Caption = 'Exportar Boletim'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -12
      Font.Name = 'Tahoma'
      Font.Style = [fsBold]
      ParentFont = False
      TabOrder = 0
      OnClick = btnExportarClick
    end
    object cmbAnoLetivo: TComboBox
      Left = 250
      Top = 12
      Width = 80
      Height = 21
      Style = csDropDownList
      TabOrder = 3
    end
    object btnFechar: TButton
      Left = 900
      Top = 45
      Width = 90
      Height = 30
      Caption = 'Fechar'
      TabOrder = 1
      OnClick = btnFecharClick
    end
    object ProgressBar: TProgressBar
      Left = 180
      Top = 48
      Width = 700
      Height = 25
      Smooth = True
      TabOrder = 2
      Visible = False
    end
  end
  object PanelGrid: TPanel
    Left = 0
    Top = 80
    Width = 1000
    Height = 300
    Align = alClient
    BevelOuter = bvNone
    TabOrder = 1
    object DBGridEnvios: TDBGrid
      Left = 0
      Top = 41
      Width = 1000
      Height = 259
      Align = alClient
      DataSource = DataSourceEnvios
      Options = [dgTitles, dgIndicator, dgColumnResize, dgColLines, dgRowLines, dgTabs, dgRowSelect, dgConfirmDelete, dgCancelOnExit, dgTitleClick, dgTitleHotTrack]
      ReadOnly = True
      TabOrder = 0
      TitleFont.Charset = DEFAULT_CHARSET
      TitleFont.Color = clWindowText
      TitleFont.Height = -11
      TitleFont.Name = 'Tahoma'
      TitleFont.Style = []
      Columns = <
        item
          Expanded = False
          FieldName = 'ID'
          Title.Alignment = taCenter
          Width = 50
          Visible = True
        end
        item
          Expanded = False
          FieldName = 'DATA_ENVIO'
          Title.Alignment = taCenter
          Title.Caption = 'Data Envio'
          Width = 120
          Visible = True
        end
        item
          Expanded = False
          FieldName = 'ANO_LETIVO'
          Title.Alignment = taCenter
          Title.Caption = 'Ano Letivo'
          Width = 70
          Visible = True
        end
        item
          Expanded = False
          FieldName = 'ID_ENVIO_FIREBASE'
          Title.Alignment = taCenter
          Title.Caption = 'ID Firebase'
          Width = 200
          Visible = True
        end
        item
          Expanded = False
          FieldName = 'QUANTIDADE_REGISTROS'
          Title.Alignment = taCenter
          Title.Caption = 'Qtd. Registros'
          Width = 90
          Visible = True
        end
        item
          Expanded = False
          FieldName = 'TURMA_CODIGO'
          Title.Alignment = taCenter
          Title.Caption = 'Turma'
          Width = 60
          Visible = True
        end
        item
          Expanded = False
          FieldName = 'STATUS'
          Title.Alignment = taCenter
          Title.Caption = 'Status'
          Width = 80
          Visible = True
        end>
    end
    object PanelBotoesGrid: TPanel
      Left = 0
      Top = 0
      Width = 1000
      Height = 41
      Align = alTop
      BevelOuter = bvNone
      TabOrder = 1
      object btnReverter: TButton
        Left = 20
        Top = 8
        Width = 120
        Height = 25
        Caption = 'Reverter Envio'
        TabOrder = 0
        OnClick = btnReverterClick
      end
      object btnAtualizar: TButton
        Left = 150
        Top = 8
        Width = 120
        Height = 25
        Caption = 'Atualizar Grid'
        TabOrder = 1
        OnClick = btnAtualizarClick
      end
    end
  end
  object PanelLog: TPanel
    Left = 0
    Top = 385
    Width = 1000
    Height = 215
    Align = alBottom
    BevelOuter = bvNone
    TabOrder = 2
    object MemoLog: TMemo
      Left = 0
      Top = 0
      Width = 1000
      Height = 215
      Align = alClient
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -11
      Font.Name = 'Courier New'
      Font.Style = []
      ParentFont = False
      ReadOnly = True
      ScrollBars = ssBoth
      TabOrder = 0
    end
  end
  object FDConnection: TFDConnection
    Left = 800
    Top = 100
  end
  object FDQueryBoletim: TFDQuery
    Connection = FDConnection
    Left = 880
    Top = 100
  end
  object FDQueryEnvios: TFDQuery
    Connection = FDConnection
    Left = 880
    Top = 160
  end
  object DataSourceEnvios: TDataSource
    DataSet = FDQueryEnvios
    Left = 960
    Top = 160
  end
  object FDPhysFBDriverLink: TFDPhysFBDriverLink
    Left = 800
    Top = 160
  end
end
