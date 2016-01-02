function out = updateFrench(in)
  f_replace = '$1$2 $3';
  % Singular definite article
  out = regexprep(in, '([*]? )(l'')([^ ][*]?)', f_replace);
  % Single-consonant words
  out = regexprep(out, '([*]? )([cdjtmns]'')([^ ][*]?)', f_replace);
  % que
  out = regexprep(out, '([*]? )(qu'')([^ ][*]?)', f_replace);
  % Conjunctions - puisque and lorsque
  out = regexprep(out, '([*]? )(puisqu''|lorsqu'')(on|il)', f_replace);
  % d'abord, d'accord, d'ailleurs, d'habitude
  out = regexprep(out, '([*]? )(d'') (abord|accord|ailleurs||habitude)( [*]?)', '$1$2$3$4');
