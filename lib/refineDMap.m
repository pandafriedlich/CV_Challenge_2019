function dmap_refined = refineDMap(im0, dmap)
    [height, width] = size(dmap);
    th = 30;
    dmap_refined = double(dmap);
    im0 = double(ictRGB2YCbCr(im0));
    f = waitbar(0,'Refining (0.00%)');
    for py = 1:1:height
        waitbar(py/height,f,sprintf("(1/3) Horizontal Refining (%4.2f%%)",py/height*100) );
        start_px = 1;
        for px = 2:1:width
            delta_c = im0(py, px, 2:3) - im0(py, start_px, 2:3);
            delta_c = sum(delta_c.^2, 'all');
            if (delta_c > th) || (px == width)
                % refine sub-line
                dmap_slice = dmap_refined(py, start_px:px-1);
                median_d = median(dmap_slice);
                dmap_slice(abs(dmap_slice - median_d) > 10) = median_d ;
                dmap_refined(py, start_px:px-1) = dmap_slice;
                start_px = px;
            end
            
        end
    end
    th = 10;
    for px = 1:1:width
        waitbar(px/width,f,sprintf("(2/3) Vertical Refining(%4.2f%%)",px/width*100) );
        start_py = 1;
        for py = 2:1:height
            delta_c = im0(py, px, 2:3) - im0(start_py, px, 2:3);
            delta_c = sum(delta_c.^2, 'all');
            if (delta_c > th) || (py == height)
                % refine sub-line
                dmap_slice = dmap_refined( start_py:py-1, px);
                median_d = median(dmap_slice);
                dmap_slice(abs(dmap_slice - median_d) > 10) = median_d ;
                dmap_refined(start_py:py-1, px) = dmap_slice;
                start_py = py;
            end
            
        end
    end
    delete(f);
    dmap_refined = median_fltr(dmap_refined, 5);
    
end