unit USelecionarAluno;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls, Vcl.ExtCtrls, Vcl.Grids, Vcl.DBGrids,
  Data.DB, FireDAC.Comp.Client, FireDAC.Comp.DataSet, FireDAC.Stan.Intf,
  FireDAC.Stan.Option, FireDAC.Stan.Param, FireDAC.Stan.Error, FireDAC.DatS,
  FireDAC.Phys.Intf, FireDAC.DApt.Intf,
  UConfigManager;

type
  TFormSelecionarAluno = class(TForm)
    PanelTop: TPanel;
    lblTitulo: TLabel;
    btnFechar: TButton;
    PanelBusca: TPanel;
    lblBusca: TLabel;
    edtBusca: TEdit;
    btnBuscar: TButton;
    PanelGrid: TPanel;
    DBGridAlunos: TDBGrid;
    PanelBotoes: TPanel;
    btnSelecionar: TButton;
    FDMemTableAlunos: TFDMemTable;
    DataSourceAlunos: TDataSource;
    btnLimpar: TButton;
    procedure FormCreate(Sender: TObject);
    procedure btnFecharClick(Sender: TObject);
    procedure btnBuscarClick(Sender: TObject);
    procedure btnSelecionarClick(Sender: TObject);
    procedure DBGridAlunosDblClick(Sender: TObject);
    procedure edtBuscaKeyPress(Sender: TObject; var Key: Char);
    procedure btnLimparClick(Sender: TObject);
  private
    FConnection: TFDConnection;
    FCodigoSelecionado: Integer;
    FNomeSelecionado: string;
    FCPFSelecionado: string;
    procedure CarregarAlunos(Filtro: string);
    procedure ConfigurarMemTable;
  public
    property Connection: TFDConnection write FConnection;
    property CodigoSelecionado: Integer read FCodigoSelecionado;
    property NomeSelecionado: string read FNomeSelecionado;
    property CPFSelecionado: string read FCPFSelecionado;
  end;

var
  FormSelecionarAluno: TFormSelecionarAluno;

implementation

{$R *.dfm}

procedure TFormSelecionarAluno.FormCreate(Sender: TObject);
begin
  FCodigoSelecionado := 0;
  FNomeSelecionado := '';
  FCPFSelecionado := '';
  ConfigurarMemTable;
end;

procedure TFormSelecionarAluno.ConfigurarMemTable;
begin
  FDMemTableAlunos.Close;
  FDMemTableAlunos.FieldDefs.Clear;
  FDMemTableAlunos.FieldDefs.Add('CODIGO', ftInteger, 0, False);
  FDMemTableAlunos.FieldDefs.Add('NOME', ftString, 100, False);
  FDMemTableAlunos.FieldDefs.Add('CPF', ftString, 20, False);
  FDMemTableAlunos.CreateDataSet;
  FDMemTableAlunos.Open;
end;

procedure TFormSelecionarAluno.CarregarAlunos(Filtro: string);
var
  Query: TFDQuery;
  SQL: string;
begin
  if not Assigned(FConnection) then
  begin
    ShowMessage('Conexão não configurada!');
    Exit;
  end;

  FDMemTableAlunos.Close;
  FDMemTableAlunos.Open;

  Query := TFDQuery.Create(nil);
  try
    Query.Connection := FConnection;
    
    SQL := 'SELECT CODIGO, NOME, CPF FROM ALUNO';
    
    if Trim(Filtro) <> '' then
    begin
      // Verificar se é número (CPF) ou texto (nome)
      if StrToIntDef(Filtro, 0) > 0 then
      begin
        // Busca por CPF (apenas números)
        SQL := SQL + ' AND (REPLACE(REPLACE(REPLACE(CPF, ''.'', ''''), ''-'', ''''), '' '', '''') CONTAINING :FILTRO)';
      end
      else
      begin
        // Busca por nome
        SQL := SQL + ' AND UPPER(NOME) CONTAINING UPPER(:FILTRO)';
      end;
      Query.ParamByName('FILTRO').AsString := Filtro;
    end;
    
    SQL := SQL + ' ORDER BY NOME';
    Query.SQL.Text := SQL;
    Query.Open;

    while not Query.Eof do
    begin
      FDMemTableAlunos.Append;
      FDMemTableAlunos.FieldByName('CODIGO').AsInteger := Query.FieldByName('CODIGO').AsInteger;
      FDMemTableAlunos.FieldByName('NOME').AsString := Query.FieldByName('NOME').AsString;
      FDMemTableAlunos.FieldByName('CPF').AsString := Query.FieldByName('CPF').AsString;
      FDMemTableAlunos.Post;
      Query.Next;
    end;

    FDMemTableAlunos.First;
  finally
    Query.Free;
  end;
end;

procedure TFormSelecionarAluno.btnBuscarClick(Sender: TObject);
begin
  CarregarAlunos(edtBusca.Text);
end;

procedure TFormSelecionarAluno.btnLimparClick(Sender: TObject);
begin
  edtBusca.Text := '';
  CarregarAlunos('');
end;

procedure TFormSelecionarAluno.edtBuscaKeyPress(Sender: TObject; var Key: Char);
begin
  if Key = #13 then
  begin
    Key := #0;
    btnBuscarClick(Sender);
  end;
end;

procedure TFormSelecionarAluno.btnSelecionarClick(Sender: TObject);
begin
  if FDMemTableAlunos.IsEmpty then
  begin
    ShowMessage('Selecione um aluno!');
    Exit;
  end;

  FCodigoSelecionado := FDMemTableAlunos.FieldByName('CODIGO').AsInteger;
  FNomeSelecionado := FDMemTableAlunos.FieldByName('NOME').AsString;
  FCPFSelecionado := FDMemTableAlunos.FieldByName('CPF').AsString;
  
  ModalResult := mrOk;
end;

procedure TFormSelecionarAluno.DBGridAlunosDblClick(Sender: TObject);
begin
  btnSelecionarClick(Sender);
end;

procedure TFormSelecionarAluno.btnFecharClick(Sender: TObject);
begin
  ModalResult := mrCancel;
end;

end.
