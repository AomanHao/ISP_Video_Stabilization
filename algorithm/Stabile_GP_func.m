function [fs,correctedVideo_shift] = Stabile_GP_func(movie, conf)
%%
% movie£ºmovie data
% conf ; config param

sf = conf.start_frame;
nf = conf.num_frames;
%% initialize variables
fs = read(movie, [sf, sf+nf-1]);         % frame sequence of interest
height = movie.Height;
width = movie.Width;

tic
%% Estimate the vertical and horizontal pixel shifts 
for frame = sf:nf
    data_temp = rgb2gray(fs(:,:,:,frame));
    row_shif_temp = sum(data_temp,2);
    row_shift(:,:,frame) = row_shif_temp./255./height;
    
    col_shift_temp = sum(data_temp,1);
    col_shift(:,:,frame) = col_shift_temp./255./width;
    
end
clear frame

%% Estimate the translational pixel shift 
for frame = sf+1:nf
    row_xcorr = xcorr(row_shift(:,:,frame-1),row_shift(:,:,frame));
    [argValue_row argMax_row] = max(row_xcorr);
    vertShift(frame) = height-argMax_row;
    
    
    %Estimate the horizontal pixel shift
    col_xcorr = xcorr(col_shift(:,:,frame-1),col_shift(:,:,frame));
    [argValue_col argMax_col] = max(col_xcorr);
    horiShift(frame) = width-argMax_col;
end
clear frame

%% Compensate for the vertical and horizontal pixel shifts
for frame = sf:nf
    vertShiftCom(frame) = -sum(vertShift(frame));
    horiShiftCom(frame) =  -sum(horiShift(frame));
end
clear frame

%%  pixel shifts
for frame = sf:nf
    % Correct the measured vertical and horizontal pixel shifts
    correctedVideo_shift(:,:,:,frame) = imtranslate(fs(:,:,:,frame),[horiShiftCom(frame) vertShiftCom(frame)]);
end
clear frame