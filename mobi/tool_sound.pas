unit tool_sound;
//unit tool_sound;
interface
uses
{$IFDEF Win32}
  Dialogs,Windows, ShellAPI, Messages, MMSystem,
{$ELSE}
  LMessages, LCLType,
{$ENDIF}
math,  Classes, SysUtils, eeg_type;

procedure PlaySoundX;
procedure StopSoundX;
procedure CreateSound (lEEG: TEEG; lChannel, lDurationMS: integer);


implementation

  const
  Mono: Word = $0001;
  
  RiffId: string = 'RIFF';
  WaveId: string = 'WAVE';
  FmtId: string = 'fmt ';
  DataId: string = 'data';
var
     gStream: boolean;
     MS : array [false..true] of tmemorystream;


 procedure PlaySoundX;
 var options:integer;
 begin
   if not assigned (ms[gStream]) then
    exit;
   options:=SND_MEMORY or SND_ASYNC or SND_NODEFAULT or SND_PURGE {or SND_LOOP}; //SND_PURGE
   //options:=options or SND_LOOP;
   //PlaySound(MS[gStream].Memory, 0, options);
   sndPlaySound(MS[gStream].Memory, SND_MEMORY or SND_NODEFAULT or SND_ASYNC);
 end;


procedure StopSoundX;
begin
  PlaySound(nil,0,SND_Purge);
  if assigned (ms[false]) then freeandnil(Ms[false]);
  if assigned (ms[true]) then freeandnil(Ms[true]);

end;

procedure ComputeMinMax(lEEG: TEEG; lChannel, DataCount: integer; var Min,Max: single);
procedure MinMax (lV: single; var lMin,lMax: single);
begin
  if lV < lMin then lMin := lV;
  if lV > lMax then lMax := lV;
end;//nested minmax
var
  i,lStartSample, c: integer;
begin
  min := 0;
  max := 0;
    c := lChannel-1;//arrays indexed from 0
  lStartSample := lEEG.samplesprocessed-DataCount;
  if (DataCount < 1) or (lStartSample < 0) {or (lEEG.samplesprocessed < (lStartSample+DataCount))} then
    exit;
  max := lEEG.filtered[c][lStartSample];
  min :=  lEEG.filtered[c][lStartSample];
  for i := 0 to DataCount-1 do
    minmax(lEEG.filtered[c][lStartSample+i],Min,Max);
end;

procedure CreateSound (lEEG: TEEG; lChannel, lDurationMS: integer);

var
  WaveFormatEx: TWaveFormatEx;
  c,samplerate, i, TempInt, RiffCount, datacount,lStartSample:integer;
  Byteval:byte;
  min,max,
  scale: single;
begin
  if (lEEG.samplesprocessed< 1) or (lChannel > lEEG.numChannels) then
    exit;
  c := lChannel-1;//arrays indexed from 0
  SampleRate := round(lEEG.Channels[c].SampleRate);
  DataCount := (lDurationMS * SampleRate) div 1000; {record "duration" ms at "samplrate" samps/sec}
  lStartSample := lEEG.samplesprocessed-DataCount;
  if (DataCount < 1) or (lStartSample < 0) {or (lEEG.samplesprocessed < (lStartSample+DataCount))} then
    exit;
  //min := lEEG.audiomin;
  //max := lEEG.audioMax;
  if lEEG.audiomin = lEEG.audiomax then
    ComputeMinMax(lEEG,lChannel,{DataCount}SampleRate*2 {2 seconds of data},lEEG.audioMin,lEEG.audioMax);
  scale := lEEG.audiomax-lEEG.audiomin;//range
  if scale <= 0 then
    exit;
  scale := 255/scale;
  with WaveFormatEx do begin
      wFormatTag := WAVE_FORMAT_PCM;
      nChannels := Mono;
      nSamplesPerSec := SampleRate;
      wBitsPerSample := $0008;
      nBlockAlign := (nChannels * wBitsPerSample) div 8;
      nAvgBytesPerSec := nSamplesPerSec * nBlockAlign;
      cbSize := 0;
  end;
  gStream := not gStream;
    MS[gStream] := TMemoryStream.Create;
    {Calculate length of sound data and of file data}
    DataCount := (lDurationMS * SampleRate) div 1000; {record "duration" ms at "samplrate" samps/sec}
    RiffCount := Length(WaveId) + Length(FmtId) + SizeOf(DWORD) +
    SizeOf(TWaveFormatEx) + Length(DataId) + SizeOf(DWORD) + DataCount; // file data
    {write out the wave header}
    MS[gStream] .Write(RiffId[1], 4); // 'RIFF'
    MS[gStream] .Write(RiffCount, SizeOf(DWORD)); // file data size
    MS[gStream] .Write(WaveId[1], Length(WaveId)); // 'WAVE'
    MS[gStream] .Write(FmtId[1], Length(FmtId)); // 'fmt '
    TempInt := SizeOf(TWaveFormatEx);
    MS[gStream] .Write(TempInt, SizeOf(DWORD)); // TWaveFormat data size
    MS[gStream] .Write(WaveFormatEx, SizeOf(TWaveFormatEx)); // WaveFormatEx record
    MS[gStream] .Write(DataId[1], Length(DataId)); // 'data'
    MS[gStream] .Write(DataCount, SizeOf(DWORD)); // sound data size
    {calculate and write out the tone signal} // now the data values
    min := lEEG.audioMin;
    max := lEEG.audioMax;
    for i := 0 to DataCount-1 do begin
      if lEEG.filtered[c][lStartSample+i] < Min then
        ByteVal := 0
      else if lEEG.filtered[c][lStartSample+i] > Max then
        ByteVal := 255
      else
        Byteval := round((lEEG.filtered[c][lStartSample+i]-Min)*scale);
      MS[gStream] .Write(Byteval, SizeOf(Byte));
    end;
    PlaySoundX;
end;


end.

