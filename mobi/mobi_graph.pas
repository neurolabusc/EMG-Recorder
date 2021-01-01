unit mobi_graph;

interface
uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, ExtCtrls, StdCtrls, filter_rbj, math, eeg_type;
type
Toscilloscope = Class(TObject)  // This is an actual class definition :
    // Internal class field definitions - only accessible in this unit
    private

      img,timeimg: TImage;
      bgC,lineC: TColor;
      horizontalscale  : single;
       channelheight, erase,hsample,hmin,hmax: integer;
      function pixelheightperchannelX: integer;
      procedure AddSample(sample,pixelstep: integer) ;
      procedure AutoScaleX(windowsamples,finalsample: integer);
      procedure UpdateDisplayScale;
    protected
      //none
    public
    EEG: TEEG;
    procedure AddTimeLine;
    //function VPixels (lValue: single): integer;

    procedure AddScaleLines;
      constructor Clear;
      procedure AddSamples(mostrecentsample: integer) ;
      procedure AutoScale(windowsamples: integer); overload; //scales based on the most recent samples...
      procedure VerticalMinMax (  min,max: single);
      procedure BigText(lString: string);
      constructor Create;               overload;
//      samplespergraphpoint,
      constructor Create(samplespersec,channels, seconds,  HighPassHz: integer; var lImage,lTimeImage: TImage; bg,trace: TColor;  lChannelFilter: array of boolean; samplespergraphpoint: single); overload;
      Destructor  Destroy; override;
    published
      property BGColor : TColor
        read   bgC write bgC;
      property LineColor : TColor
        read   lineC write lineC;
     // property HighPassHz : single
    //    read   highpass write highpass;
      property horizontalscaleSamples : single
        read   horizontalscale write horizontalscale;
      property pixelheightperchannel : integer
        read   channelheight write channelheight;
      property channelcount : integer
        read   EEG.numChannels write EEG.numChannels;
      property erasepixels : integer
        read   erase write erase;
      property E : TEEG
        read   EEG write EEG;
  end;

implementation

//uses logger;
const
kVPct = 0.25;


procedure TOscilloscope.AutoScaleX(windowsamples,finalsample: integer);
var
  c,start,i: integer;
  min,max: single;
begin
  if (finalsample > EEG.maxsamples) or (EEG.numChannels < 1) or (finalsample < 1) then exit;
  start := finalsample-abs(windowsamples);
  if start < 1 then
    start := 0;//
  for c := 0 to EEG.numChannels-1 do begin
      min :=  EEG.filtered[c][start];
      max := min;
      for i := start to finalsample do begin
        if EEG.filtered[c][i] < min then
          min := EEG.filtered[c][i];
        if EEG.filtered[c][i] > max then
          max := EEG.filtered[c][i];
      end;
      EEG.Channels[c].DisplayMin  := Min;
      EEG.Channels[c].DisplayMax  := Max;
  end;//for each sample
  UpdateDisplayscale;
  AddScaleLines;
end; //AutoScale

procedure TOscilloscope.AutoScale(windowsamples: integer);
begin
  AutoScaleX(windowsamples,EEG.samplesprocessed-1);
end; //AutoScale

procedure TOscilloscope.VerticalMinMax (  min,max: single);
var
  c: integer;
begin
  if (EEG.numChannels < 1) then exit;
  for c := 0 to EEG.numChannels-1 do begin
    EEG.Channels[c].DisplayMin  := Min;
      EEG.Channels[c].DisplayMax  := Max;
  end;//for each sample
  UpdateDisplayscale;
  Clear;
  AddScaleLines;
end; //AutoScale

function ReqDecimals (lV: double): integer;
//e.g. values >1 require no decimals, 0.999...0.1 require 1, etc...
var
  lF: double;
begin
  result := 0;
  if (lV = 0) or (lV > 1) then
       exit;
  lF := lV;
  repeat
    inc(result);
    lF := lF * 10;
  until (lF >= 1) or (result >= 10);
end;

procedure SetDimension(lImage: TImage; lPGHt,lPGWid {,lBits}:integer);
var
   Bmp     : TBitmap;
begin
     if (lImage.Picture.Height = lPGHt) and (lImage.Picture.Width = lPGWid) then
      exit;
     Bmp := TBitmap.Create;
     Bmp.Height := lPGHt;
     Bmp.Width  := lPGwid;
     lImage.Picture.Assign(Bmp);
     lImage.width := round(Bmp.Width);
     lImage.height := round(Bmp.Height);
     Bmp.Free;
end;

procedure TOscilloscope.BigText ( lString: string);
begin
  Img.Canvas.Font.Size := 36;
  Img.Canvas.Font.Color := linec;
  Img.Canvas.TextOut(Img.width-Img.Canvas.TextWidth(lString)-2,0,lString);
end; //AutoScale



procedure TOscilloscope.AddTimeLine;
var
  h,ns,ldec : integer;
  s: string;
  sec,nsec,stepsize,secperpixel: single;
begin
  if (EEG.numChannels < 1) or (EEG.Channels[0].SampleRate < 0.01) then exit;
  ns := hmax-hmin;
  if (horizontalscaleSamples=0) or (ns = 0) then
    exit;
  SetDimension(Timeimg,Timeimg.Height,Timeimg.Width);
  secperpixel := EEG.Channels[0].SampleRate/horizontalscaleSamples;
  nsec := (horizontalscaleSamples*ns) /EEG.Channels[0].SampleRate;
  if nsec >= 20 then
    stepsize := 10
  else if nsec >= 2 then
    stepsize := 1
  else if nsec >= 0.2 then
    stepsize := 0.1
  else if nsec >= 0.02 then
    stepsize := 0.01
  else if nsec >= 0.002 then
    stepsize := 0.001
  else if nsec >= 0.0002 then
    stepsize := 0.0001
  else
    exit;
  (*if nsec >= 2 then
    ldec := 0
  else if nsec >= 0.2 then
    ldec := 1
  else
    ldec := 2;*)
  lDec := ReqDecimals(nsec/2);
  //form1.Caption := floattostr(nsec);

  //Img.Canvas.FillRect(Rect(0,0,img.width,vtitle));//remove titlebar
  Img.Canvas.brush.Color := bgC;
  Img.Canvas.FillRect(Rect(hmin,0,img.width,img.Height));//remove previous trace
  TimeImg.Canvas.brush.Color := bgC;
  TimeImg.Canvas.FillRect(Rect(0,0,TimeImg.width,TimeImg.Height));//remove titlebar
  TimeImg.Canvas.Pen.Color := lineC;
  TimeImg.Canvas.Font.Name := 'Arial';
  TimeImg.Canvas.Font.Size := 10;
  TimeImg.Canvas.Font.Color := linec;
  sec := 0;
  repeat
    h := hmin+round(sec*secperpixel);
    s := FloatToStrF(sec, ffFixed,7,ldec);
    TimeImg.Canvas.moveto(h,14);
    TimeImg.Canvas.lineto(h,18);
    TimeImg.Canvas.TextOut(h-(Img.Canvas.TextWidth(S) div 2),0,s);
    sec := sec+stepsize;
    //form1.Caption := 'zz'+floattostr(sec)+'  '+floattostr(nsec*secperpixel);
  until sec > nsec;
      hsample := hmin;
end;        

function Rounded (lV: double; var lDec: integer): double;
//e.g. 0.012 will return 0.01 with 2 decimals place precision
var
  lValue: double;
begin
  lValue :=abs(lV);
  result := round(lV);
  lDec := ReqDecimals(lValue);
  if lDec < 1 then
    exit;
  result := round(lV*Power(10,lDec));
  result := result/Power(10,lDec);
end;


procedure TOscilloscope.AddScaleLines;
var
  lopix,hipix,th,c,lDecLo,lDecHi,o : integer;
  lo,hi,range: single;
  s: string;
begin
  if (EEG.numChannels < 1) or (EEG.Channels[0].SampleRate < 0.01) then exit;
  Img.Canvas.brush.Color := bgC;
  Img.Canvas.FillRect(Rect(0,0{vtitle},hmin,img.Height));//remove previous trace
  Img.Canvas.Pen.Color := lineC;
  Img.Canvas.Font.Name := 'Arial';
  Img.Canvas.Font.Size := 10;
  Img.Canvas.Font.Color := linec;
  //h := round(channelheight * 0.8 * 0.5); //80% of range
  o := channelheight div 2;
  if channelheight < 1 then
    exit;
  th := img.Canvas.TextHeight('X') div 2;
  for c := 0 to EEG.numChannels-1 do begin
      Img.Canvas.TextOut(1,c*channelheight+o,EEG.Channels[c].Info{EEG.Channels[i].Info} );
      Range := EEG.Channels[c].displaymax-EEG.Channels[c].displaymin;
      if Range = 0 then
        Range := 1;
      //if EEG.Channels[c].displayscalex <> 0 then begin
      //beta
      //  scale := (channelheight div 2)/ EEG.Channels[c].displayscalex {/(channelheight div 2)} ;
        hi := Rounded ( ((0.5+kVPct)*Range)+EEG.Channels[c].displaymin, lDecHi);
        hipix := (c+1)*channelheight-round((hi-EEG.Channels[c].displaymin) * EEG.Channels[c].displayscale);
        lo := Rounded ( ((0.5-kVPct)*Range)+EEG.Channels[c].displaymin, lDecLo);
        //if c = 0 then
        //  Form1.caption :=  FloatToStrF(lo, ffFixed,7,6)+'..'+FloatToStrF(hi, ffFixed,7,6)+'  '+FloatToStrF(EEG.Channels[c].displaymin, ffFixed,7,6)+'..'+FloatToStrF(EEG.Channels[c].displaymax, ffFixed,7,6);
        lopix := (c+1)*channelheight-round((lo-EEG.Channels[c].displaymin) * EEG.Channels[c].displayscale);
        Img.Canvas.moveto(hmin-2,hipix);
        Img.Canvas.lineto(hmin-2,lopix);
        s := FloatToStrF(hi, ffFixed,7,ldechi);
        Img.Canvas.TextOut(hmin-4-Img.Canvas.TextWidth(s),hipix-th,s );
        s := FloatToStrF(lo, ffFixed,7,ldeclo);
        Img.Canvas.TextOut(hmin-4-Img.Canvas.TextWidth(s),lopix-th,s );
        if erase  < 1 then begin
          Img.Canvas.moveto(hmin+2,hipix);
          Img.Canvas.lineto(Img.picture.Width,hipix);
          Img.Canvas.moveto(hmin+2,lopix);
          Img.Canvas.lineto(Img.picture.Width,lopix);
        end;
  end;
end;

(*procedure TOscilloscope.AddSample(sample: integer; Offline: boolean);
var
  i,c: Integer;
  v: single;
begin
  if sample >= EEG.maxsamples then
    exit;
  channelheight := pixelheightperchannelX;
  with Img.Canvas do begin
    Pen.Color := bgC;
    if erase > 0 then begin
      i := hsample+erase;
      if i > hmax then
        i := i-hmax+hmin-1;
      moveto(i,0);
      lineto(i,img.height);
    end;
    if offline then
        Pen.Color := offlineC
    else
        Pen.Color := lineC;
    if EEG.numChannels < 1 then exit;
    for c := 0 to EEG.numChannels-1 do begin
      v := EEG.filtered[c][sample];
      i := (c+1)*channelheight-round((v-EEG.Channels[c].displaymin) * EEG.Channels[c].displayscale);
      if sample = 0 then
        moveto(hsample,i)
      else
        moveto(hsample-1,EEG.Channels[c].previ);
      lineto(hsample,i);
      EEG.Channels[c].previ := i;
    end;
  end;
  inc(hsample);
  if hsample > hmax then
    hsample := hmin;
end; *)
procedure TOscilloscope.AddSample(sample,pixelstep: integer);
var
  i,c,px: Integer;
  v: single;
begin
  if (sample >= EEG.maxsamples) or (Pixelstep < 1) then
    exit;
  channelheight := pixelheightperchannelX;
  with Img.Canvas do begin
    Pen.Color := bgC;
    if erase > 0 then begin
      for px := 1 to pixelstep do begin
        i := px+hsample+erase;
        if i > hmax then
          i := i-hmax+hmin-1;
        moveto(i,0);
        lineto(i,img.height);
      end;//for each pixel
    end;
    {if offline then
        Pen.Color := offlineC
    else }
        Pen.Color := lineC;
    if EEG.numChannels < 1 then exit;
    for c := 0 to EEG.numChannels-1 do begin
      v := EEG.filtered[c][sample];
      i := (c+1)*channelheight-round((v-EEG.Channels[c].displaymin) * EEG.Channels[c].displayscale);
      if ((hsample-pixelstep)< hmin) then
        moveto(hmin,i)//hsample := hmin+pixelstep;
      else if sample = 0 then
        moveto(hsample,i)
      else
        moveto(hsample-pixelstep,EEG.Channels[c].previ);
      lineto(hsample,i);
      EEG.Channels[c].previ := i;
    end;
  end;
  inc(hsample,pixelstep);
  if hsample > hmax then
    hsample := hmin;
end;

procedure TOscilloscope.AddSamples(mostrecentsample: integer);
var
  i,c,Ihorizontalscale: Integer;
begin
  if (mostrecentsample >= EEG.maxsamples) or (mostrecentsample <= EEG.samplesprocessed) then
    exit;
  //add processing here....
  for i := EEG.samplesprocessed to mostrecentsample-1 do begin //-1: indexed from 0
    for c := 0 to EEG.numChannels-1 do
      if EEG.Channels[c].HighPass.Freq <> 0 then
        EEG.filtered[c][i] := EEG.Channels[c].HighPass.Process(EEG.samples[c][i])
      else
        EEG.filtered[c][i] := EEG.samples[c][i];
  end;
  if horizontalscale < 1 then begin //need to interpolate points
    if horizontalscale = 0 then
      exit;
    Ihorizontalscale := round(1/horizontalscale);
    for i := EEG.samplesprocessed to mostrecentsample-1 do  //-1: indexed from 0
        AddSample(i,Ihorizontalscale);
  end else begin
    Ihorizontalscale := round(horizontalscale);
    for i := EEG.samplesprocessed to mostrecentsample-1 do  //-1: indexed from 0
      if (i mod Ihorizontalscale) = 0 then
        AddSample(i,1);
  end;

  EEG.samplesprocessed := mostrecentsample;
end;

function TOscilloscope.pixelheightperchannelX: integer;
begin
   result := channelheight;
   if result > 1 then
    exit;
   if (EEG.numChannels < 1) or (img.height <= EEG.numChannels) then
      result := 64
   else
      result :=(img.height-(EEG.numChannels-1){-vtitle}-8) div EEG.numChannels;
   if result < 16 then
    result := 16;
end;

constructor TOscilloscope.Clear;
begin
  channelheight := 0;
  channelheight := pixelheightperchannelX;
  //if oldchannelheight = 0 then
  //  oldchannelheight := 1;
  if channelheight = 0 then
    channelheight := 1;
  SetDimension(img,img.Height,img.Width);
  with Img.Canvas do begin
    Brush.Color := bgC;
    Brush.Style:=bsSolid;
    FillRect(ClipRect);
    Brush.Style:=bsClear;
    Pen.Color := lineC;
    hmax := img.width;
    hmin := 60;
    //vtitle := 20;
    hsample := hmin;
  end;
  UpdateDisplayScale;
  AddTimeLine;
  AddScaleLines;
end;

constructor TOscilloscope.Create;
var
  i: integer;
begin
  horizontalscaleSamples := 16;
  EEG.samplesprocessed := 0;
  bgC := clMoneyGreen;
  lineC := clRed;
  EEG.numChannels := 0;
  EEG.maxsamples := 0;
  channelheight := 0;
  EEG.audiomin := 0;
  EEG.audiomax := 0;
  erase := 20;
  EEG.time := Now;
  for i := 0 to kMaxChannels do begin
    freeandnil(EEG.Samples[i]);
    freeandnil(EEG.Filtered[i]);
  end;
end;

procedure TOscilloscope.UpdateDisplayScale;
//
var
  range: double;
  c: integer;
begin
  if EEG.numChannels < 1 then
    exit;
  for c := 0 to EEG.numChannels-1 do begin
    range := abs(EEG.Channels[c].displaymax-EEG.Channels[c].displaymin);
    if range = 0 then begin
      range := 1;
      EEG.Channels[c].displaymax := EEG.Channels[c].displaymin + 1;
    end;
    EEG.Channels[c].displayscale := channelheight/range;
  end;
end; //UpdateDisplayScale

constructor TOscilloscope.Create(samplespersec, channels, seconds, HighPassHz: integer; var lImage, lTimeImage: TImage; bg,trace: TColor; lChannelFilter: array of boolean; samplespergraphpoint: single);
//,
var
  i: integer;
begin
  create;
  timeimg := lTimeImage;
  img := lImage;      
  bgC := bg;
  lineC := trace;
  //offlineC := offline;
  horizontalscale := samplespergraphpoint;
  //EEG.numChannels := channels;
  //if EEG.numChannels > kMaxChannels then
  //  EEG.numChannels := kMaxChannels;
  channelheight := pixelheightperchannelX;
  CreateEEG(EEG, channels,seconds* samplespersec,samplespersec);
  if channels > 0 then begin
    //EEG.maxsamples := seconds* samplespersec;
    for i := 0 to EEG.numChannels-1 do begin
      //getmem(EEG.Samples[i], EEG.maxsamples*sizeof(single));
      //getmem(EEG.Filtered[i], EEG.maxsamples*sizeof(single));
      //EEG.Channels[i].SignalLead := true;
      //EEG.Channels[i].Info := 'ch'+inttostr(i+1);
      //EEG.Channels[i].UnitType := 'uV';
      //EEG.Channels[i].SampleRate := samplespersec;
      //EEG.Channels[i].previ := 0;
      EEG.Channels[i].HighPass := TRbjEqFilter.Create(samplespersec,0);
      if {(HighPassHz <> 0) and} (lChannelFilter[i] = true) then begin
        EEG.Channels[i].signallead := true;
        EEG.Channels[i].HighPass.Freq := HighPassHz;
        if HighPassHz <> 0 then
          EEG.Channels[i].HighPass.CalcFilterCoeffs(kHighPass,HighPassHz,0.3{Q},0{Gain}, true {QIsBandWidthCheck})
      end else begin
        EEG.Channels[i].HighPass.Freq := 0;
        EEG.Channels[i].signallead := false;
      end;
      EEG.Channels[i].displaymin := 0;
      EEG.Channels[i].displaymax := 1;
      //EEG.Channels[i].displayscale := channelheight / 2;
    end;
   end;
   updateDisplayScale;
  Clear;
end;


Destructor  TOscilloscope.Destroy;
var
  i: integer;
begin
  if EEG.numchannels > 0 then
    for i := 0 to EEG.numChannels-1 do begin
      freemem(EEG.Samples[i]);
      freemem(EEG.filtered[i]);
    end;
  EEG.numChannels := 0;
  EEG.maxsamples := 0;
end;

end.
 