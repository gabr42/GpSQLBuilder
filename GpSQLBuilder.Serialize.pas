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
    function  Concatenate(const elements: array of string; delimiter: string = ' '): string;
    function  SerializeColumns(const columns: IGpSQLColumns): string;
    function  SerializeDirection(direction: TGpSQLOrderByDirection): string;
    function  SerializeExpression(const expression: IGpSQLExpression): string;
    function  SerializeGroupBy: string;
    function  SerializeHaving: string;
    function SerializeJoins: string;
    function SerializeJoinType(const join: IGpSQLJoin): string;
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
    SerializeJoins,
    SerializeWhere,
    SerializeGroupBy,
    SerializeHaving,
    SerializeOrderBy]);
end; { TGpSQLSerializer.AsString }

function TGpSQLSerializer.Concatenate(const elements: array of string; delimiter: string
  = ' '): string;
var
  s: string;
begin
  Result := '';
  for s in elements do
    if s <> '' then
      Result := AddToList(Result, delimiter, s);
end; { TGpSQLSerializer.Concatenate }

function TGpSQLSerializer.SerializeColumns(const columns: IGpSQLColumns): string;
var
  i         : integer;
  orderByCol: IGpSQLOrderByColumn;
begin
  Result := '';
  for i := 0 to columns.Count - 1 do begin
    Result := Concatenate([Result, SerializeName(columns[i])], ', ');
    if Supports(columns[i], IGpSQLOrderByColumn, orderByCol) then
      Result := Concatenate([Result, SerializeDirection(orderByCol.Direction)]);
  end;
end; { TGpSQLSerializer.SerializeColumns }

function TGpSQLSerializer.SerializeDirection(direction: TGpSQLOrderByDirection): string;
begin
  case direction of
    dirAscending:  Result := '';
    dirDescending: Result := 'DESC';
    else raise Exception.Create('TGpSQLSerializer.SerializeDirection: Unknown direction');
  end;
end; { TGpSQLSerializer.SerializeDirection }

function TGpSQLSerializer.SerializeExpression(const expression: IGpSQLExpression): string;
begin
  if expression.IsEmpty then
    Result := ''
  else
    case expression.Operation of
      opNone: Result := expression.Term;
      opAnd:  Result := Concatenate([
                          '(' + SerializeExpression(expression.Left) + ')',
                          'AND',
                          '(' + SerializeExpression(expression.Right) + ')'
                        ]);
      opOr:   Result := Concatenate([
                          '(' + SerializeExpression(expression.Left) + ')',
                          'OR',
                          '(' + SerializeExpression(expression.Right) + ')'
                        ]);
      else raise Exception.Create('TGpSQLSerializer.SerializeExpression: Unknown operation');
    end;
end; { TGpSQLSerializer.SerializeExpression }

function TGpSQLSerializer.SerializeGroupBy: string;
begin
  if FAST.GroupBy.IsEmpty then
    Result := ''
  else
    Result := Concatenate(['GROUP BY', SerializeColumns(FAST.GroupBy.Columns)]);
end; { TGpSQLSerializer.SerializeGroupBy }

function TGpSQLSerializer.SerializeHaving: string;
begin
  if FAST.Having.IsEmpty then
    Result := ''
  else
    Result := Concatenate(['HAVING', SerializeExpression(FAST.Having.Expression)]);
end; { TGpSQLSerializer.SerializeHaving }

function TGpSQLSerializer.SerializeJoins: string;
var
  iJoin: integer;
  join : IGpSQLJoin;
begin
  Result := '';
  for iJoin := 0 to FAST.Joins.Count - 1 do begin
    join := FAST.Joins[iJoin];
    Result := Concatenate([Result, SerializeJoinType(join), 'JOIN',
       SerializeName(join.JoinedTable),
      'ON', SerializeExpression(join.Condition)]);
  end;
end; { TGpSQLSerializer.SerializeJoins }

function TGpSQLSerializer.SerializeJoinType(const join: IGpSQLJoin): string;
begin
  case join.JoinType of
    jtInner: Result := 'INNER';
    jtLeft:  Result := 'LEFT';
    jtRight: Result := 'RIGHT';
    jtFull:  Result := 'FULL';
    else raise Exception.Create('Error Message');
  end;
end; { TGpSQLSerializer.SerializeJoinType }

function TGpSQLSerializer.SerializeName(const name: IGpSQLName): string;
begin
  Result := name.Name;
  if name.Alias <> '' then
    Result := Result + ' AS ' + name.Alias;
end; { TGpSQLSerializer.SerializeName }

function TGpSQLSerializer.SerializeOrderBy: string;
begin
  if FAST.OrderBy.IsEmpty then
    Result := ''
  else
    Result := Concatenate(['ORDER BY', SerializeColumns(FAST.OrderBy.Columns)]);
end; { TGpSQLSerializer.SerializeOrderBy }

function TGpSQLSerializer.SerializeSelect: string;
begin
  if FAST.Select.IsEmpty then
    Result := ''
  else
    Result := Concatenate(['SELECT', SerializeSelectQualifiers(FAST.Select.Qualifiers),
      SerializeColumns(FAST.Select.Columns), 'FROM', SerializeName(FAST.Select.TableName)]);
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
  if FAST.Where.IsEmpty then
    Result := ''
  else
    Result := Concatenate(['WHERE', SerializeExpression(FAST.Where.Expression)]);
end; { TGpSQLSerializer.SerializeWhere }

end.
