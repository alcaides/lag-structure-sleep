function writeHDF5FromStruct(dataPath, mStruct )
% 
% function writeHDF5FromStruct(dataPath, mStruct, compress)
% Input:
%   dataPath      - a path to the output HDF file.
%                   If file exists, data is overwritten.
%   mStruct       - < 1x1 struct > 
%
%   Note: If this script works on Matlab version >= 7.12 (2011a) and data size > 10MB, 
%         data will be compressed. 
%
% ex.) 
%      data.data1=1;data.group1.data2={'a','b'};
%      writeHDF5FromStruct( 'sampleHDF5.h5', data );
%  
%      datasets  '/data1' and '/group1/data2' are created
%      and save to 'sampleHDF5.h5'
%    
%
if ~exist('dataPath', 'var')||isempty(dataPath)
    error('Specify output HDF file');    
end
if ~exist('mStruct', 'var')
    error('Specify an input Matlab struct');
end


% If this script works on Matlab version >= 7.12 (2011a),
% large data is compressed.
%{
compress = 0;
matlabInfo = ver('MATLAB');
[ verIdx1, remain ] = strtok( matlabInfo.Version, '.');
if str2num(verIdx1) >= 8
    compress = 1;
else
    verIdx2 = strtoc( remain, '.') ;
    if str2num(verIdx1) == 7 && str2num(verIdx2) >= 12
        compress = 1;
    end
end
%}
if exist(dataPath, 'file')
    delete(dataPath);
end
compress=0;
groupHierachy = [];
if ~isstruct(mStruct)
    evalString = [ inputname(2) ' = mStruct ;' ];
    eval(evalString);
    eval([ 'writeHDF5Hierachy(dataPath,' inputname(2) ', groupHierachy, compress) ;' ] );
else
    writeHDF5Hierachy(dataPath, mStruct, groupHierachy, compress);
end


end
%%
function writeHDF5Hierachy(dataPath, mStruct, groupHierachy, compress)

if ~isstruct(mStruct)
    data = mStruct ;
    clear mStruct
    mStruct.(inputname(2)) = data;
end
fields = fieldnames(mStruct);
nField = length(fields);
for fieldIdx = 1:nField
    data = mStruct.(fields{fieldIdx});
    gh   = [ groupHierachy, '/', fields{fieldIdx} ];
    if isstruct(data)
        writeHDF5Hierachy(dataPath, data, gh, compress);                
    else
        % compress if data size > 10000000 bytes (10MB);
        dataInfo = whos('data');
        if dataInfo.bytes > 10000000 && isnumeric(data) && compress 
            chunkSize = floor(size(data)/10) + 1 ;
            h5create(dataPath, gh, size(data), 'Deflate',9,'ChunkSize',chunkSize);
            h5write(dataPath, gh, data);
        else
            if exist(dataPath, 'file')
                hdf5write(dataPath, gh , data, 'WriteMode', 'append');
            else
                hdf5write(dataPath, gh , data);
            end
        end
    
    end
        
end

end
