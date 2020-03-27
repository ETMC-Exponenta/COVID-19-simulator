h = figure;
h.Color = 'white';
ax = subplot(2,1,1);
ht = title('Time = ');
axis off
axis equal
axis manual
ax.XLim = [-1 1]*1.1;
ax.YLim = [-1 1]*0.55;
ax.XColor = 'white';
ax.YColor = 'white';
rectangle(ax,'Position',[-1 -0.5 2 1])
for i = 1:N
    hr(i) = rectangle(ax,'Position',[0 0 R R],'Curvature',[1 1],'FaceColor',[0 1 0],'EdgeColor',[0 1 0]);  %#ok<SAGROW>
end

[a, ~] = find(state0);
hr(a).FaceColor = [1 0 0];
hr(a).EdgeColor = [1 0 0];

allPos = out.yout{1}.Values.Data;
allStatuses = out.yout{2}.Values.Data;
t = out.yout{2}.Values.Time;

[~,~,nPoints] = size(allPos);

mp = subplot(2,1,2);
mp.Position = [0.28    0.300    0.47    0.25];
mp.XColor = 'white';
mp.YColor = 'white';


status1Stem = zeros(nPoints,1);
status2Stem = ((N-1).*ones(nPoints,1));
status3Stem = ones(nPoints,1);
mp.XAxis.Limits = [0,t(end)];
mp.YAxis.Limits = [0,50];
hold on
s1 = stem(mp,t,status1Stem, 'LineWidth', 2, 'color', [0.00,0.45,0.74] , 'Marker', 'none')
s2 = stem(mp,t,status2Stem, 'LineWidth', 2, 'color', [0.39,0.83,0.07], 'Marker', 'none')
s3 = stem(mp,t,status3Stem, 'LineWidth', 2, 'color',[0.85,0.33,0.10], 'Marker','none');
hold off

for kk = 1:nPoints
    ht.String = ['Time = ' num2str(out.yout{2}.Values.Time(kk))];
    for i = 1:length(hr)
        hr(i).Position = [allPos(i,1,kk) allPos(i,2,kk) R R];
    end
    
    currentStatusLevel2 = allStatuses(kk,:)';
    [row , ~] = find(currentStatusLevel2);
    
    [StatusLevel1, ~] = find(currentStatusLevel2==0);
    [StatusLevel2 , ~] = find(currentStatusLevel2==1);
    [StatusLevel3 , ~] = find(currentStatusLevel2==2);
    
    for i = 1:length(row)
        if currentStatusLevel2(row(i)) == 1
            hr(row(i)).FaceColor = [1 0 0];
            hr(row(i)).EdgeColor = [1 0 0];
        end
        if currentStatusLevel2(row(i)) == 2
            hr(row(i)).FaceColor = [0 0 1];
            hr(row(i)).EdgeColor = [0 0 1];
        end
    end
    
    StatusLevel1Count = length(StatusLevel1);
    StatusLevel2Count = length(StatusLevel2);
    StatusLevel3Count = length(StatusLevel3);
    
    status1Stem(kk) = StatusLevel2Count+StatusLevel1Count+StatusLevel3Count;
    status2Stem(kk) = StatusLevel2Count+StatusLevel1Count;
    status3Stem(kk) = StatusLevel2Count;
   
    s1.YData = status1Stem;
    s2.YData = status2Stem;
    s3.YData = status3Stem;
    drawnow
end
