function outSentence = preprocess( inSentence, language )
%
%  preprocess
%
%  This function preprocesses the input text according to language-specific rules.
%  Specifically, we separate contractions according to the source language, convert
%  all tokens to lower-case, and separate end-of-sentence punctuation 
%
%  INPUTS:
%       inSentence     : (string) the original sentence to be processed 
%                                 (e.g., a line from the Hansard)
%       language       : (string) either 'e' (English) or 'f' (French) 
%                                 according to the language of inSentence
%
%  OUTPUT:
%       outSentence    : (string) the modified sentence
%
%  Template (c) 2011 Frank Rudzicz 

  global CSC401_A2_DEFNS
  
  % first, convert the input sentence to lower-case and add sentence marks 
  inSentence = [CSC401_A2_DEFNS.SENTSTART ' ' lower( inSentence ) ' ' CSC401_A2_DEFNS.SENTEND];

  % trim whitespaces down 
  inSentence = regexprep( inSentence, '\s+', ' '); 

  % initialize outSentence
  outSentence = inSentence;

  % perform language-agnostic changes
  % TODO: your code here
  %    e.g., outSentence = regexprep( outSentence, 'TODO', 'TODO');

  % Separate sentence-final punctuation, commas, colons and semicolons,
  % parentheses, dashes between parentheses, mathematical operators,
  % and quotation marks.
  replace = '$1 $2 $3';
  sen_final_punc = '([*]?)([?.!]+) (SENTEND)';
  sen_punc = '([*]?)([;=-+\(\)<>,;:])([*]?)';
  dashes = '([*]?\([*]?)(-)([*]?\)[*]?)';

  outSentence = regexprep(outSentence, sen_final_punc, replace);
  outSentence = regexprep(outSentence, sen_punc, replace);
  outSentence = regexprep(outSentence, dashes, replace);


  switch language
   case 'e'
    e_replace = '$1 $2$3';
    outSentence = regexprep(outSentence, '([*]?)(''|''s|''ll|.''.*)( [*]?)', e_replace);

   case 'f'
    f_replace = '$1$2 $3';
    % Singular definite article
    outSentence = regexprep(outSentence, '([*]? )(l'')([^ ][*]?)', f_replace);
    % Single-consonant words
    outSentence = regexprep(outSentence, '([*]? )([cdjtmns]'')([^ ][*]?)', f_replace);
    % que
    outSentence = regexprep(outSentence, '([*]? )(qu'')([^ ][*]?)', f_replace);
    % Conjunctions - puisque and lorsque
    outSentence = regexprep(outSentence, '([*]? )(puisqu''|lorsqu'')(on|il)', f_replace);
    % d'abord, d'accord, d'ailleurs, d'habitude
    outSentence = regexprep(outSentence, '(d'') (abord|accord|ailleurs||habitude)', '$1$2');
  end

  % change unpleasant characters to codes that can be keys in dictionaries
  outSentence = convertSymbols( outSentence );

