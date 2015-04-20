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
  TGpSQLSection = (secSelect, secFrom, secLeftJoin, secWhere, secGroupBy, secHaving, secOrderBy);
  TGpSQLSections = set of TGpSQLSection;
  TGpSQLStringType = (stNormal, stAnd, stOr, stList, stAppend);

  TGpSQLBuilderColumn = record
    Name : string;
    Alias: string;
    constructor Create(const aName: string);
  end; { TGpSQLBuilderColumn }

  IGpSQLBuilderSection = interface ['{BE0A0FF9-AD70-40C5-A1C2-7FA2F7061153}']
    function  GetAsString: string;
    function  GetColumns: TList<TGpSQLBuilderColumn>;
//    function  GetName: string;
  //
    procedure Add(const params: array of const; paramType: TGpSQLStringType = stNormal;
      const pushBefore: string = ''); overload;
    procedure Add(const params: string; paramType: TGpSQLStringType = stNormal;
      const pushBefore: string = ''); overload;
    procedure Clear;
    property AsString: string read GetAsString;
    property Columns: TList<TGpSQLBuilderColumn> read GetColumns;
//    property Name: string read GetName; // TODO -oPrimoz Gabrijelcic : Temporary, should be part of the stringifying mechanism
  end; { IGpSQLBuilderSection }

  IGpSQLBuilderAST = interface
    function GetSection(sect: TGpSQLSection): IGpSQLBuilderSection;
  //
    property Section[sect: TGpSQLSection]: IGpSQLBuilderSection read GetSection; default;
  end; { IGpSQLBuilderAST }

  function CreateSQLAST: IGpSQLBuilderAST;

  // TODO -oPrimoz Gabrijelcic : maybe could be removed at the end?
  function CreateSQLSection: IGpSQLBuilderSection;

implementation

uses
  System.SysUtils,
  System.StrUtils,        // TODO -oPrimoz Gabrijelcic : Temporary, AST must not depend on serialization
  GpSQLBuilder.Serialize; // TODO -oPrimoz Gabrijelcic : Temporary, AST must not depend on serialization

type
  TGpSQLBuilderSection = class(TInterfacedObject, IGpSQLBuilderSection)
  strict private
    FAsString        : string;
    FColumns         : TList<TGpSQLBuilderColumn>;
//    FName            : string;
    FInsertedParen   : boolean;
    FIsAndExpr       : boolean;
    FIsList          : boolean;
    FLastAndInsertion: integer;
  strict protected
    function  GetAsString: string;
    function  GetColumns: TList<TGpSQLBuilderColumn>;
//    function  GetName: string;
  public
    constructor Create;
    destructor  Destroy; override;
    procedure Add(const params: array of const; paramType: TGpSQLStringType = stNormal;
      const pushBefore: string = ''); overload;
    procedure Add(const params: string; paramType: TGpSQLStringType = stNormal;
      const pushBefore: string = ''); overload;
    procedure Clear;
    property AsString: string read GetAsString;
    property Columns: TList<TGpSQLBuilderColumn> read GetColumns;
//    property Name: string read GetName;
  end; { TGpSQLBuilderSection }

  TGpSQLBuilderAST = class(TInterfacedObject, IGpSQLBuilderAST)
  strict private // TODO -oPrimoz Gabrijelcic : temporary, this belong to serialization
//  const
//    FSectionNames : array [TGpSQLSection] of string = (
//      'SELECT', 'FROM', 'LEFT JOIN', 'WHERE', 'GROUP BY', 'HAVING', 'ORDER BY'
//    );
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

function CreateSQLSection: IGpSQLBuilderSection;
begin
  Result := TGpSQLBuilderSection.Create;
end; { CreateSection }

{ TGpSQLBuilderColumn }

constructor TGpSQLBuilderColumn.Create(const aName: string);
begin
  Name := aName;
end; { TGpSQLBuilderColumn.Create }

{ TGpSQLBuilderSection }

constructor TGpSQLBuilderSection.Create;
begin
  inherited Create;
//  FName := name;
  FColumns := TList<TGpSQLBuilderColumn>.Create;
end; { TGpSQLBuilderSection.Create }

destructor TGpSQLBuilderSection.Destroy;
begin
  FreeAndNil(FColumns);
  inherited;
end; { TGpSQLBuilderSection.Destroy }

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

function TGpSQLBuilderSection.GetColumns: TList<TGpSQLBuilderColumn>;
begin
  Result := FColumns;
end; { TGpSQLBuilderSection.GetColumns }

//function TGpSQLBuilderSection.GetName: string;
//begin
//  Result := FName;
//end; { TGpSQLBuilderSection.GetName }

{ TGpSQLBuilderAST }

constructor TGpSQLBuilderAST.Create;
var
  section: TGpSQLSection;
begin
  inherited;
  for section := Low(TGpSQLSection) to High(TGpSQLSection) do
    FSections[section] := TGpSQLBuilderSection.Create;
end; { TGpSQLBuilderAST.Create }

function TGpSQLBuilderAST.GetSection(sect: TGpSQLSection): IGpSQLBuilderSection;
begin
  Result := FSections[sect];
end; { TGpSQLBuilderAST.GetSection }

end.
