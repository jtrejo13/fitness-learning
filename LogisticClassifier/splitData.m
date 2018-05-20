function [X_train, y_train, X_test, y_test] = splitData(X, y, train_ratio)

dat = [X y];

N  = size(dat,1);    
tf = false(N,1);                % create logical index vector
tf(1:round(train_ratio*N)) = true; 
tf = tf(randperm(N));           % randomise order
dat_train = dat(tf,:);
dat_test  = dat(~tf,:); 

X_train = dat_train(:, 1:end-1);
y_train = dat_train(:, end);

X_test = dat_test(:, 1:end-1);
y_test = dat_test(:, end);
end