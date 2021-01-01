unit logger;
{$DEFINE notTEST}
{$DEFINE VMRK}

interface

uses
  mmSystem, Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  ExtCtrls, StdCtrls, mobi_graph, Menus, tool_sound, prefs, userdir,
  OleCtrls, PORTISERIALLib_TLB, format_all, eeg_type, Dialogs,ucopydata,
  ComCtrls {$IFDEF VMRK}, format_vmrk {$ENDIF};

type
  TMobiRecordForm = class(TForm)
    Timer1: TTimer;
    Image1: TImage;
    MainMenu1: TMainMenu;
    File1: TMenuItem;
    Exit1: TMenuItem;
    Edit1: TMenuItem;
    View1: TMenuItem;
    Vertical1: TMenuItem;
    Horizontal1: TMenuItem;
    Acquire1: TMenuItem;
    Audio1: TMenuItem;
    ZoomIn1: TMenuItem;
    Zoomout1: TMenuItem;
    Rescale1: TMenuItem;
    TimeImage: TImage;
    SaveDialog1: TSaveDialog;
    Savedata1: TMenuItem;
    AxSerialSource1: TSerialSource;
    RescaleTimer: TTimer;
    Help1: TMenuItem;
    About1: TMenuItem;
    Events1: TMenuItem;
    Showevent: TMenuItem;
    Verticalscale1: TMenuItem;
    Horizontalscale1: TMenuItem;
    Zoomin2: TMenuItem;
    Zoomout2: TMenuItem;
    Samples1: TMenuItem;
    StatusBar1: TStatusBar;
    procedure LinkWithMobi;
    procedure CheckTrigger (var prev: integer);
    procedure StartRecording (ExternalTrigger: boolean);
    procedure StopRecording (AutoSave: boolean);
    procedure FormShow(Sender: TObject);
    procedure Timer1Timer(Sender: TObject);
    procedure Acquire1Click(Sender: TObject);
    procedure Exit1Click(Sender: TObject);
    procedure FormResize(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure FormDestroy(Sender: TObject);
    procedure Audio1Click(Sender: TObject);
    procedure ZoomIn1Click(Sender: TObject);
    procedure Zoomout1Click(Sender: TObject);
    procedure Vertical1Click(Sender: TObject);
    procedure ApplyPrefs;
    procedure SaveCore (AutoSave: boolean);
    procedure Rescale1Click(Sender: TObject);
    procedure Savedata1Click(Sender: TObject);
    procedure RescaleTimerTimer(Sender: TObject);
    procedure About1Click(Sender: TObject);
    procedure DrawTrigger;
    procedure ShoweventClick(Sender: TObject);
    procedure Verticalscale1Click(Sender: TObject);
    procedure Zoomin2Click(Sender: TObject);
    procedure Zoomout2Click(Sender: TObject);
    procedure Samples1Click(Sender: TObject);
    procedure FormCreate(Sender: TObject);
  private
    { Private declarations }
    procedure WMCopyData(var Msg : TWMCopyData); message WM_COPYDATA;
  public
    { Public declarations }
  end;
var
  MobiRecordForm: TMobiRecordForm;

implementation
uses pref_form, trigger_form;
{$R *.dfm}

var
  gOsc: Toscilloscope;
  gStartTick: DWord;
  gRefreshTrigger: integer;
  {$IFDEF VMRK}gOptVMRK, gwmVMRK: TVMRK;
const
  kMaxVMRK = 65535;
   {$ENDIF}

procedure TMobiRecordForm.ApplyPrefs;
var
  i,nc: integer;
  filt: array of boolean;
begin
  gOSc.BGColor := gPrefs.Background;
  gOSc.LineColor := gPrefs.Trace;
  if gPrefs.MaxChannels > kMaxChannels then
    gPrefs.MaxChannels := kMaxChannels;
  nc := 0;
  for i:=1 to gPrefs.MaxChannels do
    if gPrefs.ChannelEnabled[i] then
      inc(nc);
  SetLength( filt,nc);
  nc := 0;
  for i:=1 to gPrefs.MaxChannels do
    if gPrefs.ChannelEnabled[i] then begin
      filt[nc] := gPrefs.ChannelFiltered[i];
      inc(nc);
    end;
  gOsc := Toscilloscope.Create(gPrefs.SampleRateHz,nc,gPrefs.MaxRecordSec,gPrefs.HighPassHz, Image1,TimeImage,
    gPrefs.Background,gPrefs.Trace,filt,gOsc.horizontalscaleSamples);  //,
  Filt[0] := false; 
  gTriggerOsc := Toscilloscope.Create(gPrefs.SampleRateHz,1,gPrefs.MaxRecordSec,0, TriggerForm.Image1,TriggerForm.TimeImage,gPrefs.Background,gPrefs.Trace,filt,gPrefs.TriggerhorizontalscaleSamples);
  gTriggerOsc.horizontalscaleSamples :=  gPrefs.TriggerhorizontalscaleSamples;
  gTriggerOsc.erasepixels := 0;
  gTriggerOsc.VerticalMinMax (gPrefs.TriggerMin,gPrefs.TriggerMax);
  TriggerForm.Visible := gPrefs.TriggerFormVisible;
  Showevent.checked := gPrefs.TriggerFormVisible;
  Filt := nil;
  nc := 0;
  for i:=1 to gPrefs.MaxChannels do
    if gPrefs.ChannelEnabled[i] then begin
      gOsc.EEG.Channels[nc].Info := 'Ch'+inttostr(i);
      inc(nc);
    end;
end;

procedure TMobiRecordForm.LinkWithMobi;
var
  SerialNumber: integer;
begin
        gPrefs.RealData := false;
       gPrefs.MaxChannels := 8;
       gPrefs.MaxSampleRateHz := 2048;
       if gPrefs.ComPort < 1 then begin
        exit;
       end;
        AxSerialSource1.ComPort := inttostr(gPrefs.ComPort);
        SerialNumber := AxSerialSource1.FrontendSerialNumber;
        If SerialNumber = -1 then begin
            showmessage('Setup your hardware and restart this software: can''t connect to sampling device on ComPort '+inttostr(gPrefs.ComPort));
            Exit;
        End;
        gPrefs.RealData := true;
        gPrefs.MaxChannels := AxSerialSource1.FrontendNrOfChannels;
        gPrefs.MaxSampleRateHz := trunc(AxSerialSource1.SampleRate);
        StatusBar1.Panels[0].Text :='Serial number :'+inttostr(SerialNumber)+'  Channels:'+inttostr(gPrefs.MaxChannels)+' MaxSampleRate:'+floattostr(gPrefs.MaxSampleRateHz);
End;//link with mobi

procedure TMobiRecordForm.FormShow(Sender: TObject);
begin
  MobiRecordForm.DoubleBuffered:=true;
  gOsc := Toscilloscope.Create;
  gTriggerOsc := Toscilloscope.Create;
  IniFile(true, IniName, gPrefs);
 {$IFDEF TEST}
  gPrefs.ComPort := -1;
{$ENDIF}
  if (gPrefs.DefaultFileSaveType < 1) or (gPrefs.DefaultFileSaveType > 2) then  //2 is hard coded - not sure how to easily count number of extentions
    gPrefs.DefaultFileSaveType := 1;
  SaveDialog1.FilterIndex := gPrefs.DefaultFileSaveType;
  LinkWithMobi;
  ApplyPrefs;
end;

{$IFDEF VMRK}
procedure AddVMRK(Cond, Sample: integer; var lVMRK: TVMRK; Opt: boolean);
var
  txt: string;
  secx: single;
  t: integer;
begin
  if (lVMRK.CurrentEvent >= kMaxVMRK) or ((lVMRK.CurrentEvent+1) > Length(lVMRK.events)) then
    exit;
  inc(lVMRK.CurrentEvent);
  t := lVMRK.CurrentEvent-1; //indexed from 0
  lVMRK.Events[t].Typ:= 'Stimulus';
  lVMRK.Events[t].Desc := 'Cond'+inttostr(Cond);
  lVMRK.Events[t].OnsetSamp := Sample;
  lVMRK.Events[t].DurationSamp := 100;
  lVMRK.Events[t].Channel := 0;
  secx :=  Sample/gPrefs.SampleRateHz;
  if t > 0 then
    txt := inttostr(lVMRK.Events[t].OnsetSamp-lVMRK.Events[t-1].OnsetSamp)
  else
    txt := '';
  if not opt then
      MobiRecordForm.StatusBar1.Panels[1].Text := 'Windows Trigger '+floattostr(lVMRK.CurrentEvent)+ ' @ '+FloatToStrF(Secx, ffGeneral, 4, 1)+'s '+txt
  else
    MobiRecordForm.StatusBar1.Panels[2].Text := 'Optical Trigger '+floattostr(lVMRK.CurrentEvent)+ ' @ '+FloatToStrF(Secx, ffGeneral, 4, 1)+'s';
end;
{$ENDIF}


procedure CheckTriggerX (var prev: integer);
//if a trigger signal is detected, data is shifted so that trigger occurred at first sample
//e.g. initially samplesprocessed=0, 100 incoming, check first 100 = 0..99
var
  s,c,i: integer;
begin
  c := abs(gPrefs.TriggerChannelx);
  if (c < 0) or (gOsc.E.samplesprocessed < prev) or (prev < 0)or  (c >= gOSC.EEG.numChannels) then
    exit;
  s := gOSC.EEG.samplesprocessed;
  if s = 0 then s := 1;
  for i :=   s downto  prev  do  //-1: indexed from 0
    if (gOSC.EEG.samples[c][i] >= 1) and (gOSC.EEG.samples[c][i-1] < 1) then
      gRefreshTrigger := i+ gPrefs.TriggerSamples;
  {$IFDEF VMRK}
  for i :=   prev to s do  //-1: indexed from 0
    if (gOSC.EEG.samples[c][i] >= 1) and (gOSC.EEG.samples[c][i-1] < 1) then
        AddVMRK(1,i,goptVMRK,true)
  {$ENDIF}

end;//xxx

procedure TMobiRecordForm.CheckTrigger(var prev: integer);
//if a trigger signal is detected, data is shifted so that trigger occurred at first sample
//e.g. initially samplesprocessed=0, 100 incoming, check first 100 = 0..99
label 666;
var
  c,i,remaining,trigger: integer;
begin
  if gPrefs.TriggerDetected then
    exit;
  trigger := 0;
  c := gPrefs.TriggerChannelx;
  if (c < 0) or (gOsc.E.samplesprocessed < prev) or (prev < 0)or  (c >= gOSC.EEG.numChannels) then
    exit;
  for i := prev to gOSC.EEG.samplesprocessed-1  do begin //-1: indexed from 0
    if gOSC.EEG.samples[c][i] >= 1 then begin
      trigger := i;
      goto 666;
    end;
  end;
  exit;
666:
  if trigger = 0 then
    exit;
  remaining := gOSC.EEG.samplesprocessed-trigger;
  //remaining := 0;
  if remaining > 1 then begin
    for c := 0 to gOSC.EEG.numChannels-1 do
      for i := 0 to remaining do begin //-1: indexed from 0
        gOSC.EEG.samples[c][i] := gOSC.EEG.samples[c][i+trigger];
        gOSC.EEG.filtered[c][i] := gOSC.EEG.filtered[c][i+trigger];
    end; //each channel
  end;  //remaining > 0
  gOsc.EEG.samplesprocessed := remaining;
  gOSC.EEG.Time := now;
  gPrefs.TriggerDetected := true;
  StatusBar1.Panels[0].Text  := 'Trigger detected';
    gStartTick := {GetTickCount}TimeGetTime- round(remaining/gPrefs.SampleRateHz * 1000);
  gOSC.AddTimeLine;
end;

function PeakToPeak (lEEG: TEEG; lChannel, lStartMS,lEndMS: integer): single;
var
  i,lStart,lEnd,lSamples: integer;
  lMin,lMax: single;
begin
  result := 0;
  lSamples :=  NumSamples(lEEG,lChannel);
  lStart := round(lStartMS* lEEG.Channels[lChannel].SampleRate/1000);
  lEnd := round(lEndMS* lEEG.Channels[lChannel].SampleRate/1000);
  if lEnd < lStart then
    Showmessage('Error in calling peak-to-peak');
  if (lSamples < 1) or (lStart= lEnd) or (lEnd >= lSamples) or (lStart < 0) then
    exit;
  lMin :=  gTriggerOSC.EEG.samples[lChannel][lStart];
  for i := lStart to lEnd do
    if gTriggerOSC.EEG.samples[lChannel][i] < lMin then
      lMin :=  gTriggerOSC.EEG.samples[lChannel][i];
  lMax :=  gTriggerOSC.EEG.samples[lChannel][lStart];
  for i := lStart to lEnd do
    if gTriggerOSC.EEG.samples[lChannel][i] > lMax then
      lMax :=  gTriggerOSC.EEG.samples[lChannel][i];
  result := lMax-lMin;
end;

procedure TMobiRecordForm.DrawTrigger;
var
  c,s,i : integer;
  f: single;
begin
  if (gOsc.EEG.samplesprocessed < (gRefreshTrigger-gPrefs.TriggerSamples)) or  (gPrefs.TriggerSamples < 1) then
    exit;
  c := 0;
  s := gRefreshTrigger - gPrefs.TriggerSamples;
  TriggerForm.Caption := 'Last pulse '+floattostr(gRefreshTrigger/ gPrefs.SampleRateHz)+'sec';
  gRefreshTrigger := MaxInt;
  for i := 0 to gPrefs.TriggerSamples-1 do
    gTriggerOSC.EEG.samples[c][i] := gOSC.EEG.filtered[c][s+i];
  gTriggerOsc.EEG.samplesprocessed := gPrefs.TriggerSamples;

  f := round(PeakToPeak(gTriggerOsc.EEG,0,gPrefs.TriggerStartPeakToPeak,gPrefs.TriggerEndPeakToPeak)/1000);
  gTriggerOsc.EEG.samplesprocessed := 0;
  gTriggerOSC.Clear;
  gTriggerOSC.BigText(Floattostr( f));
  gTriggerOSC.AddSamples(gPrefs.TriggerSamples-1);
end;

//Next 2 procedures only used if NOT gPrefs.RealData
var
  gTSamples: integer;
  gTFreqHz,gOpticalFreqHz,gOpticalPhase: integer;
procedure TestStartAcq(var pFreq: Single; out pErrorResult: Integer);
begin
    gTSamples := 0;
    gTFreqHz:= round(pFreq);
    gOpticalFreqHz := gTFreqHz * 5;
    gOpticalPhase := round(gTFreqHz * 2.5);
    pErrorResult :=  S_OK;
end;

procedure TestGetSampleRecordAsVariant(out pReceivedPeriods: Integer; out V: OleVariant);
var
  c,i,samp: integer;
  s: single;
begin
 samp :=  round(( (TimeGetTime-gStartTick)/1000) * gTFreqHz);
  pReceivedPeriods := 0;
  if samp <= gTSamples then
    exit;//no new samples
  pReceivedPeriods := samp - gTSamples;
  V := VarArrayCreate([0, gPrefs.MaxChannels-1, 0, pReceivedPeriods-1], varSingle );
  for c := 0 to gPrefs.MaxChannels-1 do
    for i := 0 to pReceivedPeriods-1 do begin
      case c of
        6: begin
            if ((gTSamples+i-gOpticalPhase) mod gOpticalFreqHz) = 0 then
              s := 1
            else
              s := 0;
          end;
        7: s := (gTSamples+i) mod 62;
        else begin
          s :=50000*sin ((gTSamples+i) * 2.0 * pi /gPrefs.F1)
        end;
      end;
      V[c,i] := s;

    end;
  gTSamples := samp;
end;

procedure TMobiRecordForm.Timer1Timer(Sender: TObject);
var
  mostrecentsample,ReceivedPeriods,c,i,o,prev: integer;
    V: OleVariant;
begin
  if not gPrefs.RealData then
     TestGetSampleRecordAsVariant(ReceivedPeriods,V)
  else
    AxSerialSource1.GetSampleRecordAsVariant(ReceivedPeriods,V);
    if ReceivedPeriods < 1 then
      exit;
    o := 0;
    prev := gOsc.E.samplesprocessed;
    for c := 0 to  gPrefs.MaxChannels-1 do begin
      if gPrefs.ChannelEnabled[c+1] then begin
        for i := 0 to ReceivedPeriods-1 do
          gOsc.E.samples[o][i+prev] :=  V[c,i];
        inc(o);
      end;//channel enabled...
    end; //for each channel
    mostrecentsample := gOsc.E.samplesprocessed + ReceivedPeriods;
    gOsc.AddSamples(mostrecentsample);
    if (gRefreshTrigger < MaxInt) and  (gRefreshTrigger < gOsc.EEG.samplesprocessed) then
      DrawTrigger;
    CheckTriggerX(prev);

    if not gPrefs.TriggerDetected then
      CheckTrigger(prev);
    if  Audio1.Checked then
      CreateSound (gOsc.E, gPrefs.AudioChannel, Timer1.interval);
end;

{$IFDEF VMRK}
function ReconcileVMRK(var lOptVMRK, lwmVMRK: TVMRK): boolean;
//Windows messaging accurately records condition, but not onset time
// optical trigger accurately records onset time, but not condition
// This function updates WM-based VMRK file to use optical timing
var
  i,nopt,nwm: integer;
begin
  result := false;
  nwm :=lwmVMRK.CurrentEvent;
  nopt := lwmVMRK.CurrentEvent;
  if (nwm < 1) or (nopt < 1) then
    exit;
  if nopt <> nwm then
    Showmessage('Counted  '+ inttostr(nWM)+ ' Windows events, and '+inttostr(nopt)+' optical events');
  if nopt > nwm then begin
    nwm := nopt;
    setlength(lwmVMRK.Events,nwm);
  end;
  for i := 0 to nwm - 1 do
    lwmVMRK.Events[i].OnsetSamp := loptVMRK.Events[i].OnsetSamp;
  result := true;
end;
{$ENDIF}

procedure TMobiRecordForm.SaveCore (AutoSave: boolean);
begin
  if MaxNumSamples(gOsc.E) < 1 then begin
    Showmessage('You need to load data before you can save.');
    exit;
  end;
  gPrefs.UnsavedData := false;
  if AutoSave then
    SaveDialog1.FileName :=  extractfiledir(paramstr(0))+'\'+ (FormatDateTime('yyyymmdd_hhnnss', (gOsc.E.Time {now})))+'.vhdr'
  else begin
    if not SaveDialog1.Execute then
      exit;
  end;
  WriteEEG(SaveDialog1.FileName,gOsc.EEG);
  StatusBar1.Panels[0].Text  := 'saved data as '+SaveDialog1.FileName;
  {$IFDEF VMRK}
  //first save raw files, with windows messaging time stamps...
  if gwmVMRK.CurrentEvent > 0 then begin
      StatusBar1.Panels[1].Text := 'Windows events : '+inttostr(gwmVMRK.CurrentEvent);
      setlength(gwmVMRK.Events,gwmVMRK.CurrentEvent);
      WriteVMRK(changefileext(SaveDialog1.FileName,'wm.vmrk'),gwmVMRK);
  end;
  if goptVMRK.CurrentEvent > 0 then begin
      StatusBar1.Panels[2].Text := 'Optical events : '+inttostr(goptVMRK.CurrentEvent);
      setlength(goptVMRK.Events,goptVMRK.CurrentEvent);
      WriteVMRK(changefileext(SaveDialog1.FileName,'opt.vmrk'),goptVMRK);
  end;
  if ReconcileVMRK(gOptVMRK, gwmVMRK) then
      WriteVMRK(changefileext(SaveDialog1.FileName,'.vmrk'),gwmVMRK);
  {$ENDIF}
end;

procedure TMobiRecordForm.StopRecording (AutoSave: boolean);
var
  error: integer;
begin
  Timer1.Enabled := false;
  gPrefs.TriggerFormVisible := Showevent.checked;
  if gPrefs.RealData then
    AxSerialSource1.StopAcq(error);
  if (gPrefs.UnsavedData) then
      SaveCore (AutoSave);
    exit;
  Acquire1.Checked := false;
  StatusBar1.Panels[0].Text  := 'Data logging started '+FormatDateTime('yyyymmdd_hhnnss', (now));
end;

procedure TMobiRecordForm.StartRecording (ExternalTrigger: boolean);
var
  error: integer;
  v: single;
begin
  Timer1.Enabled := false;
  gPrefs.TriggerFormVisible := Showevent.checked;
  ApplyPrefs;
  gRefreshTrigger := maxint;
    gOSC.EEG.Time := now;
    v := gPrefs.SampleRateHz;
    if  not gPrefs.RealData then
      TestStartAcq(v, Error)
    else
      AxSerialSource1.StartAcq(v, Error);
    gStartTick := timeGetTime;
    if Error = S_FALSE  then begin
        showmessage('Unable to connect to device - is it in sleep mode?');
        exit;
    end;
    Acquire1.Checked := true;
    gPrefs.UnsavedData := true;
    {$IFDEF VMRK}
    CreateEmptyVMRK(gwmVMRK, kMaxVMRK);
    CreateEmptyVMRK(gOptVMRK, kMaxVMRK);
    {$ENDIF}
    if (ExternalTrigger) or (gPrefs.TriggerChannelx < 0) then
      gPrefs.TriggerDetected := true
    else
      gPrefs.TriggerDetected := false;
    if not gPrefs.TriggerDetected then
      StatusBar1.Panels[0].Text  := 'Data logging started '+FormatDateTime('yyyymmdd_hhnnss', (now))+' waiting for triggers'
    else
      StatusBar1.Panels[0].Text  := 'Data logging started '+FormatDateTime('yyyymmdd_hhnnss', (now));
    RescaleTimer.tag := 0;
    RescaleTimer.enabled := true;
    gOsc.EEG.samplesprocessed := 0;
    Timer1.Enabled := true;
end;

procedure TMobiRecordForm.Acquire1Click(Sender: TObject);
begin
  if (not Acquire1.Checked) then
    StopRecording(false)
  else
    StartRecording (false);
end;

procedure TMobiRecordForm.WMCopyData(var Msg: TWMCopyData);
var
  T,I: integer;
begin
    T := round( ((timeGetTime-gStartTick)/1000) *(gPrefs.SampleRateHz {+9})) ;//KLUDGE - our Mobi records @ 2057hz when 2048 is requested...
     I := ReceiveDataDigit(Msg,T {Resp});
     if I = kStartRecording then
      StartRecording (true)
     else if I = kStopRecording then
      StopRecording (true)
     {$IFDEF VMRK}
     else if I > 0 then
      AddVMRK(I,T,gwmVMRK,false)
      {$ENDIF};
end;


procedure TMobiRecordForm.Exit1Click(Sender: TObject);
begin
  Close;
end;

procedure TMobiRecordForm.FormResize(Sender: TObject);
begin
  if MobiRecordForm.Visible then //a 'FormResize' event generated after FormDestroy!
    gOsc.Clear;
end;

procedure TMobiRecordForm.FormClose(Sender: TObject; var Action: TCloseAction);
var
  lError: integer;
begin
  Timer1.Enabled := false;

  if gPrefs.RealData then begin
    AxSerialSource1.StopAcq(lError);
    AxSerialSource1.ReleaseSerialPort(lError);
  end;

   if gPRefs.UnsavedData then
    SaveCore(false);
   gPrefs.TriggerFormVisible := Showevent.checked;
  IniFile(false, IniName, gPrefs);
end;

procedure TMobiRecordForm.FormDestroy(Sender: TObject);
begin
  gOsc.Destroy;
  gTriggerOsc.Destroy;
  timeEndPeriod(1);
end;

procedure TMobiRecordForm.Audio1Click(Sender: TObject);
begin
  StopSoundX;
end;

procedure TMobiRecordForm.ZoomIn1Click(Sender: TObject);
begin
  gOsc.horizontalscaleSamples := gOsc.horizontalscaleSamples / 2;
  if gOsc.horizontalscaleSamples > 1 then
    gOsc.horizontalscaleSamples := round(gOsc.horizontalscaleSamples);
  gOsc.AddTimeLine;
end;

procedure TMobiRecordForm.Zoomout1Click(Sender: TObject);
begin
    gOsc.horizontalscaleSamples := gOsc.horizontalscaleSamples * 2;
  gOsc.AddTimeLine;
end;

procedure TMobiRecordForm.Vertical1Click(Sender: TObject);
begin
  if ( Acquire1.Checked) then
    Acquire1.Click;
  PrefsForm.Showmodal;
  gOsc.AddScaleLines;
end;

procedure TMobiRecordForm.Rescale1Click(Sender: TObject);
begin
  gOsc.AutoScale(gPrefs.SampleRateHz);//autoscale based on last second worth of data
  gOsc.AddScaleLines;
  gOsc.EEG.audiomax := gOsc.EEG.audiomin;
end;

procedure TMobiRecordForm.Savedata1Click(Sender: TObject);
begin
  if ( Acquire1.Checked) then
    Acquire1.Click
  else
    SaveCore(false);
end;

procedure TMobiRecordForm.RescaleTimerTimer(Sender: TObject);
begin
  Rescale1Click(nil);
  gOsc.EEG.audiomax := gOsc.EEG.audiomin; //for audio rescale
  RescaleTimer.tag := RescaleTimer.tag + 1;
  if RescaleTimer.tag > 2 then
    RescaleTimer.enabled := false;
end;

procedure TMobiRecordForm.About1Click(Sender: TObject);
begin
  showmessage('EMG recorder :: Chris Rorden :: August 2010');
end;

procedure TMobiRecordForm.ShoweventClick(Sender: TObject);
begin
     TriggerForm.Visible :=  Showevent.checked;
end;

function GetFloat (lCaption: string; lDefault: single): single;
var
  lS: string;
begin
  result := lDefault;
  lS := floattostr(lDefault);
  InputQuery('Value required', lCaption, lS);
  if lS = '' then
        exit;
  result := strtofloat(lS);
end;

function GetInt (lCaption: string; lDefault: integer): integer;

begin
  result := round(GetFloat(lCaption,lDefault));
end;
procedure TMobiRecordForm.Verticalscale1Click(Sender: TObject);
begin
  //gOsc.AutoScale(gPrefs.SampleRateHz);//autoscale based on last second worth of data
  gPrefs.TriggerMin := GetFloat ('Minimum vertical scale for events',gPrefs.TriggerMin);
  gPrefs.TriggerMax := GetFloat ('Maximum vertical scale for events',gPrefs.TriggerMax);
  gTriggerOsc.VerticalMinMax (gPrefs.TriggerMin,gPrefs.TriggerMax);
end;

procedure TMobiRecordForm.Zoomin2Click(Sender: TObject);
begin
  gPrefs.TriggerhorizontalscaleSamples := gPrefs.TriggerhorizontalscaleSamples / 2;
  if gPrefs.TriggerhorizontalscaleSamples > 1 then
    gPrefs.TriggerhorizontalscaleSamples := round(gPrefs.TriggerhorizontalscaleSamples);
  gTriggerOsc.horizontalscaleSamples :=  gPrefs.TriggerhorizontalscaleSamples;
  gTriggerOsc.AddTimeLine;
end;

procedure TMobiRecordForm.Zoomout2Click(Sender: TObject);
begin
  gPrefs.TriggerhorizontalscaleSamples := gPrefs.TriggerhorizontalscaleSamples * 2;
  gTriggerOsc.horizontalscaleSamples :=  gPrefs.TriggerhorizontalscaleSamples;
  gTriggerOsc.AddTimeLine;
end;

procedure TMobiRecordForm.Samples1Click(Sender: TObject);
begin
  gPrefs.TriggerSamples := GetInt ('Number of samples displayed after each event',gPrefs.TriggerSamples);
  gPrefs.TriggerStartPeakToPeak := GetInt ('Beginning of peak-to-peak estimate (ms)',gPrefs.TriggerStartPeakToPeak);
  gPrefs.TriggerEndPeakToPeak := GetInt ('End of peak-to-peak estimate (ms)',gPrefs.TriggerEndPeakToPeak);
end;

procedure TMobiRecordForm.FormCreate(Sender: TObject);
begin
DecimalSeparator := '.';
  timeBeginPeriod(1)
end;

end.
