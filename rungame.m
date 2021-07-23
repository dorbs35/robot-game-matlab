close all
team1win = 0;
team1draw = 0;
team1lose = 0;
for i = 1 : 50
team1 = struct('name','Team A','color',rand(1,3),'strategy',@robostrategy_DorOtniel);
team2 = struct('name','Team B','color',rand(1,3),'strategy',@robostrategy_good);
[a,b,c] = robotgame_main(team1,team2);
team1win = team1win + a;
team1lose = team1lose + b;
team1draw = team1draw + c;
close all
end
fprintf('%d wins, %d draws, %d loses\n', team1win,team1draw,team1lose);
%close all
%team1 = struct('name','Team A','color',rand(1,3),'strategy',@robostrategy_good);
%team2 = struct('name','Team B','color',rand(1,3),'strategy',@robostrategy_nomove);
%robotgame_main(team1,team2);

%close all
%team1 = struct('name','Team A','color',rand(1,3),'strategy',@robostrategy_good);
%team2 = struct('name','Team B','color',rand(1,3),'strategy',@robostrategy_rand);
%robotgame_main(team1,team2);

%close all
%team1 = struct('name','Team A','color',rand(1,3),'strategy',@robostrategy_good);
%team2 = struct('name','Team B','color',rand(1,3),'strategy',@robostrategy_direct);
%robotgame_main(team1,team2);

