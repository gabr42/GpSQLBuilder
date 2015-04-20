///<summary>Abstract syntax tree for the SQL query builder.</summary>
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
///   History:
///</para></remarks>

unit GpSQLBuilder.AST;

interface

uses
  System.Generics.Collections;

type
  TGpSQLSection = (secSelect, secLeftJoin, secWhere, secGroupBy, secHaving, secOrderBy);
  TGpSQLSections = set of TGpSQLSection;

  TGpSQLStringType = (stNormal, stAnd, stOr, stList, stAppend); // TODO -oPrimoz Gabrijelcic : should not be necessary in 3.0

  IGpSQLName = interface
  ['{B219D388-7E5E-4F71-A1F1-9AE4DDE754BC}']
    function  GetAlias: string;
    function  GetName: string;
    procedure SetAlias(const value: string);
    procedure SetName(const value: string);
  //
    property Name: string read GetName write SetName;
    property Alias: string read GetAlias write SetAlias;
  end; { IGpSQLName }

  IGpSQLColumns = interface
  ['{DA9157F6-3526-4DA4-8CD3-115DFE7719B3}']
    function  GetColumns(idx: integer): IGpSQLName;
  //
    procedure Add(const name: string);
    function  Count: integer;
    property Columns[idx: integer]: IGpSQLName read GetColumns; default;
  end; { IGpSQLColumns }

  IGpSQLSection = interface
  ['{BE0A0FF9-AD70-40C5-A1C2-7FA2F7061153}']
    function  GetAsString: string;
    function  GetSection: TGpSQLSection;
  //
    procedure Add(const params: array of const; paramType: TGpSQLStringType = stNormal;
      const pushBefore: string = ''); overload;
    procedure Add(const params: string; paramType: TGpSQLStringType = stNormal;
      const pushBefore: string = ''); overload;
    procedure Clear;
    property AsString: string read GetAsString;
    property Section: TGpSQLSection read GetSection;
  end; { IGpSQLSection }

  TGpSQLSelectQualifierType = (sqFirst, sqSkip);

  IGpSQLSelectQualifier = interface ['{EC0EC192-81C6-493B-B4A7-F8DA7F6D0D4B}']
    function  GetQualifier: TGpSQLSelectQualifierType;
    function  GetValue: integer;
    procedure SetQualifier(const value: TGpSQLSelectQualifierType);
    procedure SetValue(const value: integer);
  //
    property Qualifier: TGpSQLSelectQualifierType read GetQualifier write SetQualifier;
    property Value: integer read GetValue write SetValue;
  end; { IGpSQLSelectQualifier }

  IGpSQLSelectQualifiers = interface ['{522F34BC-C916-45B6-9DC2-E800FEC7661A}']
    function GetQualifier(idx: integer): IGpSQLSelectQualifier;
  //
    procedure Add(qualifier: IGpSQLSelectQualifier);
    function Count: integer;
    property Qualifier[idx: integer]: IGpSQLSelectQualifier read GetQualifier; default;
  end; { IGpSQLSelectQualifiers }

  IGpSQLSelect = interface(IGpSQLSection) ['{6B23B86E-97F3-4D8A-BED5-A678EAEF7842}']
    function  GetQualifiers: IGpSQLSelectQualifiers;
    function  GetTableName: IGpSQLName;
    procedure SetTableName(const value: IGpSQLName);
  //
    property Qualifiers: IGpSQLSelectQualifiers read GetQualifiers;
    property TableName: IGpSQLName read GetTableName write SetTableName;
  end; { IGpSQLSelect }

  IGpSQLAST = interface
    function GetSection(sect: TGpSQLSection): IGpSQLSection;
  //
    property Section[sect: TGpSQLSection]: IGpSQLSection read GetSection; default;
  end; { IGpSQLAST }

  function CreateSQLName: IGpSQLName;
  function CreateSQLColumns: IGpSQLColumns;
  function CreateSQLSection(section: TGpSQLSection): IGpSQLSection;
  function CreateSQLSelectQualifier: IGpSQLSelectQualifier;
  function CreateSQLSelectQualifiers: IGpSQLSelectQualifiers;
  function CreateSQLAST: IGpSQLAST;

implementation

uses
  System.SysUtils,
  System.StrUtils,        // TODO -oPrimoz Gabrijelcic : Temporary, AST must not depend on serialization
  GpSQLBuilder.Serialize; // TODO -oPrimoz Gabrijelcic : Temporary, AST must not depend on serialization

type
  TGpSQLName = class(TInterfacedObject, IGpSQLName)
  strict private
    FAlias: string;
    FName : string;
  strict protected
    function  GetAlias: string;
    function  GetName: string;
    procedure SetAlias(const value: string);
    procedure SetName(const value: string);
  public
    property Name: string read GetName write SetName;
    property Alias: string read GetAlias write SetAlias;
  end; { TGpSQLName }

  TGpSQLColumns = class(TInterfacedObject, IGpSQLColumns)
  strict private
    FColumns: TList<IGpSQLName>;
  strict protected
    function  GetColumns(idx: integer): IGpSQLName;
  public
    constructor Create;
    destructor  Destroy; override;
    procedure Add(const name: string);
    function  Count: integer;
    property Columns[idx: integer]: IGpSQLName read GetColumns; default;
  end; { TGpSQLColumns }

  TGpSQLBaseSection = class(TInterfacedObject, IGpSQLSection)
  strict private
    FAsString        : string;
    FInsertedParen   : boolean;
    FIsAndExpr       : boolean;
    FIsList          : boolean;
    FLastAndInsertion: integer;
    FSection: TGpSQLSection;
  strict protected
    function  GetAsString: string;
    function  GetSection: TGpSQLSection;
  public
    constructor Create(section: TGpSQLSection);
    procedure Add(const params: array of const; paramType: TGpSQLStringType = stNormal;
      const pushBefore: string = ''); overload;
    procedure Add(const params: string; paramType: TGpSQLStringType = stNormal;
      const pushBefore: string = ''); overload;
    procedure Clear;
    property AsString: string read GetAsString;
    property Section: TGpSQLSection read GetSection;
  end; { TGpSQLBaseSection }

  TGpSQLSelectQualifier = class(TInterfacedObject, IGpSQLSelectQualifier)
  strict private
    FQualifier: TGpSQLSelectQualifierType;
    FValue    : integer;
  strict protected
    function  GetQualifier: TGpSQLSelectQualifierType;
    function  GetValue: integer;
    procedure SetQualifier(const value: TGpSQLSelectQualifierType);
    procedure SetValue(const value: integer);
  public
    property Qualifier: TGpSQLSelectQualifierType read GetQualifier write SetQualifier;
    property Value: integer read GetValue write SetValue;
  end; { TGpSQLSelectQualifier }

  TGpSQLSelectQualifiers = class(TInterfacedObject, IGpSQLSelectQualifiers)
  strict private
    FQualifiers: TList<IGpSQLSelectQualifier>;
  strict protected
    function  GetQualifier(idx: integer): IGpSQLSelectQualifier;
  public
    constructor Create;
    destructor  Destroy; override;
    procedure Add(qualifier: IGpSQLSelectQualifier);
    function  Count: integer;
    property Qualifier[idx: integer]: IGpSQLSelectQualifier read GetQualifier; default;
  end; { TGpSQLSelectQualifiers }

  TGpSQLSelect = class(TGpSQLBaseSection, IGpSQLSelect, IGpSQLColumns)
  strict private
    FColumns   : IGpSQLColumns;
    FQualifiers: IGpSQLSelectQualifiers;
    FTableName : IGpSQLName;
  strict protected
    function  GetColumns: IGpSQLColumns;
    function  GetQualifiers: IGpSQLSelectQualifiers;
    function  GetTableName: IGpSQLName;
    procedure SetTableName(const value: IGpSQLName);
  public
    constructor Create;
    property Columns: IGpSQLColumns read FColumns implements IGpSQLColumns;
    property Qualifiers: IGpSQLSelectQualifiers read GetQualifiers;
    property TableName: IGpSQLName read GetTableName write SetTableName;
  end; { IGpSQLSelect }

  TGpSQLAST = class(TInterfacedObject, IGpSQLAST)
  strict private
    FSections: array [TGpSQLSection] of IGpSQLSection;
  strict protected
    function  GetSection(sect: TGpSQLSection): IGpSQLSection; inline;
  public
    constructor Create;
    property Section[sect: TGpSQLSection]: IGpSQLSection read GetSection; default;
  end; { TGpSQLAST }

{ exports }

function CreateSQLName: IGpSQLName;
begin
  Result := TGpSQLName.Create;
end; { CreateSQLName }

function CreateSQLColumns: IGpSQLColumns;
begin
  Result := TGpSQLColumns.Create;
end; { CreateSQLColumns }

function CreateSQLSection(section: TGpSQLSection): IGpSQLSection;
begin
  case section of
    secSelect:   Result := TGpSQLSelect.Create;
    else         Result := TGpSQLBaseSection.Create(section);
  end;
end; { CreateSection }

function CreateSQLSelectQualifier: IGpSQLSelectQualifier;
begin
  Result := TGpSQLSelectQualifier.Create;
end; { CreateSQLSelectQualifier }

function CreateSQLSelectQualifiers: IGpSQLSelectQualifiers;
begin
  Result := TGpSQLSelectQualifiers.Create;
end; { CreateSQLSelectQualifiers }

function CreateSQLAST: IGpSQLAST;
begin
  Result := TGpSQLAST.Create;
end; { CreateSQLAST }

{ TGpSQLName }

function TGpSQLName.GetAlias: string;
begin
  Result := FAlias;
end; { TGpSQLName.GetAlias }

function TGpSQLName.GetName: string;
begin
  Result := FName;
end; { TGpSQLName.GetName }

procedure TGpSQLName.SetAlias(const value: string);
begin
  FAlias := value;
end; { TGpSQLName.SetAlias }

procedure TGpSQLName.SetName(const value: string);
begin
  FName := value;
end; { TGpSQLName.SetName }

{ TGpSQLColumns }

constructor TGpSQLColumns.Create;
begin
  inherited Create;
  FColumns := TList<IGpSQLName>.Create;
end; { TGpSQLColumns.Create }

destructor TGpSQLColumns.Destroy;
begin
  FreeAndNil(FColumns);
  inherited;
end; { TGpSQLColumns.Destroy }

procedure TGpSQLColumns.Add(const name: string);
var
  column: IGpSQLName;
begin
  column := CreateSQLName;
  column.Name := name;
  FColumns.Add(column);
end; { TGpSQLColumns.Add }

function TGpSQLColumns.Count: integer;
begin
  Result := FColumns.Count;
end; { TGpSQLColumns.Count }

function TGpSQLColumns.GetColumns(idx: integer): IGpSQLName;
begin
  Result := FColumns[idx];
end; { TGpSQLColumns.GetColumns }

{ TGpSQLBaseSection }

constructor TGpSQLBaseSection.Create(section: TGpSQLSection);
begin
  inherited Create;
  FSection := section;
end; { TGpSQLBaseSection.Create }

procedure TGpSQLBaseSection.Add(const params: array of const; paramType: TGpSQLStringType;
  const pushBefore: string);
var
  sParams: string;
begin
  if paramType = stOr then begin
    if not FIsAndExpr then
      raise Exception.Create('TGpSQLBaseSection: OrE without preceding AndE');
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
  else if (pushBefore = '') or (not EndsText(pushBefore, FAsString)) then
    FAsString := SqlParamsToStr([FAsString, sParams])
  else begin
    Delete(FAsString, Length(FAsString) - Length(pushBefore) + 1, Length(pushBefore));
    FAsString := SqlParamsToStr([FAsString, sParams, pushBefore]);
  end;
  if not (paramType in [stAppend, stOr]) then begin
    FIsAndExpr := (paramType = stAnd);
    FIsList := (paramType = stList);
  end;
end; { TGpSQLBaseSection.Add }

procedure TGpSQLBaseSection.Add(const params: string; paramType: TGpSQLStringType;
  const pushBefore: string);
begin
  Add([params], paramType, pushBefore);
end; { TGpSQLBaseSection.Add }

procedure TGpSQLBaseSection.Clear;
begin
  FAsString := '';
  FIsAndExpr := false;
  FIsList := false;
end; { TGpSQLBaseSection.Clear }

function TGpSQLBaseSection.GetAsString: string;
begin
  Result := FAsString;
end; { TGpSQLBaseSection.GetAsString }

function TGpSQLBaseSection.GetSection: TGpSQLSection;
begin
  Result := FSection;
end; { TGpSQLBaseSection.GetSection }

{ TGpSQLSelectQualifier }

function TGpSQLSelectQualifier.GetQualifier: TGpSQLSelectQualifierType;
begin
  Result := FQualifier;
end; { TGpSQLSelectQualifier.GetQualifier }

function TGpSQLSelectQualifier.GetValue: integer;
begin
  Result := FValue;
end; { TGpSQLSelectQualifier.GetValue }

procedure TGpSQLSelectQualifier.SetQualifier(const value: TGpSQLSelectQualifierType);
begin
  FQualifier := value;
end; { TGpSQLSelectQualifier.SetQualifier }

procedure TGpSQLSelectQualifier.SetValue(const value: integer);
begin
  FValue := value;
end; { TGpSQLSelectQualifier.SetValue }

{ TGpSQLSelectQualifiers }

constructor TGpSQLSelectQualifiers.Create;
begin
  inherited Create;
  FQualifiers := TList<IGpSQLSelectQualifier>.Create;
end; { TGpSQLSelectQualifiers.Create }

destructor TGpSQLSelectQualifiers.Destroy;
begin
  FreeAndNil(FQualifiers);
  inherited;
end; { TGpSQLSelectQualifiers.Destroy }

procedure TGpSQLSelectQualifiers.Add(qualifier: IGpSQLSelectQualifier);
begin
  FQualifiers.Add(qualifier);
end; { TGpSQLSelectQualifiers.Add }

function TGpSQLSelectQualifiers.Count: integer;
begin
  Result := FQualifiers.Count;
end; { TGpSQLSelectQualifiers.Count }

function TGpSQLSelectQualifiers.GetQualifier(idx: integer): IGpSQLSelectQualifier;
begin
  Result := FQualifiers[idx];
end; { TGpSQLSelectQualifiers.GetQualifier }

{ TGpSQLSelect }

constructor TGpSQLSelect.Create;
begin
  inherited Create(secSelect);
  FColumns := CreateSQLColumns;
  FQualifiers := CreateSQLSelectQualifiers;
  FTableName := CreateSQLName;
end; { TGpSQLSelect.Create }

function TGpSQLSelect.GetColumns: IGpSQLColumns;
begin
  Result := FColumns;
end; { TGpSQLSelect.GetColumns }

function TGpSQLSelect.GetQualifiers: IGpSQLSelectQualifiers;
begin
  Result := FQualifiers;
end; { TGpSQLSelect.GetQualifiers }

function TGpSQLSelect.GetTableName: IGpSQLName;
begin
  Result := FTableName;
end; { TGpSQLSelect.GetTableName }

procedure TGpSQLSelect.SetTableName(const value: IGpSQLName);
begin
  FTableName := value;
end; { TGpSQLSelect.SetTableName }

{ TGpSQLAST }

constructor TGpSQLAST.Create;
var
  section: TGpSQLSection;
begin
  inherited;
  for section := Low(TGpSQLSection) to High(TGpSQLSection) do
    FSections[section] := CreateSQLSection(section);
end; { TGpSQLAST.Create }

function TGpSQLAST.GetSection(sect: TGpSQLSection): IGpSQLSection;
begin
  Result := FSections[sect];
end; { TGpSQLAST.GetSection }

end.
