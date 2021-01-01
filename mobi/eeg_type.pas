unit eeg_type;

interface
uses filter_rbj, sysutils;

const
 kMaxChannels = 64;
type
	SingleRA0 = array [0..0] of Single;
	Singlep0 = ^SingleRA0;
  TChannel = record
      previ: integer;
      SignalLead: boolean;
      Info,UnitType: string;
      DisplayMin,DisplayMax,DisplayScale,SampleRate : double;
      HighPass:  TRbjEqFilter;
   end;
  TEEG = record
      maxsamples,numChannels,samplesprocessed: integer;
      audiomin,audiomax: single;
      Time: TDateTime;
      Channels: array [0..kMaxChannels] of TChannel;
      samples,filtered: array [0..kMaxChannels] of Singlep0;
   end;
   procedure CreateEEG(var lEEG: TEEG; channels,nSamples: integer; SampleHz: double);
   function NumChannels(lEEG: TEEG): integer;
   function NumSamples(lEEG: TEEG; lChannel: integer): integer;
   function MaxNumSamples(lEEG: TEEG): integer;
   function NumSamplesZeroIfVariable(lEEG: TEEG): integer;
   function SampleRateZeroIfVariable(lEEG: TEEG): double;

implementation

function NumChannels(lEEG: TEEG): integer;
begin
  result := lEEG.numChannels;
end;

function NumSamples(lEEG: TEEG; lChannel: integer): integer;
begin
  result := lEEG.samplesprocessed;
end;

function MaxNumSamples(lEEG: TEEG): integer;
begin
  result := lEEG.samplesprocessed;
end;

function NumSamplesZeroIfVariable(lEEG: TEEG): integer;
begin
  result := lEEG.samplesprocessed;
end;

function SampleRateZeroIfVariable(lEEG: TEEG): double;
var
  r: double;
  c: integer;
begin
  result := 0;
  if (NumChannels(lEEG) < 1) or (MaxNumSamples(lEEG)<1) then
    exit;
  r := lEEG.Channels[0].SampleRate;
  for c := 0 to  NumChannels(lEEG)-1 do
    if r <> lEEG.Channels[0].SampleRate then
      exit;
  result := round(r);
end;

procedure CreateEEG(var lEEG: TEEG; channels,nSamples: integer; SampleHz: double);
var
  i: integer;
begin

  if channels > kMaxChannels then
    lEEG.numChannels := kMaxChannels
  else
    lEEG.numChannels := channels;;
  //channelheight := pixelheightperchannelX;
  if channels > 0 then begin
    lEEG.maxsamples := nSamples;
    for i := 0 to lEEG.numChannels-1 do begin
      getmem(lEEG.Samples[i], lEEG.maxsamples*sizeof(single));
      getmem(lEEG.Filtered[i], lEEG.maxsamples*sizeof(single));
      lEEG.Channels[i].SignalLead := true;
      lEEG.Channels[i].Info := 'ch'+inttostr(i+1);
      lEEG.Channels[i].UnitType := 'uV';
      lEEG.Channels[i].SampleRate := SampleHz ;
      lEEG.Channels[i].previ := 0;
      //lEEG.Channels[i].HighPass := TRbjEqFilter.Create(HighPassHz,0);
      //lEEG.Channels[i].HighPass.Freq := 0;
        //lEEG.Channels[i].displayscale := channelheight / 2;
    end;
   end;

end;


end.
