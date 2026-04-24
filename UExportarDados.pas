unit UExportarDados;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls, Vcl.ExtCtrls, Vcl.Buttons, Vcl.Grids, Vcl.DBGrids,
  Vcl.ComCtrls, Data.DB, FireDAC.Comp.Client, FireDAC.Stan.Intf, FireDAC.Stan.Option,
  FireDAC.Stan.Error, FireDAC.UI.Intf, FireDAC.Phys.Intf, FireDAC.Stan.Def, FireDAC.Stan.Pool,
  FireDAC.Stan.Async, FireDAC.Phys, FireDAC.Phys.FB, FireDAC.Phys.FBDef, FireDAC.VCLUI.Wait,
  FireDAC.Comp.DataSet, System.JSON, System.Net.HttpClient, System.Net.URLClient,
  System.Net.HttpClientComponent, System.DateUtils, FireDAC.Stan.Param,
  FireDAC.DatS, FireDAC.DApt.Intf, FireDAC.DApt;

const
  FIREBASE_PROJECT = 'clickacademico-342da';
  FIREBASE_API_KEY = 'AIzaSyA2-w2UfVhzN2prqJ2H0kecHYwLTC3XbkU';

  // Coleções Firebase
  COLECAO_ALUNOS = 'alunos';
  COLECAO_CURSOS = 'cursos';
  COLECAO_DISCIPLINAS = 'disciplinas';
  COLECAO_PROFESSORES = 'professores';
  COLECAO_TURMAS = 'turmas';
  COLECAO_MATRICULAS = 'matriculas';
  COLECAO_ALUNOFREQUENCIA = 'aluno_frequencia';

type
  TFormExportarDados = class(TForm)
    PanelTopo: TPanel;
    lblTitulo: TLabel;
    PanelConfig: TPanel;
    GroupBoxConfig: TGroupBox;
    LabelAnoMatricula: TLabel;
    cmbAnoMatricula: TComboBox;
    chkSobrescrever: TCheckBox;
    btnExportarTodos: TBitBtn;
    btnFechar: TBitBtn;
    PanelProgresso: TPanel;
    LabelProgresso: TLabel;
    ProgressBarTotal: TProgressBar;
    PanelLog: TPanel;
    GroupBoxLog: TGroupBox;
    MemoLog: TMemo;
    PanelHistorico: TPanel;
    GroupBoxHistorico: TGroupBox;
    DBGridHistorico: TDBGrid;
    FDConnection: TFDConnection;
    FDQueryExportacao: TFDQuery;
    FDQueryLog: TFDQuery;
    FDQueryInsertLog: TFDQuery;
    DataSourceHistorico: TDataSource;
    procedure FormCreate(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure btnFecharClick(Sender: TObject);
    procedure btnExportarTodosClick(Sender: TObject);
  private
    { Private declarations }
    FHTTP: THTTPClient;
    procedure Log(const Msg: string);
    procedure AtualizarProgresso(Atual, Total: Integer; const Msg: string);
    procedure CriarTabelaLogSeNaoExistir;
    procedure CarregarHistorico;
    procedure CarregarAnosMatricula;
    
    // Funções de exportação
    function ExportarTabela(const NomeTabela, NomeColecao, CampoCodigo: string; Filtro: string = ''): Integer;
    function VerificarRegistroExiste(const NomeColecao, Codigo: string): Boolean;
    function InserirNoFirebase(const NomeColecao, Codigo: string; const Dados: TJSONObject): Boolean;
    function AtualizarNoFirebase(const NomeColecao, Codigo: string; const Dados: TJSONObject): Boolean;
    
    // Exportação específica de cada tabela
    function ExportarAlunos: Integer;
    function ExportarCursos: Integer;
    function ExportarDisciplinas: Integer;
    function ExportarProfessores: Integer;
    function ExportarTurmas: Integer;
    function ExportarMatriculas: Integer;
    function ExportarAlunoFrequencia: Integer;
    
    // Salvar log
    procedure SalvarLogExportacao(Tabelas: string; TotalRegistros: Integer; Status: string);
  public
    { Public declarations }
  end;

var
  FormExportarDados: TFormExportarDados;

implementation

{$R *.dfm}

procedure TFormExportarDados.FormCreate(Sender: TObject);
begin
  FHTTP := THTTPClient.Create;
  FHTTP.ConnectionTimeout := 30000;
  FHTTP.ResponseTimeout := 30000;
  
  MemoLog.Clear;
  ProgressBarTotal.Position := 0;
  LabelProgresso.Caption := 'Pronto';
  
  CriarTabelaLogSeNaoExistir;
end;

procedure TFormExportarDados.FormShow(Sender: TObject);
begin
  CarregarAnosMatricula;
  CarregarHistorico;
end;

procedure TFormExportarDados.btnFecharClick(Sender: TObject);
begin
  Close;
end;

procedure TFormExportarDados.Log(const Msg: string);
begin
  MemoLog.Lines.Add(FormatDateTime('hh:nn:ss', Now) + ' - ' + Msg);
  // Scroll para o final
  MemoLog.SelStart := Length(MemoLog.Text);
  MemoLog.SelLength := 0;
  Application.ProcessMessages;
end;

procedure TFormExportarDados.AtualizarProgresso(Atual, Total: Integer; const Msg: string);
begin
  if Total > 0 then
    ProgressBarTotal.Position := Round((Atual / Total) * 100)
  else
    ProgressBarTotal.Position := 0;
  LabelProgresso.Caption := Msg;
  Application.ProcessMessages;
end;

procedure TFormExportarDados.CriarTabelaLogSeNaoExistir;
var
  Qry: TFDQuery;
  TabelaExiste: Boolean;
begin
  TabelaExiste := False;
  Qry := TFDQuery.Create(nil);
  
  try
    try
      Qry.Connection := FDConnection;
      // Verificar se a tabela existe no Firebird
      Qry.SQL.Text :=
        'SELECT COUNT(*) AS QTDE FROM RDB$RELATIONS ' +
        'WHERE RDB$RELATION_NAME = ''EXPORTACAO_LOG''';
      Qry.Open;
      
      TabelaExiste := Qry.FieldByName('QTDE').AsInteger > 0;
      Qry.Close;
      
      if not TabelaExiste then
      begin
        Log('Tabela EXPORTACAO_LOG não existe. Criando...');
        
        // Criar a tabela
        FDConnection.ExecSQL(
          'CREATE TABLE EXPORTACAO_LOG (' +
          '  CODIGO INTEGER NOT NULL PRIMARY KEY,' +
          '  DATA_EXPORTACAO DATE NOT NULL,' +
          '  HORA_EXPORTACAO TIME NOT NULL,' +
          '  TABELAS_EXPORTADAS VARCHAR(200),' +
          '  TOTAL_REGISTROS INTEGER,' +
          '  STATUS VARCHAR(20)' +
          ')'
        );
        
        Log('Tabela EXPORTACAO_LOG criada com sucesso');
      end
      else
      begin
        Log('Tabela EXPORTACAO_LOG já existe');
      end;
    except
      on E: Exception do
        Log('Erro ao verificar/criar tabela EXPORTACAO_LOG: ' + E.Message);
    end;
  finally
    Qry.Free;
  end;
end;

procedure TFormExportarDados.CarregarHistorico;
var
  QryCheck: TFDQuery;
  TabelaExiste: Boolean;
begin
  // Verificar se a tabela existe antes de tentar carregar
  TabelaExiste := False;
  QryCheck := TFDQuery.Create(nil);
  
  try
    try
      QryCheck.Connection := FDConnection;
      QryCheck.SQL.Text :=
        'SELECT COUNT(*) AS QTDE FROM RDB$RELATIONS ' +
        'WHERE RDB$RELATION_NAME = ''EXPORTACAO_LOG''';
      QryCheck.Open;
      TabelaExiste := QryCheck.FieldByName('QTDE').AsInteger > 0;
      QryCheck.Close;
    except
      TabelaExiste := False;
    end;
  finally
    QryCheck.Free;
  end;
  
  // Se a tabela não existe, não tentar carregar
  if not TabelaExiste then
  begin
    Log('Tabela de histórico não existe. Pulando carregamento.');
    Exit;
  end;
  
  try
    FDQueryLog.Close;
    FDQueryLog.SQL.Text := 
      'SELECT DATA_EXPORTACAO, HORA_EXPORTACAO, TABELAS_EXPORTADAS, TOTAL_REGISTROS, STATUS ' +
      'FROM EXPORTACAO_LOG ' +
      'ORDER BY CODIGO DESC';
    FDQueryLog.Open;
    
    // Configurar colunas do grid
    if DBGridHistorico.Columns.Count > 0 then
    begin
      DBGridHistorico.Columns[0].Title.Caption := 'Data';
      DBGridHistorico.Columns[0].Width := 80;
      DBGridHistorico.Columns[1].Title.Caption := 'Hora';
      DBGridHistorico.Columns[1].Width := 60;
      DBGridHistorico.Columns[2].Title.Caption := 'Tabelas';
      DBGridHistorico.Columns[2].Width := 250;
      DBGridHistorico.Columns[3].Title.Caption := 'Registros';
      DBGridHistorico.Columns[3].Width := 80;
      DBGridHistorico.Columns[4].Title.Caption := 'Status';
      DBGridHistorico.Columns[4].Width := 100;
    end;
  except
    on E: Exception do
      Log('Erro ao carregar histórico: ' + E.Message);
  end;
end;

procedure TFormExportarDados.CarregarAnosMatricula;
var
  AnoAtual, Ano: Integer;
begin
  cmbAnoMatricula.Items.Clear;
  
  // Adicionar anos de 2020 até ano atual + 1
  AnoAtual := YearOf(Date);
  for Ano := 2020 to AnoAtual + 1 do
    cmbAnoMatricula.Items.Add(IntToStr(Ano));
  
  // Selecionar ano atual
  cmbAnoMatricula.ItemIndex := cmbAnoMatricula.Items.IndexOf(IntToStr(AnoAtual));
end;

function TFormExportarDados.VerificarRegistroExiste(const NomeColecao, Codigo: string): Boolean;
var
  URL: string;
  Response: IHTTPResponse;
begin
  Result := False;
  try
    URL := Format('https://firestore.googleapis.com/v1/projects/%s/databases/(default)/documents/%s/%s?key=%s',
      [FIREBASE_PROJECT, NomeColecao, Codigo, FIREBASE_API_KEY]);
    
    Response := FHTTP.Get(URL);
    Result := Response.StatusCode = 200;
  except
    Result := False;
  end;
end;

function TFormExportarDados.InserirNoFirebase(const NomeColecao, Codigo: string; const Dados: TJSONObject): Boolean;
var
  URL: string;
  Body: TStringStream;
  Response: IHTTPResponse;
  JSONDoc: TJSONObject;
  FieldsObj: TJSONObject;
  Pair: TJSONPair;
  i: Integer;
  Chave, Valor: string;
  ValorInt: Int64;
  ValorFloat: Double;
  DataValor: TDateTime;
begin
  Result := False;
  try
    // Usar o próprio código como ID do documento
    URL := Format('https://firestore.googleapis.com/v1/projects/%s/databases/(default)/documents/%s/%s?key=%s',
      [FIREBASE_PROJECT, NomeColecao, Codigo, FIREBASE_API_KEY]);
    
    // Converter TJSONObject para formato Firestore
    JSONDoc := TJSONObject.Create;
    FieldsObj := TJSONObject.Create;
    
    try
      // Iterar pelos campos do Dados
      for i := 0 to Dados.Count - 1 do
      begin
        Pair := Dados.Pairs[i];
        Chave := Pair.JsonString.Value;
        
        // Tentar converter para número
        if TryStrToInt64(Pair.JsonValue.Value, ValorInt) then
        begin
          FieldsObj.AddPair(Chave, TJSONObject.Create.AddPair('integerValue', ValorInt.ToString));
        end
        else if TryStrToFloat(Pair.JsonValue.Value, ValorFloat) then
        begin
          FieldsObj.AddPair(Chave, TJSONObject.Create.AddPair('doubleValue', FloatToStr(ValorFloat)));
        end
        else
        begin
          // String
          Valor := Pair.JsonValue.Value;
          FieldsObj.AddPair(Chave, TJSONObject.Create.AddPair('stringValue', Valor));
        end;
      end;
      
      JSONDoc.AddPair('fields', FieldsObj);
      
      Body := TStringStream.Create(JSONDoc.ToString, TEncoding.UTF8);
      try
        Response := FHTTP.Patch(URL, Body);
        Result := Response.StatusCode in [200, 201];
      finally
        Body.Free;
      end;
    finally
      JSONDoc.Free;
    end;
  except
    on E: Exception do
    begin
      Log('Erro ao inserir no Firebase: ' + E.Message);
      Result := False;
    end;
  end;
end;

function TFormExportarDados.AtualizarNoFirebase(const NomeColecao, Codigo: string; const Dados: TJSONObject): Boolean;
var
  URL: string;
  Body: TStringStream;
  Response: IHTTPResponse;
  JSONDoc: TJSONObject;
  FieldsObj: TJSONObject;
  UpdateMask: string;
  i: Integer;
  Pair: TJSONPair;
  Chave, Valor: string;
  ValorInt: Int64;
  ValorFloat: Double;
begin
  Result := False;
  try
    // Construir updateMask com todos os campos
    UpdateMask := '';
    for i := 0 to Dados.Count - 1 do
    begin
      if UpdateMask <> '' then
        UpdateMask := UpdateMask + '&';
      UpdateMask := UpdateMask + 'updateMask.fieldPaths=' + Dados.Pairs[i].JsonString.Value;
    end;
    
    // URL com updateMask
    URL := Format('https://firestore.googleapis.com/v1/projects/%s/databases/(default)/documents/%s/%s?key=%s&%s',
      [FIREBASE_PROJECT, NomeColecao, Codigo, FIREBASE_API_KEY, UpdateMask]);
    
    // Converter TJSONObject para formato Firestore
    JSONDoc := TJSONObject.Create;
    FieldsObj := TJSONObject.Create;
    
    try
      // Iterar pelos campos do Dados
      for i := 0 to Dados.Count - 1 do
      begin
        Pair := Dados.Pairs[i];
        Chave := Pair.JsonString.Value;
        
        // Tentar converter para número
        if TryStrToInt64(Pair.JsonValue.Value, ValorInt) then
        begin
          FieldsObj.AddPair(Chave, TJSONObject.Create.AddPair('integerValue', ValorInt.ToString));
        end
        else if TryStrToFloat(Pair.JsonValue.Value, ValorFloat) then
        begin
          FieldsObj.AddPair(Chave, TJSONObject.Create.AddPair('doubleValue', FloatToStr(ValorFloat)));
        end
        else
        begin
          // String
          Valor := Pair.JsonValue.Value;
          FieldsObj.AddPair(Chave, TJSONObject.Create.AddPair('stringValue', Valor));
        end;
      end;
      
      JSONDoc.AddPair('fields', FieldsObj);
      
      Body := TStringStream.Create(JSONDoc.ToString, TEncoding.UTF8);
      try
        Response := FHTTP.Patch(URL, Body);
        Result := Response.StatusCode in [200, 201];
      finally
        Body.Free;
      end;
    finally
      JSONDoc.Free;
    end;
  except
    on E: Exception do
    begin
      Log('Erro ao atualizar no Firebase: ' + E.Message);
      Result := False;
    end;
  end;
end;

function TFormExportarDados.ExportarTabela(const NomeTabela, NomeColecao, CampoCodigo: string; Filtro: string = ''): Integer;
var
  Qry: TFDQuery;
  Total, Atual, Processados: Integer;
  Codigo: string;
  Dados: TJSONObject;
  i: Integer;
  Existe: Boolean;
begin
  Result := 0;
  Qry := TFDQuery.Create(nil);
  
  try
    Qry.Connection := FDConnection;
    
    // Contar total
    Qry.SQL.Text := 'SELECT COUNT(*) AS TOTAL FROM ' + NomeTabela;
    if Filtro <> '' then
      Qry.SQL.Text := Qry.SQL.Text + ' WHERE ' + Filtro;
    Qry.Open;
    Total := Qry.FieldByName('TOTAL').AsInteger;
    Qry.Close;
    
    Log(Format('Iniciando exportação de %s: %d registros encontrados', [NomeTabela, Total]));
    
    if Total = 0 then
    begin
      Log('Nenhum registro para exportar em ' + NomeTabela);
      Exit;
    end;
    
    // Selecionar dados
    Qry.SQL.Text := 'SELECT * FROM ' + NomeTabela;
    if Filtro <> '' then
      Qry.SQL.Text := Qry.SQL.Text + ' WHERE ' + Filtro;
    Qry.Open;
    
    Atual := 0;
    Processados := 0;
    
    while not Qry.Eof do
    begin
      Inc(Atual);
      Codigo := Qry.FieldByName(CampoCodigo).AsString;
      
      if Codigo = '' then
      begin
        Log('Registro ' + IntToStr(Atual) + ' ignorado: código vazio');
        Qry.Next;
        Continue;
      end;
      
      // Verificar se já existe no Firebase
      Existe := VerificarRegistroExiste(NomeColecao, Codigo);
      
      // Criar objeto JSON com os dados
      Dados := TJSONObject.Create;
      try
        for i := 0 to Qry.FieldCount - 1 do
        begin
          if not Qry.Fields[i].IsNull then
            Dados.AddPair(Qry.Fields[i].FieldName, Qry.Fields[i].AsString);
        end;
        
        // Verificar se deve sobrescrever ou inserir
        if Existe and chkSobrescrever.Checked then
        begin
          // Atualizar com updateMask
          if AtualizarNoFirebase(NomeColecao, Codigo, Dados) then
          begin
            Inc(Processados);
            Log(Format('[%s] Registro %s ATUALIZADO com sucesso', [NomeTabela, Codigo]));
          end
          else
          begin
            Log(Format('[%s] ERRO ao atualizar registro %s', [NomeTabela, Codigo]));
          end;
        end
        else if not Existe then
        begin
          // Inserir novo registro
          if InserirNoFirebase(NomeColecao, Codigo, Dados) then
          begin
            Inc(Processados);
            Log(Format('[%s] Registro %s inserido com sucesso', [NomeTabela, Codigo]));
          end
          else
          begin
            Log(Format('[%s] ERRO ao inserir registro %s', [NomeTabela, Codigo]));
          end;
        end
        else
        begin
          // Registro existe e não está marcado para sobrescrever
          Log(Format('[%s] Registro %s já existe (pulado)', [NomeTabela, Codigo]));
        end;
      finally
        Dados.Free;
      end;
      
      AtualizarProgresso(Atual, Total, Format('Exportando %s: %d de %d', [NomeTabela, Atual, Total]));
      
      Qry.Next;
    end;
    
    Result := Processados;
    Log(Format('%s concluído: %d registros processados de %d total', [NomeTabela, Processados, Total]));
    
  finally
    Qry.Free;
  end;
end;

function TFormExportarDados.ExportarAlunos: Integer;
begin
  Log('=== EXPORTANDO ALUNOS ===');
  Result := ExportarTabela('ALUNO', COLECAO_ALUNOS, 'CODIGO');
end;

function TFormExportarDados.ExportarCursos: Integer;
begin
  Log('=== EXPORTANDO CURSOS ===');
  Result := ExportarTabela('CURSO', COLECAO_CURSOS, 'CODIGO');
end;

function TFormExportarDados.ExportarDisciplinas: Integer;
begin
  Log('=== EXPORTANDO DISCIPLINAS ===');
  Result := ExportarTabela('DISCIPLINA', COLECAO_DISCIPLINAS, 'CODIGO');
end;

function TFormExportarDados.ExportarProfessores: Integer;
begin
  Log('=== EXPORTANDO PROFESSORES ===');
  Result := ExportarTabela('FUNCIONARIO', COLECAO_PROFESSORES, 'CODIGO', 'PROFESSOR = ''S''');
end;

function TFormExportarDados.ExportarTurmas: Integer;
begin
  Log('=== EXPORTANDO TURMAS ===');
  Result := ExportarTabela('TURMA', COLECAO_TURMAS, 'CODIGO');
end;

function TFormExportarDados.ExportarMatriculas: Integer;
var
  AnoSelecionado: string;
  Filtro: string;
begin
  Log('=== EXPORTANDO MATRICULAS ===');
  
  AnoSelecionado := cmbAnoMatricula.Text;
  if AnoSelecionado = '' then
  begin
    Log('ERRO: Nenhum ano selecionado para matrículas');
    Result := 0;
    Exit;
  end;
  
  // Filtrar matrículas pelo ano
  Filtro := Format('EXTRACT(YEAR FROM DATA) = %s', [AnoSelecionado]);
  Log('Filtrando matrículas do ano: ' + AnoSelecionado);
  
  Result := ExportarTabela('MATRICULA', COLECAO_MATRICULAS, 'CODIGO', Filtro);
end;

function TFormExportarDados.ExportarAlunoFrequencia: Integer;
var
  AnoSelecionado: string;
  Filtro: string;
begin
  Log('=== EXPORTANDO ALUNOFREQUENCIA ===');
  
  AnoSelecionado := cmbAnoMatricula.Text;
  if AnoSelecionado = '' then
  begin
    Log('ERRO: Nenhum ano selecionado para aluno_frequencia');
    Result := 0;
    Exit;
  end;
  
  // Filtrar aluno_frequencia pelo ano
  Filtro := 'ANOLETIVO = ' + AnoSelecionado;
  Log('Filtrando aluno_frequencia do ano: ' + AnoSelecionado);
  
  Result := ExportarTabela('ALUNOFREQUENCIA', COLECAO_ALUNOFREQUENCIA, '', Filtro);
end;

procedure TFormExportarDados.SalvarLogExportacao(Tabelas: string; TotalRegistros: Integer; Status: string);
var
  ProximoCodigo: Integer;
begin
  try
    // Buscar próximo código
    FDQueryInsertLog.Close;
    FDQueryInsertLog.SQL.Text := 'SELECT MAX(CODIGO) AS MAX_COD FROM EXPORTACAO_LOG';
    FDQueryInsertLog.Open;
    
    if FDQueryInsertLog.FieldByName('MAX_COD').IsNull then
      ProximoCodigo := 1
    else
      ProximoCodigo := FDQueryInsertLog.FieldByName('MAX_COD').AsInteger + 1;
    
    FDQueryInsertLog.Close;
    
    // Inserir log
    FDQueryInsertLog.SQL.Text := 
      'INSERT INTO EXPORTACAO_LOG (CODIGO, DATA_EXPORTACAO, HORA_EXPORTACAO, TABELAS_EXPORTADAS, TOTAL_REGISTROS, STATUS) ' +
      'VALUES (:CODIGO, :DATA, :HORA, :TABELAS, :TOTAL, :STATUS)';
    
    FDQueryInsertLog.ParamByName('CODIGO').AsInteger := ProximoCodigo;
    FDQueryInsertLog.ParamByName('DATA').AsDate := Date;
    FDQueryInsertLog.ParamByName('HORA').AsTime := Time;
    FDQueryInsertLog.ParamByName('TABELAS').AsString := Tabelas;
    FDQueryInsertLog.ParamByName('TOTAL').AsInteger := TotalRegistros;
    FDQueryInsertLog.ParamByName('STATUS').AsString := Status;
    
    FDQueryInsertLog.ExecSQL;
    
    Log('Log de exportação salvo no Firebird');
    
    // Recarregar histórico
    CarregarHistorico;
  except
    on E: Exception do
      Log('Erro ao salvar log: ' + E.Message);
  end;
end;

procedure TFormExportarDados.btnExportarTodosClick(Sender: TObject);
var
  TotalAlunos, TotalCursos, TotalDisciplinas, TotalProfessores, TotalTurmas, TotalMatriculas, TotalAlunoFrequencia: Integer;
  TotalGeral: Integer;
  TabelasExportadas: string;
begin
  // Desabilitar botão
  btnExportarTodos.Enabled := False;
  btnFechar.Enabled := False;
  MemoLog.Clear;
  
  Log('========================================');
  Log('INICIANDO EXPORTAÇÃO COMPLETA');
  Log('Data/Hora: ' + DateTimeToStr(Now));
  if chkSobrescrever.Checked then
    Log('Modo: SOBRESCREVER registros existentes (UPDATE)')
  else
    Log('Modo: PULAR registros existentes (não duplicar)');
  Log('========================================');
  
  TotalGeral := 0;
  TabelasExportadas := '';
  
  try
    try
      // 1. Exportar Alunos
      TotalAlunos := ExportarAlunos;
      TotalGeral := TotalGeral + TotalAlunos;
      TabelasExportadas := TabelasExportadas + 'ALUNOS(' + IntToStr(TotalAlunos) + ') ';
      
      // 2. Exportar Cursos
      TotalCursos := ExportarCursos;
      TotalGeral := TotalGeral + TotalCursos;
      TabelasExportadas := TabelasExportadas + 'CURSOS(' + IntToStr(TotalCursos) + ') ';
      
      // 3. Exportar Disciplinas
      TotalDisciplinas := ExportarDisciplinas;
      TotalGeral := TotalGeral + TotalDisciplinas;
      TabelasExportadas := TabelasExportadas + 'DISCIPLINAS(' + IntToStr(TotalDisciplinas) + ') ';
      
      // 4. Exportar Professores
      TotalProfessores := ExportarProfessores;
      TotalGeral := TotalGeral + TotalProfessores;
      TabelasExportadas := TabelasExportadas + 'PROFESSORES(' + IntToStr(TotalProfessores) + ') ';
      
      // 5. Exportar Turmas
      TotalTurmas := ExportarTurmas;
      TotalGeral := TotalGeral + TotalTurmas;
      TabelasExportadas := TabelasExportadas + 'TURMAS(' + IntToStr(TotalTurmas) + ') ';
      
      // 6. Exportar Matrículas
      TotalMatriculas := ExportarMatriculas;
      TotalGeral := TotalGeral + TotalMatriculas;
      TabelasExportadas := TabelasExportadas + 'MATRICULAS(' + IntToStr(TotalMatriculas) + ') ';
      
      // 7. Exportar AlunoFrequencia
      TotalAlunoFrequencia := ExportarAlunoFrequencia;
      TotalGeral := TotalGeral + TotalAlunoFrequencia;
      TabelasExportadas := TabelasExportadas + 'ALUNOFREQUENCIA(' + IntToStr(TotalAlunoFrequencia) + ')';
      
      // Log final
      Log('========================================');
      Log('EXPORTAÇÃO CONCLUÍDA');
      Log('Total de registros exportados: ' + IntToStr(TotalGeral));
      Log('========================================');
      
      // Salvar log no Firebird
      SalvarLogExportacao(TabelasExportadas, TotalGeral, 'SUCESSO');
      
      // Atualizar progresso final
      AtualizarProgresso(100, 100, 'Exportação concluída! Total: ' + IntToStr(TotalGeral) + ' registros');
      
      ShowMessage('Exportação concluída com sucesso!' + #13#10 +
                  'Total de registros exportados: ' + IntToStr(TotalGeral));
      
    except
      on E: Exception do
      begin
        Log('ERRO CRÍTICO: ' + E.Message);
        SalvarLogExportacao(TabelasExportadas, TotalGeral, 'ERRO: ' + E.Message);
        ShowMessage('Erro durante a exportação: ' + E.Message);
        AtualizarProgresso(0, 100, 'Erro na exportação');
      end;
    end;
  finally
    btnExportarTodos.Enabled := True;
    btnFechar.Enabled := True;
  end;
end;

end.
