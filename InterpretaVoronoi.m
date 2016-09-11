function [VERT, CON] = InterpretaVoronoi(verticesFile,carasFile)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% Lee archivo con la posicion de los vertices en cada celda
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
fileID1 = fopen(verticesFile);
Cellvertices = {};
tline = fgetl(fileID1);
i=1;
VERT = zeros(0,3);
while(ischar(tline))
    split = strsplit(tline);
    split = strrep(split, '(', '');
    split = strrep(split, ')', '');
    split = strrep(split, ',', ' ');
    for j = 1:length(split)
        coordsVert = cell2mat(split(j));
        coordsVert = str2num(coordsVert);
        Cellvertices{i,j} = coordsVert;
        VERT = [VERT; coordsVert];
    end
    
    tline = fgetl(fileID1);
    i=i+1;
end

% Elimina vertices repetidos
VERT = unique(VERT,'rows');

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% Lee archivo con la secuencia de vertices que forma cada una de las 
%%% caras de las celdas
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
fileID2 = fopen(carasFile);
Cellcaras = {};
tline = fgetl(fileID2);
i=1;
while(ischar(tline))
    split = strsplit(tline);
    split = strrep(split, '(', '');
    split = strrep(split, ')', '');
    split = strrep(split, ',', ' ');
    for j = 1:length(split)
        secCaras = cell2mat(split(j));
        secCaras = str2num(secCaras);
        Cellcaras{i,j} = secCaras;
    end
    
    tline = fgetl(fileID2);
    i=i+1;
end

% matriz de conectividad
CON = [];

Ncelda = length(Cellcaras);
for celda = 1:Ncelda
    NcarasPerRow = sum(~cellfun(@isempty,Cellcaras),2);
    for cara = 1:NcarasPerRow(celda)
        puntosCara = [];
        for punto = 1:length(Cellcaras{celda,cara})
            indice    = Cellcaras{celda,cara}(punto);
            vertice    = Cellvertices{celda,indice+1};
            puntosCara = [puntosCara; vertice];
        end
        % indices de los vertices globales
        [~,ind1] = ismember(puntosCara,VERT,'rows');
        for i = 1:(length(ind1)-1)
            CON = [CON; ind1(i), ind1(i+1)];
        end
        CON = [CON; ind1(end), ind1(1)];
    end
    sprintf('celda %d de %d',celda,Ncelda)
end

% Elimina conexiones repetidas
CON = sort(CON,2); % sort columns
CON = unique(CON,'rows');% Elimina conexiones repetidas
CON(CON(:,1) == CON(:,2), :) = [];


% Dibuja todos los pares de uniones
% for i = 1:length(CON)
%     plot3([VERT(CON(i,1),1),VERT(CON(i,2),1)],...
%           [VERT(CON(i,1),2),VERT(CON(i,2),2)],...
%           [VERT(CON(i,1),3),VERT(CON(i,2),3)]);
%     hold on
% end
% axis equal

% Exporta las matrices de conectividad y de vertices
outputFile1 = [verticesFile,'.voronoiVertices'];
outputFile2 = [verticesFile,'.voronoiConectivity'];
dlmwrite(outputFile1,VERT, 'delimiter',' ')
dlmwrite(outputFile2,CON, 'delimiter',' ')

end
