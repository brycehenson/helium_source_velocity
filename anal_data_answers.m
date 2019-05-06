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
smooth_tc=0e-6;
if smooth_tc==0 || isnan(smooth_tc)
    donger_curr_smooth=donger_curr;
else
    donger_curr_smooth=gaussfilt(time_vec,donger_curr,smooth_tc);
end

amplifier_gain=1e6;

mask=time_vec>0.5e-3;
time_vec_sub=time_vec(mask);
donger_curr_smooth_sub=donger_curr_smooth(mask);
figure(2)
set(gcf,'color','w')
plot(1e3*time_vec_sub,-1e9*donger_curr_smooth_sub/amplifier_gain,'k')
xlabel('Time (ms)')
ylabel('Current (nA)')
title(sprintf('Current from impulse, %g us filt',smooth_tc*1e6))


%% convert this to velocity distribution
% give y=g(x),  where vel=y, delay=x
%  vel=g(delay)
%  vel=dist/delay
% give x=g^-1(y)
%  delay=g^-1(vel)
%  delay=dist/velocity
% d/d(vel) g^-1(vel)
%  d/d(vel) g^-1(vel)=-1*dist*vel^-2

vel_samp=linspace(500,2000,1e3);
distance=1.749;%m
ginv=@(vin) distance./vin;
ddy_ginv=@(vin) -distance.*(vin.^-2);
delay_den=-donger_curr_smooth_sub-mean(-donger_curr_smooth_sub);
delay_den=delay_den/trapz(time_vec_sub,delay_den);
delay_dist_interp=@(x) interp1(time_vec_sub,delay_den,x)

vel_den=abs(ddy_ginv(vel_samp)).*delay_dist_interp(ginv(vel_samp));
figure(3)
clf
set(gcf,'color','w')
plot(vel_samp,vel_den,'k')
xlabel('velocity (m/s)')
ylabel('density (arb. units)')
yl=ylim;
ylim([-5,yl(2)])
title(sprintf('vel. dist. from impulse, %g us filt',smooth_tc*1e6))


% now fit a guassian to the velocity dist

xdat=vel_samp;
ydat=vel_den;
gauss_norm_fun = @(x,mu,sigma,amp) amp*(1/(sigma*sqrt(2*pi))).*exp(-(1/2)*((x-mu)./sigma).^2); %normalized gaussian
fit_fun=@(param,x) gauss_norm_fun(x,param(1),param(2),param(3));
opts = statset('nlinfit');
%opts.MaxIter=1;
%opts.RobustWgtFun = 'welsch' ; %a bit of robust fitting
%opts.Tune = 1;
beta0 = [900,200,1]; %intial guesses
fit_mdl = fitnlm(xdat,ydat,fit_fun,beta0,'Options',opts,'CoefficientNames',{'mu','sigma','amp'});
vel_samp_fit=vel_samp;
[vel_den_fit,vel_unc_den_fit]=predict(fit_mdl,vel_samp_fit');
sfigure(3);
hold on
plot(vel_samp_fit,vel_den_fit,'r')
plot(vel_samp_fit,vel_unc_den_fit,'b')
hold off

print_var=@(idx) sprintf('%s=%.2f±%.2f',...
            fit_mdl.Coefficients.Row{idx},...
            fit_mdl.Coefficients.Estimate(idx),...
            fit_mdl.Coefficients.SE(idx) );
        
% add a box with the fit param
dim = [0.6 0.5 0.3 0.3];
str = {print_var(1),...
      print_var(2),...
       print_var(3)};
annotation('textbox',dim,'String',str,'FitBoxToText','on');





%% TODO
% derive delay distribution
% cut out the first ms of the data
% fit delay distribution to that signal
% - set max itterations to 1(or zero) to chekc that inital param are right
% make another file to fit the step response

