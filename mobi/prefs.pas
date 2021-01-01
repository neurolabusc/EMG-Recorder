unit prefs;
{$H+}

interface
uses
{$IFDEF Win32}
  Windows,
{$ELSE}
 LCLIntf,
{$ENDIF}
IniFiles,SysUtils,graphics,Dialogs,Classes,eeg_type;

//const
//  kMaxChannels= 32;

type
  TPrefs = record
         TriggerDetected,TriggerFormVisible,UnsavedData, RealData: boolean;
         TriggerhorizontalscaleSamples,TriggerMax,TriggerMin: single;
         TriggerStartPeakToPeak,TriggerEndPeakToPeak,TriggerSamples,
         DefaultFileSaveType,TriggerChannelx,{TriggerIndex,}F1, {,F2,F3,}MaxChannels,MaxSampleRateHz,
         ComPort,HighPassHz, SampleRateHz,MaxRecordSec,AudioChannel: integer;
         Trace,Background: TColor;
         ChannelFiltered,ChannelEnabled: array [1..kMaxChannels] of boolean;
  end;
  var
      gPrefs: TPrefs;
procedure SetDefaultPrefs (var lPrefs: TPrefs);
function xIniFile(lRead: boolean; lFilename: string; var lPrefs: TPrefs): boolean;

implementation

procedure SetDefaultPrefs (var lPrefs: TPrefs);
var
  i: integer;
begin
  with lPrefs do begin
    F1:=300; //F2 := 0; F3 := 0;
    TriggerFormVisible := true;
    TriggerDetected := false;
    TriggerChannelx := 0;
    TriggerSamples := 500;
    DefaultFileSaveType := 1;
    TriggerhorizontalscaleSamples := 1;
    RealData := false;
    UnsavedData := false;
    MaxChannels := 8;
    AudioChannel := 1;
    ComPort := 4;
    MaxSampleRateHz := 2048;
//    Offline := $ff0000;
    Trace := $0000ff;//$aa0055;//clBlue;
    Background := $C8FFB4;//clBlack;
    HighPassHz := 10;
    SampleRateHz := 2048;
    MaxRecordSec := 60*30;
    for i := 1 to kMaxChannels do
         ChannelEnabled[i] := false;
    ChannelEnabled[1] := true;
    ChannelEnabled[7] := true;
    ChannelEnabled[8] := true;
    for i := 1 to kMaxChannels do
         ChannelFiltered[i] := true;
    ChannelFiltered[7] := false;
    ChannelFiltered[8] := false;
    //TriggerIndex := -1;
    TriggerMax := 100000;
    TriggerMin := -100000;
    TriggerStartPeakToPeak := 5;
    TriggerEndPeakToPeak := 50
  end;//with lPrefs
end; //Proc SetDefaultPrefs

function TColorToHex( Color : TColor ) : string;
begin
  Result :=
    { red value }
    IntToHex( GetRValue( Color ), 2 ) +
    { green value }
    IntToHex( GetGValue( Color ), 2 ) +
    { blue value }
    IntToHex( GetBValue( Color ), 2 );
end;

function HexToTColor( sColor : string ) : TColor;
begin
  Result :=
    RGB(
      { get red value }
      StrToInt( '$'+Copy( sColor, 1, 2 ) ),
      { get green value }
      StrToInt( '$'+Copy( sColor, 3, 2 ) ),
      { get blue value }
      StrToInt( '$'+Copy( sColor, 5, 2 ) )
    );
end;

function StrToHex( sColor : string ) : TColor;
begin
  Result :=
    RGB(
      { get red value }
      StrToInt( '$'+Copy( sColor, 1, 2 ) ),
      { get green value }
      StrToInt( '$'+Copy( sColor, 3, 2 ) ),
      { get blue value }
      StrToInt( '$'+Copy( sColor, 5, 2 ) ) );
end;

procedure IniColor(lRead: boolean; lIniFile: TIniFile; lIdent: string;  var lValue: TColor);
//read or write an integer value to the initialization file
var
	lStr: string;
begin
  if not lRead then begin
           lIniFile.WriteString('CLR',lIdent,{IntToHex(lValue,8)} TColorToHex(lValue));
           exit;
  end;
	lStr := lIniFile.ReadString('CLR',lIdent, '');
	if length(lStr) > 0 then
		lValue := HexToTColor(lStr);
end; //IniColor

function Bool2Char (lBool: boolean): char;
begin
     if lBool then
        result := '1'
     else
         result := '0';
end;

function Char2Bool (lChar: char): boolean;
begin
	if lChar = '1' then
		result := true
	else
		result := false;
end;

procedure IniSingle(lRead: boolean; lIniFile: TIniFile; lIdent: string;  var lValue: single);
//read or write an integer value to the initialization file
var
	lStr: string;
begin
        if not lRead then begin
           lIniFile.WriteString('FLT',lIdent,FloatToStr(lValue));
           exit;
        end;
	lStr := lIniFile.ReadString('FLT',lIdent, '');
	if length(lStr) > 0 then
		lValue := StrToFLoat(lStr);
end; //IniInt

procedure IniInt(lRead: boolean; lIniFile: TIniFile; lIdent: string;  var lValue: integer);
//read or write an integer value to the initialization file
var
	lStr: string;
begin
        if not lRead then begin
           lIniFile.WriteString('INT',lIdent,IntToStr(lValue));
           exit;
        end;
	lStr := lIniFile.ReadString('INT',lIdent, '');
	if length(lStr) > 0 then
		lValue := StrToInt(lStr);
end; //IniInt

procedure IniBool(lRead: boolean; lIniFile: TIniFile; lIdent: string;  var lValue: boolean);
//read or write a boolean value to the initialization file
var
	lStr: string;
begin
        if not lRead then begin
           lIniFile.WriteString('BOOL',lIdent,Bool2Char(lValue));
           exit;
        end;
	lStr := lIniFile.ReadString('BOOL',lIdent, '');
	if length(lStr) > 0 then
	   lValue := Char2Bool(lStr[1]);
end; //IniBool

procedure IniStr(lRead: boolean; lIniFile: TIniFile; lIdent: string; var lValue: string);
//read or write a string value to the initialization file
begin
  if not lRead then begin
    lIniFile.WriteString('STR',lIdent,lValue);
    exit;
  end;
	lValue := lIniFile.ReadString('STR',lIdent, '');
end; //IniStr

procedure IniChar(lRead: boolean; lIniFile: TIniFile; lIdent: string; var lValue: char);
//read or write a string value to the initialization file
var
  lS: string;
begin
  if not lRead then begin
    lIniFile.WriteString('STR',lIdent,lValue);
    exit;
  end;
	lS := lIniFile.ReadString('STR',lIdent, lValue);
  if length(lS)> 0 then
    lValue := lS[1];
end; //IniStr

function xIniFile(lRead: boolean; lFilename: string; var lPrefs: TPrefs): boolean;
//Read or write initialization variables to disk
var
  lIniFile: TIniFile;
  i: integer;
begin
  result := false;
  if lRead then
     SetDefaultPrefs(lPrefs);
  if (lRead) and (not Fileexists(lFilename)) then
        exit;
   //     if not lRead then
   //      showmessage( lFilename);
  lIniFile := TIniFile.Create(lFilename);
  IniColor(lRead,lIniFile, 'Trace',lPrefs.Trace);
  IniColor(lRead,lIniFile, 'Background',lPrefs.Background);
  IniInt(lRead,lIniFile, 'F1',lPrefs.F1);
  IniInt(lRead,lIniFile, 'AudioChannel',lPrefs.AudioChannel);
  IniInt(lRead,lIniFile, 'ComPort',lPrefs.ComPort);
  IniInt(lRead,lIniFile, 'HighPassHz',lPrefs.HighPassHz);
  IniInt(lRead,lIniFile, 'SampleRateHz',lPrefs.SampleRateHz);
  IniInt(lRead,lIniFile, 'MaxRecordSec',lPrefs.MaxRecordSec);
  //lPrefs.TriggerChannelx := abs(lPrefs.TriggerChannelx);//negative value used when waiting for a pulse
  IniInt(lRead,lIniFile, 'TriggerChannel',lPrefs.TriggerChannelx);
  IniInt(lRead,lIniFile, 'TriggerSamples',lPrefs.TriggerSamples);
  IniInt(lRead,lIniFile, 'TriggerStartPeakToPeak',lPrefs.TriggerStartPeakToPeak);
  IniInt(lRead,lIniFile, 'TriggerEndPeakToPeak',lPrefs.TriggerEndPeakToPeak);
  IniInt(lRead,lIniFile, 'DefaultFileSaveType',lPrefs.DefaultFileSaveType);
  IniSingle(lRead,lIniFile, 'TriggerhorizontalscaleSamples',lPrefs.TriggerhorizontalscaleSamples);
  IniSingle(lRead,lIniFile, 'TriggerMax',lPrefs.TriggerMax);
  IniSingle(lRead,lIniFile, 'TriggerMin',lPrefs.TriggerMin);
  IniBool(lRead,lIniFile, 'TriggerFormVisible',lPrefs.TriggerFormVisible);
  for i := 1 to kMaxChannels do
      IniBool(lRead,lIniFile, 'ChannelEnabled'+inttostr(i),lPrefs.ChannelEnabled[i]);
  for i := 1 to kMaxChannels do
      IniBool(lRead,lIniFile, 'ChannelFiltered'+inttostr(i),lPrefs.ChannelFiltered[i]);
  lIniFile.Free;
end;

end.
