uses System, System.Net, System.IO, System.Xml, Newtonsoft.Json, crt, IniFile;

begin
  crt.SetWindowSize(55, 19); //Set console size
  crt.SetBufferSize(55, 19); //Set console buffer
  crt.HideCursor;
  while true
    do 
    try
      begin
        var ini := TIniFile.Create('Config.ini').ReadString('MAIN', 'IP', ''); //Check bad config
        if ini in ['', 'http:\\address:port'] then 
        begin
          TextColor(LightRed);
          Writeln('Error! Invalid config data! Shutdown app and edit config.');
          Sleep(2000);
          ClrScr;
        end
        else
        begin
          var req := System.Net.WebRequest.CreateHttp(ini + '/2/summary');
          req.Method := 'GET';
          req.Timeout := 1000;
          var res := req.GetResponse.GetResponseStream;
          var stre := new StreamReader(res);
          var xml := JsonConvert.DeserializeXNode(stre.ReadToEnd, 'Main');
          var xmar := new XmlDocument;
          xmar.LoadXml(xml.ToString);
          TextColor(LightGreen);
          Writeln('                   Hello ' + xmar.GetElementsByTagName('worker_id')[0].InnerText + '!                '); //Write mining data
          TextColor(LightGray);
          Writeln('                     Miner info                  ');
          Writeln('Version of Xmrig: ' + xmar.GetElementsByTagName('version')[0].InnerText + NewLine);
          Writeln('                     CPU Info                     ');
          Writeln('Model: ' + xmar.GetElementsByTagName('brand')[0].InnerText);
          Writeln('Threads: ' + xmar.GetElementsByTagName('threads')[0].InnerText);
          Writeln('                     GPU Info                    ');
          var rq := System.Net.WebRequest.CreateHttp(ini + '/2/backends');
          rq.Method := 'GET';
          rq.Timeout := 1000;
          var rs := rq.GetResponse.GetResponseStream;
          var strrdr := new StreamReader(rs);
          var wrappedDocument := string.Format('{{ Backends: {0} }}', strrdr.ReadToEnd);
          var xdoc := JsonConvert.DeserializeXmlNode(wrappedDocument, 'Backends');
          Writeln('Name: ' + xdoc.GetElementsByTagName('name')[0].InnerText);
          Writeln('Fan Speed: ' + xdoc.GetElementsByTagName('fan_speed')[0].InnerText);
          if xdoc.GetElementsByTagName('temperature')[0].InnerText.ToInteger > 60 then
          begin
            Write('Temperature: ');
            TextColor(LightRed);
            Writeln(xdoc.GetElementsByTagName('temperature')[0].InnerText);
            TextColor(LightGray);
          end
          else
          begin
            Write('Temperature: ');
            TextColor(LightGreen);
            Writeln(xdoc.GetElementsByTagName('temperature')[0].InnerText);
            TextColor(LightGray);
          end;
          Writeln('                    Mining Info                     ');
          Writeln('Algo: ' + xdoc.GetElementsByTagName('algo')[0].InnerText);
          Writeln('Shares Accepted: ' + xmar.GetElementsByTagName('accepted')[0].InnerText);
          Writeln('Shares Rejected: ' + xmar.GetElementsByTagName('rejected')[0].InnerText);
          Writeln('Shares Total: ' + xmar.GetElementsByTagName('shares_total')[0].InnerText);
          Writeln('Hashrate (10s/60s/15m): ' + xmar.GetElementsByTagName('total')[1].InnerText + '/' + xmar.GetElementsByTagName('total')[2].InnerText + '/' + xmar.GetElementsByTagName('total')[3].InnerText); 
          Writeln('Highest hashrate: ' + xmar.GetElementsByTagName('highest')[0].InnerText);
          if xmar.GetElementsByTagName('ping')[0].InnerText.ToInteger > 1000 then
          begin
            Write('Pool Ping: ' + xmar.GetElementsByTagName('ping')[0].InnerText + ' - ');
            TextColor(LightRed);  
            Write('Bad Ping');
            TextColor(LightGray);
          end
          else
          begin
            Write('Pool Ping: ' + xmar.GetElementsByTagName('ping')[0].InnerText + ' - ');
            TextColor(Green);  
            Writeln('Good Ping');
            TextColor(LightGray);
          end;
          Sleep(5000);
          ClrScr;
        end;
      end;
    
    
    
    except
      on ex: WebException do
      begin
        TextColor(LightRed);
        Writeln('Error! No API Access! Trying again...');
        Sleep(2000);
        TextColor(LightGray);
        ClrScr;
      end;
    end;
end.