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
///   Last modification : 2015-04-20
///   Version           : 3.0
///</para><para>
///   History:
///     3.0:
///       - Internal redesign: SQL is generated as an abstract syntax tree and only
///         converted to text when AsString is called. This allows implementing the
///         'pretty print' function and makes the code less ugly.
///     2.02a: 2015-04-20
///       - Corrected SQL generation for LeftJoin().&As() construct.
///     2.02: 2015-04-05
///       - Reimplemented old .Subquery mechanism as .Expression: IGpSQLBuilderExpression.
///       - Added &And and &Or overloads accepting IGpSQLBuilderExpression.
///     2.01: 2015-04-05
///       - Added integer-accepting overloads for IGpSQLBuilderCase.&Then and .&Else.
///     2.0: 2015-04-04
///       - Removed AndE and OrE aliases.
///       - Removed Column overload which accepted 'alias' parameter.
///       - Removed 'dbAlias' parameter from From and LeftJoin methods.
///       - Removed 'subquery' concept as it was not really useful.
///       - Renamed AllColumns to All.
///       - Renamed AsAlias to &As.
///       - IGpSQLBuilderCase.&Then and .&Else values are not automatically quoted.
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

uses
  GpSQLBuilder.AST;

type
  IGpSQLBuilder = interface;

  IGpSQLBuilderExpression = interface ['{CC7ED7A2-3B39-4341-9CBB-EE1C7851BBA9}']
    function  GetAsString: string;
  //
    function  &And(const expression: array of const): IGpSQLBuilderExpression; overload;
    function  &And(const expression: string): IGpSQLBuilderExpression; overload;
    function  &Or(const expression: array of const): IGpSQLBuilderExpression; overload;
    function  &Or(const expression: string): IGpSQLBuilderExpression; overload;
    property AsString: string read GetAsString;
  end; { IGpSQLBuilderExpression }

  IGpSQLBuilderCase = interface ['{1E379718-0959-455A-80AA-63BDA7C92F8C}']
    function  GetAsString: string;
  //
    function  &And(const expression: array of const): IGpSQLBuilderCase; overload;
    function  &And(const expression: string): IGpSQLBuilderCase; overload;
    function  &And(const expression: IGpSQLBuilderExpression): IGpSQLBuilderCase; overload;
    function  &Else(const value: string): IGpSQLBuilderCase; overload;
    function  &Else(const value: int64): IGpSQLBuilderCase; overload;
    function  &End: IGpSQLBuilder;
    function  &Or(const expression: array of const): IGpSQLBuilderCase; overload;
    function  &Or(const expression: string): IGpSQLBuilderCase; overload;
    function  &Or(const expression: IGpSQLBuilderExpression): IGpSQLBuilderCase; overload;
    function  &Then(const value: string): IGpSQLBuilderCase; overload;
    function  &Then(const value: int64): IGpSQLBuilderCase; overload;
    function  When(const condition: string): IGpSQLBuilderCase; overload;
    function  When(const condition: array of const): IGpSQLBuilderCase; overload;
    function Expression: IGpSQLBuilderExpression;
    property AsString: string read GetAsString;
  end; { IGpSQLBuilderCase }

  IGpSQLBuilder = interface ['{43EA3E34-A8DB-4257-A19F-030F404646E7}']
    function GetAsString: string;
    function GetAST: IGpSQLAST;
  //
    function &And(const expression: array of const): IGpSQLBuilder; overload;
    function &And(const expression: string): IGpSQLBuilder; overload;
    function &And(const expression: IGpSQLBuilderExpression): IGpSQLBuilder; overload;
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
    function &Or(const expression: IGpSQLBuilderExpression): IGpSQLBuilder; overload;
    function OrderBy(const colName: string = ''): IGpSQLBuilder;
    function Select(const colName: string = ''): IGpSQLBuilder;
    function Skip(num: integer): IGpSQLBuilder;
    function Where(const expression: string = ''): IGpSQLBuilder; overload;
    function Where(const expression: array of const): IGpSQLBuilder; overload;
  //
    function Clear: IGpSQLBuilder;
    function ClearAll: IGpSQLBuilder;
    function Expression(const term: string = ''): IGpSQLBuilderExpression; overload;
    function Expression(const term: array of const): IGpSQLBuilderExpression; overload;
    function IsEmpty: boolean;
    property AsString: string read GetAsString;
    property AST: IGpSQLAST read GetAST;
  end; { IGpSQLBuilder }

function CreateGpSQLBuilder: IGpSQLBuilder;

implementation

uses
  System.SysUtils,
  System.StrUtils,
  System.Generics.Collections,
  GpSQLBuilder.Serialize;

type
  // TODO -oPrimoz Gabrijelcic : do we need it?
  IGpSQLBuilderEx = interface ['{9F70DAA3-0900-4DFD-B967-C56D23513609}']
//    function  ActiveSection: IGpSQLSection;
  end; { IGpSQLBuilderEx }

  TGpSQLBuilderExpression = class(TInterfacedObject, IGpSQLBuilderExpression)
  strict private
    FActiveSection : IGpSQLSection;
  strict protected
    function  GetAsString: string;
  public
    constructor Create(const expression: string = '');
    function  &And(const expression: array of const): IGpSQLBuilderExpression; overload;
    function  &And(const expression: string): IGpSQLBuilderExpression; overload;
    function  &Or(const expression: array of const): IGpSQLBuilderExpression; overload;
    function  &Or(const expression: string): IGpSQLBuilderExpression; overload;
    property AsString: string read GetAsString;
  end; { TGpSQLBuilderExpression }

  TGpSQLBuilderCase = class(TInterfacedObject, IGpSQLBuilderCase)
  strict private
    FActiveSection : IGpSQLSection;
    FCaseExpression: string;
    FElseValue     : string;
    FHasElse       : boolean;
    FSQLBuilder    : IGpSQLBuilder;
    FWhenList      : TList<TPair<IGpSQLSection,string>>;
  strict protected
    function  GetAsString: string;
  public
    constructor Create(const sqlBuilder: IGpSQLBuilder; const expression: string);
    destructor  Destroy; override;
    function  &And(const expression: array of const): IGpSQLBuilderCase; overload;
    function  &And(const expression: string): IGpSQLBuilderCase; overload;
    function  &And(const expression: IGpSQLBuilderExpression): IGpSQLBuilderCase; overload;
    function  &Else(const value: string): IGpSQLBuilderCase; overload;
    function  &Else(const value: int64): IGpSQLBuilderCase; overload;
    function  &End: IGpSQLBuilder;
    function  Expression: IGpSQLBuilderExpression;
    function  &Or(const expression: array of const): IGpSQLBuilderCase; overload;
    function  &Or(const expression: string): IGpSQLBuilderCase; overload;
    function  &Or(const expression: IGpSQLBuilderExpression): IGpSQLBuilderCase; overload;
    function  &Then(const value: string): IGpSQLBuilderCase; overload;
    function  &Then(const value: int64): IGpSQLBuilderCase; overload;
    function  When(const condition: string): IGpSQLBuilderCase; overload;
    function  When(const condition: array of const): IGpSQLBuilderCase; overload;
    property AsString: string read GetAsString;
  end; { TGpSQLBuilderCase }

  TGpSQLBuilder = class(TInterfacedObject, IGpSQLBuilder, IGpSQLBuilderEx)
  strict private
  type
    TGpSQLSection = (secSelect, secJoin, secWhere, secGroupBy, secHaving, secOrderBy);
    TGpSQLSections = set of TGpSQLSection;
  var
    FActiveSection: TGpSQLSection;
    FAST          : IGpSQLAST;
    FASTColumns   : IGpSQLColumns;
    FASTSection   : IGpSQLSection;
    FASTName      : IGpSQLName;
  strict protected
    procedure AssertHaveName;
    procedure AssertSection(sections: TGpSQLSections);
//    procedure AssertPart(parts: TGpSQLParts);
    function  GetAsString: string;
    function  GetAST: IGpSQLAST;
    procedure SelectSection(section: TGpSQLSection);
  public
    constructor Create;
    function  &And(const expression: array of const): IGpSQLBuilder; overload;
    function  &And(const expression: string): IGpSQLBuilder; overload;
    function  &And(const expression: IGpSQLBuilderExpression): IGpSQLBuilder; overload;
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
    function  Expression(const term: string = ''): IGpSQLBuilderExpression; overload;
    function  Expression(const term: array of const): IGpSQLBuilderExpression; overload;
    function  First(num: integer): IGpSQLBuilder;
    function  From(const dbName: string): IGpSQLBuilder;
    function  GroupBy(const colName: string = ''): IGpSQLBuilder;
    function  Having(const expression: string = ''): IGpSQLBuilder; overload;
    function  Having(const expression: array of const): IGpSQLBuilder; overload;
    function  IsEmpty: boolean;
    // TODO -oPrimoz Gabrijelcic : Add other joins
    function  LeftJoin(const dbName: string): IGpSQLBuilder;
    function  &On(const expression: string): IGpSQLBuilder; overload;
    function  &On(const expression: array of const): IGpSQLBuilder; overload;
    function  &Or(const expression: array of const): IGpSQLBuilder; overload;
    function  &Or(const expression: string): IGpSQLBuilder; overload;
    function  &Or(const expression: IGpSQLBuilderExpression): IGpSQLBuilder; overload;
    function  OrderBy(const colName: string = ''): IGpSQLBuilder;
    function  Select(const colName: string = ''): IGpSQLBuilder;
    function  Skip(num: integer): IGpSQLBuilder;
    function  Where(const expression: string = ''): IGpSQLBuilder; overload;
    function  Where(const expression: array of const): IGpSQLBuilder; overload;
    property AsString: string read GetAsString;
    property AST: IGpSQLAST read GetAST;
  end; { TGpSQLBuilder }

{ exports }

function CreateGpSQLBuilder: IGpSQLBuilder;
begin
  Result := TGpSQLBuilder.Create;
end; { CreateGpSQLBuilder }

{ TGpSQLBuilderCase }

constructor TGpSQLBuilderCase.Create(const sqlBuilder: IGpSQLBuilder;
  const expression: string);
begin
  inherited Create;
  FSQLBuilder := sqlBuilder;
  FCaseExpression := expression;
  FWhenList := TList<TPair<IGpSQLSection,string>>.Create;
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
  // TODO -oPrimoz Gabrijelcic : implement: TGpSQLBuilderCase
//  FActiveSection.Add(['(', expression, ')'], stAnd);
  Result := Self;
end; { TGpSQLBuilder.&And }

function TGpSQLBuilderCase.&And(const expression: IGpSQLBuilderExpression):
  IGpSQLBuilderCase;
begin
  Result := &And(expression.AsString);
end; { TGpSQLBuilderCase }

function TGpSQLBuilderCase.&Else(const value: string): IGpSQLBuilderCase;
begin
  FElseValue := value;
  FHasElse := true;
  Result := Self;
end; { TGpSQLBuilderCase }

function TGpSQLBuilderCase.&Else(const value: int64): IGpSQLBuilderCase;
begin
  Result := &Else(IntToStr(value));
end; { TGpSQLBuilderCase }

function TGpSQLBuilderCase.&End: IGpSQLBuilder;
begin
  // TODO -oPrimoz Gabrijelcic : implement: TGpSQLBuilderCase
//  (FSQLBuilder as IGpSQLBuilderEx).ActiveSection.Add(AsString, stList);
  Result := FSQLBuilder;
end; { TGpSQLBuilderCase }

function TGpSQLBuilderCase.GetAsString: string;
//var
//  kv: TPair<IGpSQLSection,string>;
begin
  // TODO -oPrimoz Gabrijelcic : Remove
//  Result := 'CASE ';
//  if FCaseExpression <> '' then
//    Result := Result + FCaseExpression + ' ';
//  for kv in FWhenList do
//    Result := Result + 'WHEN ' + kv.Key.AsString + ' THEN ' + kv.Value + ' ';
//  if FHasElse then
//    Result := Result + 'ELSE ' + FElseValue + ' ';
//  Result := Result + 'END';
end; { TGpSQLBuilderCase.GetAsString }

function TGpSQLBuilderCase.&Or(const expression: array of const): IGpSQLBuilderCase;
begin
  Result := &Or(SqlParamsToStr(expression));
end; {  TGpSQLBuilder.&Or}

function TGpSQLBuilderCase.&Or(const expression: string): IGpSQLBuilderCase;
begin
  // TODO -oPrimoz Gabrijelcic : implement: TGpSQLBuilderCase
//  FActiveSection.Add(['(', expression, ')'], stOr);
  Result := Self;
end; { TGpSQLBuilder.&Or }

function TGpSQLBuilderCase.&Or(const expression: IGpSQLBuilderExpression):
  IGpSQLBuilderCase;
begin
  Result := &Or(expression.AsString);
end; { TGpSQLBuilderCase }

function TGpSQLBuilderCase.&Then(const value: string): IGpSQLBuilderCase;
begin
  FWhenList[FWhenList.Count - 1] :=
    TPair<IGpSQLSection,string>.Create(
      FWhenList[FWhenList.Count - 1].Key,
      value);
  Result := Self;
end; { TGpSQLBuilderCase }

function TGpSQLBuilderCase.&Then(const value: int64): IGpSQLBuilderCase;
begin
  Result := &Then(IntToStr(value));
end; { TGpSQLBuilderCase }

function TGpSQLBuilderCase.Expression: IGpSQLBuilderExpression;
begin
  Result := TGpSQLBuilderExpression.Create;
end; { TGpSQLBuilderCase.Expression }

function TGpSQLBuilderCase.When(const condition: array of const): IGpSQLBuilderCase;
begin
  Result := When(SqlParamsToStr(condition));
end; { TGpSQLBuilderCase.When }

function TGpSQLBuilderCase.When(const condition: string): IGpSQLBuilderCase;
begin
  // TODO -oPrimoz Gabrijelcic : implement: TGpSQLBuilderCase.When
//  FActiveSection := CreateSQLSection(secSelect); // TODO -oPrimoz Gabrijelcic : stopgap solution
//  FWhenList.Add(TPair<IGpSQLSection,string>.Create(FActiveSection, ''));
//  if condition = '' then
//    Result := Self
//  else
//    Result := &And(condition);
end; { TGpSQLBuilderCase.When }

{ TGpSQLBuilderExpression }

constructor TGpSQLBuilderExpression.Create(const expression: string);
begin
  // TODO -oPrimoz Gabrijelcic : implement: TGpSQLBuilderExpression.Create
//  FActiveSection := CreateSQLSection(secSelect); // TODO 1 -oPrimoz Gabrijelcic : stopgap solution
//  if expression <> '' then
//    &And(expression);
end; { TGpSQLBuilderExpression.Create }

function TGpSQLBuilderExpression.&And(const expression: string): IGpSQLBuilderExpression;
begin
  // TODO -oPrimoz Gabrijelcic : implement: TGpSQLBuilderExpression
//  FActiveSection.Add(['(', expression, ')'], stAnd);
  Result := Self;
end; { TGpSQLBuilderExpression }

function TGpSQLBuilderExpression.&And(
  const expression: array of const): IGpSQLBuilderExpression;
begin
  Result := &And(SqlParamsToStr(expression));
end; { TGpSQLBuilderExpression }

function TGpSQLBuilderExpression.GetAsString: string;
begin
  // TODO -oPrimoz Gabrijelcic : Remove
//  Result := FActiveSection.AsString;
end; { TGpSQLBuilderExpression.GetAsString }

function TGpSQLBuilderExpression.&Or(const expression: string): IGpSQLBuilderExpression;
begin
  // TODO 1 -oPrimoz Gabrijelcic : implement: TGpSQLBuilderExpression
//  FActiveSection.Add(['(', expression, ')'], stOr);
  Result := Self;
end; { TGpSQLBuilderExpression }

function TGpSQLBuilderExpression.&Or(const expression: array of const): IGpSQLBuilderExpression;
begin
  Result := &Or(SqlParamsToStr(expression));
end; { TGpSQLBuilderExpression }

{ TGpSQLBuilder }

constructor TGpSQLBuilder.Create;
begin
  inherited;
  FAST := CreateSQLAST;
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
  // TODO 1 -oPrimoz Gabrijelcic : implement: TGpSQLBuilder
//  FActiveSection.Add(['(', expression, ')'], stAnd);
  Result := Self;
end; { TGpSQLBuilder.&And }

function TGpSQLBuilder.&And(const expression: IGpSQLBuilderExpression): IGpSQLBuilder;
begin
  Result := &And(expression.AsString);
end; { TGpSQLBuilder }

function TGpSQLBuilder.&As(const alias: string): IGpSQLBuilder;
var
  columns   : IGpSQLColumns;
  pushBefore: string;
begin
  AssertSection([secSelect, secJoin]);
  AssertHaveName;

  FASTName.Alias := alias;
  Result := Self;
end; { TGpSQLBuilder.&As }

procedure TGpSQLBuilder.AssertHaveName;
begin
  if not assigned(FASTName) then
    raise Exception.Create('TGpSQLBuilder: Curernt name is not set');
end; { TGpSQLBuilder.AssertHaveName }

procedure TGpSQLBuilder.AssertSection(sections: TGpSQLSections);
begin
  if not (FActiveSection in sections) then
    raise Exception.Create('TGpSQLBuilder: Not supported in this section');
end; { TGpSQLBuilder.AssertSection }

//procedure TGpSQLBuilder.AssertPart(parts: TGpSQLParts);
//begin
//  if not (FLastPart in parts) then
//    raise Exception.Create('TGpSQLBuilder: Not supported in this part');
//end; { TGpSQLBuilder.AssertPart }

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
  // TODO -oPrimoz Gabrijelcic : implement: TGpSQLBuilder.Clear
//  FActiveSection.Clear;
  Result := Self;
end; { TGpSQLBuilder.Clear }

function TGpSQLBuilder.ClearAll: IGpSQLBuilder;
var
  section: TGpSQLSection;
begin
  // TODO -oPrimoz Gabrijelcic : implement: TGpSQLBuilder.ClearAll
//  for section := Low(TGpSQLSection) to High(TGpSQLSection) do
//    AST[section].Clear;
  Result := Self;
end; { TGpSQLBuilder.ClearAll }

function TGpSQLBuilder.Column(const colName: string): IGpSQLBuilder;
begin
  if assigned(FASTColumns) then begin
    FASTName := CreateSQLName;
    FASTName.Name := colName;
    FASTColumns.Add(FASTName);
  end
  else
    raise Exception.CreateFmt('Current section [%s] does not support COLUMN.',
      [FASTSection.Name]);
  Result := Self;
end; { TGpSQLBuilder.Column }

function TGpSQLBuilder.Column(const dbName, colName: string): IGpSQLBuilder;
begin
  Result := Column(dbName + '.' + colName);
end; { TGpSQLBuilder.Column }

function TGpSQLBuilder.Column(const colName: array of const): IGpSQLBuilder;
begin
  Result := Column(SqlParamsToStr(colName));
end; { TGpSQLBuilder.Column }

function TGpSQLBuilder.Desc: IGpSQLBuilder;
begin
// TODO -oPrimoz Gabrijelcic :
//  FActiveSection.Add('DESC', stAppend);
  Result := Self;
end; { TGpSQLBuilder.Desc }

function TGpSQLBuilder.Expression(const term: string): IGpSQLBuilderExpression;
begin
  Result := TGpSQLBuilderExpression.Create(term);
end; { TGpSQLBuilder.Expression }

function TGpSQLBuilder.Expression(const term: array of const): IGpSQLBuilderExpression;
begin
  Result := Expression(SqlParamsToStr(term));
end; { TGpSQLBuilder.Expression }

function TGpSQLBuilder.First(num: integer): IGpSQLBuilder;
var
  qual: IGpSQLSelectQualifier;
begin
  AssertSection([secSelect]);
  qual := CreateSQLSelectQualifier;
  qual.Qualifier := sqFirst;
  qual.Value := num;
  (FASTSection as IGpSQLSelect).Qualifiers.Add(qual);
  Result := Self;
end; { TGpSQLBuilder.First }

function TGpSQLBuilder.From(const dbName: string): IGpSQLBuilder;
begin
  AssertSection([secSelect]);
  FASTName := (FASTSection as IGpSQLSelect).TableName;
  FASTName.Name := dbName;
  Result := Self;
end; { TGpSQLBuilder.From }

function TGpSQLBuilder.GetAsString: string;
begin
  Result := CreateSQLSerializer(AST).AsString;
end; { TGpSQLBuilder.GetAsString }

function TGpSQLBuilder.GroupBy(const colName: string): IGpSQLBuilder;
begin
  SelectSection(secGroupBy);
  if colName = '' then
    Result := Self
  else
    Result := Column(colName);
end; { TGpSQLBuilder.GroupBy }

function TGpSQLBuilder.Having(const expression: string): IGpSQLBuilder;
begin
  SelectSection(secHaving);
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
// TODO -oPrimoz Gabrijelcic : implement: TGpSQLBuilder.IsEmpty
//  Result := FASTSection.IsEmpty;
end; { TGpSQLBuilder.IsEmpty }

function TGpSQLBuilder.LeftJoin(const dbName: string): IGpSQLBuilder;
var
  join: IGpSQLJoin;
begin
  FActiveSection := secJoin;
  join := CreateSQLJoin;
  join.JoinType := jtLeft;
  FASTName := join.JoinedTable;
  FASTName.Name := dbName;
  FAST.Joins.Add(join);
  FASTSection := join;
  FASTColumns := nil;
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
  SelectSection(secOrderBy);
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
  // TODO -oPrimoz Gabrijelcic : implement: TGpSQLBuilder
//  FActiveSection.Add(['(', expression, ')'], stOr);
  Result := Self;
end; { TGpSQLBuilder.&Or }

function TGpSQLBuilder.&Or(const expression: IGpSQLBuilderExpression): IGpSQLBuilder;
begin
  Result := &Or(expression.AsString);
end; { TGpSQLBuilder }

function TGpSQLBuilder.GetAST: IGpSQLAST;
begin
  Result := FAST;
end; { TGpSQLBuilder.GetAST }

function TGpSQLBuilder.Select(const colName: string): IGpSQLBuilder;
begin
  SelectSection(secSelect);
  if colName = '' then
    Result := Self
  else
    Result := Column(colName);
end; { TGpSQLBuilder.Select }

procedure TGpSQLBuilder.SelectSection(section: TGpSQLSection);
begin
  case section of
    secSelect:
      begin
        FASTSection := FAST.Select;
        FASTColumns := FAST.Select.Columns;
      end;
    secWhere:
      begin
        FASTSection := FAST.Where;
        FASTColumns := nil;
      end;
    secGroupBy:
      begin
        FASTSection := FAST.GroupBy;
        FASTColumns := FAST.GroupBy.Columns;
      end;
    secHaving:
      begin
        FASTSection := FAST.Having;
        FASTColumns := nil;
      end;
    secOrderBy:
      begin
        FASTSection := FAST.OrderBy;
        FASTColumns := FAST.OrderBy.Columns;
      end;
    else raise Exception.Create('TGpSQLBuilder.SelectSection: Unknown section');
  end;
  FActiveSection := section;
end; { TGpSQLBuilder.SelectSection }

function TGpSQLBuilder.Skip(num: integer): IGpSQLBuilder;
var
  qual: IGpSQLSelectQualifier;
begin
  AssertSection([secSelect]);
  qual := CreateSQLSelectQualifier;
  qual.Qualifier := sqSkip;
  qual.Value := num;
  (FASTSection as IGpSQLSelect).Qualifiers.Add(qual);
  Result := Self;
end; { TGpSQLBuilder.Skip }

function TGpSQLBuilder.Where(const expression: string): IGpSQLBuilder;
begin
  SelectSection(secWhere);
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
