program exportador_boletim;

uses
  Vcl.Forms,
  System.SysUtils,
  System.IniFiles,
  System.IOUtils,
  Winapi.Windows,
  UConfigManager in 'UConfigManager.pas',
  UExportarBoletim in 'UExportarBoletim.pas' {FormExportarBoletim},
  USyncService in 'USyncService.pas',
  UCadastroLoginAlunos in 'UCadastroLoginAlunos.pas' {FormCadastroLoginAlunos},
  UFormPrincipal in 'UFormPrincipal.pas' {FormPrincipal},
  UConfigBoletim in 'UConfigBoletim.pas' {FormConfigBoletim},
  UCadastroLoginProfessores in 'UCadastroLoginProfessores.pas' {FormCadastroLoginProfessores},
  UExportarDados in 'UExportarDados.pas' {FormExportarDados},
  UConsultarNotas in 'UConsultarNotas.pas' {FormConsultarNotas},
  USelecionarAluno in 'USelecionarAluno.pas' {FormSelecionarAluno};

{$R *.res}

begin
  Application.Initialize;
  Application.MainFormOnTaskbar := True;

  // IMPORTANTE: ConfigManager é criado na initialization de UConfigManager
  // e já carrega as configurações. Mas precisamos garantir que ele recarregue
  // após o arquivo INI ser criado (se não existia).
  // Recarregar configurações ANTES de criar qualquer formulário
  ConfigManager.Reload;

  // Verificar se arquivo de configuração existe e mostrar mensagem se necessário
  if not TFile.Exists(ConfigManager.ConfigPath) then
  begin
    Application.MessageBox(
      PChar('Arquivo config.ini não encontrado!' + #13#10 +
            'Um arquivo padrão foi criado. Por favor, edite conforme necessário.' + #13#10 +
            'Caminho: ' + ConfigManager.ConfigPath),
      'Configuração Inicial',
      MB_ICONINFORMATION or MB_OK
    );
  end;

  // NOTA: Os formulários não devem ter 'Connected = True' nos DFM
  // e não devem tentar conectar no FormCreate.
  // Cada formulário deve chamar ConfigurarConexaoFromINI quando necessário.

  Application.CreateForm(TFormPrincipal, FormPrincipal);
  // Outros forms são criados manualmente quando necessário
  Application.Run;
end.
