# CV-Challenge 2019 G02

- Finde Corners

>Harris detector
> > Image gradients using sobel-filter  
> > Calculate H matrix  
> > Suppose to eig, but shortcut is given  
> > filter through the threshold value  
> > Corners found  

- Find Matching points  

> Given found corners  (!Bug: input parser, wrong order)
> > Create window around corners  
> >> NCC to compare the correlations (gradient rotated?)  
> >> SSD (disadvantage: Rotation and darkness)  
> >  
> > Get matching points when NCC>threshold  

- Get Essential Matrix
> Given found matching corner points
> > Use ransac algo to pick out the robust correspondings  
> > Apply 8-points-algo on robust_corres

- T,R from E  
> Get T,R candidates (each has 2)  
> Calc depth of correspondings for all 4 combination  
> Choose the T,R with most pos. depth values  

## Disparity search
- Epipolar line  
> Camera pair rectified, No need to calc the epipolar line  

