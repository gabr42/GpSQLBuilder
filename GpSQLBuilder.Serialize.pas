///<summary>Serializers working on the SQL AST.</summary>
///<author>Primoz Gabrijelcic</author>
///<remarks><para>
///Copyright (c) 2015, Primoz Gabrijelcic
///All rights reserved.
///
///Redistribution and use in source and binary forms, with or without
///modification, are permitted provided that the following conditions are met:
///
///* Redistributions of source code must retain the above copyright notice, this
///  list of conditions and the following disclaimer.
///
///* Redistributions in binary form must reproduce the above copyright notice,
///  this list of conditions and the following disclaimer in the documentation
///  and/or other materials provided with the distribution.
///
///* Neither the name of GpSQLBuilder nor the names of its
///  contributors may be used to endorse or promote products derived from
///  this software without specific prior written permission.
///
///THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
///AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
///IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
///DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE
///FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL
///DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR
///SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER
///CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY,
///OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE
///OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
///
///   Author            : Primoz Gabrijelcic
///   Creation date     : 2015-04-20
///   Last modification : 2015-04-20
///   Version           : 0.1
///</para><para>
///   History:
///     0.1: 2015-04-20
///       - Created.
///</para></remarks>

unit GpSQLBuilder.Serialize;

interface

uses
  GpSQLBuilder.AST;

type
  IGpSQLASTSerializer = interface
  ['{E6355E23-1D91-4536-A693-E1E33B0E2707}']
    function AsString: string;
  end; { IGpSQLASTSerializer }

function CreateSQLSerializer(const ast: IGpSQLAST): IGpSQLASTSerializer;

// TODO -oPrimoz Gabrijelcic : temporary solution
function SqlParamsToStr(const params: array of const): string;

implementation

uses
  System.SysUtils;

type
  TGpSQLSerializer = class(TInterfacedObject, IGpSQLASTSerializer)
  strict private
    FAST: IGpSQLAST;
  strict protected
    function  AddToList(const aList, delim, newElement: string): string;
    function  Concatenate(const elements: array of string): string;
    function  SerializeColumns(const columns: IGpSQLColumns): string;
    function  SerializeGroupBy: string;
    function  SerializeHaving: string;
    function  SerializeLeftJoins: string;
    function  SerializeName(const name: IGpSQLName): string;
    function  SerializeOrderBy: string;
    function  SerializeSelect: string;
    function  SerializeSelectQualifiers(const qualifiers: IGpSQLSelectQualifiers): string;
    function  SerializeWhere: string;
  public
    constructor Create(const AAST: IGpSQLAST);
    function AsString: string;
  end; { TGpSQLSerializer }

{ globals }

function VarRecToString(const vr: TVarRec): string;
const
  BoolChars: array [boolean] of string = ('F', 'T');
begin
  case vr.VType of
    vtInteger:    Result := IntToStr(vr.VInteger);
    vtBoolean:    Result := BoolChars[vr.VBoolean];
    vtChar:       Result := char(vr.VChar);
    vtExtended:   Result := FloatToStr(vr.VExtended^);
    vtString:     Result := string(vr.VString^);
    vtPointer:    Result := IntToHex(integer(vr.VPointer),8);
    vtPChar:      Result := string(vr.VPChar^);
    vtObject:     Result := vr.VObject.ClassName;
    vtClass:      Result := vr.VClass.ClassName;
    vtWideChar:   Result := string(vr.VWideChar);
    vtPWideChar:  Result := string(vr.VPWideChar^);
    vtAnsiString: Result := string(vr.VAnsiString);
    vtCurrency:   Result := CurrToStr(vr.VCurrency^);
    vtVariant:    Result := string(vr.VVariant^);
    vtWideString: Result := string(WideString(vr.VWideString));
    vtInt64:      Result := IntToStr(vr.VInt64^);
    {$IFDEF Unicode}
    vtUnicodeString: Result := string(vr.VUnicodeString);
    {$ENDIF}
    else raise Exception.Create('VarRecToString: Unsupported parameter type');
  end;
end; { VarRecToString }

{ exports }

function SqlParamsToStr(const params: array of const): string;
var
  iParam: integer;
  lastCh: char;
  sParam: string;
begin
  Result := '';
  for iParam := Low(params) to High(params) do begin
    sParam := VarRecToString(params[iparam]);
    if Result = '' then
      lastCh := ' '
    else
      lastCh := Result[Length(Result)];
    if (lastCh <> '.') and (lastCh <> '(') and (lastCh <> ' ') and (lastCh <> ':') and
       (sParam <> ',') and (sParam <> '.') and (sParam <> ')')
    then
      Result := Result + ' ';
    Result := Result + sParam;
  end;
end; { SqlParamsToStr }

function CreateSQLSerializer(const ast: IGpSQLAST): IGpSQLASTSerializer;
begin
  Result := TGpSQLSerializer.Create(ast);
end; { CreateSQLSerializer }

{ TGpSQLSerializer }

constructor TGpSQLSerializer.Create(const AAST: IGpSQLAST);
begin
  inherited Create;
  FAST := AAST;
end; { TGpSQLSerializer.Create }

function TGpSQLSerializer.AddToList(const aList, delim, newElement: string): string;
begin
  Result := aList;
  if Result <> '' then
    Result := Result + delim;
  Result := Result + newElement;
end; { TGpSQLSerializer.AddToList }

function TGpSQLSerializer.AsString: string;
begin
  Result := Concatenate([
    SerializeSelect,
    SerializeLeftJoins,
    SerializeWhere,
    SerializeGroupBy,
    SerializeHaving,
    SerializeOrderBy]);
end; { TGpSQLSerializer.AsString }

function TGpSQLSerializer.Concatenate(const elements: array of string): string;
var
  s: string;
begin
  Result := '';
  for s in elements do
    if s <> '' then
      Result := AddToList(Result, ' ', s);
end; { TGpSQLSerializer.Concatenate }

function TGpSQLSerializer.SerializeColumns(const columns: IGpSQLColumns): string;
var
  i: integer;
begin
  Result := '';
  for i := 0 to columns.Count - 1 do begin
    if Result <> '' then
      Result := Result + ', ';
    Result := Result + SerializeName(columns[i]);
  end;
end; { TGpSQLSerializer.SerializeColumns }

function TGpSQLSerializer.SerializeGroupBy: string;
begin
  Result := '';
end; { TGpSQLSerializer.SerializeGroupBy }

function TGpSQLSerializer.SerializeHaving: string;
begin
  Result := '';
end; { TGpSQLSerializer.SerializeHaving }

function TGpSQLSerializer.SerializeLeftJoins: string;
begin
  Result := '';
end; { TGpSQLSerializer.SerializeLeftJoins }

function TGpSQLSerializer.SerializeName(const name: IGpSQLName): string;
begin
  Result := name.Name;
  if name.Alias <> '' then
    Result := Result + ' AS ' + name.Alias;
end; { TGpSQLSerializer.SerializeName }

function TGpSQLSerializer.SerializeOrderBy: string;
begin
  Result := '';
end; { TGpSQLSerializer.SerializeOrderBy }

function TGpSQLSerializer.SerializeSelect: string;
var
  columns: IGpSQLColumns;
  select : IGpSQLSelect;
begin
  columns := FAST.Select as IGpSQLColumns;
  select := FAST.Select as IGpSQLSelect;
  if (select.TableName.Name = '') and (columns.Count = 0) then
    Result := ''
  else
    Result := Concatenate(['SELECT', SerializeSelectQualifiers(select.Qualifiers),
      SerializeColumns(columns), 'FROM', SerializeName(select.TableName)]);
end; { TGpSQLSerializer.SerializeSelect }

function TGpSQLSerializer.SerializeSelectQualifiers(
  const qualifiers: IGpSQLSelectQualifiers): string;
var
  i: integer;
begin
  Result := '';
  for i := 0 to qualifiers.Count - 1 do
    case qualifiers[i].Qualifier of
      sqFirst: Result := AddToList(Result, ' ', Concatenate(['FIRST', IntToStr(qualifiers[i].Value)]));
      sqSkip:  Result := AddToList(Result, ' ', Concatenate(['SKIP', IntToStr(qualifiers[i].Value)]));
      else raise Exception.Create('TGpSQLSerializer.SerializeSelectQualifiers: Unknown qualifier');
    end;
end; { TGpSQLSerializer.SerializeSelectQualifiers }

function TGpSQLSerializer.SerializeWhere: string;
begin
  Result := '';
end; { TGpSQLSerializer.SerializeWhere }

end.
