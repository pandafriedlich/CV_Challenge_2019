
- Finde Corners
>Harris detector
> > Image gradients using sobel-filter
> > Calculate H matrix
> > Suppose to eig, but shortcut is given 
> > filter through the threshold value
> > Corners found

- Find Matching points
> Given found corners
> > Create window around corners
> >> NCC to compare the correlations (gradient rotated?)
> >> SSD (disadvantage: Rotation and darkness)
> >
> > Get matching points when NCC>threshold

- Get T and R (Epipolar equation)