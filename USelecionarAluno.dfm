object FormSelecionarAluno: TFormSelecionarAluno
  Left = 0
  Top = 0
  BorderStyle = bsDialog
  Caption = 'Selecionar Aluno'
  ClientHeight = 450
  ClientWidth = 700
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = True
  Position = poScreenCenter
  OnCreate = FormCreate
  PixelsPerInch = 96
  TextHeight = 13
  object PanelTop: TPanel
    Left = 0
    Top = 0
    Width = 700
    Height = 60
    Align = alTop
    BevelOuter = bvNone
    Color = clWhite
    ParentBackground = False
    TabOrder = 0
    object lblTitulo: TLabel
      Left = 20
      Top = 15
      Width = 173
      Height = 25
      Caption = 'Selecionar Aluno'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clNavy
      Font.Height = -21
      Font.Name = 'Tahoma'
      Font.Style = [fsBold]
      ParentFont = False
    end
    object btnFechar: TButton
      Left = 590
      Top = 15
      Width = 90
      Height = 30
      Caption = 'Cancelar'
      TabOrder = 0
      OnClick = btnFecharClick
    end
  end
  object PanelBusca: TPanel
    Left = 0
    Top = 60
    Width = 700
    Height = 60
    Align = alTop
    BevelOuter = bvNone
    TabOrder = 1
    object lblBusca: TLabel
      Left = 20
      Top = 20
      Width = 111
      Height = 13
      Caption = 'Buscar (Nome ou CPF):'
    end
    object edtBusca: TEdit
      Left = 130
      Top = 17
      Width = 400
      Height = 21
      TabOrder = 0
      OnKeyPress = edtBuscaKeyPress
    end
    object btnBuscar: TButton
      Left = 540
      Top = 15
      Width = 60
      Height = 25
      Caption = 'Buscar'
      TabOrder = 1
      OnClick = btnBuscarClick
    end
    object btnLimpar: TButton
      Left = 610
      Top = 15
      Width = 60
      Height = 25
      Caption = 'Limpar'
      TabOrder = 2
      OnClick = btnLimparClick
    end
  end
  object PanelGrid: TPanel
    Left = 0
    Top = 120
    Width = 700
    Height = 290
    Align = alClient
    BevelOuter = bvNone
    TabOrder = 2
    object DBGridAlunos: TDBGrid
      Left = 0
      Top = 0
      Width = 700
      Height = 290
      Align = alClient
      DataSource = DataSourceAlunos
      Options = [dgTitles, dgIndicator, dgColumnResize, dgColLines, dgRowLines, dgTabs, dgRowSelect, dgAlwaysShowSelection, dgConfirmDelete, dgCancelOnExit, dgTitleClick, dgTitleHotTrack]
      TabOrder = 0
      TitleFont.Charset = DEFAULT_CHARSET
      TitleFont.Color = clWindowText
      TitleFont.Height = -11
      TitleFont.Name = 'Tahoma'
      TitleFont.Style = []
      OnDblClick = DBGridAlunosDblClick
      Columns = <
        item
          Expanded = False
          FieldName = 'CODIGO'
          Title.Alignment = taCenter
          Title.Caption = 'C'#243'digo'
          Width = 60
          Visible = True
        end
        item
          Expanded = False
          FieldName = 'NOME'
          Title.Alignment = taCenter
          Title.Caption = 'Nome do Aluno'
          Width = 400
          Visible = True
        end
        item
          Expanded = False
          FieldName = 'CPF'
          Title.Alignment = taCenter
          Width = 120
          Visible = True
        end>
    end
  end
  object PanelBotoes: TPanel
    Left = 0
    Top = 410
    Width = 700
    Height = 40
    Align = alBottom
    BevelOuter = bvNone
    TabOrder = 3
    object btnSelecionar: TButton
      Left = 280
      Top = 5
      Width = 140
      Height = 30
      Caption = 'Selecionar Aluno'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -12
      Font.Name = 'Tahoma'
      Font.Style = [fsBold]
      ParentFont = False
      TabOrder = 0
      OnClick = btnSelecionarClick
    end
  end
  object FDMemTableAlunos: TFDMemTable
    FetchOptions.AssignedValues = [evMode]
    FetchOptions.Mode = fmAll
    ResourceOptions.AssignedValues = [rvSilentMode]
    ResourceOptions.SilentMode = True
    UpdateOptions.AssignedValues = [uvCheckRequired, uvAutoCommitUpdates]
    UpdateOptions.CheckRequired = False
    UpdateOptions.AutoCommitUpdates = True
    Left = 60
    Top = 200
  end
  object DataSourceAlunos: TDataSource
    DataSet = FDMemTableAlunos
    Left = 140
    Top = 200
  end
end
