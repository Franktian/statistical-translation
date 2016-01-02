function out = separatePunctuation(in)
  % Separate sentence-final punctuation, commas, colons and semicolons,
  % parentheses, dashes between parentheses, mathematical operators,
  % and quotation marks.

  replace = '$1 $2 $3';
  sen_final_punc = '([*]?)([?.!]+) (SENTEND)';
  sen_punc = '([*]?)([;=-+\(\)<>,;:])([*]?)';
  dashes = '([*]?\([*]?)(-)([*]?\)[*]?)';

  out = regexprep(in, sen_final_punc, replace);
  out = regexprep(out, sen_punc, replace);
  out = regexprep(out, dashes, replace);
