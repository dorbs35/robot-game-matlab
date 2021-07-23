function [a,b,c] = robotgame_main(team1,team2,mnf,param)
%ROBOTGAME_MAIN   Robot Tournament Game, main stage
% An implementation of the Robot Tournament.
% This script is the main function of the robot game. It calls two other
% functions in which the strategy of the robot is defined.
% References of theRobot Tournament could be found at: 
a = 0;
b = 0;
c = 0;
n_arg = nargin;
if n_arg < 4
    param = struct('R',0.3,'r',0.5,'lmax',0.25,'flRatio',5,'tConsump',2,...
        'court',struct('name','Matlab','color',[1 1 1]));
    if n_arg < 3
        mnf = struct('nMine',24,'nFuel',16,...
            'mScr',20*ones(1,24),'fScr',30*ones(1,16));
        if n_arg < 2
            team1 = struct('name','Team A','color',rand(1,3),...
                'strategy',@robostrategy_na);
            team2 = struct('name','Team B','color',rand(1,3),...
                'strategy',@robostrategy_na);
        end
    end
end
strategy1 = team1.strategy;
strategy2 = team2.strategy;
%generate map
xylim = [0 10 0 10];
R = param.R; % radius of robot
r = param.r; % mine & fuel detection
nMine = mnf.nMine;
nFuel = mnf.nFuel;
mScr = mnf.mScr;
fScr = mnf.fScr;
rbtColor = [team1.color;team2.color];
flRatio = param.flRatio;
fbRatio = 112.5;
tConsump = param.tConsump*[1 1];
lmax = param.lmax;
dt = 0.1;
fuelbar = [1000 1000];
%Court
courtColor = param.court.color;
hf = figure('name','Robot Tournament',...
    'numbertitle','off','menubar','none','color',courtColor,...
    'pos',[[1366 768]/2-[800 600]/2 800 600]);
ha = axes('parent',hf,'dataaspectratio',[1 1 1],...
    'color',courtColor,'xcolor',courtColor,'ycolor',courtColor,...
    'xlim',xylim(1:2)+[-1 1],'ylim',xylim(3:4)+[-1 1]);
text(5,5,param.court.name,...
    'fontsize',27,'fontweight','bold','color',.92*courtColor,...
    'HorizontalAlignment','center'); %Home Court
%Title
text(0.16,0.27,['xlim:[' num2str(xylim(1:2)) '] '...
    'ylim:[' num2str(xylim(3:4)) ']'],...
    'fontsize',8,'fontweight','bold')
text(5,11,[team1.name ' vs. ' team2.name],...
    'fontsize',14,'fontweight','bold','HorizontalAlignment','center');
hturn = text(xylim(1)+(xylim(1)+xylim(2))/2,xylim(4)+0.5,'Turn: 0',...
    'fontsize',12,'fontweight','bold','HorizontalAlignment','center');
line(xylim([1 1 2 2 1]),xylim([3 4 4 3 3]),'parent',ha,...
    'linewidth',6,'color',[0 0 0]); %walls
wallseg = [xylim([1 1 2 2])',xylim([3 4 4 3])',...
    xylim([1 2 2 1])',xylim([4 4 3 3])'];
%Mines & Fuels
hfuel = zeros(1,2);
hfuel_op = zeros(1,2);
hrbt = zeros(1,2);
htxt1 = zeros(1,4); %name, fuel
htxt2 = zeros(1,4); %name, fuel
while 1
    rbtPos = 10*rand(2,2);%[1 1;9 9];
    if ptdist(rbtPos(1,:),rbtPos(2,:)) > 5
        break
    end
end
rbtPosPre = rbtPos;
hfuel(1) = line([xylim(1)-0.5 xylim(1)-0.5],0.5+[0 fuelbar(1)]/fbRatio,...
    'parent',ha,'linewidth',8.5,'color',rbtColor(1,:));
hfuel(2) = line([xylim(2)+0.5 xylim(2)+0.5],0.5+[0 fuelbar(2)]/fbRatio,...
    'parent',ha,'linewidth',8.5,'color',rbtColor(2,:));
hfuel_op(1) = line([xylim(1)-0.5 xylim(1)-0.5],0.5+fuelbar(2)/fbRatio+[-.05 0],...
    'parent',ha,'linewidth',8.5,'color',rbtColor(2,:));
hfuel_op(2) = line([xylim(2)+0.5 xylim(2)+0.5],0.5+fuelbar(1)/fbRatio+[-.05 0],...
    'parent',ha,'linewidth',8.5,'color',rbtColor(1,:));
hrbt(1) = line(rbtPos(1,1),rbtPos(1,2),'parent',ha,'marker','o','markersize',17,...
    'markerfacecolor',rbtColor(1,:),'markeredgecolor',[0 0 0],'linewidth',2);
hrbt(2) = line(rbtPos(2,1),rbtPos(2,2),'parent',ha,'marker','o','markersize',17,...
    'markerfacecolor',rbtColor(2,:),'markeredgecolor',[0 0 0],'linewidth',2);
htxt1(1) = text('position',rbtPos(1,:)+[.32 0],'string',team1.name,...
    'fontsize',8,'fontweight','bold');
htxt1(2) = text('position',rbtPos(1,:)+[.32 -.32],'string','',...
    'fontsize',8,'fontweight','bold');
htxt2(1) = text('position',rbtPos(2,:)+[.32 0],'string',team2.name,...
    'fontsize',8,'fontweight','bold');
htxt2(2) = text('position',rbtPos(2,:)+[.32 -.32],'string','',...
    'fontsize',8,'fontweight','bold');
nM = nMine;
nF = nFuel;
mExist = true(1,nMine);
fExist = true(1,nFuel);
hnMine = zeros(1,nMine);
hnFuel = zeros(1,nFuel);
hMScr = zeros(1,nMine);
hFScr = zeros(1,nFuel);
mfPos = zeros(nMine+nFuel,2);
for ii = 1:nMine+nFuel
    overlap = 1;
    while overlap
        overlap = 0;
        x = xylim(1)+0.25+(xylim(2)-xylim(1)-0.5)*rand;
        y = xylim(1)+0.25+(xylim(2)-xylim(1)-0.5)*rand;
        for jj = 1:ii-1
            if (x-mfPos(jj,1))^2+(y-mfPos(jj,2))^2 < (2*R)^2
                overlap = 1;
                break
            end
        end
        for jj = 1:2
            if (x-rbtPos(jj,1))^2+(y-rbtPos(jj,2))^2 < (2*R)^2
                overlap = 1;
                break
            end
        end
        if ~overlap
            mfPos(ii,:) = [x y];
        end
    end
end
for ii = 1:nMine
    hnMine(ii) = line(mfPos(ii,1),mfPos(ii,2),'parent',ha,...
        'marker','*','markersize',14,'color',[1 0 0],...
        'linestyle','none','linewidth',2);
    hMScr(ii) = text(mfPos(ii,1),mfPos(ii,2),num2str(mScr(ii),'%.0f'),...
        'fontsize',8,'HorizontalAlignment','center');
end
for ii = 1:nFuel
    hnFuel(ii) = line(mfPos(nMine+ii,1),mfPos(nMine+ii,2),'parent',ha,...
        'marker','o','markersize',14,'color',[0 0 1],...
        'linestyle','none','linewidth',2);
    hFScr(ii) = text(mfPos(nMine+ii,1),mfPos(nMine+ii,2),num2str(fScr(ii),'%.0f'),...
        'fontsize',8,'HorizontalAlignment','center');
end
%Environment Struct
% field:
% info,  STRUCT{team, fuel, myPos, opPos, turn, fuel_op}
% basic, STRUCT{walls, rRbt, rMF, lmax, flRatio, tConsump}
% mines, STRUCT{nMine, mPos, mScr, mExist}
% fuels, STRUCT{nFuel, fPos, fScr, fExist}
envStrc = struct('info',struct('team',[],'fuel',[],'fuel_op',[],...
    'myPos',[],'opPos',[],'turn',[]),...
    'basic',struct('walls',wallseg,'rRbt',R,'rMF',r,'lmax',lmax,...
    'flRatio',flRatio,'tConsump',param.tConsump),...
    'mines',struct('nMine',nMine,'mPos',mfPos(1:nMine,:),...
    'mScr',mScr,'mExist',[]),...
    'fuels',struct('nFuel',nFuel,'fPos',mfPos(nMine+1:nMine+nFuel,:),...
    'fScr',fScr,'fExist',[]));
%Memory Struct
memStrc1 = struct([]);
memStrc2 = struct([]);
t = 0;
cnt = 0;
gameover = false;
dn1 = 0;
dn2 = 0;
%Main Loop
while ~gameover
    %general basic environment
    envStrc.mines.mExist = mExist;
    envStrc.fuels.fExist = fExist;
    envStrc.info.turn = cnt;
    %individial
    %team 1:
    envStrc.info.team = 1;
    envStrc.info.fuel = fuelbar(1);
    envStrc.info.fuel_op = fuelbar(2); % fuel_op is optional
    envStrc.info.myPos = rbtPos(1,:);
    envStrc.info.opPos = rbtPos(2,:);
    [lv1,memStrc1] = strategy1(envStrc,memStrc1);
    %team 2:
    envStrc.info.team = 2;
    envStrc.info.fuel = fuelbar(2);
    envStrc.info.fuel_op = fuelbar(1); % fuel_op is optional
    envStrc.info.myPos = rbtPos(2,:);
    envStrc.info.opPos = rbtPos(1,:);
    [lv2,memStrc2] = strategy2(envStrc,memStrc2);
    %update position
    %team 1:
    lv = lv1;
    l = sqrt(lv*lv');
    if l ~= 0
        lv = lv/l;
        l = min(l,lmax);
        lv = lv*l;
    end
    tf = hitwall(rbtPos(1,:)+lv);
    if ~tf
        rbtPos(1,:) = rbtPos(1,:)+lv;
        fuelbar(1) = fuelbar(1)-l*flRatio;
        set(hrbt(1),...
            'xdata',rbtPos(1,1),'ydata',rbtPos(1,2));
        set(htxt1(1),...
            'position',rbtPos(1,:)+[.32 0])
        %set(htxt1(2),...
        %    'position',rbtPos(1,:)+[.32 -.32],...
        %    'string',['Fuel: ' num2str(fuelbar(1),'%.1f')])
        if l > 0.2
            line([rbtPosPre(1,1) rbtPos(1,1)],...
                [rbtPosPre(1,2) rbtPos(1,2)],...
                'linestyle','--','linewidth',2,'color',rbtColor(1,:));
            rbtPosPre(1,:) = rbtPos(1,:);
        elseif dn1 > 4
            line([rbtPosPre(1,1) rbtPos(1,1)],...
                [rbtPosPre(1,2) rbtPos(1,2)],...
                'linestyle','--','linewidth',2,'color',rbtColor(1,:));
            rbtPosPre(1,:) = rbtPos(1,:);
            dn1 = 0;
        else
            dn1 = dn1+1;
        end
    end
    %team 2:
    lv = lv2;
    l = sqrt(lv*lv');
    if l ~= 0
        lv = lv/l;
        l = min(l,lmax);
        lv = lv*l;
    end
    tf = hitwall(rbtPos(2,:)+lv);
    if ~tf
        rbtPos(2,:) = rbtPos(2,:)+lv;
        fuelbar(2) = fuelbar(2)-l*flRatio;
        set(hrbt(2),...
            'xdata',rbtPos(2,1),'ydata',rbtPos(2,2));
        set(htxt2(1),...
            'position',rbtPos(2,:)+[.32 0])
        %set(htxt2(2),...
        %    'position',rbtPos(2,:)+[.32 -.32],...
        %    'string',['Fuel: ' num2str(fuelbar(2),'%.1f')])
        if l > 0.2
            line([rbtPosPre(2,1) rbtPos(2,1)],...
                [rbtPosPre(2,2) rbtPos(2,2)],...
                'linestyle','--','linewidth',2,'color',rbtColor(2,:));
            rbtPosPre(2,:) = rbtPos(2,:);
        elseif dn2 > 4
            line([rbtPosPre(2,1) rbtPos(2,1)],...
                [rbtPosPre(2,2) rbtPos(2,2)],...
                'linestyle','--','linewidth',2,'color',rbtColor(2,:));
            rbtPosPre(2,:) = rbtPos(2,:);
            dn2 = 0;
        else
            dn2 = dn2+1;
        end
    end
    %mine & fuel
    %mine
    offset = 0;
    mineList = find(mExist);
    for ii = 1:nM
        ix = mineList(ii);
        %team 1:
        if ((rbtPos(1,1)-mfPos(ix+offset,1))^2+...
                (rbtPos(1,2)-mfPos(ix+offset,2))^2) < r^2
            fuelbar(1) = fuelbar(1)-mScr(ix);
            %set(hnMine(ix),'visible','off');
            set(hMScr(ix),'visible','off');
            set(hnMine(ix),'color',[.8 .8 .8]);
            mExist(ix) = false;
            nM = nM-1;
        end
        %team 2:
        if ((rbtPos(2,1)-mfPos(ix+offset,1))^2+...
                (rbtPos(2,2)-mfPos(ix+offset,2))^2) < r^2
            fuelbar(2) = fuelbar(2)-mScr(ix);
            %set(hnMine(ix),'visible','off');
            set(hMScr(ix),'visible','off');
            set(hnMine(ix),'color',[.8 .8 .8]);
            mExist(ix) = false;
            nM = nM-1;
        end
    end
    %fuel
    offset = nMine;
    fuelList = find(fExist);
    for ii = 1:nF
        ix = fuelList(ii);
        %team 1:
        if ((rbtPos(1,1)-mfPos(ix+offset,1))^2+...
                (rbtPos(1,2)-mfPos(ix+offset,2))^2) < r^2
            fuelbar(1) = fuelbar(1)+fScr(ix);
            %set(hnFuel(ix),'visible','off');
            set(hFScr(ix),'visible','off');
            set(hnFuel(ix),'color',[.85 .85 .85]);
            fExist(ix) = false;
            nF = nF-1;
        end
        %team 2:
        if ((rbtPos(2,1)-mfPos(ix+offset,1))^2+...
                (rbtPos(2,2)-mfPos(ix+offset,2))^2) < r^2
            fuelbar(2) = fuelbar(2)+fScr(ix);
            %set(hnFuel(ix),'visible','off');
            set(hFScr(ix),'visible','off');
            set(hnFuel(ix),'color',[.85 .85 .85]);
            fExist(ix) = false;
            nF = nF-1;
        end
    end
    fuelbar = fuelbar-tConsump;
    set(hfuel(1),'ydata',0.5+[0 fuelbar(1)]/fbRatio);
    set(hfuel(2),'ydata',0.5+[0 fuelbar(2)]/fbRatio);
    set(hfuel_op(1),'ydata',0.5+fuelbar(2)/fbRatio+[-.05 0]);
    set(hfuel_op(2),'ydata',0.5+fuelbar(1)/fbRatio+[-.05 0]);
    %refresh display
    cnt = cnt+1;
    t = t+dt;
    set(hturn,'string',['Turn: ' num2str(cnt)])
    set(htxt1(2),...
        'position',rbtPos(1,:)+[.32 -.32],...
        'string',['Fuel: ' num2str(fuelbar(1),'%.1f')])
    set(htxt2(2),...
        'position',rbtPos(2,:)+[.32 -.32],...
        'string',['Fuel: ' num2str(fuelbar(2),'%.1f')])
    pause(dt);
    %gameover
    lrbt = sqrt((rbtPos(1,1)-rbtPos(2,1))^2+(rbtPos(1,2)-rbtPos(2,2))^2);
    if (lrbt < 2*R) || any(fuelbar < 0)
        gameover = true;
    end
end
%Who Wins?
if fuelbar(1) > fuelbar(2)
    winner = team1.name;
    a = 1;
elseif fuelbar(1) < fuelbar(2)
    winner = team2.name;
    b = 1;
else
    winner = '';
end
if ~isempty(winner)
    text(5,5.25,[winner ' Wins!'],'color',[0 0 0],...
        'fontsize',32,'fontweight','bold','HorizontalAlignment','center')
    fprintf('%s Wins!\n\nFuel:\n%s: %.2f\n%s: %.2f\r',...
        winner,team1.name,fuelbar(1),team2.name,fuelbar(2));
else
    text(5,5.25,'Draw!','color',[0 0 0],...
        'fontsize',32,'fontweight','bold','HorizontalAlignment','center')
    fprintf('Draw!\n\nFuel:\n%s & %s: %.2f\r',...
        team1.name,team2.name,fuelbar(1));
    c = 1;
end

%SubFunctions
    function TF = hitwall(rpos)
        TF = ~(((rpos(1)-xylim(1))*(rpos(1)-xylim(2)) < 0) && ...
            ((rpos(2)-xylim(3))*(rpos(2)-xylim(4)) < 0));
    end
    function d = ptdist(A,B)
        AB = B-A;
        d = sqrt(AB*AB');
    end

end
