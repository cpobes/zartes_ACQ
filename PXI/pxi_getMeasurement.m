function Result=pxi_getMeasurement(pxi,ChList,MeasureType)
%%%%Función para devolver el resultado de una medida
%%%Funciones: NISCOPE_VAL_VOLTAGE_BASE

%invoke(pxi.configurationfunctionsvertical,'configurevertical',ChannelList,Range,offset,Coupling,ProbeAttenuation,Enabled)
%function [Result] = readmeasurement(obj, ChannelList, Timeout, ScalarMeasFunction, Result)
Result=0;
invoke(pxi.Measurement,'readmeasurement',ChList,5,MeasureType,Result);

%%%%Available Measurements:
%       printf("Available Measurements:\n");
%       printf("1 - Frequency\n");
%       printf("2 - Average Frequency\n");
%       printf("3 - FFT Frequency\n");
%       printf("4 - Period\n");
%       printf("5 - Average Period\n");
%       printf("6 - Rise Time\n");
%       printf("7 - Fall Time\n");
%       printf("8 - Rising Slew Rate\n");
%       printf("9 - Falling Slew Rate\n");
%       printf("10 - Overshoot\n");
%       printf("11 - Preshoot\n");
%       printf("12 - Voltage RMS\n");
%       printf("13 - Voltage Cycle RMS\n");
%       printf("14 - AC Estimate\n");
%       printf("15 - FFT Amplitude\n");
%       printf("16 - Voltage Average\n");
%       printf("17 - Voltage Cycle Average\n");
%       printf("18 - DC Estimate\n");
%       printf("19 - Voltage Max\n");
%       printf("20 - Voltage Min\n");
%       printf("21 - Voltage Peak-to-Peak\n");
%       printf("22 - Voltage High\n");
%       printf("23 - Voltage Low\n");
%       printf("24 - Voltage Amplitude\n");
%       printf("25 - Voltage Top\n");
%       printf("26 - Voltage Base\n");
%       printf("27 - Voltage Base-to-Top\n");
%       printf("28 - Negative Width\n");
%       printf("29 - Positive Width\n");
%       printf("30 - Negative Duty Cycle\n");
%       printf("31 - Positive Duty Cycle\n");
%       printf("32 - Integral\n");
%       printf("33 - Area\n");
%       printf("34 - Cycle Area\n");
%       printf("35 - Time Delay\n");
%       printf("36 - Phase Delay\n");
%       printf("37 - Low Ref Volts\n");
%       printf("38 - Mid Ref Volts\n");
%       printf("39 - High Ref Volts\n");
%       printf("40 - Volt. Hist. Mean\n");
%       printf("41 - Volt. Hist. Stdev\n");
%       printf("42 - Volt. Hist. Median\n");
%       printf("43 - Volt. Hist. Mode\n");
%       printf("44 - Volt. Hist. Max\n");
%       printf("45 - Volt. Hist. Min\n");
%       printf("46 - Volt. Hist. Peak-to-Peak\n");
%       printf("47 - Volt. Hist. Mean + Stdev\n");
%       printf("48 - Volt. Hist. Mean + 2 Stdev\n");
%       printf("49 - Volt. Hist. Mean + 3 Stdev\n");
%       printf("50 - Volt. Hist. Hits\n");
%       printf("51 - Volt. Hist. New Hits\n");
%       printf("52 - Time Hist. Mean\n");
%       printf("53 - Time Hist. Stdev\n");
%       printf("54 - Time Hist. Median\n");
%       printf("55 - Time Hist. Mode\n");
%       printf("56 - Time Hist. Max\n");
%       printf("57 - Time Hist. Min\n");
%       printf("58 - Time Hist. Peak-to-Peak\n");
%       printf("59 - Time Hist. Mean + Stdev\n");
%       printf("60 - Time Hist. Mean + 2 Stdev\n");
%       printf("61 - Time Hist. Mean + 3 Stdev\n");
%       printf("62 - Time Hist. Hits\n");
%       printf("63 - Time Hist. New Hits\n\n");
