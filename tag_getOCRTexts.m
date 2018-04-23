function [ ocrTexts ] = tag_getOCRTexts( fileURIs )
%TAG_GETOCRTEXTS Summary of this function goes here
%   Detailed explanation goes here

%%  Set initial output vars
    len = length(fileURIs);
    ocrTexts = cell(1, len);
    msg = 'tag_getOCRTexts: ';

%%  Retrieve OCR Results for each fileURI
    url = 'https://api.ocr.space/parse/image';
    for i = 1 : len
        fid = fopen(fileURIs{i},'r');
        bytes = fread(fid);
        fclose(fid);
        encoder = org.apache.commons.codec.binary.Base64;
        base64string = char(encoder.encode(bytes))';
        base64string = ['data:image/png;base64,',base64string];
%         disp(base64string);
        writeApiKey = '1f1cb776f788957';
        options = weboptions('Timeout',30);
        response = webwrite(url,'apikey',writeApiKey,'base64Image',base64string,options);
        ocrTexts{i} = regexprep(response.ParsedResults.ParsedText, '\W', '');
    end

end