function [data_out] = array_padd(data_in, pad_sz)
    [h, w, ch] = size(data_in);
    data_out = zeros(h+2*pad_sz, w+2*pad_sz, ch);
    for d = 1:1:ch
       data_out(pad_sz+1:end-pad_sz,pad_sz+1:end-pad_sz, d) = ...
           data_in(:, :, d);
       % up
       data_out(1:pad_sz, pad_sz+1:end-pad_sz, d) = ...
           flipud(data_in(1:pad_sz, :, d));
       % down
       data_out(end-pad_sz+1:end, pad_sz+1:end-pad_sz, d) = ...
           flipud(data_in(end-pad_sz+1:end, :, d));
       % left 
       data_out(pad_sz+1:end-pad_sz, 1:pad_sz,d) = ...
           fliplr(data_in(:, 1:pad_sz, d));
       
       % right
       data_out(pad_sz+1:end-pad_sz, end-pad_sz+1:end, d) = ...
           fliplr(data_in(:, end-pad_sz+1:end, d));
       
       % upper-left
       data_out(1:pad_sz, 1:pad_sz, d) = ...
           flipud(data_out(pad_sz+1:2*pad_sz, 1:pad_sz, d));
       % upper-right
       data_out(1:pad_sz, end-pad_sz+1:end, d) = ...
           flipud(data_out(pad_sz+1:2*pad_sz, end-pad_sz+1:end, d));
       
       % lower-left
       data_out(end-pad_sz+1:end, 1:pad_sz, d) = ...
           flipud(data_out(end-2*pad_sz+1:end -pad_sz, 1:pad_sz, d));
       
       % lower-right
       data_out(end-pad_sz+1:end, end-pad_sz+1:end, d) = ...
           flipud(data_out(end-2*pad_sz+1:end -pad_sz, end-2*pad_sz+1:end -pad_sz, d)); 
       
       
       
    end
    
    
end