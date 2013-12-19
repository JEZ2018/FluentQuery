unit Generics.Collections.Query.Types;

interface
uses
  System.SysUtils;

type
  IMinimalEnumerator<T> = interface
    function MoveNext: Boolean;
    function GetCurrent: T;
    property Current: T read GetCurrent;
  end;

  IQueryEnumerator<T> = interface(IMinimalEnumerator<T>)
    function First : IQueryEnumerator<T>;
    function Skip(Count : Integer): IQueryEnumerator<T>;
    function SkipWhile(Predicate : TPredicate<T>) : IQueryEnumerator<T>;
    function Take(Count : Integer): IQueryEnumerator<T>;
    function TakeWhile(Predicate : TPredicate<T>): IQueryEnumerator<T>;
    function Where(Predicate : TPredicate<T>) : IQueryEnumerator<T>;
    function GetEnumerator: IQueryEnumerator<T>;
  end;

  IStringQueryEnumerator = interface(IMinimalEnumerator<String>)
    function First : IStringQueryEnumerator;
    function Foo : IStringQueryEnumerator;
    function Skip(Count : Integer): IStringQueryEnumerator;
    function SkipWhile(Predicate : TPredicate<String>) : IStringQueryEnumerator;
    function Take(Count : Integer): IStringQueryEnumerator;
    function TakeWhile(Predicate : TPredicate<String>): IStringQueryEnumerator;
    function Where(Predicate : TPredicate<String>) : IStringQueryEnumerator;
    function GetEnumerator: IStringQueryEnumerator;
  end;


implementation

end.