function varargout = LV_Segmenter(varargin)
% LV_SEGMENTER MATLAB code for LV_Segmenter.fig
%      LV_SEGMENTER, by itself, creates a new LV_SEGMENTER or raises the existing
%      singleton*.
%
%      H = LV_SEGMENTER returns the handle to a new LV_SEGMENTER or the handle to
%      the existing singleton*.
%
%      LV_SEGMENTER('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in LV_SEGMENTER.M with the given input arguments.
%
%      LV_SEGMENTER('Property','Value',...) creates a new LV_SEGMENTER or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before LV_Segmenter_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to LV_Segmenter_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help LV_Segmenter

% Last Modified by GUIDE v2.5 17-Dec-2020 15:38:05

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @LV_Segmenter_OpeningFcn, ...
                   'gui_OutputFcn',  @LV_Segmenter_OutputFcn, ...
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



% --- Executes just before LV_Segmenter is made visible.
function LV_Segmenter_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to LV_Segmenter (see VARARGIN)

% Choose default command line output for LV_Segmenter
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes LV_Segmenter wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = LV_Segmenter_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;



% --- Executes on button press in Load_Image.
function Load_Image_Callback(hObject, eventdata, handles)
% hObject    handle to Load_Image (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
%handles    structure with handles and user data (see GUIDATA) 
global filename;
global pathname;
global file; 
global data; 
global image_4d; 
global image_1D;
global image_1D_mirror;
global n;
n=3;

[filename, pathname] = uigetfile({'*.nii.gz'},'Pick a file');        
file = strcat(pathname, filename);
data = load_nii(file);
image_4d = data.img;
image_1D = image_4d(:,:,n);
image_1D_rotate = imrotate(image_1D,270);
image_1D_mirror = flipdim(image_1D_rotate,2);
axes(handles.axes1);
imshow(image_1D_mirror,[]);
[x,y,z,t] = size(image_4d);
z = num2str(z);
set(handles.slice, 'String', z);



% --- Executes on button press in Segment.
function Segment_Callback(hObject, eventdata, handles)
% hObject    handle to Segment (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

%Finding the center of the Image
global filename;
global pathname;
global file; 
global data; 
global image_4d; 
global image_1D;
global image_1D_mirror;
global Biggest_Blob;
global n;

m = num2str(n);
set(handles.dslice, 'String', m);

[rows columns numberOfColorChannels] = size(image_1D_mirror);
y_center = rows / 2;
x_center = columns / 2;
croppedImage = imcrop(image_1D_mirror, [x_center-45 y_center-45 90 90]);

%Quantization(Binarization) using Otsu's Threshold
level = multithresh(croppedImage);
im_quantized = imquantize(croppedImage, level);

%Canny Edge detection
canny_edged = edge(im_quantized,'canny');

%Dilation to increase the detection border
diskElem = strel('line',3,3);
Img = imdilate(canny_edged, diskElem);

%clearing the elements at the border
border_cleared = imclearborder(Img);

%filing the center elements to creat blobs
Blobs = imfill(border_cleared,'holes');

%Deleting all blobs less than 300 pixels(total image=1101 pixels), biggest
%blob is the binary mask.
Biggest_Blob = bwareaopen(Blobs,300);

%Finding the boundary infromation of the mask
[B,L]=bwboundaries(Biggest_Blob,'noholes');

axes(handles.axes2);
imshow(croppedImage,[]);

axes(handles.axes3);
imshow(Biggest_Blob,[]);

axes(handles.axes4);
imshow(croppedImage,[]);
hold on
for i=1:length(B)
    plot(B{i}(:,2),B{i}(:,1), 'r' ,'linewidth',1.45);
end
hold off;


% --- Executes on button press in Refresh.
function Refresh_Callback(hObject, eventdata, handles)
% hObject    handle to Refresh (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
axes(handles.axes1); cla;
axes(handles.axes2); cla;
axes(handles.axes3); cla;
axes(handles.axes4); cla;
axes(handles.axes5); cla;
axes(handles.axes6); cla;
axes(handles.axes7); cla;
set(handles.slice, 'String', ' ');
set(handles.Dice_score, 'String', ' ');
set(handles.dslice, 'String', ' ');
set(handles.dslice2, 'String', ' ');



% --- Executes on button press in Load_GroundTruth.
function Load_GroundTruth_Callback(hObject, eventdata, handles)
% hObject    handle to Load_GroundTruth (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global image_1D_mirror2;
global data2;
global l;
l = 3;

[filename2, pathname2] = uigetfile({'*.nii.gz'},'Pick the ground truth file');        
file2 = strcat(pathname2, filename2);
data2 = load_nii(file2);
image_4d2 = data2.img;
image_1D2 = image_4d2(:,:,l);
image_1D_rotate2 = imrotate(image_1D2,270);
image_1D_mirror2 = flipdim(image_1D_rotate2,2);
axes(handles.axes5);
imshow(image_1D_mirror2, []);



% --- Executes on button press in Calculate_Dice.
function Calculate_Dice_Callback(hObject, eventdata, handles)
% hObject    handle to Calculate_Dice (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global image_1D_mirror2;
global Biggest_Blob;
global dice;
global l;

k = num2str(l);
set(handles.dslice2, 'String', k);

[rows2 columns2 numberOfColorChannels2] = size(image_1D_mirror2);
y_center2 = rows2 / 2;
x_center2 = columns2 / 2;
croppedImage2 = imcrop(image_1D_mirror2, [x_center2-45 y_center2-45 90 90]);
axes(handles.axes6);
imshow(croppedImage2,[]);
endocard = max(croppedImage2,2.1);
binarized2 = imbinarize(endocard);
axes(handles.axes7);
imshow(binarized2,[]);
dice = (2*nnz(Biggest_Blob&binarized2))/(nnz(Biggest_Blob)+nnz(binarized2));
dice = num2str(dice);
set(handles.Dice_score, 'String', dice);



function Dice_score_Callback(hObject, eventdata, handles)
% hObject    handle to Dice_score (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of Dice_score as text
%        str2double(get(hObject,'String')) returns contents of Dice_score as a double


% --- Executes during object creation, after setting all properties.
function Dice_score_CreateFcn(hObject, eventdata, handles)
% hObject    handle to Dice_score (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function slice_Callback(hObject, eventdata, handles)
% hObject    handle to slice (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of slice as text
%        str2double(get(hObject,'String')) returns contents of slice as a double


% --- Executes during object creation, after setting all properties.
function slice_CreateFcn(hObject, eventdata, handles)
% hObject    handle to slice (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function dslice_Callback(hObject, eventdata, handles)
% hObject    handle to dslice (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of dslice as text
%        str2double(get(hObject,'String')) returns contents of dslice as a double


% --- Executes during object creation, after setting all properties.
function dslice_CreateFcn(hObject, eventdata, handles)
% hObject    handle to dslice (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in selectSlice_1.
function selectSlice_1_Callback(hObject, eventdata, handles)
% hObject    handle to selectSlice_1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global filename;
global pathname;
global file; 
global data; 
global image_4d; 
global image_1D;
global image_1D_mirror;
global Biggest_Blob;
global n;
n = str2num(get(handles.dslice,'String'));

image_1D = image_4d(:,:,n);
image_1D_rotate = imrotate(image_1D,270);
image_1D_mirror = flipdim(image_1D_rotate,2);
axes(handles.axes1);
imshow(image_1D_mirror,[]);

m = num2str(n);
set(handles.dslice, 'String', m);

[rows columns numberOfColorChannels] = size(image_1D_mirror);
y_center = rows / 2;
x_center = columns / 2;
croppedImage = imcrop(image_1D_mirror, [x_center-45 y_center-45 90 90]);

%Quantization(Binarization) using Otsu's Threshold
level = multithresh(croppedImage);
im_quantized = imquantize(croppedImage, level);

%Canny Edge detection
canny_edged = edge(im_quantized,'canny');

%Dilation to increase the detection border
diskElem = strel('line',3,3);
Img = imdilate(canny_edged, diskElem);

%clearing the elements at the border
border_cleared = imclearborder(Img);

%filing the center elements to creat blobs
Blobs = imfill(border_cleared,'holes');

%Deleting all blobs less than 300 pixels(total image=1101 pixels), biggest
%blob is the binary mask.
Biggest_Blob = bwareaopen(Blobs,300);

%Finding the boundary infromation of the mask
[B,L]=bwboundaries(Biggest_Blob,'noholes');

axes(handles.axes2);
imshow(croppedImage,[]);

axes(handles.axes3);
imshow(Biggest_Blob,[]);

axes(handles.axes4);
imshow(croppedImage,[]);
hold on
for i=1:length(B)
    plot(B{i}(:,2),B{i}(:,1), 'r' ,'linewidth',1.45);
end
hold off;



function dslice2_Callback(hObject, eventdata, handles)
% hObject    handle to dslice2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of dslice2 as text
%        str2double(get(hObject,'String')) returns contents of dslice2 as a double


% --- Executes during object creation, after setting all properties.
function dslice2_CreateFcn(hObject, eventdata, handles)
% hObject    handle to dslice2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in selectSlice_2.
function selectSlice_2_Callback(hObject, eventdata, handles)
% hObject    handle to selectSlice_2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global image_1D_mirror2;
global data2;
global l;
global image_1D_mirror2;
global Biggest_Blob;
global dice;
l = str2num(get(handles.dslice2,'String'));

image_4d2 = data2.img;
image_1D2 = image_4d2(:,:,l);
image_1D_rotate2 = imrotate(image_1D2,270);
image_1D_mirror2 = flipdim(image_1D_rotate2,2);
axes(handles.axes5);
imshow(image_1D_mirror2, []);

[rows2 columns2 numberOfColorChannels2] = size(image_1D_mirror2);
y_center2 = rows2 / 2;
x_center2 = columns2 / 2;
croppedImage2 = imcrop(image_1D_mirror2, [x_center2-45 y_center2-45 90 90]);
axes(handles.axes6);
imshow(croppedImage2,[]);
endocard = max(croppedImage2,2.1);
binarized2 = imbinarize(endocard);
axes(handles.axes7);
imshow(binarized2,[]);
dice = (2*nnz(Biggest_Blob&binarized2))/(nnz(Biggest_Blob)+nnz(binarized2));
dice = num2str(dice);
set(handles.Dice_score, 'String', dice);
