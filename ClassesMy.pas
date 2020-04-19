{
    unraw - Asus RAW firmware unpacker
    Copyright (C) 2020  Yoti

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

unit ClassesMy;

interface

uses
  Classes, // TStream
  SysUtils, // fmOpenWrite, fmShareExclusive, fmShareDenyWrite
  Zlib; // TZStream

procedure AddFileToStream(const FileName: String; const Stream: TMemoryStream); Overload;
procedure AddFileToStream(const FileName: String; const Stream: TFileStream); Overload;

procedure AddFileToStreamZLib(const FileName: String; const Stream: TMemoryStream; const CompLevel: TCompressionLevel); Overload;
procedure AddFileToStreamZLib(const FileName: String; const Stream: TFileStream; const CompLevel: TCompressionLevel); Overload;

function ExtractFileNameNoExt(const FileName: String): String; Overload;

function GetFileSizeBytes(const FileName: String): Int64; Overload;
function GetFileSizeViaFS(const FileName: String): Int64; Overload;

procedure SaveStreamToFile(const Stream: TMemoryStream; const FileName: String; const Offset, Size: Cardinal); Overload;
procedure SaveStreamToFile(const Stream: TFileStream; const FileName: String; const Offset, Size: Cardinal); Overload;

function SaveStreamToFileUnZL(const Stream: TMemoryStream; const FileName: String; const Offset, Size: Cardinal): Int64; Overload;
function SaveStreamToFileUnZL(const Stream: TFileStream; const FileName: String; const Offset, Size: Cardinal): Int64; Overload;

procedure WriteStringToFile(const FileName, TextString: String);
function ReadStringFromFile(const FileName: String): String;

implementation

procedure AddFileToStream(const FileName: String; const Stream: TMemoryStream);
var
  InputFile: TFileStream;
begin
  InputFile:=TFileStream.Create(FileName, fmOpenRead or fmShareDenyWrite);
  Stream.Seek(0, soFromEnd);
  Stream.CopyFrom(InputFile, InputFile.Size);
  InputFile.Free;
end;
procedure AddFileToStream(const FileName: String; const Stream: TFileStream);
var
  InputFile: TFileStream;
begin
  InputFile:=TFileStream.Create(FileName, fmOpenRead or fmShareDenyWrite);
  Stream.Seek(0, soFromEnd);
  Stream.CopyFrom(InputFile, InputFile.Size);
  InputFile.Free;
end;

procedure AddFileToStreamZLib(const FileName: String; const Stream: TMemoryStream; const CompLevel: TCompressionLevel);
var
  InputFile: TFileStream;
  ZLibStream: TCompressionStream;
begin
  Stream.Seek(0, soFromEnd);

  InputFile:=TFileStream.Create(FileName, fmOpenRead or fmShareDenyWrite);
  ZLibStream:=TCompressionStream.Create(CompLevel, Stream);
  ZLibStream.CopyFrom(InputFile, InputFile.Size);
  ZLibStream.Free;
  InputFile.Free;
end;
procedure AddFileToStreamZLib(const FileName: String; const Stream: TFileStream; const CompLevel: TCompressionLevel);
var
  InputFile: TFileStream;
  ZLibStream: TCompressionStream;
begin
  Stream.Seek(0, soFromEnd);

  InputFile:=TFileStream.Create(FileName, fmOpenRead or fmShareDenyWrite);
  ZLibStream:=TCompressionStream.Create(CompLevel, Stream);
  ZLibStream.CopyFrom(InputFile, InputFile.Size);
  ZLibStream.Free;
  InputFile.Free;
end;

function ExtractFileNameNoExt(const FileName: String): String;
begin
  Result:=ChangeFileExt(ExtractFileName(FileName), '');
end;

function GetFileSizeBytes(const FileName: String): Int64;
var
  InputFile: File of Byte;
begin
  AssignFile(InputFile, FileName);
  Reset(InputFile);
  Result:=FileSize(InputFile);
  CloseFile(InputFile);
end;
function GetFileSizeViaFS(const FileName: String): Int64;
var
  InputFile: TFileStream;
begin
  InputFile:=TFileStream.Create(FileName, fmOpenRead or fmShareDenyWrite);
  Result:=InputFile.Size;
  InputFile.Free;
end;

procedure SaveStreamToFile(const Stream: TMemoryStream; const FileName: String; const Offset, Size: Cardinal);
var
  TempOffset: Cardinal;
  OutputFile: TFileStream;
begin
  OutputFile:=TFileStream.Create(FileName, fmCreate or fmOpenWrite or fmShareExclusive);
  TempOffset:=Stream.Position;
  Stream.Seek(Offset, soFromBeginning);
  OutputFile.CopyFrom(Stream, Size);
  Stream.Seek(TempOffset, soFromBeginning);
  OutputFile.Free;
end;
procedure SaveStreamToFile(const Stream: TFileStream; const FileName: String; const Offset, Size: Cardinal);
var
  TempOffset: Cardinal;
  OutputFile: TFileStream;
begin
  OutputFile:=TFileStream.Create(FileName, fmCreate or fmOpenWrite or fmShareExclusive);
  TempOffset:=Stream.Position;
  Stream.Seek(Offset, soFromBeginning);
  OutputFile.CopyFrom(Stream, Size);
  Stream.Seek(TempOffset, soFromBeginning);
  OutputFile.Free;
end;

function SaveStreamToFileUnZL(const Stream: TMemoryStream; const FileName: String; const Offset, Size: Cardinal): Int64;
var
  TempOffset: Cardinal;
  TempStream: TMemoryStream;
  UnZLStream: TZDecompressionStream;
  OutputFile: TFileStream;
begin
  TempOffset:=Stream.Position;

  Stream.Seek(Offset, soFromBeginning);
  OutputFile:=TFileStream.Create(FileName, fmCreate or fmOpenWrite or fmShareExclusive);
  TempStream:=TMemoryStream.Create;
  TempStream.CopyFrom(Stream, Size);
  UnZLStream:=TZDecompressionStream.Create(TempStream);
  OutputFile.CopyFrom(UnZLStream, UnZLStream.Size);
  Result:=OutputFile.Size;
  UnZLStream.Free;
  TempStream.Free;
  OutputFile.Free;

  Stream.Seek(TempOffset, soFromBeginning);
end;
function SaveStreamToFileUnZL(const Stream: TFileStream; const FileName: String; const Offset, Size: Cardinal): Int64;
var
  TempOffset: Cardinal;
  TempStream: TMemoryStream;
  UnZLStream: TZDecompressionStream;
  OutputFile: TFileStream;
begin
  TempOffset:=Stream.Position;

  Stream.Seek(Offset, soFromBeginning);
  OutputFile:=TFileStream.Create(FileName, fmCreate or fmOpenWrite or fmShareExclusive);
  TempStream:=TMemoryStream.Create;
  TempStream.CopyFrom(Stream, Size);
  UnZLStream:=TZDecompressionStream.Create(TempStream);
  OutputFile.CopyFrom(UnZLStream, UnZLStream.Size);
  Result:=OutputFile.Size;
  UnZLStream.Free;
  TempStream.Free;
  OutputFile.Free;

  Stream.Seek(TempOffset, soFromBeginning);
end;

procedure WriteStringToFile(const FileName, TextString: String);
var
  tmpSL: TStringList;
begin
  tmpSL:=TStringList.Create;
  tmpSL.Add(TextString);
  tmpSL.SaveToFile(FileName);
  tmpSL.Free;
end;
function ReadStringFromFile(const FileName: String): String;
var
  tmpSL: TStringList;
begin
  tmpSL:=TStringList.Create;
  tmpSL.LoadFromFile(FileName);
  Result:=tmpSL.Strings[0];
  tmpSL.Free;
end;

end.
