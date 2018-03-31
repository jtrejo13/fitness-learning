%% Logistic Regression of Fitness Data

%% =========== Initialization =============
clear ; close all; clc
dataprocess
%% =========== Parameters =============
X = Xdat(:, 2:end);
input_layer_size = 13;    % 13 features
num_labels = 4;           % 4 labels. Eliptical=1, Pushups=2, Rowing=3,
                          % Treadmill=4

%% =========== Loading and Visualizing Data =============
%  Loading and visualizing the dataset.

% % Load Training Data
% fprintf('Loading and Visualizing Data ...\n')
% 
% % load('ex3data1.mat'); % training data stored in arrays X, y
% m = size(X, 1);
% 
% % Randomly select 100 data points to display
% rand_indices = randperm(m);
% sel = X(rand_indices(1:100), :);
% 
% displayData(sel);
% 
% fprintf('Program paused. Press enter to continue.\n');
% pause;

%% ============ One-vs-All Training ============
fprintf('\nTraining One-vs-All Logistic Regression...\n')

lambda = 0.1; % <----- Check!!
[all_theta] = oneVsAll(X, y, num_labels, lambda);

fprintf('Program paused. Press enter to continue.\n');
pause;


%% ================ Predict for One-Vs-All ================

pred = predictOneVsAll(all_theta, X);

fprintf('\nTraining Set Accuracy: %f\n', mean(double(pred == y)) * 100);
