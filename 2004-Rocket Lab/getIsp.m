%Static Test Stand Report Code File
%By Cannon Palmer

% Files = dir('StaticTestStandData\');
% file = 3; %file number to load
% long_name = strcat(Files(file).folder,'\',Files(file).name);
% Data = load(long_name);

clc
clear
close all

%loads all data files in a for loop and inputs these into 1 cell array
files = dir('StaticTestStandData\');
allData = {};
alldata_trimmed = {};
%for loop iterates once per data file
for i = 3:20
    %current data file is read in
    temp = readtable((files(i).name),'PreserveVariableName',1);
    
    %the data file's size is taken and any extra rows will be removed by
    %removing the first couple rows if there are extras
    [m,n] = size(temp);
    r = rem(m,10);
    
    %the data is inputted into the respective slot in the data cell array
    allData{i-2} = temp((1+r):end,1:3);
end

sampleRate = 1.652 * 1000; %Hz sampling rate for all data files
testStats = zeros(18,7); %stores data about each test: Start, Start Load, Finish, Finish Load

for i = 1:18
    data = table2array(allData{i});
    [m,n] = size(data);
    time = (1:m) / sampleRate; %set up time vector in terms of seconds
    
    tempMean = mean(data(1:100,3));
    start = find(data(:,3) >= (tempMean + 0.15),1) - 1;
    startLoad = mean(data(1:start,3));
    
    
    finishR = start + 2000;
    finishLoad = mean(data(finishR:finishR+1000,3));
    
    check = false;
    temp = flip(data(start:finishR,3));
    j = 0;
    while check ~= 1
        j = j + 1;
        tempMean = mean(temp((1:10) + j*10));
        remainder = abs(finishLoad - tempMean);
        if remainder >= 0.25
           check = true; 
        elseif j >= 190
           check = true;
        end
    end
    finish = finishR - (j-1)*10;
    
    [p] = polyfit([time(start) time(finish)], [startLoad finishLoad],1);
    templine = p(1) * time(start:finish) + p(2);
    
    Idata = trapz(time(start:finish),data(start:finish,3));
    Iline = trapz(time(start:finish),templine);
    %Ir = trapz(data(start:finish,3),templine);
    Itot = Idata - Iline;
    
    peakThrust = max(data(start:finish,3));
    
    thrustTime = time(finish) - time(start);
    
    testStats(i,1) = start;
    testStats(i,2) = startLoad;
    testStats(i,3) = finish;
    testStats(i,4) = finishLoad;
    testStats(i,5) = peakThrust;
    testStats(i,6) = Itot;
    testStats(i,7) = thrustTime;
    
    subplot(3,6,i)
    plot(time,data(:,3))
    xlabel("Time (s)")
    ylabel("Thrust (lbf)")
    hold on
    plot(time(start:finish),templine,'k')
    xline(time(start),'r')
    %xline(time(finishR),'r')
    xline(time(finish),'r')
    yline(startLoad,'r')
    xlim([time(start-200) time(finish+200)])
    hold off
    trimmeddata{i} = data(start:finish);
end
g = 9.81;
weight = [1; 1; 1; 1; 1; 1; 1.004; 0.996; 1; 1; 1; 0.999; 1; 0.999; 1; 1; 1; 1];
Isp = testStats(:,6) ./ (weight);
testStats = [testStats weight Isp];

testStatistics = array2table(testStats,'VariableNames',{'Start Index','Starting Load (lbf)','Finish Index','Finishing Load (lbf)','Peak Thrust (lbf)','Total Impulse (N*s)','Thrust Time (s)','Water Weight (kg)','Isp (s)'});