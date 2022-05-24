function BFdumpHistoricalData(fstart,fstop)
%%%función para devolver los datos históricos de MC entre fechas
%%%formato fecha: yyyy-mm-ddThh:mm:ssZ
url='ws://192.168.2.121:5002/channel/historical-data';
ws=SimpleClient(url);
message=['{"channel_nr":6,"start_time":','"',fstart,'",','"stop_time":','"',fstop,'",','"fields":["temperature"]}']
diary 'MCdata.log'
ws.send(message);
diary off
ws.close();
urlH='ws://192.168.2.121:5002/heater/historical-data';
messH=['{"heater_nr":6,"start_time":','"',fstart,'",','"stop_time":','"',fstop,'",','"fields":["power"]}']
diary 'Hdata.log'
ws.send(messH);
diary off
ws.close();