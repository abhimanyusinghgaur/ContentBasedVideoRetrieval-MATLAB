function varargout = ui_main(varargin)
%UI_MAIN M-file for ui_main.fig
%      UI_MAIN, by itself, creates a new UI_MAIN or raises the existing
%      singleton*.
%
%      H = UI_MAIN returns the handle to a new UI_MAIN or the handle to
%      the existing singleton*.
%
%      UI_MAIN('Property','Value',...) creates a new UI_MAIN using the
%      given property value pairs. Unrecognized properties are passed via
%      varargin to ui_main_OpeningFcn.  This calling syntax produces a
%      warning when there is an existing singleton*.
%
%      UI_MAIN('CALLBACK') and UI_MAIN('CALLBACK',hObject,...) call the
%      local function named CALLBACK in UI_MAIN.M with the given input
%      arguments.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help ui_main

% Last Modified by GUIDE v2.5 22-Apr-2018 16:30:46

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @ui_main_OpeningFcn, ...
                   'gui_OutputFcn',  @ui_main_OutputFcn, ...
                   'gui_LayoutFcn',  [], ...
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


% --- Executes just before ui_main is made visible.
function ui_main_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   unrecognized PropertyName/PropertyValue pairs from the
%            command line (see VARARGIN)
pos = get(0, 'screensize');
set(hObject, 'units','pixels','outerposition',[0 0 pos(3)-25 pos(4)-60]);

% Choose default command line output for ui_main
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes ui_main wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = ui_main_OutputFcn(hObject, eventdata, handles)
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes on button press in insertButton.
function insertButton_Callback(hObject, eventdata, handles)
% hObject    handle to insertButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
load('dbConfig.mat', 'supportedVideoFormats');
formatspec = '';
for i = 1 : length(supportedVideoFormats)
    formatspec = [formatspec, '*.', supportedVideoFormats{i}, ';'];
end
[filename, pathstr] = uigetfile(formatspec, 'Select the video to insert', 'MultiSelect', 'on');
disp(pathstr);
h = msgbox('Inserting Video...', 'Please Wait...');
% set pointer to indicate processing
oldPointer = get(handles.figure1, 'pointer'); 
set(handles.figure1, 'pointer', 'watch');
drawnow;
if iscell(filename)
%   insert multiple videos
    for i = 1 : length(filename)
        videoURI = [pathstr{i}, filename{i}];
        indexMap = tag_getAllTags(videoURI);
        disp(['Status: All Tags found.\nFile:', videoURI, '\nindexMap: ', indexMap]);
        [ inserted, msg ] = db_insertVideo( [pathstr filename], indexMap );
        if ~inserted
            msg = strsplit(msg, ':');
            ed = errordlg([msg{2:end}], msg{1}, 'modal');
        end
    end
    disp('Insert Complete!');
elseif ischar(filename)
%   insert single video
    videoURI = [pathstr, filename];
    indexMap = tag_getAllTags(videoURI);
    disp(['Status: All Tags found.\nFile:', videoURI, '\nindexMap: ', indexMap]);
    [ inserted, msg ] = db_insertVideo( [pathstr filename], indexMap );
    if ~inserted
        msg = strsplit(msg, ':');
        ed = errordlg([msg{2:end}], msg{1}, 'modal');
        uiwait(ed);
    end
    disp('Insert Complete!');
else
    disp('Insert Canceled!');
end
% reset pointer
set(handles.figure1, 'pointer', oldPointer);
delete(h);


% --- Executes on button press in searchButton.
function searchButton_Callback(hObject, eventdata, handles)
% hObject    handle to searchButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% disp(handles.figure1);
% ui_searchFig = openfig('ui_search.fig','reuse', 'invisible');
% handles.figure1 = ui_searchFig;
% disp(handles.figure1);
% disp('done');
close();
ui_search();


% --- Executes on button press in deleteButton.
function deleteButton_Callback(hObject, eventdata, handles)
% hObject    handle to deleteButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
