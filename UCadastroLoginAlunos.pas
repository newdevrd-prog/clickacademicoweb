unit UCadastroLoginAlunos;

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
  USelecionarAluno,
  UConfigManager;

type
  TFormCadastroLoginAlunos = class(TForm)
    PanelTop: TPanel;
    lblTitulo: TLabel;
    btnFechar: TButton;
    PanelCadastro: TPanel;
    lblCodigoAluno: TLabel;
    edtCodigoAluno: TEdit;
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
    FDQueryAlunos: TFDQuery;
    DataSourceAlunos: TDataSource;
    FDQueryBusca: TFDQuery;
    FDMemTableAlunos: TFDMemTable;
    lblNomeAluno: TLabel;
    btnBuscarAluno: TButton;
    btnExcluir: TButton;
    btnResetarSenha: TButton;
    btnCadastrarTodos: TButton;
    btnAdicionarIndividual: TButton;
    procedure btnFecharClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure btnSalvarClick(Sender: TObject);
    procedure btnNovoClick(Sender: TObject);
    procedure btnEditarClick(Sender: TObject);
    procedure btnAtualizarClick(Sender: TObject);
    procedure btnBuscarAlunoClick(Sender: TObject);
    procedure DBGridLoginsDblClick(Sender: TObject);
    procedure btnExcluirClick(Sender: TObject);
    procedure btnResetarSenhaClick(Sender: TObject);
    procedure btnCadastrarTodosClick(Sender: TObject);
    procedure btnAdicionarIndividualClick(Sender: TObject);
    procedure FDConnectionBeforeConnect(Sender: TObject);
  private
    FEditando: Boolean;
    FCodigoAlunoAtual: Integer;
    procedure ConfigurarConexaoFromINI;
    procedure LimparCampos;
    procedure HabilitarCampos(Habilitar: Boolean);
    procedure CarregarGrid;
    procedure CarregarDadosEdicao;
    function ValidarCampos: Boolean;
    function UsuarioExiste(Usuario: string; IgnorarCodigo: Integer): Boolean;
    procedure SalvarNoFirebase;
    procedure AtualizarNoFirebase(DocumentId: string; CodigoAluno: Integer; NomeAluno, SenhaAtual: string; PrimeiroLogin: Boolean);
    function BuscarDocumentIdFirebase(CodigoAluno: Integer): string;
    procedure BuscarDadosAlunoFirebase(DocumentId: string; out Nome, Senha: string; out PrimeiroLogin: Boolean);
    function IsJSONInstanceValid(const AObj: TJSONObject; const AcceptEmpty: Boolean = False): Boolean;
    procedure ExcluirDoFirebase(DocumentId: string);
    procedure ResetarSenhaNoFirebase(DocumentId: string);
    function LoginJaExiste(CodigoAluno: Integer): Boolean;
    function CriarLoginFirebase(CodigoAluno: Integer; NomeAluno, CPF: string): Boolean;
    procedure CadastrarTodosAlunos;
  public
    { Public declarations }
  end;

var
  FormCadastroLoginAlunos: TFormCadastroLoginAlunos;

implementation

{$R *.dfm}

procedure TFormCadastroLoginAlunos.FDConnectionBeforeConnect(Sender: TObject);
begin
  // Configurar conexão automaticamente via ConfigManager antes de abrir
  ConfigManager.ConfigurarFDConnection(FDConnection);
end;

procedure TFormCadastroLoginAlunos.ConfigurarConexaoFromINI;
const
  FIREBASE_PROJECT = 'clickacademico-342da';
  FIREBASE_API_KEY = 'AIzaSyA2-w2UfVhzN2prqJ2H0kecHYwLTC3XbkU';
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

procedure TFormCadastroLoginAlunos.FormCreate(Sender: TObject);
begin
  // Configurar conexão do arquivo INI antes de inicializar
  ConfigurarConexaoFromINI;

  FEditando := False;
  FCodigoAlunoAtual := 0;
  LimparCampos;
  HabilitarCampos(False);
  CarregarGrid;
end;

procedure TFormCadastroLoginAlunos.LimparCampos;
begin
  edtCodigoAluno.Text := '';
  edtUsuario.Text := '';
  chkAtivo.Checked := True;
  lblNomeAluno.Caption := 'Nome do Aluno: -';
  FCodigoAlunoAtual := 0;
  FEditando := False;
end;

procedure TFormCadastroLoginAlunos.HabilitarCampos(Habilitar: Boolean);
begin
  edtCodigoAluno.Enabled := Habilitar and not FEditando;
  edtUsuario.Enabled := Habilitar;
  chkAtivo.Enabled := Habilitar;
  btnBuscarAluno.Enabled := Habilitar and not FEditando;
  btnSalvar.Enabled := Habilitar;
end;

procedure TFormCadastroLoginAlunos.CarregarGrid;
var
  HTTP: TNetHTTPClient;
  Response: IHTTPResponse;
  JSONRes, DocItem, FieldValue: TJSONObject;
  JSONValue: TJSONValue;
  Documents: TJSONArray;
  i: Integer;
  Fields: TJSONObject;
begin
  // Limpar e preparar o FDMemTable
  FDMemTableAlunos.Close;
  FDMemTableAlunos.FieldDefs.Clear;
  FDMemTableAlunos.FieldDefs.Add('CODIGO', ftInteger, 0, False);
  FDMemTableAlunos.FieldDefs.Add('NOME', ftString, 100, False);
  FDMemTableAlunos.FieldDefs.Add('USUARIO', ftString, 50, False);
  FDMemTableAlunos.FieldDefs.Add('ATIVO', ftInteger, 0, False);
  FDMemTableAlunos.FieldDefs.Add('DOCUMENT_ID_FIREBASE', ftString, 100, False);
  FDMemTableAlunos.CreateDataSet;
  FDMemTableAlunos.Open;
  
  // Buscar dados do Firebase
  HTTP := TNetHTTPClient.Create(nil);
  try
    try
      Response := HTTP.Get('https://firestore.googleapis.com/v1/projects/clickacademico-342da/databases/(default)/documents/alunos_online?key=AIzaSyA2-w2UfVhzN2prqJ2H0kecHYwLTC3XbkU');
      
      if Response.StatusCode in [200, 201] then
      begin
        JSONRes := TJSONObject.ParseJSONValue(Response.ContentAsString) as TJSONObject;
        try
          // Verificar se JSONRes é válido
          if not Assigned(JSONRes) then
          begin
            ShowMessage('Erro: Resposta JSON inválida');
            Exit;
          end;
          
          // DEBUG: Mostrar resposta bruta do Firebase (comentado)
          // ShowMessage('Resposta Firebase:' + sLineBreak + Response.ContentAsString);
          
          // Verificar se existe 'documents' (pode não existir se collection vazia)
          if JSONRes.TryGetValue('documents', JSONValue) then
          begin
            // Verificar se JSONValue é um array
            if not (JSONValue is TJSONArray) then
            begin
              ShowMessage('Erro: documents não é um array');
              Exit;
            end;
            
            Documents := JSONValue as TJSONArray;
            
            // DEBUG: Mostrar quantidade de documentos (comentar se nao precisar)
            // ShowMessage('Total de documentos encontrados: ' + IntToStr(Documents.Count));
            
            // Preencher FDMemTable com dados do Firebase
            for i := 0 to Documents.Count - 1 do
            begin
              DocItem := Documents.Items[i] as TJSONObject;
              Fields := DocItem.GetValue('fields') as TJSONObject;
              
              FDMemTableAlunos.Append;
              
              // Código
              if Fields.TryGetValue('codigo_aluno', FieldValue) then
                FDMemTableAlunos.FieldByName('CODIGO').AsInteger := StrToIntDef(FieldValue.GetValue('integerValue').Value, 0);
              
              // Nome
              if Fields.TryGetValue('nome_aluno', FieldValue) then
                FDMemTableAlunos.FieldByName('NOME').AsString := FieldValue.GetValue('stringValue').Value;
              
              // Usuário
              if Fields.TryGetValue('usuario', FieldValue) then
                FDMemTableAlunos.FieldByName('USUARIO').AsString := FieldValue.GetValue('stringValue').Value;
              
              // Ativo
              if Fields.TryGetValue('ativo', FieldValue) then
                FDMemTableAlunos.FieldByName('ATIVO').AsInteger := StrToIntDef(FieldValue.GetValue('integerValue').Value, 0);
              
              // Document ID
              FDMemTableAlunos.FieldByName('DOCUMENT_ID_FIREBASE').AsString := Copy(DocItem.GetValue('name').Value, LastDelimiter('/', DocItem.GetValue('name').Value) + 1, MaxInt);
              
              FDMemTableAlunos.Post;
              
              // DEBUG: Mostrar dados inseridos (comentar se nao precisar)
              // ShowMessage('Registro ' + IntToStr(i+1) + ' inserido: ' + 
              //            'CODIGO=' + FDMemTableAlunos.FieldByName('CODIGO').AsString + 
              //            ', NOME=' + FDMemTableAlunos.FieldByName('NOME').AsString + 
              //            ', USUARIO=' + FDMemTableAlunos.FieldByName('USUARIO').AsString);
            end;
            
            // DEBUG: Mostrar total de registros no FDMemTable (comentar se nao precisar)
            // ShowMessage('Total de registros no FDMemTable: ' + IntToStr(FDMemTableAlunos.RecordCount));
            FDMemTableAlunos.First;
          end;
        finally
          JSONRes.Free;
        end;
      end
      else
      begin
        ShowMessage('Erro ao carregar dados do Firebase: ' + Response.StatusText);
      end;
    except
      on E: Exception do
        ShowMessage('Erro ao carregar grid: ' + E.Message);
    end;
  finally
    HTTP.Free;
  end;
end;

procedure TFormCadastroLoginAlunos.btnBuscarAlunoClick(Sender: TObject);
var
  Codigo: Integer;
begin
  if not TryStrToInt(edtCodigoAluno.Text, Codigo) then
  begin
    ShowMessage('Digite um codigo de aluno valido!');
    Exit;
  end;

  FDQueryBusca.Close;
  FDQueryBusca.SQL.Text := 'SELECT NOME FROM ALUNO WHERE CODIGO = :CODIGO';
  FDQueryBusca.ParamByName('CODIGO').AsInteger := Codigo;
  FDQueryBusca.Open;

  if FDQueryBusca.IsEmpty then
  begin
    ShowMessage('Aluno nao encontrado!');
    lblNomeAluno.Caption := 'Nome do Aluno: -';
    FCodigoAlunoAtual := 0;
  end
  else
  begin
    lblNomeAluno.Caption := 'Nome do Aluno: ' + FDQueryBusca.FieldByName('NOME').AsString;
    FCodigoAlunoAtual := Codigo;
    edtUsuario.Text := 'aluno' + Codigo.ToString;
  end;
end;

/// <summary>
/// Valida se uma string é um JSON bem formado e opcionalmente se contém dados.
/// </summary>
function TFormCadastroLoginAlunos.IsJSONInstanceValid(const AObj: TJSONObject; const AcceptEmpty: Boolean = False): Boolean;
begin
  // 1. Checa se a instância existe na memória (o seu <> nil)
  Result := Assigned(AObj);

  // 2. Se existir e você NÃO aceitar JSON vazio tipo {}
  if Result and (not AcceptEmpty) then
  begin
    Result := AObj.Count > 0;
  end;
end;

function TFormCadastroLoginAlunos.UsuarioExiste(Usuario: string; IgnorarCodigo: Integer): Boolean;
var
  HTTP: TNetHTTPClient;
  Response: IHTTPResponse;
  JSONRes, DocItem, FieldValue: TJSONObject;
  JSONValue: TJSONValue;
  Documents: TJSONArray;
  i: Integer;
  Fields: TJSONObject;
  UsuarioDoc: string;
  CodigoDoc: Integer;
begin
  Result := False;
  
  // Buscar no Firebase
  HTTP := TNetHTTPClient.Create(nil);
  try
    Response := HTTP.Get('https://firestore.googleapis.com/v1/projects/clickacademico-342da/databases/(default)/documents/alunos_online?key=AIzaSyA2-w2UfVhzN2prqJ2H0kecHYwLTC3XbkU');
    
    if Response.StatusCode in [200, 201] then
    begin
      JSONRes := TJSONObject.ParseJSONValue(Response.ContentAsString) as TJSONObject;
      try
        // Verificar se JSONRes é válido
        if not Assigned(JSONRes) then Exit;
        
        // Verificar se existe 'documents'
        if JSONRes.TryGetValue('documents', JSONValue) then
        begin
          // Verificar se é um array
          if not (JSONValue is TJSONArray) then Exit;

          Documents := JSONValue as TJSONArray;

          // Se não houver documentos, usuário não existe
          if Documents.Count = 0 then Exit;
          
          for i := 0 to Documents.Count - 1 do
          begin
            DocItem := Documents.Items[i] as TJSONObject;
            Fields := DocItem.GetValue('fields') as TJSONObject;
            
            if Fields.TryGetValue('usuario', FieldValue) then
            begin
              UsuarioDoc := FieldValue.GetValue('stringValue').Value;
              
              // Verifica se é o mesmo usuário e código diferente do ignorado
              if UsuarioDoc = Usuario then
              begin
                if Fields.TryGetValue('codigo_aluno', FieldValue) then
                  CodigoDoc := StrToIntDef(FieldValue.GetValue('integerValue').Value, 0);
                
                // Se for edição, ignora o próprio código
                if CodigoDoc <> IgnorarCodigo then
                begin
                  Result := True;
                  Break;
                end;
              end;
            end;
          end;
        end;
      finally
        JSONRes.Free;
      end;
    end;
  finally
    HTTP.Free;
  end;
end;

function TFormCadastroLoginAlunos.ValidarCampos: Boolean;
begin
  Result := False;

  if FCodigoAlunoAtual = 0 then
  begin
    ShowMessage('Busque um aluno valido primeiro!');
    Exit;
  end;

  if Trim(edtUsuario.Text) = '' then
  begin
    ShowMessage('Digite o nome de usuario!');
    Exit;
  end;

  if not FEditando and UsuarioExiste(edtUsuario.Text, 0) then
  begin
    ShowMessage('Este nome de usuario ja esta em uso!');
    Exit;
  end;

  if FEditando and UsuarioExiste(edtUsuario.Text, FCodigoAlunoAtual) then
  begin
    ShowMessage('Este nome de usuario ja esta em uso!');
    Exit;
  end;

  Result := True;
end;

procedure TFormCadastroLoginAlunos.SalvarNoFirebase;
const
  URL_BASE = 'https://firestore.googleapis.com/v1/projects/clickacademico-342da/databases/(default)/documents/alunos_online';
  FIREBASE_API_KEY = 'AIzaSyA2-w2UfVhzN2prqJ2H0kecHYwLTC3XbkU';
var
  HTTP: TNetHTTPClient;
  JSONDoc, Fields, Item, JSONRes: TJSONObject;
  JSONValue: TJSONValue;
  RequestStream: TStringStream;
  Response: IHTTPResponse;
  ValorAtivo: Integer;
  NomeAluno: string;
  DocId: string;
begin
  HTTP := TNetHTTPClient.Create(nil);
  try
    HTTP.ContentType := 'application/json';

    // Estrutura exigida pela REST API do Firestore
    Fields := TJSONObject.Create;
    
    // Código do Aluno
    Item := TJSONObject.Create;
    Item.AddPair('integerValue', FCodigoAlunoAtual.ToString);
    Fields.AddPair('codigo_aluno', Item);

    // Nome do Aluno
    Item := TJSONObject.Create;
    NomeAluno := StringReplace(lblNomeAluno.Caption, 'Nome do Aluno: ', '', [rfReplaceAll]);
    Item.AddPair('stringValue', NomeAluno);
    Fields.AddPair('nome_aluno', Item);

    // Usuário
    Item := TJSONObject.Create;
    Item.AddPair('stringValue', edtUsuario.Text);
    Fields.AddPair('usuario', Item);

    // Ativo
    ValorAtivo := IfThen(chkAtivo.Checked, 1, 0);
    Item := TJSONObject.Create;
    Item.AddPair('integerValue', ValorAtivo.ToString);
    Fields.AddPair('ativo', Item);

    // Data de Cadastro
    Item := TJSONObject.Create;
    Item.AddPair('timestampValue', FormatDateTime('yyyy-mm-dd"T"hh:nn:ss"Z"', Now));
    Fields.AddPair('data_cadastro', Item);

    // Senha (vazia para primeiro login)
    Item := TJSONObject.Create;
    Item.AddPair('stringValue', '');
    Fields.AddPair('senha', Item);

    // Primeiro Login (true para forçar criação de senha)
    Item := TJSONObject.Create;
    Item.AddPair('booleanValue', 'true');
    Fields.AddPair('primeiro_login', Item);

    JSONDoc := TJSONObject.Create;
    try
      JSONDoc.AddPair('fields', Fields);

      RequestStream := TStringStream.Create(JSONDoc.ToJSON, TEncoding.UTF8);
      try
        // DEBUG: Mostrar JSON sendo enviado (temporário para diagnóstico)
        ShowMessage('DEBUG - JSON enviado:' + sLineBreak + JSONDoc.ToJSON);

        Response := HTTP.Post(URL_BASE + '?key=' + FIREBASE_API_KEY, RequestStream);

        if Response.StatusCode in [200, 201] then
        begin
          // Pegar o ID do documento criado
          JSONRes := TJSONObject.ParseJSONValue(Response.ContentAsString) as TJSONObject;
          if Assigned(JSONRes) then
          try
            if JSONRes.TryGetValue('name', JSONValue) then
              DocId := JSONValue.Value;
            if DocId <> '' then
            begin
              // Salvar ID no Firebird
              FDConnection.ExecSQL('UPDATE ALUNOS_LOGIN SET DOCUMENT_ID_FIREBASE = :DOCID WHERE CODIGO = :CODIGO',
                [Copy(DocId, LastDelimiter('/', DocId) + 1, MaxInt), FCodigoAlunoAtual]);
            end;
          finally
            JSONRes.Free;
          end;
        end
        else
          ShowMessage('Aviso: Erro ao salvar no Firebase: ' + Response.StatusText);
      finally
        RequestStream.Free;
      end;
    finally
      JSONDoc.Free;
    end;
  finally
    HTTP.Free;
  end;
end;

function TFormCadastroLoginAlunos.BuscarDocumentIdFirebase(CodigoAluno: Integer): string;
const
  URL_BASE = 'https://firestore.googleapis.com/v1/projects/clickacademico-342da/databases/(default)/documents/alunos_online';
  FIREBASE_API_KEY = 'AIzaSyA2-w2UfVhzN2prqJ2H0kecHYwLTC3XbkU';
var
  HTTP: TNetHTTPClient;
  Response: IHTTPResponse;
  JSONRes, DocItem, FieldValue: TJSONObject;
  JSONValue: TJSONValue;
  Documents: TJSONArray;
  i: Integer;
  Fields: TJSONObject;
  CodigoDoc: string;
begin
  Result := '';
  
  HTTP := TNetHTTPClient.Create(nil);
  try
    Response := HTTP.Get(URL_BASE + '?key=' + FIREBASE_API_KEY);
    
    if Response.StatusCode in [200, 201] then
    begin
      JSONRes := TJSONObject.ParseJSONValue(Response.ContentAsString) as TJSONObject;
      try
        // Verificar se JSONRes é válido
        if not Assigned(JSONRes) then Exit;
        
        // Verificar se existe 'documents'
        if JSONRes.TryGetValue('documents', JSONValue) then
        begin
          // Verificar se é um array
          if not (JSONValue is TJSONArray) then Exit;
          
          Documents := JSONValue as TJSONArray;
          
          // Se não houver documentos, não encontrou
          if Documents.Count = 0 then Exit;

          for i := 0 to Documents.Count - 1 do
          begin
            DocItem := Documents.Items[i] as TJSONObject;
            Fields := DocItem.GetValue('fields') as TJSONObject;
            
            if Assigned(Fields) and Fields.TryGetValue('codigo_aluno', FieldValue) then
            begin
              CodigoDoc := FieldValue.GetValue('integerValue').Value;
              if CodigoDoc = CodigoAluno.ToString then
              begin
                Result := DocItem.GetValue('name').Value;
                if Result <> '' then
                  Result := Copy(Result, LastDelimiter('/', Result) + 1, MaxInt);
                Break;
              end;
            end;
          end;
        end;
      finally
        JSONRes.Free;
      end;
    end;
  finally
    HTTP.Free;
  end;
end;

procedure TFormCadastroLoginAlunos.BuscarDadosAlunoFirebase(DocumentId: string; out Nome, Senha: string; out PrimeiroLogin: Boolean);
const
  URL_BASE = 'https://firestore.googleapis.com/v1/projects/clickacademico-342da/databases/(default)/documents/alunos_online/';
  FIREBASE_API_KEY = 'AIzaSyA2-w2UfVhzN2prqJ2H0kecHYwLTC3XbkU';
var
  HTTP: TNetHTTPClient;
  Response: IHTTPResponse;
  JSONRes, FieldValue: TJSONObject;
  Fields: TJSONObject;
  PrimeiroLoginStr: string;
begin
  Nome := '';
  Senha := '';
  PrimeiroLogin := True;

  HTTP := TNetHTTPClient.Create(nil);
  try
    Response := HTTP.Get(URL_BASE + DocumentId + '?key=' + FIREBASE_API_KEY);

    if Response.StatusCode in [200, 201] then
    begin
      JSONRes := TJSONObject.ParseJSONValue(Response.ContentAsString) as TJSONObject;
      try
        if not Assigned(JSONRes) then Exit;

        Fields := JSONRes.GetValue('fields') as TJSONObject;
        if not Assigned(Fields) then Exit;

        // Buscar nome_aluno
        if Fields.TryGetValue('nome_aluno', FieldValue) then
          Nome := FieldValue.GetValue('stringValue').Value;

        // Buscar senha
        if Fields.TryGetValue('senha', FieldValue) then
          Senha := FieldValue.GetValue('stringValue').Value;

        // Buscar primeiro_login
        if Fields.TryGetValue('primeiro_login', FieldValue) then
        begin
          PrimeiroLoginStr := FieldValue.GetValue('booleanValue').Value;
          PrimeiroLogin := (PrimeiroLoginStr = 'true') or (PrimeiroLoginStr = 'True');
        end;
      finally
        JSONRes.Free;
      end;
    end;
  finally
    HTTP.Free;
  end;
end;

procedure TFormCadastroLoginAlunos.AtualizarNoFirebase(DocumentId: string; CodigoAluno: Integer; NomeAluno, SenhaAtual: string; PrimeiroLogin: Boolean);
const
  URL_BASE = 'https://firestore.googleapis.com/v1/projects/clickacademico-342da/databases/(default)/documents/alunos_online/';
  FIREBASE_API_KEY = 'AIzaSyA2-w2UfVhzN2prqJ2H0kecHYwLTC3XbkU';
var
  HTTP: TNetHTTPClient;
  JSONDoc, Fields, Item: TJSONObject;
  RequestStream: TStringStream;
  Response: IHTTPResponse;
  ValorAtivo: Integer;
begin
  if DocumentId = '' then Exit;

  HTTP := TNetHTTPClient.Create(nil);
  try
    HTTP.ContentType := 'application/json';

    // Estrutura exigida pela REST API do Firestore
    Fields := TJSONObject.Create;

    // Código do Aluno (manter)
    Item := TJSONObject.Create;
    Item.AddPair('integerValue', CodigoAluno.ToString);
    Fields.AddPair('codigo_aluno', Item);

    // Nome do Aluno (manter)
    Item := TJSONObject.Create;
    Item.AddPair('stringValue', NomeAluno);
    Fields.AddPair('nome_aluno', Item);

    // Usuário (atualizar)
    Item := TJSONObject.Create;
    Item.AddPair('stringValue', edtUsuario.Text);
    Fields.AddPair('usuario', Item);

    // Ativo (atualizar)
    ValorAtivo := IfThen(chkAtivo.Checked, 1, 0);
    Item := TJSONObject.Create;
    Item.AddPair('integerValue', ValorAtivo.ToString);
    Fields.AddPair('ativo', Item);

    // Data de Cadastro (manter - usar data atual)
    Item := TJSONObject.Create;
    Item.AddPair('timestampValue', FormatDateTime('yyyy-mm-dd"T"hh:nn:ss"Z"', Now));
    Fields.AddPair('data_cadastro', Item);

    // Senha (manter)
    Item := TJSONObject.Create;
    Item.AddPair('stringValue', SenhaAtual);
    Fields.AddPair('senha', Item);

    // Primeiro Login (manter)
    Item := TJSONObject.Create;
    Item.AddPair('booleanValue', BoolToStr(PrimeiroLogin, True).ToLower);
    Fields.AddPair('primeiro_login', Item);

    JSONDoc := TJSONObject.Create;
    try
      JSONDoc.AddPair('fields', Fields);

      // Usar PATCH para atualizar campos especificos
      RequestStream := TStringStream.Create(JSONDoc.ToJSON, TEncoding.UTF8);
      try
        Response := HTTP.Patch(URL_BASE + DocumentId + '?key=' + FIREBASE_API_KEY, RequestStream);

        if not (Response.StatusCode in [200, 201]) then
          ShowMessage('Aviso: Erro ao atualizar no Firebase: ' + Response.StatusText);
      finally
        RequestStream.Free;
      end;
    finally
      JSONDoc.Free;
    end;
  finally
    HTTP.Free;
  end;
end;

procedure TFormCadastroLoginAlunos.btnSalvarClick(Sender: TObject);
var
  DocId: string;
  NomeAluno: string;
  NomeAtual, SenhaAtual: string;
  PrimeiroLoginAtual: Boolean;
begin
  if not ValidarCampos then Exit;

  NomeAluno := StringReplace(lblNomeAluno.Caption, 'Nome do Aluno: ', '', [rfReplaceAll]);

  try
    if not FEditando then
    begin
      // Salvar apenas no Firebase
      SalvarNoFirebase;
      ShowMessage('Login criado com sucesso!');
    end
    else
    begin
      // Para edição, precisamos buscar o Document ID do Firebase
      // Como não temos cache local, vamos buscar no Firebase
      DocId := BuscarDocumentIdFirebase(FCodigoAlunoAtual);
      
      if DocId <> '' then
      begin
        // Buscar dados atuais do aluno no Firebase para não perder campos
        BuscarDadosAlunoFirebase(DocId, NomeAtual, SenhaAtual, PrimeiroLoginAtual);
        AtualizarNoFirebase(DocId, FCodigoAlunoAtual, NomeAtual, SenhaAtual, PrimeiroLoginAtual);
        ShowMessage('Login atualizado com sucesso!');
      end
      else
      begin
        ShowMessage('Erro: usuário não encontrado no Firebase para atualização.');
      end;
    end;

    CarregarGrid;
    LimparCampos;
    HabilitarCampos(False);
  except
    on E: Exception do
      ShowMessage('Erro ao salvar: ' + E.Message);
  end;
end;

procedure TFormCadastroLoginAlunos.btnNovoClick(Sender: TObject);
begin
  LimparCampos;
  HabilitarCampos(True);
  edtCodigoAluno.SetFocus;
end;

procedure TFormCadastroLoginAlunos.btnEditarClick(Sender: TObject);
begin
  if FDMemTableAlunos.IsEmpty then
  begin
    ShowMessage('Selecione um registro para editar!');
    Exit;
  end;

  FEditando := True;
  FCodigoAlunoAtual := FDMemTableAlunos.FieldByName('CODIGO').AsInteger;

  edtCodigoAluno.Text := FCodigoAlunoAtual.ToString;
  edtUsuario.Text := FDMemTableAlunos.FieldByName('USUARIO').AsString;
  chkAtivo.Checked := FDMemTableAlunos.FieldByName('ATIVO').AsInteger = 1;
  lblNomeAluno.Caption := 'Nome do Aluno: ' + FDMemTableAlunos.FieldByName('NOME').AsString;

  HabilitarCampos(True);
  edtUsuario.SetFocus;
end;

procedure TFormCadastroLoginAlunos.DBGridLoginsDblClick(Sender: TObject);
begin
  btnEditarClick(Sender);
end;

procedure TFormCadastroLoginAlunos.btnAtualizarClick(Sender: TObject);
begin
  CarregarGrid;
end;

procedure TFormCadastroLoginAlunos.btnFecharClick(Sender: TObject);
begin
  Close;
end;

procedure TFormCadastroLoginAlunos.CarregarDadosEdicao;
begin
  if FDMemTableAlunos.IsEmpty then Exit;
  
  FCodigoAlunoAtual := FDMemTableAlunos.FieldByName('CODIGO').AsInteger;
  edtCodigoAluno.Text := FCodigoAlunoAtual.ToString;
  edtUsuario.Text := FDMemTableAlunos.FieldByName('USUARIO').AsString;
  chkAtivo.Checked := FDMemTableAlunos.FieldByName('ATIVO').AsInteger = 1;
  lblNomeAluno.Caption := 'Nome do Aluno: ' + FDMemTableAlunos.FieldByName('NOME').AsString;
end;

procedure TFormCadastroLoginAlunos.ExcluirDoFirebase(DocumentId: string);
const
  URL_BASE = 'https://firestore.googleapis.com/v1/projects/clickacademico-342da/databases/(default)/documents/alunos_online';
  FIREBASE_API_KEY = 'AIzaSyA2-w2UfVhzN2prqJ2H0kecHYwLTC3XbkU';
var
  HTTP: TNetHTTPClient;
  Response: IHTTPResponse;
begin
  HTTP := TNetHTTPClient.Create(nil);
  try
    Response := HTTP.Delete(URL_BASE + '/' + DocumentId + '?key=' + FIREBASE_API_KEY);

    if not (Response.StatusCode in [200, 204]) then
      raise Exception.Create('Erro ao excluir do Firebase: ' + Response.StatusText);
  finally
    HTTP.Free;
  end;
end;

procedure TFormCadastroLoginAlunos.btnExcluirClick(Sender: TObject);
var
  DocId: string;
  CodigoAluno: Integer;
  NomeAluno: string;
begin
  if FDMemTableAlunos.IsEmpty then
  begin
    ShowMessage('Selecione um aluno para excluir.');
    Exit;
  end;

  CodigoAluno := FDMemTableAlunos.FieldByName('CODIGO').AsInteger;
  NomeAluno := FDMemTableAlunos.FieldByName('NOME').AsString;

  if MessageDlg('Confirma a exclusão do login do aluno:' + sLineBreak +
                'Código: ' + CodigoAluno.ToString + sLineBreak +
                'Nome: ' + NomeAluno + sLineBreak + sLineBreak +
                'Esta operação não pode ser desfeita.',
                mtConfirmation, [mbYes, mbNo], 0) = mrYes then
  begin
    try
      // Buscar o Document ID no Firebase
      DocId := BuscarDocumentIdFirebase(CodigoAluno);

      if DocId <> '' then
      begin
        ExcluirDoFirebase(DocId);
        ShowMessage('Login excluído com sucesso!');
        CarregarGrid;
        LimparCampos;
      end
      else
      begin
        ShowMessage('Erro: usuário não encontrado no Firebase.');
      end;
    except
      on E: Exception do
        ShowMessage('Erro ao excluir: ' + E.Message);
    end;
  end;
end;

procedure TFormCadastroLoginAlunos.ResetarSenhaNoFirebase(DocumentId: string);
const
  URL_BASE = 'https://firestore.googleapis.com/v1/projects/clickacademico-342da/databases/(default)/documents/alunos_online';
  FIREBASE_API_KEY = 'AIzaSyA2-w2UfVhzN2prqJ2H0kecHYwLTC3XbkU';
var
  HTTP: TNetHTTPClient;
  Response: IHTTPResponse;
  JSONBody: TJSONObject;
  JSONFields: TJSONObject;
  JSONSenha: TJSONObject;
  JSONPrimeiroLogin: TJSONObject;
  BodyStream: TStringStream;
begin
  HTTP := TNetHTTPClient.Create(nil);
  JSONBody := TJSONObject.Create;
  JSONFields := TJSONObject.Create;
  JSONSenha := TJSONObject.Create;
  JSONPrimeiroLogin := TJSONObject.Create;
  BodyStream := TStringStream.Create;
  try
    // Montar o JSON com apenas os campos a atualizar
    JSONSenha.AddPair('nullValue', TJSONNull.Create);
    JSONFields.AddPair('senha', JSONSenha);

    JSONPrimeiroLogin.AddPair('booleanValue', TJSONBool.Create(True));
    JSONFields.AddPair('primeiro_login', JSONPrimeiroLogin);

    JSONBody.AddPair('fields', JSONFields);

    BodyStream.WriteString(JSONBody.ToString);
    BodyStream.Position := 0;

    // Usar updateMask para atualizar apenas os campos especificos (preserva outros campos)
    Response := HTTP.Patch(URL_BASE + '/' + DocumentId + '?key=' + FIREBASE_API_KEY +
                            '&updateMask.fieldPaths=senha&updateMask.fieldPaths=primeiro_login',
                            BodyStream);

    if not (Response.StatusCode in [200, 204]) then
      raise Exception.Create('Erro ao resetar senha: ' + Response.StatusText);
  finally
    BodyStream.Free;
    JSONBody.Free;
    HTTP.Free;
  end;
end;

procedure TFormCadastroLoginAlunos.btnResetarSenhaClick(Sender: TObject);
var
  DocId: string;
  CodigoAluno: Integer;
  NomeAluno: string;
begin
  if FDMemTableAlunos.IsEmpty then
  begin
    ShowMessage('Selecione um aluno para resetar a senha.');
    Exit;
  end;

  CodigoAluno := FDMemTableAlunos.FieldByName('CODIGO').AsInteger;
  NomeAluno := FDMemTableAlunos.FieldByName('NOME').AsString;

  if MessageDlg('Confirma o reset de senha do aluno:' + sLineBreak +
                'Código: ' + CodigoAluno.ToString + sLineBreak +
                'Nome: ' + NomeAluno + sLineBreak + sLineBreak +
                'A senha será removida e o aluno precisará criar uma nova senha no próximo login.',
                mtConfirmation, [mbYes, mbNo], 0) = mrYes then
  begin
    try
      // Buscar o Document ID no Firebase
      DocId := BuscarDocumentIdFirebase(CodigoAluno);

      if DocId <> '' then
      begin
        ResetarSenhaNoFirebase(DocId);
        ShowMessage('Senha resetada com sucesso!' + sLineBreak +
                    'O aluno precisará criar uma nova senha no próximo login.');
      end
      else
      begin
        ShowMessage('Erro: usuário não encontrado no Firebase.');
      end;
    except
      on E: Exception do
        ShowMessage('Erro ao resetar senha: ' + E.Message);
    end;
  end;
end;

// ========== CADASTRO EM LOTE ==========

procedure TFormCadastroLoginAlunos.btnCadastrarTodosClick(Sender: TObject);
begin
  if MessageDlg('Deseja cadastrar logins para TODOS os alunos do sistema?' + sLineBreak +
                sLineBreak +
                '- Serão criados apenas para alunos que ainda não possuem login' + sLineBreak +
                '- Usuário e senha serão o CPF do aluno (apenas números)' + sLineBreak +
                sLineBreak +
                'Continuar?',
                mtConfirmation, [mbYes, mbNo], 0) = mrYes then
  begin
    CadastrarTodosAlunos;
  end;
end;

function TFormCadastroLoginAlunos.LoginJaExiste(CodigoAluno: Integer): Boolean;
begin
  Result := BuscarDocumentIdFirebase(CodigoAluno) <> '';
end;

function TFormCadastroLoginAlunos.CriarLoginFirebase(CodigoAluno: Integer; NomeAluno, CPF: string): Boolean;
const
  URL_BASE = 'https://firestore.googleapis.com/v1/projects/clickacademico-342da/databases/(default)/documents/alunos_online';
  FIREBASE_API_KEY = 'AIzaSyA2-w2UfVhzN2prqJ2H0kecHYwLTC3XbkU';
var
  HTTP: TNetHTTPClient;
  JSONDoc, Fields, Item: TJSONObject;
  RequestStream: TStringStream;
  Response: IHTTPResponse;
  CPFNumeros: string;
  i: Integer;
begin
  Result := False;

  // Extrair apenas números do CPF
  CPFNumeros := '';
  for i := 1 to Length(CPF) do
    if CharInSet(CPF[i], ['0'..'9']) then
      CPFNumeros := CPFNumeros + CPF[i];

  // Se CPF estiver vazio após limpeza, usar codigo do aluno
  if CPFNumeros = '' then
    CPFNumeros := CodigoAluno.ToString;

  HTTP := TNetHTTPClient.Create(nil);
  try
    HTTP.ContentType := 'application/json';

    Fields := TJSONObject.Create;

    // Código do Aluno
    Item := TJSONObject.Create;
    Item.AddPair('integerValue', CodigoAluno.ToString);
    Fields.AddPair('codigo_aluno', Item);

    // Nome do Aluno
    Item := TJSONObject.Create;
    Item.AddPair('stringValue', NomeAluno);
    Fields.AddPair('nome_aluno', Item);

    // Usuário = CPF (apenas números)
    Item := TJSONObject.Create;
    Item.AddPair('stringValue', CPFNumeros);
    Fields.AddPair('usuario', Item);

    // Ativo = 1
    Item := TJSONObject.Create;
    Item.AddPair('integerValue', '1');
    Fields.AddPair('ativo', Item);

    // Data de Cadastro
    Item := TJSONObject.Create;
    Item.AddPair('timestampValue', FormatDateTime('yyyy-mm-dd"T"hh:nn:ss"Z"', Now));
    Fields.AddPair('data_cadastro', Item);

    // Senha = CPF (apenas números)
    Item := TJSONObject.Create;
    Item.AddPair('stringValue', CPFNumeros);
    Fields.AddPair('senha', Item);

    // Primeiro Login = false (pois já tem senha)
    Item := TJSONObject.Create;
    Item.AddPair('booleanValue', 'false');
    Fields.AddPair('primeiro_login', Item);

    JSONDoc := TJSONObject.Create;
    try
      JSONDoc.AddPair('fields', Fields);

      RequestStream := TStringStream.Create(JSONDoc.ToJSON, TEncoding.UTF8);
      try
        Response := HTTP.Post(URL_BASE + '?key=' + FIREBASE_API_KEY, RequestStream);
        Result := Response.StatusCode in [200, 201];
      finally
        RequestStream.Free;
      end;
    finally
      JSONDoc.Free;
    end;
  finally
    HTTP.Free;
  end;
end;

procedure TFormCadastroLoginAlunos.CadastrarTodosAlunos;
var
  QueryAlunos: TFDQuery;
  Criados, Ignorados: Integer;
  NomeAluno, CPF: string;
  CodigoAluno: Integer;
begin
  Criados := 0;
  Ignorados := 0;

  QueryAlunos := TFDQuery.Create(nil);
  try
    QueryAlunos.Connection := FDConnection;
    QueryAlunos.SQL.Text := 'SELECT CODIGO, NOME, CPF FROM ALUNO ORDER BY CODIGO';
    QueryAlunos.Open;

    // Desativar botões durante o processo
    btnCadastrarTodos.Enabled := False;
    btnAtualizar.Enabled := False;
    try
      while not QueryAlunos.Eof do
      begin
        CodigoAluno := QueryAlunos.FieldByName('CODIGO').AsInteger;
        NomeAluno := QueryAlunos.FieldByName('NOME').AsString;
        CPF := QueryAlunos.FieldByName('CPF').AsString;

        // Verificar se CPF está preenchido
        if Trim(CPF) = '' then
        begin
          Inc(Ignorados);
          QueryAlunos.Next;
          Continue;
        end;

        // Verificar se já existe login
        if LoginJaExiste(CodigoAluno) then
        begin
          Inc(Ignorados);
        end
        else
        begin
          // Criar login
          if CriarLoginFirebase(CodigoAluno, NomeAluno, CPF) then
            Inc(Criados)
          else
            Inc(Ignorados);
        end;

        QueryAlunos.Next;
        Application.ProcessMessages;
      end;
    finally
      btnCadastrarTodos.Enabled := True;
      btnAtualizar.Enabled := True;
    end;

    ShowMessage('Processamento concluído!' + sLineBreak + sLineBreak +
                'Logins criados: ' + Criados.ToString + sLineBreak +
                'Já existentes (ignorados): ' + Ignorados.ToString);

    CarregarGrid;
  finally
    QueryAlunos.Free;
  end;
end;

// ========== CADASTRO INDIVIDUAL VIA MODAL ==========

procedure TFormCadastroLoginAlunos.btnAdicionarIndividualClick(Sender: TObject);
var
  FormSelecionar: TFormSelecionarAluno;
  CPFNumeros: string;
  i: Integer;
begin
  FormSelecionar := TFormSelecionarAluno.Create(Self);
  try
    FormSelecionar.Connection := FDConnection;
    
    if FormSelecionar.ShowModal = mrOk then
    begin
      // Verificar se já existe login
      if LoginJaExiste(FormSelecionar.CodigoSelecionado) then
      begin
        ShowMessage('Este aluno já possui login cadastrado!');
        Exit;
      end;

      // Preencher os campos do formulário principal
      FCodigoAlunoAtual := FormSelecionar.CodigoSelecionado;
      edtCodigoAluno.Text := FCodigoAlunoAtual.ToString;
      lblNomeAluno.Caption := 'Nome do Aluno: ' + FormSelecionar.NomeSelecionado;
      
      // Extrair apenas números do CPF
      CPFNumeros := '';
      for i := 1 to Length(FormSelecionar.CPFSelecionado) do
        if CharInSet(FormSelecionar.CPFSelecionado[i], ['0'..'9']) then
          CPFNumeros := CPFNumeros + FormSelecionar.CPFSelecionado[i];
      
      // Se CPF vazio, usar código
      if CPFNumeros = '' then
        CPFNumeros := FCodigoAlunoAtual.ToString;
      
      // Preencher usuário (somente leitura - CPF fixo)
      edtUsuario.Text := CPFNumeros;
      edtUsuario.Enabled := False; // Não permite alterar
      
      chkAtivo.Checked := True;
      
      // Habilitar modo de edição
      FEditando := False;
      HabilitarCampos(True);
      
      // Salvar automaticamente
      if ValidarCampos then
      begin
        SalvarNoFirebase;
        ShowMessage('Login criado com sucesso!' + sLineBreak +
                    'Usuário: ' + CPFNumeros + sLineBreak +
                    'Senha: ' + CPFNumeros);
        CarregarGrid;
        LimparCampos;
        HabilitarCampos(False);
      end;
    end;
  finally
    FormSelecionar.Free;
  end;
end;

end.
