unit UFormPrincipal;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls, Vcl.ExtCtrls, Vcl.ComCtrls, Vcl.Menus,
  UExportarBoletim, UCadastroLoginAlunos, UCadastroLoginProfessores, UConfigBoletim, UExportarDados,
  UConsultarNotas;

type
  TFormPrincipal = class(TForm)
    PanelTop: TPanel;
    lblTitulo: TLabel;
    MainMenu: TMainMenu;
    MenuArquivo: TMenuItem;
    MenuSair: TMenuItem;
    MenuBoletim: TMenuItem;
    MenuExportarBoletim: TMenuItem;
    MenuAlunos: TMenuItem;
    MenuCadastroLogin: TMenuItem;
    PanelBotoes: TPanel;
    btnExportarBoletim: TButton;
    btnCadastroLogin: TButton;
    btnCadastroLoginProfessores: TButton;
    btnConfigBoletim: TButton;
    btnExportarDados: TButton;
    btnConsultarNotas: TButton;
    btnSair: TButton;
    procedure btnSairClick(Sender: TObject);
    procedure btnExportarBoletimClick(Sender: TObject);
    procedure btnCadastroLoginClick(Sender: TObject);
    procedure btnCadastroLoginProfessoresClick(Sender: TObject);
    procedure btnConfigBoletimClick(Sender: TObject);
    procedure btnExportarDadosClick(Sender: TObject);
    procedure btnConsultarNotasClick(Sender: TObject);
    procedure MenuSairClick(Sender: TObject);
    procedure MenuExportarBoletimClick(Sender: TObject);
    procedure MenuCadastroLoginClick(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  FormPrincipal: TFormPrincipal;

implementation

{$R *.dfm}

procedure TFormPrincipal.btnSairClick(Sender: TObject);
begin
  Close;
end;

procedure TFormPrincipal.btnExportarBoletimClick(Sender: TObject);
begin
  FormExportarBoletim := TFormExportarBoletim.Create(Self);
  try
    FormExportarBoletim.ShowModal;
  finally
    FormExportarBoletim.Free;
  end;
end;

procedure TFormPrincipal.btnCadastroLoginClick(Sender: TObject);
begin
  FormCadastroLoginAlunos := TFormCadastroLoginAlunos.Create(Self);
  try
    FormCadastroLoginAlunos.ShowModal;
  finally
    FormCadastroLoginAlunos.Free;
  end;
end;

procedure TFormPrincipal.btnCadastroLoginProfessoresClick(Sender: TObject);
begin
  FormCadastroLoginProfessores := TFormCadastroLoginProfessores.Create(Self);
  try
    FormCadastroLoginProfessores.ShowModal;
  finally
    FormCadastroLoginProfessores.Free;
  end;
end;

procedure TFormPrincipal.btnConfigBoletimClick(Sender: TObject);
begin
  FormConfigBoletim := TFormConfigBoletim.Create(Self);
  try
    FormConfigBoletim.ShowModal;
  finally
    FormConfigBoletim.Free;
  end;
end;

procedure TFormPrincipal.btnExportarDadosClick(Sender: TObject);
begin
  FormExportarDados := TFormExportarDados.Create(Self);
  try
    FormExportarDados.ShowModal;
  finally
    FormExportarDados.Free;
  end;
end;

procedure TFormPrincipal.btnConsultarNotasClick(Sender: TObject);
begin
  FormConsultarNotas := TFormConsultarNotas.Create(Self);
  try
    FormConsultarNotas.ShowModal;
  finally
    FormConsultarNotas.Free;
  end;
end;

procedure TFormPrincipal.MenuSairClick(Sender: TObject);
begin
  Close;
end;

procedure TFormPrincipal.MenuExportarBoletimClick(Sender: TObject);
begin
  btnExportarBoletimClick(Sender);
end;

procedure TFormPrincipal.MenuCadastroLoginClick(Sender: TObject);
begin
  btnCadastroLoginClick(Sender);
end;

end.
