function [VERT, CON] = dump2voronoi(filename)

% Arregla el archivo dump para ser procesado por voro++
filename = dump2voroInput(filename);

%%%%%%%%%%%%%
%%% VORO++
%%%%%%%%%%%%%
% Archivo con la posicion de los vertices
system(sprintf(['voro++ -c "%%P" -wc 0 0 0 0 0 8500 11000 -r'...
      ' -o -11000 11000 -11000 11000 -100 9000 %s'], filename));

% Renombra el archivo recien creado
verticesFile = [filename, 'VoroVertices.txt.vol'];
system(sprintf('mv ./%s.vol ./%s', filename, verticesFile));


% Archivo con el orden de los vertices en las caras
system(sprintf(['voro++ -c "%%t" -wc 0 0 0 0 0 8500 11000 -r'...
      ' -o -11000 11000 -11000 11000 -100 9000 %s'], filename));

% Renombra el archivo recien creado
carasFile = [filename, 'VoroCaras.txt.vol'];
system(sprintf('mv ./%s.vol ./%s', filename, carasFile));

%%%%%%%%%%%%%
%%% Construye matriz de vertices y de conectividad, guarda los
%%% resultados
%%%%%%%%%%%%%
[VERT, CON] = InterpretaVoronoi(verticesFile, carasFile);
    
end