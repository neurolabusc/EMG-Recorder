unit pref_form;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, Spin, prefs,eeg_type;

type



  TPrefsForm = class(TForm)
    HighPassHzEdit: TSpinEdit;
    Label1: TLabel;
    MaxRecordSecEdit: TSpinEdit;
    Label2: TLabel;
    SampleRateHzEdit: TSpinEdit;
    Label3: TLabel;
    Label4: TLabel;
    CancelBtn: TButton;
    OKBtn: TButton;
    TriggerLabel: TLabel;
    TriggerChannelEdit: TSpinEdit;
    procedure FormShow(Sender: TObject);
    procedure OKBtnClick(Sender: TObject);
    procedure TriggerChannelEditChange(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  PrefsForm: TPrefsForm;

implementation
uses logger;
{$R *.dfm}
 var
  FiltArr,EnArr: Array of TCheckBox;

procedure TPrefsForm.FormShow(Sender: TObject);
const
  kTop = 124;
var
  I : integer;
begin
  SampleRateHzEdit.MaxValue := gPrefs.MaxSampleRateHz;
  if gPrefs.MaxChannels > kMaxChannels then
    gPrefs.MaxChannels := kMaxChannels;
  SetLength(EnArr, gPrefs.MaxChannels);
  SetLength(FiltArr, gPrefs.MaxChannels);
  for i:=0 to gPrefs.MaxChannels-1 do begin
    EnArr[i]:=TCheckBox.Create(Self);
    EnArr[i].parent:=Self;
    EnArr[i].Left := 12;
    EnArr[i].Top := kTop+(i *20);
    EnArr[i].caption := '';
    EnArr[i].checked := gPrefs.ChannelEnabled[i+1];
  end;
    for i:=0 to gPrefs.MaxChannels-1 do begin
    FiltArr[i]:=TCheckBox.Create(Self);
    FiltArr[i].parent:=Self;
    FiltArr[i].Left := 64;
    FiltArr[i].Top := kTop+(i *20);
    FiltArr[i].caption := 'Ch'+inttostr(i+1);
    FiltArr[i].checked := gPrefs.ChannelFiltered[i+1];
  end;
  OKbtn.Top := (gPrefs.MaxChannels*20)+kTop;
  Cancelbtn.Top := (gPrefs.MaxChannels*20)+kTop;
  PrefsForm.Height := (gPrefs.MaxChannels*20)+kTop+64;
  HighPassHzEdit.value := gPrefs.HighPassHz;
  SampleRateHzEdit.value := gPrefs.SampleRateHz;
  MaxRecordSecEdit.value := gPrefs.MaxRecordSec;
  TriggerChannelEdit.Value := gPrefs.TriggerChannelx;
  TriggerChannelEditChange(nil);

end;

function ChannelsActive: integer;
var
  i,len: integer;
begin
  result := 0;
  len := length(EnArr);
  if len < 1 then
    exit;
  for i := 0 to len-1 do
    if EnArr[i].checked then
      inc(result);
end;

function ChannelLabel (Channel: integer {indexed from 0}): string;
var
  i,active, len: integer;
begin
  result := 'Unused';
  len := length(EnArr);
  if (Channel < 0) or (Channel >= len) then
    exit;
  active := 0;
  for i := 0 to len-1 do begin
    if EnArr[i].checked then begin
      if active = Channel then begin
          result := 'Ch'+inttostr(i+1);
          exit;
      end;
      inc(active);
    end; //active
  end;
end;


procedure TPrefsForm.OKBtnClick(Sender: TObject);
var
  i: integer;
begin
  gPrefs.HighPassHz := HighPassHzEdit.value;
  gPrefs.SampleRateHz := SampleRateHzEdit.value;
  gPrefs.MaxRecordSec := MaxRecordSecEdit.value;
  gPrefs.TriggerChannelx := TriggerChannelEdit.value;

  if gPrefs.MaxChannels > kMaxChannels then
    gPrefs.MaxChannels := kMaxChannels;
  for i:=0 to gPrefs.MaxChannels-1 do
    gPrefs.ChannelEnabled[i+1] := EnArr[i].checked;
  for i:=0 to gPrefs.MaxChannels-1 do
    gPrefs.ChannelFiltered[i+1] := FiltArr[i].checked;
  MobiRecordForm.ApplyPrefs;
  
end;

procedure TPrefsForm.TriggerChannelEditChange(Sender: TObject);
begin
  if gPrefs.MaxChannels < 1 then
    exit;
  if TriggerChannelEdit.value >= ChannelsActive then
    TriggerChannelEdit.value := TriggerChannelEdit.value - 1;
  if TriggerChannelEdit.value < -1 then
    TriggerChannelEdit.value :=  - 1;

    TriggerLabel.caption := 'Trigger channel ['+ChannelLabel(TriggerChannelEdit.value)+']';
end;

end.
