% DONT TOUCH ANYTHING INSIDE THE BOX HERE
%==========================================================================
function varargout = GUI_Design_2015_05_03(varargin)

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @GUI_Design_2015_05_03_OpeningFcn, ...
                   'gui_OutputFcn',  @GUI_Design_2015_05_03_OutputFcn, ...
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
% ========================================================================


%--------------------------------------------------------------------------
% Executes just before GUI_Design_2015_05_03 is made visible.
%--------------------------------------------------------------------------
% INITIALISATIONS VAR
function GUI_Design_2015_05_03_OpeningFcn(hObject, eventdata, handles, varargin)
% Set All Handles Variable
handles.output = hObject;
clc;
disp('------------   START   -----------');

%--------Innitialize All Handles Variable That Will be Used----------------
%VALUES
handles.moving      = 0;                % Indicate the status of the robot in moving or not
handles.position    = [ 0,0,0]; 
handles.joint       = [ 0,0,0,0,0,0];
handles.Speed ='10';
handles.pause=0;

% Initial Input Output - Conveyor Run ; Conveyor Direction ; Solenoid Valve
% ; Vacuum Pump
handles.CRun        ='0';   % Conveyor On/Off Output Status                  
handles.CDir        ='0';   % Conveyor direction output status
handles.Sol         ='0';   % Solenoid valve on/off output status
handles.Vac         ='0';   % Vacuum pump on/off output status

handles.Connect     = 0;    % Status connection with robot studio 0 = Unconnected ; 1 = Connected

% Initial Value for Current Joint Status 
% Current Joint 1 ---> Current Joint 6
% Before GUI connected & syncronize with Robot Studio
handles.CJ1 ='0';       % Joint 1 current status 
handles.CJ2 ='0';       % Joint 2 current status
handles.CJ3 ='0';       % Joint 3 current status
handles.CJ4 ='0';       % Joint 4 current status
handles.CJ5 ='0';       % Joint 5 current status
handles.CJ6 ='0';       % Joint 6 current status

% Initial Value for Current End Effector status 
% Before GUI connected & syncronize with Robot Studio 
handles.CX   = '0';     % Current end effector position on X 
handles.CY   = '0';     % Current end effector position on Y 
handles.CZ   = '0';     % Current end effector position on Z 

% Status of boxes and chocolates 
% Before GUI connected & syncronize with Robot Studio 
handles.box  ={};
handles.b    = [];
handles.bSelect = [0 0]; %[box, region]

set(handles.pickTargetList,'data',[] );
set(handles.placeTargetList,'data',[] );

handles.pickTarget = [];
handles.placeTarget = [];
handles.selectedChocolate = [];
handles.zTable = 150;
handles.placeTable = [];
handles.robotStatus = 'GREEN';

% Managing proper ties of Axis handles for showing the video & image
% processing result
% axes3 for showing detected choclate
% axesConvDetect for showing detected box
% axesConvCam for showing conveyor camera
% TableCam for showing table camera                      
set(handles.axes3, 'Xlim', [0,1600], 'YLim', [0 900]); % Setting limit axes tobe respect to the image resolution
set(handles.axes3,'xtick',[],'ytick',[]);       % Supress the axes3 axis value
set(handles.axesConvDetect,'xtick',[],'ytick',[]);       % Supress the axes4 axis value
set(handles.axesConvCam,'xtick',[],'ytick',[]);     % Supress the ConvCam axis value
set(handles.TableCam,'xtick',[],'ytick',[]);    % Supress the TableCam axis value
set(handles.axesConvDetect, 'Xlim', [0,640], 'YLim', [0 480]);

set(handles.axesTableSelect,'Xlim', [0,1600], 'YLim', [0 900]);
set(handles.placeTargetAxes,'Xlim', [0,1600], 'YLim', [0 900]);
set(handles.placeTargetAxes,'xtick',[],'ytick',[]);



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
axes(handles.axesConnectivity);
%%%%%%%%%%%%%%%%%%%%

%Managing handles TIMERS INITIALISATION
handles.timer= timer(...
    'ExecutionMode', 'fixedRate', ...               % Run timer repeatedly in fix rate
    'Period', 5, ...                              % Initial period is 0.1 sec.
    'TimerFcn', {@DetectChocolates,hObject,handles});  % Specify callback function that executed when timer iterated

    %Calling robBIND
handles.timer2= timer(...
    'ExecutionMode', 'fixedRate', ...               % Run timer repeatedly in fix rate
    'Period', 7, ...                              % Initial period is 0.1 sec.
    'TimerFcn', {@UpdateConnection2,hObject,handles});  % Specify callback function that executed when timer iterated
    
    %Calling robSTAT
handles.timer1= timer(...
    'ExecutionMode', 'fixedRate', ...               % Run timer repeatedly in fix rate
    'Period', 5, ...                              % Initial period is 0.1 sec.
    'TimerFcn', {@UpdateConnection,hObject,handles}); 

%% Timer that check the Steps Of Current Robot's Run & Run it
handles.timerRunRobot= timer(...
    'ExecutionMode', 'fixedRate', ...               
    'Period', 1, ...                             
    'TimerFcn', {@RunRobot,hObject,handles}); 



% Update handles structure
guidata(hObject, handles);
% UIWAIT makes GUI_Design_2015_05_03 wait for user response (see UIRESUME)
%uiwait(handles.figure1);
%--------------------------------------------------------------------------


% --- Outputs from this function are returned to the command line.
function varargout = GUI_Design_2015_05_03_OutputFcn(hObject, eventdata, handles) 
varargout{1} = handles.output;
% -----------------------------------------------------------------------


%--------------------------------------------------------------------------
% Managing Edit Texbox Components
%--------------------------------------------------------------------------

%-------------------Speed Setting Input------------------------------------

function editSpeed_Callback(hObject, eventdata, handles)
% --- Executes during object creation, after setting all properties.
function editSpeed_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), ...
        get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

%-------------------Command Output & Status Robot--------------------------


% Texbox for showing coordinate in conveyor camera
% that will be sending to the robot on Click n GO operation
function C_Coordinate_Callback(hObject, eventdata, handles)
% --- Executes during object creation, after setting all properties.
function C_Coordinate_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), ...
        get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

% Texbox for showing coordinate in table camera
% that will be sending to the robot on Click n GO operation
function T_Coordinate_Callback(hObject, eventdata, handles)
% --- Executes during object creation, after setting all properties.
function T_Coordinate_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), ...
        get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

% Texbox for showing realtime current position of the robot 
function CurrentPosition_Callback(hObject, eventdata, handles)
% Executes during object creation, after setting all properties.
function CurrentPosition_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), ...
        get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

% Texbox for showing realtime current joint angle of the robot 
function CurrentJoint_Callback(hObject, eventdata, handles)
% --- Executes during object creation, after setting all properties.
function CurrentJoint_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), ...
        get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

% Texbox for showing realtime current I/O status of the robot
function CurrentIO_Callback(hObject, eventdata, handles)
% --- Executes during object creation, after setting all properties.
function CurrentIO_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), ...
        get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
%--------------------------------------------------------------------------


%--------------------------------------------------------------------------
% Managing Axis
%--------------------------------------------------------------------------
function axesConvCam_CreateFcn(hObject, eventdata, handles)
% Hint: place code in OpeningFc
% --- Executes during object creation, after setting all properties.


%--------------------------------------------------------------------------
% Managing Button Object
%--------------------------------------------------------------------------

%------------------------Setting Speed Button------------------------------
function SpeedButton_Callback(hObject, eventdata, handles)
handles.Speed= get(handles.editSpeed, 'string');    % Get speed data input from the textbox
sender('3');                                        % Call sender function to send '3' as speed change mode
pause(0.01);
data=sprintf('[%s,%s,%s,%s,%s,0]'...                % Set data tobe sended as string
    ,handles.Vac,handles.Sol...
    ,handles.CRun,handles.CDir,handles.Speed);
sender(data);                                       % Call sender function to send speed data

%--------------------------Click & GO Button-------------------------------

% Executed when Click 2 Select button pressed 
function GetC_Coordinate_Callback(hObject, eventdata, handles)
set(handles.editCommand,'string', 'Press ENTER to cancel' );

[X, Y]=ginput(1);                                   % Get input coordinate from the table camera frame
ax = gca;
[pick]= reachable(X,Y);
if pick==1
    switch ax
        case handles.axesConvSelect
            location = 0;
        case handles.axesConvDetect
            location = 0;
        case handles.axesConvCam
            location = 0;
        case handles.placeTargetAxes
            location = 1;
        case handles.axesTableSelect
            location = 1;
        case handles.axes3
            location = 1;
        case handles.TableCam
            location = 1;
    end
      
    switch location
        % switch location % 0 = conveyer camera, 1 = table camera
        case 0
            XR=900-Y; YR=X; XR=XR*1.5; YR=YR*1.5;               % Convert & adjust the measurement from pixle to mm
            XR=int32(XR); YR=int32(YR);                         % Convert X & Y value into integer
            % texboxStatus = sprintf('X = %d  Y = %d', XR, YR);   % Set data to be showed
            % set(handles.C_Coordinate,'String',texboxStatus);    % Show value into textbox
            % sender('0');                                        % Call sender function to send '0' as linear mode
            % pause(0.01);
            % data=sprintf('[%d,%d,150]',XR, YR);                 % Set data to be sended
            % sender(data);                                       % Call sender function to send data
            % set ( handles.CmdStatus, 'String' ,...              % Show command in the command status
            %     ['Move End Efector Robot Linear to ' ] );
            inside = 0;
            siz = size(handles.b);
            for choco = 1:siz(1,1);
                for reg = 1:4
                    inside = inpolygon( X,Y,...
                        handles.box{choco}.rec{reg}(1,:),...
                        handles.box{choco}.rec{reg}(2,:));
                    if inside ~= 0
                        set(handles.editCommand,'string',...
                            ['Yea Baby! it is inside '   num2str(choco) ] );
                        boxID = choco;
                        handles.bSelect = [boxID , reg];
                        
                        tempStr = data2str(handles.box{boxID}.xy,reg,0);
                        set(handles.uitableRegion, 'data', tempStr);
                        
                        tempStr = data2str(handles.b(:,3),boxID,0);
                        set(handles.uitableBox, 'data', tempStr);
                        
                        %plotting the rectangle
                        axes(handles.axesConvSelect);
                        plot(handles.box{boxID}.rec{reg}(1,:),...
                            handles.box{boxID}.rec{reg}(2,:), '--k');
                        set(handles.axesConvSelect,'color','none','Xlim'...
                            ,[0 640],'ylim',[0 480]...
                            ,'Xtick',[], 'Ytick',[]);
                        guidata(hObject, handles);
                        
                        % Set the Currently Selected coordinate
                        X = handles.box{boxID}.xy(reg,1);
                        Y = handles.box{boxID}.xy(reg,2);
                        [X,Y] = conveyor2robot(X,Y);
                        theta = handles.b(boxID,3);
                        set(handles.textCurrentSelect, 'string' ...
                            , num2str([X Y theta]) );
                        return;
                    end
                end
            end
            
            set(handles.uitableRegion, 'data', []);
            
            tempStr = data2str(handles.b(:,3),0,0);
            set(handles.uitableBox, 'data', tempStr);
            set(handles.editCommand,'string','Not In Any Box' );
            axes(handles.axesConvSelect);cla;
            set(handles.axesConvSelect,'color','none','Xlim'...
                ,[0 640],'ylim',[0 480]...
                ,'Xtick',[], 'Ytick',[]);
            
            % Set the Currently Selected coordinate . theta is left to be 0 for now
            [X,Y] = conveyor2robot(X,Y);
            the = get(handles.editThetaClick,'String');
            set(handles.textCurrentSelect, 'string' , [num2str([X Y]) '   ' the ] );
            %% Case Table axes
        case 1
            xx = X;
            yy = Y;
            
            Data = handles.chocolates;
            dataSize = size(Data);
            selectedData = [];
            Row = [];
            for i=1:dataSize(1),
                in = checkPoint(xx , yy , Data(i,1) , Data(i,2),  -Data(i,3));
                if in == 1,
                    selectedData = Data(i,:);
                    Row = [Row,i];
                    tempX = Data(i,1);
                    tempY = Data(i,2);
                    tempT = Data(i,3);
                    [tempX, tempY] = table2robot(tempX,tempY);
                    % show in the 'Currently Selected'
                    set(handles.textCurrentSelect, 'string' ,...
                        num2str([tempX tempY tempT]) );
                    break;
                end
            end;
            axes(handles.axesTableSelect); cla;
            set(handles.axesTableSelect,'color','none');
            try
                plotRectangle(selectedData(1,1) , selectedData(1,2),  -selectedData(1,3))
                handles.chocolatesStr =reshape(strtrim(cellstr(num2str(handles.chocolates(:)))),...
                    size(handles.chocolates));
                handles.chocolatesStr(Row,:) = strcat('<html><body bgcolor="#0000FF" text="#FFFFFF" width="100px">', ...
                    handles.chocolatesStr(Row,:),'</span></html>');
                set(handles.ChocTable,'Data',handles.chocolatesStr);
                
            catch
                set(handles.editCommand,'string','TABLE : Not In Any Box' );
                [X, Y] = table2robot(X, Y);
                the = get(handles.editThetaClick,'String');
                set(handles.textCurrentSelect, 'string' , [num2str([X Y]) '   ' the ]);
            end
    end
else
    errordlg('Unreachable Chocolate. Select again');
end

%%
guidata(hObject, handles);


% Executed when Click & GO button on Table camera pressed 
function Get_T_Coordinate_Callback(hObject, eventdata, handles)
[xx, yy]=ginput(1);

switch get(get(handles.singleSelection,'SelectedObject'),'Tag')
    case 'pickMode',  
        Data = handles.chocolates;
        dataSize = size(Data);
        selectedData = [];
        Row = [];
        for i=1:dataSize(1),
            in = checkPoint(xx , yy , Data(i,1) , Data(i,2),  -Data(i,3));
            if in == 1,
                selectedData = Data(i,:);
                Row = [Row,i];
            end
        end;
        axes(handles.axesTableSelect); cla; 
        set(handles.axesTableSelect,'color','none');
        try
            plotRectangle(selectedData(1,1) , selectedData(1,2),  -selectedData(1,3))
            handles.chocolatesStr =reshape(strtrim(cellstr(num2str(handles.chocolates(:)))),...
                size(handles.chocolates));
            handles.chocolatesStr(Row,:) = strcat('<html><body bgcolor="#0000FF" text="#FFFFFF" width="100px">', ...
                    handles.chocolatesStr(Row,:),'</span></html>');
            set(handles.ChocTable,'Data',handles.chocolatesStr);
    
            [Xr , Yr] = table2robot(selectedData(1,1),selectedData(1,2));
            newPickTarget = [double(Xr) , double(Yr) , handles.zTable , ...
                selectedData(1,3)];
            handles.pickTarget = [handles.pickTarget ; newPickTarget];
            set(handles.pickTargetList,'Data',handles.pickTarget);
            set(handles.nPickTargetShow,'string',...
                num2str(length(handles.pickTarget(:,1))));
        catch
            errordlg('No chocolate detected on that particular area');
        end
    case 'placeMode',
        [Xr, Yr] = table2robot(xx,yy);
        theta = get(handles.placeTargetTheta,'Value');
        theta = theta*pi/180;
        newPlaceTarget = [double(Xr) , double(Yr) , handles.zTable , ...
                theta];
        newPlaceTable = [xx , yy , theta] ;
%         
%         if ~isempty(handles.placeTarget(:,:))        
%             len = length( find((handles.placeTarget(:,1)>newPlaceTarget(1,1)-10) && ...
%                     (handles.placeTarget(:,1)<newPlaceTarget(1,1)+10)) && ...
%                     (handles.placeTarget(:,2)>newPlaceTarget(1,2)-10) && ...
%                     (handles.placeTarget(:,2)<newPlaceTarget(1,2)+10) );    
% 
%             handles.zTable= handles.zTable+ 6*(len);
%         end
%         
        handles.placeTable = [handles.placeTable ; newPlaceTable];
        handles.placeTarget = [handles.placeTarget ; newPlaceTarget];
        set(handles.placeTargetList,'Data',handles.placeTarget);
        set(handles.nPlaceTargetShow,'string',...
                num2str(length(handles.placeTarget(:,1))));
        axes(handles.placeTargetAxes); hold on;
        set(handles.placeTargetAxes,'color','none');
        plotTarget(handles.placeTable); hold off;
end






guidata(hObject, handles);



% ------------------Activate Timer To Connect Robot Studio-----------------

function connectButton_Callback(hObject, eventdata, handles)
disp(handles.Connect)
if handles.Connect == 0,        % When it hasn't connected yet
    %Managing Video handles
    [handles.vid1,handles.vid2,videoConnect] = ConnectToCamera;
    if videoConnect==1,
        set(handles.connectButton,'String', 'Disconnect'); % Turn the button into disconnect button
        handles.Connect = 1;        % make the connection status = 1 ---> Connected
        showImage(hObject,handles)
    end              
    start(handles.timer1);       % Start timer 1 to connect with robot studio periodically      
    start(handles.timer2);
else                            % When it already connected
    stop(handles.timer1);   
    stop(handles.timer2);delete(handles.timer2); 
    stop(handles.vid1);         % stop video 2 to disconnect from table camera
    stop(handles.vid2);         % stop video 2 to disconnect from conveyor camera
    delete(handles.timer1);        % Stop  to stop connection wit the robot
    delete(handles.vid1);         % stop video 2 to disconnect from table camera
    delete(handles.vid2);
    handles.Connect = 0;        % make the connection status = 0 ---> unconnected
    set(handles.connectButton,'String', 'Connect'); % Turn the button into connect button
end
guidata(hObject, handles);


% ----------------------PAUSE & RESUME BUTTON------------------------------

% Executed when the resume button pressed
function resumeButton_Callback(hObject, eventdata, handles)
sender('S2');                                   % Call function sender to send character 'S2' into robot studio
set(handles.resumeButton,'Enable', 'off');      % Make the resume button disable
set(handles.pauseButton,'Enable', 'on');        % Make the pause button enable
set ( handles.CmdStatus, 'String' , 'RESUME' ); % Show in the command status texbox RESUME

% Executed when the pause button pressed
function pauseButton_Callback(hObject, eventdata, handles)
sender('S1');                                   % Call function sender to send character 'S1' into robot studio
set(handles.resumeButton,'Enable', 'on');       % Make the resume button enable
set(handles.pauseButton,'Enable', 'off');       % Make the pause button disable while the robot is paused
set ( handles.CmdStatus, 'String' , 'PAUSE' ) ; % Show in the command status texbox PAUSE
%--------------------------------------------------------------------------

% ----------------------Calibrate Position Button--------------------------

% Executed when the calibrate pos button pressed
function calibrateButton_Callback(hObject, eventdata, handles)
sender('2');                                                        % Call function sender to send charachter '2' into robot studio
set ( handles.CmdStatus, 'String' , 'Move to Calibrate Position' ); % Show in the command status 

%--------------------------------------------------------------------------


%------------------- Managing Table Object---------------------------------
% Creating table object to show the list of detected chocolate
function ChocTable1_CreateFcn(hObject, eventdata, handles)


%------------------------TIMER FUNCTION------------------------------------
% This function will be executed every time timer object iterated
%--------------------------------------------------------------------------

function UpdateConnection(hObject,eventdata,hfigure,handles)
% handles.robotStatus
robStat = robBIND;
set(handles.textConnection,'String',robStat);
switch robStat
    case 'RED'
        set(handles.textConnection,'ForegroundColor',[1 0 0]);
    case 'YELLOW'
        set(handles.textConnection,'ForegroundColor',[1 1 0]);
    case 'GREEN'
        set(handles.textConnection,'ForegroundColor',[0 1 0]);
end

function UpdateConnection2(hObject,eventdata,hfigure,handles)
% handles.robotStatus
robStat = robBIND;
set(handles.textConnection,'String',robStat);

switch robStat
    case 'RED'
        set(handles.textConnection,'ForegroundColor',[1 0 0]);
    case 'YELLOW'
        set(handles.textConnection,'ForegroundColor',[1 1 0]);
    case 'GREEN'
        set(handles.textConnection,'ForegroundColor',[0 1 0]);
end

function DetectChocolates(hObject,eventdata,hfigure,handles)
                  
drawnow();  % Push matlab to show the result before executing another function
%guidata(hObject, handles);

%%=============== IMPORTANT PART FOR THE AUTOMATION============
function RunRobot(hObject,eventdata,hfigure,handles)
% 'PICK ' : trying to Pick
% 'PICK_' : Just finished Picked
% _ currently doing the task
% robStat = get(handles.textRobotStatus,'String');
% conn    = get(handles.textConnection,'String');
% stepNum = str2num(robStat(6:end));
% doing = robStat(1:5);
step = get(handles.textRobotStatus,'String');
stepNum = str2num(step(6:end));

xytPICK = get(handles.pickTargetList,'data');
xytPLACE = get(handles.placeTargetList,'data');

switch step(1:5)
    %------------- PICKING STEPS ------------------------------------
    case 'PICK ' % Go to the picking location
        [ X, Y, Z, theta] = getZloc(xytPICK, stepNum,'PICK');
        if  strcmp(TOrobot(X, Y, Z, 0, 0, theta),'DONE')
            set(handles.textRobotStatus,'String',['PICK_' num2str(stepNum)]);
            set(handles.textConnection,'String','YELLOW');
            set(handles.textConnection,'ForegroundColor',[1 1 0]);
        else
            set(handles.textConnection,'String','RED');
            set(handles.textConnection,'ForegroundColor',[1 0 0]);
            set(handles.textRobotStatus,'String', 'STAND BY');drawonow;
            stop(handles.timerRunRobot);
            uwait(errordlg,'Disconnected','Disconnected')
            return;
        end   
    case 'PICK_' % Check if the robot have reached the pick location    
        if  strcmp(robSTAT,'GREEN')
            set(handles.textRobotStatus,'String',['VaON ' num2str(stepNum)]);
            set(handles.textConnection,'String','GREEN');
            set(handles.textConnection,'ForegroundColor',[0 1 0]);
        end    
        
    case 'VaON ' % Turn On the Vacumm pump and solenoid
        if strcmp(TOio(1,1,0,0,300),'DONE')
            set(handles.textRobotStatus,'String',['g1UP ' num2str(stepNum)]);
        end 
    case 'g1UP ' % Elevate the chocolate(prevent collision with other choc)
        [ X, Y, Z, theta] = getZloc(xytPICK, stepNum,'PICK');
        if  strcmp(TOrobot(X, Y, Z+50, 0, 0, theta),'DONE')
            set(handles.textRobotStatus,'String',['g1UP_' num2str(stepNum)]); 
            set(handles.textConnection,'String','YELLOW');
            set(handles.textConnection,'ForegroundColor',[1 1 0]);
        else
            set(handles.textConnection,'String','RED');
            set(handles.textConnection,'ForegroundColor',[1 0 0]);
            set(handles.textRobotStatus,'String', 'STAND BY');drawonow;
            stop(handles.timerRunRobot);
            uwait(errordlg,'Disconnected','Disconnected')
            return;
        end
    case 'g1UP_' % check if the robot already goes up
        if strcmp(robSTAT,'GREEN')
            set(handles.textRobotStatus,'String',['LOAD ' num2str(stepNum)]);
            set(handles.textConnection,'String','GREEN');
            set(handles.textConnection,'ForegroundColor',[0 1 0]);
        end   
   %------------- LOADING/PLACING STEPS ----------------------------------
    case 'LOAD ' % Go to the loading/place location
        [ X, Y, Z, theta] = getZloc(xytPLACE, stepNum, 'PLACE');
        if  strcmp(TOrobot(X, Y, Z, 0, 0, theta),'DONE')
            set(handles.textRobotStatus,'String',['LOAD_' num2str(stepNum)]);
        else
            set(handles.textConnection,'String','RED');
            set(handles.textConnection,'ForegroundColor',[1 0 0]);
            set(handles.textRobotStatus,'String', 'STAND BY');drawonow;
            stop(handles.timerRunRobot);
            uwait(errordlg,'Disconnected','Disconnected')
            return;
        end     
    case 'LOAD_' % Check if its arrived the loading/place location
        if strcmp(robSTAT,'GREEN')
            set(handles.textRobotStatus,'String',['VaOF ' num2str(stepNum)]);
            set(handles.textConnection,'String','GREEN');
            set(handles.textConnection,'ForegroundColor',[0 1 0]);
        end
    case 'VaOF ' % turn off the vacumm
        if strcmp(TOio(0,0,0,0,300),'DONE')
            set(handles.textRobotStatus,'String',['g2UP ' num2str(stepNum)]);
        end
        
    case 'g2UP ' % Go up
        [ X, Y, Z, theta] = getZloc(xytPLACE, stepNum,'PLACE');
        if  strcmp(TOrobot(X, Y, Z, 0, 0, theta),'DONE')
            set(handles.textRobotStatus,'String',['g2UP_' num2str(stepNum+1)]);
        else
            set(handles.textConnection,'String','RED');
            set(handles.textConnection,'ForegroundColor',[1 0 0]);
            set(handles.textRobotStatus,'String', 'STAND BY');drawonow;
            stop(handles.timerRunRobot);
            uwait(errordlg,'Disconnected','Disconnected')
            return;
        end
        
    case 'g2UP_' %check if already went up
        if strcmp(robSTAT,'GREEN')
            nPICK = str2num(get(handles.nPickTargetShow,'String'));
            set(handles.textConnection,'String','GREEN');
            set(handles.textConnection,'ForegroundColor',[0 1 0]);
            if nPICK==stepNum %% done all steps
                set(handles.textRobotStatus,'String', 'STAND BY');drawonow;
                stop(handles.timerRunRobot);
                return;
            else
                set(handles.textRobotStatus,'String',['PICK ' num2str(stepNum+1)]);
            end
        end      
end
drawonow;
guidata(hObject, handles);



%--------------------------------------------------------------------------
% Managing Close GUI
%--------------------------------------------------------------------------
% --- Executes when user attempts to close figure1.
function figure1_CloseRequestFcn(hObject, eventdata, handles)
disp('------------END OF RUN------------');
delete(hObject);
try
    delete(handles.vid1);   % Delete object input vodeo 1 before closing the GUI
    delete(handles.vid2);   % Delete object input vodeo 2 before closing the GUI
catch
end
delete(handles.timer1);delete(handles.timer2);  % Delete object timer before closing the GUI
delete(handles.timer);  % Delete object timer before closing the GUI

function showImage(hObject,handles)

    [imHeight,imWidth, nBands] = SetImage(handles.vid1,handles.vid1);
    axes(handles.TableCam);                              % set axes ConvCam for showing video 1
    hImage1 = image(zeros(imHeight(1),imWidth(1), nBands(1)), ... % set image frame as a the size of video image as a base for showing 
        'parent', handles.TableCam);                     % video image
    preview(handles.vid1,hImage1);                       % show video image 1 on hImage frame
    
    axes(handles.axesConvCam);                             % set axes TableCam for showing video 2
    hImage2 = image(zeros(imHeight(2), imWidth(2), nBands(2)), ... % set image frame as a the size of video image as a base for showing 
        'parent', handles.axesConvCam);                    % video image
    preview(handles.vid2,hImage2); 
    
    guidata(hObject, handles);


% --- Executes when selected cell(s) is changed in ChocTable1.
function ChocTable1_CellSelectionCallback(hObject, eventdata, handles)
% hObject    handle to ChocTable1 (see GCBO)
% eventdata  structure with the following fields (see MATLAB.UI.CONTROL.TABLE)
%	Indices: row and column indices of the cell(s) currently selecteds
% handles    structure with handles and user data (see GUIDATA)
handles.selectedRow = eventdata.Indices(1);
Data = get(handles.ChocTable1,'Data');
selectedData = Data(handles.selectedRow,:);
set(handles.selectedChocolateTable,'Data',selectedData);
axes(handles.axes3); cla;
plotRectangle(selectedData(1,1) , selectedData(1,2),  -selectedData(1,3))
disp(eventdata);


% --- Executes on button press in pushbutton36.
function pushbutton36_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton36 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on button press in selectGroupButton.
function selectGroupButton_Callback(hObject, eventdata, handles)
Data = get(handles.ChocTable1,'Data');
flavourColoum = Data(:,6); 
switch get(get(handles.selectGroup,'SelectedObject'),'Tag')
    case 'selectMilk',  
        milkRow = find(flavourColoum==1);
        selectedData = Data(milkRow,:);
        set(handles.selectedChocolateTable,'Data',selectedData);
    case 'selectDark',  
        darkRow = find(flavourColoum==2);
        selectedData = Data(darkRow,:);
        set(handles.selectedChocolateTable,'Data',selectedData);
    case 'selectOrange',  
        orangeRow = find(flavourColoum==3);
        selectedData = Data(orangeRow,:);
        set(handles.selectedChocolateTable,'Data',selectedData);
    case 'selectMint',  
        mintRow = find(flavourColoum==4);
        selectedData = Data(mintRow,:);
        set(handles.selectedChocolateTable,'Data',selectedData);
    case 'selectBack',  
        backRow = find(flavourColoum==0);
        selectedData = Data(backRow,:);
        set(handles.selectedChocolateTable,'Data',selectedData);
end
dataSize = size(selectedData);
axes(handles.axes3); cla;
for i=1:dataSize(1),    
    plotRectangle(selectedData(i,1) , selectedData(i,2),  -selectedData(i,3))
    hold on;
end


% --- Executes on button press in findChocolatesButton.
function findChocolatesButton_Callback(hObject, eventdata, handles)
try 
    imgTable=getsnapshot(handles.vid1);     % capture image from video 1 (Table camera)
    set(handles.editCommand, 'string', 'Snaphot from Table Camera');
catch
    imgTable=imread('IMG_013.jpg');
    set(handles.editCommand, 'string', 'Saved Image');
end
axes(handles.TableCam);
image(imgTable);
set(handles.TableCam,'xtick',[],'ytick',[]);       % Supress the axes3 axis value

axes(handles.axes3);cla;
set(handles.axes3,'color','none');
c = findChoc((imgTable));   % HERE THE CHOC DETECTION
set(handles.axes3,'xtick',[],'ytick',[]);       % Supress the axes3 axis value

handles.chocolates =c(:,[1:3 6 8]);
setappdata(hObject.Parent,'chocolatesData',handles.chocolates);
handles.chocolatesStr =reshape(strtrim(cellstr(num2str(handles.chocolates(:)))),...
        size(handles.chocolates));
set(handles.ChocTable,'Data',handles.chocolatesStr); % show data chocolate on the table 
% set(handles.editCommand,'string','Done Detection');
guidata(hObject, handles);

% --- Executes on button press in runButton. 
function runButton_Callback(hObject, eventdata, handles)
% pickTarget = get(handles.pickTargetList,'Data');
% placeTarget = get(handles.placeTargetList,'Data');
% Torobot(pickTarget(1),pickTarget(2),pickTarget(3),0,0,pickTarget(4));
switch get(handles.runButton,'String')
    case 'RUN'
        switch get(handles.textConnection,'string')
            case 'GREEN'
                set(handles.runButton,'String','PAUSE'); 
                stat = get(handles.textRobotStatus,'String');
                if strcmp(stat(1:5),'STAND')
                    start(handles.timerRunRobot);
%                     RunRob(hObject, eventdata, handles);
                    set(handles.textRobotStatus,'String', 'PICK 1');
                end
            case 'YELLOW'
                set(handles.editCommand,'String','Robot is busy. Please Wait');
            case 'RED'
                set(handles.editCommand,'String','Please Connect to the Robot');
%                 errordlg('Please connect the robot','NO CONNECTION');
        end
    case 'PAUSE'
        set(handles.runButton,'String','RESUME');
        set(handles.editCommand,'String','Press Esc to Cancel Task');
        stop(handles.timerRunRobot);
        sender('S1');
    case 'RESUME'
        set(handles.runButton,'String','PAUSE');
        start(handles.timerRunRobot);
        sender('S2');
end

function RunRob(hObject, eventdata, handles)
    set(handles.textRobotStatus,'String', 'PICK 1');
    
    toPICK = get(handles.pickTargetList,'data');
    step = get(handles.textRobotStatus,'String');
    stepNum = str2num(step(6:end)); 
    
    xytPICK = get(handles.pickTargetList,'data'); 
    xytPLACE = get(handles.placeTargetList,'data');
    

    while 1
%         try
            [ X, Y, Z, theta] = getZloc(xytPICK, stepNum);
            
            if  strcmp(TOrobot(X, Y, Z, 0, 0, theta),'DONE')
                while strcmp(robSTAT,'YELLOW')
                    pause(0.5);
                end
            end
            
            if strcmp(TOio(1,1,0,0,300),'DONE')
            pause(1);
            end

            if strcmp(TOrobot(X, Y, Z+50, 0, 0, theta),'DONE')
                while strcmp(robSTAT,'YELLOW')
                    pause(0.5);
                end
            end   

            [ X, Y, Z, theta] = getZloc(xytPLACE, stepNum);         
            if  strcmp(TOrobot(X, Y, Z, 0, 0, theta),'DONE')
                while strcmp(robSTAT,'YELLOW')
                    pause(0.5);
                end
            end 
            
            if strcmp(TOio(0,0,0,0,300),'DONE')
                pause(1);
            end
            stepNum =  stepNum +1;
            
%         catch
%             disp('DONE/error');
%             break;
%         end
        
%         set(handles.textRobotStatus,'String')
%         step = get(handles.textRobotStatus,'String');
%         stepNum = str2num(step(6:end));         
    end
    guidata(hObject, handles);
    
    
    
    

    
    

function figure1_WindowKeyPressFcn(hObject, eventdata, handles)

function figure1_WindowKeyReleaseFcn(hObject, eventdata, handles)
% 
% 
% % --- Executes on button press in radiobuttonConnection.
% function radiobuttonConnection_Callback(hObject, eventdata, handles)
% hObject    handle to radiobuttonConnection (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of radiobuttonConnection



function editCommand_Callback(hObject, eventdata, handles)
% hObject    handle to editCommand (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of editCommand as text
%        str2double(get(hObject,'String')) returns contents of editCommand as a double


% --- Executes during object creation, after setting all properties.
function editCommand_CreateFcn(hObject, eventdata, handles)
% hObject    handle to editCommand (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in pushbuttonDetectBox.

function pushbuttonDetectBox_Callback(hObject, eventdata, handles)
try
    imgConv=getsnapshot(handles.vid2);      % capture image from video 2 (conveyor camera)
catch
    imgConv=imread('converyor4.jpg');
end
axes(handles.axesConvCam);
image(imgConv);
set(handles.axesConvCam,'xtick',[],'ytick',[]);

axes(handles.axesConvDetect);hold on;
[handles.b ,handles.box]=plotBoxConv(imgConv); hold off; % detect box

set(handles.axesConvDetect,'color','none'); 
set(handles.axesConvDetect,'xtick',[],'ytick',[]);

set(handles.uitableBox, 'data', handles.b(:,3));

set(handles.editCommand, 'String', 'Done Boxes Detection');
% assignin('base', 'handles', handles);
num2Place = (get(handles.nPickTargetShow,'string'));


if str2num(num2Place) > 0
    set(handles.nPlaceTargetShow,'string',num2Place);    
    boxTotal = size(handles.b());
    tempDat=[];
    for bx = 1:boxTotal(1,1)
        for layer = 1:6
            tempDat(4*layer-3:4*layer,1:2) = handles.box{bx}.xy(:,:);
            tempDat(4*layer-3:4*layer,3)   = handles.b(bx,3);
        end
    end
    tempDat = tempDat(1:str2num(num2Place),:);
    set(handles.placeTargetList,'Data',tempDat);
else
    set(handles.placeTargetList,'Data',[]);
    set(handles.editCommand,'string','Select PICKs 1st');
end


guidata(hObject, handles);


% --- Executes when selected cell(s) is changed in uitableBox.
function uitableBox_CellSelectionCallback(hObject, eventdata, handles)
try
    rowS = eventdata.Indices(1);
    set(handles.editCommand,'string',['Box ' num2str(rowS) ' was picked'] );

    set(handles.uitableBox, 'data', data2str(handles.b(:,3),rowS,0));

    set(handles.uitableRegion, 'data', data2str(handles.box{rowS}.xy,0,0));
    handles.bSelect(1,1) = rowS ;
catch
end

guidata(hObject, handles);


% --- Executes when selected cell(s) is changed in uitableRegion.
function uitableRegion_CellSelectionCallback(hObject, eventdata, handles)
% handles.b(:,3)    : x by 3. the x,y,theta of the box
% handles.box{boxID}.xy : the 4 X,Y of each region
% handles.box{boxID}.rec{rowS} : the 4 corners of each regions

try    
    boxID = handles.bSelect(1,1);
    rowS = eventdata.Indices(1);
    set(handles.editCommand,'string',['Region '...
        num2str(rowS) ' of box ' num2str(boxID) ' was picked'] );
    
    tempStr = data2str(handles.box{boxID}.xy, rowS,0 );    
    
    set(handles.uitableRegion, 'data', tempStr);
    handles.bSelect(1,2) = rowS ;
    
    axes(handles.axesConvSelect);
    plot(handles.box{boxID}.rec{rowS}(1,:),...
        handles.box{boxID}.rec{rowS}(2,:), '--k');
    set(handles.axesConvSelect, 'Xlim', [0,640], 'YLim', [0 480]...
        ,'color','none' ,'xtick',[],'ytick',[]);
    
    % Set the current coordinate textbox
    X = handles.box{boxID}.xy(rowS,1);
    Y = handles.box{boxID}.xy(rowS,2);
    theta = handles.b(rowS,3);
    [X, Y] = conveyor2robot(X,Y);
    set(handles.textCurrentSelect, 'string' , num2str([X Y theta]) );

    
catch
end


guidata(hObject, handles);

% --- Executes on key release with focus on figure1 and none of its controls.
function figure1_KeyReleaseFcn(hObject, eventdata, handles)
k=get(gcf,'CurrentCharacter');
disp(k);
if k =='q'
    close all;clc;clear;
end
if k =='/'
    uwait(errordlg('I LOVE CHOCOLATES', 'I LOVE CHOCOLATES'));
end


% --- Executes when selected cell(s) is changed in ChocTable.
function ChocTable_CellSelectionCallback(hObject, eventdata, handles)
try
handles.chocolates = getappdata(hObject.Parent,'chocolatesData');
handles.selectedRow = eventdata.Indices(1);
handles.selectedChocolate = handles.chocolates(handles.selectedRow,:);
handles.chocolatesStr =reshape(strtrim(cellstr(num2str(handles.chocolates(:)))),...
        size(handles.chocolates));
handles.chocolatesStr(handles.selectedRow,:) = strcat('<html><body bgcolor="#0000FF" text="#FFFFFF" width="100px">', ...
            handles.chocolatesStr(handles.selectedRow,:),'</span></html>');
set(handles.ChocTable,'Data',handles.chocolatesStr);
axes(handles.axesTableSelect); cla;
set(handles.axesTableSelect,'color','none');
plotRectangle(handles.selectedChocolate(1,1) , ...
    handles.selectedChocolate(1,2),  -handles.selectedChocolate(1,3));
[Xr , Yr] = table2robot(handles.selectedChocolate(1),handles.selectedChocolate(2));
X = handles.chocolates(handles.selectedRow,1);
Y = handles.chocolates(handles.selectedRow,2);
theta = handles.chocolates(handles.selectedRow,3);
set(handles.textCurrentSelect,'string',num2str([Xr Yr theta]));
catch
end
guidata(hObject, handles);



% --- Executes on button press in checkbox19.
function checkbox19_Callback(hObject, eventdata, handles)
% hObject    handle to checkbox19 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of checkbox19


% --- Executes on button press in checkbox20.
function checkbox20_Callback(hObject, eventdata, handles)
% hObject    handle to checkbox20 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of checkbox20


% --- Executes on button press in checkbox21.
function checkbox21_Callback(hObject, eventdata, handles)
% hObject    handle to checkbox21 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of checkbox21


% --- Executes on button press in checkbox22.
function checkbox22_Callback(hObject, eventdata, handles)
% hObject    handle to checkbox22 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of checkbox22


% --- Executes on button press in checkbox23.
function checkbox23_Callback(hObject, eventdata, handles)
% hObject    handle to checkbox23 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of checkbox23



function edit43_Callback(hObject, eventdata, handles)
% hObject    handle to edit43 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit43 as text
%        str2double(get(hObject,'String')) returns contents of edit43 as a double


% --- Executes during object creation, after setting all properties.
function edit43_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit43 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit45_Callback(hObject, eventdata, handles)
% hObject    handle to edit45 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit45 as text
%        str2double(get(hObject,'String')) returns contents of edit45 as a double


% --- Executes during object creation, after setting all properties.
function edit45_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit45 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit46_Callback(hObject, eventdata, handles)
% hObject    handle to edit46 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit46 as text
%        str2double(get(hObject,'String')) returns contents of edit46 as a double


% --- Executes during object creation, after setting all properties.
function edit46_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit46 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit47_Callback(hObject, eventdata, handles)
% hObject    handle to edit47 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit47 as text
%        str2double(get(hObject,'String')) returns contents of edit47 as a double


% --- Executes during object creation, after setting all properties.
function edit47_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit47 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit48_Callback(hObject, eventdata, handles)
% hObject    handle to edit48 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit48 as text
%        str2double(get(hObject,'String')) returns contents of edit48 as a double


% --- Executes during object creation, after setting all properties.
function edit48_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit48 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit49_Callback(hObject, eventdata, handles)
% hObject    handle to edit49 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit49 as text
%        str2double(get(hObject,'String')) returns contents of edit49 as a double


% --- Executes during object creation, after setting all properties.
function edit49_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit49 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in checkbox24.
function checkbox24_Callback(hObject, eventdata, handles)
% hObject    handle to checkbox24 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of checkbox24


% --- Executes on button press in selectMilk.
function selectMilk_Callback(hObject, eventdata, handles)
% hObject    handle to selectMilk (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of selectMilk


% --- Executes on button press in selectDark.
function selectDark_Callback(hObject, eventdata, handles)
% hObject    handle to selectDark (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of selectDark


% --- Executes on button press in selectMint.
function selectMint_Callback(hObject, eventdata, handles)
% hObject    handle to selectMint (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of selectMint


% --- Executes on button press in selectOrange.
function selectOrange_Callback(hObject, eventdata, handles)
% hObject    handle to selectOrange (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of selectOrange


% --- Executes on button press in selectBack.
function selectBack_Callback(hObject, eventdata, handles)
% hObject    handle to selectBack (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of selectBack



function nBackInput_Callback(hObject, eventdata, handles)
% hObject    handle to nBackInput (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of nBackInput as text
%        str2double(get(hObject,'String')) returns contents of nBackInput as a double


% --- Executes during object creation, after setting all properties.
function nBackInput_CreateFcn(hObject, eventdata, handles)
% hObject    handle to nBackInput (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function nMintInput_Callback(hObject, eventdata, handles)
% hObject    handle to nMintInput (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of nMintInput as text
%        str2double(get(hObject,'String')) returns contents of nMintInput as a double


% --- Executes during object creation, after setting all properties.
function nMintInput_CreateFcn(hObject, eventdata, handles)
% hObject    handle to nMintInput (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function nMilkInput_Callback(hObject, eventdata, handles)
% hObject    handle to nMilkInput (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of nMilkInput as text
%        str2double(get(hObject,'String')) returns contents of nMilkInput as a double


% --- Executes during object creation, after setting all properties.
function nMilkInput_CreateFcn(hObject, eventdata, handles)
% hObject    handle to nMilkInput (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function nDarkInput_Callback(hObject, eventdata, handles)
% hObject    handle to nDarkInput (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of nDarkInput as text
%        str2double(get(hObject,'String')) returns contents of nDarkInput as a double


% --- Executes during object creation, after setting all properties.
function nDarkInput_CreateFcn(hObject, eventdata, handles)
% hObject    handle to nDarkInput (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function nOrangeInput_Callback(hObject, eventdata, handles)
% hObject    handle to nOrangeInput (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of nOrangeInput as text
%        str2double(get(hObject,'String')) returns contents of nOrangeInput as a double


% --- Executes during object creation, after setting all properties.
function nOrangeInput_CreateFcn(hObject, eventdata, handles)
% hObject    handle to nOrangeInput (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in addChocolatesButton.
function addChocolatesButton_Callback(hObject, eventdata, handles)

try
    Data = handles.chocolates;
    flavourColoum = Data(:,4);
    selectedData = [];
    %% Milk check box
    if get(handles.selectMilk,'value')==1,
        Nstr = get(handles.nMilkInput,'string');
        if strcmp(Nstr,'all')==1,
            milkRow = find(flavourColoum==1);
            selectedData = [selectedData ; Data(milkRow,:)];                  
        else
            N = uint16(str2double(Nstr));
            milkRow = find(flavourColoum==1);
            selectedData = [selectedData ; Data(milkRow(1:N),:)];
        end
    end    
    %% Dark check box
    if get(handles.selectDark,'value')==1,
        Nstr = get(handles.nDarkInput,'string');
        darkRow = find(flavourColoum==2);
        if strcmp(Nstr,'all')==1,
            selectedData = [selectedData ; Data(darkRow,:)];
        else
            N = uint16(str2double(Nstr));
            selectedData = [selectedData ; Data(darkRow(1:N),:)];
        end
    end    
    %% Orange check box
    if get(handles.selectOrange,'value')==1,
        Nstr = get(handles.nOrangeInput,'string');
        orangeRow = find(flavourColoum==3);
        if strcmp(Nstr,'all')==1,
            selectedData = [selectedData ; Data(orangeRow,:)];
        else
            N = uint16(str2double(Nstr));
            selectedData = [selectedData ; Data(orangeRow(1:N),:)];
        end
    end
    %% Mint check box
    if get(handles.selectMint,'value')==1,
        Nstr = get(handles.nMintInput,'string');
        mintRow = find(flavourColoum==4);
        if strcmp(Nstr,'all')==1,
            selectedData = [selectedData ; Data(mintRow,:)];
        else
            N = uint16(str2double(Nstr));
            selectedData = [selectedData ; Data(mintRow(1:N),:)];
        end
    end
    %% Back/Unknown check box
    if get(handles.selectBack,'value')==1,
        Nstr = get(handles.nBackInput,'string');
        backRow = find(flavourColoum==0);
        if strcmp(Nstr,'all')==1,
            selectedData = [selectedData ; Data(backRow,:)];
        else
            N = uint16(str2double(Nstr));
            selectedData = [selectedData ; Data(backRow(1:N),:)];
        end
    end
    
    %% Highlights the Selected Chocolates
    axes(handles.axesTableSelect); cla;
    set(handles.axesTableSelect,'color','none');
    for i=1:length(selectedData(:,1)),
        [Xr , Yr] = table2robot(selectedData(i,1),selectedData(i,2));
        newPickTarget = [double(Xr) , double(Yr) , handles.zTable , ...
            selectedData(i,3)];
        handles.pickTarget = [handles.pickTarget ; newPickTarget];
        
        %     set(handles.pickTargetList,'Data',handles.pickTarget);
        %     set(handles.nPickTargetShow,'string',...
        %          num2str(length(handles.pickTarget(:,1))));
        
        hold on;
        set(handles.axesTableSelect,'color','none');
        plotRectangle(selectedData(i,1) , selectedData(i,2),  -selectedData(i,3));
        hold off;
    end
    %% Added this section . NOTE RONI
    handles.pickTarget = [handles.pickTarget ; newPickTarget];
    
    newPick = handles.pickTarget(1:end-1,1:2);
    newPick(:,3) = handles.pickTarget(1:end-1,4);
    numb = size(newPick);
    oldPick = get(handles.pickTargetList,'data');
    oldPick = [oldPick;newPick];
    
    numPICK = num2str(str2num(handles.nPickTargetShow.String)+numb(1));
    handles.nPickTargetShow.String = numPICK;
    set(handles.pickTargetList,'data',oldPick );
    
    handles.pickTarget=[]; 

catch
    set(handles.editCommand,'string','NOT enough chocolate' );
end

% guidata(hObject, handles);



% --- Executes on slider movement.
function slider26_Callback(hObject, eventdata, handles)
% hObject    handle to slider26 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider


% --- Executes during object creation, after setting all properties.
function slider26_CreateFcn(hObject, eventdata, handles)
% hObject    handle to slider26 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end


% --- Executes on button press in addToPickTargetButton.
function addToPickTargetButton_Callback(hObject, eventdata, handles)
[Xr , Yr] = table2robot(handles.selectedChocolate(1),handles.selectedChocolate(2));
newPickTarget = [double(Xr) , double(Yr) , handles.zTable , ...
    handles.selectedChocolate(3)];
handles.pickTarget = [handles.pickTarget ; newPickTarget];
set(handles.pickTargetList,'Data',handles.pickTarget);
set(handles.nPickTargetShow,'string',num2str(length(handles.pickTarget(:,1))));
guidata(hObject, handles);



% --- Executes on slider movement.
function placeTargetTheta_Callback(hObject, eventdata, handles)
newTheta = get(hObject,'Value');
newTheta = newTheta*pi/180;
handles.placeTarget(handles.selectedPlace,4) = newTheta;
set(handles.placeTargetList,'Data',handles.placeTarget);
handles.placeTable(handles.selectedPlace,3)=newTheta;
axes(handles.placeTargetAxes); cla; hold on;
set(handles.placeTargetAxes,'color','none');
plotTarget(handles.placeTable); hold off;        
guidata(hObject, handles);


% --- Executes during object creation, after setting all properties.
function placeTargetTheta_CreateFcn(hObject, eventdata, handles)
% hObject    handle to placeTargetTheta (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end


% --- Executes on button press in clearPickListButton.
function clearPickListButton_Callback(hObject, eventdata, handles)
handles.pickTarget=[];
set(handles.pickTargetList,'Data',handles.pickTarget);
set(handles.nPickTargetShow,'string','0');
guidata(hObject, handles);


% --- Executes on button press in clearPlaceListButton.
function clearPlaceListButton_Callback(hObject, eventdata, handles)
handles.placeTarget=[];
set(handles.placeTargetList,'Data',handles.placeTarget);
set(handles.nPlaceTargetShow,'string','0');
guidata(hObject, handles);


% --- Executes when selected cell(s) is changed in placeTargetList.
function placeTargetList_CellSelectionCallback(hObject, eventdata, handles)
handles.selectedPlace = eventdata.Indices(1);
guidata(hObject, handles);


% --- Executes on button press in pushbutton48.
function pushbutton48_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton48 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on button press in pushbutton49.
function pushbutton49_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton49 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on button press in pushbuttonSetPICK.
function pushbuttonSetPICK_Callback(hObject, eventdata, handles)

% if handles.chocolates(:,5)==1
    newPick = str2num(get(handles.textCurrentSelect,'string'));
    oldPick = get(handles.pickTargetList,'data');
    set(handles.pickTargetList,'data',oldPick );
    oldPick = [oldPick;newPick];

    numPICK = num2str(str2num(handles.nPickTargetShow.String)+1);
    handles.nPickTargetShow.String = numPICK;

    set(handles.pickTargetList,'data',oldPick );
    
% else     
%     errordlg('Unreachable Chocolate. Select again'); 
% end

guidata(hObject, handles);



% --- Executes on button press in pushbuttonSetPLACE.
function pushbuttonSetPLACE_Callback(hObject, eventdata, handles)


newPick = str2num(get(handles.textCurrentSelect,'string'));
oldPick = get(handles.placeTargetList,'data');
set(handles.placeTargetList,'data',oldPick );
oldPick = [oldPick;newPick];

numPLACE = num2str(str2num(handles.nPlaceTargetShow.String)+1);
handles.nPlaceTargetShow.String = numPLACE;

set(handles.placeTargetList,'data',oldPick );


guidata(hObject, handles);


% --- Keyboard shortcuts
function figure1_KeyPressFcn(hObject, eventdata, handles)
keyB = eventdata.Key % Let's display the key, for fun!
switch keyB
    case '1'
        pushbuttonSetPICK_Callback(hObject, eventdata, handles);
    case '2'
        pushbuttonSetPLACE_Callback(hObject, eventdata, handles);
    case 'space'
        GetC_Coordinate_Callback(hObject, eventdata, handles);
%     case 't'
    case 'escape'
        switch get(handles.runButton,'String')
            case 'RESUME'
                set(handles.runButton,'String','RUN');
                stop(handles.timerRunRobot);
%                 cancel_func;
                sender('S3');
                pause(0.6);
                TOio(0,0,0,0,300);
        end
        
end


% --- Executes on slider movement.
function sliderThetaClick_Callback(hObject, eventdata, handles)
sliderValue = num2str( get(handles.sliderThetaClick,'Value') );
set(handles.editThetaClick,'String', sliderValue);


% --- Executes during object creation, after setting all properties.
function sliderThetaClick_CreateFcn(hObject, eventdata, handles)
% hObject    handle to sliderThetaClick (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end



function editThetaClick_Callback(hObject, eventdata, handles)
textValue = str2num( get(handles.editThetaClick,'String') );
if isempty(textValue) || length(textValue)~=1
    textValue = 0;
    set(handles.editThetaClick,'String', num2str(textValue));
    set(handles.editCommand,'String','Please fill only a single numeric value');
end
if textValue<pi && textValue>-pi
    set(handles.sliderThetaClick,'Value',textValue);
elseif textValue>0
    textValue = 3.141; 
    set(handles.editThetaClick,'String', num2str(textValue));
    set(handles.sliderThetaClick,'Value',textValue);
elseif textValue<0
    textValue = -3.141;
    set(handles.editThetaClick,'String', num2str(textValue));
    set(handles.sliderThetaClick,'Value',textValue);
end

set(Manual.listSaveButton,'enable','off');

    
    

% --- Executes during object creation, after setting all properties.
function editThetaClick_CreateFcn(hObject, eventdata, handles)
% hObject    handle to editThetaClick (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function editCustom_Callback(hObject, eventdata, handles)
textValue = str2num( get(handles.editCustom,'String') );
thet = get(handles.editThetaClick,'String');
if isempty(textValue) || length(textValue)~=2
    textValue = [0  0];
    set(handles.textCurrentSelect,'String', [num2str(textValue) '   ' thet]);
    set(handles.editCustom,'String', [num2str(textValue) '   ' thet]);
    set(handles.editCommand,'String', 'Please fill only a 1X2 numeric value');
end
set(handles.textCurrentSelect,'string', [num2str(textValue) '   ' thet]);







% --- Executes during object creation, after setting all properties.
function editCustom_CreateFcn(hObject, eventdata, handles)
% hObject    handle to editCustom (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in pushbutton55.
function pushbutton55_Callback(hObject, eventdata, handles)
% % % pushbuttonDetectBox_Callback(hObject, eventdata, handles);
% % % findChocolatesButton_Callback(hObject, eventdata, handles);
% % % % handles.b(1,3);
% % % % handles.chocolates
% % % % handles.box{1}.xy(1,1
% % % try
% % %     for i =1:100
% % %         temp(:,1:3) = handles.chocolates(:,1:3);
% % %         set(handles.pickTargetList,'string',num2str(temp));       
% % %     end
% % % catch
% % % end
try
    imgConv=getsnapshot(handles.vid2);      % capture image from video 2 (conveyor camera)
catch
    imgConv=imread('converyor4.jpg');
end
axes(handles.axesConvCam);
image(imgConv);
set(handles.axesConvCam,'xtick',[],'ytick',[]);
axes(handles.axesConvDetect);hold on;
[handles.b ,handles.box]=plotBoxConv(imgConv); hold off; % detect box
set(handles.axesConvDetect,'color','none'); 
set(handles.axesConvDetect,'xtick',[],'ytick',[]);
set(handles.uitableBox, 'data', handles.b(:,3));
set(handles.editCommand, 'String', 'Done Boxes Detection');

try 
    imgTable=getsnapshot(handles.vid1);     % capture image from video 1 (Table camera)
    set(handles.editCommand, 'string', 'Snaphot from Table Camera');
catch
    imgTable=imread('IMG_005.jpg');
    set(handles.editCommand, 'string', 'Saved Image');
end
axes(handles.TableCam);
image(imgTable);
set(handles.TableCam,'xtick',[],'ytick',[]);       % Supress the axes3 axis value
axes(handles.axes3);cla;
set(handles.axes3,'color','none');
c = findChoc((imgTable));   % HERE THE CHOC DETECTION
handles.chocolates =c(:,[1:3 6 8]);
[n,~]=size(c);

%get box coordinate
box=handles.b(1,3);
handles.placeTarget = [handles.box{1}.xy(1,1),handles.box{1}.xy(1,2),box];
% axes(handles.axesConvSelect);
%  plot(handles.box{1}.rec{1}(1,:),...
%         handles.box{1}.rec{1}(2,:), 'k');
%     set(handles.axesConvSelect, 'Xlim', [0,640], 'YLim', [0 480]...
%         ,'color','none' ,'xtick',[],'ytick',[]);
%     
for i=1:n %loop until detected chocolate
if handles.chocolates(:,5)==1 %if reachable
    %pick function
    pushbuttonSetPICK_Callback(hObject, eventdata, handles)

    %place function
    pushbuttonSetPLACE_Callback(hObject, eventdata, handles)
    %run fuction
    runButton_Callback(hObject, eventdata, handles)
end

    if c(:,6)==0
        %flip function
    end
    i=i+1;
end



% --- Executes when entered data in editable cell(s) in uitableBox.
function uitableBox_CellEditCallback(hObject, eventdata, handles)
% hObject    handle to uitableBox (see GCBO)
% eventdata  structure with the following fields (see MATLAB.UI.CONTROL.TABLE)
%	Indices: row and column indices of the cell(s) edited
%	PreviousData: previous data for the cell(s) edited
%	EditData: string(s) entered by the user
%	NewData: EditData or its converted form set on the Data property. Empty if Data was not changed
%	Error: error string when failed to convert EditData to appropriate value for Data
% handles    structure with handles and user data (see GUIDATA)


% --- Executes when entered data in editable cell(s) in pickTargetList.
function pickTargetList_CellEditCallback(hObject, eventdata, handles)
% hObject    handle to pickTargetList (see GCBO)
% eventdata  structure with the following fields (see MATLAB.UI.CONTROL.TABLE)
%	Indices: row and column indices of the cell(s) edited
%	PreviousData: previous data for the cell(s) edited
%	EditData: string(s) entered by the user
%	NewData: EditData or its converted form set on the Data property. Empty if Data was not changed
%	Error: error string when failed to convert EditData to appropriate value for Data
% handles    structure with handles and user data (see GUIDATA)


% --- Executes during object creation, after setting all properties.
function placeTargetAxes_CreateFcn(hObject, eventdata, handles)
% hObject    handle to placeTargetAxes (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: place code in OpeningFcn to populate placeTargetAxes


% --- Executes on selection change in autoMode.
function autoMode_Callback(hObject, eventdata, handles)
p = eventdata.Source.String(eventdata.Source.Value,:);
% Set the mode onto the push button
set(handles.pushbuttonAuto,'String',p);


% --- Executes during object creation, after setting all properties.
function autoMode_CreateFcn(hObject, eventdata, handles)
% hObject    handle to autoMode (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: listbox controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in pushbuttonAuto.
function pushbuttonAuto_Callback(hObject, eventdata, handles)
p = get(handles.pushbuttonAuto,'String');
try
    switch p{1}
        case 'LOAD'
            autoLoad(hObject, eventdata, handles);
        case 'UNLOAD'
            autoUnload(hObject, eventdata, handles);
        case 'STACK all'
            autoStack(hObject, eventdata, handles);
        case 'STACK 1'
            autoStack1(hObject, eventdata, handles);    
        case 'Choose'
            set(handles.editCommand,'String','Please select a Mode');
    end
catch
end
set(handles.pushbuttonAuto,'String','Choose');
guidata(hObject, handles);

%% Auto Stacking ALL
function autoStack(hObject, eventdata, handles)
% clearing the PICK and PLACE table
clearPickListButton_Callback(hObject, eventdata, handles);
clearPlaceListButton_Callback(hObject, eventdata, handles);
% donkey
try 
    imgTable=getsnapshot(handles.vid1);     % capture image from video 1 (Table camera)
    set(handles.editCommand, 'string', 'Snaphot from Table Camera');
catch
    imgTable=imread('IMG_011.jpg');
    set(handles.editCommand, 'string', 'Saved Image');
end
drawnow;
[c]= findChocNoPlot(imgTable); %[Xr, Yr, theta, Realflavi,reachable(Xr,Yr)];
% c = unique(c,'rows');

% Set the PLACEs, milk;dark;orange;mint
placePose = [200, 100, 0;...
             200, 200, 0;...
             200, 300, 0;...
             200, 400, 0];
n2pick = 0;
for i = 4:-1:1
    idFlav  = find(c(:,4)==i);
    idReach = find(c(:,5)==1);
    idGood  = intersect(idFlav,idReach);
    
    k = size(idGood);
    k = k(1,1);
    if k~=0
        toPick(n2pick+1:n2pick+k,1:3)  = c(idGood,1:3);
        for j = 1:k    
            toPlace(n2pick+j,1:3) =  placePose(i,:);
        end    
        n2pick = n2pick + k;
    end          
end

set(handles.pickTargetList,'data',toPick);
set(handles.placeTargetList,'data',toPick);

set(handles.nPickTargetShow,'string',num2str(n2pick));
set(handles.nPlaceTargetShow,'string',num2str(n2pick));

disp(c);
runButton_Callback(hObject, eventdata, handles)
disp('DONE');
guidata(hObject, handles);


%% Auto Stacking ONLY 1 of each
function autoStack1(hObject, eventdata, handles);
set(handles.editCommand,'String','Stacking one of each flavour'); drawnow;
% Clearing the PICK n PLACE table
clearPickListButton_Callback(hObject, eventdata, handles);
findChocolatesButton_Callback(hObject, eventdata, handles);
% Set the PICKs
set(handles.selectMilk,'value',1);
set(handles.selectDark,'value',1); 
set(handles.selectOrange,'value',1);
set(handles.selectMint,'value',1);
set(handles.selectBack,'value',0); 

set(handles.nMilkInput,'string','1');
set(handles.nDarkInput,'string','1');
set(handles.nOrangeInput,'string','1');
set(handles.nMintInput,'string','1');

addChocolatesButton_Callback(hObject, eventdata, handles);

% Set the PLACEs, milk;dark;orange;mint
placePose = [200, 100, 0;...
             200, 200, 0;...
             200, 300, 0;...
             200, 400, 0];
set(handles.placeTargetList,'data',placePose);
set(handles.nPlaceTargetShow,'string',...
    get(handles.nPickTargetShow,'String'));
% Run 
runButton_Callback(hObject, eventdata, handles);
guidata(hObject, handles);





%% Auto Load Function
function autoLoad(hObject, eventdata, handles)
%function autoLoad(handles)
% Set the PICKs
set(handles.editCommand,'String','AutoLoading'); drawnow;
clearPickListButton_Callback(hObject, eventdata, handles)
findChocolatesButton_Callback(hObject, eventdata, handles);
handles.chocolates= getappdata(hObject.Parent,'chocolatesData');
setappdata(hObject.Parent,'chocolatesData',handles.chocolates);
disp(handles.chocolates)
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%
%Convert into robot coordinate
Xt = handles.chocolates(:,1);
Yt = handles.chocolates(:,2);
theta = handles.chocolates(:,3);
[Xr,Yr] = table2robot(Xt,Yt);
newData = [Xr Yr theta];
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%
%set(handles.pickTargetList,'data',handles.ChocTable.Data(:,1:3));
set(handles.pickTargetList,'data',newData);
Sc = size(newData);
% Set The PLACEs
set(handles.nPickTargetShow,'string',num2str(Sc(1,1)));
pushbuttonDetectBox_Callback(hObject, eventdata, handles);
% Run 
runButton_Callback(hObject, eventdata, handles);
disp(handles.chocolates)
guidata(hObject, handles);


% --- Executes on selection change in listboxPredefined.
function listboxPredefined_Callback(hObject, eventdata, handles)
% p = eventdata.Source.String(eventdata.Source.Value,:);
p = eventdata.Source.Value;
switch p
    case 1
        location = '227   0';
    case 2
        location = '0   409';
    case 3
        location = '200 100';        
end

set(handles.textCurrentSelect,'String',location);

% --- Executes during object creation, after setting all properties.
function listboxPredefined_CreateFcn(hObject, eventdata, handles)
% hObject    handle to listboxPredefined (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: listbox controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end











% % --- Executes on button press in clearPlaceListButton.
% function clearPlaceListButton_Callback(hObject, eventdata, handles)
% % hObject    handle to clearPlaceListButton (see GCBO)
% % eventdata  reserved - to be defined in a future version of MATLAB
% % handles    structure with handles and user data (see GUIDATA)
% 
% 
% % --- Executes on button press in addToPickTargetButton.
% function addToPickTargetButton_Callback(hObject, eventdata, handles)
% % hObject    handle to addToPickTargetButton (see GCBO)
% % eventdata  reserved - to be defined in a future version of MATLAB
% % handles    structure with handles and user data (see GUIDATA)
% 
% 
% % --- Executes on button press in findChocolatesButton.
% function findChocolatesButton_Callback(hObject, eventdata, handles)
% % hObject    handle to findChocolatesButton (see GCBO)
% % eventdata  reserved - to be defined in a future version of MATLAB
% % handles    structure with handles and user data (see GUIDATA)
% 
% 
% % --- Executes on button press in addChocolatesButton.
% function addChocolatesButton_Callback(hObject, eventdata, handles)
% % hObject    handle to addChocolatesButton (see GCBO)
% % eventdata  reserved - to be defined in a future version of MATLAB
% % handles    structure with handles and user data (see GUIDATA)


% --- Executes when entered data in editable cell(s) in ChocTable.
function ChocTable_CellEditCallback(hObject, eventdata, handles)
% hObject    handle to ChocTable (see GCBO)
% eventdata  structure with the following fields (see MATLAB.UI.CONTROL.TABLE)
%	Indices: row and column indices of the cell(s) edited
%	PreviousData: previous data for the cell(s) edited
%	EditData: string(s) entered by the user
%	NewData: EditData or its converted form set on the Data property. Empty if Data was not changed
%	Error: error string when failed to convert EditData to appropriate value for Data
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on button press in pushbuttoCancel.
function pushbuttoCancel_Callback(hObject, eventdata, handles)
set(handles.runButton,'String','RUN');
stop(handles.timerRunRobot);
sender('S3');
pause(0.6);
sender('S2');
TOio(0,0,0,0,300);
