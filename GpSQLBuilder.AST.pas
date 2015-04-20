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
  TGpSQLStringType = (stNormal, stAnd, stOr, stList, stAppend);

  IGpSQLBuilderName = interface ['{B219D388-7E5E-4F71-A1F1-9AE4DDE754BC}']
    function  GetAlias: string;
    function  GetName: string;
    procedure SetAlias(const value: string);
    procedure SetName(const value: string);
  //
    property Name: string read GetName write SetName;
    property Alias: string read GetAlias write SetAlias;
  end; { IGpSQLBuilderName }

  IGpSQLBuilderColumns = interface ['{DA9157F6-3526-4DA4-8CD3-115DFE7719B3}']
    function  GetColumns(idx: integer): IGpSQLBuilderName;
  //
    procedure Add(const name: string);
    function  Count: integer;
    property Columns[idx: integer]: IGpSQLBuilderName read GetColumns; default;
  end; { IGpSQLBuilderColumns }

  IGpSQLBuilderSection = interface ['{BE0A0FF9-AD70-40C5-A1C2-7FA2F7061153}']
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
  end; { IGpSQLBuilderSection }

  IGpSQLBuilderSelect = interface(IGpSQLBuilderSection) ['{6B23B86E-97F3-4D8A-BED5-A678EAEF7842}']
    function  GetTableName: IGpSQLBuilderName;
    procedure SetTableName(const value: IGpSQLBuilderName);
  //
    property TableName: IGpSQLBuilderName read GetTableName write SetTableName;
  end; { IGpSQLBuilderSelect }

  IGpSQLBuilderAST = interface
    function GetSection(sect: TGpSQLSection): IGpSQLBuilderSection;
  //
    property Section[sect: TGpSQLSection]: IGpSQLBuilderSection read GetSection; default;
  end; { IGpSQLBuilderAST }

  function CreateSQLAST: IGpSQLBuilderAST;

  // TODO -oPrimoz Gabrijelcic : maybe could be removed at the end?
  function CreateSQLSection(section: TGpSQLSection): IGpSQLBuilderSection;

implementation

uses
  System.SysUtils,
  System.StrUtils,        // TODO -oPrimoz Gabrijelcic : Temporary, AST must not depend on serialization
  GpSQLBuilder.Serialize; // TODO -oPrimoz Gabrijelcic : Temporary, AST must not depend on serialization

type
  TGpSQLBuilderName = class(TInterfacedObject, IGpSQLBuilderName)
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
  end; { TIGpSQLBuilderName }

  TGpSQLBuilderColumns = class(TInterfacedObject, IGpSQLBuilderColumns)
  strict private
    FColumns: TList<IGpSQLBuilderName>;
  strict protected
    function  GetColumns(idx: integer): IGpSQLBuilderName;
  public
    constructor Create;
    destructor  Destroy; override;
    procedure Add(const name: string);
    function  Count: integer;
    property Columns[idx: integer]: IGpSQLBuilderName read GetColumns; default;
  end; { TGpSQLBuilderColumns }

  TGpSQLBuilderSection = class(TInterfacedObject, IGpSQLBuilderSection)
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
  end; { TGpSQLBuilderSection }

  TGpSQLBuilderSelect = class(TGpSQLBuilderSection, IGpSQLBuilderSelect, IGpSQLBuilderColumns)
  strict private
    FColumns  : IGpSQLBuilderColumns;
    FTableName: IGpSQLBuilderName;
  strict protected
    function  GetColumns: IGpSQLBuilderColumns;
    function  GetTableName: IGpSQLBuilderName;
    procedure SetTableName(const value: IGpSQLBuilderName);
  public
    constructor Create;
    property Columns: IGpSQLBuilderColumns read FColumns implements IGpSQLBuilderColumns;
    property TableName: IGpSQLBuilderName read GetTableName write SetTableName;
  end; { IGpSQLBuilderSelect }

  TGpSQLBuilderAST = class(TInterfacedObject, IGpSQLBuilderAST)
  strict private
    FSections: array [TGpSQLSection] of IGpSQLBuilderSection;
  strict protected
    function  GetSection(sect: TGpSQLSection): IGpSQLBuilderSection; inline;
  public
    constructor Create;
    property Section[sect: TGpSQLSection]: IGpSQLBuilderSection read GetSection; default;
  end; { TGpSQLBuilderAST }

{ exports }

function CreateSQLAST: IGpSQLBuilderAST;
begin
  Result := TGpSQLBuilderAST.Create;
end; { CreateSQLAST }

function CreateSQLSection(section: TGpSQLSection): IGpSQLBuilderSection;
begin
  Result := TGpSQLBuilderSection.Create(section);
end; { CreateSection }

{ TGpSQLBuilderName }

function TGpSQLBuilderName.GetAlias: string;
begin
  Result := FAlias;
end; { TGpSQLBuilderName.GetAlias }

function TGpSQLBuilderName.GetName: string;
begin
  Result := FName;
end; { TGpSQLBuilderName.GetName }

procedure TGpSQLBuilderName.SetAlias(const value: string);
begin
  FAlias := value;
end; { TGpSQLBuilderName.SetAlias }

procedure TGpSQLBuilderName.SetName(const value: string);
begin
  FName := value;
end; { TGpSQLBuilderName.SetName }

{ TGpSQLBuilderColumns }

constructor TGpSQLBuilderColumns.Create;
begin
  inherited Create;
  FColumns := TList<IGpSQLBuilderName>.Create;
end; { TGpSQLBuilderColumns.Create }

destructor TGpSQLBuilderColumns.Destroy;
begin
  FreeAndNil(FColumns);
  inherited;
end; { TGpSQLBuilderColumns.Destroy }

procedure TGpSQLBuilderColumns.Add(const name: string);
var
  column: TGpSQLBuilderName;
begin
  column := TGpSQLBuilderName.Create;
  column.Name := name;
  FColumns.Add(column);
end; { TGpSQLBuilderColumns.Add }

function TGpSQLBuilderColumns.Count: integer;
begin
  Result := FColumns.Count;
end; { TGpSQLBuilderColumns.Count }

function TGpSQLBuilderColumns.GetColumns(idx: integer): IGpSQLBuilderName;
begin
  Result := FColumns[idx];
end; { TGpSQLBuilderColumns.GetColumns }

{ TGpSQLBuilderSection }

constructor TGpSQLBuilderSection.Create(section: TGpSQLSection);
begin
  inherited Create;
  FSection := section;
end; { TGpSQLBuilderSection.Create }

procedure TGpSQLBuilderSection.Add(const params: array of const; paramType: TGpSQLStringType;
  const pushBefore: string);
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
end; { TGpSQLBuilderSection.Add }

procedure TGpSQLBuilderSection.Add(const params: string; paramType: TGpSQLStringType;
  const pushBefore: string);
begin
  Add([params], paramType, pushBefore);
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

function TGpSQLBuilderSection.GetSection: TGpSQLSection;
begin
  Result := FSection;
end; { TGpSQLBuilderSection.GetSection }

{ TGpSQLBuilderSelect }

constructor TGpSQLBuilderSelect.Create;
begin
  inherited Create(secSelect);
  FColumns := TGpSQLBuilderColumns.Create;
  FTableName := TGpSQLBuilderName.Create;
end; { TGpSQLBuilderSelect.Create }

function TGpSQLBuilderSelect.GetColumns: IGpSQLBuilderColumns;
begin
  Result := FColumns;
end; { TGpSQLBuilderSelect.GetColumns }

function TGpSQLBuilderSelect.GetTableName: IGpSQLBuilderName;
begin
  Result := FTableName;
end; { TGpSQLBuilderSelect.GetTableName }

procedure TGpSQLBuilderSelect.SetTableName(const value: IGpSQLBuilderName);
begin
  FTableName := value;
end; { TGpSQLBuilderSelect.SetTableName }

{ TGpSQLBuilderAST }

constructor TGpSQLBuilderAST.Create;
var
  section: TGpSQLSection;
begin
  inherited;
  FSections[secSelect] := TGpSQLBuilderSelect.Create;
  for section := secLeftJoin to High(TGpSQLSection) do
    FSections[section] := TGpSQLBuilderSection.Create(section);
end; { TGpSQLBuilderAST.Create }

function TGpSQLBuilderAST.GetSection(sect: TGpSQLSection): IGpSQLBuilderSection;
begin
  Result := FSections[sect];
end; { TGpSQLBuilderAST.GetSection }

end.
