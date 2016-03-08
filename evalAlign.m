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
fn_AM        = 'am30k';
lm_type      = '';
delta        = 0.5;
% vocabSize    = TODO; 
numSentences = 30000;
maxIt = 10;
task5_f = '/u/cs401/A2_SMT/data/Hansard/Testing/Task5.f';
task5_e = '/u/cs401/A2_SMT/data/Hansard/Testing/Task5.e';
task5_g = '/u/cs401/A2_SMT/data/Hansard/Testing/Task5.google.e';

% Train your language models. This is task 2 which makes use of task 1
% LME = lm_train( trainDir, 'e', fn_LME );
% LMF = lm_train( trainDir, 'f', fn_LMF );
% LM = LME;
load(fn_LME, '-mat', 'LM');

% Train your alignment model of French, given English
% AM = align_ibm1( trainDir, numSentences, maxIt, 'file');
load(fn_AM, '-mat', 'AM');
vocabSize = length(fieldnames(AM));

% ... TODO: more 

% TODO: a bit more work to grab the English and French sentences. 
%       You can probably reuse your previous code for this
french_sens = textread(task5_f, '%s', 'delimiter', '\n');
english_sens = textread(task5_e, '%s', 'delimiter', '\n');
google_sens = textread(task5_g, '%s', 'delimiter', '\n');

unix_pre = 'env LD_LIBRARY_PATH='''' curl -u 6aaea5e9-df0e-4a9b-aefd-aecb761781db:WTceKuyFlVeu -X POST -F "text=';
unix_post = '" -F "source=fr" -F "target=en" https://gateway.watsonplatform.net/language-translation/api/v2/translate';

% Decode the test sentence 'fre'
for l=1:length(french_sens)
    original = french_sens{l};

    f = preprocess(original, 'f');
    %model_trans = decode2(f, LM, AM, 'smooth', delta, vocabSize);
    command = strjoin({unix_pre, french_sens{l}, unix_post});

    [status, bluemix_trans] = unix(command);
    google_trans = google_sens{l};
    ref_trans = english_sens{l};

    % TODO: Add BLEU score
    disp(bluemix_trans);
end


% TODO: perform some analysis
% add BlueMix code here 
%disp('Evaluate blue mix');
% unix_pre = 'env LD_LIBRARY_PATH='''' curl -u 6aaea5e9-df0e-4a9b-aefd-aecb761781db:WTceKuyFlVeu -X POST -F "text=';
% french = 'Dans le monde reel, il n''y a rien de mal a cela.';
% unix_post = '" -F "source=fr" -F "target=en" https://gateway.watsonplatform.net/language-translation/api/v2/translate';
% command = strjoin({unix_pre, french, unix_post});
%[status, result] = unix('env LD_LIBRARY_PATH='''' curl -u 6aaea5e9-df0e-4a9b-aefd-aecb761781db:WTceKuyFlVeu -X POST -F "text=Dans le monde reel, il n''y a rien de mal a cela." -F "source=fr" -F "target=en" https://gateway.watsonplatform.net/language-translation/api/v2/translate')