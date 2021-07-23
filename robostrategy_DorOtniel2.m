function [lv,mem] = robostrategy_DorOtniel2(env,mem)
    %Strategy for robot tournament game, following opponent
    % Dor Bar shay, ID: 205661739
    % Otniel Yazedi, ID: 312530603
    %Environment Struct
    % field:
    % info,  STRUCT{team, fuel, myPos, oppPos}
    % basic, STRUCT{walls, rRbt, rMF, lmax}
    % mines, STRUCT{nMine, mPos, mineScr, mineExist}
    % fuels, STRUCT{nFuel, fPos, fuelScr, fuelExist}

    %Memory Struct
    % field:
    % path, STRUCT{start, dest, pathpt, nPt, proc, lv}
    myPos = env.info.myPos;
    oppPos = env.info.opPos;
    myfuel = env.info.fuel;
    oppfuel = env.info.fuel_op;
    rMF = env.basic.rMF;
    
    %% go to the nearest fuel strategy:
    nFuel = env.fuels.nFuel;
    fPos = env.fuels.fPos;
    fuelExist = env.fuels.fExist;
    for i = 1:nFuel
        if fuelExist(i) == 0
           fueldes(i) = 100;
        else
           fueldes(i) = destCalc([fPos(i,1) fPos(i,2)],myPos);
        end
    end
    if isempty(find(fuelExist == 1, 1))
            lv = [0 0];
        else
            min_index = find(fueldes == min(fueldes),1);
            lv = [fPos(min_index,1)-myPos(1) fPos(min_index,2)-myPos(2)];
            l = sqrt(lv1*lv1');
            if (l >= env.basic.lmax)
                lv = (lv1*env.basic.lmax)/l1;
            end
    end
       %% SubFunctions
    function dest = destCalc(vec1,vec2)
        vec = vec1 - vec2;
        dest = sqrt(vec*vec');
    end
end
