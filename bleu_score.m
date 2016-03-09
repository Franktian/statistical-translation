function bleu = bleu_score(sentence, refs, n)
    % Assume cap(.) = 2
    % The inputs are preprocessed sentences
%     disp(sentence);
%     disp(refs);

    % calculate brevity and bp
    tempmin = 1;
    for i=1:3
        if abs(length(refs{i}) - length(sentence)) < abs(length(refs{tempmin})-length(sentence))
            tempmin = i;
        end
    end
    brevity = length(refs{tempmin}) / length(sentence);

    if brevity < 1
        bp = 1;
    else
        bp = exp(1-brevity);
    end
    
    % unigram
%     wc = struct();
%     for i=1:length(sentence)
%         word = sentence{i};
%         if ~isfield(wc, word)
%             wc.(word) = 0;
%         end
%         for j=1:length(refs)
%             if sum(strcmp(refs{j}, word)) > 0 && wc.(word) < 2 
%                 wc.(word) = wc.(word) + 1;
%                 break;
%             end
%         end
%     end
%     count = 0;
%     words = fieldnames(wc);
%     for k=1:length(words)
%         count = count + wc.(words{k});
%     end
%     uni_precision = count / length(sentence);
    
    % multiply the n gram precisions
    prod_precision = 1;
    for i=1:n
        precision = calculate_precision(sentence, refs, i);
        prod_precision = prod_precision * precision;
        disp(precision);
    end
    disp('BP');
    disp(bp);
    
    bleu = bp * (prod_precision)^(1/n);
    

    

%     x = count_matched(sentence, refs, n);
%     disp(x);
%     bleu = 0;
end

function nprecision = calculate_precision(sen, refs, n)
    wc = struct();
    for i=1:length(sen)-n+1
        word = strjoin({sen{i:i+n-1}}, '_');
        disp(word);
        if ~isfield(wc, word)
            wc.(word) = 0;
        end
        for j=1:length(refs)
            shouldbreak = 0;
            for k=1:length(refs{j}) - n + 1
%             y = strjoin({refs{j}{k:k+n-1}}, '_');
%             disp(y);
                
                if strcmp(strjoin({refs{j}{k:k+n-1}}, '_'), word) > 0 && wc.(word) < 2 
                    wc.(word) = wc.(word) + 1;
                    shouldbreak = 1;
                    break;
                end
            end
            if shouldbreak == 1
                break;
            end
            
        end
    end
    count = 0;
    words = fieldnames(wc);
    for k=1:length(words)
        count = count + wc.(words{k});
    end
    nprecision = count / (length(sen)-n+1);
    
end
