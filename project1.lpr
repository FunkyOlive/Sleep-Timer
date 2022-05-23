program project1;

{$mode objfpc}{$H+}

uses
  {$IFDEF UNIX}{$IFDEF UseCThreads}
  cthreads,
  {$ENDIF}{$ENDIF}
  Interfaces, // this includes the LCL widgetset
  Forms, Unit1
  { you can add units after this };
{$R *.res}


//function FindDuplicateMainWdw: HWND;
//begin
//  Result := FindWindow('SleepTimer')
//end;
//
//function CanStart: Boolean;
//var Wdw: HWND;
//begin
//    Wdw := FindDuplicateMainWdw;
//  if Wdw = 0 then
//    // no instance running: we can start our app
//    Result := True
//  else
//    // instance running: try to pass command line to it
//    // terminate this instance if this succeeds
//    // (SwitchToPrevInst routine explained later)
//    Result := not SwitchToPrevInst(Wdw);
//end;
//
//
//begin
//  if CanStart() then
  begin
  Application.Title :='SleepTimer';
  RequireDerivedFormResource := True;
  Application.Initialize;
  Application.CreateForm(TSleepTimer, SleepTimer);
  Application.Run;
//end;
end.

