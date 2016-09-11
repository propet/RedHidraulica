function [P, VERT, CON, J] = tet_voroVert(filename)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% Asocia a cada union de vertices una cara de Delaunay por la 
%%% que atraviesa el conducto
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%filename = 'dumpUNIFORME';

% Arregla el archivo dump para ser procesado por voro++
filename1 = dump2voroInput(filename);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% Lee archivo con la posicion de los centros y radios de las esferas
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

DUMP   = dlmread(filename1);
    
x      = DUMP(:,2);         % posicion x del centro de la particula
y      = DUMP(:,3);         % posicion y del centro de la particula
z      = DUMP(:,4);         % posicion z del centro de la particula
r      = DUMP(:,5);         % radio de la particula
P = [x,y,z,r];
Nparticulas = size(P,1);

%%%%%%%%%%%%%
%%% VORO++
%%%%%%%%%%%%%
% Archivo con la posicion de los vertices
system(sprintf(['voro++ -c "%%P" -wc 0 0 0 0 0 8500 11000 -r'...
      ' -o -11000 11000 -11000 11000 -100 9000 %s'], filename1));

% Renombra el archivo recien creado
verticesFile = [filename, 'VoroVertices.txt.vol'];
system(sprintf('mv ./%s.vol ./%s', filename1, verticesFile));

% Archivo con el orden de los vertices en las caras
system(sprintf(['voro++ -c "%%t" -wc 0 0 0 0 0 8500 11000 -r'...
      ' -o -11000 11000 -11000 11000 -100 9000 %s'], filename1));

% Renombra el archivo recien creado
carasFile = [filename, 'VoroCaras.txt.vol'];
system(sprintf('mv ./%s.vol ./%s', filename1, carasFile));


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% Lee archivo con la posicion de los vertices en cada celda
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
disp('Leyendo archivo de vertices: asociando vertices con celdas voronoi')
fileID1 = fopen(verticesFile);
tline = fgetl(fileID1);
i=1;
tet_VERT = zeros(0,3);
while(ischar(tline))
    split = strsplit(tline);
    split = strrep(split, '(', '');
    split = strrep(split, ')', '');
    split = strrep(split, ',', ' ');
    for j = 1:length(split)
        coordsVert = cell2mat(split(j));
        coordsVert = str2num(coordsVert);
        % cada vertice de la teselacion de voronoi queda asociado a la
        % celda a la que pertenece, que tendra el mismo indice que la
        % particula correspondiente a la celda
        tet_VERT = [tet_VERT; i, coordsVert];
    end
    tline = fgetl(fileID1);
    i=i+1;
    sprintf('celda numero %d de %d', i, Nparticulas+1)
end
tet_VERT = unique(tet_VERT,'rows');


disp('Calculando matriz de conectividad entre vertices')
[VERT, CON] = InterpretaVoronoi(verticesFile, carasFile);



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Elimina las conexiones de vertices que estan pegados a la pared
disp('Eliminando los vertices pegados a la pared de la matriz')
Rdisco = 8000;
VERT(sqrt(VERT(:,1).^2+VERT(:,2).^2) > Rdisco, :) = 0;
length(CON)
ind_vert0 = find(all(bsxfun(@eq, VERT, [0 0 0]), 2));
filasBorrar = [];
for i = 1:length(CON)
    for ind = 1:length(ind_vert0)
        if(CON(i,1)==ind_vert0(ind) || CON(i,2)==ind_vert0(ind))
            filasBorrar = [filasBorrar; i];
        end
    end
end
CON(filasBorrar,:) = [];
length(CON)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

disp('Construyendo matriz J para calcular conductividades entre poros')
Ncon  = length(CON);
filasBorrar = [];
J = zeros(Ncon,5);
cuentaUnionesRotas = 0;
for i = 1:Ncon
    In_vtet1 = find(all(bsxfun(@eq, tet_VERT(:,2:4), VERT(CON(i,1),:)), 2));
    puntos1 = tet_VERT(In_vtet1,1);
    In_vtet2 = find(all(bsxfun(@eq, tet_VERT(:,2:4), VERT(CON(i,2),:)), 2));
    puntos2 = tet_VERT(In_vtet2,1);
    puntos = [puntos1; puntos2];
    [u, uind] = unique(puntos);
    % return the values in 1:length(puntos), that are not in uind
    duplicate_ind = setdiff(1:length(puntos),uind);
    % particulas que definen una cara perpedicular a la union de poros
    verticesDela = puntos(duplicate_ind); 
    if(length(verticesDela) == 3)
        J(i,:) = [CON(i,:), verticesDela'];
    else
        filasBorrar = [filasBorrar; i];
        cuentaUnionesRotas = cuentaUnionesRotas + 1;
    end
end
CON(filasBorrar,:) = [];

end
    