uses System, System.Xml, crt, IniFile;

begin
  crt.SetWindowSize(55, 20); //Set console size
  crt.SetBufferSize(55, 20); //Set console buffer
  crt.HideCursor;
  while true 
    do 
    try
      begin
        var ini := TIniFile.Create('Config.ini').ReadString('MAIN', 'IP', ''); //Check bad config
        if ini in ['', 'address:port'] then 
        begin
          TextColor(LightRed);
          Writeln('Error! Invalid config data! Shutdown app and edit config.');
          Sleep(2000);
          ClrScr;
        end
        else
        begin
          var req := System.Net.HttpWebRequest.CreateHttp(ini); //Create web request
          req.Timeout:= 1000;
          var res := req.GetResponse;
          var reststr := res.GetResponseStream;
          var strread := new System.IO.StreamReader(reststr); // Get data
          var xml := Newtonsoft.Json.JsonConvert.DeserializeXNode(strread.ReadToEnd, 'Main'); //Convert data to xml
          var xmar := new System.Xml.XmlDocument;
          xmar.LoadXml(xml.ToString);
          TextColor(LightGreen);
          Writeln('          Hello ' + xmar.GetElementsByTagName('worker_id')[0].InnerText + '!          ' + NewLine);
          TextColor(LightGray);
          Writeln('          Miner info          ');
          Writeln('Version of Xmrig: ' + xmar.GetElementsByTagName('version')[0].InnerText + NewLine);
          Writeln('          CPU Configuration          ');
          Writeln('Model: ' + xmar.GetElementsByTagName('brand')[0].InnerText);
          Writeln('AES support: ' + xmar.GetElementsByTagName('aes')[0].InnerText);
          Writeln('Is x64: ' + xmar.GetElementsByTagName('x64')[0].InnerText);
          Writeln('Number of Sockets: ' + xmar.GetElementsByTagName('sockets')[0].InnerText + NewLine);
          Writeln('          Videocard Info          ');
          Writeln('Videocard Model: ' + xmar.GetElementsByTagName('kind')[0].InnerText + ' ' + xmar.GetElementsByTagName('name')[0].InnerText); // Parse data
          Writeln('Hashrate (total/highest): ' + xmar.GetElementsByTagName('total')[0].InnerText + '/' + xmar.GetElementsByTagName('highest')[0].InnerText);
          if xmar.GetElementsByTagName('temp')[0].InnerText.ToInteger > 60 then
          begin
            Write('Temperature: ');
            TextColor(Red);
            Writeln(xmar.GetElementsByTagName('temp')[0].InnerText);
            TextColor(LightGray);
          end
          else
          begin
            Write('Temperature: ');
            TextColor(Green);
            Writeln(xmar.GetElementsByTagName('temp')[0].InnerText);
            TextColor(LightGray);
          end;
          Writeln('Fan Speed: ' + xmar.GetElementsByTagName('fan')[0].InnerText);
          Writeln('Success Shares: ' + xmar.GetElementsByTagName('shares_good')[0].InnerText);
          Writeln('Total Shares: ' + xmar.GetElementsByTagName('shares_total')[0].InnerText);
         
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
            Write('Good Ping');
            TextColor(LightGray);
          end;
          Sleep(5000);
          ClrScr;
        end;
      end
    except
      on ex: Exception do
      begin
        TextColor(LightRed);
        Writeln('Error! No API Access! Trying again...');
        Sleep(2000);
        TextColor(LightGray);
        ClrScr;
      end;
    end;
end.