function plane_save_apdl(E1,E2,Nu12,Nu13,Nu32,G12,G23,a,b,c,nelx,nely,F,fixeddof,xPhys,angle,vft, fname) 
%входные параметры:
%модули упругости E1,E2;
%коэффициенты Пуассона Nu12,Nu21,Nu32;
%модули сдвига G12,G23;
%размеры элемента a,b;
%толщина c;
%число элементов по x и y nelx,nely;
%сила F;
%закрепленные степени свободы fixeddof;
%плотность xPhys;
%матрица углов (nelx:nely) tetaAns;
%порог плотности vft

fileID = fopen(fname,'w'); 

nodecoord = zeros((nelx+1)*(nely+1),2);
fprintf(fileID,'/NOP\n');
fprintf(fileID,'FINISH\n/CLEAR,START\nKEYW,PR_STRUC,1\n/PREP7\n'); 

%fprintf(fileID,'ET,1,SHEll181\nTYPE,1\nMAT,1\n');
fprintf(fileID,'ET,1,PLANE182\n'); 

fprintf(fileID,'MPTEMP,1,0\n'); 
fprintf(fileID,'MPDATA,EX,1,,%f\n',E1);
fprintf(fileID,'MPDATA,EY,1,,%f\n',E2);
fprintf(fileID,'MPDATA,EZ,1,,%f\n',E2);
fprintf(fileID,'MPDATA,PRXY,1,,%f\n',Nu12);
fprintf(fileID,'MPDATA,PRYZ,1,,%f\n',Nu32);
fprintf(fileID,'MPDATA,PRXZ,1,,%f\n',Nu13);
fprintf(fileID,'MPDATA,GXY,1,,%f\n',G12);
fprintf(fileID,'MPDATA,GYZ,1,,%f\n',G23);
fprintf(fileID,'MPDATA,GXZ,1,,%f\n',G12);

for i = 1:nelx+1 %цикл создания узлов
    x = (i-1)*a; %формула присвоения координаты X узла в цикле
    for j = 1:nely+1
        y = nely*b - (j-1)*b; %формула присвоения координаты Y узла в цикле
        nodeid = (i-1)*(nely+1)+(j-1); %задание айди узла
        nodecoord(nodeid+1,1) = x; %запись в массив с координатами
        nodecoord(nodeid+1,2) = y;
        fprintf(fileID,'N,%i,%f,%f,%f\n',nodeid+1,x,y,0); %построение узла
    end
end

xPhys=flip(xPhys,1); 
for i = 1:nelx
    for j = 1:nely
        if (xPhys(j,i) > vft)
            nodeid = (i-1)*(nely+1)+(nely+1-(j-1)); 
            N1 = nodeid; 
            N2 = nodeid+(nely+1);
            N3 = nodeid+nely;
            N4 = nodeid-1;
            fprintf(fileID, 'TYPE,   1   \nMAT,       1\nREAL,   \nESYS,       0   \nSECNUM,   %i \nTSHAP,LINE\n',angle); 
            fprintf(fileID,'E,%i,%i,%i,%i\n',N1,N2,N3,N4); %построение самого элемента
        end
    end
end

fprintf(fileID,'F,%i,FY,%f\n',1,F);

innz = nnz(fixeddof);
[i,j,s] = find(fixeddof);
for i0 = 1:innz
    inodeid = floor((s(i0)+1) / 2);
    dofid = s(i0) - inodeid*2;
    if dofid==-1
        fprintf(fileID,'D,%i,UX\n',inodeid);
    end
    if dofid==0
        fprintf(fileID,'D,%i, , , , , ,UY,UZ, , \n',inodeid);
    end
end

fprintf(fileID,'FINISH\n/SOL\nANTYPE,0\nSOLVE\n');

fclose(fileID);

end