
this_folder = fileparts(which(mfilename));
% Add that folder plus all subfolders to the path.
addpath(genpath(this_folder));



hebec_constants
temperature=300;
dist_vx=@(v,t) (const.mhe/(2*pi*const.kb*t))^(1/2).*exp(-(const.mhe*v.^2)./(2*const.kb*t));
dist_width=@(t) sqrt(const.kb*t/const.mhe);

v_pts=linspace(0,3000,1e4);
figure(1)
clf;
set(gcf,'color','w')
%values from https://aip.scitation.org/doi/10.1063/1.1372169
v_mean=900; %m/s
therm_width=15;%kelvin


shifted_dist=@(v) dist_vx(v-v_mean,therm_width);
prob_dist_val=shifted_dist(v_pts);
%prob_dist_samp=prob_dist_samp./trapz(v_pts,prob_dist_samp);
plot(v_pts,prob_dist_val,'k')

xlabel('veloctiy (m/s)')
ylabel('density (arb. units)')

%% Get the impulse response
%formal way is by transofrmation of variables 
%https://en.wikipedia.org/wiki/Probability_density_function#Dependent_variables_and_change_of_variables
%hack way is to sample transform and histogram

support=[500 1000 1500];
samples=1e4;
dist_samples=IA2RMS(shifted_dist,support,samples,0);


[counts,bin_edges] = histcounts(dist_samples,linspace(0,3000,1e5));
bin_cen=0.5*(bin_edges(1:end-1)+bin_edges(2:end));
smooth_const=3;
counts=gaussfilt(bin_cen,counts,smooth_const);
counts=counts./trapz(bin_cen,counts);

hold on
plot(bin_cen,counts,'r')
hold off

%% Now transform
len_zs=3;%m
delay_samples=len_zs./dist_samples;

[counts,bin_edges] = histcounts(delay_samples,linspace(0,10e-3,1e5));
bin_cen=0.5*(bin_edges(1:end-1)+bin_edges(2:end));
smooth_const=1e-6; %seconds
counts=gaussfilt(bin_cen,counts,smooth_const);
counts=counts./trapz(bin_cen,counts);

figure(3)
clf
set(gcf,'color','w')
plot(bin_cen*1e3,counts,'r')
xlabel('time (ms)')
ylabel('density (arb. units)')


