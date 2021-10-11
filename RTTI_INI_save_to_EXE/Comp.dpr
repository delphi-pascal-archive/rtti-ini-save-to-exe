program Comp;

uses
  Forms, Windows, SysUtils, Dialogs, Controls, ShellApi,
  Unit1 in 'Unit1.pas' {Form1};

{$R *.res}

var
    Drive           : string;
    FreeAvailable   : int64;
    TotalSpace      : int64;
    SizeExeTemp     : int64;
    SizeExe         : int64;
    hFile           : Cardinal;
    lpFileSizeHigh  : DWord;
    A, B            : Cardinal;

const
    Mes : array [1..3] of ShortString = ( 'Impossible de supprimer le fichier source',
                                          'Impossible de copier le fichier temporaire',
                                          'Impossible de supprimer le fichier temporaire');

function Boucle(Value: Integer): Boolean;
begin
    Result:=False;
    Sleep(50);
    B:=GetTickCount;
    if (B - A) > 30000 then
    begin
        MessageDlg('Un problème est survenu opération annulée !'+#13#10+Mes[Value],mtError,[mbOK],0);
        Result:=True;
    end;
end;

begin
    SetLastError(NO_ERROR);
    CreateMutex (nil, True, PChar('MutexFor' + ExtractFileName(Application.ExeName)));
    if GetLastError = ERROR_ALREADY_EXISTS then
        Exit;
    if ParamStr(1) = '-Exit' then
    begin
        GetTempPath(MAX_PATH, @lpBuffer);
        A:=GetTickCount;
        repeat
            if Boucle(3) then
                Exit;
        until DeleteFile(lpBuffer+NameTemp);
        Exit;
    end;
    if ParamStr(1) <> EmptyStr then
    begin
        Drive:=ExtractFileDrive(ParamStr(1))+PathDelim;
        GetDiskFreeSpaceEx(PChar(Drive),FreeAvailable,TotalSpace,nil);
        hFile := CreateFile(PChar(ParamStr(0)), GENERIC_READ, FILE_SHARE_READ, nil, OPEN_EXISTING, 0, 0);
        try
        SizeExeTemp:=GetFileSize(hFile ,@lpFileSizeHigh);
        finally
            CloseHandle(hFile);
        end;
        SizeExeTemp:=SizeExeTemp + Int64( lpFileSizeHigh ) shl 32;
        hFile := CreateFile(PChar(ParamStr(1)), GENERIC_READ, FILE_SHARE_READ, nil, OPEN_EXISTING, 0, 0);
        try
        SizeExe:=GetFileSize(hFile ,@lpFileSizeHigh);
        finally
            CloseHandle(hFile);
        end;
        SizeExe:=SizeExe + Int64( lpFileSizeHigh ) shl 32;
        If ((FreeAvailable + SizeExe) - SizeExeTemp) <= 0 then
        begin
            repeat
                if ((FreeAvailable + SizeExe) - SizeExeTemp) <= 0 then
                    if MessageDlg(Format('Il vous manque %d Ko sur votre support !'+#13#10+
                        'si vous le souhaitez, faite de la place, puis " Oui "'+#13#10+
                        'sinon faite " Non " est l''opération sera annulée.',
                        [-(((FreeAvailable + SizeExe) - SizeExeTemp) div 1024)]),mtInformation,[mbYes,mbNo],0) = mrYes then
                        GetDiskFreeSpaceEx(PChar(Drive),FreeAvailable,TotalSpace,nil)
                    else
                    begin
                        ShellExecute( 0, nil, PChar(ParamStr(1)), '-Exit', nil, SW_HIDE);
                        Exit;
                    end;
            until (((FreeAvailable + SizeExe) - SizeExeTemp) > 0);
        end;
        A:=GetTickCount;
        repeat
            if Boucle(1) then
                Exit;
        until (DeleteFile(ParamStr(1)));
        A:=GetTickCount;
        repeat
            if Boucle(2) then
            begin
                MessageDlg('Votre executable a été enregistré à l''emplacement suivant'+#13#10+ParamStr(0),mtInformation,[mbOK],0);
                Exit;
            end;
        until CopyFile(PChar(ExtractFilePath(Application.ExeName)+NameTemp),PChar(ParamStr(1)),True);
        ShellExecute( 0, nil, PChar(ParamStr(1)), '-Exit', nil, SW_HIDE);
        Exit;
    end;
    
    Application.Initialize;
    Application.CreateForm(TForm1, Form1);
    {$IF RTLVersion >= 21}
    ReportMemoryLeaksOnShutdown := True;
    {$IFEND}
    Application.Run;
end.
