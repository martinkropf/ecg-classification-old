function varargout = ECGviewer(varargin)
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

% Last Modified by GUIDE v2.5 11-Sep-2017 17:20:57

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
    'gui_Singleton',  gui_Singleton, ...
    'gui_OpeningFcn', @ECGviewer_OpeningFcn, ...
    'gui_OutputFcn',  @ECGviewer_OutputFcn, ...
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

% --- Executes during object creation, after setting all properties.
function ECGviewer_CreateFcn(hObject, eventdata, handles)
% hObject    handle to PredictionLabel (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called


% --- Executes just before ECGViewer is made visible.
function ECGviewer_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to wfdbRecordViewer (see VARARGIN)
% --- Executes just before wfdbRecordViewer is made visible.

global current_record current_record_number current_records records tm tm_step target current_class current_result predictions res_dataset t avbeat_figure_1 avbeat_figure_2 avbeat_figure_3
current_class='All';
current_result='All';
hGUIecg=gcf;
% store the handle to the root named hGUIecg
setappdata(0,'hGUIecg',hGUIecg);
[data_dir,signal_dir]=getLocalProperties();
reffile = [signal_dir, 'REFERENCE.csv'];
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
    

% Choose default command line output for wfdbRecordViewer
handles.output = hObject;
set(hGUIecg,'Units','pixels');
guiPos=get(0, 'MonitorPositions');
%set(hGUIecg,'Units','pixels','Position', [0 0 guiPos(1,3) guiPos(1,4)])
PHIS=getappdata(0,'PHIS');
SD_ProcessSets=dataset('XLSFile',PHIS.sourceTable,'Sheet','ProcessSets');
SD_ParameterSets=dataset('XLSFile',PHIS.sourceTable,'Sheet','ParameterSets');
SD_ParameterSets_VN=SD_ParameterSets.Properties.VarNames';
I_startsWithV=cellfun(@(x) x(1)=='V', SD_ParameterSets_VN);
SD_ParameterSets_Versions=SD_ParameterSets_VN(I_startsWithV);
set(hGUIecg,'Pointer','arrow');

% extend and update application data
data = getappdata(hGUIecg,'data');
data.SD_ProcessSets=SD_ProcessSets;
data.SD_ParameterSets=SD_ParameterSets;
data.PHIS=PHIS;
data.Predictions=predictions;
data.Target=target;
setappdata(hGUIecg,'data',data);

% Initialisations
set(handles.ProcessingResultsLB,'String',unique(SD_ProcessSets.processFunction(2:end)));
set(handles.ProcessingResultsLB,'Value',numel(unique(SD_ProcessSets.processFunction(2:end))));
set(handles.ParameterDefinitionLB,'String',SD_ParameterSets_Versions);
set(handles.ParameterDefinitionLB,'Value',numel(SD_ParameterSets_Versions));

set(handles.ClassMenu,'String',{'All','N','A','O','~'});
set(handles.ResultMenu,'String',{'All','Wrong classification','Correct classification'});


% set(handles.RecordMenu,'String',{'select a file ...'});
% set(handles.RecordMenu,'Value',1);

% current_class='All';
% current_result='All';
% current_record_number=1;

% Update handles structure
handles.ECGviewer=hGUIecg;
guidata(hObject, handles);

% --------------------------------------------------------------------
function DataToWorkspaceMenu_Callback(hObject, eventdata, handles)
% hObject    handle to DataToWorkspaceMenu (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
hGUIecg = getappdata(0,'hGUIecg');
data = getappdata(hGUIecg,'data');
assignin('base','data',data);
assignin('base','handles',handles);
% assignin('base','F',handles.F);
% disp('Featureset ("F") was saved in workspace successfully')


% --------------------------------------------------------------------
function LoadECG_Callback(hObject, eventdata, handles, varargin)
% hObject    handle to LoadECG (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% GSc 2017-05-20 define list of signals based on input parameter in nargin
global current_record current_record_number current_records records tm tm_step target current_class current_result predictions res_dataset t avbeat_figure_1 avbeat_figure_2 avbeat_figure_3
[data_dir,signal_dir]=getLocalProperties();
handles = guidata(hObject);
if isempty(varargin)
    [filename,directoryname] = uigetfile([signal_dir,'*.hea'],'Select signal header file:');
    loadRecord(strcat(directoryname,filename(1:end-4)));
    %     tmp=dir([signal_dir,'*.hea']);
    
%     N=length(tmp);
%     records=cell(N,1);
%     current_record=1;
%     for n=1:N
%         fname=tmp(n).name;
%         records(n)={fname(1:end-4)};
%         if(strcmp(fname,filename))
%             current_record=n;
%         end
%     end
    
else
    records=varargin{1};
    current_record=1; % jut take first record as the one to display
end

% %reffile = [directoryname, 'REFERENCE.csv'];
% reffile = [signal_dir, 'REFERENCE.csv'];
% fid = fopen(reffile, 'r');
% if(fid ~= -1)
%     Ref = textscan(fid,'%s %s','Delimiter',',');
% else
%     error(['Could not open ' reffile ' for scoring. Exiting...'])
% end
% fclose(fid);
% ansfile = [data_dir,filesep, 'answers.txt'];
% fid = fopen(ansfile,'r');
% if(fid ~= -1)
%     ANSWERS = textscan(fid, '%s %s','Delimiter',',');
% else
%     error('Could not open users answer.txt for scoring. Run the generateValidationSet.m script and try again.')
% end
%
% % Header entfernen
% %RECORDS = Ref{1};
% predictions=ANSWERS{:,2};
% target = Ref{2};


% current_target=target;
% current_prediction=prediction;

set(handles.RecordMenu,'String',filename);
set(handles.RecordMenu,'Value',0);
%loadRecord(records{current_record});

%loadAnnotationList(records{current_record},handles);
set(handles.slider1,'Max',tm(end))
set(handles.slider1,'Min',tm(1))
set(handles.slider1,'SliderStep',[1 1]);
sliderStep=get(handles.slider1,'SliderStep');
tm_step=(tm(end)-tm(1)).*sliderStep(1);

%
% t=table;
% object_handles = findall(hObject);
% for idx = 1:length(object_handles)
%     object_handle=object_handles(idx);
%     if (strcmp(class(object_handle),'matlab.ui.control.Table'))
%         t=object_handle;
%     end
% end
%
%
% txtbox = uicontrol(hObject,'Style','text',...
%                 'String','Enter your name here.',...
%                 'Position',[1350 700 130 20]);
% txtbox = uicontrol(hObject,'Style','text',...
%                 'String','Enter your name here.',...
%                 'Position',[1350 685 130 20]);
% res_dataset=load('ait_result_dataset.mat');
% avbeat_figure_1 = findobj(hObject,'tag','avbeat1');
% avbeat_figure_2 = findobj(hObject,'tag','avbeat2');
% avbeat_figure_3 = findobj(hObject,'tag','avbeat3');
% avbeat_figure_3 = findobj(hObject,'tag','avbeat3');

%wfdbplot(handles)
RefreshECG(hObject, eventdata, handles)

function varargout = ECGviewer_OutputFcn(~,~, handles)
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% Get default command line output from handles structure
varargout{1} = handles.output;

function PreviousButton_Callback(hObject, eventdata, handles)
handles.RecordMenu.Value=max(1,handles.RecordMenu.Value - 1);
%dirty hack, only works for CinC2017 training set
RefreshECG(hObject, eventdata, handles)

function NextButton_Callback(hObject, eventdata, handles)
handles.RecordMenu.Value=min(numel(handles.RecordMenu.String),handles.RecordMenu.Value + 1);
%dirty hack, only works for CinC2017 training set
RefreshECG(hObject, eventdata, handles)


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
printdlg(handles.ECGviewer)

% --------------------------------------------------------------------
function CloseMenuItem_Callback(hObject, eventdata, handles)
selection = questdlg(['Close ' get(handles.ECGviewer,'Name') '?'],...
    ['Close ' get(handles.ECGviewer,'Name') '...'],...
    'Yes','No','Yes');
if strcmp(selection,'No')
    return;
end

delete(handles.ECGviewer)


% --- Executes on selection change in RecordMenu.
function RecordMenu_Callback(hObject, eventdata, handles)

global current_record current_records current_record_number records current_prediction target predictions current_result current_class
current_record=get(handles.RecordMenu,'Value');

%contents = cellstr(get(hObject,'String'));
current_records = cellstr(get(hObject,'String'));
str= current_records{get(hObject,'Value')};
%dirty hack, only works for CinC2017 training set
idx=str2num(strrep(str,'A',''));
current_record_number=idx;


RefreshECG(hObject, eventdata, handles)


% --- Executes during object creation, after setting all properties.
function RecordMenu_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on slider movement.
function slider1_Callback(hObject, eventdata, handles)
%Get time info
hGUIecg=getappdata(0,'hGUIecg');
data = getappdata(hGUIecg,'data');
center=get(handles.slider1,'Value');
maxSlide=get(handles.slider1,'Max');
minSlide=get(handles.slider1,'Min');

tm=data.ECG.tm;
tm_step=range(get(handles.slider1,'SliderStep'))*tm(end)-tm(1) ;

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
[~,data.ECG.ind_start]=min(abs(tm-tm_start));
[~,data.ECG.ind_end]=min(abs(tm-tm_end));
setappdata(hGUIecg,'data',data);

wfdbplot(handles)
plotProcessingResults(handles);


% --- Executes during object creation, after setting all properties.
function slider1_CreateFcn(hObject, eventdata, handles)
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end



function loadRecord(fname)
% global tm signal info tm_step signalDescription analysisSignal analysisTime
%h = waitbar(0,'Loading Data. Please wait...');
hGUIecg=getappdata(0,'hGUIecg');
handles=guidata(hGUIecg);
data = getappdata(hGUIecg,'data');

%D=getappdata(hGUIecg);
try
    [tm,signal,fs]=rdmat(fname);
    
    %     info(1).Description='ECG';
    %     info(1).Gain='1000 adu/mV';
    %     info(1).SamplingFrequency=300;
    data.ECG.SamplingFrequency=fs;
    data.ECG.tm=tm;
    data.ECG.signal=signal;
    data.ECG.ind_start=1;
    data.ECG.ind_end=length(signal);
    %info=load
catch
    [tm,signal]=rdsamp(fname);
end

% GSc 2017-05-20 - adjust slider to newly loaded signal length
handles.slider1.Min=tm(1);
handles.slider1.Max=tm(end);
handles.slider1.SliderStep=[0.01 0.1];
data.ECG.tm_start=tm(1);
data.ECG.tm_end=tm(end);

% R=length(info);
% analysisSignal=[];
% analysisTime=[];
% signalDescription=cell(R,1);
% for r=1:R
%     signalDescription(r)={info(r).Description};
% end
%setappdata(hGUIecg,'D',D);
setappdata(hGUIecg,'data',data);


%close(h)

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

function loadAnnotationList(fname,handles)
global ann1 ann2 annDiff
ann1=[];
ann2=[];
annDiff=[];
tmp=dir([fname '*']);
annotations={'none'};
exclude={'dat','hea','edf','mat'};
for i=1:length(tmp)
    name=tmp(i).name;
    st=strfind(name,'.');
    if(~isempty(st))
        tmp_ann=name(st+1:end);
        enter=1;
        for k=1:length(exclude)
            if(strcmp(tmp_ann,exclude{k}))
                enter=0;
            end
        end
        if(enter)
            annotations(end+1)={tmp_ann};
        end
    end
end

%set(handles.Ann1Menu,'String',annotations)
%set(handles.Ann2Menu,'String',annotations)


function wfdbplot(handles)
global analysisSignal analysisTime analysisUnits analysisYAxis
hGUIecg=getappdata(0,'hGUIecg');
handles=guidata(hGUIecg);
data = getappdata(hGUIecg,'data');
figure(hGUIecg)
cla(handles.axes1);
cla(handles.axes13);
%cla(handles.AnalysisAxes);

%Normalize each signal and plot them with an offset
[N,CH]=size(data.ECG.signal);
offset=0.5;

tm=data.ECG.tm;
ind_start=data.ECG.ind_start;
ind_end=data.ECG.ind_end;

DC=min(data.ECG.signal(ind_start:ind_end,:),[],1);
sig=data.ECG.signal - repmat(DC,[N 1]);
SCALE=max(sig(ind_start:ind_end,:),[],1);
SCALE(SCALE==0)=1;
sig=offset.*sig./repmat(SCALE,[N 1]);
OFFSET=offset.*[1:CH];
sig=sig + repmat(OFFSET,[N 1]);

axes(handles.axes1);
for ch=1:CH;
    plot(handles.axes1,tm(ind_start:ind_end),sig(ind_start:ind_end,ch))
    hold on ; grid on
end
% set(handles.axes1,'YTick',[]);
% set(handles.axes1,'YTickLabel',[]);
set(handles.axes1,'FontSize',10);
% set(handles.axes1,'FontWeight','bold');
set(handles.axes1.XLabel,'String','Time (seconds)');
set(handles.axes1,'xlim',[tm(ind_start) tm(ind_end)]);

%Plot custom signal in the analysis window
if(~isempty(analysisSignal))
    axes(handles.AnalysisAxes);
    if(isempty(analysisYAxis))
        %Standard 2D Plot
        plot(handles.AnalysisAxes,analysisTime,analysisSignal,'k')
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
    set(handles.AnalysisAxes,'xlim',[tm(ind_start) tm(ind_end)]);
    if(~isempty(analysisUnits))
        set(handles.AnalysisAxes.YLabel,'String',analysisUnits);
        ylabel(analysisUnits)
    end
    plotProcessingResults(handles)
end


% --- Executes on selection change in TimeScaleSelection.
function TimeScaleSelection_Callback(hObject, eventdata, handles)
% global tm_step tm
hGUIecg=getappdata(0,'hGUIecg');
data = getappdata(hGUIecg,'data');

tm_start=data.ECG.tm(1);
tm_end=data.ECG.tm(end);
tm_length = tm_end-tm_start;

TM_SC=[tm_end-tm_start 120 60 30 15 10 5 1];
index = get(handles.TimeScaleSelection, 'Value');
%Normalize step to time range
if(TM_SC(index)>TM_SC(1))
    index=1;
end
data.ECG.ind_start=1;
data.ECG.ind_end=TM_SC(index)*data.ECG.SamplingFrequency;


stp=TM_SC(index)/TM_SC(1);
tm_fract=TM_SC(index);
numSteps = tm_length/tm_fract;
set(handles.slider1, 'Min', 0);
set(handles.slider1, 'Max', tm_length);
set(handles.slider1, 'Value', 0);
set(handles.slider1, 'SliderStep', [0.1/(numSteps) , 1/(numSteps) ]);

setappdata(hGUIecg,'data',data);
wfdbplot(handles);
plotProcessingResults(handles);

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


function AnnotationMenu_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function RefreshECG(hObject, eventdata, handles)
% central Update function to be called when a new ECG has been
% selected/loaded/...
% Calls a number of routines to update dependent objects
hGUIecg = getappdata(0,'hGUIecg');
figure(hGUIecg);
handles=guidata(hGUIecg);
data = getappdata(hGUIecg,'data');
curECGName=handles.RecordMenu.String{handles.RecordMenu.Value};
current_record_number=getCurRecordNumber(curECGName);
curECGfileName= getRecordFileName(curECGName);
if exist([curECGfileName,'.mat'],'file')
    loadRecord(curECGfileName);
else
    warning(' ECG file "%s" not found - so quitting!',curECGfileName);
    return
end
UpdateFeatureTable(hObject, eventdata, handles)
wfdbplot(handles);
ProcessingResultsLB_Callback(hObject, eventdata, handles, curECGName)
set(handles.TargetLabel,'String',data.Target(current_record_number));
set(handles.PredictionLabel,'String',data.Predictions(current_record_number));


function UpdateFeatureTable(hObject, eventdata, handles)
% updates the table in the GUI which displays information on the featuers for the
% current observation and also puts FT to the workspace which can be
% elegantly viewed using the variable browser
hGUIecg = getappdata(0,'hGUIecg');
data = getappdata(hGUIecg,'data');
curECGName=handles.RecordMenu.String{handles.RecordMenu.Value};
curECGNumber=getCurRecordNumber(curECGName);
curECGfileName= getRecordFileName(curECGName);
if exist([curECGfileName,'.mat'],'file')
    loadRecord(curECGfileName);
else
    warning(' ECG file "%s" not found - so quitting!',curECGfileName);
    return
end
correct_idx = UpdateTruthPredictLabels(hObject, eventdata, handles);

% Update feature Table and paste it to WS to be viewed with the Variable browser
if isfield(data,'F')
    IcurRecNum=data.F.(1)==curECGNumber;
    curVarNames=data.F.Properties.VarNames;
    curFeatures=data.F(IcurRecNum,:);
    feature_col=dataset2cell(curFeatures);
    FT=cell2table(feature_col');
    FT.Properties.VariableNames(1)={'Feature'};
    FT.Properties.VariableNames(2)={'Value'};
    
    if ~isempty(correct_idx) % add a column with the average for the true class
        correct_data=data.F(correct_idx,:);
        correct_mean=nanmean(double(correct_data));
    else
        correct_mean = nan(size(feature_col));
    end
    feature_mean_col=num2cell(correct_mean);
    FT.MeanTrue=correct_mean';
    
    if ~isempty(handles.observedParameter.String) % also update the observed parameter
        %        J_observedParameter=strcmp(data.F.Properties.VarNames,handles.observedParameter.String);
        J_observedParameter=strcmp(data.F.Properties.VarNames,handles.observedParameter.String);
        handles.observedValue.String = num2str(feature_col{2,J_observedParameter});
    else
        handles.observedValue.String = [];
    end
    order=[];
    if isfield(data,'M') % model present and record uniquely identified
        curL=data.M.model.L;
        if sum(strcmp(curL.Properties.VariableNames,'Mod')) % model object is also present in the table (often not stored during modelling due to high storage volumen needs)
            IcurM=data.M.V.XS(data.M.V.(1)==curECGNumber);
            curModellingVarNames=data.M.model.L.VarNames{IcurM};
            JcurVarNames=ismember(curVarNames,curModellingVarNames);
            %             [~,featureRelevancePercent,featureRelevanceRel]=...
            %                 phis_explainDecision(data.M.model.L.Mod{IcurM,1},double(data.F(IcurRecNum,JcurVarNames)),...
            %                 curModellingVarNames,data.M.model.L.featureImportance{IcurM},0);
            [~,featureRelevancePercent,featureRelevanceRel]=...
                phis_explainDecision(data.M.model.L.Mod{IcurM,1},double(data.F(IcurRecNum,JcurVarNames)),...
                [],data.M.model.L.featureImportance{IcurM},0);
            [~,order]=sort(abs(featureRelevancePercent),'descend');
            curVarNamesOrdered=curModellingVarNames(order);
            disp('the 10 most important features were:');
            disp(curVarNamesOrdered(1:10)');
            
            [Lia,Locb]=ismember(curVarNames,curModellingVarNames);
            FT.Relevance(:,1)=nan;
            FT.RelevanceRel(:,1)=nan;
            FT.Relevance(Lia,1)=featureRelevancePercent;
            FT.RelevanceRel(Lia,1)=featureRelevanceRel;
        end
    end
    if isempty(order)
        handles.FeatureTable.Data=[feature_col;feature_mean_col]';
    else % sort the features according to their relevance
        [Lia_1,Locb_1]=ismember(curVarNames,curVarNamesOrdered);
        [Lia_2,Locb_2]=ismember(curVarNamesOrdered,curVarNames);
        IcurVarNamesOrdered=1:numel(curVarNames);
        IcurVarNamesOrdered(Lia_1)=Locb_2;
        handles.FeatureTable.Data=[feature_col(:,IcurVarNamesOrdered);feature_mean_col(IcurVarNamesOrdered)]';
    end
    
    assignin('base','FT',FT);
    
else
    feature_col=[];
    feature_mean_col=[];
    handles.observedValue.String = [];
end

function plotProcessingResults(handles)
% Plot results from signal analysis
% RR series in dedicated axis
% takes data from (priviously loaded) data.R
data = getappdata(handles.ECGviewer,'data');
avbeat_color=get(gca,'ColorOrder');
avbeat_color=[0 0 0;1 0 0;0 1 0; 0 0 1];
processedText=' --------  --:--:--';
cla(handles.avbeat1);
cla(handles.avbeat2);
cla(handles.avbeat3);
cla(handles.avbeat4);
cla(handles.axes13);
%cla(handles.AnalysisAxes);

if isfield(data,'R') && ~isempty(data.R)
    if ~isempty(data.R.dataPerBeat.QRS)
        
        dataPerBeat=data.R.dataPerBeat; % restore to current context
        dataPerBeat(dataPerBeat.corrClass95==0,:)=[]; % get rid of anormal SC 0
        beatClasses=dataPerBeat.corrClass95;
        
        ann1RR=data.R.dataPerBeat.BCI/data.ECG.SamplingFrequency;
        tBeat=data.R.dataPerBeat.QRS/data.ECG.SamplingFrequency;
        corrClassPerBeat=data.R.dataPerBeat.corrClass95;
        rhythmClassPerBeat=data.R.dataPerBeat.rhythmClass;
        axes(handles.axes13);
        ind=data.R.dataPerBeat.BeatID(data.R.dataPerBeat.corrClass95>0);
        codeMax=size(avbeat_color,1);
        BeatColorCodes=min(data.R.dataPerBeat.corrClass95,codeMax);
        BeatColorCodes(BeatColorCodes==0)=codeMax;
        h = scatter(handles.axes13,tBeat,ann1RR,18,avbeat_color(BeatColorCodes,:),'filled');
        ht = text(handles.axes13,tBeat,zeros(size(tBeat)),int2str(corrClassPerBeat),...
            'VerticalAlignment','bottom','HorizontalAlignment','center');
        ht2 = text(handles.axes13,tBeat,ones(size(tBeat))*2,char(rhythmClassPerBeat),...
            'VerticalAlignment','top','HorizontalAlignment','center');
        if isfield(data.R,'detectionTypeList') & sum(strcmp(data.R.detectionTypeList.Properties.VariableNames,'beat'))
            L=data.R.detectionTypeList;
            I_inList=~isnan(L.beat) & L.beat<=length(tBeat);
            if sum(I_inList)
            ht3 = text(handles.axes13,tBeat(L.beat(I_inList)),ones(size(L.beat(I_inList)))*1.4,L.type(I_inList),...
            'VerticalAlignment','bottom','HorizontalAlignment','center','Color','r','FontAngle','Italic');
            else
                ht3 = text(handles.axes13,tBeat(1),1.5,'no detection cut-off within beats list','Color','r','FontAngle','Italic');            
            end
        else
           % ht3 = text(handles.axes13,tBeat(1),1.5,'no detection info available','Color','r','FontAngle','Italic');            
        end
        grid on
        set(handles.axes13.YLabel,'String','BCI (seconds)');
        %         if(~isnan(ind_start) && ~isnan(ind_end) && ~(ind_start==ind_end))
        %             handles.axes13.XLim=[tm(ind_start) tm(ind_end)];
        %         end
        handles.axes13.YLim=[0 2]; % set y range to constant values so as to easily detect rhythm aspects
        handles.axes13.XLim=[data.ECG.tm(data.ECG.ind_start) data.ECG.tm(data.ECG.ind_end)];
    end
    if isfield(data.R,'processedTimeStamp')
        processedText=datestr(data.R.processedTimeStamp,' yyyy-mm-dd  HH:MM:SS');
    end
    
    if ~isempty(data.R.avbeats) & ~all(isnan(beatClasses))
        cur_avbeats=data.R.avbeats(1); % could have one entry for each bin (sequence)
        
        beatCorrClassTable=tabulate(beatClasses);
        [beatCorrClassTable_sorted,beatCorrClassTable_sorted_order]=...
            sort(beatCorrClassTable(:,2),'descend');
        for i=1:min(numel(beatCorrClassTable_sorted),4)
            cur_h=handles.(['avbeat',int2str(i)]);
            subClass_i=beatCorrClassTable(beatCorrClassTable_sorted_order(i),1);
            numOfClass=sum(beatClasses==subClass_i);
            ab_index=find(cur_avbeats.SC==subClass_i);
            %        if length(avbeats.seq)>=i
            if numel(ab_index)==1 & ~isempty(cur_avbeats.window{ab_index}) % uniquely identified
                timeLine=(cur_avbeats.window{1,ab_index}(1):cur_avbeats.window{1,ab_index}(2))/data.ECG.SamplingFrequency*1000;
                ecgSequence=cur_avbeats.seq{1,ab_index};
                plot(cur_h,timeLine,ecgSequence,'Color',avbeat_color(i,:));
                ht = text(cur_h,cur_h.XLim(1),cur_h.YLim(2),[' Beats: ',int2str(numOfClass),...
                    ' (',int2str(numOfClass/numel(beatClasses)*100),'%)'],'VerticalAlignment','top');
                ht = text(cur_h,cur_h.XLim(1),cur_h.YLim(1),[' Class#: ',int2str(subClass_i)],'VerticalAlignment','bottom');
                cur_h.XGrid='on';
                cur_h.YGrid='on';
                if i==1 % display waveformmarkers for majority class avbeat
                    if ~isnan(cur_avbeats.P_on(1))
                    line(cur_h,timeLine(cur_avbeats.P_on(1)),ecgSequence(cur_avbeats.P_on(1)),...
                        'Marker','o','MarkerSize',4,'MarkerEdgeColor','r','LineStyle','none');
                    end
                    if ~isnan(cur_avbeats.P_off(1))
                    line(cur_h,timeLine(cur_avbeats.P_off(1)),ecgSequence(cur_avbeats.P_off(1)),...
                        'Marker','*','MarkerSize',4,'MarkerEdgeColor','r','LineStyle','none');
                    end
                    if ~isnan(cur_avbeats.QRS_on(1))
                    line(cur_h,timeLine(cur_avbeats.QRS_on(1)),ecgSequence(cur_avbeats.QRS_on(1)),...
                        'Marker','o','MarkerSize',4,'MarkerEdgeColor','b','LineStyle','none');
                    end
                    if ~isnan(cur_avbeats.QRS_off(1))
                    line(cur_h,timeLine(cur_avbeats.QRS_off(1)),ecgSequence(cur_avbeats.QRS_off(1)),...
                        'Marker','*','MarkerSize',4,'MarkerEdgeColor','b','LineStyle','none');
                    end
                end
            else
                if i==1
                    ht = text(cur_h,mean(cur_h.XLim),mean(cur_h.YLim),'Averaged Beat not available',...
                        'HorizontalAlignment','center','VerticalAlignment','middle', 'color','r','FontWeight','bold');
                end
            end
        end
    else
        warning(' averaged beat not available ... ignored!');
        avbeats.seq=[]; % should lead to skip the plotting
    end
else
    warning(' no processing result data available, so quitting!')
end
handles.processedText.String=processedText;


function correct_idx = UpdateTruthPredictLabels(hObject, eventdata, handles)
hGUIecg = getappdata(0,'hGUIecg');
figure(hGUIecg);
handles=guidata(hGUIecg);
data = getappdata(hGUIecg,'data');
curECGName=handles.RecordMenu.String{handles.RecordMenu.Value};
current_record_number=getCurRecordNumber(curECGName);
correct_idx=[];
curTargetName=' --- ';
truthString=' --- ';
predictionString=' --- ';
resultString=' --- ';
resultColor='k';
if isfield(data,'F') % true class labels
    IcurRecNum=data.F.(1)==current_record_number;
    if sum(IcurRecNum)==1 & isfield(data,'M') % model present and record uniquely identified
        curTargetName=data.M.model.target;
        curTargetFeatureClassesName=data.M.model.targetFeatureClasses;
        if ~isempty(curTargetName)
            truthName = curTargetName;
            truthValue = data.F.(curTargetName)(IcurRecNum);
            correct_idx = data.F.(curTargetName)==truthValue;
            truthString = [num2str(truthValue),' (',data.F.Properties.UserData.(curTargetName){truthValue},')'];
        else
            truthString='class feature not defined';
            correct_idx = [];
        end
    else
        truthString='no model data';
        correct_idx = [];
    end
else
    truthString='no FS data';
    correct_idx = [];
end
if isfield(data,'M') & isfield(data.M,'V') % predicted class labels
    IcurRecNum=data.M.V.(1)==current_record_number;
    if sum(IcurRecNum)==1
        curEvalString = handles.EvalResultsTypePopup.String{handles.EvalResultsTypePopup.Value};
        curEvalName = ['Y_',curEvalString];
        cur_opt_thresh=nan;
        if sum(strcmp(data.M.V.Properties.VarNames,curEvalName))==1
            predictionValue = data.M.V.(curEvalName)(IcurRecNum);
            predictionString=num2str(predictionValue);
            if isreal(predictionValue) && rem(predictionValue,1)==0
                curCodeList=data.F.Properties.UserData.(curTargetName);
                predictionString=[predictionString,' (',curCodeList{predictionValue},')'];
            else
                if isfield(data.M,'E') % prediction evaluation results are available
                    curEvalGroupString = handles.EvaluationGroupPopup.String{handles.EvaluationGroupPopup.Value};
                    curEvalGroupNumber=str2num(curEvalGroupString);
                    curEvalRow=find(data.M.E.(curEvalString).group==curEvalGroupNumber);
                    cur_opt_thresh=data.M.E.(curEvalString).opt_thresh(curEvalRow);
                    predictionString=[predictionString,' (',num2str(cur_opt_thresh),')'];
                end
                curCodeList=[]; % e.g. in case of classification
            end
            
            if predictionValue == truthValue |...
                    (truthValue == 2 & predictionValue >= cur_opt_thresh) | ...
                    (truthValue == 1 & predictionValue < cur_opt_thresh)
                resultString = 'T';
                resultColor = [0.8 1.0 0.8 ];
            else
                resultString = 'F';
                resultColor = [1.0 0.8 0.8 ];
            end
            if numel(curCodeList)==2 | isfinite(cur_opt_thresh) % binary classification
                if predictionValue == 2 | predictionValue >= cur_opt_thresh
                    classString = 'P';
                else
                    classString = 'N';
                end
            else
                classString = '';
            end
            resultString=[resultString,classString];
        else
            predictionString='not found';
        end
    else
        predictionString='not found';
    end
else
    truthString='no data';
    predictionString='no data';
    correct_idx=[];
end
handles.TargetLabel.String=curTargetName;
handles.TruthLabel.String=truthString;
handles.PredictionLabel.String=predictionString;
handles.ResultLabel.String=resultString;
handles.ResultLabel.BackgroundColor=resultColor;



% --- Executes on selection change in SignalMenu.
function SignalMenu_Callback(hObject, eventdata, handles)
% hObject    handle to SignalMenu (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns SignalMenu contents as cell array
%        contents{get(hObject,'Value')} returns selected item from SignalMenu

global tm signal info analysisSignal analysisTime analysisUnits analysisYAxis
hGUIecg = getappdata(0,'hGUIecg');
data = getappdata(hGUIecg,'data');
contents = cellstr(get(hObject,'String'));
ind=get(handles.ClassMenu,'Value');
str= contents{get(hObject,'Value')};

analysisTime=data.ECG.tm;
analysisSignal=data.ECG.signal(:,1);
% analysisUnits=strsplit(info(1).Gain,'/');
% if(length(analysisUnits)>1)
%     analysisUnits=analysisUnits{2};
% else
%     analysisUnits=[];
% end
fs=data.ECG.SamplingFrequency;
% analysisYAxis=[];

switch str
    
    case 'Plot Raw Signal'
        wfdbplot(handles);
        
    case 'Apply General Filter'
        [analysisSignal]=wfdbFilter(analysisSignal);
        wfdbplot(handles);
        
    case '60/50 Hz Notch Filter'
        [analysisSignal]=wfdbNotch(analysisSignal,fs);
        wfdbplot(handles);
        
    case 'Resonator Filter'
        [analysisSignal]=wfdbResonator(analysisSignal,fs);
        wfdbplot(handles);
        
    case 'Custom Function'
        %[analysisSignal,analysisTime]=wfdbFunction(analysisSignal,analysisTime,Fs);
        analysisSignal=analysisSignal*-1;
        wfdbplot(handles);
        
    case 'Spectogram Analysis'
        [analysisSignal,analysisTime,analysisYAxis,analysisUnits]=wfdbSpect(analysisSignal,fs);
        wfdbplot(handles);
        
    case 'Wavelets Analysis'
        [analysisSignal,analysisYAxis,analysisUnits]=wfdbWavelets(analysisSignal,fs);
        wfdbplot(handles);
    case 'Test'
        [analysisSignal]=wfdbFilter(analysisSignal);
        wfdbplot(handles);
    otherwise % plot RR intervals
        analysisSignal=[];
end
RefreshECG(hObject, eventdata, handles)


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
hGUIecg = getappdata(0,'hGUIecg');
data = getappdata(hGUIecg,'data');
all_records=cellstr(num2str(data.F.RecID, 'A%05d'));
records=all_records(idx);
set(handles.RecordMenu,'String',records)


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

hGUIecg = getappdata(0,'hGUIecg');
data = getappdata(hGUIecg,'data');
all_records=cellstr(num2str(data.F.RecID, 'A%05d'));
records=all_records(idx);

set(handles.RecordMenu,'String',records)

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



% --- Executes on button press in pushbuttonProcess.
function pushbuttonProcess_Callback(hObject, eventdata, handles)
% hObject    handle to pushbuttonProcess (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
PHIS=getappdata(0,'PHIS');
hGUIecg = getappdata(0,'hGUIecg');
data = getappdata(handles.ECGviewer,'data');
hObject.BackgroundColor=[0.5 0 0];
set(hGUIecg,'Pointer','watch');
recordName = handles.RecordMenu.String{handles.RecordMenu.Value};
recordFileName = getRecordFileName(recordName);
processName = handles.ProcessingResultsLB.String{handles.ProcessingResultsLB.Value};
processVersion=handles.ParameterDefinitionLB.String{handles.ParameterDefinitionLB.Value};
try % try to load parameters from XLSX Sheet named ParameterSets
    p=data.SD_ParameterSets;
    pars2use = parseParameterDS(p,processVersion);
catch
    warning(' Failed to parse process parameters by "%s", using defaults.',processVersion);
    pars2use=eval(processVersion);
end
feval(processName, recordFileName, pars2use); % Attention: uses default parameter settings!!!
hObject.BackgroundColor=[0 0.5 0];
set(hGUIecg,'Pointer','arrow');
%Refresh(hObject, eventdata, handles)
ProcessingResultsLB_Callback(hObject, eventdata, handles)


function recordFileName = getRecordFileName(recordName)
% hObject    handle to pushbuttonProcess (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
PHIS=getappdata(0,'PHIS');
if 0
    hGUIecg = getappdata(0,'hGUIecg');
    handles=guidata(hGUIecg);
    data = getappdata(hGUIecg,'data');
    if isfield(data,'F') & isfield(data.F.Properties.Description,'sourceFilePath')
        sourceFilePath=data.F.Properties.Description.sourceFilePath;
        if numel(sourceFilePath)==1 % unique path
            signal_dir=fullfile(PHIS.dataPath,sourceFilePath);
        else
            [data_dir,signal_dir]=getLocalProperties(); % dirty, hardcoded method
            warning(' dirty, hardcoded method used to determin source signal path')
        end
    else
        [data_dir,signal_dir]=getLocalProperties(); % dirty, hardcoded method
        warning(' dirty, hardcoded method used to determin source signal path')
    end
    recordFileName = fullfile(char(signal_dir),recordName);
else
    recordFileName = fullfile(PHIS.rawDataPath,recordName);
end


function Menu_LoadFeatureset_Callback(hObject, eventdata, handles, varargin)
% hObject    handle to Menu_LoadFeatureset (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

hGUIecg = getappdata(0,'hGUIecg');
data = getappdata(hGUIecg,'data');
if nargin > 3
    Pathname=data.PHIS.dataPath;
    Filename=varargin{1};
else
    [Filename,Pathname] = uigetfile('*.mat','Select a featureset','multiselect','off');
end
if iscell(Filename)
    fileName=fullfile(Pathname,Filename{:});
else
    fileName=fullfile(Pathname,Filename);
end
disp(['ECGviewer: loading data from "',fileName,'" ...']);
set(gcf,'Pointer','watch');
S = load(fileName);
set(gcf,'Pointer','arrow');
I_fieldname=isfield(S,{'F','F_cum'});
if any(I_fieldname) % test for valididy - could be more extensive, eventually
    fn=fieldnames(S);
    F = S.(fn{1});
    % Add F to data and to appdata
    data = getappdata(hGUIecg,'data');
    data.F = F;
    setappdata(hGUIecg,'data',data);
    set(handles.LoadFeatureSetEdit,'string',Filename); % Populate textfield "LoadFEdit" with the name of the loaded featureset
    
    % get the list of patient IDs and populate the PatLB with corresponding strings
    opsIdKey = F.Properties.Description.keys{1};
    ObsIDs = unique(F.(opsIdKey));
    set(handles.RecordMenu,'string',F.Properties.UserData.(opsIdKey)(ObsIDs));
    %    Menu_LoadModellingResults_Callback(hObject, eventdata, handles);         % next, look for modelling results and load them, if possible
    LoadModelResultsLB_Callback(hObject, eventdata, handles);         % next, look for modelling results and load them, if possible
else
    warning('ECGviewer: file "%s" does not contain a featureset object ... ignored!',fileName);
%     if hasfield(S, 'res_dataset')
%         S=S.res_dataset;
%         fn=fieldnames(S);
%         F = S;
%     end
    if isstruct(S)
        S=S.res_dataset;
        fn=fieldnames(S);
        F = S;
    end
    % Add F to data and to appdata
    data = getappdata(hGUIecg,'data');
    data.F = F;
    setappdata(hGUIecg,'data',data);
    set(handles.LoadFeatureSetEdit,'string',Filename); % Populate textfield "LoadFEdit" with the name of the loaded featureset
%         set(handles.RecordMenu,'string',F.Properties.UserData.(opsIdKey)(ObsIDs));
%             LoadModelResultsLB_Callback(hObject, eventdata, handles);         % next, look for modelling results and load them, if possible
%  opsIdKey = F.Properties.Description.keys{1};
%     ObsIDs = unique(F.(opsIdKey));
    set(handles.RecordMenu,'string',cellstr(num2str(F.RecID, 'A%05d')));
    
    

end


% --------------------------------------------------------------------
function Menu_LoadModellingResults_Callback(hObject, eventdata, handles)
% hObject    handle to Menu_LoadModellingResults (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

hGUIecg = getappdata(0,'hGUIecg');
data = getappdata(hGUIecg,'data');
PHIS=getappdata(0,'PHIS');
% Load rawdataset(s)
if isfield(data,'F') % try to load raw data sets automatically
    Pathname=fullfile(PHIS.dataPath,data.F.Properties.Description.name,'models');
    modelFiles = dir(fullfile(Pathname,'*.mat'));
    I = cellfun(@isempty,regexp({modelFiles.name}','s\d,*|b\d*,|_E\.')); % rule these out
    Filenames={modelFiles(I).name}';
    if isempty(Filenames)
        [Filenames,Pathname] = uigetfile('*.mat','Select modelling results','multiselect','on');
        
    end
end
if ~isempty(Filenames)
    % get Filenames without extension
    disp('ECGviewer: loading modelling results ...');
    set(gcf,'Pointer','watch');
    [~,Fnames] = cellfun(@fileparts,Filenames,'UniformOutput',false);
    data.M.name=Fnames;
    set(handles.LoadModelResultsLB,'string',Fnames,'value',1); % select the first one
else
    warning('ECGviewer: missing data, so quitting!');
end
LoadModelResultsLB_Callback(hObject, eventdata, handles);


function LoadFeatureSetEdit_Callback(hObject, eventdata, handles)
% hObject    handle to LoadFeatureSetEdit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of LoadFeatureSetEdit as text
%        str2double(get(hObject,'String')) returns contents of LoadFeatureSetEdit as a double


% --- Executes during object creation, after setting all properties.
function LoadFeatureSetEdit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to LoadFeatureSetEdit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in AnnotationMenu.
function popupmenu13_Callback(hObject, eventdata, handles)
% hObject    handle to AnnotationMenu (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns AnnotationMenu contents as cell array
%        contents{get(hObject,'Value')} returns selected item from AnnotationMenu


% --- Executes during object creation, after setting all properties.
function popupmenu13_CreateFcn(hObject, eventdata, handles)
% hObject    handle to AnnotationMenu (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function LoadModelResultsLB_Callback(hObject, eventdata, handles, model2load)
% hObject    handle to LoadModelResultsLB (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
if nargin == 4
    modelFile = updateStringAndValueOfControl(handles.LoadModelResultsLB, eventdata, handles, model2load, 'last');
else
    str=get(handles.LoadModelResultsLB,'String');
    modelFile = str{get(handles.LoadModelResultsLB,'Value'),:};
end
% Get data from appdata
hGUIecg = getappdata(0,'hGUIecg');
data = getappdata(hGUIecg,'data');
PHIS=getappdata(0,'PHIS');
Pathname=fullfile(PHIS.dataPath,data.F.Properties.Description.name,'models');
[~,modelFileName,~]=fileparts(modelFile);
fname=fullfile(Pathname,modelFileName);
modelFiles = dir([fname,'_*.mat']);
evalFiles={modelFiles.name};
fname=fullfile(Pathname,[modelFileName,'.mat']);
if exist(fname,'file')
    disp([' Loading ',fname,' ...']);
    set(hGUIecg,'Pointer','watch');
    drawnow;
    S = load(fname);
    set(hGUIecg,'Pointer','arrow');
    if isfield(S,'model') % M contains a field "model" (could also just contain a TreeBagger object "M"
        model = S.model;
    else
    end
    [E,V, EvalResultsTypeNames] = loadEvalResults(hObject, eventdata, handles, evalFiles);
    data.M.name=modelFileName;
    data.M.model = model;
    data.M.V = V;
    data.M.E = E;
    setappdata(hGUIecg,'data',data);
    updateStringAndValueOfControl(handles.EvalResultsTypePopup, eventdata, handles, EvalResultsTypeNames, 'last');
    UpdateTruthPredictLabels(hObject, eventdata, handles);
else
    warning('ECGviewer: no file found for model %s ... so quitting!', fname);
end

function [E,V,EvalResultsTypeString] = loadEvalResults(hObject, eventdata, handles, evalFiles, IND)
% load the evaluation objects for a list of evaluation files
E=[];
V=[];
EvalResultsTypeString='';
data = getappdata(handles.ECGviewer,'data');
PHIS=getappdata(0,'PHIS');
Pathname=fullfile(PHIS.dataPath,data.F.Properties.Description.name,'models');
EvalResultsTypeString=[];
for f=1:numel(evalFiles)
    [~,evalFileName,~]=fileparts(evalFiles{f});
    evalFile=fullfile(Pathname,evalFileName);
    disp([' Loading evaluation results for ',evalFile,' ...']);
    S = load(evalFile); % supposed to be a structure with a field named E
    C = strsplit(evalFileName,'_');
    if 0
        evalType=C{end}; % last part supposed to be the type suffix
        nameY=['Y',evalType];
        E.(evalType)=S.E;
        if isfield(S,'V') % structure contains evaluation vector
            IND.(nameY)=S.V.(nameY);
        end
        EvalResultsTypeString{end+1}=evalType;
    else
        evalTypes=unique(S.E.emode);
        evalTypes=evalTypes(~cellfun(@isempty,evalTypes));
        for e=1:numel(evalTypes)
            evalType=evalTypes{e};
            E.(evalType)=S.E(strcmp(S.E.emode,evalType),:);
        end
        EvalResultsTypeString=evalTypes;
        V=S.V;
    end
end

% --- Executes during object creation, after setting all properties.
function LoadModelResultsLB_CreateFcn(hObject, eventdata, handles)
% hObject    handle to LoadModelResultsLB (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in EvalResultsTypePopup.
function EvalResultsTypePopup_Callback(hObject, eventdata, handles, evalResults2load)
% hObject    handle to EvalResultsTypePopup (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
str=get(handles.EvalResultsTypePopup,'String');
if nargin == 4
    updateStringAndValueOfControl(handles.EvalResultsTypePopup, eventdata, handles, evalResults2load, 'last')
end
UpdateTruthPredictLabels(hObject, eventdata, handles);



% --- Executes during object creation, after setting all properties.
function EvalResultsTypePopup_CreateFcn(hObject, eventdata, handles)
% hObject    handle to EvalResultsTypePopup (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function current_record_number = getCurRecordNumber(curRecordName)
% central function to convert a recording name, e.g. "A0043" into a
% recording number, i.e. the RecID, e.g. 43
if nargin
    curRecordString = curRecordName;
else
    curRecordString = handles.RecordMenu.String(handles.RecordMenu.Value);
end
current_record_number=str2double(strrep(curRecordString,'A',''));


% --- Executes when user attempts to close ECGviewer.
function ECGviewer_CloseRequestFcn(hObject, eventdata, handles)
% hObject    handle to ECGviewer (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: delete(hObject) closes the figure
delete(hObject);


% --- Executes on button press in remarks_PB.
function remarks_PB_Callback(hObject, eventdata, handles)
% hObject    handle to remarks_PB (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
PHIS=getappdata(0,'PHIS');
system(['open ',PHIS.remark_table]);

function UpdateExternal(hObject, eventdata, handles)
% GSc 2017-06-04 - general update function based on UserData properties of
% controls - checks whether nonempty values are the once currently set,
% otherwise does a tailored update procedure

hGUIecg = getappdata(0,'hGUIecg');
figure(hGUIecg);
handles=guidata(hGUIecg);
u=structfun(@(x) get(x,'UserData'),handles,'UniformOutput', false);
fieldnames_u=fieldnames(u);
hasNewUserData=find(~structfun(@isempty,u));
fn=fieldnames_u(hasNewUserData);
fn_priority= {'LoadFeatureSetEdit',...
    'LoadModelResultsLB',...
    'EvalResultsTypePopup',...
    'EvaluationGroupPopup',...
    'RecordMenu'};
[Lia,Locb]=ismember(fn,fn_priority);


for i=1:numel(hasNewUserData)
    %    fieldname_i=fieldnames_u{hasNewUserData(i)};
    iLocb=Locb(i);
    if iLocb % if priority is zero, ignore element
%        fieldname_i=fn{Locb(i)};
        fieldname_i=fn_priority{Locb(i)};
        userdata_i=handles.(fieldname_i).UserData;
        switch fieldname_i
            case 'LoadFeatureSetEdit'
                if ~strcmp(handles.(fieldname_i).String,userdata_i) % load new FS
                    Menu_LoadFeatureset_Callback(hGUIecg, 0, handles, userdata_i);
                end
            case 'LoadModelResultsLB' % check, whether model has been loaded already
                curLoadedModel=handles.LoadModelResultsLB.String(handles.LoadModelResultsLB.Value);
                if ~strcmp(curLoadedModel,userdata_i)
                    LoadModelResultsLB_Callback(hGUIecg, 0, handles, userdata_i);
                end
            case 'EvalResultsTypePopup' % check, whether evaluation results have been loaded already
                curEvalResultsType=handles.EvalResultsTypePopup.String(handles.EvalResultsTypePopup.Value);
                if ~strcmp(curEvalResultsType,userdata_i)
                    EvalResultsTypePopup_Callback(hGUIecg, 0, handles, userdata_i);
                end
                %            UpdateTruthPredictLabels(hObject, eventdata, handles)
            case 'EvaluationGroupPopup' % check, whether evaluation results have been loaded already
                curEvaluationGroup=handles.EvalResultsTypePopup.String(handles.EvalResultsTypePopup.Value);
                if ~strcmp(curEvaluationGroup,userdata_i)
                    EvaluationGroupPopup_Callback(hGUIecg, 0, handles, userdata_i);
                end
            case 'RecordMenu' % check, whether Record has bean loaded already
                curLoadedRecord=handles.RecordMenu.String(handles.RecordMenu.Value);
                if ~isequal(handles.RecordMenu.String,userdata_i) % if a different set of records needs to be loaded
                    newStrings = sort(userdata_i);
                    updateStringAndValueOfControl(handles.RecordMenu, 0, handles, newStrings, 'first');
                end
            otherwise
                warning(' no update process defined for UI control "%s" ... ignored!',fieldname_i);
        end
        handles.(fieldname_i).UserData=[]; % reset to []
    else
        warning(' no priority defined for UI control "%s" ... ignored but deleted userData anyway!',fn{i});
        handles.(fn{i}).UserData=[]; % reset to []
    end
end
RefreshECG(hGUIecg, 0, handles);

function ProcessingResultsLB_Callback(hObject, eventdata, handles, recordJustLoaded, processingResults2load)
% hObject    handle to ProcessingResultsLB (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% Hints: get(hObject,'String') returns contents of ProcessingResultsLB as text
%        str2double(get(hObject,'String')) returns contents of ProcessingResultsLB as a double
% Get data from appdata
recordName=handles.RecordMenu.String(handles.RecordMenu.Value);
recordFileName = getRecordFileName(recordName);
[pathName,fileName,fileExt]=fileparts(recordFileName{:});
curStrings=get(handles.ProcessingResultsLB,'String');
if nargin > 4
    newSelection = updateStringAndValueOfControl(handles.ProcessingResultsLB, eventdata, handles, processingResults2load, 'first');
elseif nargin > 3
    resultFiles = dir(fullfile(pathName,[recordJustLoaded,'.*']));
    I = cellfun(@isempty,regexp({resultFiles.name}','.hea|.mat')); % rule these out
    fileNames={resultFiles(I).name}';
    newStrings=replace(fileNames,[recordName,'.'],''); % get rid of leading parts
    allStrings=union(curStrings,newStrings);
    if ~isempty(fileNames)
        newSelection = updateStringAndValueOfControl(handles.ProcessingResultsLB, eventdata, handles, allStrings, 'last');
    else
        %         set(handles.ProcessingResultsLB,'String',{'no results'});
        %         set(handles.ProcessingResultsLB,'Value',1);
    end
else % nothing to do here
end
LoadProcessingResults(hObject, eventdata, handles)

function LoadProcessingResults(hObject, eventdata, handles)
% Load the results from the currenlty selected record, process and version
% into a structure R in the data object
data = getappdata(handles.ECGviewer,'data');
recordName=handles.RecordMenu.String(handles.RecordMenu.Value);
recordFileName = getRecordFileName(recordName);
[pathName,fileName,fileExt]=fileparts(recordFileName{:});
processName=handles.ProcessingResultsLB.String(handles.ProcessingResultsLB.Value);
versionName=handles.ParameterDefinitionLB.String(handles.ParameterDefinitionLB.Value);
fname=fullfile(pathName,[recordName{:},'.',processName{:},'.',versionName{:}]);
if exist(fname,'file')
    disp([' Loading ',fname,' ...']);
    data.R = load(fname,'-mat');
else
    data.R = [];
end
setappdata(handles.ECGviewer,'data',data);
plotProcessingResults(handles);


% --- Executes during object creation, after setting all properties.
function ProcessingResultsLB_CreateFcn(hObject, eventdata, handles)
% hObject    handle to ProcessingResultsLB (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function newSelection = updateStringAndValueOfControl(hObject, eventdata, handles, newStrings, defaultPosition)
% sets the strings of control hObject to newStrings and chooses the value
% such that it points to previously selected string or to 1 as a default
% output
%  newSelection ...  selected string at the end of the process

if nargin < 5
    defaultPosition='last';
end
curStrings=get(hObject,'String');
curValue=get(hObject,'Value');
curSelection=curStrings(curValue);

JvalidSelection=ismember(newStrings,curSelection);
set(hObject,'String',newStrings);
if sum(JvalidSelection)==1 % selection is already in the list
    set(hObject,'Value',find(JvalidSelection));
else
    switch defaultPosition
        case 'last'
            defaultValue=numel(newStrings);
        case 'first'
            defaultValue=1;
        otherwise
            warning('chooseStringOFControl: undefined defaultPosition %s" ... using "last".',defaultPosition);
            defaultValue=numel(newStrings);
    end
    set(hObject,'Value',defaultValue);
end
newStrings=get(hObject,'String');
newValue=get(hObject,'Value');
newSelection=newStrings{newValue};


% --------------------------------------------------------------------
function DataToWorkspace_Callback(hObject, eventdata, handles)
% hObject    handle to DataToWorkspace (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes when user attempts to close ECGviewer.
function figure1_CloseRequestFcn(hObject, eventdata, handles)
% hObject    handle to ECGviewer (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: delete(hObject) closes the figure
delete(hObject);


% --- Executes when selected cell(s) is changed in FeatureTable.
function FeatureTable_CellSelectionCallback(hObject, eventdata, handles)
% hObject    handle to FeatureTable (see GCBO)
% eventdata  structure with the following fields (see MATLAB.UI.CONTROL.TABLE)
%	Indices: row and column indices of the cell(s) currently selecteds
% handles    structure with handles and user data (see GUIDATA)
hGUIecg = getappdata(0,'hGUIecg');
data = getappdata(hGUIecg,'data');
cellData = get(hObject,'Data');
indices = eventdata.Indices;
if ~isempty(indices)
    r = indices(:,1);
    c = indices(:,2);
    linear_index = sub2ind(size(cellData),r,1);
    linear_index_value = sub2ind(size(cellData),r,2);
    linear_index_value_true_class = sub2ind(size(cellData),r,3);
    observedParameter = cellData(linear_index);
    observedValue = cellData(linear_index_value);
    observedValueTrueClass = cellData(linear_index_value_true_class);
    handles.observedParameter.String = observedParameter;
    handles.observedValue.String = observedValue;
    handles.observedValueTrueClass.String = observedValueTrueClass;
end


% --- Executes on selection change in ParameterDefinitionLB.
function ParameterDefinitionLB_Callback(hObject, eventdata, handles)
% hObject    handle to ParameterDefinitionLB (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
LoadProcessingResults(hObject, eventdata, handles)

% --- Executes during object creation, after setting all properties.
function ParameterDefinitionLB_CreateFcn(hObject, eventdata, handles)
% hObject    handle to ParameterDefinitionLB (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes when entered data in editable cell(s) in FeatureTable.
function FeatureTable_CellEditCallback(hObject, eventdata, handles)
% hObject    handle to FeatureTable (see GCBO)
% eventdata  structure with the following fields (see MATLAB.UI.CONTROL.TABLE)
%	Indices: row and column indices of the cell(s) edited
%	PreviousData: previous data for the cell(s) edited
%	EditData: string(s) entered by the user
%	NewData: EditData or its converted form set on the Data property. Empty if Data was not changed
%	Error: error string when failed to convert EditData to appropriate value for Data
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on selection change in EvaluationGroupPopup.
function EvaluationGroupPopup_Callback(hObject, eventdata, handles, evaluationGroup2load)
% hObject    handle to EvaluationGroupPopup (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
newSelection = updateStringAndValueOfControl(handles.EvaluationGroupPopup, eventdata, handles, evaluationGroup2load, 'first');


% --- Executes during object creation, after setting all properties.
function EvaluationGroupPopup_CreateFcn(hObject, eventdata, handles)
% hObject    handle to EvaluationGroupPopup (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in pushbutton11.
function pushbutton11_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton11 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% --- Executes on button press in pushbuttonProcess.
PHIS=getappdata(0,'PHIS');
hGUIecg = getappdata(0,'hGUIecg');
data = getappdata(handles.ECGviewer,'data');
hObject.BackgroundColor=[0.5 0 0];
set(hGUIecg,'Pointer','watch');
recordNames = handles.RecordMenu.String;
recordFileNames = getRecordFileName(recordNames);
processName = handles.ProcessingResultsLB.String{handles.ProcessingResultsLB.Value};
processVersion=handles.ParameterDefinitionLB.String{handles.ParameterDefinitionLB.Value};
try % try to load parameters from XLSX Sheet named ParameterSets
    p=data.SD_ParameterSets;
    pars2use = parseParameterDS(p,processVersion);
catch
    warning(' Failed to parse process parameters by "%s", using defaults.',processVersion);
    pars2use=eval(processVersion);
end
for i = 1:numel(recordFileNames)
    cur_recordFileName=recordFileNames{i};
    feval(processName, cur_recordFileName, pars2use); % Attention: uses default parameter settings!!!
end
hObject.BackgroundColor=[0 0.5 0];
set(hGUIecg,'Pointer','arrow');
%Refresh(hObject, eventdata, handles)
ProcessingResultsLB_Callback(hObject, eventdata, handles)
