object FormConfigBoletim: TFormConfigBoletim
  Left = 0
  Top = 0
  BorderIcons = [biSystemMenu]
  BorderStyle = bsDialog
  Caption = 'Configura'#231#245'es do Boletim'
  ClientHeight = 750
  ClientWidth = 892
  Color = clBtnFace
  DoubleBuffered = True
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
  object PanelCampos: TPanel
    Left = 0
    Top = 0
    Width = 892
    Height = 690
    Align = alClient
    BevelOuter = bvNone
    Padding.Left = 20
    Padding.Top = 20
    Padding.Right = 20
    Padding.Bottom = 20
    TabOrder = 0
    ExplicitWidth = 600
    object LabelNomeEscola: TLabel
      Left = 20
      Top = 20
      Width = 852
      Height = 15
      Align = alTop
      Caption = 'Nome da Escola *'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -12
      Font.Name = 'Segoe UI'
      Font.Style = [fsBold]
      ParentFont = False
      ExplicitWidth = 94
    end
    object LabelEndereco: TLabel
      Left = 20
      Top = 58
      Width = 852
      Height = 15
      Align = alTop
      Caption = 'Endere'#231'o'
      ExplicitWidth = 49
    end
    object LabelTelefone: TLabel
      Left = 20
      Top = 96
      Width = 852
      Height = 15
      Align = alTop
      Caption = 'Telefone'
      ExplicitWidth = 44
    end
    object LabelEmail: TLabel
      Left = 20
      Top = 134
      Width = 852
      Height = 15
      Align = alTop
      Caption = 'Email'
      ExplicitWidth = 29
    end
    object LabelSite: TLabel
      Left = 20
      Top = 172
      Width = 852
      Height = 15
      Align = alTop
      Caption = 'Site'
      ExplicitWidth = 19
    end
    object LabelTitulo: TLabel
      Left = 20
      Top = 210
      Width = 852
      Height = 15
      Align = alTop
      Caption = 'T'#237'tulo do Boletim'
      ExplicitWidth = 91
    end
    object LabelLogo: TLabel
      Left = 612
      Top = 309
      Width = 60
      Height = 15
      Caption = 'Logomarca'
    end
    object imgLogoPreview: TImage
      Left = 612
      Top = 391
      Width = 245
      Height = 186
      Center = True
      Proportional = True
      Stretch = True
    end
    object lblStatus: TLabel
      Left = 20
      Top = 655
      Width = 852
      Height = 15
      Align = alBottom
      Alignment = taCenter
      Caption = 'Pronto'
      ExplicitWidth = 36
    end
    object LabelTemaCores: TLabel
      Left = 20
      Top = 248
      Width = 852
      Height = 15
      Align = alTop
      Caption = 'Tema de Cores'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -12
      Font.Name = 'Segoe UI'
      Font.Style = [fsBold]
      ParentFont = False
      ExplicitWidth = 81
    end
    object LabelCorPrimaria: TLabel
      Left = 20
      Top = 290
      Width = 66
      Height = 15
      Caption = 'Cor Primaria'
    end
    object LabelCorSecundaria: TLabel
      Left = 20
      Top = 334
      Width = 80
      Height = 15
      Caption = 'Cor Secundaria'
    end
    object LabelOrdenacao: TLabel
      Left = 20
      Top = 375
      Width = 852
      Height = 15
      Caption = 'Ordena'#231#227'o das Disciplinas'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -12
      Font.Name = 'Segoe UI'
      Font.Style = [fsBold]
      ParentFont = False
    end
    object lblInfoOrdenacao: TLabel
      Left = 20
      Top = 593
      Width = 557
      Height = 13
      Caption = 
        'Use os bot'#245'es ao lado para ordenar as disciplinas. A ordem defin' +
        'ida aqui ser'#225' usada no boletim dos alunos.'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clGray
      Font.Height = -11
      Font.Name = 'Segoe UI'
      Font.Style = []
      ParentFont = False
      WordWrap = True
    end
    object cmbTemaCores: TComboBox
      Left = 20
      Top = 263
      Width = 852
      Height = 23
      Align = alTop
      Style = csDropDownList
      TabOrder = 11
      OnChange = cmbTemaCoresChange
      Items.Strings = (
        'Verde (Padrao)'
        'Azul'
        'Vermelho'
        'Roxo'
        'Laranja'
        'Rosa'
        'Azul Escuro'
        'Cinza')
      ExplicitWidth = 560
    end
    object edtNomeEscola: TEdit
      Left = 20
      Top = 35
      Width = 852
      Height = 23
      Align = alTop
      TabOrder = 0
      ExplicitWidth = 560
    end
    object edtEndereco: TEdit
      Left = 20
      Top = 73
      Width = 852
      Height = 23
      Align = alTop
      TabOrder = 1
      ExplicitWidth = 560
    end
    object edtTelefone: TEdit
      Left = 20
      Top = 111
      Width = 852
      Height = 23
      Align = alTop
      TabOrder = 2
      ExplicitWidth = 560
    end
    object edtEmail: TEdit
      Left = 20
      Top = 149
      Width = 852
      Height = 23
      Align = alTop
      TabOrder = 3
      ExplicitWidth = 560
    end
    object edtSite: TEdit
      Left = 20
      Top = 187
      Width = 852
      Height = 23
      Align = alTop
      TabOrder = 4
      ExplicitWidth = 560
    end
    object edtTitulo: TEdit
      Left = 20
      Top = 225
      Width = 852
      Height = 23
      Align = alTop
      TabOrder = 5
      ExplicitWidth = 560
    end
    object btnCarregarLogo: TBitBtn
      Left = 612
      Top = 332
      Width = 120
      Height = 30
      Caption = 'Selecionar...'
      TabOrder = 10
      OnClick = btnCarregarLogoClick
    end
    object colorPrimaria: TColorBox
      Left = 20
      Top = 305
      Width = 475
      Height = 22
      DefaultColorColor = clGreen
      Selected = 5287756
      Style = [cbStandardColors, cbExtendedColors, cbSystemColors, cbIncludeNone, cbIncludeDefault, cbCustomColor, cbPrettyNames]
      TabOrder = 6
    end
    object btnResetCorPrimaria: TBitBtn
      Left = 500
      Top = 305
      Width = 80
      Height = 22
      Caption = 'Padrao'
      TabOrder = 8
      OnClick = btnResetCorPrimariaClick
    end
    object colorSecundaria: TColorBox
      Left = 20
      Top = 349
      Width = 475
      Height = 22
      DefaultColorColor = clGreen
      Selected = 3308846
      Style = [cbStandardColors, cbExtendedColors, cbSystemColors, cbIncludeNone, cbIncludeDefault, cbCustomColor, cbPrettyNames]
      TabOrder = 7
    end
    object btnResetCorSecundaria: TBitBtn
      Left = 500
      Top = 349
      Width = 80
      Height = 22
      Caption = 'Padrao'
      TabOrder = 9
      OnClick = btnResetCorSecundariaClick
    end
    object btnCarregarDisciplinas: TBitBtn
      Left = 20
      Top = 392
      Width = 560
      Height = 30
      Caption = 'Carregar Disciplinas do Firebase'
      TabOrder = 12
      OnClick = btnCarregarDisciplinasClick
    end
    object lbDisciplinas: TListBox
      Left = 22
      Top = 431
      Width = 480
      Height = 160
      ItemHeight = 15
      TabOrder = 13
    end
    object btnSubir: TBitBtn
      Left = 510
      Top = 444
      Width = 70
      Height = 40
      Caption = #8593' Subir'
      TabOrder = 14
      OnClick = btnSubirClick
    end
    object btnDescer: TBitBtn
      Left = 510
      Top = 489
      Width = 70
      Height = 40
      Caption = #8595' Descer'
      TabOrder = 15
      OnClick = btnDescerClick
    end
    object btnRestaurarOrdem: TBitBtn
      Left = 510
      Top = 534
      Width = 70
      Height = 40
      Caption = 'Padr'#227'o'
      TabOrder = 16
      OnClick = btnRestaurarOrdemClick
    end
  end
  object PanelBotoes: TPanel
    Left = 0
    Top = 690
    Width = 892
    Height = 60
    Align = alBottom
    BevelOuter = bvNone
    Padding.Left = 20
    Padding.Top = 10
    Padding.Right = 20
    Padding.Bottom = 10
    TabOrder = 1
    ExplicitWidth = 600
    object btnSalvar: TBitBtn
      Left = 722
      Top = 10
      Width = 75
      Height = 40
      Align = alRight
      Caption = '&Salvar'
      Default = True
      TabOrder = 0
      OnClick = btnSalvarClick
      ExplicitLeft = 430
    end
    object btnCancelar: TBitBtn
      Left = 797
      Top = 10
      Width = 75
      Height = 40
      Align = alRight
      Cancel = True
      Caption = '&Cancelar'
      ModalResult = 2
      TabOrder = 1
      OnClick = btnCancelarClick
      ExplicitLeft = 505
    end
  end
  object OpenDialogLogo: TOpenDialog
    Filter = 'Imagens|*.jpg;*.jpeg;*.png;*.bmp;*.gif'
    Title = 'Selecionar Logomarca'
    Left = 552
    Top = 432
  end
end
