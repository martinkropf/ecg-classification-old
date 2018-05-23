function varargout = cincRecordViewer(varargin)
% WFDBRECORDVIEWER MATLAB code for wfdbRecordViewer.fig
%      WFDBRECORDVIEWER, by itself, creates a new WFDBRECORDVIEWER or raises the existing
%      singleton*.
%
%      H = WFDBRECORDVIEWER returns the handle to a new WFDBRECORDVIEWER or the handle to
%      the existing singleton*.
%
%      WFDBRECORDVIEWER('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in WFDBRECORDVIEWER.M with the given input arguments.
%
%      WFDBRECORDVIEWER('Property','Value',...) creates a new WFDBRECORDVIEWER or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before wfdbRecordViewer_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to wfdbRecordViewer_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%load
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help wfdbRecordViewer

% Last Modified by GUIDE v2.5 19-May-2017 07:41:13

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
    'gui_Singleton',  gui_Singleton, ...
    'gui_OpeningFcn', @cincRecordViewer_OpeningFcn, ...
    'gui_OutputFcn',  @cincRecordViewer_OutputFcn, ...
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

% --- Executes just before wfdbRecordViewer is made visible.
function cincRecordViewer_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to wfdbRecordViewer (see VARARGIN)

global current_record current_record_name current_records records tm tm_step target current_class current_result predictions res_dataset t avbeat_figure_1 avbeat_figure_2 avbeat_figure_3

% Choose default command line output for wfdbRecordViewer
handles.output = hObject;


[data_dir,signal_dir]=getLocalProperties();


current_class='All';
current_result='All';
current_record_name=1;
% Update handles structure
guidata(hObject, handles);
[filename,directoryname] = uigetfile([signal_dir,'*.hea'],'Select signal header file:');

tmp=dir([signal_dir,'*.hea']);


reffile = [directoryname, 'REFERENCE.csv'];
fid = fopen(reffile, 'r');
if(fid ~= -1)
    Ref = textscan(fid,'%s %s','Delimiter',',');
else
    error(['Could not open ' reffile ' for scoring. Exiting...'])
end
fclose(fid);
ansfile = [data_dir,filesep, 'answers.txt'];
fid = fopen(ansfile,'r');
if(fid ~= -1)
    ANSWERS = textscan(fid, '%s %s','Delimiter',',');
else
    error('Could not open users answer.txt for scoring. Run the generateValidationSet.m script and try again.')
end

% Header entfernen
%RECORDS = Ref{1};
predictions=ANSWERS{:,2};
target = Ref{2};
    
    
N=length(tmp);
records=cell(N,1);
current_record=1;
for n=1:N
    fname=tmp(n).name;
    records(n)={fname(1:end-4)};
    if(strcmp(fname,filename))
        current_record=n;
    end
end

current_records=records;
% current_target=target;
% current_prediction=prediction;
set(handles.RecordMenu,'String',current_records)
set(handles.RecordMenu,'Value',current_record)
loadRecord(records{current_record})
set(handles.ClassMenu,'String',{'All','N','A','O','~'})
set(handles.ResultMenu,'String',{'All','Wrong classification','Correct classification'})

%loadAnnotationList(records{current_record},handles);
set(handles.slider1,'Max',tm(end))
set(handles.slider1,'Min',tm(1))
set(handles.slider1,'SliderStep',[1 1]);
sliderStep=get(handles.slider1,'SliderStep');
tm_step=(tm(end)-tm(1)).*sliderStep(1);

% 
t=table;
object_handles = findall(hObject);
for idx = 1:length(object_handles)
    object_handle=object_handles(idx);
    if (strcmp(class(object_handle),'matlab.ui.control.Table'))
        t=object_handle;
    end
end

% 
% txtbox = uicontrol(hObject,'Style','text',...
%                 'String','Enter your name here.',...
%                 'Position',[1350 700 130 20]);
% txtbox = uicontrol(hObject,'Style','text',...
%                 'String','Enter your name here.',...
%                 'Position',[1350 685 130 20]);            
res_dataset=load('ait_result_dataset.mat');
avbeat_figure_1 = findobj(hObject,'tag','avbeat1');
avbeat_figure_2 = findobj(hObject,'tag','avbeat2');
avbeat_figure_3 = findobj(hObject,'tag','avbeat3');

wfdbplot(handles)



function varargout = cincRecordViewer_OutputFcn(~,~, handles)
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% Get default command line output from handles structure
varargout{1} = handles.output;

function PreviousButton_Callback(hObject, eventdata, handles)
global current_record current_records current_record_name
current_record=current_record - 1;
%dirty hack, only works for CinC2017 training set
idx=str2double(strrep(string(current_records(current_record)),'A',''));
current_record_name=idx;
set(handles.RecordMenu,'Value',current_record);
Refresh(hObject, eventdata, handles)


function NextButton_Callback(hObject, eventdata, handles)
global current_record current_records current_record_name
current_record=current_record + 1;
%dirty hack, only works for CinC2017 training set
idx=str2double(strrep(string(current_records(current_record)),'A',''));
current_record_name=idx;
set(handles.RecordMenu,'Value',current_record);
Refresh(hObject, eventdata, handles)


% --------------------------------------------------------------------
function FileMenu_Callback(hObject, eventdata, handles)
% hObject    handle to FileMenu (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --------------------------------------------------------------------
function OpenMenuItem_Callback(hObject, eventdata, handles)
file = uigetfile('*.fig');
if ~isequal(file, 0)
    open(file);
end

% --------------------------------------------------------------------
function PrintMenuItem_Callback(hObject, eventdata, handles)
printdlg(handles.figure1)

% --------------------------------------------------------------------
function CloseMenuItem_Callback(hObject, eventdata, handles)
selection = questdlg(['Close ' get(handles.figure1,'Name') '?'],...
    ['Close ' get(handles.figure1,'Name') '...'],...
    'Yes','No','Yes');
if strcmp(selection,'No')
    return;
end

delete(handles.figure1)


% --- Executes on selection change in RecordMenu.
function RecordMenu_Callback(hObject, eventdata, handles)

global current_record current_record_name records current_prediction target predictions current_result current_class
current_record=get(handles.RecordMenu,'Value');

contents = cellstr(get(hObject,'String'));
str= contents{get(hObject,'Value')};
%dirty hack, only works for CinC2017 training set
idx=str2num(strrep(str,'A',''));
current_record_name=idx;


Refresh(hObject, eventdata, handles)


% --- Executes during object creation, after setting all properties.
function RecordMenu_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on slider movement.
function slider1_Callback(hObject, eventdata, handles)
wfdbplot(handles)


% --- Executes during object creation, after setting all properties.
function slider1_CreateFcn(hObject, eventdata, handles)
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end



function loadRecord(fname)
global tm signal info tm_step signalDescription analysisSignal analysisTime
h = waitbar(0,'Loading Data. Please wait...');
try
    [data_dir,signal_dir]=getLocalProperties();
    fullname=[signal_dir,fname]
    [tm,signal]=rdmat(fullname);

    info(1).Description='ECG';
    info(1).Gain='1000 adu/mV';
    info(1).SamplingFrequency=300;
    %info=load
catch
    [tm,signal]=rdsamp(fullname);
end

R=length(info);
analysisSignal=[];
analysisTime=[];
signalDescription=cell(R,1);
for r=1:R
    signalDescription(r)={info(r).Description};
end


close(h)

function loadAnn1(fname,annName)
global ann1
h = waitbar(0,'Loading Annotations. Please wait...');
if(strcmp(fname,'none'))
    ann1=[];
else
    [ann1,type,subtype,chan,num,comments]=rdann(fname,annName);
end
close(h)

function loadAnn2(fname,annName)
global ann2
h = waitbar(0,'Loading Annotations. Please wait...');
if(strcmp(fname,'none'))
    ann1=[];
else
    [ann2,type,subtype,chan,num,comments]=rdann(fname,annName);
end
close(h)



%set(handles.Ann1Menu,'String',annotations)
%set(handles.Ann2Menu,'String',annotations)


function wfdbplot(handles)
global tm signal info tm_step ann1 ann2 annDiff ann1RR analysisSignal analysisTime analysisUnits analysisYAxis
axes(handles.axes1);
cla;

%Normalize each signal and plot them with an offset
[N,CH]=size(signal);
offset=0.5;

%Get time info
center=get(handles.slider1,'Value');
maxSlide=get(handles.slider1,'Max');
minSlide=get(handles.slider1,'Min');
if(tm_step == ( tm(end)-tm(1) ))
    tm_start=tm(1);
    tm_end=tm(end);
elseif(center==maxSlide)
    tm_end=tm(end);
    tm_start=tm_end - tm_step;
elseif(center==minSlide)
    tm_start=tm(1);
    tm_end=tm_start + tm_step;
else
    tm_start=center - tm_step/2;
    tm_end=center + tm_step/2;
end
[~,ind_start]=min(abs(tm-tm_start));
[~,ind_end]=min(abs(tm-tm_end));

DC=min(signal(ind_start:ind_end,:),[],1);
sig=signal - repmat(DC,[N 1]);
SCALE=max(sig(ind_start:ind_end,:),[],1);
SCALE(SCALE==0)=1;
sig=offset.*sig./repmat(SCALE,[N 1]);
OFFSET=offset.*[1:CH];
sig=sig + repmat(OFFSET,[N 1]);

for ch=1:CH;
    plot(tm(ind_start:ind_end),sig(ind_start:ind_end,ch))
    hold on ; grid on
    if(~isempty(ann1))
       
        plot(tm(ann1(:,1)),OFFSET(ch),'go','MarkerSize',5,'MarkerFaceColor','g')
        x=tm(ann1(:,1))
        y=ones(size(ann1(:,1)))
        texts=char(ann1(:,2))
        text(x,y,texts)
        
    end
    if(~isempty(ann2))
        tmp_ann2=ann2((ann2>ind_start) & (ann2<ind_end));
        if(~isempty(tmp_ann2))
            if(length(tmp_ann2)<30)
                msize=8;
            else
                msize=5;
            end
            plot(tm(tmp_ann2),OFFSET(ch),'r*','MarkerSize',msize,'MarkerFaceColor','r')
        end
    end
    if(~isempty(info(ch).Description))
        text(tm(ind_start),ch*offset+0.85*offset,info(ch).Description,'FontWeight','bold','FontSize',12)
    end
    
end
set(gca,'YTick',[])
set(gca,'YTickLabel',[])
set(gca,'FontSize',10)
set(gca,'FontWeight','bold')
xlabel('Time (seconds)')
xlim([tm(ind_start) tm(ind_end)])

%Plot annotations in analysis window
if(~isempty(annDiff) & (get(handles.AnnotationMenu,'Value')==2))
    axes(handles.AnalysisAxes);
    df=annDiff((ann1>ind_start) & (ann1<ind_end));
    plot(tm(tmp_ann1),df,'k*-')
    text(tm(tmp_ann1(1)),max(df),'Ann Diff','FontWeight','bold','FontSize',12)
    grid on
    ylabel('Diff (seconds)')
    xlim([tm(ind_start) tm(ind_end)])
end

%Plot custom signal in the analysis window
if(~isempty(analysisSignal))
    axes(handles.AnalysisAxes);
    if(isempty(analysisYAxis))
        %Standard 2D Plot
        plot(analysisTime,analysisSignal,'k')
        grid on;
    else
        if(isfield(analysisYAxis,'isImage') && analysisYAxis.isImage)
            %Plot scaled image
            imagesc(analysisSignal)
        else
        %3D Plot with colormap
        surf(analysisTime,analysisYAxis.values,analysisSignal,'EdgeColor','none');
        axis xy; axis tight; colormap(analysisYAxis.map); view(0,90);
        end
        ylim([analysisYAxis.minY analysisYAxis.maxY])
    end
    xlim([tm(ind_start) tm(ind_end)])
    if(~isempty(analysisUnits))
        ylabel(analysisUnits)
    end
else
    %Plot RR series in analysis window
    if(~isempty(ann1RR) & (get(handles.AnnotationMenu,'Value')==3))
        Nann=length(ann1);
        axes(handles.AnalysisAxes);
        ind=(ann1(1:end)>ind_start) & (ann1(1:end)<ind_end);
        ind=find(ind==1)+1;
        if(~isempty(ind) && ind(end)> Nann)
            ind(end)=[];
        end
        tm_ind=ann1(ind);
        del_ind=find(tm_ind>N);
        if(~isempty(del_ind))
            ind(ann1(ind)==tm_ind(del_ind))=[];
            tm_ind(del_ind)=[];
        end
        if(~isempty(ind) && ind(end)>length(ann1RR))
            del_ind=find(ind>length(ann1RR));
            ind(del_ind)=[];
            tm_ind(del_ind)=[];
        end
        plot(tm(tm_ind),ann1RR(ind),'k*-')
        text(tm(tm_ind(1)),max(df),'RR Series','FontWeight','bold','FontSize',12)
        grid on
        ylabel('Interval (seconds)')
        if(~isnan(ind_start) && ~isnan(ind_end) && ~(ind_start==ind_end))
            xlim([tm(ind_start) tm(ind_end)])
        end
        
    end
end


% --- Executes on selection change in TimeScaleSelection.
function TimeScaleSelection_Callback(hObject, eventdata, handles)
global tm_step tm

TM_SC=[tm(end)-tm(1) 120 60 30 15 10 5 1];
index = get(handles.TimeScaleSelection, 'Value');
%Normalize step to time range
if(TM_SC(index)>TM_SC(1))
    index=1;
end
stp=TM_SC(index)/TM_SC(1);
set(handles.slider1,'SliderStep',[stp stp*10]);
tm_step=TM_SC(1).*stp(1);

axes(handles.axes1);
cla;
wfdbplot(handles)

% --- Executes during object creation, after setting all properties.
function TimeScaleSelection_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in AmplitudeScale.
function AmplitudeScale_Callback(hObject, eventdata, handles)
wfdbplot(handles)


% --- Executes during object creation, after setting all properties.
function AmplitudeScale_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in Ann1Menu.
function Ann1Menu_Callback(hObject, eventdata, handles)
global ann1 records current_record

ind = get(handles.Ann1Menu, 'Value');
annStr=get(handles.Ann1Menu, 'String');
loadAnn1(records{current_record},annStr{ind})
wfdbplot(handles)


% --- Executes during object creation, after setting all properties.
function Ann1Menu_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in Ann2Menu.
function Ann2Menu_Callback(hObject, eventdata, handles)
global ann2 records current_record

ind = get(handles.Ann2Menu, 'Value');
annStr=get(handles.Ann2Menu, 'String');
loadAnn2(records{current_record},annStr{ind})
wfdbplot(handles)


% --- Executes during object creation, after setting all properties.
function Ann2Menu_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function AnnotationMenu_Callback(hObject, eventdata, handles)

global ann1 ann1RR info tm ann2

tips=0;
Fs=double(info(1).SamplingFrequency);
annStr=get(handles.AnnotationMenu,'String');
index=get(handles.AnnotationMenu,'Value');
switch(annStr{index})
    case 'Plot RR Series Ann1'
        h = waitbar(0,'Generating RR Series. Please wait...');
        %Compare annotation with ann1menu being the reference
        ann1RR=diff(ann1)./double(info(1).SamplingFrequency);
        close(h)
        wfdbplot(handles)
        
    case 'Add annotations to Ann1'
        %Get closest sample using ginput
        if(tips)
            helpdlg('Left click to add multiple annotations. Hit Enter when done.','Adding Annotations');
        end
        axes(handles.axes1);
        [x,~]= ginput;
        
        %Convert to samples ann to ann1
        x=round(x*Fs);
        ann1=sort([ann1;x]);
        %Refresh annotation plot
        wfdbplot(handles)
        
    case 'Delete annotations from Ann1'
        
        %Get closest sample using ginput
        if(tips)
            helpdlg('Left click on annotations to remove multiple. Hit Enter when done.','Removing Annotations');
        end
        axes(handles.axes1);
        [x,~]= ginput;
        rmN=length(x);
        rm_ind=zeros(rmN,1);
        for n=1:rmN
            [~,tmp_ind]=min(abs(x(n)-tm(ann1)));
            rm_ind(n)=tmp_ind;
        end
        if~(isempty(rm_ind))
            ann1(rm_ind)=[];
        end
        %Refresh annotation plot
        wfdbplot(handles)
        
    case 'Delete annotations in a range from Ann1'
        
        %Get closest sample using ginput
        if(tips)
            helpdlg('Left click on start and end regions. Hit Enter when done.','Removing Annotations');
        end
        axes(handles.axes1);
        [x,~]= ginput;
        [~,start_ind]=min(abs(x(end-1)-tm(ann1)));
        [~,end_ind]=min(abs(x(end)-tm(ann1)));
        ann1(start_ind:end_ind)=[];
        %Refresh annotation plot
        wfdbplot(handles)
        
    case 'Edit annotations in Ann1'
        %Modify closest sample using ginput
        if(tips)
            helpdlg('Left click on waveform will shift closest annotation to the clicked point. Hit Enter when done.','Adding Annotations');
        end
        axes(handles.axes1);
        [x,~]= ginput;
        editN=length(x);
        edit_ind=zeros(editN,1);
        for n=1:editN
            [~,tmp_ind]=min(abs(x(n)-tm(ann1)));
            edit_ind(n)=tmp_ind;
        end
        if~(isempty(edit_ind))
            ann1(edit_ind)=round(x*Fs);
        end
        %Refresh annotation plot
        wfdbplot(handles)
        
    
        
end


function AnnotationMenu_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function Refresh(hObject, eventdata, handles)
global ann1 records current_records current_record tm signal info analysisSignal analysisTime analysisUnits analysisYAxis target predictions current_record_name res_dataset t current_class avbeat_figure_1 avbeat_figure_2 avbeat_figure_3
cla(avbeat_figure_1)
cla(avbeat_figure_2)
cla(avbeat_figure_3)


loadRecord(current_records{current_record});
% loadAnnotationList(records{current_record},handles);
set(handles.TargetLabel,'String',strcat('Target: ',target(current_record_name)));
set(handles.PredictionLabel,'String',strcat('Pred: ',predictions(current_record_name)));
features=res_dataset.res_dataset(current_record_name,:);
correct_idx= find(strcmp(predictions,target(current_record_name)) & strcmp(target,target(current_record_name)));
correct_data=res_dataset.res_dataset(correct_idx,:);
disp([num2str(length(correct_data)), ' correct predictions for class ', target(current_record_name)]);
correct_mean=nanmean(double(correct_data));
feature_col=dataset2cell(features);
mean_col=num2cell(correct_mean);
[data_dir,signal_dir]=getLocalProperties();
load([signal_dir,current_records{current_record}, '.ait_challenge_8.V37'],'-mat');
ann1=QRS1;
types=ann1(:,2)'
if length(avbeats.seq)==1
    plot(avbeat_figure_1,avbeats.seq{1,1});    
end
if length(avbeats.seq)==2
    plot(avbeat_figure_1,avbeats.seq{1,1});    
    plot(avbeat_figure_2,avbeats.seq{1,2});    
end
if length(avbeats.seq)>2
    plot(avbeat_figure_1,avbeats.seq{1,1});    
    plot(avbeat_figure_2,avbeats.seq{1,2});  
    plot(avbeat_figure_3,avbeats.seq{1,3});  
end






t.Data=[feature_col;mean_col]';


%Get Raw Signal
analysisTime=tm;
analysisSignal=signal(:,1);
analysisUnits=strsplit(info(1).Gain,'/');
if(length(analysisUnits)>1)
    analysisUnits=analysisUnits{2};
else
    analysisUnits=[];
end
Fs=double(info(1).SamplingFrequency);
analysisYAxis=[];
wfdbplot(handles);

%Ann1Menu_Callback(hObject, eventdata, handles)
%Ann2Menu_Callback(hObject, eventdata, handles)
%AnalysisMenu_Callback(hObject, eventdata, handles)

% --- Executes on selection change in SignalMenu.
function SignalMenu_Callback(hObject, eventdata, handles)
% hObject    handle to SignalMenu (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns SignalMenu contents as cell array
%        contents{get(hObject,'Value')} returns selected item from SignalMenu

global tm signal info analysisSignal analysisTime analysisUnits analysisYAxis
contents = cellstr(get(hObject,'String'));
ind=get(handles.ClassMenu,'Value');
str= contents{get(hObject,'Value')};
% 
% %Get Raw Signal
% analysisTime=tm;
% analysisSignal=signal(:,1);
% analysisUnits=strsplit(info(1).Gain,'/');
% if(length(analysisUnits)>1)
%     analysisUnits=analysisUnits{2};
% else
%     analysisUnits=[];
% end
% Fs=double(info(1).SamplingFrequency);
% analysisYAxis=[];
Refresh(hObject, eventdata, handles)
switch str
    
    case 'Plot Raw Signal'
        wfdbplot(handles);
        
    case 'Apply General Filter'
        [analysisSignal]=wfdbFilter(analysisSignal);
        wfdbplot(handles);
        
    case '60/50 Hz Notch Filter'
        [analysisSignal]=wfdbNotch(analysisSignal,Fs);
        wfdbplot(handles);
        
    case 'Resonator Filter'
        [analysisSignal]=wfdbResonator(analysisSignal,Fs);
        wfdbplot(handles);
        
    case 'Custom Function'
        %[analysisSignal,analysisTime]=wfdbFunction(analysisSignal,analysisTime,Fs);
        analysisSignal=analysisSignal*-1;
        wfdbplot(handles);
        
    case 'Spectogram Analysis'
        [analysisSignal,analysisTime,analysisYAxis,analysisUnits]=wfdbSpect(analysisSignal,Fs);
        wfdbplot(handles);
        
    case 'Wavelets Analysis'
        [analysisSignal,analysisYAxis,analysisUnits]=wfdbWavelets(analysisSignal,Fs);
        wfdbplot(handles);
    case 'Test'
        [analysisSignal]=wfdbFilter(analysisSignal);
        wfdbplot(handles);        
end


% --- Executes during object creation, after setting all properties.
function SignalMenu_CreateFcn(hObject, eventdata, handles)
% hObject    handle to SignalMenu (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in ClassMenu.
function ClassMenu_Callback(hObject, eventdata, handles)
% hObject    handle to ClassMenu (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global target records current_records predictions current_class current_result
contents = cellstr(get(hObject,'String'));
selected_class=contents{get(hObject,'Value')};
current_class=selected_class;

if strcmp(current_class,'All')
    if strcmp(current_result,'All')
        idx=find(strcmp(target,target));
    elseif strcmp(current_result,'Wrong classification')
        idx=find(~strcmp(predictions,target));
    elseif strcmp(current_result,'Correct classification')
        idx=find(strcmp(predictions,target));
    end
else
    if strcmp(current_result,'All')
        idx=find(strcmp(target,target) & strcmp(current_class, target));
    elseif strcmp(current_result,'Wrong classification')
        idx=find(~strcmp(predictions,target) & strcmp(current_class, target));
    elseif strcmp(current_result,'Correct classification')
        idx=find(strcmp(predictions,target) & strcmp(current_class, target));
    end
end

current_records=records(idx);
set(handles.RecordMenu,'String',current_records)


% --- Executes during object creation, after setting all properties.
function ClassMenu_CreateFcn(hObject, eventdata, handles)
% hObject    handle to ClassMenu (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function [analysisSignal]=wfdbFilter(analysisSignal)

%Set Low-pass default values
dlgParam.prompt={'Filter Design Function (should return "a" and "b", for use by FILTFILT ):'};
dlgParam.defaultanswer={'b=fir1(48,[0.1 0.5]);a=1;'};
dlgParam.name='Filter Design Command';
dlgParam.numlines=1;

answer=inputdlg(dlgParam.prompt,dlgParam.name,dlgParam.numlines,dlgParam.defaultanswer);
h = waitbar(0,'Filtering Data. Please wait...');
try
    eval([answer{1} ';']);
    analysisSignal=filtfilt(b,a,analysisSignal);
catch
    errordlg(['Unable to filter data! Error: ' lasterr])
end
close(h)


function [analysisSignal]=wfdbNotch(analysisSignal,Fs)
% References:
% *Rangayyan (2002), "Biomedical Signal Analysis", IEEE Press Series in BME
%
% *Hayes (1999), "Digital Signal Processing", Schaum's Outline
%Set Low-pass default values
dlgParam.prompt={'Control Paramter (0 < r < 1 ):','Notch Frequency (Hz):'};
dlgParam.defaultanswer={'0.995','60'};
dlgParam.name='Notch Filter Design';
dlgParam.numlines=1;

answer=inputdlg(dlgParam.prompt,dlgParam.name,dlgParam.numlines,dlgParam.defaultanswer);
h = waitbar(0,'Filtering Data. Please wait...');
r = str2num(answer{1});   % Control parameter. 0 < r < 1.
fn= str2num(answer{2});

cW = cos(2*pi*fn/Fs);
b=[1 -2*cW 1];
a=[1 -2*r*cW r^2];
try
    eval([answer{1} ';']);
    analysisSignal=filtfilt(b,a,analysisSignal);
catch
    errordlg(['Unable to filter data! Error: ' lasterr])
end
close(h)


function [analysisSignal]=wfdbResonator(analysisSignal,Fs)
% References:
% *Rangayyan (2002), "Biomedical Signal Analysis", IEEE Press Series in BME
%
% *Hayes (1999), "Digital Signal Processing", Schaum's Outline
%Set Low-pass default values
dlgParam.prompt={'Resonating Frequency (Hz):','Q factor:'};
dlgParam.defaultanswer={num2str(Fs/5),'50'};
dlgParam.name='Resonator Filter Design';
dlgParam.numlines=1;

answer=inputdlg(dlgParam.prompt,dlgParam.name,dlgParam.numlines,dlgParam.defaultanswer);
h = waitbar(0,'Filtering Data. Please wait...');
fn= str2num(answer{1});
K= str2num(answer{2});

%Similar  to 'Q1' but more accurate
%For details see IEEE SP 2008 (5), pg 113
beta=1+K;
f=pi*fn/Fs;
numA=tan(pi/4 - f);
denA=sin(2*f)+cos(2*f)*numA;
A=numA/denA;
b=[1 -2*A A.^2];
a=[ (beta + K*(A^2)) -2*A*(beta+K) ((A^2)*beta + K)];

try
    eval([answer{1} ';']);
    analysisSignal=filtfilt(b,a,analysisSignal);
catch
    errordlg(['Unable to filter data! Error: ' lasterr])
end
close(h)


function [analysisSignal,analysisTime]=wfdbFunction(analysisSignal,analysisTime,Fs)

dlgParam.prompt={'Custom Function must output variables ''analysisSignal'' and ''analysisTime'''};
dlgParam.defaultanswer={'[analysisSignal,analysisTime]=foo(analysisSignal,analysisTime,Fs)'};
dlgParam.name='Evaluate Command:';

answer=inputdlg(dlgParam.prompt,dlgParam.name,dlgParam.numlines,dlgParam.defaultanswer);
h = waitbar(0,'Executing code on signal. Please wait...');
try
    eval([answer{1} ';']);
    analysisSignal=filtfilt(b,a,analysisSignal);
catch
    errordlg(['Unable to execute code!! Error: ' lasterr])
end
close(h)


function [analysisSignal,analysisTime,analysisYAxis,analysisUnits]=wfdbSpect(analysisSignal,Fs)

persistent dlgParam
if(isempty(dlgParam))
    dlgParam.prompt={'window size','overlap size','Min Frequency (Hz)','Max Frequency (Hz)','colormap'};
    dlgParam.window=2^10;
    dlgParam.minY= 0;
    dlgParam.maxY= floor(Fs/2);
    dlgParam.noverlap=round(dlgParam.window/2);
    dlgParam.map='jet';    
    dlgParam.name='Spectogram Parameters';
    dlgParam.numlines=1;
end

dlgParam.defaultanswer={num2str(dlgParam.window),num2str(dlgParam.noverlap),...
    num2str(dlgParam.minY),num2str(dlgParam.maxY),dlgParam.map};  

answer=inputdlg(dlgParam.prompt,dlgParam.name,dlgParam.numlines,dlgParam.defaultanswer);
h = waitbar(0,'Calculating spectogram. Please wait...');
dlgParam.window= str2num(answer{1});
dlgParam.noverlap= str2num(answer{2});
analysisYAxis.minY= str2num(answer{3});
analysisYAxis.maxY= str2num(answer{4});
analysisYAxis.map=answer{5};

dlgParam.minY=analysisYAxis.minY;
dlgParam.maxY=analysisYAxis.maxY;
dlgParam.map=analysisYAxis.map;

[~,F,analysisTime,analysisSignal] = spectrogram(analysisSignal,dlgParam.window,...
    dlgParam.noverlap,dlgParam.window,Fs,'yaxis');

analysisSignal=10*log10(abs(analysisSignal));
analysisYAxis.values=F;
analysisUnits='Frequency (Hz)';
close(h)


function [analysisSignal,analysisYAxis,analysisUnits]=wfdbWavelets(analysisSignal,Fs)

persistent dlgParam
if(isempty(dlgParam))
    dlgParam.prompt={'wavelet','scales','colormap','logScale'};
    dlgParam.wavelet='coif2';    
    dlgParam.scales='1:28';    
    dlgParam.map='jet';    
    dlgParam.log='false';
    dlgParam.name='Wavelet Parameters';
    dlgParam.numlines=1;
end

dlgParam.defaultanswer={num2str(dlgParam.wavelet),num2str(dlgParam.scales),dlgParam.map,dlgParam.log};  

answer=inputdlg(dlgParam.prompt,dlgParam.name,dlgParam.numlines,dlgParam.defaultanswer);
h = waitbar(0,'Calculating wavelets. Please wait...');
dlgParam.wavelet= answer{1};
dlgParam.scales = str2num(answer{2});
dlgParam.map= answer{3};
dlgParam.log= answer{4};
analysisYAxis.minY= dlgParam.scales(1);
analysisYAxis.maxY= dlgParam.scales(end);
analysisYAxis.map=dlgParam.map;
analysisYAxis.isImage=1;

coefs = cwt(analysisSignal,dlgParam.scales,dlgParam.wavelet);
analysisSignal = wscalogram('',coefs);
if(strcmp(dlgParam.log,'true'))
    analysisSignal=log(analysisSignal);
end
analysisYAxis.values=dlgParam.scales;
analysisUnits='Scale';
close(h)


      


% --- Executes during object creation, after setting all properties.
function PredictionLabel_CreateFcn(hObject, eventdata, handles)
% hObject    handle to PredictionLabel (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called



% --- Executes on selection change in ResultMenu.
function ResultMenu_Callback(hObject, eventdata, handles)
% hObject    handle to ResultMenu (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns ResultMenu contents as cell array
%        contents{get(hObject,'Value')} returns selected item from ResultMenu

global target records current_records predictions current_class current_result

contents = cellstr(get(hObject,'String'));
selected_result=contents{get(hObject,'Value')};
current_result=selected_result;

if strcmp(current_class,'All')
    if strcmp(selected_result,'All')
        idx=find(strcmp(target,target));
    elseif strcmp(selected_result,'Wrong classification')
        idx=find(~strcmp(predictions,target));
    elseif strcmp(selected_result,'Correct classification')
        idx=find(strcmp(predictions,target));
    end
else
    if strcmp(selected_result,'All')
        idx=find(strcmp(target,target) & strcmp(current_class, target));
    elseif strcmp(selected_result,'Wrong classification')
        idx=find(~strcmp(predictions,target) & strcmp(current_class, target));
    elseif strcmp(selected_result,'Correct classification')
        idx=find(strcmp(predictions,target) & strcmp(current_class, target));
    end
end

current_records=records(idx);
set(handles.RecordMenu,'String',current_records)







% --- Executes during object creation, after setting all properties.
function ResultMenu_CreateFcn(hObject, eventdata, handles)
% hObject    handle to ResultMenu (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- If Enable == 'on', executes on mouse press in 5 pixel border.
% --- Otherwise, executes on mouse press in 5 pixel border or over AnnotationMenu.
function AnnotationMenu_ButtonDownFcn(hObject, eventdata, handles)
% hObject    handle to AnnotationMenu (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
