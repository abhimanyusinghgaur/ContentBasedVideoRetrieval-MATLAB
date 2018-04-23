function varargout = ui_search(varargin)
% UI_SEARCH MATLAB code for ui_search.fig
%      UI_SEARCH, by itself, creates a new UI_SEARCH or raises the existing
%      singleton*.
%
%      H = UI_SEARCH returns the handle to a new UI_SEARCH or the handle to
%      the existing singleton*.
%
%      UI_SEARCH('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in UI_SEARCH.M with the given input arguments.
%
%      UI_SEARCH('Property','Value',...) creates a new UI_SEARCH or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before ui_search_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to ui_search_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help ui_search

% Last Modified by GUIDE v2.5 24-Apr-2018 03:59:28

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @ui_search_OpeningFcn, ...
                   'gui_OutputFcn',  @ui_search_OutputFcn, ...
                   'gui_LayoutFcn',  [] , ...
                   'gui_Callback',   []);
if nargin && ischar(varargin{1})
    gui_State.gui_Callback = str2func(varargin{1});
end

if nargout
    [varargout{1:nargout}] = gui_mainfcn(gui_State, varargin{:});
else
    gui_mainfcn(gui_State, varargin{:});
end
% End initialization code - DO NOT EDIT


% --- Executes just before ui_search is made visible.
function ui_search_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to ui_search (see VARARGIN)
pos = get(0, 'screensize');
set(hObject, 'units','pixels','outerposition',[0 0 pos(3)-25 pos(4)-60]);
addprop(hObject, 'vlc');
handles.isVlcOpen = false;

% Choose default command line output for ui_search
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes ui_search wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = ui_search_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


function queryEditText_Callback(hObject, eventdata, handles)
% hObject    handle to queryEditText (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of queryEditText as text
%        str2double(get(hObject,'String')) returns contents of queryEditText as a double


% --- Executes during object creation, after setting all properties.
function queryEditText_CreateFcn(hObject, eventdata, handles)
% hObject    handle to queryEditText (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in tvChannelPopup.
function tvChannelPopup_Callback(hObject, eventdata, handles)
% hObject    handle to tvChannelPopup (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns tvChannelPopup contents as cell array
%        contents{get(hObject,'Value')} returns selected item from tvChannelPopup


% --- Executes during object creation, after setting all properties.
function tvChannelPopup_CreateFcn(hObject, eventdata, handles)
% hObject    handle to tvChannelPopup (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called
load('dbConfig.mat', 'tvChannelClasses');
tvChannelClasses = ['<html><font color="gray">Select TV Channel</font></html>', tvChannelClasses];
set(hObject, 'String', tvChannelClasses);

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function sportPopup_Callback(hObject, eventdata, handles)
% hObject    handle to sportPopup (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of sportPopup as text
%        str2double(get(hObject,'String')) returns contents of sportPopup as a double


% --- Executes during object creation, after setting all properties.
function sportPopup_CreateFcn(hObject, eventdata, handles)
% hObject    handle to sportPopup (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called
load('dbConfig.mat', 'sportClasses');
sportClasses = ['<html><font color="gray">Select Sport</font></html>', sportClasses];
set(hObject, 'String', sportClasses);

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function teamPopup_Callback(hObject, eventdata, handles)
% hObject    handle to teamPopup (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of teamPopup as text
%        str2double(get(hObject,'String')) returns contents of teamPopup as a double


% --- Executes during object creation, after setting all properties.
function teamPopup_CreateFcn(hObject, eventdata, handles)
% hObject    handle to teamPopup (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called
load('dbConfig.mat', 'teamClasses');
teamClasses = ['<html><font color="gray">Select Team</font></html>', teamClasses];
set(hObject, 'String', teamClasses);

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in playerPopup.
function playerPopup_Callback(hObject, eventdata, handles)
% hObject    handle to playerPopup (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns playerPopup contents as cell array
%        contents{get(hObject,'Value')} returns selected item from playerPopup


% --- Executes during object creation, after setting all properties.
function playerPopup_CreateFcn(hObject, eventdata, handles)
% hObject    handle to playerPopup (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called
load('dbConfig.mat', 'playerClasses');
playerClasses = ['<html><font color="gray">Select Player</font></html>', playerClasses];
set(hObject, 'String', playerClasses);

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in backButton.
function backButton_Callback(hObject, eventdata, handles)
% hObject    handle to backButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
if handles.isVlcOpen
    delete(handles.output.vlc);
    handles.isVlcOpen = false;
    guidata(hObject, handles);
else
    close();
    ui_main();
end


% --- Executes on button press in querySearchButton.
function querySearchButton_Callback(hObject, eventdata, handles)
% hObject    handle to querySearchButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
query = get(handles.queryEditText,'String');
temp = strrep(query, ' ', '');
if isempty(temp) || strcmpi(temp,'Entertextquery')
    ed = errordlg('Please input a query to perform search.', 'Search Error', 'modal');
    uiwait(ed);
else
    h = msgbox('Searching Video...', 'Please Wait...');
    % set pointer to indicate processing
    set(handles.figure1, 'pointer', 'watch');
    drawnow;
    indexMap = tag_getAllQueryTags(query);
    if any(indexMap)
        [videoNames, found, msg] = db_findBestMatchVideos(indexMap, 10);
        msg = strsplit(msg, ':');
        if found==0
            showSearchResults([0], handles.bestMatchPanel, handles);
            ed = errordlg([msg{2:end}], msg{1}, 'modal');
            uiwait(ed);
        else
            showSearchResults(videoNames, handles.bestMatchPanel, handles);
        end
        videoNames = db_findBestMatchVideos([indexMap(1) 0 0 0], 10);
        showSearchResults(videoNames, handles.tvChannelPanel, handles);
        videoNames = db_findBestMatchVideos([0 indexMap(2) 0 0], 10);
        showSearchResults(videoNames, handles.sportPanel, handles);
        videoNames = db_findBestMatchVideos([0 0 indexMap(3) 0], 10);
        showSearchResults(videoNames, handles.teamPanel, handles);
        videoNames = db_findBestMatchVideos([0 0 0 indexMap(4)], 10);
        showSearchResults(videoNames, handles.playerPanel, handles);
    else
        showSearchResults([0], handles.bestMatchPanel, handles);
        showSearchResults([0], handles.tvChannelPanel, handles);
        showSearchResults([0], handles.sportPanel, handles);
        showSearchResults([0], handles.teamPanel, handles);
        showSearchResults([0], handles.playerPanel, handles);
    end
    % reset pointer
    set(handles.figure1, 'pointer', 'arrow');
    delete(h);
end


% --- Executes on button press in tagSearchButton.
function tagSearchButton_Callback(hObject, eventdata, handles)
% hObject    handle to tagSearchButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
tvChannel = get(handles.tvChannelPopup,'Value')-1;
sport = get(handles.sportPopup,'Value')-1;
team = get(handles.teamPopup,'Value')-1;
player = get(handles.playerPopup,'Value')-1;
if ~tvChannel && ~sport && ~team && ~player
    ed = errordlg('Select at least one search criteria.', 'Search Error', 'modal');
    uiwait(ed);
else
    h = msgbox('Searching Video...', 'Please Wait...');
    % set pointer to indicate processing
    set(handles.figure1, 'pointer', 'watch');
    drawnow;
    [videoNames, found, msg] = db_findBestMatchVideos([tvChannel sport team player], 10);
    msg = strsplit(msg, ':');
    if found==0
        showSearchResults([0], handles.bestMatchPanel, handles);
        ed = errordlg([msg{2:end}], msg{1}, 'modal');
        uiwait(ed);
    else
        showSearchResults(videoNames, handles.bestMatchPanel, handles);
    end
    videoNames = db_findBestMatchVideos([tvChannel 0 0 0], 10);
    showSearchResults(videoNames, handles.tvChannelPanel, handles);
    videoNames = db_findBestMatchVideos([0 sport 0 0], 10);
    showSearchResults(videoNames, handles.sportPanel, handles);
    videoNames = db_findBestMatchVideos([0 0 team 0], 10);
    showSearchResults(videoNames, handles.teamPanel, handles);
    videoNames = db_findBestMatchVideos([0 0 0 player], 10);
    showSearchResults(videoNames, handles.playerPanel, handles);
    % reset pointer
    set(handles.figure1, 'pointer', 'arrow');
    delete(h);
end


% --- Executes on button press in videoSearchButton.
function videoSearchButton_Callback(hObject, eventdata, handles)
% hObject    handle to videoSearchButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
load('dbConfig.mat', 'supportedVideoFormats');
formatspec = '';
for i = 1 : length(supportedVideoFormats)
    formatspec = [formatspec, '*.', supportedVideoFormats{i}, ';'];
end
[filename, pathstr] = uigetfile(formatspec, 'Select the video to search');
if ischar(filename)
    h = msgbox('Searching Video...', 'Please Wait...');
    % set pointer to indicate processing
    set(handles.figure1, 'pointer', 'watch');
    drawnow;
    videoURI = [pathstr, filename];
    indexMap = tag_getAllTags(videoURI);
    [videoNames, found, msg] = db_findBestMatchVideos(indexMap, 10);
    msg = strsplit(msg, ':');
    if found==0
        showSearchResults([0], handles.bestMatchPanel, handles);
        ed = errordlg([msg{2:end}], msg{1}, 'modal');
        uiwait(ed);
    else
        showSearchResults(videoNames, handles.bestMatchPanel, handles);
    end
    videoNames = db_findBestMatchVideos([indexMap(1) 0 0 0], 10);
    showSearchResults(videoNames, handles.tvChannelPanel, handles);
    videoNames = db_findBestMatchVideos([0 indexMap(2) 0 0], 10);
    showSearchResults(videoNames, handles.sportPanel, handles);
    videoNames = db_findBestMatchVideos([0 0 indexMap(3) 0], 10);
    showSearchResults(videoNames, handles.teamPanel, handles);
    videoNames = db_findBestMatchVideos([0 0 0 indexMap(4)], 10);
    showSearchResults(videoNames, handles.playerPanel, handles);
    % reset pointer
    set(handles.figure1, 'pointer', 'arrow');
    delete(h);
end


% --- Executes on thumbnail click in panel.
function thumbnailButton_Callback(hObject, eventdata, handles)
% hObject    handle to backButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
pos = getpixelposition(handles.figure1);
handles.figure1.vlc = actxcontrol('VideoLAN.VLCPlugin.2', [0 0 pos(3) pos(4)-25], handles.figure1);
handles.figure1.vlc.playlist.add(hObject.videoURI);
handles.figure1.vlc.AutoLoop = 0;
handles.figure1.vlc.AutoPlay = true;
handles.isVlcOpen = true;
guidata(hObject, handles);


% --- Called on search result output.
function showSearchResults(videoNames, panel, handles)
% videoNames    horizontal vector of video names from db
child_handles = allchild(panel);
delete(child_handles);
panelPos = getpixelposition(panel);
panelWidth = panelPos(3);   panelHeight = panelPos(4);
videoNames = videoNames(videoNames>0);
if isempty(videoNames)
    uicontrol(panel,'Style','text',...
     'String','No videos found for this category :(',...
     'Position',[5 5 panelWidth-10, panelHeight-30]);
%      'Callback',{@thumbnailButton_Callback});
else
    load('dbConfig.mat', 'videoDbDir');
    videoDbDirURI = ['file:///', strrep(videoDbDir, '\', '/')];
    fullVideoNames = db_getFullVideoNames(videoNames);
    thumbnailWidth = panelWidth/10; thumbnailHeight = panelHeight-20;
    len = length(fullVideoNames);
    for i = 1 : len
        thumbnailImg = getThumbnail([videoDbDir, fullVideoNames{i}], thumbnailWidth-10, thumbnailHeight);
        thumbnailButton = uicontrol(panel,'Style','pushbutton',...
                 'CData',thumbnailImg,...
                 'Position',[(i-1)*thumbnailWidth+5,5,thumbnailWidth-10,thumbnailHeight],...
                 'Callback',{@thumbnailButton_Callback,handles});
        addprop(thumbnailButton, 'videoURI');
        thumbnailButton.videoURI = [videoDbDirURI, fullVideoNames{i}];
    end
end
