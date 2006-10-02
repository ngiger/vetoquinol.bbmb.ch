function bc_read(bc_comport, bc_noconnection, bc_nocode)
{
  dojo.debug('jusqu\'ici tout va bien');
  var data = new Array();
  var BCReader = dojo.byId('BCReader');
  data['fail'] = bc_noconnection;
  data['nocd'] = bc_nocode;

  dojo.debug(data);

  if(!BCReader)
  {
    alert(data['fail']);
    return false;
  }
  if(bc_comport.value < 0)
  {
    return bc_select_and_try(bc_comport, data);
  }
  else
  {
    return bc_try_or_select(bc_comport, data);
  }
}

function bc_select_and_try(bc_comport, data)
{
  var port_selected;
  port_selected = BCReader.SelectCom();
  if(port_selected < 0) 
    return false;
  else
    bc_comport.value = port_selected;
  if(bc_try(bc_comport, data))
  {
    return true;
  }
  else
  {
    alert(data['fail'])
    return false;
  }
}

function bc_try_or_select(bc_comport, data)
{
  return bc_try(bc_comport, data) || bc_select_and_try(bc_comport, data);
}

function bc_try(bc_comport, data)
{
  var numCodes = -1;
  BCReader.SetCom(bc_comport.value)
  if(!BCReader.Init()) 
  {  
    bc_comport.value = -1;
    return false;
  }
  else
  {
    numCodes = BCReader.Read();
  }
  if(numCodes < 0)
  {
    BCReader.Exit();
    bc_comport.value = -1;
    return false;
  }
  else if(numCodes == 0)
  {
    BCReader.Exit();
    alert(data['nocd']);
    return true;
  }
  else
  {
    var form = document.createElement( "form" );
    form.method = 'POST';
    form.action = '/index.rbx'; 

    var BarCodes = new Array();
    BarCodes["comport"] =  bc_comport.value;
    BarCodes["event"] = 'scan';
    dojo.debug(BarCodes);
    while(success = BCReader.Next())
    {
      fname = BCReader.GetCodeType()+"["+BCReader.GetBarCode()+"]";;
      if(BarCodes[fname] == null)
      {
        BarCodes[fname]=1;
      }
      else
      {
        BarCodes[fname]++;
      }
    }
    dojo.debug(BarCodes);
    BCReader.Exit();
    
    for(fname in BarCodes)
    {
      var input = document.createElement( "input" );
      input.name = fname;
      input.value = BarCodes[fname];
      form.appendChild(input);
    }

    dojo.io.bind({
      formNode: form,
      load: function(type, data, evt) {
        if(data['success']) {
          bc_clear();
        }
        document.location.reload();
      },
      mimetype: "text/json"
    });
    
  }
  return true;
}

function bc_clear()
{
  if(BCReader.Init())
  {
    BCReader.Clear();
    BCReader.Exit();
  }
}
