{
    unraw - Asus RAW firmware unpacker
    Copyright (C) 2021  Yoti

    This program is free software: you can redistribute it and/or modify
    it under the terms of the GNU General Public License as published by
    the Free Software Foundation, either version 3 of the License, or
    (at your option) any later version.

    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU General Public License for more details.

    You should have received a copy of the GNU General Public License
    along with this program.  If not, see <https://www.gnu.org/licenses/>
}

program unraw;

{$APPTYPE CONSOLE}

uses
  Classes,
  ClassesMy,
  SysUtils,
  SysUtilsMy,
  Windows;

const
  TitleStr: String = 'Asus RAW unpacker by Yoti';

type
  EntryV1 = Record
    Mount: Array[$00..$0f] of WideChar;
    Name: Array[$00..$1f] of AnsiChar;
    Size: Cardinal;
    unk1: Cardinal;
    unk2: Cardinal;
    unk3: Cardinal;
    unk4: Cardinal;
    unk5: Cardinal;
    Check: Cardinal;
    unk6: Cardinal;
  end;
  EntryV2 = Record
    Name: Array[$00..$7F] of AnsiChar;
    Offset: Int64;
    Size: Int64;
    unk1: Array[$00..$6F] of Byte;
  end;
  EntryV2_2 = Record
    Name: Array[$00..$7F] of AnsiChar;
    unk1: Cardinal;
    unk2: Array[$00..$17B] of Byte;
  end;

var
  ConsoleTitle: String;

procedure UnPackV1(const inFileName, outDirName: String);
var
  inFS: TFileStream;
  Count: Cardinal;
  Offset: Cardinal;
  i: Integer;
  MyEntry: EntryV1;
begin
  WriteLn('Mode: v1');

  if (DirectoryExists(outDirName) = False)
  then ForceDirectories(outDirName);

  inFS:=TFileStream.Create(inFileName, fmOpenRead or fmShareDenyWrite);

  inFS.Seek($18, soFromBeginning);
  inFS.Read(Count, SizeOf(Count)); // files count
  WriteLn('Count: ' + IntToStr(Count));

  inFS.Seek($30, soFromBeginning); // table offset
  Offset:=$2800; // files offset

  for i:=1 to Count do begin
    FillChar(MyEntry, SizeOf(MyEntry), $00);
    inFS.Read(MyEntry, SizeOf(MyEntry));
    WriteLn(MyEntry.Name + ' (' + IntToStr(MyEntry.Size) + ')');
    SaveStreamToFile(inFS, outDirName + String(MyEntry.Name), Offset, MyEntry.Size);
    Offset:=Offset + MyEntry.Size;
  end;

  inFS.Free;
  WriteLn('Dst: ' + ExtractDirName(outDirName) + '\');
end;

procedure UnPackV2(const inFileName, outDirName: String);
var
  inFS: TFileStream;
  Count: Cardinal;
  i: Integer;
  MyEntry: EntryV2;
  TempOffset: Int64;
  MyEntry_2: EntryV2_2;
begin
  WriteLn('Mode: v2');

  if (DirectoryExists(outDirName) = False)
  then ForceDirectories(outDirName);

  inFS:=TFileStream.Create(inFileName, fmOpenRead or fmShareDenyWrite);

  inFS.Seek($40, soFromBeginning);
  inFS.Read(Count, SizeOf(Count)); // files count
  WriteLn('Count: ' + IntToStr(Count));

  inFS.Seek($400, soFromBeginning); // table offset

  for i:=1 to Count do begin
    FillChar(MyEntry, SizeOf(MyEntry), $00);
    inFS.Read(MyEntry, SizeOf(MyEntry));

    if (MyEntry.Size < 0) then begin // v2_32
      MyEntry.Size:=MyEntry.Offset shr 32;
      MyEntry.Offset:=MyEntry.Offset and $FFFFFFFF;
    end; // else v2_64

    TempOffset:=inFS.Position;
    inFS.Position:=MyEntry.Offset;
    FillChar(MyEntry_2, SizeOf(MyEntry_2), $00);
    inFS.Read(MyEntry_2, SizeOf(MyEntry_2));
    inFS.Position:=TempOffset;

    WriteLn(MyEntry.Name + ' (' + IntToStr(MyEntry.Size) + ')');
    SaveStreamToFile(inFS, outDirName + String(MyEntry.Name), MyEntry.Offset + SizeOf(MyEntry_2), MyEntry.Size);
  end;

  inFS.Free;
  WriteLn('Dst: ' + ExtractDirName(outDirName) + '\');
end;

procedure UnPack(inFileName, outDirName: String);
var
  inFS: TFileStream;
  Sign: Cardinal;
begin
  if (outDirName = '')
  then outDirName:=ChangeFileExt(inFileName, '');
  if (ExtractFilePath(outDirName) = '')
  then outDirName:=ExtractFilePath(ParamStr(0)) + outDirName;
  if (outDirName[Length(outDirName)] <> '\')
  then outDirName:=outDirName + '\';

  inFS:=TFileStream.Create(inFileName, fmOpenRead or fmShareDenyWrite);
  inFS.Read(Sign, SizeOf(Sign));
  inFS.Free;

  case Sign of
    $73757361: begin // asus (asus package)
      UnPackV1(inFileName, outDirName);
    end;
    $6B636150: begin // Pack (Package of SD Download v2)
      UnPackV2(inFileName, outDirName);
    end;
    $04034b50: begin // .zip
      WriteLn('ZIP file detected, use 7-Zip instead!');
      ExitCode:=3;
    end;
    else begin
      WriteLn('Unknown file type, can not continue!');
      ExitCode:=4;
    end;
  end;
end;

begin
  ExitCode:=0;
  GetConsoleTitle(PChar(ConsoleTitle), MAX_PATH);
  SetConsoleTitle(PChar(ChangeFileExt(ExtractFileName(ParamStr(0)), '')));
  WriteLn(TitleStr);

  if ((ParamCount < 1) or (ParamCount > 2)) then begin
    WriteLn('usage: ' + ExtractFileName(ParamStr(0)) + ' <input> [output]');
    ExitCode:=1;
  end else

  if (FileExists(ParamStr(1)) = False) then begin
    WriteLn('usage: ' + ExtractFileName(ParamStr(0)) + ' <input> [output]');
    ExitCode:=2;
  end else

  if (FileExists(ParamStr(1)) = True) then begin
    WriteLn('Src: ' + ExtractFileName(ParamStr(1)));
    UnPack(ParamStr(1), ParamStr(2));
  end;

  if (ExitCode = 0)
  then WriteLn('The job was done with success')
  else WriteLn('The job was done with failure (' + IntToStr(ExitCode) + ')');
  SetConsoleTitle(PChar(ConsoleTitle));
end.

