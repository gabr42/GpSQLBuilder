unit TestGpSQLBuilder1;

interface

uses
  DUnitX.TestFramework,
  GpSQLBuilder;

type
  [TestFixture]
  TTestGpSQLBuilder = class(TObject)
  strict private
    SQL: IGpSQLBuilder;
  public
    [Setup]
    procedure Setup;
    [TearDown]
    procedure TearDown;
    [Test] procedure TestEmptyResult;
    [Test] procedure TestSelectAll;
    [Test] procedure TestSelectAll2;
    [Test] procedure TestSelectColumn;
    [Test] procedure TestSelectColumn2;
    [Test] procedure TestSelectTwoColumns;
    [Test] procedure TestSelectDBColumn;
    [Test] procedure TestDBAlias;
    [Test] procedure TestColumnAlias;
    [Test] procedure TestSelectFirst;
    [Test] procedure TestSelectFirstSkip;
    [Test] procedure TestSelectWhere;
    [Test] procedure TestLeftJoin;
    [Test] procedure TestLeftJoin2;
    [Test] procedure TestLeftJoinAnd;
    [Test] procedure TestLeftJoinAlias;
    [Test] procedure TestDoubleLeftJoin;
    [Test] procedure TestGroupBy;
    [Test] procedure TestGroupByHaving;
    [Test] procedure TestOrderBy;
    [Test] procedure TestOrderBy2;
    [Test] procedure TestOrderByTwoColumns;
    [Test] procedure TestOrderByDesc;
    [Test] procedure TestOrderByTwoColumnsDesc1;
    [Test] procedure TestOrderByTwoColumnsDesc2;
    [Test] procedure TestWhereAnd;
    [Test] procedure TestWhereAnd2;
    [Test] procedure TestWhereOr;
    [Test] procedure TestWhereAndOr;
    [Test] procedure TestCaseIntegration;
    [Test] procedure TestExpressionIntegration;
    [Test] procedure TestMixed;
    [Test] procedure TestSectionEmpty;
    [Test] procedure TestSectionEmpty2;
    [Test] procedure TestSectionEmpty3;
    [Test] procedure TestSectionNotEmpty;
    [Test] procedure TestSectionNotEmpty2;
  end;

  [TestFixture]
  TTestGpSQLBuilderCase = class(TObject)
  public
    [Test] procedure TestCase;
    [Test] procedure TestCase2;
    [Test] procedure TestCase3;
    [Test] procedure TestCaseAndOr;
  end;

  [TestFixture]
  TTestGpSQLBuilderExpression = class(TObject)
  public
    [Test] procedure TestAnd;
    [Test] procedure TestAnd2;
    [Test] procedure TestOr;
    [Test] procedure TestAndOr;
  end;

implementation

uses
  System.SysUtils,
  GpSQLBuilder.AST;

const
  //test table names
  DB_TEST = 'Test';
  DB_TEST_ALIAS = 'TestAlias';
  DB_DETAIL = 'Detail';
  DB_DETAIL_ALIAS = 'DetailAlias';
  DB_SUB = 'Sub';

  COL_ALL_ALIAS = 'ALL';
  COL_1 = 'Column1';
  COL_2 = 'Column2';
  COL_DETAIL_ID = 'DetailID';
  COL_DETAIL_2 = 'Detail2';
  COL_SUB_ID = 'SubID';

{ TTestGpSQLBuilder }

procedure TTestGpSQLBuilder.Setup;
begin
  SQL := CreateGpSQLBuilder;
end;

procedure TTestGpSQLBuilder.TearDown;
begin
  SQL := nil;
end;

procedure TTestGpSQLBuilder.TestCaseIntegration;
const
  CExpected = 'SELECT CASE WHEN (Column2 < 0) THEN 0 WHEN (Column2 > 100) THEN 2 ' +
    'ELSE 1 END FROM Test';
begin
//  SQL
//    .Select(
//      SQL.&Case
//        .When([COL_2, '< 0']).&Then('0')
//        .When([COL_2, '> 100']).&Then('2')
//        .&Else('1')
//      .&End)
//    .From(DB_TEST);

//select(case)
//orderby(case)
//column(case)

//SELECT BusinessEntityID, SalariedFlag
//FROM HumanResources.Employee
//ORDER BY CASE SalariedFlag WHEN 1 THEN BusinessEntityID END DESC,
//         CASE WHEN SalariedFlag = 0 THEN BusinessEntityID END;

//  Assert.AreEqual(CExpected, SQL.AsString);

//.Func('Max', case, expression

end;

procedure TTestGpSQLBuilder.TestColumnAlias;
const
  CExpected = 'SELECT * AS ALL FROM Test';
begin
  SQL
    .Select('*').&As(COL_ALL_ALIAS)
    .From(DB_TEST);
  Assert.AreEqual(CExpected, SQL.AsString);
end;

procedure TTestGpSQLBuilder.TestDBAlias;
const
  CExpected = 'SELECT * FROM Test AS TestAlias';
begin
  SQL
    .Select('*')
    .From(DB_TEST).&As(DB_TEST_ALIAS);
  Assert.AreEqual(CExpected, SQL.AsString);
end;

procedure TTestGpSQLBuilder.TestDoubleLeftJoin;
const
  CExpected = 'SELECT * FROM Test LEFT JOIN Detail ON Column1 = DetailID ' +
    'LEFT JOIN Sub ON DetailID = SubID';
begin
  SQL
    .Select.All
    .From(DB_TEST)
     .LeftJoin(DB_DETAIL).On([COL_1, '=', COL_DETAIL_ID])
     .LeftJoin(DB_SUB).On([COL_DETAIL_ID, '=', COL_SUB_ID]);
  Assert.AreEqual(CExpected, SQL.AsString);
end;

procedure TTestGpSQLBuilder.TestEmptyResult;
begin
  Assert.IsEmpty(SQL.AsString);
end;

procedure TTestGpSQLBuilder.TestExpressionIntegration;
const
  CExpected = 'SELECT * FROM Test WHERE (Column1 IS NULL) AND ((Column2 < 0) OR (Column2 > 10))';
begin
  SQL
    .Select.All
    .From(DB_TEST)
    .Where
      .&And([COL_1, 'IS NULL'])
      .&And(
        SQL.Expression([COL_2, '< 0'])
         .&Or([COL_2, '> 10']));
  Assert.AreEqual(CExpected, SQL.AsString);
end;

procedure TTestGpSQLBuilder.TestGroupBy;
const
  CExpected = 'SELECT * FROM Test GROUP BY Column2';
begin
  SQL
    .Select.All
    .From(DB_TEST)
    .GroupBy(COL_2);
  Assert.AreEqual(CExpected, SQL.AsString);
end;

procedure TTestGpSQLBuilder.TestGroupByHaving;
const
  CExpected = 'SELECT * FROM Test GROUP BY Column2 HAVING Column2 > 0';
begin
  SQL
    .Select.All
    .From(DB_TEST)
    .GroupBy(COL_2)
    .Having([COL_2, '> 0']);
  Assert.AreEqual(CExpected, SQL.AsString);
end;

procedure TTestGpSQLBuilder.TestLeftJoin;
const
  CExpected = 'SELECT * FROM Test LEFT JOIN Detail ON Column1 = DetailID';
begin
  SQL
    .Select.All
    .From(DB_TEST)
     .LeftJoin(DB_DETAIL).On([COL_1, '=', COL_DETAIL_ID]);
  Assert.AreEqual(CExpected, SQL.AsString);
end;

procedure TTestGpSQLBuilder.TestLeftJoin2;
const
  CExpected = 'SELECT * FROM Test LEFT JOIN Detail ON Column1 = DetailID';
begin
  SQL
    .Select.All
    .From(DB_TEST)
     .LeftJoin(DB_DETAIL).On(Format('%s = %s', [COL_1, COL_DETAIL_ID]));
  Assert.AreEqual(CExpected, SQL.AsString);
end;

procedure TTestGpSQLBuilder.TestLeftJoinAlias;
const
  CExpected = 'SELECT * FROM Test LEFT JOIN Detail AS DetailAlias ON Column1 = DetailID';
begin
  SQL
    .Select.All
    .From(DB_TEST)
     .LeftJoin(DB_DETAIL).&As(DB_DETAIL_ALIAS)
       .On([COL_1, '=', COL_DETAIL_ID]);
  Assert.AreEqual(CExpected, SQL.AsString);
end;

procedure TTestGpSQLBuilder.TestLeftJoinAnd;
const
  CExpected = 'SELECT * FROM Test LEFT JOIN Detail ON (Column1 = DetailID) AND (Detail2 > 0)';
begin
  SQL
    .Select.All
    .From(DB_TEST)
     .LeftJoin(DB_DETAIL)
       .On([COL_1, '=', COL_DETAIL_ID])
       .&And([COL_DETAIL_2, '> 0']);
  Assert.AreEqual(CExpected, SQL.AsString);
end;

procedure TTestGpSQLBuilder.TestMixed;
const
  CExpected = 'SELECT * FROM Test WHERE (Column1 IS NOT NULL) AND (Column2 > 0)';
begin
  SQL.Select.All;
  SQL.Where([COL_1, 'IS NOT NULL']);
  SQL.Select.From(DB_TEST);
  SQL.Where.&And([COL_2, '> 0']);
  Assert.AreEqual(CExpected, SQL.AsString);
end;

procedure TTestGpSQLBuilder.TestOrderBy;
const
  CExpected = 'SELECT * FROM Test ORDER BY Column1';
begin
  SQL
    .Select.All
    .From(DB_TEST)
    .OrderBy(COL_1);
  Assert.AreEqual(CExpected, SQL.AsString);
end;

procedure TTestGpSQLBuilder.TestOrderBy2;
const
  CExpected = 'SELECT * FROM Test ORDER BY Column1';
begin
  SQL
    .Select.All
    .From(DB_TEST)
    .OrderBy
      .Column(COL_1);
  Assert.AreEqual(CExpected, SQL.AsString);
end;

procedure TTestGpSQLBuilder.TestOrderByDesc;
const
  CExpected = 'SELECT * FROM Test ORDER BY Column1 DESC';
begin
  SQL
    .Select.All
    .From(DB_TEST)
    .OrderBy(COL_1).Desc;
  Assert.AreEqual(CExpected, SQL.AsString);
end;

procedure TTestGpSQLBuilder.TestOrderByTwoColumns;
const
  CExpected = 'SELECT * FROM Test ORDER BY Column1, Column2';
begin
  SQL
    .Select.All
    .From(DB_TEST)
    .OrderBy
      .Column(COL_1)
      .Column(COL_2);
  Assert.AreEqual(CExpected, SQL.AsString);
end;

procedure TTestGpSQLBuilder.TestOrderByTwoColumnsDesc1;
const
  CExpected = 'SELECT * FROM Test ORDER BY Column1 DESC, Column2';
begin
  SQL
    .Select.All
    .From(DB_TEST)
    .OrderBy
      .Column(COL_1).Desc
      .Column(COL_2);
  Assert.AreEqual(CExpected, SQL.AsString);
end;

procedure TTestGpSQLBuilder.TestOrderByTwoColumnsDesc2;
const
  CExpected = 'SELECT * FROM Test ORDER BY Column1, Column2 DESC';
begin
  SQL
    .Select.All
    .From(DB_TEST)
    .OrderBy
      .Column(COL_1)
      .Column(COL_2).Desc;
  Assert.AreEqual(CExpected, SQL.AsString);
end;

procedure TTestGpSQLBuilder.TestSectionEmpty;
begin
  Assert.IsTrue(SQL.Select.IsEmpty);
end;

procedure TTestGpSQLBuilder.TestSectionEmpty2;
begin
  SQL.Select.All;
  SQL.Select.Clear;
  Assert.IsTrue(SQL.Select.IsEmpty);
end;

procedure TTestGpSQLBuilder.TestSectionEmpty3;
begin
  SQL.Select.All;
  SQL.Select.Clear;
  SQL.GroupBy(COL_1);
  Assert.IsTrue(SQL.Select.IsEmpty);
end;

procedure TTestGpSQLBuilder.TestSectionNotEmpty;
begin
  SQL.Select.All;
  Assert.IsFalse(SQL.IsEmpty);
end;

procedure TTestGpSQLBuilder.TestSectionNotEmpty2;
begin
  SQL.Select.All;
  SQL.OrderBy;
  Assert.IsFalse(SQL.Select.IsEmpty);
end;

procedure TTestGpSQLBuilder.TestSelectAll;
const
  CExpected = 'SELECT * FROM Test';
begin
  SQL
    .Select('*')
    .From(DB_TEST);
  Assert.AreEqual(CExpected, SQL.AsString);
end;

procedure TTestGpSQLBuilder.TestSelectAll2;
const
  CExpected = 'SELECT * FROM Test';
begin
  SQL
    .Select.All
    .From(DB_TEST);
  Assert.AreEqual(CExpected, SQL.AsString);
end;

procedure TTestGpSQLBuilder.TestSelectColumn;
const
  CExpected = 'SELECT Column1 FROM Test';
begin
  SQL
    .Select(COL_1)
    .From(DB_TEST);
  Assert.AreEqual(CExpected, SQL.AsString);
end;

procedure TTestGpSQLBuilder.TestSelectColumn2;
const
  CExpected = 'SELECT Column1 FROM Test';
begin
  SQL
    .Select
      .Column(COL_1)
    .From(DB_TEST);
  Assert.AreEqual(CExpected, SQL.AsString);
end;

procedure TTestGpSQLBuilder.TestSelectDBColumn;
const
  CExpected = 'SELECT Test.Column1 FROM Test';
begin
  SQL
    .Select
      .Column(DB_TEST, COL_1)
    .From(DB_TEST);
  Assert.AreEqual(CExpected, SQL.AsString);
end;

procedure TTestGpSQLBuilder.TestSelectFirst;
const
  CExpected = 'SELECT FIRST 10 * FROM Test';
begin
  SQL
    .Select
      .First(10)
      .All
    .From(DB_TEST);
  Assert.AreEqual(CExpected, SQL.AsString);
end;

procedure TTestGpSQLBuilder.TestSelectFirstSkip;
const
  CExpected = 'SELECT FIRST 10 SKIP 5 * FROM Test';
begin
  SQL
    .Select
      .First(10)
      .Skip(5)
      .All
    .From(DB_TEST);
  Assert.AreEqual(CExpected, SQL.AsString);
end;

procedure TTestGpSQLBuilder.TestSelectTwoColumns;
const
  CExpected = 'SELECT Column1, Column2 FROM Test';
begin
  SQL
    .Select
      .Column(COL_1)
      .Column(COL_2)
    .From(DB_TEST);
  Assert.AreEqual(CExpected, SQL.AsString);
end;

procedure TTestGpSQLBuilder.TestSelectWhere;
const
  CExpected = 'SELECT * FROM Test WHERE Column2 > 0';
begin
  SQL
    .Select.All
    .From(DB_TEST)
    .Where([COL_2, '> 0']);
  Assert.AreEqual(CExpected, SQL.AsString);
end;

procedure TTestGpSQLBuilder.TestWhereAnd;
const
  CExpected = 'SELECT * FROM Test WHERE (Column1 IS NOT NULL) AND (Column2 > 0)';
begin
  SQL
    .Select.All
    .From(DB_TEST)
    .Where([COL_1, 'IS NOT NULL'])
      .&And([COL_2, '> 0']);
  Assert.AreEqual(CExpected, SQL.AsString);
end;

procedure TTestGpSQLBuilder.TestWhereAnd2;
const
  CExpected = 'SELECT * FROM Test WHERE (Column1 IS NOT NULL) AND (Column2 > 0)';
begin
  SQL
    .Select.All
    .From(DB_TEST)
    .Where
      .&And([COL_1, 'IS NOT NULL'])
      .&And([COL_2, '> 0']);
  Assert.AreEqual(CExpected, SQL.AsString);
end;

procedure TTestGpSQLBuilder.TestWhereAndOr;
const
  CExpected = 'SELECT * FROM Test WHERE ((Column1 IS NULL) OR (Column1 = 0)) AND ((Column2 > 0) OR (Column2 < 10))';
begin
  SQL
    .Select.All
    .From(DB_TEST)
    .Where
      .&And([COL_1, 'IS NULL'])
        .&Or([COL_1, '= 0'])
      .&And([COL_2, '> 0'])
        .&Or([COL_2, '< 10']);
  Assert.AreEqual(CExpected, SQL.AsString);
end;

procedure TTestGpSQLBuilder.TestWhereOr;
const
  CExpected = 'SELECT * FROM Test WHERE ((Column1 IS NOT NULL) OR (Column2 > 0))';
begin
  SQL
    .Select.All
    .From(DB_TEST)
    .Where([COL_1, 'IS NOT NULL'])
      .&Or([COL_2, '> 0']);
  Assert.AreEqual(CExpected, SQL.AsString);
end;

{ TTestGpSQLBuilderCase }

procedure TTestGpSQLBuilderCase.TestCase;
const
  CExpected = 'CASE WHEN Column2 < 0 THEN 0 WHEN Column2 > 100 THEN 2 ELSE 1 END';
var
  SQLCase: IGpSQLBuilderCase;
begin
  SQLCase := CreateGpSQLBuilder.&Case
    .When([COL_2, '< 0']).&Then('0')
    .When([COL_2, '> 100']).&Then('2')
    .&Else('1')
    .&End;
  Assert.AreEqual(CExpected, SQLCase.AsString);
end;

procedure TTestGpSQLBuilderCase.TestCase2;
const
  CExpected = 'CASE WHEN Column2 < 0 THEN 0 WHEN Column2 > 100 THEN 2 ELSE 1 END';
var
  SQLCase: IGpSQLBuilderCase;
begin
  SQLCase := CreateGpSQLBuilder.&Case
    .When([COL_2, '< 0']).&Then(0)
    .When([COL_2, '> 100']).&Then(2)
    .&Else(1)
    .&End;
  Assert.AreEqual(CExpected, SQLCase.AsString);
end;

procedure TTestGpSQLBuilderCase.TestCase3;
const
  CExpected = 'CASE Column2 WHEN 0 THEN ''A'' WHEN 1 THEN ''B'' END';
var
  SQLCase: IGpSQLBuilderCase;
begin
  SQLCase := CreateGpSQLBuilder.&Case(COL_2)
    .When([0]).&Then('''A''')
    .When([1]).&Then('''B''')
    .&End;
  Assert.AreEqual(CExpected, SQLCase.AsString);
end;

procedure TTestGpSQLBuilderCase.TestCaseAndOr;
const
  CExpected = 'CASE WHEN (Column2 < 0) AND (Column1 IS NOT NULL) THEN 0 ' +
    'WHEN ((Column2 > 100) OR (Column1 IS NULL)) THEN 2 ELSE 1 END';
var
  SQLCase: IGpSQLBuilderCase;
begin
  SQLCase := CreateGpSQLBuilder.&Case
    .When([COL_2, '< 0'])
      .&And([COL_1, 'IS NOT NULL'])
      .&Then(0)
    .When([COL_2, '> 100'])
      .&Or([COL_1, 'IS NULL'])
      .&Then(2)
    .&Else(1)
    .&End;
  Assert.AreEqual(CExpected, SQLCase.AsString);
end;

{ TTestGpSQLBuilderExpression }

procedure TTestGpSQLBuilderExpression.TestAnd;
const
  CExpected = '(Column1 IS NOT NULL) AND (Column2 > 0)';
var
  expr: IGpSQLBuilderExpression;
begin
  expr := CreateGpSQLBuilder.Expression;
  expr
    .&And([COL_1, 'IS NOT NULL'])
    .&And([COL_2, '> 0']);
  Assert.IsTrue(expr.Expression.Operation = opAnd);
  Assert.IsTrue(expr.Expression.Left.Operation = opNone);
  Assert.AreEqual(expr.Expression.Left.Term, 'Column1 IS NOT NULL');
  Assert.IsTrue(expr.Expression.Right.Operation = opNone);
  Assert.AreEqual(expr.Expression.Right.Term, 'Column2 > 0');
  Assert.AreEqual(CExpected, expr.AsString);
end;

procedure TTestGpSQLBuilderExpression.TestAnd2;
const
  CExpected = '(Column1 IS NOT NULL) AND (Column2 > 0)';
var
  expr: IGpSQLBuilderExpression;
begin
  expr := CreateGpSQLBuilder.Expression([COL_1, 'IS NOT NULL']);
  expr.&And([COL_2, '> 0']);
  Assert.IsTrue(expr.Expression.Operation = opAnd);
  Assert.IsTrue(expr.Expression.Left.Operation = opNone);
  Assert.AreEqual(expr.Expression.Left.Term, 'Column1 IS NOT NULL');
  Assert.IsTrue(expr.Expression.Right.Operation = opNone);
  Assert.AreEqual(expr.Expression.Right.Term, 'Column2 > 0');
  Assert.AreEqual(CExpected, expr.AsString);
end;

procedure TTestGpSQLBuilderExpression.TestAndOr;
const
  CExpected = '((Column1 IS NULL) OR (Column1 = 0)) AND ((Column2 > 0) OR (Column2 < 10))';
var
  expr: IGpSQLBuilderExpression;
begin
  expr := CreateGpSQLBuilder.Expression;
  expr
    .&And([COL_1, 'IS NULL'])
      .&Or([COL_1, '= 0'])
    .&And([COL_2, '> 0'])
      .&Or([COL_2, '< 10']);
  Assert.IsTrue(expr.Expression.Operation = opAnd);
  Assert.IsTrue(expr.Expression.Left.Operation = opOr);
  Assert.AreEqual(expr.Expression.Left.Left.Term, 'Column1 IS NULL');
  Assert.AreEqual(expr.Expression.Left.Right.Term, 'Column1 = 0');
  Assert.IsTrue(expr.Expression.Right.Operation = opOr);
  Assert.AreEqual(expr.Expression.Right.Left.Term, 'Column2 > 0');
  Assert.AreEqual(expr.Expression.Right.Right.Term, 'Column2 < 10');
  Assert.AreEqual(CExpected, expr.AsString);
end;

procedure TTestGpSQLBuilderExpression.TestOr;
const
  CExpected = '((Column1 IS NOT NULL) OR (Column2 > 0))';
var
  expr: IGpSQLBuilderExpression;
begin
  expr := CreateGpSQLBuilder.Expression([COL_1, 'IS NOT NULL']);
  expr.&Or([COL_2, '> 0']);
  Assert.IsTrue(expr.Expression.Operation = opOr);
  Assert.IsTrue(expr.Expression.Left.Operation = opNone);
  Assert.AreEqual(expr.Expression.Left.Term, 'Column1 IS NOT NULL');
  Assert.IsTrue(expr.Expression.Right.Operation = opNone);
  Assert.AreEqual(expr.Expression.Right.Term, 'Column2 > 0');
  Assert.AreEqual(CExpected, expr.AsString);
end;

initialization
  TDUnitX.RegisterTestFixture(TTestGpSQLBuilder);
end.
