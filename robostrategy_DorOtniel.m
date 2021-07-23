function [lv,mem] = robostrategy_DorOtniel(env,mem)
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
    walls = env.basic.walls;
    rMF = env.basic.rMF;
    
    %% go to the nearest fuel strategy:
    nFuel = env.fuels.nFuel;
    fPos = env.fuels.fPos;
    fuelExist = env.fuels.fExist;
    allFuel = 0;
    for i = 1:nFuel
        if fuelExist(i) == 0
           fueldes(i) = 100;
           oppFueldes(i) = 100;
        else
            fueldes(i) = destCalc([fPos(i,1) fPos(i,2)],myPos);
            oppFueldes(i) = destCalc([fPos(i,1) fPos(i,2)],oppPos);
        end
    end
    myFuelNoS = fueldes/(env.basic.lmax);
    oppFuelNoS = oppFueldes/(env.basic.lmax);
    myOppNoS = destCalc(oppPos,myPos)/ (env.basic.lmax);
    if isempty(find(fuelExist == 1, 1))
            lv1 = [0 0];
            l1 = 100;
        else
            min_index = find(fueldes == min(fueldes),1);
            lv1 = [fPos(min_index,1)-myPos(1) fPos(min_index,2)-myPos(2)];
            l1 = sqrt(lv1*lv1');
            if (l1 >= env.basic.lmax)
                lv1 = (lv1*env.basic.lmax)/l1;
        end
    end
    %% acquire fuel, attack opponent or run away:
    lv2 = [oppPos(1)-myPos(1) oppPos(2)-myPos(2)];
    l2 = sqrt(lv2*lv2');
    if (l2 >= env.basic.lmax)
        lv2 = (lv2*env.basic.lmax)/l2;
    end
    if (l2 >= l1)
        lv = lv1;
    else
        if (myfuel - oppfuel > 0)
            lv = lv2;
            if isempty(find(fuelExist == 1, 1))
                allFuel = 0;
            else
                for i = find(fuelExist == 1)
                    allFuel = allFuel + env.fuels.fScr(i);
                end 
            end
            if(allFuel < myfuel - oppfuel && (myOppNoS-2)*(env.basic.lmax + env.basic.tConsump) > myfuel - oppfuel)
                lv = [0 0];
            end
        else
            lv = -lv2;
            for i = 1:nFuel
                if ((fuelExist(i) == 1) && (myFuelNoS(i) < oppFuelNoS(i) || myFuelNoS(i) < myOppNoS))
                    lv = [fPos(i,1)-myPos(1) fPos(i,2)-myPos(2)];
                    l1 = sqrt(lv*lv');
                    if (l1 >= env.basic.lmax)
                       lv = (lv*env.basic.lmax)/l1;
                    end
                    break; 
                end
            end
        end
    end

    %% avoiding the mines that in the way
    nMine = env.mines.nMine;
    mPos = env.mines.mPos;
    mineExist = env.mines.mExist;
    lvcheck = lv; % current step
    if(lv(1) == 0)
        if(lv(2)>0)
            angle = pi/2;
        else
            angle = -pi/2;
        end
    else
        angle = atan(lv(2)/lv(1));
        if(lv(1) < 0 && lv(2) < 0) || (lv(1) < 0 && lv(2) > 0)
            angle = angle + pi;
        end
    end
    M=0; % counter of mines
    while(M<nMine)
        check = 0;
        check = closeToMine(M+1,lv);
        if(check==1)
            angle1 = angle +asin(rMF/destCalc([mPos(M,1) mPos(M,2)],myPos));
            lv = [env.basic.lmax*cos(angle1) env.basic.lmax*sin(angle1)];
            check = check + closeToMine(1,lv);
        end
        if(check==2)
            angle1 = angle -asin(rMF/destCalc([mPos(M,1) mPos(M,2)],myPos));
            lv = [env.basic.lmax*cos(angle1) env.basic.lmax*sin(angle1)];
            check = check + closeToMine(1,lv);
        end
        if(check == 3)
            lv = lvcheck;
        else
            if(check == 2 || check == 1)
                break;
            end
        end
    end
    %% avoid wall's limitations
    if (lv(1) + myPos(1) < 0 || lv(1) + myPos(1) > 10)
        lv(1)=0;
    end
    if (lv(2) + myPos(2) < 0 || lv(2) + myPos(2) > 10)
        lv(2)=0;
    end
    %% SubFunctions
    function close = closeToMine(h,lvX)
        close = 0;
        for k = h:nMine
            if check == 0
                M = k;
            end
            close = 0;
            if (destCalc([mPos(k,1) mPos(k,2)],myPos+lvX) < rMF && mineExist(k) == 1)
                close=1;
                break;
            end
        end
    end
    function dest = destCalc(vec1,vec2)
        vec = vec1 - vec2;
        dest = sqrt(vec*vec');
    end
end
