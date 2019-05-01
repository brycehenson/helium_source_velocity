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


%TO DO
% use gaussfilt to smooth the data and plot the smoothed version
% plot the current in nA using the gain as 1e6 V/A
% convert this distirbution of delays (current vs time) into a distribution of velcoities 
% https://en.wikipedia.org/wiki/Probability_density_function#Dependent_variables_and_change_of_variables
%   give y=g(x),  where vel=y, delay=x
%   vel=dist/delay
%   you may need to use interp1 so that you can define f_x from the data you have
% plot the distribution of velocities
% fit a gaussian to this distribtuon



%% how to fit
% this is a function for an (area) normalized gaussian
gauss_norm_fun = @(x,mu,sigma,amp) amp*(1/(sigma*sqrt(2*pi))).*exp(-(1/2)*((x-mu)./sigma).^2); %normalized gaussian

% now fit a guassian to the velocity dist

xdat=%put your x data here
ydat=% put the y data here
% no the fit needs a function where the first argurment is a vector of the fit parameters and the scond is a vecotr of
% the x values, it then will return its guess for the y value
fit_fun=@(param,x) gauss_norm_fun(x,param(1),param(2),param(3));
opts = statset('nlinfit');
%opts.MaxIter=1;  %use this to check that the initall guess is right 
beta0 = [900,200,1]; %intial guesses for parameters
fit_mdl = fitnlm(xdat,ydat,fit_fun,beta0,...
    'Options',opts,...
    'CoefficientNames',{'mu','sigma','amp'});

%then we want to plot the fit on top of the data plot
x_samp_fit=linspace(500,2000,1e4); %the x values we will sample
y_val_fit=predict(fit_mdl,x_samp_fit'); % what the fit thinks it is
sfigure(3);
hold on
plot(x_samp_fit,y_val_fit,'r')
hold off

%add lets add the fit parmeters to a box in the fit
%this function spits out a string of the varaible name is equal to the estimated value ± its uncert
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
% make another file to fit the step response

