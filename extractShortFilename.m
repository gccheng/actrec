function [ shortname ] = extractShortFilename( fullpath )
% EXTRACTSHORTFILENAME extract short file name, removing the path and the
% extenion

posShortFile = regexp(fullpath, '/[^/]+$');    % remove path
if isempty(posShortFile)
    fileext = fullpath;
    shortname = regexprep(fileext, '\..*$',''); % remove extension
else
    fileext = fullpath(posShortFile+1:end);
    shortname = regexprep(fileext, '\..*$',''); % remove extension
end

end

