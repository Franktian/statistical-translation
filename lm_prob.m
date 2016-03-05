function logProb = lm_prob(sentence, LM, type, delta, vocabSize)
%
%  lm_prob
% 
%  This function computes the LOG probability of a sentence, given a 
%  language model and whether or not to apply add-delta smoothing
%
%  INPUTS:
%
%       sentence  : (string) The sentence whose probability we wish
%                            to compute
%       LM        : (variable) the LM structure (not the filename)
%       type      : (string) either '' (default) or 'smooth' for add-delta smoothing
%       delta     : (float) smoothing parameter where 0<delta<=1 
%       vocabSize : (integer) the number of words in the vocabulary
%
% Template (c) 2011 Frank Rudzicz

  logProb = -Inf;

  % some rudimentary parameter checking
  if (nargin < 2)
    disp( 'lm_prob takes at least 2 parameters');
    return;
  elseif nargin == 2
    type = '';
    delta = 0;
    vocabSize = length(fieldnames(LM.uni));
  end
  if (isempty(type))
    delta = 0;
    vocabSize = length(fieldnames(LM.uni));
  elseif strcmp(type, 'smooth')
    if (nargin < 5)  
      disp( 'lm_prob: if you specify smoothing, you need all 5 parameters');
      return;
    end
    if (delta <= 0) or (delta > 1.0)
      disp( 'lm_prob: you must specify 0 < delta <= 1.0');
      return;
    end
  else
    disp( 'type must be either '''' or ''smooth''' );
    return;
  end

  sentence = lower( sentence );

  words = strsplit(' ', sentence);

  logProb = 0;
  for i = 1:length(words) - 1
      unicount = 0;
      bicount = 0;
      
      % Count the bigram
      if isfield(LM.bi, words{i}) && isfield(LM.bi.(words{i}), words{i+1})
          bicount = LM.bi.(words{i}).(words{i+1});
      end

      % Count the unigram
      if isfield(LM.uni, words{i})
          unicount = LM.uni.(words{i});
      end

      % Count numerator and denominator of the MLE, take
      % laplace smoonthing into consideration
      numerator = bicount + delta;
      denominator = unicount + delta * vocabSize;

      % 0/0 situation, the prob of test sentence is 0
      if numerator == 0 && denominator == 0
          logProb = -Inf;
          return;
      else
          logProb = logProb + log2(numerator) - log2(denominator);
      end
  end

return