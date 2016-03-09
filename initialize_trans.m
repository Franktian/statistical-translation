function out = initialize_trans(in)
    % Preprocess, split and remove sentence tag
    out = preprocess(in, 'e');
    
    out = strsplit(' ', out);
    
    out(1) = [];
    out(end) = [];

end
