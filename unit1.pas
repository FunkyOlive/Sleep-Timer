unit Unit1;

{$mode objfpc}{$H+}

interface

uses
  {$IFDEF UNIX}{$IFDEF UseCThreads}
  cthreads,
  {$ENDIF}{$ENDIF}
  Classes, SysUtils, FileUtil, Forms, Controls, Graphics, Dialogs, StdCtrls,
  ComCtrls, ExtCtrls, Buttons, Menus, Process;

type

  { TSleepTimer }

  TSleepTimer = class(TForm)
    Mainaction: TButton;
    Label1: TLabel;
    Label3: TLabel;
    Label5: TLabel;
    Label4: TLabel;
    Label2: TLabel;
    Label6: TLabel;
    Label7: TLabel;
    LabelVersion: TLabel;
    TrayMenuMinMaximise: TMenuItem;
    TrayMenuExtend5: TMenuItem;
    TrayMenuExit: TMenuItem;
    TrayMenuLabel: TMenuItem;
    TrayMenuMainaction: TMenuItem;
    TrayPopupMenu: TPopupMenu;
    Timer1: TTimer;
    TrackBar1: TTrackBar;
    TrayIcon1: TTrayIcon;
    procedure MainactionClick(Sender: TObject);
    procedure FormClose(Sender: TObject);
    procedure TrayMenuMainactionClick(Sender: TObject);
    procedure TrayMenuExtend5Click(Sender: TObject);
    procedure TrayMenuExitClick(Sender: TObject);
    procedure Timer1Timer(Sender: TObject);
    procedure TrayIcon1Click(Sender: TObject);
    procedure TrayMenuMinMaximiseClick(Sender: TObject);
  private
    { private declarations }
  public
    { public declarations }
  end;

var
  SleepTimer : TSleepTimer;

  AProcess   : TProcess;                       //cmd-Prozessobjekt
  state      : integer;                        //Timerobjekt Mehrfachbenutzung
  Pos        : String;                         //Position bzw. verbleibende Zeit

implementation

{$R *.lfm}

{ TSleepTimer }

procedure TSleepTimer.MainactionClick(Sender: TObject);
begin
  if Timer1.Enabled = false then
  begin
    state := 2;
    if TrackBar1.Position > 1 then
    begin
      //SwitchMenus(false);
      TrayMenuMainaction.Caption := 'Pause';
      Mainaction.Caption := 'Pause Timer';
      TrayMenuExtend5.Enabled := true;
      Str(Trackbar1.Position, Pos);
      TrayIcon1.Hint := 'SleepTimer' + sLineBreak + Pos + ' min left';
      SleepTimer.caption := 'SleepTimer - ' + Pos + ' min left';

      Timer1.Interval := 60000;
      Timer1.Enabled := true;
      //UnShow();
      if SleepTimer.Showing then
      begin
        SleepTimer.Hide;
        TrackBar1.Enabled := false;
        Mainaction.Enabled := false;
      end;
      TrayIcon1.BalloonHint := Pos + ' min to shutdown';
      TrayIcon1.ShowBalloonHint;
    end
    else
    begin
      //SwitchMenus(true);
      TrayMenuMainaction.Caption := 'Pause';
      Mainaction.Caption := 'Pause Timer';
      TrayMenuExtend5.Enabled := true;
      TrackBar1.Position := 2;
      Timer1.Interval := 50;
      Timer1.Enabled := true;
      //UnShow();
      if SleepTimer.Showing then
      begin
        SleepTimer.Hide;
        TrackBar1.Enabled := false;
        Mainaction.Enabled := false;
      end
    end
  end
  else
  begin
    Timer1.Enabled := false;
    TrackBar1.Enabled := true;
    TrayMenuMainaction.Caption := 'Resume';
    Mainaction.Caption := 'Resume Timer';
    TrayMenuExtend5.Enabled := false;
    TrayIcon1.Hint := 'SleepTimer - inactive';
    SleepTimer.caption := 'SleepTimer - inactive';
  end;
end;

procedure TSleepTimer.FormClose(Sender: TObject);
begin
  TrayIcon1.Visible := false;
  Timer1.Enabled := false;
  AProcess.Destroy;
  Application.Terminate;
end;


procedure TSleepTimer.TrayMenuMainactionClick(Sender: TObject);
begin
  MainactionClick(TrayMenuMainaction);
end;

procedure TSleepTimer.TrayMenuExtend5Click(Sender: TObject);
begin
  if Timer1.Enabled then
  begin
    TrackBar1.Position := TrackBar1.Position + 5;
    state := 2;
    Str(Trackbar1.Position, Pos);
    Hint := 'SleepTimer' + sLineBreak + Pos + ' min left';
    TrayIcon1.Hint := Hint;
    SleepTimer.caption := 'SleepTimer - ' + Pos + ' min left';
  end;
end;

procedure TSleepTimer.TrayMenuMinMaximiseClick(Sender: TObject);
begin
  //UnShow();
  if SleepTimer.Showing then
  begin
    Mainaction.Enabled := false; //TODO test if this can be omitted
    SleepTimer.Hide;
  end
  else
  begin
    Mainaction.Enabled := true;
    SleepTimer.ShowOnTop;
  end;
end;


procedure TSleepTimer.TrayMenuExitClick(Sender: TObject);
begin
  FormClose(TrayMenuExit);
end;

procedure TSleepTimer.Timer1Timer(Sender: TObject);
begin
  case state of
  0: try
        begin
          AProcess.Execute;
          AProcess.Free;
        end;
     finally end;
  1: try
        begin
          TrayIcon1.BalloonHint := '20 sec to shutdown';
          TrayIcon1.ShowBalloonHint;
          Timer1.Interval := 20000;
          state := 0;
        end;
     finally  end;
  2: try
        begin
          TrackBar1.Position := TrackBar1.Position - 1;
          Str(Trackbar1.Position, Pos);
          Hint := 'SleepTimer'+ sLineBreak + Pos + ' min left';
          TrayIcon1.Hint := Hint;
          SleepTimer.caption := 'SleepTimer - ' + Pos + ' min left';

          if TrackBar1.Position = 1 then
          begin
            TrayIcon1.BalloonHint := '1 min to shutdown';
            TrayIcon1.ShowBalloonHint;
            Timer1.Interval := 40000;
            state := 1;
          end;
        end;
     finally  end;
  end;
end;


procedure TSleepTimer.TrayIcon1Click(Sender: TObject);
begin
  TrayMenuMinMaximiseClick(TrayIcon1);
end;


begin
  AProcess := TProcess.Create(nil);
  AProcess.Executable:= 'shutdown';
  AProcess.Parameters.Add('/p');
  AProcess.Options := AProcess.Options + [poWaitOnExit];
  state := 2;
end.

