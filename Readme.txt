CV Challenge 2019, G02
1. GUI
> a) RUN start_gui.m in Matlab, GUI should pop up.

> b) Click 'Choose folder' button to select directory.
> > Now the 2 Input images should be shown on GUI.

> There are 2 Modes: Boost Mode and Best Quality
>> In default the Boost mode is selected.
[WARNING] In 'Best quality', the calculation time for e.g. Motorcyle is ~ 20 mins.

> You can also choose between show 3D plt or not
[WARNING] 3D plot can be very RAM-Consuming (sometimes ~10GB)

> c) Click 'Get disparity map' to start calculation.
> > Now a progress bar should pop up.

> After the calculation has been done, disparity map and
  T, R, PSNR should be shown on GUI.

2. Challenge.m
> set path on line 24 and 31
>> Run script

3. Bonus function: 3D-plot
> By default the 3D-plot will be gernerated in disparity_map.m, you 
can disable it by comment it out.

> The function Plot_3D takes 2 inputs: TestData and disparity map
In TestData the 2 images and the camera parameters are parsed.
