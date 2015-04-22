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
  TGpSQLStringType = (stNormal, stAnd, stOr, stList, stAppend); // TODO -oPrimoz Gabrijelcic : should not be necessary in 3.0

  IGpSQLName = interface
  ['{B219D388-7E5E-4F71-A1F1-9AE4DDE754BC}']
    function  GetAlias: string;
    function  GetName: string;
    procedure SetAlias(const value: string);
    procedure SetName(const value: string);
  //
    procedure Clear;
    function  IsEmpty: boolean;
    property Name: string read GetName write SetName;
    property Alias: string read GetAlias write SetAlias;
  end; { IGpSQLName }

  IGpSQLColumns = interface
  ['{DA9157F6-3526-4DA4-8CD3-115DFE7719B3}']
    function  GetColumns(idx: integer): IGpSQLName;
  //
    function  Add: IGpSQLName; overload;
    procedure Add(const name: IGpSQLName); overload;
    procedure Clear;
    function  Count: integer;
    function  IsEmpty: boolean;
    property Columns[idx: integer]: IGpSQLName read GetColumns; default;
  end; { IGpSQLColumns }

  IGpSQLSection = interface ['{BE0A0FF9-AD70-40C5-A1C2-7FA2F7061153}']
    function  GetName: string;
  //
    procedure Clear;
    function  IsEmpty: boolean;
    property Name: string read GetName;
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
    function  Add: IGpSQLSelectQualifier; overload;
    procedure Add(qualifier: IGpSQLSelectQualifier); overload;
    procedure Clear;
    function  Count: integer;
    function  IsEmpty: boolean;
    property Qualifier[idx: integer]: IGpSQLSelectQualifier read GetQualifier; default;
  end; { IGpSQLSelectQualifiers }

  IGpSQLSelect = interface(IGpSQLSection) ['{6B23B86E-97F3-4D8A-BED5-A678EAEF7842}']
    function  GetColumns: IGpSQLColumns;
    function  GetQualifiers: IGpSQLSelectQualifiers;
    function  GetTableName: IGpSQLName;
    procedure SetTableName(const value: IGpSQLName);
  //
    property Columns: IGpSQLColumns read GetColumns;
    property Qualifiers: IGpSQLSelectQualifiers read GetQualifiers;
    property TableName: IGpSQLName read GetTableName write SetTableName;
  end; { IGpSQLSelect }

  IGpSQLExpression = interface ['{011D9FD2-AE54-4720-98AB-085D6F6B421E}']
    procedure Clear;
    function  IsEmpty: boolean;
  end; { IGpSQLExpression }

  TGpSQLJoinType = (jtLeft, jtLeftOuter, jtRight, jtRightOuter); // TODO -oPrimoz Gabrijelcic : Is that all?

  IGpSQLJoin = interface(IGpSQLSection) ['{CD8AD84D-2FCC-4EBD-A83A-A637CF9D188E}']
    function  GetCondition: IGpSQLExpression;
    function  GetJoinedTable: IGpSQLName;
    function  GetJoinType: TGpSQLJoinType;
    procedure SetCondition(const value: IGpSQLExpression);
    procedure SetJoinedTable(const value: IGpSQLName);
    procedure SetJoinType(const value: TGpSQLJoinType);
  //
    property JoinedTable: IGpSQLName read GetJoinedTable write SetJoinedTable;
    property JoinType: TGpSQLJoinType read GetJoinType write SetJoinType;
    property Condition: IGpSQLExpression read GetCondition write SetCondition;
  end; { IGpSQLJoin }

  IGpSQLJoins = interface ['{5C277003-FC57-4DE5-B041-371012A51D82}']
    function  Add: IGpSQLJoin; overload;
    procedure Add(const join: IGpSQLJoin); overload;
  end; { IGpSQLJoins }

  IGpSQLWhere = interface(IGpSQLSection) ['{77BD3E41-53DC-4FC7-B0ED-B339564791AA}']
    function GetExpression: IGpSQLExpression;
  //
    property Expression: IGpSQLExpression read GetExpression;
  end; { IGpSQLWhere }

  IGpSQLGroupBy = interface(IGpSQLSection) ['{B8B50CF2-2E2A-4C3C-B9B6-D6B0BE92502C}']
    function GetColumns: IGpSQLColumns;
  //
    property Columns: IGpSQLColumns read GetColumns;
  end; { IGpSQLGroupBy }

  IGpSQLHaving = interface(IGpSQLSection) ['{BF1459A7-C665-4983-A724-A7002F6D201F}']
    function  GetExpression: string;
    procedure SetExpression(const value: string);
  //
    property Expression: string read GetExpression write SetExpression;
  end; { IGpSQLHaving }

  TGpSQLOrderByDirection = (dirAscending, dirDescending);

  IGpSQLOrderByColumn = interface(IGpSQLName) ['{05ECC702-D102-4D7D-A150-49A7A8787A7C}']
    function  GetDirection: TGpSQLOrderByDirection;
    procedure SetDirection(const value: TGpSQLOrderByDirection);
  //
    property Direction: TGpSQLOrderByDirection read GetDirection write SetDirection;
  end; { IGpSQLOrderByColumn }

  IGpSQLOrderBy = interface(IGpSQLSection) ['{6BC985B7-219A-4359-9F21-60A985969368}']
    function GetColumns: IGpSQLColumns;
  //
    property Columns: IGpSQLColumns read GetColumns;
  end; { IGpSQLOrderBy }

  IGpSQLAST = interface
    function GetGroupBy: IGpSQLGroupBy;
    function GetHaving: IGpSQLHaving;
    function GetJoins: IGpSQLJoins;
    function GetOrderBy: IGpSQLOrderBy;
    function GetSelect: IGpSQLSelect;
    function GetWhere: IGpSQLWhere;
  //
    property Select: IGpSQLSelect read GetSelect;
    property Joins: IGpSQLJoins read GetJoins;
    property Where: IGpSQLWhere read GetWhere;
    property GroupBy: IGpSQLGroupBy read GetGroupBy;
    property Having: IGpSQLHaving read GetHaving;
    property OrderBy: IGpSQLOrderBy read GetOrderBy;
  end; { IGpSQLAST }

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
    procedure Clear;
    function  IsEmpty: boolean;
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
    function  Add: IGpSQLName; overload; virtual;
    procedure Add(const name: IGpSQLName); overload; virtual;
    procedure Clear;
    function  Count: integer;
    function  IsEmpty: boolean;
    property Columns[idx: integer]: IGpSQLName read GetColumns; default;
  end; { TGpSQLColumns }

  TGpSQLSection = class(TInterfacedObject, IGpSQLSection)
  strict private
    FName: string;
  strict protected
    function  GetName: string;
  public
    constructor Create(sectionName: string);
    procedure Clear; virtual; abstract;
    function  IsEmpty: boolean; virtual; abstract;
    property Name: string read GetName;
  end; { TGpSQLSection }

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
    function  Add: IGpSQLSelectQualifier; overload;
    procedure Add(qualifier: IGpSQLSelectQualifier); overload;
    procedure Clear;
    function  Count: integer;
    function  IsEmpty: boolean;
    property Qualifier[idx: integer]: IGpSQLSelectQualifier read GetQualifier; default;
  end; { TGpSQLSelectQualifiers }

  TGpSQLSelect = class(TGpSQLSection, IGpSQLSelect)
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
    procedure Clear; override;
    function  IsEmpty: boolean; override;
    property Columns: IGpSQLColumns read GetColumns;
    property Qualifiers: IGpSQLSelectQualifiers read GetQualifiers;
    property TableName: IGpSQLName read GetTableName write SetTableName;
  end; { IGpSQLSelect }

  TGpSQLJoin = class(TGpSQLSection, IGpSQLJoin)
  strict private
    FCondition  : IGpSQLExpression;
    FJoinedTable: IGpSQLName;
    FJoinType   : TGpSQLJoinType;
  strict protected
    function  GetCondition: IGpSQLExpression;
    function  GetJoinedTable: IGpSQLName;
    function  GetJoinType: TGpSQLJoinType;
    procedure SetCondition(const value: IGpSQLExpression);
    procedure SetJoinedTable(const value: IGpSQLName);
    procedure SetJoinType(const value: TGpSQLJoinType);
  public
    constructor Create;
    procedure Clear; override;
    function  IsEmpty: boolean; override;
    property Condition: IGpSQLExpression read GetCondition write SetCondition;
    property JoinedTable: IGpSQLName read GetJoinedTable write SetJoinedTable;
    property JoinType: TGpSQLJoinType read GetJoinType write SetJoinType;
  end; { TGpSQLJoin }

  TGpSQLJoins = class(TInterfacedObject, IGpSQLJoins)
  strict private
    FJoins: TList<IGpSQLJoin>;
  public
    constructor Create;
    destructor  Destroy; override;
    function  Add: IGpSQLJoin; overload;
    procedure Add(const join: IGpSQLJoin); overload;
    procedure Clear;
    function  IsEmpty: boolean;
  end; { TGpSQLJoins }

  TGpSQLWhere = class(TGpSQLSection, IGpSQLWhere)
  strict private
    FExpression: IGpSQLExpression;
  strict protected
    function  GetExpression: IGpSQLExpression;
  public
    constructor Create;
    procedure Clear; override;
    function  IsEmpty: boolean; override;
    property Expression: IGpSQLExpression read GetExpression;
  end; { TGpSQLWhere }

  TGpSQLGroupBy = class(TGpSQLSection, IGpSQLGroupBy)
  strict private
    FColumns: IGpSQLColumns;
  strict protected
    function  GetColumns: IGpSQLColumns;
  public
    constructor Create;
    procedure Clear; override;
    function  IsEmpty: boolean; override;
    property Columns: IGpSQLColumns read GetColumns;
  end; { IGpSQLGroupBy }

  TGpSQLHaving = class(TGpSQLSection, IGpSQLHaving)
  strict private
    FExpression: string;
  strict protected
    function  GetExpression: string;
    procedure SetExpression(const value: string);
  public
    constructor Create;
    procedure Clear; override;
    function  IsEmpty: boolean; override;
    property Expression: string read GetExpression write SetExpression;
  end; { TGpSQLHaving }

  TGpSQLOrderByColumn = class(TGpSQLName, IGpSQLOrderByColumn)
  strict private
    FDirection: TGpSQLOrderByDirection;
  strict protected
    function  GetDirection: TGpSQLOrderByDirection;
    procedure SetDirection(const value: TGpSQLOrderByDirection);
  public
    property Direction: TGpSQLOrderByDirection read GetDirection write SetDirection;
  end; { TGpSQLOrderByColumn }

  TGpSQLOrderByColumns = class(TGpSQLColumns)
  public
    function Add: IGpSQLName; override;
  end; { TGpSQLOrderByColumns }

  TGpSQLOrderBy = class(TGpSQLSection, IGpSQLOrderBy)
  strict private
    FColumns: IGpSQLColumns;
  strict protected
    function  GetColumns: IGpSQLColumns;
  public
    constructor Create;
    procedure Clear; override;
    function  IsEmpty: boolean; override;
    property Columns: IGpSQLColumns read GetColumns;
  end; { IGpSQLOrderBy }

  TGpSQLAST = class(TInterfacedObject, IGpSQLAST)
  strict private
    FGroupBy: IGpSQLGroupBy;
    FHaving : IGpSQLHaving;
    FJoins  : IGpSQLJoins;
    FOrderBy: IGpSQLOrderBy;
    FSelect : IGpSQLSelect;
    FWhere  : IGpSQLWhere;
  strict protected
    function GetGroupBy: IGpSQLGroupBy;
    function GetHaving: IGpSQLHaving;
    function GetJoins: IGpSQLJoins;
    function GetOrderBy: IGpSQLOrderBy;
    function GetSelect: IGpSQLSelect;
    function GetWhere: IGpSQLWhere;
  public
    constructor Create;
    property Select: IGpSQLSelect read GetSelect;
    property Joins: IGpSQLJoins read GetJoins;
    property Where: IGpSQLWhere read GetWhere;
    property GroupBy: IGpSQLGroupBy read GetGroupBy;
    property Having: IGpSQLHaving read GetHaving;
    property OrderBy: IGpSQLOrderBy read GetOrderBy;
  end; { TGpSQLAST }

{ exports }

function CreateSQLAST: IGpSQLAST;
begin
  Result := TGpSQLAST.Create;
end; { CreateSQLAST }

{ TGpSQLName }

procedure TGpSQLName.Clear;
begin
  FName := '';
  FAlias := '';
end; { TGpSQLName.Clear }

function TGpSQLName.GetAlias: string;
begin
  Result := FAlias;
end; { TGpSQLName.GetAlias }

function TGpSQLName.GetName: string;
begin
  Result := FName;
end; { TGpSQLName.GetName }

function TGpSQLName.IsEmpty: boolean;
begin
  Result := (FName = '') and (FAlias = '');
end; { TGpSQLName.IsEmpty }

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

function TGpSQLColumns.Add: IGpSQLName;
begin
  Result := TGpSQLName.Create;
  Add(Result);
end; { TGpSQLColumns.Add }

procedure TGpSQLColumns.Add(const name: IGpSQLName);
begin
  FColumns.Add(name);
end; { TGpSQLColumns.Add }

procedure TGpSQLColumns.Clear;
begin
  FColumns.Clear;
end; { TGpSQLColumns.Clear }

function TGpSQLColumns.Count: integer;
begin
  Result := FColumns.Count;
end; { TGpSQLColumns.Count }

function TGpSQLColumns.GetColumns(idx: integer): IGpSQLName;
begin
  Result := FColumns[idx];
end; { TGpSQLColumns.GetColumns }

function TGpSQLColumns.IsEmpty: boolean;
begin
  Result := (Count = 0);
end; { TGpSQLColumns.IsEmpty }

{ TGpSQLSection }

constructor TGpSQLSection.Create(sectionName: string);
begin
  inherited Create;
  FName := sectionName;
end; { TGpSQLSection.Create }

function TGpSQLSection.GetName: string;
begin
  Result := FName;
end; { TGpSQLSection.GetName }

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

function TGpSQLSelectQualifiers.Add: IGpSQLSelectQualifier;
begin
  Result := TGpSQLSelectQualifier.Create;
  Add(Result);
end; { TGpSQLSelectQualifiers.Add }

procedure TGpSQLSelectQualifiers.Add(qualifier: IGpSQLSelectQualifier);
begin
  FQualifiers.Add(qualifier);
end; { TGpSQLSelectQualifiers.Add }

procedure TGpSQLSelectQualifiers.Clear;
begin
  FQualifiers.Clear;
end; { TGpSQLSelectQualifiers.Clear }

function TGpSQLSelectQualifiers.Count: integer;
begin
  Result := FQualifiers.Count;
end; { TGpSQLSelectQualifiers.Count }

function TGpSQLSelectQualifiers.GetQualifier(idx: integer): IGpSQLSelectQualifier;
begin
  Result := FQualifiers[idx];
end; { TGpSQLSelectQualifiers.GetQualifier }

function TGpSQLSelectQualifiers.IsEmpty: boolean;
begin
  Result := (Count = 0);
end; { TGpSQLSelectQualifiers.IsEmpty }

{ TGpSQLSelect }

procedure TGpSQLSelect.Clear;
begin
  Columns.Clear;
  TableName.Clear;
end; { TGpSQLSelect.Clear }

constructor TGpSQLSelect.Create;
begin
  inherited Create('Select');
  FColumns := TGpSQLColumns.Create;
  FQualifiers := TGpSQLSelectQualifiers.Create;
  FTableName := TGpSQLName.Create;
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

function TGpSQLSelect.IsEmpty: boolean;
begin
  Result := Columns.IsEmpty and TableName.IsEmpty;
end; { TGpSQLSelect.IsEmpty }

procedure TGpSQLSelect.SetTableName(const value: IGpSQLName);
begin
  FTableName := value;
end; { TGpSQLSelect.SetTableName }

{ TGpSQLJoin }

procedure TGpSQLJoin.Clear;
begin
  Condition.Clear;
  JoinedTable.Clear;
end; { TGpSQLJoin.Clear }

constructor TGpSQLJoin.Create;
begin
  inherited Create('Join');
  FJoinedTable := TGpSQLName.Create;
end; { TGpSQLJoin.Create }

function TGpSQLJoin.GetCondition: IGpSQLExpression;
begin
  Result := FCondition;
end; { TGpSQLJoin.GetCondition }

function TGpSQLJoin.GetJoinedTable: IGpSQLName;
begin
  Result := FJoinedTable;
end; { TGpSQLJoin.GetJoinedTable }

function TGpSQLJoin.GetJoinType: TGpSQLJoinType;
begin
  Result := FJoinType;
end; { TGpSQLJoin.GetJoinType }

function TGpSQLJoin.IsEmpty: boolean;
begin
  Result := Condition.IsEmpty and JoinedTable.IsEmpty;
end; { TGpSQLJoin.IsEmpty }

procedure TGpSQLJoin.SetCondition(const value: IGpSQLExpression);
begin
  FCondition := value;
end; { TGpSQLJoin.SetCondition }

procedure TGpSQLJoin.SetJoinedTable(const value: IGpSQLName);
begin
  FJoinedTable := value;
end; { TGpSQLJoin.SetJoinedTable }

procedure TGpSQLJoin.SetJoinType(const value: TGpSQLJoinType);
begin
  FJoinType := value;
end; { TGpSQLJoin.SetJoinType }

{ TGpSQLJoins }

procedure TGpSQLJoins.Clear;
begin
  FJoins.Clear;
end; { TGpSQLJoins.Clear }

constructor TGpSQLJoins.Create;
begin
  inherited Create;
  FJoins := TList<IGpSQLJoin>.Create;
end; { TGpSQLJoins.Create }

destructor TGpSQLJoins.Destroy;
begin
  FreeAndNil(FJoins);
  inherited;
end; { TGpSQLJoins.Destroy }

function TGpSQLJoins.IsEmpty: boolean;
begin
  Result := (FJoins.Count = 0);
end; { TGpSQLJoins.IsEmpty }

procedure TGpSQLJoins.Add(const join: IGpSQLJoin);
begin
  FJoins.Add(join);
end; { TGpSQLJoins.Add }

function TGpSQLJoins.Add: IGpSQLJoin;
begin
  Result := TGpSQLJoin.Create;
  Add(Result);
end; { TGpSQLJoins.Add }

{ TGpSQLWhere }

procedure TGpSQLWhere.Clear;
begin
  Expression.Clear;
end; { TGpSQLWhere.Clear }

constructor TGpSQLWhere.Create;
begin
  inherited Create('Where');
end; { TGpSQLWhere.Create }

function TGpSQLWhere.GetExpression: IGpSQLExpression;
begin
  Result := FExpression;
end; { TGpSQLWhere.GetExpression }

function TGpSQLWhere.IsEmpty: boolean;
begin
  Result := Expression.IsEmpty;
end; { TGpSQLWhere.IsEmpty }

{ TGpSQLGroupBy }

procedure TGpSQLGroupBy.Clear;
begin
  Columns.Clear;
end; { TGpSQLGroupBy.Clear }

constructor TGpSQLGroupBy.Create;
begin
  inherited Create('GroupBy');
  FColumns := TGpSQLColumns.Create;
end; { TGpSQLGroupBy.Create }

function TGpSQLGroupBy.GetColumns: IGpSQLColumns;
begin
  Result := FColumns;
end; { TGpSQLGroupBy.GetColumns }

function TGpSQLGroupBy.IsEmpty: boolean;
begin
  Result := Columns.Isempty;
end; { TGpSQLGroupBy.IsEmpty }

{ TGpSQLHaving }

procedure TGpSQLHaving.Clear;
begin
  Expression := '';
end; { TGpSQLHaving.Clear }

constructor TGpSQLHaving.Create;
begin
  inherited Create('Having');
end; { TGpSQLHaving.Create }

function TGpSQLHaving.GetExpression: string;
begin
  Result := FExpression;
end; { TGpSQLHaving.GetExpression }

function TGpSQLHaving.IsEmpty: boolean;
begin
  Result := (Expression = '');
end; { TGpSQLHaving.IsEmpty }

{ TGpSQLHaving }

procedure TGpSQLHaving.SetExpression(const value: string);
begin
  FExpression := value;
end; { TGpSQLHaving.SetExpression }

{ TGpSQLOrderByColumn }

function TGpSQLOrderByColumn.GetDirection: TGpSQLOrderByDirection;
begin
  Result := FDirection;
end; { TGpSQLOrderByColumn.GetDirection }

procedure TGpSQLOrderByColumn.SetDirection(const value: TGpSQLOrderByDirection);
begin
  FDirection := value;
end; { TGpSQLOrderByColumn.SetDirection }

{ TGpSQLOrderByColumns }

function TGpSQLOrderByColumns.Add: IGpSQLName;
begin
  Result := TGpSQLOrderByColumn.Create;
  Add(Result);
end; { TGpSQLOrderByColumns.Add }

{ TGpSQLOrderBy }

constructor TGpSQLOrderBy.Create;
begin
  inherited Create('OrderBy');
  FColumns := TGpSQLOrderByColumns.Create;
end; { TGpSQLOrderBy.Create }

procedure TGpSQLOrderBy.Clear;
begin
  Columns.Clear;
end; { TGpSQLOrderBy.Clear }

function TGpSQLOrderBy.GetColumns: IGpSQLColumns;
begin
  Result := FColumns;
end; { TGpSQLOrderBy.GetColumns }

function TGpSQLOrderBy.IsEmpty: boolean;
begin
  Result := Columns.IsEmpty;
end; { TGpSQLOrderBy.IsEmpty }

{ TGpSQLAST }

constructor TGpSQLAST.Create;
begin
  inherited;
  FSelect := TGpSQLSelect.Create;
  FJoins := TGpSQLJoins.Create;
  FWhere := TGpSQLWhere.Create;
  FGroupBy := TGpSQLGroupBy.Create;
  FHaving := TGpSQLHaving.Create;
  FOrderBy := TGpSQLOrderBy.Create;
end; { TGpSQLAST.Create }

function TGpSQLAST.GetGroupBy: IGpSQLGroupBy;
begin
  Result := FGroupBy;
end; { TGpSQLAST.GetGroupBy }

function TGpSQLAST.GetHaving: IGpSQLHaving;
begin
  Result := FHaving;
end; { TGpSQLAST.GetHaving }

function TGpSQLAST.GetJoins: IGpSQLJoins;
begin
  Result := FJoins;
end;

function TGpSQLAST.GetOrderBy: IGpSQLOrderBy;
begin
  Result := FOrderBy;
end; { TGpSQLAST.GetOrderBy }

function TGpSQLAST.GetSelect: IGpSQLSelect;
begin
  Result := FSelect;
end; { TGpSQLAST.GetSelect }

function TGpSQLAST.GetWhere: IGpSQLWhere;
begin
  Result := FWhere;
end; { TGpSQLAST.GetWhere }

end.
