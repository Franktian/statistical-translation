%
% evalAlign
%
%  This is simply the script (not the function) that you use to perform your evaluations in 
%  Task 5. 

% some of your definitions
trainDir     = '/u/cs401/A2_SMT/data/Hansard/Training/';
testDir      = '/u/cs401/A2_SMT/data/Hansard/Testing/';
fn_LME       = 'ngram_eng';
fn_LMF       = 'ngram_fre';
%fn_AM        = 'am1k';
lm_type      = '';
delta        = 0.5;
numSentences = 30000;
maxIt = 10;
task5_f = '/u/cs401/A2_SMT/data/Hansard/Testing/Task5.f';
task5_e = '/u/cs401/A2_SMT/data/Hansard/Testing/Task5.e';
task5_g = '/u/cs401/A2_SMT/data/Hansard/Testing/Task5.google.e';

% Train your language models. This is task 2 which makes use of task 1
LME = lm_train( trainDir, 'e', fn_LME );
LMF = lm_train( trainDir, 'f', fn_LMF );
LM = LME;
% load(fn_LME, '-mat', 'LM');

% Train your alignment model of French, given English
AM = align_ibm1( trainDir, numSentences, maxIt, 'file');
% load(fn_AM, '-mat', 'AM');
vocabSize = length(fieldnames(AM));

% ... TODO: more 

% TODO: a bit more work to grab the English and French sentences. 
%       You can probably reuse your previous code for this
french_sens = textread(task5_f, '%s', 'delimiter', '\n');
english_sens = textread(task5_e, '%s', 'delimiter', '\n');
google_sens = textread(task5_g, '%s', 'delimiter', '\n');

% Helper string to get BlueMix translation
unix_pre = 'env LD_LIBRARY_PATH='''' curl -u 6aaea5e9-df0e-4a9b-aefd-aecb761781db:WTceKuyFlVeu -X POST -F "text=';
unix_post = '" -F "source=fr" -F "target=en" https://gateway.watsonplatform.net/language-translation/api/v2/translate';

% Decode the test sentence 'fre'
for l=1:length(french_sens)
    original = french_sens{l};

    f = preprocess(original, 'f');
    model_trans = decode2(f, LM, AM, 'smooth', delta, vocabSize);
    command = strjoin({unix_pre, french_sens{l}, unix_post});

    [status, bluemix_trans] = unix(command);
    google_trans = google_sens{l};
    ref_trans = english_sens{l};

    % Preprocess the translation
    google_trans = initialize_trans(google_trans);
    ref_trans = initialize_trans(ref_trans);
    bluemix_trans = initialize_trans(bluemix_trans);
    
    % Remove sentence marks for decoded translation
    splitted_trans = strsplit(' ', model_trans);
    splitted_trans(1) = [];
    splitted_trans(end) = [];

    %disp(strjoin(splitted_trans));

    refs = {google_trans, ref_trans, bluemix_trans};

    % Calculate BLEU score
    bleu = bleu_score(splitted_trans, refs, 1);
    disp(bleu);
end
