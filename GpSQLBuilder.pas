///<summary>SQL query builder.</summary>
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
///   Creation date     : 2010-11-24
///   Last modification : 2015-04-04
///   Version           : 1.09
///</para><para>
///   History:
///     2.0: 2015-04-04
///        - Removed AndE and OrE aliases.
///        - Removed Column overload which accepted 'alias' parameter.
///        - Removed 'dbAlias' parameter from From and LeftJoin methods.
///        - Removed 'subquery' concept as it was not really useful.
///        - Renamed AllColumns to All.
///        - Renamed AsAlias to &As.
///        - &Case.&Then and .&Else values are not automatically quoted.
///     1.08: 2015-04-03
///        - &And and &Or aliases for AndE and OrE.
///     1.07: 2015-04-02
///       - IGpSQLBuilder
///         - Added new overloads for Select, Where, OrderBy, GroupBy, and Having.
///         - Added property ActiveSection.
///         - Added methods &On and &Case.
///       - Added case-implementing interface IGpSQLBuilderCase.
///     1.06: 2015-03-16
///       - Exposed Sections[].
///       - Added parameter dbAlias to the Column method.
///       - Added overloaded Column acception array of const.
///       - Added parameter dbAlias to the LeftJoin method.
///       - Fixed IGpSQLBuilderSection.Clear.
///     1.05: 2015-03-13
///       - Added parameter dbAlias to the From method.
///     1.04: 2013-03-06
///       - Added function AllColumns.
///     1.03: 2013-03-04
///       - Supports multiple left joins.
///     1.02: 2012-01-10
///       - Supports multiple 'from' databases.
///     1.01: 2010-12-02
///       - Added 'OR' expression builder.
///     1.0b: 2010-11-30
///       - Fixed memory leak in TGpSQLBuilder.Destroy.
///     1.0a: 2010-11-25
///       - AsAlias did not insert 'AS' token.
///       - Clear and ClearAll did not return result.
///     1.0: 2010-11-24
///       - Released.
///</para></remarks>

unit GpSQLBuilder;

interface

type
  TGpSQLSection = (secSelect, secFrom, secLeftJoin, secWhere, secGroupBy, secHaving, secOrderBy);
  TGpSQLSections = set of TGpSQLSection;
  TGpSQLStringType = (stNormal, stAnd, stOr, stList, stAppend);

  IGpSQLBuilderSection = interface ['{BE0A0FF9-AD70-40C5-A1C2-7FA2F7061153}']
    function  GetAsString: string;
  //
    procedure Add(const params: array of const; paramType: TGpSQLStringType = stNormal); overload;
    procedure Add(const params: string; paramType: TGpSQLStringType = stNormal); overload;
    procedure Clear;
    property AsString: string read GetAsString;
  end; { IGpSQLBuilderSection }

  IGpSQLBuilder = interface;

  IGpSQLBuilderCase = interface ['{1E379718-0959-455A-80AA-63BDA7C92F8C}']
    function  GetAsString: string;
  //
    function  &And(const expression: array of const): IGpSQLBuilderCase; overload;
    function  &And(const expression: string): IGpSQLBuilderCase; overload;
    function  &Else(const value: string): IGpSQLBuilderCase;
    function  &End: IGpSQLBuilder;
    function  &Or(const expression: array of const): IGpSQLBuilderCase; overload;
    function  &Or(const expression: string): IGpSQLBuilderCase; overload;
    function  &Then(const value: string): IGpSQLBuilderCase;
    function  When(const condition: string): IGpSQLBuilderCase; overload;
    function  When(const condition: array of const): IGpSQLBuilderCase; overload;
    property AsString: string read GetAsString;
  end; { IGpSQLBuilderCase }

  IGpSQLBuilder = interface ['{43EA3E34-A8DB-4257-A19F-030F404646E7}']
    function GetAsString: string;
    function GetSection(sqlSection: TGpSQLSection): IGpSQLBuilderSection;
  //
    function &And(const expression: array of const): IGpSQLBuilder; overload;
    function &And(const expression: string): IGpSQLBuilder; overload;
    function All: IGpSQLBuilder;
    function &As(const alias: string): IGpSQLBuilder;
    function &Case(const expression: string = ''): IGpSQLBuilderCase; overload;
    function &Case(const expression: array of const): IGpSQLBuilderCase; overload;
    function Column(const colName: string): IGpSQLBuilder; overload;
    function Column(const dbName, colName: string): IGpSQLBuilder; overload;
    function Column(const colName: array of const): IGpSQLBuilder; overload;
    function Desc: IGpSQLBuilder;
    function First(num: integer): IGpSQLBuilder;
    function From(const dbName: string): IGpSQLBuilder;
    function GroupBy(const colName: string = ''): IGpSQLBuilder;
    function Having(const expression: string = ''): IGpSQLBuilder; overload;
    function Having(const expression: array of const): IGpSQLBuilder; overload;
    function LeftJoin(const dbName: string): IGpSQLBuilder;
    function &On(const expression: string): IGpSQLBuilder; overload;
    function &On(const expression: array of const): IGpSQLBuilder; overload;
    function &Or(const expression: array of const): IGpSQLBuilder; overload;
    function &Or(const expression: string): IGpSQLBuilder; overload;
    function OrderBy(const colName: string = ''): IGpSQLBuilder;
    function Select(const colName: string = ''): IGpSQLBuilder;
    function Skip(num: integer): IGpSQLBuilder;
    function Where(const expression: string = ''): IGpSQLBuilder; overload;
    function Where(const expression: array of const): IGpSQLBuilder; overload;
  //
    function ActiveSection: IGpSQLBuilderSection;
    function Clear: IGpSQLBuilder;
    function ClearAll: IGpSQLBuilder;
    function IsEmpty: boolean;
    property AsString: string read GetAsString;
    property Section[sqlSection: TGpSQLSection]: IGpSQLBuilderSection read GetSection; default;
  end; { IGpSQLBuilder }

function CreateGpSQLBuilder: IGpSQLBuilder;

implementation

uses
  System.SysUtils,
  System.Generics.Collections;

type
  TGpSQLBuilderSection = class(TInterfacedObject, IGpSQLBuilderSection)
  strict private
    FAsString        : string;
    FInsertedParen   : boolean;
    FIsAndExpr       : boolean;
    FIsList          : boolean;
    FLastAndInsertion: integer;
  strict protected
    function  GetAsString: string;
  public
    procedure Add(const params: array of const; paramType: TGpSQLStringType = stNormal); overload;
    procedure Add(const params: string; paramType: TGpSQLStringType = stNormal); overload;
    procedure Clear;
    property AsString: string read GetAsString;
  end; { TGpSQLBuilderSection }

  TGpSQLBuilderCase = class(TInterfacedObject, IGpSQLBuilderCase)
  strict private
    FActiveSection : IGpSQLBuilderSection;
    FCaseExpression: string;
    FElseValue     : string;
    FHasElse       : boolean;
    FSQLBuilder    : IGpSQLBuilder;
    FWhenList      : TList<TPair<IGpSQLBuilderSection,string>>;
  strict protected
    function  GetAsString: string;
  public
    constructor Create(const sqlBuilder: IGpSQLBuilder; const expression: string);
    destructor  Destroy; override;
    function  &And(const expression: array of const): IGpSQLBuilderCase; overload;
    function  &And(const expression: string): IGpSQLBuilderCase; overload;
    function  &Else(const value: string): IGpSQLBuilderCase;
    function  &End: IGpSQLBuilder;
    function  &Or(const expression: array of const): IGpSQLBuilderCase; overload;
    function  &Or(const expression: string): IGpSQLBuilderCase; overload;
    function  &Then(const value: string): IGpSQLBuilderCase;
    function  When(const condition: string): IGpSQLBuilderCase; overload;
    function  When(const condition: array of const): IGpSQLBuilderCase; overload;
    property AsString: string read GetAsString;
  end; { IGpSQLBuilderCase }

  TGpSQLBuilder = class(TInterfacedObject, IGpSQLBuilder)
  strict private
  const
    FSectionNames : array [TGpSQLSection] of string = (
      'SELECT', 'FROM', 'LEFT JOIN', 'WHERE', 'GROUP BY', 'HAVING', 'ORDER BY'
    );
  strict private
    FActiveSection: IGpSQLBuilderSection;
    FSections     : array [TGpSQLSection] of IGpSQLBuilderSection;
  strict protected
    procedure AssertSection(section: TGpSQLSection); overload;
    procedure AssertSection(sections: TGpSQLSections); overload;
    function  GetAsString: string;
    function  GetSection(sqlSection: TGpSQLSection): IGpSQLBuilderSection;
  public
    constructor Create;
    function  ActiveSection: IGpSQLBuilderSection;
    function  &And(const expression: array of const): IGpSQLBuilder; overload;
    function  &And(const expression: string): IGpSQLBuilder; overload;
    function  All: IGpSQLBuilder;
    function  &As(const alias: string): IGpSQLBuilder;
    function  &Case(const expression: string = ''): IGpSQLBuilderCase; overload;
    function  &Case(const expression: array of const): IGpSQLBuilderCase; overload;
    function  Clear: IGpSQLBuilder;
    function  ClearAll: IGpSQLBuilder;
    function  Column(const colName: string): IGpSQLBuilder; overload;
    function  Column(const dbName, colName: string): IGpSQLBuilder; overload;
    function  Column(const colName: array of const): IGpSQLBuilder; overload;
    function  Desc: IGpSQLBuilder;
    function  First(num: integer): IGpSQLBuilder;
    function  From(const dbName: string): IGpSQLBuilder;
    function  GroupBy(const colName: string = ''): IGpSQLBuilder;
    function  Having(const expression: string = ''): IGpSQLBuilder; overload;
    function  Having(const expression: array of const): IGpSQLBuilder; overload;
    function  IsEmpty: boolean;
    function  LeftJoin(const dbName: string): IGpSQLBuilder;
    function  &On(const expression: string): IGpSQLBuilder; overload;
    function  &On(const expression: array of const): IGpSQLBuilder; overload;
    function  &Or(const expression: array of const): IGpSQLBuilder; overload;
    function  &Or(const expression: string): IGpSQLBuilder; overload;
    function  OrderBy(const colName: string = ''): IGpSQLBuilder;
    function  Select(const colName: string = ''): IGpSQLBuilder;
    function  Skip(num: integer): IGpSQLBuilder;
    function  Where(const expression: string = ''): IGpSQLBuilder; overload;
    function  Where(const expression: array of const): IGpSQLBuilder; overload;
    property AsString: string read GetAsString;
    property Section[sqlSection: TGpSQLSection]: IGpSQLBuilderSection read GetSection; default;
  end; { TGpSQLBuilder }

{ exports }

function CreateGpSQLBuilder: IGpSQLBuilder;
begin
  Result := TGpSQLBuilder.Create;
end; { CreateGpSQLBuilder }

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

{ TGpSQLBuilderSection }

procedure TGpSQLBuilderSection.Add(const params: array of const; paramType: TGpSQLStringType);
var
  sParams: string;
begin
  if paramType = stOr then begin
    if not FIsAndExpr then
      raise Exception.Create('TGpSQLBuilderSection: OrE without preceding AndE');
    if not FInsertedParen then begin
      Insert('(', FAsString, FLastAndInsertion);
      FInsertedParen := true;
    end
    else
      Delete(FAsString, Length(FAsString), 1);
  end;
  if FIsAndExpr and (paramType = stAnd) then
    FAsString := SqlParamsToStr([FAsString, 'AND']);
  if paramType = stAnd then begin
    FLastAndInsertion := Length(FAsString) + 2; // +1 because we will insert '(' _after_ the last character and +1 because query builder will append ' ' to 'AND' in the next step
    FInsertedParen := false;
  end;
  if FIsList and (paramType = stList) then
    FAsString := SqlParamsToStr([FAsString, ',']);
  sParams := SqlParamsToStr(params);
  if paramType = stOr then
    FAsString := SqlParamsToStr([FAsString, 'OR', sParams, ')'])
  else
    FAsString := SqlParamsToStr([FAsString, sParams]);
  if not (paramType in [stAppend, stOr]) then begin
    FIsAndExpr := (paramType = stAnd);
    FIsList := (paramType = stList);
  end;
end; { TGpSQLBuilderSection.Add }

procedure TGpSQLBuilderSection.Add(const params: string; paramType: TGpSQLStringType);
begin
  Add([params], paramType);
end; { TGpSQLBuilderSection.Add }

procedure TGpSQLBuilderSection.Clear;
begin
  FAsString := '';
  FIsAndExpr := false;
  FIsList := false;
end; { TGpSQLBuilderSection.Clear }

function TGpSQLBuilderSection.GetAsString: string;
begin
  Result := FAsString;
end; { TGpSQLBuilderSection.GetAsString }

{ TGpSQLBuilderCase }

constructor TGpSQLBuilderCase.Create(const sqlBuilder: IGpSQLBuilder;
  const expression: string);
begin
  inherited Create;
  FSQLBuilder := sqlBuilder;
  FCaseExpression := expression;
  FWhenList := TList<TPair<IGpSQLBuilderSection,string>>.Create;
end; { TGpSQLBuilderCase.Create }

destructor TGpSQLBuilderCase.Destroy;
begin
  FreeAndNil(FWhenList);
  inherited;
end; { TGpSQLBuilderCase.Destroy }

function TGpSQLBuilderCase.&And(const expression: array of const): IGpSQLBuilderCase;
begin
  Result := &And(SqlParamsToStr(expression));
end; { TGpSQLBuilder.&And }

function TGpSQLBuilderCase.&And(const expression: string): IGpSQLBuilderCase;
begin
  FActiveSection.Add(['(', expression, ')'], stAnd);
  Result := Self;
end; { TGpSQLBuilder.&And }

function TGpSQLBuilderCase.&Else(const value: string): IGpSQLBuilderCase;
begin
  FElseValue := value;
  FHasElse := true;
  Result := Self;
end; { TGpSQLBuilderCase }

function TGpSQLBuilderCase.&End: IGpSQLBuilder;
begin
  FSQLBuilder.ActiveSection.Add(AsString, stList);
  Result := FSQLBuilder;
end; { TGpSQLBuilderCase }

function TGpSQLBuilderCase.GetAsString: string;
var
  kv: TPair<IGpSQLBuilderSection,string>;
begin
  Result := 'CASE ';
  if FCaseExpression <> '' then
    Result := Result + FCaseExpression + ' ';
  for kv in FWhenList do
    Result := Result + 'WHEN ' + kv.Key.AsString + ' THEN ' + kv.Value + ' ';
  if FHasElse then
    Result := Result + 'ELSE ' + FElseValue + ' ';
  Result := Result + 'END';
end; { TGpSQLBuilderCase.GetAsString }

function TGpSQLBuilderCase.&Or(const expression: array of const): IGpSQLBuilderCase;
begin
  Result := &Or(SqlParamsToStr(expression));
end; {  TGpSQLBuilder.&Or}

function TGpSQLBuilderCase.&Or(const expression: string): IGpSQLBuilderCase;
begin
  FActiveSection.Add(['(', expression, ')'], stOr);
  Result := Self;
end; { TGpSQLBuilder.&Or }

function TGpSQLBuilderCase.&Then(const value: string): IGpSQLBuilderCase;
begin
  FWhenList[FWhenList.Count - 1] :=
    TPair<IGpSQLBuilderSection,string>.Create(
      FWhenList[FWhenList.Count - 1].Key,
      value);
  Result := Self;
end; { TGpSQLBuilderCase }

function TGpSQLBuilderCase.When(const condition: array of const): IGpSQLBuilderCase;
begin
  Result := When(SqlParamsToStr(condition));
end; { TGpSQLBuilderCase.When }

function TGpSQLBuilderCase.When(const condition: string): IGpSQLBuilderCase;
begin
  FActiveSection := TGpSQLBuilderSection.Create;
  FWhenList.Add(TPair<IGpSQLBuilderSection,string>.Create(FActiveSection, ''));
  if condition = '' then
    Result := Self
  else
    Result := &And(condition);
end; { TGpSQLBuilderCase.When }

{ TGpSQLBuilder }

constructor TGpSQLBuilder.Create;
var
  section: TGpSQLSection;
begin
  inherited;
  for section := Low(TGpSQLSection) to High(TGpSQLSection) do
    FSections[section] := TGpSQLBuilderSection.Create;
end; { TGpSQLBuilder.Create }

function TGpSQLBuilder.All: IGpSQLBuilder;
begin
  Result := Column('*');
end; { TGpSQLBuilder.All }

function TGpSQLBuilder.&And(const expression: array of const): IGpSQLBuilder;
begin
  Result := &And(SqlParamsToStr(expression));
end; { TGpSQLBuilder.&And }

function TGpSQLBuilder.&And(const expression: string): IGpSQLBuilder;
begin
  FActiveSection.Add(['(', expression, ')'], stAnd);
  Result := Self;
end; { TGpSQLBuilder.&And }

function TGpSQLBuilder.&As(const alias: string): IGpSQLBuilder;
begin
  AssertSection([secSelect, secFrom, secLeftJoin]);
  FActiveSection.Add(['AS', alias], stAppend);
  Result := Self;
end; { TGpSQLBuilder.&As}

procedure TGpSQLBuilder.AssertSection(section: TGpSQLSection);
begin
  if FActiveSection <> FSections[section] then
    raise Exception.Create('TGpSQLBuilder: Wrong time and place');
end; { TGpSQLBuilder.AssertSection }

procedure TGpSQLBuilder.AssertSection(sections: TGpSQLSections);
var
  section: TGpSQLSection;
begin
  for section := Low(TGpSQLSection) to High(TGpSQLSection) do
    if (section in sections) and (FSections[section] = FActiveSection) then
      Exit;
  raise Exception.Create('TGpSQLBuilder: Wrong time and place');
end; { TGpSQLBuilder.AssertSection }

function TGpSQLBuilder.ActiveSection: IGpSQLBuilderSection;
begin
  Result := FActiveSection;
end; { TGpSQLBuilder.ActiveSection }

function TGpSQLBuilder.&Case(const expression: string = ''): IGpSQLBuilderCase;
begin
  Result := TGpSQLBuilderCase.Create(Self, expression);
end; { TGpSQLBuilder }

function TGpSQLBuilder.&Case(const expression: array of const): IGpSQLBuilderCase;
begin
  Result := &Case(SqlParamsToStr(expression));
end; { TGpSQLBuilder }

function TGpSQLBuilder.Clear: IGpSQLBuilder;
begin
  FActiveSection.Clear;
  Result := Self;
end; { TGpSQLBuilder.Clear }

function TGpSQLBuilder.ClearAll: IGpSQLBuilder;
var
  section: TGpSQLSection;
begin
  for section := Low(TGpSQLSection) to High(TGpSQLSection) do
    FSections[section].Clear;
  Result := Self;
end; { TGpSQLBuilder.ClearAll }

function TGpSQLBuilder.Column(const colName: string): IGpSQLBuilder;
begin
  FActiveSection.Add(colName, stList);
  Result := Self;
end; { TGpSQLBuilder.Column }

function TGpSQLBuilder.Column(const dbName, colName: string): IGpSQLBuilder;
begin
  FActiveSection.Add([dbName, '.', colName], stList);
  Result := Self;
end; { TGpSQLBuilder.Column }

function TGpSQLBuilder.Column(const colName: array of const): IGpSQLBuilder;
begin
  Result := Column(SqlParamsToStr(colName));
end; { TGpSQLBuilder.Column }

function TGpSQLBuilder.Desc: IGpSQLBuilder;
begin
  FActiveSection.Add('DESC', stAppend);
  Result := Self;
end; { TGpSQLBuilder.Desc }

function TGpSQLBuilder.First(num: integer): IGpSQLBuilder;
begin
  AssertSection(secSelect);
  FActiveSection.Add(['FIRST', num]);
  Result := Self;
end; { TGpSQLBuilder.First }

function TGpSQLBuilder.From(const dbName: string): IGpSQLBuilder;
begin
  FActiveSection := FSections[secFrom];
  FActiveSection.Add(dbName, stList);
  Result := Self;
end; { TGpSQLBuilder.From }

function TGpSQLBuilder.GetAsString: string;
var
  sect: TGpSQLSection;
begin
  Result := '';
  for sect := Low(TGpSQLSection) to High(TGpSQLSection) do begin
    if FSections[sect].AsString <> '' then begin
      if Result <> '' then
        Result := Result + ' ';
      Result := Result + FSectionNames[sect] + ' ' + FSections[sect].AsString;
    end;
  end;
end; { TGpSQLBuilder.GetAsString }

function TGpSQLBuilder.GetSection(sqlSection: TGpSQLSection): IGpSQLBuilderSection;
begin
  Result := FSections[sqlSection];
end; { TGpSQLBuilder.GetSection }

function TGpSQLBuilder.GroupBy(const colName: string): IGpSQLBuilder;
begin
  FActiveSection := FSections[secGroupBy];
  if colName = '' then
    Result := Self
  else
    Result := Column(colName);
end; { TGpSQLBuilder.GroupBy }

function TGpSQLBuilder.Having(const expression: string): IGpSQLBuilder;
begin
  FActiveSection := FSections[secHaving];
  if expression = '' then
    Result := Self
  else
    Result := &And(expression);
end; { TGpSQLBuilder.Having }

function TGpSQLBuilder.Having(const expression: array of const): IGpSQLBuilder;
begin
  Result := Having(SqlParamsToStr(expression));
end; { TGpSQLBuilder.Having }

function TGpSQLBuilder.IsEmpty: boolean;
begin
  Result := (FActiveSection.AsString = '');
end; { TGpSQLBuilder.IsEmpty }

function TGpSQLBuilder.LeftJoin(const dbName: string): IGpSQLBuilder;
begin
  FActiveSection := FSections[secLeftJoin];
  if (FActiveSection.AsString <> '') then // previous LEFT JOIN content
    FActiveSection.Add(FSectionNames[secLeftJoin]);
  FActiveSection.Add([dbName, 'ON']);
  Result := Self;
end; { TGpSQLBuilder.LeftJoin }

function TGpSQLBuilder.&On(const expression: string): IGpSQLBuilder;
begin
  Result := &And(expression);
end; { TGpSQLBuilder }

function TGpSQLBuilder.&On(const expression: array of const): IGpSQLBuilder;
begin
  Result := &On(SqlParamsToStr(expression));
end; { TGpSQLBuilder }

function TGpSQLBuilder.OrderBy(const colName: string): IGpSQLBuilder;
begin
  FActiveSection := FSections[secOrderBy];
  if colName = '' then
    Result := Self
  else
    Result := Column(colName);
end; { TGpSQLBuilder.OrderBy }

function TGpSQLBuilder.&Or(const expression: array of const): IGpSQLBuilder;
begin
  Result := &Or(SqlParamsToStr(expression));
end; { TGpSQLBuilder.&Or }

function TGpSQLBuilder.&Or(const expression: string): IGpSQLBuilder;
begin
  FActiveSection.Add(['(', expression, ')'], stOr);
  Result := Self;
end; { TGpSQLBuilder.&Or }

function TGpSQLBuilder.Select(const colName: string): IGpSQLBuilder;
begin
  FActiveSection := FSections[secSelect];
  if colName = '' then
    Result := Self
  else
    Result := Column(colName);
end; { TGpSQLBuilder.Select }

function TGpSQLBuilder.Skip(num: integer): IGpSQLBuilder;
begin
  AssertSection(secSelect);
  FActiveSection.Add(['SKIP', num]);
  Result := Self;
end; { TGpSQLBuilder.Skip }

function TGpSQLBuilder.Where(const expression: string): IGpSQLBuilder;
begin
  FActiveSection := FSections[secWhere];
  if expression = '' then
    Result := Self
  else
    Result := &And(expression);
end; { TGpSQLBuilder.Where }

function TGpSQLBuilder.Where(const expression: array of const): IGpSQLBuilder;
begin
  Result := Where(SqlParamsToStr(expression));
end; { TGpSQLBuilder.Where }

end.
