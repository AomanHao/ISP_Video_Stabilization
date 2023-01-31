%% 程序分享
% 个人博客 www.aomanhao.top
% Github https://github.com/AomanHao
% CSDN https://blog.csdn.net/Aoman_Hao
% Zhihu https://www.zhihu.com/people/aomanhao-hao
%--------------------------------------
%%
clc
clear
close all

%% load data
addpath('./tools');
addpath('./algorithm');

pathname = './video/';
data_conf = dir(pathname);
data_name = {data_conf.name};
data_num = numel({data_conf.name})-2;

conf.savepath = './result/';
if ~exist(conf.savepath,'var')
    mkdir(conf.savepath)
end

start_frame = 1;
number_frame = 100;

%% bypass
stabile_type = 'GP';%'GP_imp'

for i = 1:data_num
    
    imgname = split(data_name{i+2},'.');
    conf.name = [imgname{1}];
    pathfilename = [pathname,data_name{i+2}];
    movie = VideoReader(pathfilename);
    
    
    %% 电子稳像 %%%%%%%%%%%%%%
    
    sf=start_frame;
    nf=min(number_frame,movie.NumFrames-sf);
    movie_in = read(movie, [sf, sf+nf-1]);
    height = movie.Height;
    width = movie.Width;
    %% 算法处理
    tic;
    switch stabile_type
        case 'GP'
            % Gray projection
            conf.start_frame = sf;
            conf.num_frames = nf;
            [movie_re,movie_corr] = Stabile_GP_func(movie, conf);
            
        case 'GP_imp'
            conf.start_frame = sf;
            conf.num_frames = nf;
            [movie_re,movie_corr] = Stabile_GP_imp_func(movie, conf);
    end
    toc;
    t=toc;
    
    %% Motion compensation save video result
    video_savepath = strcat(conf.savepath,conf.name,'_',stabile_type);
    video_out = VideoWriter(video_savepath, 'MPEG-4');
    open(video_out);
    for savei=1:conf.num_frames-1
        writeVideo(video_out, uint8(movie_corr(:,:,:,savei)));
    end
    
    close(video_out);
    
end