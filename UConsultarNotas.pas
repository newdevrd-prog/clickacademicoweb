unit UConsultarNotas;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls, Vcl.ExtCtrls, Vcl.Buttons, Vcl.Grids,
  Vcl.DBGrids, Data.DB, FireDAC.Comp.Client, FireDAC.Stan.Intf, FireDAC.Stan.Option,
  FireDAC.Stan.Error, FireDAC.UI.Intf, FireDAC.Phys.Intf, FireDAC.Stan.Def, FireDAC.Stan.Pool,
  FireDAC.Stan.Async, FireDAC.Phys, FireDAC.Phys.FB, FireDAC.Phys.FBDef, FireDAC.VCLUI.Wait,
  FireDAC.Comp.DataSet, FireDAC.DatS, FireDAC.DApt.Intf, FireDAC.DApt, System.JSON,
  System.Net.HttpClient, System.Net.URLClient, System.Net.HttpClientComponent, Vcl.ComCtrls,
  System.DateUtils, FireDAC.Stan.Param;

const
  FIREBASE_PROJECT = 'clickacademico-342da';
  FIREBASE_API_KEY = 'AIzaSyA2-w2UfVhzN2prqJ2H0kecHYwLTC3XbkU';

type
  TFormConsultarNotas = class(TForm)
    PanelTopo: TPanel;
    lblTitulo: TLabel;
    PanelFiltros: TPanel;
    GroupBoxFiltros: TGroupBox;
    LabelAno: TLabel;
    cmbAno: TComboBox;
    LabelTurma: TLabel;
    cmbTurma: TComboBox;
    btnCarregar: TBitBtn;
    btnFechar: TBitBtn;
    PanelDados: TPanel;
    GroupBoxPeriodos: TGroupBox;
    lstPeriodos: TListBox;
    GroupBoxNotas: TGroupBox;
    DBGridNotas: TDBGrid;
    FDConnection: TFDConnection;
    FDMemTableNotas: TFDMemTable;
    DataSourceNotas: TDataSource;
    PanelProgresso: TPanel;
    LabelProgresso: TLabel;
    ProgressBar: TProgressBar;
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure btnFecharClick(Sender: TObject);
    procedure cmbAnoChange(Sender: TObject);
    procedure btnCarregarClick(Sender: TObject);
    procedure lstPeriodosClick(Sender: TObject);
  private
    { Private declarations }
    FHTTP: THTTPClient;
    procedure Log(const Msg: string);
    procedure AtualizarProgresso(Atual, Total: Integer; const Msg: string);
    procedure CarregarAnos;
    procedure CarregarTurmas(const Ano: string);
    procedure CarregarNotas(const Ano, Turma: string);
    procedure CarregarPeriodos;
    procedure FiltrarPorPeriodo(const Periodo: string);
    function ObterNomeAluno(const CodigoAluno: string): string;
    function ObterNomeDisciplina(const CodigoDisciplina: string): string;
    function ObterNomeProfessor(const CodigoProfessor: string): string;
  public
    { Public declarations }
  end;

var
  FormConsultarNotas: TFormConsultarNotas;

implementation

{$R *.dfm}

procedure TFormConsultarNotas.FormCreate(Sender: TObject);
begin
  FHTTP := THTTPClient.Create;
  FHTTP.ConnectionTimeout := 30000;
  FHTTP.ResponseTimeout := 30000;
  
  // Configurar MemTable
  FDMemTableNotas.FieldDefs.Clear;
  FDMemTableNotas.FieldDefs.Add('CODIGO_ALUNO', ftString, 20);
  FDMemTableNotas.FieldDefs.Add('NOME_ALUNO', ftString, 100);
  FDMemTableNotas.FieldDefs.Add('DISCIPLINA', ftString, 100);
  FDMemTableNotas.FieldDefs.Add('PERIODO', ftString, 50);
  FDMemTableNotas.FieldDefs.Add('NOTA', ftFloat);
  FDMemTableNotas.FieldDefs.Add('FALTAS', ftInteger);
  FDMemTableNotas.FieldDefs.Add('PROFESSOR', ftString, 100);
  FDMemTableNotas.FieldDefs.Add('DATA_LANCAMENTO', ftDateTime);
  FDMemTableNotas.CreateDataSet;
  FDMemTableNotas.Open;
  
  ProgressBar.Position := 0;
  LabelProgresso.Caption := 'Pronto';
  
  CarregarAnos;
end;

procedure TFormConsultarNotas.FormDestroy(Sender: TObject);
begin
  FHTTP.Free;
end;

procedure TFormConsultarNotas.btnFecharClick(Sender: TObject);
begin
  Close;
end;

procedure TFormConsultarNotas.cmbAnoChange(Sender: TObject);
begin
  if cmbAno.ItemIndex >= 0 then
    CarregarTurmas(cmbAno.Text)
  else
  begin
    cmbTurma.Clear;
    lstPeriodos.Clear;
    FDMemTableNotas.EmptyDataSet;
  end;
end;

procedure TFormConsultarNotas.btnCarregarClick(Sender: TObject);
begin
  if cmbAno.ItemIndex < 0 then
  begin
    ShowMessage('Selecione o ano.');
    Exit;
  end;
  
  if cmbTurma.ItemIndex < 0 then
  begin
    ShowMessage('Selecione a turma.');
    Exit;
  end;
  
  CarregarNotas(cmbAno.Text, cmbTurma.Text);
end;

procedure TFormConsultarNotas.lstPeriodosClick(Sender: TObject);
begin
  if lstPeriodos.ItemIndex >= 0 then
    FiltrarPorPeriodo(lstPeriodos.Items[lstPeriodos.ItemIndex])
  else
    FDMemTableNotas.Filtered := False;
end;

procedure TFormConsultarNotas.Log(const Msg: string);
begin
  LabelProgresso.Caption := Msg;
  Application.ProcessMessages;
end;

procedure TFormConsultarNotas.AtualizarProgresso(Atual, Total: Integer; const Msg: string);
begin
  if Total > 0 then
    ProgressBar.Position := Round((Atual / Total) * 100)
  else
    ProgressBar.Position := 0;
  LabelProgresso.Caption := Msg;
  Application.ProcessMessages;
end;

procedure TFormConsultarNotas.CarregarAnos;
begin
  cmbAno.Items.Clear;
  // Adicionar anos de 2020 a 2030
  for var Ano := 2020 to 2030 do
    cmbAno.Items.Add(IntToStr(Ano));
  
  // Selecionar ano atual
  cmbAno.ItemIndex := cmbAno.Items.IndexOf(IntToStr(YearOf(Now)));
end;

procedure TFormConsultarNotas.CarregarTurmas(const Ano: string);
begin
  cmbTurma.Clear;
  lstPeriodos.Clear;
  FDMemTableNotas.EmptyDataSet;
  
  Log('Carregando turmas do ano ' + Ano + '...');
  
  try
    var URL := 'https://firestore.googleapis.com/v1/projects/' + FIREBASE_PROJECT + 
               '/databases/(default)/documents/turmas?key=' + FIREBASE_API_KEY;
    
    var Response := FHTTP.Get(URL);
    var JSON := TJSONObject.ParseJSONValue(Response.ContentAsString) as TJSONObject;
    
    if JSON <> nil then
    begin
      var Documents := JSON.GetValue<TJSONArray>('documents');
      if Documents <> nil then
      begin
        for var I := 0 to Documents.Count - 1 do
        begin
          var Doc := Documents[I] as TJSONObject;
          var Fields := Doc.GetValue<TJSONObject>('fields');
          
          if Fields <> nil then
          begin
            var Inicio := Fields.GetValue<TJSONObject>('INICIO').GetValue<string>('stringValue');
            if Inicio <> '' then
            begin
              try
                var DataInicio := StrToDateDef(Inicio,04/19/2021);
                if YearOf(DataInicio) = StrToInt(Ano) then
                begin
                  var Nome := Fields.GetValue<TJSONObject>('NOME').GetValue<string>('stringValue');
                  var Codigo := Fields.GetValue<TJSONObject>('CODIGO').GetValue<string>('integerValue');
                  if (Nome <> '') and (Codigo <> '') then
                    cmbTurma.Items.AddObject(Nome, TObject(StrToInt(Codigo)));
                end;
              except
                on E: Exception do
                begin
                  // Ignorar erro de conversão de data
                  Continue;
                end;
              end;
            end;
          end;
        end;
      end;
      JSON.Free;
    end;
    
    Log('Turmas carregadas: ' + IntToStr(cmbTurma.Items.Count));
  except
    on E: Exception do
    begin
      Log('Erro ao carregar turmas: ' + E.Message);
    end;
  end;
end;

procedure TFormConsultarNotas.CarregarNotas(const Ano, Turma: string);
begin
  FDMemTableNotas.EmptyDataSet;
  lstPeriodos.Clear;
  
  Log('Carregando notas da turma ' + Turma + ' do ano ' + Ano + '...');
  
  try
    var URL := 'https://firestore.googleapis.com/v1/projects/' + FIREBASE_PROJECT + 
               '/databases/(default)/documents/notas_lancamentos?key=' + FIREBASE_API_KEY;
    
    var Response := FHTTP.Get(URL);
    var JSON := TJSONObject.ParseJSONValue(Response.ContentAsString) as TJSONObject;
    
    if JSON <> nil then
    begin
      var Documents := JSON.GetValue<TJSONArray>('documents');
      if Documents <> nil then
      begin
        AtualizarProgresso(0, Documents.Count, 'Processando notas...');

        var PeriodosSet := TStringList.Create;
        PeriodosSet.Sorted := True;
        PeriodosSet.Duplicates := dupIgnore;
        
        for var I := 0 to Documents.Count - 1 do
        begin
          var Doc := Documents[I] as TJSONObject;
          var Fields := Doc.GetValue<TJSONObject>('fields');
          
          if Fields <> nil then
          begin
            var AnoNota := Fields.GetValue<TJSONObject>('ANO').GetValue<string>('stringValue');
            var TurmaID := Fields.GetValue<TJSONObject>('TURMA_ID').GetValue<string>('stringValue');
            
            if (AnoNota = Ano) and (TurmaID = Turma) then
            begin
              var MatriculaID := Fields.GetValue<TJSONObject>('MATRICULA_ID').GetValue<string>('stringValue');
              var DisciplinaID := Fields.GetValue<TJSONObject>('DISCIPLINA_ID').GetValue<string>('stringValue');
              var PeriodoNome := Fields.GetValue<TJSONObject>('PERIODO_NOME').GetValue<string>('stringValue');
              var Nota := Fields.GetValue<TJSONObject>('NOTA').GetValue<Double>('doubleValue');
              var Faltas := Fields.GetValue<TJSONObject>('FALTAS').GetValue<Integer>('integerValue');
              var ProfessorID := Fields.GetValue<TJSONObject>('PROFESSOR_ID').GetValue<string>('stringValue');
              var DataLanc := Fields.GetValue<TJSONObject>('DATA_LANCAMENTO').GetValue<string>('timestampValue');
              
              // Adicionar período à lista
              if (PeriodoNome <> '') and (PeriodosSet.IndexOf(PeriodoNome) < 0) then
                PeriodosSet.Add(PeriodoNome);
              
              FDMemTableNotas.Append;
              FDMemTableNotas.FieldByName('CODIGO_ALUNO').AsString := MatriculaID;
              FDMemTableNotas.FieldByName('NOME_ALUNO').AsString := ObterNomeAluno(MatriculaID);
              FDMemTableNotas.FieldByName('DISCIPLINA').AsString := ObterNomeDisciplina(DisciplinaID);
              FDMemTableNotas.FieldByName('PERIODO').AsString := PeriodoNome;
              FDMemTableNotas.FieldByName('NOTA').AsFloat := Nota;
              FDMemTableNotas.FieldByName('FALTAS').AsInteger := Faltas;
              FDMemTableNotas.FieldByName('PROFESSOR').AsString := ObterNomeProfessor(ProfessorID);
              
              if DataLanc <> '' then
                FDMemTableNotas.FieldByName('DATA_LANCAMENTO').AsDateTime := ISO8601ToDate(DataLanc)
              else
                FDMemTableNotas.FieldByName('DATA_LANCAMENTO').Clear;
              
              FDMemTableNotas.Post;
            end;
          end;
          
          AtualizarProgresso(I + 1, Documents.Count, 'Processando notas...');
        end;
        
        // Preencher lista de períodos
        lstPeriodos.Items.Assign(PeriodosSet);
        PeriodosSet.Free;
      end;
      JSON.Free;
    end;
    
    Log('Notas carregadas: ' + IntToStr(FDMemTableNotas.RecordCount));
    AtualizarProgresso(100, 100, 'Concluído');
  except
    on E: Exception do
    begin
      Log('Erro ao carregar notas: ' + E.Message);
    end;
  end;
end;

procedure TFormConsultarNotas.CarregarPeriodos;
begin
  // Períodos já são carregados ao carregar as notas
end;

procedure TFormConsultarNotas.FiltrarPorPeriodo(const Periodo: string);
begin
  if Periodo = 'Todos' then
    FDMemTableNotas.Filtered := False
  else
  begin
    FDMemTableNotas.Filter := 'PERIODO = ''' + Periodo + '''';
    FDMemTableNotas.Filtered := True;
  end;
end;

function TFormConsultarNotas.ObterNomeAluno(const CodigoAluno: string): string;
begin
  Result := 'Aluno ' + CodigoAluno; // TODO: Buscar do Firebase
end;

function TFormConsultarNotas.ObterNomeDisciplina(const CodigoDisciplina: string): string;
begin
  Result := 'Disciplina ' + CodigoDisciplina; // TODO: Buscar do Firebase
end;

function TFormConsultarNotas.ObterNomeProfessor(const CodigoProfessor: string): string;
begin
  Result := 'Professor ' + CodigoProfessor; // TODO: Buscar do Firebase
end;

end.
