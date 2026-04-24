program exportador;

uses
  Vcl.Forms,
  UReplicator in 'UReplicator.pas' {FormReplicator};

{$R *.res}

begin
  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  Application.CreateForm(TFormReplicator, FormReplicator);
  Application.Run;
end.
