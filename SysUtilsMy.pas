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

unit SysUtilsMy;

interface

uses
  SysUtils;

function IntToStrMy(Value: Integer; Digits: Integer): string; overload;
function IntToStrMy(Value: Int64; Digits: Integer): string; overload;

function ExtractDirName(const DirPath: String): String;
function ExtractFileNameLink(const Link: String): String;

implementation

function IntToStrMy(Value: Integer; Digits: Integer): string;
begin
  FmtStr(Result, '%.*d', [Digits, Value]);
end;
function IntToStrMy(Value: Int64; Digits: Integer): string;
begin
  FmtStr(Result, '%.*d', [Digits, Value]);
end;

function ExtractDirName(const DirPath: String): String;
var
  s: String;
  i: Integer;
begin
  s:=DirPath;
  if (s[Length(s)] = '\')
  then s:=Copy(s, 1, Length(s) - 1);

  i:=LastDelimiter('\', s);
  Result:=Copy(s, i + 1, Length(s) - i);
end;
function ExtractFileNameLink(const Link: String): String;
var
  s: String;
  i: Integer;
begin
  s:=Link;
  if (s[Length(s)] = '/')
  then s:=Copy(s, 1, Length(s) - 1);

  i:=LastDelimiter('/', s);
  Result:=Copy(s, i + 1, Length(s) - i);
end;

end.
