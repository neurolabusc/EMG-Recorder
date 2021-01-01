unit trigger_form;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, ExtCtrls,mobi_graph;

type
  TTriggerForm = class(TForm)
    Image1: TImage;
    TimeImage: TImage;
    procedure FormResize(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  TriggerForm: TTriggerForm;
  gTriggerOsc: Toscilloscope;
implementation

{$R *.dfm}
uses
  logger;

procedure TTriggerForm.FormResize(Sender: TObject);
begin
    if TriggerForm.Visible then
      gTriggerOsc.Clear;
end;

end.
