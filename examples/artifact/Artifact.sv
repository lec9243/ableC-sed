grammar artifact;

import edu:umn:cs:melt:ableC:concretesyntax as cst;
import edu:umn:cs:melt:ableC:drivers:compile;


parser extendedParser :: cst:Root {
  edu:umn:cs:melt:exts:ableC:algebraicDataTypes prefix with "ADT";
  edu:umn:cs:melt:ableC:concretesyntax;
  edu:umn:cs:melt:exts:ableC:regex prefix with "RX";
  edu:umn:cs:melt:exts:ableC:sed;

  prefer edu:umn:cs:melt:exts:ableC:algebraicDataTypes:patternmatching:concretesyntax:Match_t
  over
  edu:umn:cs:melt:exts:ableC:regex:regexMatchingVerbose:RegexMatch_t;
}

function main
IOVal<Integer> ::= args::[String] io_in::IO
{
  return driver(args, io_in, extendedParser);
}
