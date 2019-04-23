
%initalize
this_folder = fileparts(which(mfilename));
% Add that folder plus all subfolders to the path.
addpath(genpath(this_folder));
hebec_constants

%define the 1d maxwell boltzman velocity distribution
dist_vx=@(v,t) (const.mhe/(2*pi*const.kb*t))^(1/2).*exp(-(const.mhe*v.^2)./(2*const.kb*t));
dist_width=@(t) sqrt(const.kb*t/const.mhe);

%now the distribution that our experiment is close to a shifted gaussian
%using values from https://aip.scitation.org/doi/10.1063/1.1372169
v_mean=900; %m/s
therm_width=15;%kelvin
shifted_dist=@(v) dist_vx(v-v_mean,therm_width);
%now lets plot this dirstibution

v_pts=linspace(0,3000,1e4);
prob_dist_val=shifted_dist(v_pts);
%prob_dist_samp=prob_dist_samp./trapz(v_pts,prob_dist_samp);
figure(1)
clf;
set(gcf,'color','w')
plot(v_pts,prob_dist_val,'k')

xlabel('veloctiy (m/s)')
ylabel('density (arb. units)')

%% Get the impulse response
%formal way is by transofrmation of variables 
%https://en.wikipedia.org/wiki/Probability_density_function#Dependent_variables_and_change_of_variables
%hack way is to sample the distribution, apply the transform and then histogram

%lets sample the distribution
support=[500 1000 1500];
samples=1e6;
dist_samples=IA2RMS(shifted_dist,support,samples,0);

%then histogram the result
% i prefer kernel density estimation to straight histograming
% its pretty simple; bin up the data with very small bins and then smooth with a gaussian 
[velocity_counts,bin_edges] = histcounts(dist_samples,linspace(0,3000,1e5));
bin_cen=0.5*(bin_edges(1:end-1)+bin_edges(2:end));
smooth_const=3; % gaussian kernel width in m/s
velocity_counts=gaussfilt(bin_cen,velocity_counts,smooth_const);
velocity_counts=velocity_counts./trapz(bin_cen,velocity_counts);

hold on
plot(bin_cen,velocity_counts,'r')
hold off
%great the histogram and the distribution are matched

%% Now transform to delays
len_zs=3;%m will need to measure
delay_samples=len_zs./dist_samples;
sample_max=10e-3;
sample_rate=1e8;
bin_edges=linspace(0,sample_max,sample_max*sample_rate);
[delay_counts,bin_edges] = histcounts(delay_samples,bin_edges);
bin_cen=0.5*(bin_edges(1:end-1)+bin_edges(2:end));
smooth_const=1e-6; %seconds
delay_counts=gaussfilt(bin_cen,delay_counts,smooth_const);
delay_counts=delay_counts./trapz(bin_cen,delay_counts);

figure(3)
clf
set(gcf,'color','w')
plot(bin_cen*1e3,delay_counts,'r')
xlabel('time (ms)')
ylabel('density (arb. units)')



%% calculate the frequency response
% this is commonly used in electronic engineering to measure the response of the system
% we could in principle measure this directly and then work backwards 
% this would be a good approach if sensitivity is an issue as we could use a lock in amplifier which is very sensitive
% but otherwise it would just make things a lot more complicated than it is needed
% we can also use this graph to get some idea of what the bandwidth requirements of the measurment are
figure(5)
clf
set(gcf,'color','w')
x_limits=[1e2,1e5];
fft_out=fft_tx(bin_cen,delay_counts);
subplot(2,1,1)
plot(fft_out(1,:),abs(fft_out(2,:)))
xlabel('Frequency (Hz)')
ylabel('Amplitude')
set(gca, 'YScale', 'log') 
set(gca, 'XScale', 'log') 
set(gca, 'Xlim', x_limits) 
subplot(2,1,2)
phase_angle=angle(fft_out(2,:));
plot(fft_out(1,:),phase_angle)
xlabel('Frequency (Hz)')
ylabel('Phase (rad)')
set(gca, 'Xlim', x_limits) 
set(gca, 'XScale', 'log') 


%% calculate the step response
%this is what we will be measuring direclty in the experiment
% the step response is the integeral of the impulse response
figure(4)
set(gcf,'color','w')
cum_delay_counts=cumtrapz(bin_cen,delay_counts);
plot(bin_cen*1e3,cum_delay_counts,'r')
xlabel('time (ms)')
ylabel('density (arb. units)')

% if we can get the delay distribution then we can analyticaly integerate it and fit it to the measured step response


% I dont think that is is that helpfull but [A calculation of the time-of-flight distribution of trapped atoms](https://aapt.scitation.org/doi/10.1119/1.1424266)
