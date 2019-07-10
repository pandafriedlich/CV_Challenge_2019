function im_p = median_fltr(im, sz)
    im = double(im);
    im_p = array_padd(im, sz);
    [h2, w2] = size(im_p);
    
    f = waitbar(0,'Refining (0.00%)');
    for py = sz+1:1:h2-sz
        waitbar((py-sz)/(h2-2*sz),f,sprintf("(3/3)Median Filtering (%4.2f%%)",(py-sz)/(h2-2*sz)*100) );
        for px = sz+1:1:w2-sz
            blk = im_p(py-sz:py+sz, px-sz:px+sz);
            im_p(py, px) = median(blk(:));            
        end
    end
    im_p = im_p(sz+1:1:h2-sz,sz+1:1:w2-sz);
    delete(f);
end