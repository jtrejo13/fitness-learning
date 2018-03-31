%% File processing

csvfiles = dir('./data/*.csv');

M = zeros(0, 13);

for file = csvfiles'
    
    filename = strcat('./data/', file.name);
    fprintf(1,'Processing %s\n', filename)
    
    dat = csvread(filename, 1, 0);
      
    accelX = dat(:, 8)  + dat(:, 11);
    accelY = dat(:, 9)  + dat(:, 12);
    accelZ = dat(:, 10) + dat(:, 13);
    accel = sqrt(accelX.^2 + accelY.^2 + accelZ.^2);
    
    dat = [dat accel ones(size(dat, 1), 1)];
    
    reg = regexp(filename,'(Elliptical|Pushups|Rowing|Treadmill)','match','once');
    switch reg
        case 'Elliptical'
            % pass
        case 'Pushups'
            dat(:,1:end) =  dat(:,1:end) + 1;
        case 'Rowing'
            dat(:,1:end) =  dat(:,1:end) + 2;
        case 'Treadmill'
            dat(:,1:end) =  dat(:,1:end) + 3;
    end
    
    M = [M; dat];
end

shuffledM = M(randperm(size(M,1)),:);

Xdat = shuffledM(:,1:end-1);
y    = shuffledM(:,end);

save('Xdat.mat','Xdat')
save('y.mat','y')