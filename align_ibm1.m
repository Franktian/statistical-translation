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

  AM.SENTSTART.SENTSTART = 1;
  AM.SENTEND.SENTEND = 1;

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

  % Setup folders to read data
  DE = dir( [ mydir, filesep, '*', 'e'] );
  DF = dir( [ mydir, filesep, '*', 'f'] );
  
  lines_read = 1;

  for iFile=1:length(DE)
        % Read in english and french sentences, note there is a one-to-one
        % relationship
        englines = textread([mydir, filesep, DE(iFile).name], '%s','delimiter','\n');
        frelines = textread([mydir, filesep, DF(iFile).name], '%s','delimiter','\n');

        for l=1:length(englines)
            eng{lines_read} = strsplit(' ', preprocess(englines{l}, 'e'));
            fre{lines_read} = strsplit(' ', preprocess(frelines{l}, 'f'));

            % Count on the lines read in already, if greater than
            % numSentences, then return
            lines_read = lines_read + 1;
            if lines_read > numSentences
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

    % For every english word in a sentence align the french word in the
    % corresponding sentence
    disp(length(eng));
    for l=1:length(eng)
        disp(eng{l});
        for en = 2:length(eng{l}) - 1
            for fr = 2:length(fre{l}) - 1
                AM.(eng{l}{en}).(fre{l}{fr}) = 1;
            end
        end
    end

    % Normalize the count with the prob in the sentence
    en_words = fieldnames(AM);
    for en = 1:length(en_words)
        fr_words = fieldnames(AM.(en_words{en}));

        % Assign a temporary value for performance concern
        prob = 1 / length(fields(AM.(en_words{en})));

        for fr = 1:length(fr_words)
            AM.(en_words{en}).(fr_words{fr}) = prob;
        end
    end

end

function t = em_step(t, eng, fre)
% 
% One step in the EM algorithm.
%
	tcount = struct();
    total = struct();

    for l=1:length(eng)
        disp(eng{l});
        uni_en = unique(eng{l});
        uni_fr = unique(fre{l});

        % for each unique word f in F:
        for fr=1:length(uni_fr)
            denom_c = 0;
            
            % Ignore sentence marks
            if strcmp(uni_fr{fr}, 'SENTEND') || strcmp(uni_fr{fr}, 'SENTSTART')
                continue;
            end

            % for each unique word e in E:
            for en = 1:length(uni_en)
                if strcmp(uni_en{en}, 'SENTEND') || strcmp(uni_en{en}, 'SENTSTART')
                    continue;
                end
                % denom_c += P(f|e) * F.count(f)
                denom_c = denom_c + t.(uni_en{en}).(uni_fr{fr}) * sum(strcmp(fre{l}, uni_fr{fr}));
            end
            % for each unique word e in E:
            for en = 1:length(uni_en)
                if strcmp(uni_en{en}, 'SENTEND') || strcmp(uni_en{en}, 'SENTSTART')
                    continue;
                end
                if ~isfield(tcount, uni_en{en})
					tcount.(uni_en{en}) = struct();
                end
                if ~isfield(total, uni_en{en})
					total.(uni_en{en}) = 0;
                end
                if ~isfield(tcount.(uni_en{en}), uni_fr{fr})
					tcount.(uni_en{en}).(uni_fr{fr}) = 0;
                end

                p_fe = t.(uni_en{en}).(uni_fr{fr});
                fcount = sum(strcmp(fre{l},uni_fr{fr}));
                ecount = sum(strcmp(eng{l},uni_en{en}));

				x = p_fe * fcount * ecount / denom_c;

                % tcount(f, e) += P(f|e) * F.count(f) * E.count(e) / denom_c
				tcount.(uni_en{en}).(uni_fr{fr}) = tcount.(uni_en{en}).(uni_fr{fr}) + x;
                % total(e) += P(f|e) * F.count(f) * E.count(e) / denom_c   
				total.(uni_en{en}) = total.(uni_en{en}) + x;
            end
        end
    end

    totalFields = fieldnames(total);
    % for each e in domain(total(:))
	for en = 1: length(totalFields)

		ew = totalFields{en};
		tcountFields = fieldnames(tcount.(ew));
        % for each f in domain(tcount(:,e)):
        for fr = 1: length(tcountFields)
			fw = tcountFields{fr};
            % P(f|e) = tcount(f, e) / total(e)
			t.(ew).(fw) = tcount.(ew).(fw)/total.(ew);

        end
	end
end
