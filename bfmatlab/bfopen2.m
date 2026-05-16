function [imageList] = bfopen2(id, varargin)
autoloadBioFormats = 1;

% Toggle the stitchFiles flag to control grouping of similarly
% named files into a single dataset based on file numbering.
stitchFiles = 0;

% To work with compressed Evotec Flex, fill in your LuraWave license code.
%lurawaveLicense = 'xxxxxx-xxxxxxx';

% -- Main function - no need to edit anything past this point --

% load the Bio-Formats library into the MATLAB environment
status = bfCheckJavaPath(autoloadBioFormats);
assert(status, ['Missing Bio-Formats library. Either add bioformats_package.jar '...
    'to the static Java path or add it to the Matlab path.']);
javaMethod('enableLogging', 'loci.common.DebugTools', 'INFO');
r = bfGetReader(id, stitchFiles);

planeSize = javaMethod('getPlaneSize', 'loci.formats.FormatTools', r);
if planeSize/(1024)^3 >= 2
    error(['Image plane too large. Only 2GB of data can be extracted '...
        'at one time. You can workaround the problem by opening '...
        'the plane in tiles.']);
end

% numSeries = r.getSeriesCount();
% result = cell(numSeries, 2);
% globalMetadata = r.getGlobalMetadata();
s=1;
% fprintf('Reading series #%d', s);
%     r.setSeries(s - 1);
%     pixelType = r.getPixelType();
    
    numImages = r.getImageCount();
%     imageList = cell(numImages, 2);
%     colorMaps = cell(numImages);
%     numImages=2;
fprintf('Reading image number:');
arr = bfGetPlane2(r, 1);
% arr = bfGetPlane2(r, 1, varargin{:});
a1=size(arr,1);
% vg=varargin{:};numImages
imageList=zeros(a1,a1,20);
imageList(:,:,1) = arr;
     for i = 2:numImages
    fprintf('.%d', i);
        arr = bfGetPlane2(r, i);
        imageList(:,:,i) = arr;
% %          warning_state = warning ('off');
% %          warning (warning_state);
         if mod(i,20)==0
              fprintf('\n');
         end
%          imageList{i, 1} = arr;
     end
%      result{s, 1} = imageList;
         
%         seriesMetadata = r.getSeriesMetadata();
%     javaMethod('merge', 'loci.formats.MetadataTools', ...
%                globalMetadata, seriesMetadata, 'Global ');
%     result{s, 2} = seriesMetadata;
%     result{s, 3} = colorMaps;
%     result{s, 4} = r.getMetadataStore();

    r.close();
end

