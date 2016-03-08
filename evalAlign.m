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
fn_AM        = 'am1k';
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

% Decode the test sentence 'fre'
for l=1:length(french_sens)
    f = preprocess(french_sens{l}, 'f');
    e = decode2(f, LM, AM, 'smooth', delta, vocabSize);
    disp(e);
end


% TODO: perform some analysis
% add BlueMix code here 
%disp('Evaluate blue mix');
%[status, result] = unix('curl -u 6aaea5e9-df0e-4a9b-aefd-aecb761781db:WTceKuyFlVeu -X POST -F "text=Honorables membres du Senat, membres de la Chambre des communes" -F "source=fr" -F "target=en" "https://gateway.watsonplatform.net/language-translation/api/v2/translate"https://gateway.watsonplatform.net/language-translation/api')