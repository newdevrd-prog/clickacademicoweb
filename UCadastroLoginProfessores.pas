unit UCadastroLoginProfessores;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls, Vcl.ExtCtrls, Vcl.Grids, Vcl.DBGrids,
  Vcl.ComCtrls, Data.DB, FireDAC.Comp.Client, FireDAC.Stan.Intf, FireDAC.Stan.Option,
  FireDAC.Stan.Error, FireDAC.UI.Intf, FireDAC.Phys.Intf, FireDAC.Stan.Def, FireDAC.Stan.Pool,
  FireDAC.Stan.Async, FireDAC.Phys, FireDAC.Phys.FB, FireDAC.Phys.FBDef, FireDAC.VCLUI.Wait,
  FireDAC.Comp.DataSet, System.JSON, System.Net.HttpClient, System.Net.URLClient,
  System.Net.HttpClientComponent, System.Math, FireDAC.Stan.Param, FireDAC.DatS,
  FireDAC.DApt.Intf, FireDAC.DApt,
  UConfigManager;

const
  FIREBASE_PROJECT = 'clickacademico-342da';
  FIREBASE_API_KEY = 'AIzaSyA2-w2UfVhzN2prqJ2H0kecHYwLTC3XbkU';
  URL_BASE = 'https://firestore.googleapis.com/v1/projects/' + FIREBASE_PROJECT + '/databases/(default)/documents/professores_online';

type
  TFormCadastroLoginProfessores = class(TForm)
    PanelTop: TPanel;
    lblTitulo: TLabel;
    btnFechar: TButton;
    PanelCadastro: TPanel;
    lblNomeProfessor: TLabel;
    edtNomeProfessor: TEdit;
    lblUsuario: TLabel;
    edtUsuario: TEdit;
    chkAtivo: TCheckBox;
    btnSalvar: TButton;
    btnNovo: TButton;
    PanelGrid: TPanel;
    DBGridLogins: TDBGrid;
    PanelBotoesGrid: TPanel;
    btnAtualizar: TButton;
    btnEditar: TButton;
    FDConnection: TFDConnection;
    FDQueryProfessores: TFDQuery;
    DataSourceProfessores: TDataSource;
    FDQueryBusca: TFDQuery;
    FDMemTableProfessores: TFDMemTable;
    btnBuscarFuncionario: TButton;
    btnExcluir: TButton;
    btnResetarSenha: TButton;
    lblCodigoFuncionario: TLabel;
    edtCodigoFuncionario: TEdit;
    procedure btnFecharClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure btnSalvarClick(Sender: TObject);
    procedure btnNovoClick(Sender: TObject);
    procedure btnEditarClick(Sender: TObject);
    procedure btnAtualizarClick(Sender: TObject);
    procedure btnBuscarFuncionarioClick(Sender: TObject);
    procedure DBGridLoginsDblClick(Sender: TObject);
    procedure btnExcluirClick(Sender: TObject);
    procedure btnResetarSenhaClick(Sender: TObject);
    procedure FDConnectionBeforeConnect(Sender: TObject);
  private
    FDocumentoId: string;
    FModoEdicao: Boolean;
    procedure ConfigurarConexaoFromINI;
    procedure CarregarProfessoresFirebase;
    procedure LimparCampos;
    procedure ConfigurarCamposModoEdicao(ModoEdicao: Boolean);
    function GerarUsuario(const Nome: string): string;
    function DocumentoParaJSON(const Document: TJSONObject): TJSONObject;
    procedure ResetarSenhaNoFirebase(const DocumentId: string);
  public
  end;

var
  FormCadastroLoginProfessores: TFormCadastroLoginProfessores;

implementation

{$R *.dfm}

procedure TFormCadastroLoginProfessores.FDConnectionBeforeConnect(Sender: TObject);
begin
  // Configurar conexão automaticamente via ConfigManager antes de abrir
  ConfigManager.ConfigurarFDConnection(FDConnection);
end;

procedure TFormCadastroLoginProfessores.ConfigurarConexaoFromINI;
begin
  // Configurar conexão Firebird do arquivo INI
  if FDConnection.Connected then
    FDConnection.Connected := False;

  FDConnection.Params.DriverID := ConfigManager.Database.DriverID;
  FDConnection.Params.Database := ConfigManager.GetFirebirdConnectionString;
  FDConnection.Params.UserName := ConfigManager.Database.UserName;
  FDConnection.Params.Password := ConfigManager.Database.Password;

  try
    FDConnection.Connected := True;
  except
    on E: Exception do
      ShowMessage('Erro ao conectar ao banco de dados: ' + E.Message + #13#10 +
                'Verifique as configurações em: ' + ConfigManager.ConfigPath);
  end;
end;

procedure TFormCadastroLoginProfessores.FormCreate(Sender: TObject);
begin
  // Configurar conexão do arquivo INI antes de inicializar
  ConfigurarConexaoFromINI;

  FDocumentoId := '';
  FModoEdicao := False;

  // Configurar FDMemTable
  FDMemTableProfessores.Close;
  FDMemTableProfessores.FieldDefs.Clear;
  FDMemTableProfessores.FieldDefs.Add('document_id', ftString, 100, False);
  FDMemTableProfessores.FieldDefs.Add('codigo_funcionario', ftInteger, 0, False);
  FDMemTableProfessores.FieldDefs.Add('nome_professor', ftString, 100, False);
  FDMemTableProfessores.FieldDefs.Add('usuario', ftString, 50, False);
  FDMemTableProfessores.FieldDefs.Add('ativo', ftBoolean, 0, False);
  FDMemTableProfessores.FieldDefs.Add('primeiro_login', ftBoolean, 0, False);
  FDMemTableProfessores.CreateDataSet;
  
  // Desabilitar campos de código
  edtCodigoFuncionario.ReadOnly := True;
  edtCodigoFuncionario.Color := clSilver;
  
  CarregarProfessoresFirebase;
  ConfigurarCamposModoEdicao(False);
end;

procedure TFormCadastroLoginProfessores.btnFecharClick(Sender: TObject);
begin
  Close;
end;

procedure TFormCadastroLoginProfessores.ConfigurarCamposModoEdicao(ModoEdicao: Boolean);
begin
  FModoEdicao := ModoEdicao;
  
  if ModoEdicao then
  begin
    btnSalvar.Caption := 'Atualizar';
    edtCodigoFuncionario.ReadOnly := True;
    edtCodigoFuncionario.Color := clSilver;
    edtNomeProfessor.ReadOnly := True;
    edtNomeProfessor.Color := clSilver;
    btnBuscarFuncionario.Enabled := False;
  end
  else
  begin
    btnSalvar.Caption := 'Salvar';
    edtCodigoFuncionario.ReadOnly := True;
    edtCodigoFuncionario.Color := clSilver;
    edtNomeProfessor.ReadOnly := True;
    edtNomeProfessor.Color := clSilver;
    btnBuscarFuncionario.Enabled := True;
  end;
end;

procedure TFormCadastroLoginProfessores.LimparCampos;
begin
  edtCodigoFuncionario.Clear;
  edtNomeProfessor.Clear;
  edtUsuario.Clear;
  chkAtivo.Checked := True;
  FDocumentoId := '';
  ConfigurarCamposModoEdicao(False);
end;

function TFormCadastroLoginProfessores.GerarUsuario(const Nome: string): string;
var
  NomeLimpo, PrimeiroNome, Iniciais: string;
  Palavras: TArray<string>;
  i: Integer;
begin
  // Converter para minúsculo
  NomeLimpo := AnsiLowerCase(Nome);

  // Remover preposições comuns (de, da, do, das, dos)
  NomeLimpo := StringReplace(NomeLimpo, ' de ', ' ', [rfReplaceAll]);
  NomeLimpo := StringReplace(NomeLimpo, ' da ', ' ', [rfReplaceAll]);
  NomeLimpo := StringReplace(NomeLimpo, ' do ', ' ', [rfReplaceAll]);
  NomeLimpo := StringReplace(NomeLimpo, ' das ', ' ', [rfReplaceAll]);
  NomeLimpo := StringReplace(NomeLimpo, ' dos ', ' ', [rfReplaceAll]);

  // Dividir em palavras
  Palavras := NomeLimpo.Split([' ']);

  Result := '';
  if Length(Palavras) > 0 then
  begin
    // Primeiro nome completo
    PrimeiroNome := Palavras[0];

    // Iniciais dos sobrenomes
    Iniciais := '';
    for i := 1 to High(Palavras) do
    begin
      if (Palavras[i] <> '') and (Length(Palavras[i]) > 0) then
        Iniciais := Iniciais + Palavras[i][1];
    end;

    // Montar resultado: primeiro nome + ponto + iniciais
    Result := PrimeiroNome + '.' + Iniciais;
  end;

  // Remover acentos do resultado
  Result := StringReplace(Result, 'á', 'a', [rfReplaceAll]);
  Result := StringReplace(Result, 'à', 'a', [rfReplaceAll]);
  Result := StringReplace(Result, 'â', 'a', [rfReplaceAll]);
  Result := StringReplace(Result, 'ã', 'a', [rfReplaceAll]);
  Result := StringReplace(Result, 'é', 'e', [rfReplaceAll]);
  Result := StringReplace(Result, 'ê', 'e', [rfReplaceAll]);
  Result := StringReplace(Result, 'í', 'i', [rfReplaceAll]);
  Result := StringReplace(Result, 'ó', 'o', [rfReplaceAll]);
  Result := StringReplace(Result, 'ô', 'o', [rfReplaceAll]);
  Result := StringReplace(Result, 'õ', 'o', [rfReplaceAll]);
  Result := StringReplace(Result, 'ú', 'u', [rfReplaceAll]);
  Result := StringReplace(Result, 'ç', 'c', [rfReplaceAll]);

  // Limitar a 30 caracteres
  if Length(Result) > 30 then
    Result := Copy(Result, 1, 30);
end;

procedure TFormCadastroLoginProfessores.CarregarProfessoresFirebase;
var
  HTTP: TNetHTTPClient;
  Response: IHTTPResponse;
  JSONResponse: TJSONObject;
  Documents: TJSONArray;
  i: Integer;
  Doc, Fields: TJSONObject;
  DocId: string;
  CodigoFunc: Integer;
  Nome, Usuario: string;
  Ativo, PrimeiroLogin: Boolean;
  Field: TJSONValue;
  DocName: string;
  TimestampValue: string;
begin
  FDMemTableProfessores.Close;
  FDMemTableProfessores.Open;
  
  HTTP := TNetHTTPClient.Create(nil);
  try
    Response := HTTP.Get(URL_BASE + '?key=' + FIREBASE_API_KEY);
    
    if Response.StatusCode = 200 then
    begin
      JSONResponse := TJSONObject.ParseJSONValue(Response.ContentAsString) as TJSONObject;
      try
        Documents := JSONResponse.GetValue('documents') as TJSONArray;
        if Assigned(Documents) then
        begin
          for i := 0 to Documents.Count - 1 do
          begin
            Doc := Documents.Items[i] as TJSONObject;
            DocName := Doc.GetValue('name').Value;
            DocId := DocName.Substring(DocName.LastIndexOf('/') + 1);
            
            Fields := Doc.GetValue('fields') as TJSONObject;
            
            CodigoFunc := 0;
            Nome := '';
            Usuario := '';
            Ativo := True;
            PrimeiroLogin := True;
            
            // Codigo funcionario
            Field := Fields.GetValue('codigo_funcionario');
            if Assigned(Field) then
            begin
              try
                CodigoFunc := StrToInt((Field as TJSONObject).GetValue('integerValue').Value);
              except
                CodigoFunc := 0;
              end;
            end;
            
            // Nome professor
            Field := Fields.GetValue('nome_professor');
            if Assigned(Field) then
              Nome := (Field as TJSONObject).GetValue('stringValue').Value;
            
            // Usuario
            Field := Fields.GetValue('usuario');
            if Assigned(Field) then
              Usuario := (Field as TJSONObject).GetValue('stringValue').Value;
            
            // Ativo
            Field := Fields.GetValue('ativo');
            if Assigned(Field) then
              Ativo := (Field as TJSONObject).GetValue('booleanValue').Value = 'true';
            
            // Primeiro login
            Field := Fields.GetValue('primeiro_login');
            if Assigned(Field) then
              PrimeiroLogin := (Field as TJSONObject).GetValue('booleanValue').Value = 'true';
            
            FDMemTableProfessores.Append;
            FDMemTableProfessores.FieldByName('document_id').AsString := DocId;
            FDMemTableProfessores.FieldByName('codigo_funcionario').AsInteger := CodigoFunc;
            FDMemTableProfessores.FieldByName('nome_professor').AsString := Nome;
            FDMemTableProfessores.FieldByName('usuario').AsString := Usuario;
            FDMemTableProfessores.FieldByName('ativo').AsBoolean := Ativo;
            FDMemTableProfessores.FieldByName('primeiro_login').AsBoolean := PrimeiroLogin;
            FDMemTableProfessores.Post;
          end;
        end;
      finally
        JSONResponse.Free;
      end;
    end;
  finally
    HTTP.Free;
  end;
end;

procedure TFormCadastroLoginProfessores.btnBuscarFuncionarioClick(Sender: TObject);
var
  FormBusca: TForm;
  Grid: TDBGrid;
  PanelBotoes: TPanel;
  btnSelecionar, btnCancelar: TButton;
  DataSource: TDataSource;
  Query: TFDQuery;
begin
  // Criar form de busca
  FormBusca := TForm.Create(nil);
  try
    FormBusca.Caption := 'Selecionar Funcionário';
    FormBusca.Width := 600;
    FormBusca.Height := 400;
    FormBusca.Position := poScreenCenter;
    FormBusca.BorderStyle := bsDialog;
    
    // Criar query
    Query := TFDQuery.Create(FormBusca);
    Query.Connection := FDConnection;
    Query.SQL.Text := 'SELECT CODIGO, NOME FROM FUNCIONARIO WHERE ATIVO = ''S'' AND PROFESSOR = ''S'' ORDER BY NOME';
    Query.Open;
    
    // DataSource
    DataSource := TDataSource.Create(FormBusca);
    DataSource.DataSet := Query;
    
    // Grid
    Grid := TDBGrid.Create(FormBusca);
    Grid.Parent := FormBusca;
    Grid.Align := alClient;
    Grid.DataSource := DataSource;
    Grid.ReadOnly := True;
    Grid.Options := [dgTitles, dgIndicator, dgColumnResize, dgColLines, dgRowLines, dgTabs, dgRowSelect, dgAlwaysShowSelection, dgConfirmDelete, dgCancelOnExit];
    
    // Panel de botões
    PanelBotoes := TPanel.Create(FormBusca);
    PanelBotoes.Parent := FormBusca;
    PanelBotoes.Align := alBottom;
    PanelBotoes.Height := 50;
    
    btnSelecionar := TButton.Create(FormBusca);
    btnSelecionar.Parent := PanelBotoes;
    btnSelecionar.Caption := 'Selecionar';
    btnSelecionar.ModalResult := mrOk;
    btnSelecionar.Left := 400;
    btnSelecionar.Top := 10;
    
    btnCancelar := TButton.Create(FormBusca);
    btnCancelar.Parent := PanelBotoes;
    btnCancelar.Caption := 'Cancelar';
    btnCancelar.ModalResult := mrCancel;
    btnCancelar.Left := 490;
    btnCancelar.Top := 10;
    
    if FormBusca.ShowModal = mrOk then
    begin
      if not Query.IsEmpty then
      begin
        edtCodigoFuncionario.Text := Query.FieldByName('CODIGO').AsString;
        edtNomeProfessor.Text := Query.FieldByName('NOME').AsString;
        
        // Gerar usuário automaticamente
        edtUsuario.Text := GerarUsuario(edtNomeProfessor.Text);
      end;
    end;
  finally
    FormBusca.Free;
  end;
end;

procedure TFormCadastroLoginProfessores.btnSalvarClick(Sender: TObject);
var
  HTTP: TNetHTTPClient;
  Response: IHTTPResponse;
  JSONDoc, FieldsObj: TJSONObject;
  Body: TStringStream;
  CodigoFunc: Integer;
  NovoDocumentId: string;
  TimestampValue: string;
begin
  // Validações
  if edtCodigoFuncionario.Text = '' then
  begin
    ShowMessage('Selecione um funcionário!');
    btnBuscarFuncionario.SetFocus;
    Exit;
  end;
  
  if edtUsuario.Text = '' then
  begin
    ShowMessage('Informe o usuário!');
    edtUsuario.SetFocus;
    Exit;
  end;
  
  try
    CodigoFunc := StrToInt(edtCodigoFuncionario.Text);
  except
    ShowMessage('Código do funcionário inválido!');
    Exit;
  end;
  
  HTTP := TNetHTTPClient.Create(nil);
  try
    if FModoEdicao and (FDocumentoId <> '') then
    begin
      // Atualizar documento existente
      JSONDoc := TJSONObject.Create;
      FieldsObj := TJSONObject.Create;
      
      // Apenas atualizar campos que podem mudar: usuario e ativo
      FieldsObj.AddPair('usuario', TJSONObject.Create.AddPair('stringValue', edtUsuario.Text));
      FieldsObj.AddPair('ativo', TJSONObject.Create.AddPair('booleanValue', BoolToStr(chkAtivo.Checked, True).ToLower));
      
      JSONDoc.AddPair('fields', FieldsObj);
      
      Body := TStringStream.Create(JSONDoc.ToString, TEncoding.UTF8);
      try
        // Usar updateMask para atualizar apenas os campos especificos
        Response := HTTP.Patch(URL_BASE + '/' + FDocumentoId + '?key=' + FIREBASE_API_KEY +
                                '&updateMask.fieldPaths=usuario&updateMask.fieldPaths=ativo',
                                Body);
        
        if (Response.StatusCode = 200) or (Response.StatusCode = 201) then
        begin
          ShowMessage('Professor atualizado com sucesso!');
          LimparCampos;
          CarregarProfessoresFirebase;
        end
        else
        begin
          ShowMessage('Erro ao atualizar: ' + IntToStr(Response.StatusCode));
        end;
      finally
        Body.Free;
        JSONDoc.Free;
      end;
    end
    else
    begin
      // Criar novo documento
      JSONDoc := TJSONObject.Create;
      FieldsObj := TJSONObject.Create;
      
      FieldsObj.AddPair('codigo_funcionario', TJSONObject.Create.AddPair('integerValue', CodigoFunc.ToString));
      FieldsObj.AddPair('nome_professor', TJSONObject.Create.AddPair('stringValue', edtNomeProfessor.Text));
      FieldsObj.AddPair('usuario', TJSONObject.Create.AddPair('stringValue', edtUsuario.Text));
      FieldsObj.AddPair('senha', TJSONObject.Create.AddPair('stringValue', ''));
      FieldsObj.AddPair('ativo', TJSONObject.Create.AddPair('booleanValue', BoolToStr(chkAtivo.Checked, True).ToLower));
      FieldsObj.AddPair('primeiro_login', TJSONObject.Create.AddPair('booleanValue', 'true'));
      
      TimestampValue := FormatDateTime('yyyy-mm-dd"T"hh:nn:ss"Z"', Now);
      FieldsObj.AddPair('data_cadastro', TJSONObject.Create.AddPair('timestampValue', TimestampValue));
      
      JSONDoc.AddPair('fields', FieldsObj);
      
      Body := TStringStream.Create(JSONDoc.ToString, TEncoding.UTF8);
      try
        NovoDocumentId := TGUID.NewGuid.ToString.Replace('{', '').Replace('}', '').Replace('-', '');
        
        Response := HTTP.Post(URL_BASE + '?documentId=' + NovoDocumentId + '&key=' + FIREBASE_API_KEY, Body);
        
        if (Response.StatusCode = 200) or (Response.StatusCode = 201) then
        begin
          ShowMessage('Professor cadastrado com sucesso!'#13#10+
                      'Usuário: ' + edtUsuario.Text + #13#10+
                      'Senha: (vazio - criar no primeiro login)');
          LimparCampos;
          CarregarProfessoresFirebase;
        end
        else
        begin
          ShowMessage('Erro ao cadastrar: ' + IntToStr(Response.StatusCode) + #13#10 + 
                      Response.ContentAsString);
        end;
      finally
        Body.Free;
        JSONDoc.Free;
      end;
    end;
  finally
    HTTP.Free;
  end;
end;

procedure TFormCadastroLoginProfessores.btnNovoClick(Sender: TObject);
begin
  LimparCampos;
  edtUsuario.SetFocus;
end;

procedure TFormCadastroLoginProfessores.btnEditarClick(Sender: TObject);
begin
  if FDMemTableProfessores.IsEmpty then
  begin
    ShowMessage('Selecione um professor para editar!');
    Exit;
  end;
  
  FDocumentoId := FDMemTableProfessores.FieldByName('document_id').AsString;
  edtCodigoFuncionario.Text := FDMemTableProfessores.FieldByName('codigo_funcionario').AsString;
  edtNomeProfessor.Text := FDMemTableProfessores.FieldByName('nome_professor').AsString;
  edtUsuario.Text := FDMemTableProfessores.FieldByName('usuario').AsString;
  chkAtivo.Checked := FDMemTableProfessores.FieldByName('ativo').AsBoolean;
  
  ConfigurarCamposModoEdicao(True);
  edtUsuario.SetFocus;
end;

procedure TFormCadastroLoginProfessores.DBGridLoginsDblClick(Sender: TObject);
begin
  btnEditarClick(Sender);
end;

function TFormCadastroLoginProfessores.DocumentoParaJSON(
  const Document: TJSONObject): TJSONObject;
var
  ResultJSON: TJSONObject;
  Fields: TJSONObject;
  DocId, DocName: string;
  Field: TJSONValue;
begin
  ResultJSON := TJSONObject.Create;
  try
    DocName := Document.GetValue('name').Value;
    DocId := Copy(DocName, LastDelimiter('/', DocName) + 1, MaxInt);
    ResultJSON.AddPair('document_id', DocId);

    Fields := Document.GetValue('fields') as TJSONObject;
    if Assigned(Fields) then
    begin
      // Codigo funcionario
      Field := Fields.GetValue('codigo_funcionario');
      if Assigned(Field) then
        ResultJSON.AddPair('codigo_funcionario', (Field as TJSONObject).GetValue('integerValue').Value);

      // Nome professor
      Field := Fields.GetValue('nome_professor');
      if Assigned(Field) then
        ResultJSON.AddPair('nome_professor', (Field as TJSONObject).GetValue('stringValue').Value);

      // Usuario
      Field := Fields.GetValue('usuario');
      if Assigned(Field) then
        ResultJSON.AddPair('usuario', (Field as TJSONObject).GetValue('stringValue').Value);

      // Ativo
      Field := Fields.GetValue('ativo');
      if Assigned(Field) then
        ResultJSON.AddPair('ativo', (Field as TJSONObject).GetValue('booleanValue').Value);

      // Primeiro login
      Field := Fields.GetValue('primeiro_login');
      if Assigned(Field) then
        ResultJSON.AddPair('primeiro_login', (Field as TJSONObject).GetValue('booleanValue').Value);
    end;

    Result := ResultJSON;
  except
    ResultJSON.Free;
    raise;
  end;
end;

procedure TFormCadastroLoginProfessores.btnAtualizarClick(Sender: TObject);
begin
  CarregarProfessoresFirebase;
end;

procedure TFormCadastroLoginProfessores.ResetarSenhaNoFirebase(const DocumentId: string);
var
  HTTP: TNetHTTPClient;
  Response: IHTTPResponse;
  JSONDoc, FieldsObj: TJSONObject;
  Body: TStringStream;
begin
  HTTP := TNetHTTPClient.Create(nil);
  try
    JSONDoc := TJSONObject.Create;
    FieldsObj := TJSONObject.Create;
    
    FieldsObj.AddPair('senha', TJSONObject.Create.AddPair('stringValue', ''));
    FieldsObj.AddPair('primeiro_login', TJSONObject.Create.AddPair('booleanValue', 'true'));
    
    JSONDoc.AddPair('fields', FieldsObj);
    
    Body := TStringStream.Create(JSONDoc.ToString, TEncoding.UTF8);
    try
      // Usar updateMask para atualizar apenas os campos especificos
      Response := HTTP.Patch(URL_BASE + '/' + DocumentId + '?key=' + FIREBASE_API_KEY +
                              '&updateMask.fieldPaths=senha&updateMask.fieldPaths=primeiro_login',
                              Body);
      
      if (Response.StatusCode = 200) or (Response.StatusCode = 201) then
      begin
        ShowMessage('Senha resetada com sucesso!'#13#10+
                    'O professor poderá criar uma nova senha no próximo login.');
        CarregarProfessoresFirebase;
      end
      else
      begin
        ShowMessage('Erro ao resetar senha: ' + IntToStr(Response.StatusCode));
      end;
    finally
      Body.Free;
      JSONDoc.Free;
    end;
  finally
    HTTP.Free;
  end;
end;

procedure TFormCadastroLoginProfessores.btnResetarSenhaClick(Sender: TObject);
var
  ProfessorNome, DocumentId: string;
begin
  if FDMemTableProfessores.IsEmpty then
  begin
    ShowMessage('Selecione um professor para resetar a senha!');
    Exit;
  end;
  
  ProfessorNome := FDMemTableProfessores.FieldByName('nome_professor').AsString;
  DocumentId := FDMemTableProfessores.FieldByName('document_id').AsString;
  
  if MessageDlg('Resetar senha do professor ' + ProfessorNome + '?', 
                mtConfirmation, [mbYes, mbNo], 0) = mrYes then
  begin
    ResetarSenhaNoFirebase(DocumentId);
  end;
end;

procedure TFormCadastroLoginProfessores.btnExcluirClick(Sender: TObject);
var
  HTTP: TNetHTTPClient;
  Response: IHTTPResponse;
  ProfessorNome, DocumentId: string;
begin
  if FDMemTableProfessores.IsEmpty then
  begin
    ShowMessage('Selecione um professor para excluir!');
    Exit;
  end;
  
  ProfessorNome := FDMemTableProfessores.FieldByName('nome_professor').AsString;
  DocumentId := FDMemTableProfessores.FieldByName('document_id').AsString;
  
  if MessageDlg('Excluir o cadastro do professor ' + ProfessorNome + '?', 
                mtConfirmation, [mbYes, mbNo], 0) = mrYes then
  begin
    HTTP := TNetHTTPClient.Create(nil);
    try
      Response := HTTP.Delete(URL_BASE + '/' + DocumentId + '?key=' + FIREBASE_API_KEY);
      
      if (Response.StatusCode = 200) or (Response.StatusCode = 204) then
      begin
        ShowMessage('Professor excluído com sucesso!');
        CarregarProfessoresFirebase;
        
        if FDocumentoId = DocumentId then
          LimparCampos;
      end
      else
      begin
        ShowMessage('Erro ao excluir: ' + IntToStr(Response.StatusCode));
      end;
    finally
      HTTP.Free;
    end;
  end;
end;

end.
