function out = separatePunctuation ( in )
  replace = '$1 $2 $3';
  sen_final_punc = '([*]?)([?.!]+) (SENTEND)';
  sen_punc = '([*]?)([;=-+\(\)<>,;:])([*]?)';
  dashes = '([*]?\([*]?)(-)([*]?\)[*]?)';

  out = regexprep(in, sen_final_punc, replace);
  out = regexprep(out, sen_punc, replace);
  out = regexprep(out, dashes, replace);