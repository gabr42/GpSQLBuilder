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
    property Name: string read GetName write SetName;
    property Alias: string read GetAlias write SetAlias;
  end; { IGpSQLName }

  IGpSQLColumns = interface
  ['{DA9157F6-3526-4DA4-8CD3-115DFE7719B3}']
    function  GetColumns(idx: integer): IGpSQLName;
  //
    procedure Add(const name: IGpSQLName);
    function  Count: integer;
    property Columns[idx: integer]: IGpSQLName read GetColumns; default;
  end; { IGpSQLColumns }

  IGpSQLSection = interface ['{BE0A0FF9-AD70-40C5-A1C2-7FA2F7061153}']
    function  GetName: string;
  //
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

  IGpSQLExpression = interface ['{011D9FD2-AE54-4720-98AB-085D6F6B421E}']
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
    procedure Add(const join: IGpSQLJoin);
  end; { IGpSQLJoins }

  IGpSQLWhere = interface(IGpSQLSection) ['{77BD3E41-53DC-4FC7-B0ED-B339564791AA}']
    function GetExpression: IGpSQLExpression;
  //
    property Expression: IGpSQLExpression read GetExpression;
  end; { IGpSQLWhere }

  IGpSQLGroupBy = interface(IGpSQLSection) ['{B8B50CF2-2E2A-4C3C-B9B6-D6B0BE92502C}']
  end; { IGpSQLGroupBy }

  IGpSQLHaving = interface(IGpSQLSection) ['{BF1459A7-C665-4983-A724-A7002F6D201F}']
    function  GetExpression: string;
    procedure SetExpression(const value: string);
  //
    property Expression: string read GetExpression write SetExpression;
  end; { IGpSQLHaving }

  IGpSQLOrderByColumns = interface ['{05ECC702-D102-4D7D-A150-49A7A8787A7C}']
  end; { IGpSQLOrderByColumns }

  IGpSQLOrderBy = interface(IGpSQLSection) ['{6BC985B7-219A-4359-9F21-60A985969368}']
//    function GetColumns: IGpSQLOrderByColumns;
  //
//    property Columns: IGpSQLOrderByColumns read GetColumns;
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

  function CreateSQLName: IGpSQLName;
  function CreateSQLColumns: IGpSQLColumns;
  function CreateSQLSelectQualifier: IGpSQLSelectQualifier;
  function CreateSQLSelectQualifiers: IGpSQLSelectQualifiers;
  // TODO -oPrimoz Gabrijelcic : add constructors for other sections
  function CreateSQLJoin: IGpSQLJoin;
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
    procedure Add(const name: IGpSQLName);
    function  Count: integer;
    property Columns[idx: integer]: IGpSQLName read GetColumns; default;
  end; { TGpSQLColumns }

  TGpSQLSection = class(TInterfacedObject, IGpSQLSection)
  strict private
    FName: string;
  strict protected
    function  GetName: string;
  public
    constructor Create(sectionName: string);
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
    procedure Add(qualifier: IGpSQLSelectQualifier);
    function  Count: integer;
    property Qualifier[idx: integer]: IGpSQLSelectQualifier read GetQualifier; default;
  end; { TGpSQLSelectQualifiers }

  TGpSQLSelect = class(TGpSQLSection, IGpSQLSelect, IGpSQLColumns)
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
    procedure Add(const join: IGpSQLJoin);
  end; { TGpSQLJoins }

  TGpSQLWhere = class(TGpSQLSection, IGpSQLWhere)
  strict private
    FExpression: IGpSQLExpression;
  strict protected
    function  GetExpression: IGpSQLExpression;
  public
    constructor Create;
    property Expression: IGpSQLExpression read GetExpression;
  end; { TGpSQLWhere }

  TGpSQLGroupBy = class(TGpSQLSection, IGpSQLGroupBy, IGpSQLColumns)
  strict private
    FColumns: IGpSQLColumns;
  strict protected
    function GetColumns: IGpSQLColumns;
  public
    constructor Create;
    property Columns: IGpSQLColumns read FColumns implements IGpSQLColumns;
  end; { IGpSQLGroupBy }

  TGpSQLHaving = class(TGpSQLSection, IGpSQLHaving)
  strict private
    FExpression: string;
  strict protected
    function  GetExpression: string;
    procedure SetExpression(const value: string);
  public
    constructor Create;
    property Expression: string read GetExpression write SetExpression;
  end; { TGpSQLHaving }

  TGpSQLOrderByColumns = class(TGpSQLColumns, IGpSQLColumns, IGpSQLOrderByColumns)
  end; { TGpSQLOrderByColumns }

  TGpSQLOrderBy = class(TGpSQLSection, IGpSQLOrderBy, IGpSQLColumns)
  strict private
    FColumns: IGpSQLColumns;
  strict protected
    function  GetColumns: IGpSQLColumns;
  public
    constructor Create;
    property Columns: IGpSQLColumns read GetColumns implements IGpSQLColumns;
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

function CreateSQLName: IGpSQLName;
begin
  Result := TGpSQLName.Create;
end; { CreateSQLName }

function CreateSQLColumns: IGpSQLColumns;
begin
  Result := TGpSQLColumns.Create;
end; { CreateSQLColumns }

function CreateSQLSelectQualifier: IGpSQLSelectQualifier;
begin
  Result := TGpSQLSelectQualifier.Create;
end; { CreateSQLSelectQualifier }

function CreateSQLSelectQualifiers: IGpSQLSelectQualifiers;
begin
  Result := TGpSQLSelectQualifiers.Create;
end; { CreateSQLSelectQualifiers }

function CreateSQLJoin: IGpSQLJoin;
begin
  Result := TGpSQLJoin.Create;
end; { CreateSQLJoin }

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

procedure TGpSQLColumns.Add(const name: IGpSQLName);
begin
  FColumns.Add(name);
end; { TGpSQLColumns.Add }

function TGpSQLColumns.Count: integer;
begin
  Result := FColumns.Count;
end; { TGpSQLColumns.Count }

function TGpSQLColumns.GetColumns(idx: integer): IGpSQLName;
begin
  Result := FColumns[idx];
end; { TGpSQLColumns.GetColumns }

{ TGpSQLSection }

constructor TGpSQLSection.Create(sectionName: string);
begin
  inherited Create;
  FName := sectionName;
end; { TGpSQLSection.Create }

function TGpSQLSection.GetName: string;
begin
  Result := FName;
end;

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
  inherited Create('Select');
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

{ TGpSQLJoin }

constructor TGpSQLJoin.Create;
begin
  inherited Create('Join');
  FJoinedTable := CreateSQLName;
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

procedure TGpSQLJoins.Add(const join: IGpSQLJoin);
begin
  FJoins.Add(join);
end; { TGpSQLJoins.Add }

{ TGpSQLWhere }

constructor TGpSQLWhere.Create;
begin
  inherited Create('Where');
end; { TGpSQLWhere.Create }

function TGpSQLWhere.GetExpression: IGpSQLExpression;
begin
  Result := FExpression;
end; { TGpSQLWhere.GetExpression }

{ TGpSQLGroupBy }

constructor TGpSQLGroupBy.Create;
begin
  inherited Create('GroupBy');
  FColumns := CreateSQLColumns;
end; { TGpSQLGroupBy.Create }

function TGpSQLGroupBy.GetColumns: IGpSQLColumns;
begin
  Result := FColumns;
end; { TGpSQLGroupBy.GetColumns }

{ TGpSQLHaving }

constructor TGpSQLHaving.Create;
begin
  inherited Create('Having');
end; { TGpSQLHaving.Create }

function TGpSQLHaving.GetExpression: string;
begin
  Result := FExpression;
end; { TGpSQLHaving.GetExpression }

{ TGpSQLHaving }

procedure TGpSQLHaving.SetExpression(const value: string);
begin
  FExpression := value;
end; { TGpSQLHaving.SetExpression }

{ TGpSQLOrderBy }

constructor TGpSQLOrderBy.Create;
begin
  inherited Create('OrderBy');
  FColumns := CreateSQLColumns;
end; { TGpSQLOrderBy.Create }

function TGpSQLOrderBy.GetColumns: IGpSQLColumns;
begin
  Result := FColumns;
end; { TGpSQLOrderBy.GetColumns }

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
