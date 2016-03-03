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
  outSentence = separatePunctuation(outSentence);


  switch language
   case 'e'
    e_replace = '$1 $2$3';
    %outSentence = regexprep(outSentence, '(.*?[^ ])(''|''s|''ll|.''.*)( .*?)', e_replace);
    outSentence = regexprep(outSentence, '(.*?[^ ])(''s|''|''ll)( .*?)', e_replace);
    %outSentence = regexprep(outSentence, '(.*?[^ ])('')( .*?)', '$1 $2$3');
    %outSentence = regexprep(outSentence, '(.*?[^ ])(''s)( .*?)', '$1 $2$3');
    %utSentence = regexprep(outSentence, '(.*?[^ ])(''ll)( .*?)', '$1 $2$3');
    %outSentence = regexprep(outSentence, '(.*?[^ ])(.''.*)( .*?)', '$1 $2$3');
   case 'f'
    outSentence = updateFrench(outSentence);
  end

  % change unpleasant characters to codes that can be keys in dictionaries
  outSentence = convertSymbols( outSentence );

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
