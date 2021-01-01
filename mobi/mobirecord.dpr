program mobirecord;

uses
  Forms,
  logger in 'logger.pas' {MobiRecordForm},
  mobi_graph in 'mobi_graph.pas',
  tool_sound in 'tool_sound.pas',
  pref_form in 'pref_form.pas' {PrefsForm},
  eeg_type in 'eeg_type.pas',
  trigger_form in 'trigger_form.pas' {TriggerForm};

{$R *.res}

begin
  Application.Initialize;
  Application.CreateForm(TMobiRecordForm, MobiRecordForm);
  Application.CreateForm(TPrefsForm, PrefsForm);
  Application.CreateForm(TTriggerForm, TriggerForm);
  Application.Run;
end.
