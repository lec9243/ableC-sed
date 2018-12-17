grammar edu:umn:cs:melt:exts:ableC:sed:abstractsyntax;

imports edu:umn:cs:melt:ableC:abstractsyntax:env;
imports edu:umn:cs:melt:ableC:abstractsyntax:host;
imports edu:umn:cs:melt:ableC:abstractsyntax:construction;
imports edu:umn:cs:melt:ableC:abstractsyntax:substitution;
imports edu:umn:cs:melt:ableC:abstractsyntax:construction:parsing;
imports edu:umn:cs:melt:ableC:abstractsyntax:overloadable;

imports silver:langutil;
imports silver:langutil:pp;

nonterminal Commands;
nonterminal ComdList with comds;
nonterminal Comd with comds;
nonterminal AddExpr with addlist;

synthesized attribute addlist :: [Integer];
synthesized attribute c :: Expr occurs on Commands;
synthesized attribute comds :: [Pair<Commands Commands>];


  abstract production sedProgram
  top::Expr ::= cl::ComdList inf::String outf::String
  {
    local input::[Pair<Expr Expr>] = convertComds(cl.comds, []);
    local infile::String = inf;
    local outfile::String = outf;
    local d::Decl =
      variableDecls(nilStorageClass(), nilAttribute(),
        tagReferenceTypeExpr(nilQualifier(), structSEU(),
          name("SedCommand", location=builtin)),
        foldDeclarator([
          declarator(name("cmds", location=builtin),
            arrayTypeExprWithoutExpr(baseTypeExpr(), nilQualifier(),
              normalArraySize()),
            nilAttribute(),
            justInitializer(objectInitializer(
              foldInit(
                map(\i::Pair<Expr Expr> ->
                  positionalInit(objectInitializer(
                    foldInit([
                      positionalInit(exprInitializer(i.fst)),
                      positionalInit(exprInitializer(i.snd))
                    ]))),
                  input)))))]));

    local fwrd::Expr =
    ableC_Expr {
    ({    $Decl{d};

          struct SedProgram sed_program = {
                  cmds, $intLiteralExpr{length(input)}
          };
          FILE *fptr;
          FILE *fred;
          run_sed_program(&sed_program, fptr, fred, $name{infile}, $name{outfile});})
    };
    forwards to fwrd;
  }

  function convertComds
  [Pair<Expr Expr>] ::= cl::[Pair<Commands Commands>] accu::[Pair<Expr Expr>]
  {
    return if null(cl)
           then accu
           else
           accu ++ [pair(head(cl).fst.c, head(cl).snd.c)] ++ convertComds(tail(cl)
, accu);
  }

  abstract production emptyAddr
  top::Commands ::=
  {
    top.c = ableC_Expr { malloc_AnyAddr() };
  }

  abstract production lineAddr
  top::Commands ::= i::Integer
  {
    top.c = ableC_Expr { malloc_LineAddr($intLiteralExpr{i}) };
  }

  abstract production lineRangeAddr
  top::Commands ::= i::Integer j::Integer
  {
    top.c = ableC_Expr { malloc_LineRangeAddr($intLiteralExpr{i}, $intLiteralExpr{
j}) } ;
  }

  abstract production deletei
  top::Commands ::=
  {
    top.c = ableC_Expr { malloc_Delete() };
  }

  abstract production appendi
  top::Commands ::= s::String
  {
    top.c = ableC_Expr { malloc_Append($stringLiteralExpr{s}) };
  }

  abstract production searchi
  top::Commands ::= tx::String st::String
  {
    top.c = ableC_Expr { malloc_Search($stringLiteralExpr{tx}, $stringLiteralExpr{st}) };
  }

  abstract production consComd
  top::ComdList ::= cl::ComdList c::Comd
  {
    top.comds = c.comds ++ cl.comds;
  }

  abstract production nilComd
  top::ComdList ::=
  {
    top.comds = [];
  }

  abstract production deleteComd
  top::Comd ::= add::AddExpr
  {
    top.comds = case add.addlist of
    |[x] -> [ pair( lineAddr(x), deletei() )]
    |[x,y] -> [ pair( lineRangeAddr(x,y), deletei() )]
    |[ ] -> [pair( emptyAddr(), deletei() )]
    end;

  }

  abstract production appendComd
  top::Comd ::= add::AddExpr tx::String
  {
  top.comds = case add.addlist of
  |[x] -> [ pair( lineAddr(x), appendi(toString(tx)) )]
  |[x,y] -> [ pair( lineRangeAddr(x,y), appendi(toString(tx)) )]
  |[ ] -> [pair( emptyAddr(), appendi(toString(tx)) )]
  end;
  }

  abstract production searchComd
  top::Comd ::= add::AddExpr tx::String st::String
  {
  top.comds = case add.addlist of
  |[x] -> [ pair( lineAddr(x), searchi(toString(tx), toString(st)) )]
  |[x,y] -> [ pair( lineRangeAddr(x,y), searchi(toString(tx), toString(st)) )]
  |[ ] -> [pair( emptyAddr(), searchi(toString(tx), toString(st)) )]
  end;
  }

  abstract production nilAddrs
  top::AddExpr ::=
  {
    top.addlist = [ ];
  }

  abstract production oneAddrs
  top::AddExpr ::= e::String
  {
    top.addlist = [toInteger(e)];
  }

  abstract production rangeAddr
  top::AddExpr ::= e::String e1::String
  {
    top.addlist = [toInteger(e), toInteger(e1)];
  }

  abstract production findAddr
  top::AddExpr ::= s::String
  {
    top.addlist = [0];
  }

global builtin::Location = builtinLoc("sed");
