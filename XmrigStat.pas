uses System, System.Xml, crt, IniFile;

begin
  crt.SetWindowSize(40,8);
  crt.SetBufferSize(40,8);
  crt.HideCursor;
  while true
  do 
   try
  begin
    var ini:= TIniFile.Create('Config.ini').ReadString('MAIN', 'IP', '');
    if ini in ['','http://address:port'] then 
    begin
      TextColor(LightRed);
      Writeln('Error! Invalid config data! Shutdown app and edit config.');
      Sleep(2000);
      ClrScr;
      end
      else
        begin
    var req := System.Net.HttpWebRequest.CreateHttp(ini);
    req.Timeout:= 5000;
    var res := req.GetResponse;
    var reststr := res.GetResponseStream;
    var strread := new System.IO.StreamReader(reststr);
    var xml := Newtonsoft.Json.JsonConvert.DeserializeXNode(strread.ReadToEnd, 'Main');
    var xmar := new System.Xml.XmlDocument;
    xmar.LoadXml(xml.ToString);
    Writeln('Videocard Model: ' + xmar.GetElementsByTagName('name')[0].InnerText);
    Writeln('Version of Xmrig: ' + xmar.GetElementsByTagName('version')[0].InnerText);
    Writeln('Hashrate (total/highest): ' + xmar.GetElementsByTagName('total')[0].InnerText + '/' + xmar.GetElementsByTagName('highest')[0].InnerText);
    if xmar.GetElementsByTagName('temp')[0].InnerText.ToInteger > 60 then
    begin
      TextColor(Red);
      Writeln('Temperature: ' + xmar.GetElementsByTagName('temp')[0].InnerText);
      TextColor(LightGray);
    end
    else
   begin
   Write('Temperature: ');
   TextColor(Green);
   Writeln(xmar.GetElementsByTagName('temp')[0].InnerText);
   TextColor(crt.LightGray);
   end;
   Writeln('Fan Speed: ' + xmar.GetElementsByTagName('fan')[0].InnerText);
   Writeln('Success Shares: ' + xmar.GetElementsByTagName('shares_good')[0].InnerText);
   Writeln('Total Shares: ' + xmar.GetElementsByTagName('shares_total')[0].InnerText);
   if xmar.GetElementsByTagName('ping')[0].InnerText.ToInteger > 1000 then
     begin
     Write('Pool Ping: ' + xmar.GetElementsByTagName('ping')[0].InnerText + ' - ');
   TextColor(Red);  
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
