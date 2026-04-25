unit UConfigManager;

interface

uses
  System.SysUtils, System.IniFiles, System.Classes,
  FireDAC.Comp.Client;

type
  TFirebaseConfig = record
    APIKey: string;
    ProjectID: string;
    FirestoreURL: string;
  end;

  TDatabaseConfig = record
    DriverID: string;
    Database: string;
    UserName: string;
    Password: string;
    Protocol: string;
    Server: string;
    Port: Integer;
  end;

  TApplicationConfig = record
    AppName: string;
    Version: string;
    Theme: string;
  end;

  TConfigManager = class
  private
    FIniFile: TIniFile;
    FFirebase: TFirebaseConfig;
    FDatabase: TDatabaseConfig;
    FApplication: TApplicationConfig;
    FConfigPath: string;
    procedure LoadFirebaseConfig;
    procedure LoadDatabaseConfig;
    procedure LoadApplicationConfig;
    function DecodeBase64(const Value: string): string;
  public
    constructor Create;
    destructor Destroy; override;
    procedure Reload;
    
    property Firebase: TFirebaseConfig read FFirebase;
    property Database: TDatabaseConfig read FDatabase;
    property Application: TApplicationConfig read FApplication;
    property ConfigPath: string read FConfigPath;
    
    function GetFirebirdConnectionString: string;
    function GetFirestoreBaseURL: string;
    procedure ConfigurarFDConnection(AConnection: TObject);
  end;

var
  ConfigManager: TConfigManager;

implementation

uses
  System.NetEncoding;

{ TConfigManager }

constructor TConfigManager.Create;
begin
  inherited Create;
  FConfigPath := ExtractFilePath(ParamStr(0)) + 'config.ini';
  FIniFile := TIniFile.Create(FConfigPath);
  Reload;
end;

destructor TConfigManager.Destroy;
begin
  FIniFile.Free;
  inherited;
end;

function TConfigManager.DecodeBase64(const Value: string): string;
begin
  if Value = '' then
    Exit('');
  try
    Result := TNetEncoding.Base64.Decode(Value);
  except
    Result := Value; // Retorna original se não for Base64 válido
  end;
end;

procedure TConfigManager.LoadFirebaseConfig;
begin
  FFirebase.APIKey := FIniFile.ReadString('Firebase', 'APIKey', 'AIzaSyA2-w2UfVhzN2prqJ2H0kecHYwLTC3XbkU');
  FFirebase.ProjectID := FIniFile.ReadString('Firebase', 'ProjectID', 'clickacademico-342da');
  FFirebase.FirestoreURL := FIniFile.ReadString('Firebase', 'FirestoreURL', 'https://firestore.googleapis.com/v1');
end;

procedure TConfigManager.LoadDatabaseConfig;
const
  PADRAO_DATABASE = 'C:\ClickAcademico\ClickAcademico.fdb';
var
  DBValue: string;
begin
  FDatabase.DriverID := FIniFile.ReadString('Database', 'DriverID', 'FB');

  // Ler valor do INI mas validar para nunca usar pasta do executável
  DBValue := FIniFile.ReadString('Database', 'Database', PADRAO_DATABASE);

  // Se estiver vazio, ou contiver caminho relativo/pasta do executável, usar padrão
  if (DBValue = '') or
     (Pos('WIN32', UpperCase(DBValue)) > 0) or
     (Pos('DEBUG', UpperCase(DBValue)) > 0) or
     (Pos('DELPHI', UpperCase(DBValue)) > 0) or
     (Pos('WINDSURF', UpperCase(DBValue)) > 0) or
     (Pos('BOLETIM RANIERI', UpperCase(DBValue)) > 0) then
    FDatabase.Database := PADRAO_DATABASE
  else
    FDatabase.Database := DBValue;

  FDatabase.UserName := FIniFile.ReadString('Database', 'UserName', 'SYSDBA');
  FDatabase.Password := DecodeBase64(FIniFile.ReadString('Database', 'Password', ''));
  if FDatabase.Password = '' then
    FDatabase.Password := 'masterkey'; // Senha padrão Firebird
  FDatabase.Protocol := FIniFile.ReadString('Database', 'Protocol', 'Local');
  FDatabase.Server := FIniFile.ReadString('Database', 'Server', '');
  FDatabase.Port := FIniFile.ReadInteger('Database', 'Port', 3050);
end;

procedure TConfigManager.LoadApplicationConfig;
begin
  FApplication.AppName := FIniFile.ReadString('Application', 'AppName', 'ClickAcademico');
  FApplication.Version := FIniFile.ReadString('Application', 'Version', '1.0.0');
  FApplication.Theme := FIniFile.ReadString('Application', 'Theme', 'Padrao');
end;

procedure TConfigManager.Reload;
begin
  if not FileExists(FConfigPath) then
  begin
    // Cria arquivo padrão se não existir
    FIniFile.WriteString('Firebase', 'APIKey', 'AIzaSyA2-w2UfVhzN2prqJ2H0kecHYwLTC3XbkU');
    FIniFile.WriteString('Firebase', 'ProjectID', 'clickacademico-342da');
    FIniFile.WriteString('Firebase', 'FirestoreURL', 'https://firestore.googleapis.com/v1');
    
    FIniFile.WriteString('Database', 'DriverID', 'FB');
    FIniFile.WriteString('Database', 'Database', 'C:\ClickAcademico\ClickAcademico.fdb');
    FIniFile.WriteString('Database', 'UserName', 'SYSDBA');
    FIniFile.WriteString('Database', 'Password', 'bWFzdGVya2V5'); // masterkey em Base64
    FIniFile.WriteString('Database', 'Protocol', 'Local');
    FIniFile.WriteString('Database', 'Server', '');
    FIniFile.WriteInteger('Database', 'Port', 3050);
    
    FIniFile.WriteString('Application', 'AppName', 'ClickAcademico');
    FIniFile.WriteString('Application', 'Version', '1.0.0');
    FIniFile.WriteString('Application', 'Theme', 'Padrao');
  end;
  
  LoadFirebaseConfig;
  LoadDatabaseConfig;
  LoadApplicationConfig;
end;

function TConfigManager.GetFirebirdConnectionString: string;
begin
  if FDatabase.Protocol = 'Local' then
    Result := FDatabase.Database
  else
    Result := Format('%s/%d:%s', [FDatabase.Server, FDatabase.Port, FDatabase.Database]);
end;

function TConfigManager.GetFirestoreBaseURL: string;
begin
  Result := Format('%s/projects/%s/databases/(default)/documents',
    [FFirebase.FirestoreURL, FFirebase.ProjectID]);
end;

procedure TConfigManager.ConfigurarFDConnection(AConnection: TObject);
var
  FDConn: TFDConnection;
  CaminhoBanco: string;
begin
  if not (AConnection is TFDConnection) then
    Exit;

  FDConn := TFDConnection(AConnection);

  // Se já estiver conectado, não faz nada
  if FDConn.Connected then
    Exit;

  // Configurar parâmetros do Firebird a partir do INI
  FDConn.Params.DriverID := FDatabase.DriverID;
  FDConn.Params.UserName := FDatabase.UserName;
  FDConn.Params.Password := FDatabase.Password;

  // Usar o caminho configurado no INI
  CaminhoBanco := GetFirebirdConnectionString;
  FDConn.Params.Database := CaminhoBanco;

  // Se estiver vazio, usar o padrão
  if CaminhoBanco = '' then
    FDConn.Params.Database := 'C:\ClickAcademico\ClickAcademico.fdb';
end;

initialization
  ConfigManager := TConfigManager.Create;

finalization
  ConfigManager.Free;

end.
