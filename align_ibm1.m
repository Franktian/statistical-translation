function AM = align_ibm1(trainDir, numSentences, maxIter, fn_AM)
%
%  align_ibm1
% 
%  This function implements the training of the IBM-1 word alignment algorithm. 
%  We assume that we are implementing P(foreign|english)
%
%  INPUTS:
%
%       dataDir      : (directory name) The top-level directory containing 
%                                       data from which to train or decode
%                                       e.g., '/u/cs401/A2_SMT/data/Toy/'
%       numSentences : (integer) The maximum number of training sentences to
%                                consider. 
%       maxIter      : (integer) The maximum number of iterations of the EM 
%                                algorithm.
%       fn_AM        : (filename) the location to save the alignment model,
%                                 once trained.
%
%  OUTPUT:
%       AM           : (variable) a specialized alignment model structure
%
%
%  The file fn_AM must contain the data structure called 'AM', which is a 
%  structure of structures where AM.(english_word).(foreign_word) is the
%  computed expectation that foreign_word is produced by english_word
%
%       e.g., LM.house.maison = 0.5       % TODO
% 
% Template (c) 2011 Jackie C.K. Cheung and Frank Rudzicz
  
  global CSC401_A2_DEFNS
  
  AM = struct();
  
  % Read in the training data
  [eng, fre] = read_hansard(trainDir, numSentences);

  % Initialize AM uniformly 
  AM = initialize(eng, fre);

  % Iterate between E and M steps
  for iter=1:maxIter,
    AM = em_step(AM, eng, fre);
  end

  % Save the alignment model
  save( fn_AM, 'AM', '-mat'); 

  end





% --------------------------------------------------------------------------------
% 
%  Support functions
%
% --------------------------------------------------------------------------------

function [eng, fre] = read_hansard(mydir, numSentences)
%
% Read 'numSentences' parallel sentences from texts in the 'dir' directory.
%
% Important: Be sure to preprocess those texts!
%
% Remember that the i^th line in fubar.e corresponds to the i^th line in fubar.f
% You can decide what form variables 'eng' and 'fre' take, although it may be easiest
% if both 'eng' and 'fre' are cell-arrays of cell-arrays, where the i^th element of 
% 'eng', for example, is a cell-array of words that you can produce with
%
%         eng{i} = strsplit(' ', preprocess(english_sentence, 'e'));
%
  eng = {};
  fre = {};

  % TODO: your code goes here.
  DE = dir( [ mydir, filesep, '*', 'e'] );
  DF = dir( [ mydir, filesep, '*', 'f'] );
  
  for iFile=1:length(DE)
    englines = textread([mydir, filesep, DE(iFile).name], '%s','delimiter','\n');
    frelines = textread([mydir, filesep, DF(iFile).name], '%s','delimiter','\n');
    for l=1:length(englines)
        eng{l} = strsplit(' ', preprocess(englines{l}, 'e'));
        fre{l} = strsplit(' ', preprocess(frelines{l}, 'e'));
        if l > numSentences
            return
        end
    end
  end

end


function AM = initialize(eng, fre)
%
% Initialize alignment model uniformly.
% Only set non-zero probabilities where word pairs appear in corresponding sentences.
%
    AM = {}; % AM.(english_word).(foreign_word)
    for l=1:length(eng)
        for en = 2:length(eng{l}) -1
            for fr = 2:length(fre{l}) -1
                if ~isfield(AM, eng{l}{en})
                    AM.(eng{l}{en}) = struct();
                end
                if ~isfield(AM.(eng{l}{en}), fre{l}{fr})
                    AM.(eng{l}{en}).(fre{l}{fr}) = 1;
                end
            end
        end
    end
    
    en_words = fieldnames(AM);
    for en = 1:length(en_words)
        fr_words = fieldnames(AM.(en_words{en}));
        for fr = 1:length(fr_words)
            AM.(en_words{en}).(fr_words{fr}) = 1 / length(fields(AM.(en_words{en})));
        end
    end
    

end

function t = em_step(t, eng, fre)
% 
% One step in the EM algorithm.
%
  
  % TODO: your code goes here
end


