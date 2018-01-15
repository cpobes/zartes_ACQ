classdef LOGClass
    properties
        String = '';
        Value = '';
    end
    
    methods (Static)
        function openVisibleNew(hObject, eventdata, handles)
            % Choose default command line output for modelIV
            handles.output = hObject;
            
            set(handles.compareHeader,'Visible','on');
            set(handles.compareSelection,'Visible','on');
            set(handles.parameterlist2,'Visible','on');
            set(handles.parameterlist3,'Visible','on');
            set(handles.compareSelection,'Value',1);
            set(handles.parameterlist2,'Value',1);
            set(handles.parameterlist3,'Value',1);
            set(handles.parameterlist2,'Enable','off');
            set(handles.parameterlist3,'Enable','off');
            set(handles.parameterlistcolor,'Visible','on');
            
            % Update handles structure
            guidata(hObject, handles);
        end
        
        function closeVisibleNew(hObject, eventdata, handles)
            % Choose default command line output for modelIV
            handles.output = hObject;
            
            set(handles.graph2,'Visible','off');
            set(handles.graph3,'Visible','off');
            set(handles.compareHeader,'Visible','off');
            set(handles.compareSelection,'Visible','off');
            set(handles.parameterlist2,'Visible','off');
            set(handles.parameterlist3,'Visible','off');
            set(handles.parameterlistcolor,'Visible','off');
            set(handles.parameterlist2color,'Visible','off');
            set(handles.parameterlist3color,'Visible','off');
            
            % Update handles structure
            guidata(hObject, handles);
        end
        
        function enableAxes2(hObject, eventdata, handles)
            % Choose default command line output for modelIV
            handles.output = hObject;
            
            ylabel(handles.graph1,'');
            set(handles.graph1,'YColor','k');
            
            set(handles.parameterlist2color,'Visible','off');
            set(handles.parameterlist3color,'Visible','on');
            
            graph1newPOS = [0.09278350515463918, 0.055652173913043515, 0.7507029053420806, 0.8382608695652175];
            set(handles.graph1,'Position',graph1newPOS);
            
            set(handles.graph2,'Visible','off');
            set(handles.parameterlist2,'Enable','off');
            set(handles.graph3,'Visible','on');
            set(handles.parameterlist3,'Enable','on');
            
            graph3POS = get(handles.graph3,'Position');
            scale13 = graph3POS(3)/graph1newPOS(3);
            graph1XLim = get(handles.graph1,'XLim');
            graph3XLim = [graph1XLim(2)-scale13*(graph1XLim(2)-graph1XLim(1)) graph1XLim(2)];
            
            set(handles.graph3,'XLim',graph3XLim);
            set(handles.graph3,'Color','none');
            set(handles.graph3,'XColor',get(handles.LOG,'Color'));
            set(handles.graph3,'YColor','k');
            set(handles.graph3,'XTick',[]);
            set(handles.graph3,'XTickLabel',[]);
            
            % Update handles structure
            guidata(hObject, handles);
        end
        
        function disableAxes2(hObject, eventdata, handles)
            % Choose default command line output for modelIV
            handles.output = hObject;
            
            set(handles.graph1,'YColor','k');
            
            set(handles.parameterlist2color,'Visible','off');
            set(handles.parameterlist3color,'Visible','off');
            
            graph1oldPOS = [0.06654170571696343, 0.055652173913043515, 0.7769447047797562, 0.8382608695652175];
            set(handles.graph1,'Position',graph1oldPOS);
            
            set(handles.graph3,'Visible','off');
            set(handles.parameterlist3,'Enable','off');
            
            % Update handles structure
            guidata(hObject, handles);
        end
        
        function enableAxes3(hObject, eventdata, handles)
            % Choose default command line output for modelIV
            handles.output = hObject;
            
            ylabel(handles.graph1,'');
            set(handles.graph1,'YColor','k');
            
            set(handles.parameterlist2color,'Visible','on');
            set(handles.parameterlist3color,'Visible','on');
            
            graph1newPOS = [0.13964386129334583, 0.055652173913043515, 0.703842549203374, 0.8382608695652175];
            set(handles.graph1,'Position',graph1newPOS);
            
            set(handles.graph2,'Visible','on');
            set(handles.graph3,'Visible','on');
            set(handles.parameterlist2,'Enable','on');
            set(handles.parameterlist3,'Enable','on');
            
            graph2POS = get(handles.graph2,'Position');
            scale12 = graph2POS(3)/graph1newPOS(3);
            graph1XLim = get(handles.graph1,'XLim');
            graph2XLim = [graph1XLim(2)-scale12*(graph1XLim(2)-graph1XLim(1)) graph1XLim(2)];
            
            set(handles.graph2,'XLim',graph2XLim);
            set(handles.graph2,'Color','none');
            set(handles.graph2,'XColor',get(handles.LOG,'Color'));
            set(handles.graph2,'YColor','k');
            set(handles.graph2,'XTick',[]);
            set(handles.graph2,'XTickLabel',[]);
            
            graph3POS = get(handles.graph3,'Position');
            scale13 = graph3POS(3)/graph1newPOS(3);
            graph1XLim = get(handles.graph1,'XLim');
            graph3XLim = [graph1XLim(2)-scale13*(graph1XLim(2)-graph1XLim(1)) graph1XLim(2)];
            
            set(handles.graph3,'XLim',graph3XLim);
            set(handles.graph3,'Color','none');
            set(handles.graph3,'XColor',get(handles.LOG,'Color'));
            set(handles.graph3,'YColor','k');
            set(handles.graph3,'XTick',[]);
            set(handles.graph3,'XTickLabel',[]);
            
            % Update handles structure
            guidata(hObject, handles);
        end
        
        function disableAxes3(hObject, eventdata, handles)
            % Choose default command line output for modelIV
            handles.output = hObject;
            
            set(handles.graph1,'YColor','k');
            
            set(handles.parameterlist2color,'Visible','off');
            set(handles.parameterlist3color,'Visible','off');
            
            graph1oldPOS = [0.06654170571696343, 0.055652173913043515, 0.7769447047797562, 0.8382608695652175];
            set(handles.graph1,'Position',graph1oldPOS);
            
            set(handles.graph2,'Visible','off');
            set(handles.graph3,'Visible','off');
            set(handles.parameterlist2,'Enable','off');
            set(handles.parameterlist3,'Enable','off');
            
            % Update handles structure
            guidata(hObject, handles);
        end
        
        function draw2nd(hObject, eventdata, handles)
            % Choose default command line output for modelIV
%             handles.output = hObject;
            
            set(handles.graph1,'Color','none');
            
            parameterSelect = get(handles.parameterlist3,'Value');
            
            data = evalin('base','dataTemp');
            timeAxis = evalin('base','timeAxis');
            dataPlot = cell2mat(data(:,parameterSelect+2));
            
            set(handles.plot3,'XData',timeAxis,'YData',dataPlot);
            axis(handles.graph3,'auto y');
            % Update handles structure
%             guidata(hObject, handles);
        end        
        
        function draw3rd(hObject, eventdata, handles)
            % Choose default command line output for modelIV
%             handles.output = hObject;
            
            set(handles.graph1,'Color','none');
            
            parameterSelect = get(handles.parameterlist2,'Value');
            
            data = evalin('base','dataTemp');
            timeAxis = evalin('base','timeAxis');
            dataPlot = cell2mat(data(:,parameterSelect+2));
            
            set(handles.plot2,'XData',timeAxis,'YData',dataPlot);
            axis(handles.graph2,'auto y');
            % Update handles structure
%             guidata(hObject, handles);
        end
        
    end
end
