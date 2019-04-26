%initalize
this_folder = fileparts(which(mfilename));
% Add that folder plus all subfolders to the path.
addpath(genpath(this_folder));
hebec_constants


%%
data_file='data/NewFile9.csv';
fp=fopen(data_file,'r');
fgetl(fp);
raw_line2=fgetl(fp);
line2=split(raw_line2,',');
time_start=str2num(line2{3});
time_inc=str2num(line2{4});
fclose(fp);

%
Array=csvread(data_file,2);
col_aom_v = Array(:, 1);
donger_curr = Array(:, 2);
time_vec=time_start+(0:(size(col_aom_v)-1)).*time_inc;
%%


starttime = Array(1,3);
fprintf('%f',starttime)
figure(1)
set(gcf,'color','w')
subplot(2,1,1)
plot(time_vec,col_aom_v)
subplot(2,1,2)
plot(time_vec,donger_curr)


%%
mask=time_vec>0.5e-3;
time_vec_sub=time_vec(mask);
donger_curr_sub=donger_curr(mask);
figure(2)
set(gcf,'color','w')
plot(time_vec_sub,donger_curr_sub)


%% TODO
% derive delay distribution
% cut out the first ms of the data
% fit delay distribution to that signal
% - set max itterations to 1(or zero) to chekc that inital param are right
% make another file to fit the step response

