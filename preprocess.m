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

  % Separate punctuations
  outSentence = separatePunctuation(outSentence);

  switch language
   case 'e'
    outSentence = regexprep(outSentence, '''', ' ''');
   case 'f'
    outSentence = updateFrench(outSentence);
  end

  % Set all multiple white spaces to single one
  outSentence = regexprep(outSentence, '[ ]+', ' ');
  % change unpleasant characters to codes that can be keys in dictionaries
  outSentence = convertSymbols( outSentence );

function out = separatePunctuation(in)
  % Separate sentence-final punctuation, commas, colons and semicolons,
  % parentheses, dashes between parentheses, mathematical operators,
  % and quotation marks.

    sen_final_punc = '[?.!]+ SENTEND';
    separate = ' $0 ';
%   sen_punc = '[":;{}[](),.<>]';
%   symbol = '[=+-/*^]';
    out = regexprep(in, '\*', separate);
    out = regexprep(out, '\-', separate);
    out = regexprep(out, '\+', separate);
    out = regexprep(out, '\=', separate);
    out = regexprep(out, '\,', separate);
    out = regexprep(out, '\.', separate);
    out = regexprep(out, '\?', separate);
    out = regexprep(out, '\!', separate);
    out = regexprep(out, ':', separate);
    out = regexprep(out, ';', separate);
    % out = regexprep(out, '''', separate);
    out = regexprep(out, '"', separate);
    out = regexprep(out, '`', separate);
    out = regexprep(out, '\(', separate);
    out = regexprep(out, '\)', separate);
    out = regexprep(out, '\[', separate);
    out = regexprep(out, '\]', separate);
    out = regexprep(out, '/', separate);
    out = regexprep(out, '\$', separate);
    out = regexprep(out, '\%', separate);
    out = regexprep(out, '\&', separate);
    out = regexprep(out, '<', separate);
    out = regexprep(out, '>', separate);

%     out = regexprep(in, sen_final_punc, ' $0');
%     out = regexprep(out, sen_punc, ' $0 ');
%     out = regexprep(out, symbol, ' $0 ');

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
