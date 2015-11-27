unit FluentQuery.DB.Tests;
{

  Delphi DUnit Test Case
  ----------------------
  This unit contains a skeleton test case class generated by the Test Case Wizard.
  Modify the generated code to correctly setup and call the methods from the unit 
  being tested.

}

interface

uses
  TestFramework, FluentQuery.Core.Types, FluentQuery.DB, Data.DB,
  FireDAC.Comp.Client;

type
  TestTDBRecord = class(TTestCase)
  strict private
    FMemTable : TFDMemTable;
  public
    procedure SetUp; override;
    procedure TearDown; override;
  published
    procedure TestFieldByName;
    procedure TestEditAndPost;
    procedure TestEditAndCancel;
  end;

  TestTDBRecordQuery = class(TTestCase)
  strict private
    FMemTable : TFDMemTable;
  public
    procedure SetUp; override;
    procedure TearDown; override;
  published
    procedure TestPassthroughEmptyDataset;
    procedure TestPassthrough;
    procedure TestWherePredicate;
  end;

implementation
uses
  System.SysUtils;

procedure InitMemTable(MemTable : TFDMemTable);
var
  LNameField, LAgeField : TFieldDef;
begin
  LNameField := MemTable.FieldDefs.AddFieldDef;
  LNameField.Name := 'Name';
  LNameField.DataType := ftString;
  LNameField.Size := 50;

  LAgeField := MemTable.FieldDefs.AddFieldDef;
  LAgeField.Name := 'Age';
  LAgeField.DataType := ftInteger;

  MemTable.Open;
  MemTable.Append;
  MemTable.Fields[0].AsString := 'Malcolm';
  MemTable.Fields[1].AsInteger := 45;
  MemTable.Post;

  MemTable.Append;
  MemTable.Fields[0].AsString := 'Julie';
  MemTable.Fields[1].AsInteger := 43;
  MemTable.Post;
end;

procedure TestTDBRecordQuery.SetUp;
begin
  FMemTable := TFDMemTable.Create(nil);
  InitMemTable(FMemTable)
end;

procedure TestTDBRecordQuery.TearDown;
begin
  FMemTable.Close;
  FMemTable.Free;
end;


procedure TestTDBRecordQuery.TestPassthrough;
var
  LDBRecord : TDBRecord;
  LPassCount : Integer;
begin
  LPassCount := 0;

  for LDBRecord in DBRecordQuery.From(FMemTable) do
    Inc(LPassCount);

  CheckEquals(2, LPassCount);
end;

procedure TestTDBRecordQuery.TestPassthroughEmptyDataset;
var
  LDBRecord : TDBRecord;
  LPassCount : Integer;
begin
  FMemTable.Last;
  repeat
    FMemTable.Delete;
  until (FMemTable.Bof);
  CheckEquals(0, FMemTable.RecordCount, 'FMemTable should be empty at this point');

  LPassCount := 0;

  for LDBRecord in DBRecordQuery.From(FMemTable) do
    Inc(LPassCount);

  CheckEquals(0, LPassCount, 'Should have enumerated no records, as dataset is empty');
end;

procedure TestTDBRecordQuery.TestWherePredicate;
var
  LDBRecord : TDBRecord;
  LPassCount : Integer;
  LPredicate : TPredicate<TDBRecord>;
begin
  LPassCount := 0;

  LPredicate := function(Value : TDBRecord) : boolean
                begin
                  Result := Value.FieldByName('Age').AsInteger > 43;
                end;

  for LDBRecord in DBRecordQuery.From(FMemTable).Where(LPredicate) do
    Inc(LPassCount);

  CheckEquals(1, LPassCount);
end;

{ TestTDBRecord }

procedure TestTDBRecord.SetUp;
begin
  FMemTable := TFDMemTable.Create(nil);
  InitMemTable(FMemTable);
end;

procedure TestTDBRecord.TearDown;
begin
  FMemTable.Free;
end;

procedure TestTDBRecord.TestEditAndCancel;
var
  LDBRecord : TDBRecord;
  LPassCount : Integer;
begin
  for LDBRecord in DBRecordQuery.From(FMemTable) do
  begin
    LDBRecord.Edit;
    LDBRecord.FieldByName('Age').AsInteger := 5;
    LDBRecord.Cancel;
  end;

  LPassCount := 0;
  FMemTable.First;
  while not FMemTable.Eof do
  begin
    Inc(LPassCount);
    case LPassCount of
       1 : begin
             CheckEqualsString('Malcolm', FMemTable.FieldByName('Name').AsString);
             CheckEquals(45, FMemTable.FieldByName('Age').AsInteger);
           end;
       2 : begin
             CheckEqualsString('Julie', FMemTable.FieldByName('Name').AsString);
             CheckEquals(43, FMemTable.FieldByName('Age').AsInteger);
           end;
    end;
    FMemTable.Next;
  end;
end;

procedure TestTDBRecord.TestEditAndPost;
var
  LDBRecord : TDBRecord;
  LPassCount : Integer;
begin
  for LDBRecord in DBRecordQuery.From(FMemTable) do
  begin
    LDBRecord.Edit;
    LDBRecord.FieldByName('Age').AsInteger := 5;
    LDBRecord.Post;
  end;

  LPassCount := 0;
  FMemTable.First;
  while not FMemTable.Eof do
  begin
    Inc(LPassCount);
    case LPassCount of
       1 : begin
             CheckEqualsString('Malcolm', FMemTable.FieldByName('Name').AsString);
             CheckEquals(5, FMemTable.FieldByName('Age').AsInteger);
           end;
       2 : begin
             CheckEqualsString('Julie', FMemTable.FieldByName('Name').AsString);
             CheckEquals(5, FMemTable.FieldByName('Age').AsInteger);
           end;
    end;
    FMemTable.Next;
  end;
end;

procedure TestTDBRecord.TestFieldByName;
var
  LDBRecord : TDBRecord;
  LPassCount : Integer;
begin
  LPassCount := 0;
  for LDBRecord in DBRecordQuery.From(FMemTable) do
  begin
    Inc(LPassCount);
    case LPassCount of
       1 : begin
             CheckEqualsString('Malcolm', LDBRecord.FieldByName('Name').AsString);
             CheckEquals(45, LDBRecord.FieldByName('Age').AsInteger);
           end;
       2 : begin
             CheckEqualsString('Julie', LDBRecord.FieldByName('Name').AsString);
             CheckEquals(43, LDBRecord.FieldByName('Age').AsInteger);
           end;
    end;
  end;
end;

initialization
  // Register any test cases with the test runner
  RegisterTest('DB', TestTDBRecordQuery.Suite);
  RegisterTest('DB', TestTDBRecord.Suite);
end.

