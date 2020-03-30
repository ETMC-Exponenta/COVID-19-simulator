classdef propagationAnimator < matlab.mixin.SetGet
    %POPULATIONANIMATOR Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        Out
        Data
        Status0
        Ts = 0.1
        FPS = 40
        Radius
        Figure
        Axes
        VLine
        Tiled
        Title
        Points
        Stems
        Iter = 0
        StatusStems
        Tasker
    end
    
    methods
        function obj = propagationAnimator(out, radius)
            %POPULATIONANIMATOR Construct an instance of this class
            arguments
                out
                radius
            end
            obj.Out = out;
            obj.Radius = radius;
            obj.processData();
        end
        
        function init(obj)
            obj.Iter = 0;
            statuses = obj.Data.Status;
            t = obj.Data.Time;
            if isempty(obj.Figure) || ~isvalid(obj.Figure)
                obj.Figure = figure('Color', 'white', 'Name', 'Propagation Animator');
            end
            obj.Tiled = tiledlayout(obj.Figure, 'flow', 'TileSpacing', 'compact');
            ax = nexttile(obj.Tiled);
            obj.Title = title(ax, 'Time = ');
            ax.XLim = [-1 1]*1.1;
            ax.YLim = [-1 1]*0.55;
            rectangle(ax,'Position',[-1 -0.5 2 1], 'Tag', 'IMPORTANT')
            axis(ax, 'off');
            axis(ax, 'equal');
            axis(ax, 'manual');
            ax.XColor = 'white';
            ax.YColor = 'white';
            obj.Axes(1) = handle(ax);
            mp = nexttile(obj.Tiled);
            mp.XColor = 'white';
            mp.YColor = 'white';
            obj.Axes(2) = mp;
            ch = get(obj.Axes, 'Children');
            todel = [ch{string(get([ch{1:end-1}], 'Tag')) ~= "IMPORTANT"}];
            if todel
                delete(todel)
            end
            N = size(obj.Data.Status, 2);
            R = obj.Radius;
            ax = obj.Axes(1);
            for i = 1:N
                hr(i) = rectangle('Parent', ax,'Position',[-R -R R R]/2,'Curvature',[1 1],'FaceColor',[0 1 0],'EdgeColor',[0 1 0]);
            end
            obj.Points = hr;
            
            nPoints = size(statuses, 1);
            mp = handle(obj.Axes(2));
            obj.StatusStems(:,1) = zeros(nPoints,1);
            obj.StatusStems(:,2) = (N.*ones(nPoints,1));
            obj.StatusStems(:,3) = zeros(nPoints,1);
            %mp.XAxis.Limits = [0 t(end)];
            mp.YAxis.Limits = [0 N];
            hold(mp, 'on')
            ss(1) = stem(mp,t,obj.StatusStems(:,1), 'LineWidth', 2,...
                'color', [0.00,0.45,0.74] , 'Marker', 'none', 'DisplayName', 'Recovered');
            ss(2) = stem(mp,t,obj.StatusStems(:,2), 'LineWidth', 2,...
                'color', [0.39,0.83,0.07], 'Marker', 'none', 'DisplayName', 'Healthy');
            ss(3) = stem(mp,t,obj.StatusStems(:,3), 'LineWidth', 2,...
                'color',[0.85,0.33,0.10], 'Marker', 'none', 'DisplayName', 'Sick');
            obj.Stems = ss;
            hold(mp, 'off');
            obj.VLine = xline(mp, 0, 'LineWidth', 2, 'Alpha', 0.4,...
                'LabelOrientation', 'horizontal');
            obj.VLine.Annotation.LegendInformation.IconDisplayStyle = 'off';
            legend(mp, ss([2 3 1]), 'Location', 'northoutside');
            obj.step();
        end
        
        function play(obj)
            if ~isvalid(obj.Figure) || obj.Iter >= height(obj.Data)
                obj.init();
            end
            for i = 1 : height(obj.Data)-1
                obj.step();
            end
            %             obj.Tasker = Async();
            %             obj.Tasker.addRepeatedTask(@(~)obj.step,...
            %                 1/obj.FPS, height(obj.Data)-1, 1);
            %             statuses = obj.Data.Status;
            %             nPoints = size(statuses, 1);
            %             obj.Tasker.start();
        end
        
        function stop(obj)
            obj.Tasker.stop();
        end
        
        function step(obj)
            obj.Iter = obj.Iter + 1;
            kk = obj.Iter;
            xPos = obj.Data.X;
            yPos = obj.Data.Y;
            statuses = obj.Data.Status;
            t = obj.Data.Time;
            hr = obj.Points;
            R = obj.Radius;
            if isvalid(obj.Figure)
                obj.Title.String = sprintf("Time = %3.2f", days(t(kk)));
                for i = 1:length(hr)
                    hr(i).Position = [xPos(kk,i) - R/2 yPos(kk,i) - R/2 R R];
                end
                currentStatusLevel2 = statuses(kk,:)';
                [row, ~] = find(currentStatusLevel2);
                [StatusLevel1, ~] = find(currentStatusLevel2 == 0);
                [StatusLevel2, ~] = find(currentStatusLevel2 == 1);
                [StatusLevel3, ~] = find(currentStatusLevel2 == 2);
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
                obj.StatusStems(kk,1) = StatusLevel2Count+StatusLevel1Count+StatusLevel3Count;
                obj.StatusStems(kk,2) = StatusLevel2Count+StatusLevel1Count;
                obj.StatusStems(kk,3) = StatusLevel2Count;
                obj.Stems(1).YData = obj.StatusStems(:,1);
                obj.Stems(2).YData = obj.StatusStems(:,2);
                obj.Stems(3).YData = obj.StatusStems(:,3);
                obj.VLine.Value = t(kk);
                obj.VLine.Label = sprintf("t=%3.2f", days(t(kk)));
                drawnow
            end
        end
        
        function set.Ts(obj, ts)
            obj.Ts = ts;
            obj.processData();
        end
        
        function processData(obj)
            out = obj.Out;
            allPos = out.yout.get('pos').Values.Data;
            x = squeeze(allPos(:,1,:))';
            y = squeeze(allPos(:,2,:))';
            statuses = out.yout.get('status').Values.Data;
            statuses = squeeze(statuses)';
            t = out.yout.get('pos').Values.Time;
            data = timetable(x, y, statuses, 'RowTimes', days(t),...
                'VariableNames', {'X' 'Y' 'Status'});
            data = retime(data, 'regular', 'nearest', 'TimeStep', days(obj.Ts));
            obj.Status0 = data.Status(:, 1)';
            obj.Data = data;
        end
        
    end
end

