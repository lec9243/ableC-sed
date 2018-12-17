grammar  edu:umn:cs:melt:exts:ableC:sed:concretesyntax;

imports edu:umn:cs:melt:exts:ableC:regex;
imports edu:umn:cs:melt:ableC:concretesyntax;
imports edu:umn:cs:melt:ableC:abstractsyntax:host;
imports edu:umn:cs:melt:ableC:abstractsyntax:construction;
imports edu:umn:cs:melt:exts:ableC:sed:abstractsyntax;

imports silver:langutil only ast;

marking terminal SedExpr_t  'sed'  lexer classes {Ckeyword};
terminal SearchExpr_t 's';
terminal DeleteExpr_t 'd';
terminal AppendExpr_t 'a';
terminal SemiColon_t ';';
terminal Greater_t '>';


concrete production sedScript_c
top::AssignExpr_c ::= 'sed' '{' cl::SedCommandList_c '}' infile::StringConstant_t '>' outfile::StringConstant_t
{
  top.ast = sedProgram(cl.ast_ComdList, infile.lexeme, outfile.lexeme, location=top.location);
}


nonterminal SedCommandList_c with ast_ComdList;
synthesized attribute ast_ComdList::ComdList;
concrete productions
top::SedCommandList_c
| c::SedCommand_c ';' cl::SedCommandList_c
     { top.ast_ComdList = consComd(cl.ast_ComdList, c.ast_Comd); }
|
     { top.ast_ComdList = nilComd(); }



nonterminal SedCommand_c with ast_Comd;
synthesized attribute ast_Comd::Comd;
concrete productions
top::SedCommand_c
| addr::SedAddr_c 'd'
    { top.ast_Comd = deleteComd(addr.ast_Addr); }
| addr::SedAddr_c 'a' tx::StringConstant_t
    { top.ast_Comd = appendComd(addr.ast_Addr, tx.lexeme); }
| addr::SedAddr_c 's' re::StringConstant_t st::StringConstant_t
    { top.ast_Comd = searchComd(addr.ast_Addr, re.lexeme, st.lexeme); }



nonterminal RegX_c with regString, repast;
synthesized attribute repast :: Expr;
concrete production sedRegex_c
top::RegX_c ::= RegexEnd_t tar::Regex_R RegexEnd_t LParen_t rep::Expr_c RParen_t RegexEnd_t
layout{ }
{
  top.regString = tar.regString;
  top.repast = rep.ast;
}

nonterminal SedAddr_c with ast_Addr;
synthesized attribute ast_Addr::AddExpr;
concrete productions
top::SedAddr_c
|
  { top.ast_Addr = nilAddrs(); }
| e::DecConstant_t
  { top.ast_Addr = oneAddrs(e.lexeme); }
| e::DecConstant_t '~' e1::DecConstant_t
  { top.ast_Addr = rangeAddr(e.lexeme, e1.lexeme); }
| RegexEnd_t tar::Regex_R RegexEnd_t
  layout{ }
  { top.ast_Addr = findAddr(tar.regString); }
