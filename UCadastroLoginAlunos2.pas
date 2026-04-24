unit UCadastroLoginAlunos;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls, Vcl.ExtCtrls, Vcl.Grids, Vcl.DBGrids,
  Vcl.ComCtrls, Data.DB, FireDAC.Comp.Client, FireDAC.Stan.Intf, FireDAC.Stan.Option,
  FireDAC.Stan.Error, FireDAC.UI.Intf, FireDAC.Phys.Intf, FireDAC.Stan.Def, FireDAC.Stan.Pool,
  FireDAC.Stan.Async, FireDAC.Phys, FireDAC.Phys.FB, FireDAC.Phys.FBDef, FireDAC.VCLUI.Wait,
  FireDAC.Comp.DataSet, System.JSON, System.Net.HttpClient, System.Net.URLClient,
  System.Net.HttpClientComponent;

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
    lblNomeAluno: TLabel;
    btnBuscarAluno: TButton;
    procedure btnFecharClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure btnBuscarAlunoClick(Sender: TObject);
    procedure btnSalvarClick(Sender: TObject);
    procedure btnNovoClick(Sender: TObject);
    procedure btnAtualizarClick(Sender: TObject);
    procedure btnEditarClick(Sender: TObject);
    procedure DBGridLoginsDblClick(Sender: TObject);
  private
    FEditando: Boolean;
    FCodigoAlunoAtual: Integer;
    procedure LimparCampos;
    procedure HabilitarCampos(Habilitar: Boolean);
    procedure CarregarGrid;
    procedure CarregarDadosEdicao;
    function ValidarCampos: Boolean;
    function UsuarioExiste(Usuario: string; IgnorarCodigo: Integer): Boolean;
    procedure SalvarNoFirebase;
    procedure AtualizarNoFirebase(DocumentId: string);
  public
    { Public declarations }
  end;

var
  FormCadastroLoginAlunos: TFormCadastroLoginAlunos;

implementation

{$R *.dfm}

const
  FIREBASE_PROJECT = 'clickacademico-342da';
  FIREBASE_API_KEY = 'AIzaSyA2-w2UfVhzN2prqJ2H0kecHYwLTC3XbkU';
  COLECAO = 'alunos_online';

procedure TFormCadastroLoginAlunos.FormCreate(Sender: TObject);
begin
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
const
  SQL_GRID = 
    'SELECT a.CODIGO, a.NOME, a.USUARIO, a.ATIVO, a.DOCUMENT_ID_FIREBASE ' +
    'FROM ALUNOS_LOGIN a ' +
    'ORDER BY a.NOME';
  SQL_CRIAR_TABELA = 
    'CREATE TABLE ALUNOS_LOGIN (' +
    '  CODIGO INTEGER PRIMARY KEY, ' +
    '  NOME VARCHAR(100), ' +
    '  USUARIO VARCHAR(50) UNIQUE, ' +
    '  ATIVO INTEGER DEFAULT 1, ' +
    '  DOCUMENT_ID_FIREBASE VARCHAR(100), ' +
    '  DATA_CADASTRO TIMESTAMP DEFAULT CURRENT_TIMESTAMP ' +
    ')';
  SQL_CHECK_TABELA = 'SELECT 1 FROM RDB$RELATIONS WHERE RDB$RELATION_NAME = ''ALUNOS_LOGIN''';
var
  CheckQuery: TFDQuery;
  TabelaExiste: Boolean;
begin
  // Verifica e cria tabela se necessario
  TabelaExiste := False;
  CheckQuery := TFDQuery.Create(nil);
  try
    CheckQuery.Connection := FDConnection;
    CheckQuery.SQL.Text := SQL_CHECK_TABELA;
    try
      CheckQuery.Open;
      TabelaExiste := not CheckQuery.IsEmpty;
      CheckQuery.Close;
    except
      TabelaExiste := False;
    end;
  finally
    CheckQuery.Free;
  end;

  if not TabelaExiste then
  begin
    try
      FDConnection.ExecSQL(SQL_CRIAR_TABELA);
      ShowMessage('Tabela ALUNOS_LOGIN criada com sucesso!');
    except
      on E: Exception do
        ShowMessage('Erro ao criar tabela: ' + E.Message);
    end;
  end;

  // Carregar grid
  try
    FDQueryAlunos.Close;
    FDQueryAlunos.SQL.Text := SQL_GRID;
    FDQueryAlunos.Open;
  except
    on E: Exception do
      ShowMessage('Erro ao carregar grid: ' + E.Message);
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

function TFormCadastroLoginAlunos.UsuarioExiste(Usuario: string; IgnorarCodigo: Integer): Boolean;
var
  Query: TFDQuery;
begin
  Result := False;
  Query := TFDQuery.Create(nil);
  try
    Query.Connection := FDConnection;
    Query.SQL.Text := 'SELECT 1 FROM ALUNOS_LOGIN WHERE USUARIO = :USUARIO AND CODIGO <> :CODIGO';
    Query.ParamByName('USUARIO').AsString := Usuario;
    Query.ParamByName('CODIGO').AsInteger := IgnorarCodigo;
    Query.Open;
    Result := not Query.IsEmpty;
  finally
    Query.Free;
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

  Result := True;
end;

procedure TFormCadastroLoginAlunos.SalvarNoFirebase;
const
  URL_BASE = 'https://firestore.googleapis.com/v1/projects/clickacademico-342da/databases/(default)/documents/alunos_online';
var
  HTTP: TNetHTTPClient;
  JSONDoc, FieldsObj: TJSONObject;
  RequestStream: TStringStream;
  Response: IHTTPResponse;
  ValorAtivo: Integer;
  ValorPrimeiroLogin: Integer;
begin
  HTTP := TNetHTTPClient.Create(nil);
  try
    HTTP.ContentType := 'application/json';

    JSONDoc := TJSONObject.Create;
    FieldsObj := TJSONObject.Create;
    try
      // Campos do documento
      FieldsObj.AddPair('codigo_aluno', TJSONObject.Create.AddPair('integerValue', FCodigoAlunoAtual.ToString));
      FieldsObj.AddPair('nome_aluno', TJSONObject.Create.AddPair('stringValue', lblNomeAluno.Caption.Replace('Nome do Aluno: ', '')));
      FieldsObj.AddPair('usuario', TJSONObject.Create.AddPair('stringValue', edtUsuario.Text));
      
      ValorAtivo := IfThen(chkAtivo.Checked, 1, 0);
      FieldsObj.AddPair('ativo', TJSONObject.Create.AddPair('integerValue', ValorAtivo.ToString));
      FieldsObj.AddPair('data_cadastro', TJSONObject.Create.AddPair('timestampValue',
        FormatDateTime('yyyy-mm-dd"T"hh:nn:ss"Z"', Now)));

      JSONDoc.AddPair('fields', FieldsObj);

      RequestStream := TStringStream.Create(JSONDoc.ToJSON, TEncoding.UTF8);
      try
        Response := HTTP.Post(URL_BASE + '?key=' + FIREBASE_API_KEY, RequestStream);

        if not (Response.StatusCode in [200, 201]) then
          ShowMessage('Aviso: Erro ao sincronizar com Firebase: ' + Response.StatusText);
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

procedure TFormCadastroLoginAlunos.AtualizarNoFirebase(DocumentId: string);
const
  URL_BASE = 'https://firestore.googleapis.com/v1/projects/clickacademico-342da/databases/(default)/documents/alunos_online/';
var
  HTTP: TNetHTTPClient;
  JSONDoc, FieldsObj: TJSONObject;
  RequestStream: TStringStream;
  Response: IHTTPResponse;
  ValorAtivo: Integer;
begin
  if DocumentId = '' then Exit;

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
const
  SQL_INSERT = 
    'INSERT INTO ALUNOS_LOGIN (CODIGO, NOME, USUARIO, ATIVO) ' +
    'VALUES (:CODIGO, :NOME, :USUARIO, :ATIVO)';
  SQL_UPDATE = 
    'UPDATE ALUNOS_LOGIN SET USUARIO = :USUARIO, ATIVO = :ATIVO ' +
    'WHERE CODIGO = :CODIGO';
  SQL_SELECT_DOC_ID = 'SELECT DOCUMENT_ID_FIREBASE FROM ALUNOS_LOGIN WHERE CODIGO = :CODIGO';
var
  QueryDocId: TFDQuery;
  DocId: string;
  NomeAluno: string;
begin
  if not ValidarCampos then Exit;

  NomeAluno := lblNomeAluno.Caption.Replace('Nome do Aluno: ', '');

  try
    if not FEditando then
    begin
      // Inserir novo
      FDConnection.ExecSQL(SQL_INSERT,
        [FCodigoAlunoAtual, NomeAluno, edtUsuario.Text,
         IfThen(chkAtivo.Checked, 1, 0)]);


      ShowMessage('Login criado com sucesso!');
    end
    else
    begin
      // Atualizar existente
      FDConnection.ExecSQL(SQL_UPDATE,
        [edtUsuario.Text, IfThen(chkAtivo.Checked, 1, 0), FCodigoAlunoAtual]);

      // Buscar Document ID do Firebase
      DocId := '';
      QueryDocId := TFDQuery.Create(nil);
      try
        QueryDocId.Connection := FDConnection;
        QueryDocId.SQL.Text := SQL_SELECT_DOC_ID;
        QueryDocId.ParamByName('CODIGO').AsInteger := FCodigoAlunoAtual;
        QueryDocId.Open;
        if not QueryDocId.IsEmpty then
          DocId := QueryDocId.FieldByName('DOCUMENT_ID_FIREBASE').AsString;
      finally
        QueryDocId.Free;
      end;

      // Atualizar no Firebase
      AtualizarNoFirebase(DocId);

      ShowMessage('Login atualizado com sucesso!');
    end;

    LimparCampos;
    HabilitarCampos(False);
    CarregarGrid;
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
  if FDQueryAlunos.IsEmpty then
  begin
    ShowMessage('Selecione um registro para editar!');
    Exit;
  end;

  FEditando := True;
  FCodigoAlunoAtual := FDQueryAlunos.FieldByName('CODIGO').AsInteger;

  edtCodigoAluno.Text := FCodigoAlunoAtual.ToString;
  edtUsuario.Text := FDQueryAlunos.FieldByName('USUARIO').AsString;
  chkAtivo.Checked := FDQueryAlunos.FieldByName('ATIVO').AsInteger = 1;
  lblNomeAluno.Caption := 'Nome do Aluno: ' + FDQueryAlunos.FieldByName('NOME').AsString;

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

end.
