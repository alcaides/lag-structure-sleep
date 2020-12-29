function [ data, info ] = readHDF5AsStruct(hdf5Path)
%
% Read an HDF5 file and Convert it to a Matlab struct.
%
% ex.) [ data, info ] = readHDF5AsStruct('sampleData.hdf5')
%
% Input:
%   hdf5Path   - path to the HDF5 file.
%
% Output:
%   data       - < struct > data converted from the HDF5 file
%   info       - Information about the HDF5 file
%                ( output of hdf5info(hdf5Path) ).
%
%%
if ~exist( 'hdf5Path', 'var') || isempty(hdf5Path)
    help(mfilename)
    error('Specify a path to an HDF5 file\n')
end

% get info
info   = hdf5info(hdf5Path);
groupHierarchy = info.GroupHierarchy ;

% load data
data = [];
data = readDataSet(data, groupHierarchy);

end

%% readDataSet
%  read DataSet and Groups in a hierarchical way
%
function data = readDataSet(data, groupHierarchy)

if ~isempty(groupHierarchy.Groups)
    nGroup = length(groupHierarchy.Groups);
    for groupIdx = 1:nGroup
        data = readDataSet(data, groupHierarchy.Groups(groupIdx));
    end
end

% load dataset
if ~isempty(groupHierarchy.Datasets)
    nDatasets = length(groupHierarchy.Datasets);
    for dataIdx = 1:nDatasets
        dataSetName = groupHierarchy.Datasets(dataIdx).Name;
        % replace '/' to '.'
        dataSetName( ismember(dataSetName, '/') ) = '.';
        
        % check if data type is string or numeric
        if strcmp(groupHierarchy.Datasets(dataIdx).Datatype.Class, 'H5T_STRING')
            stringData = hdf5read(groupHierarchy.Datasets(dataIdx)) ;
            stringDataSize = size(stringData);
            
            if length(stringDataSize) > 2
                fprintf('Worning: String array whos dimension is larger than 2 is omitted.\n')
            end
                    
            evalString = [ 'data', dataSetName, ' = cell(size(stringData)) ;' ];            
            eval(evalString);
            for row = 1:stringDataSize(1)
                for col = 1:stringDataSize(2)
                    evalString = [ 'data', dataSetName, '{row, col} = stringData(row,col).Data;'];
                    eval(evalString);
                end
            end
        else
            dataSet = hdf5read(groupHierarchy.Datasets(dataIdx));
            
            evalString = [ 'data', dataSetName, ' = ',  'dataSet ;' ];
            eval(evalString);
        end
    end
    
end

% load attribute
if ~isempty(groupHierarchy.Attributes)
    nAttributes = length(groupHierarchy.Attributes);
    for attrIdx = 1:nAttributes
        attrLocation = groupHierarchy.Attributes(attrIdx).Location;
        attrName     = groupHierarchy.Attributes(attrIdx).Shortname;
        % replace '/' to '.'
        attrLocation( ismember(attrLocation, '/') ) = '.';
        if length(attrLocation) > 1
            attrLocation = [ attrLocation, '.Attributes.', attrName ];
        else
            attrLocation = [ attrLocation, 'Attributes.', attrName ];
        end
        attrLocation( ismember(attrLocation, ' ') ) = '_';
        
        if isnumeric(groupHierarchy.Attributes(attrIdx).Value)
            attrData = groupHierarchy.Attributes(attrIdx).Value;
        else
            attrData = groupHierarchy.Attributes(attrIdx).Value.Data;
        end
        
        evalString = [ 'data', attrLocation, ' = ', 'attrData ;' ];
        eval(evalString);
    end
    
end

end







