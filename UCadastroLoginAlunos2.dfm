object FormCadastroLoginAlunos: TFormCadastroLoginAlunos
  Left = 0
  Top = 0
  Caption = 'Cadastro de Login de Alunos'
  ClientHeight = 550
  ClientWidth = 900
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
    Width = 900
    Height = 60
    Align = alTop
    BevelOuter = bvNone
    Color = clWhite
    ParentBackground = False
    TabOrder = 0
    object lblTitulo: TLabel
      Left = 20
      Top = 15
      Width = 300
      Height = 25
      Caption = 'Cadastro de Login de Alunos'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clNavy
      Font.Height = -21
      Font.Name = 'Tahoma'
      Font.Style = [fsBold]
      ParentFont = False
    end
    object btnFechar: TButton
      Left = 800
      Top = 15
      Width = 90
      Height = 30
      Caption = 'Fechar'
      TabOrder = 0
      OnClick = btnFecharClick
    end
  end
  object PanelCadastro: TPanel
    Left = 0
    Top = 60
    Width = 900
    Height = 180
    Align = alTop
    BevelOuter = bvNone
    TabOrder = 1
    object lblCodigoAluno: TLabel
      Left = 20
      Top = 20
      Width = 90
      Height = 13
      Caption = 'Codigo do Aluno:'
    end
    object lblUsuario: TLabel
      Left = 20
      Top = 70
      Width = 40
      Height = 13
      Caption = 'Usuario:'
    end
    object lblNomeAluno: TLabel
      Left = 300
      Top = 20
      Width = 100
      Height = 13
      Caption = 'Nome do Aluno: -'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clGreen
      Font.Height = -11
      Font.Name = 'Tahoma'
      Font.Style = [fsBold]
      ParentFont = False
    end
    object edtCodigoAluno: TEdit
      Left = 20
      Top = 36
      Width = 100
      Height = 21
      TabOrder = 0
    end
    object btnBuscarAluno: TButton
      Left = 130
      Top = 34
      Width = 80
      Height = 25
      Caption = 'Buscar'
      TabOrder = 1
      OnClick = btnBuscarAlunoClick
    end
    object edtUsuario: TEdit
      Left = 20
      Top = 86
      Width = 250
      Height = 21
      TabOrder = 2
    end
    object chkAtivo: TCheckBox
      Left = 300
      Top = 86
      Width = 97
      Height = 17
      Caption = 'Ativo'
      Checked = True
      State = cbChecked
      TabOrder = 3
    end
    object btnSalvar: TButton
      Left = 20
      Top = 130
      Width = 120
      Height = 35
      Caption = 'Salvar'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -12
      Font.Name = 'Tahoma'
      Font.Style = [fsBold]
      ParentFont = False
      TabOrder = 5
      OnClick = btnSalvarClick
    end
    object btnNovo: TButton
      Left = 150
      Top = 130
      Width = 120
      Height = 35
      Caption = 'Novo'
      TabOrder = 6
      OnClick = btnNovoClick
    end
  end
  object PanelGrid: TPanel
    Left = 0
    Top = 240
    Width = 900
    Height = 310
    Align = alClient
    BevelOuter = bvNone
    TabOrder = 2
    object PanelBotoesGrid: TPanel
      Left = 0
      Top = 0
      Width = 900
      Height = 41
      Align = alTop
      BevelOuter = bvNone
      TabOrder = 0
      object btnAtualizar: TButton
        Left = 20
        Top = 8
        Width = 100
        Height = 25
        Caption = 'Atualizar Grid'
        TabOrder = 0
        OnClick = btnAtualizarClick
      end
      object btnEditar: TButton
        Left = 130
        Top = 8
        Width = 100
        Height = 25
        Caption = 'Editar'
        TabOrder = 1
        OnClick = btnEditarClick
      end
    end
    object DBGridLogins: TDBGrid
      Left = 0
      Top = 41
      Width = 900
      Height = 269
      Align = alClient
      DataSource = DataSourceAlunos
      Options = [dgTitles, dgIndicator, dgColumnResize, dgColLines, dgRowLines, dgTabs, dgRowSelect, dgConfirmDelete, dgCancelOnExit, dgTitleClick, dgTitleHotTrack]
      ReadOnly = True
      TabOrder = 1
      TitleFont.Charset = DEFAULT_CHARSET
      TitleFont.Color = clWindowText
      TitleFont.Height = -11
      TitleFont.Name = 'Tahoma'
      TitleFont.Style = []
      OnDblClick = DBGridLoginsDblClick
      Columns = <
        item
          Expanded = False
          FieldName = 'CODIGO'
          Title.Alignment = taCenter
          Title.Caption = 'Codigo'
          Width = 60
          Visible = True
        end
        item
          Expanded = False
          FieldName = 'NOME'
          Title.Alignment = taCenter
          Title.Caption = 'Nome do Aluno'
          Width = 250
          Visible = True
        end
        item
          Expanded = False
          FieldName = 'USUARIO'
          Title.Alignment = taCenter
          Title.Caption = 'Usuario'
          Width = 120
          Visible = True
        end
        item
          Expanded = False
          FieldName = 'ATIVO'
          Title.Alignment = taCenter
          Title.Caption = 'Ativo'
          Width = 50
          Visible = True
        end
        item
          Expanded = False
          FieldName = 'DATA_CADASTRO'
          Title.Alignment = taCenter
          Title.Caption = 'Data Cadastro'
          Width = 120
          Visible = True
        end>
    end
  end
  object FDConnection: TFDConnection
    Left = 800
    Top = 100
  end
  object FDQueryAlunos: TFDQuery
    Connection = FDConnection
    Left = 800
    Top = 160
  end
  object DataSourceAlunos: TDataSource
    DataSet = FDQueryAlunos
    Left = 880
    Top = 160
  end
  object FDQueryBusca: TFDQuery
    Connection = FDConnection
    Left = 800
    Top = 220
  end
end
