var doctype =  '<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN" \n\
        "http://www.w3.org/TR/1999/REC-html401-19991224/loose.dtd">';

function bc_read(bc_comport, bc_onemoment, bc_noconnection, bc_nocode, bc_language, bc_flavor)
{
	var data = new Array();
	data['wait'] = bc_onemoment;
	data['fail'] = bc_noconnection;
	data['nocd'] = bc_nocode;
	data['lang'] = bc_language;
	data['flav'] = bc_flavor;

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

		var BarCodes = {
      "comport":  bc_comport.value,
      "event":    "bcread",
      "language": data["lang"]
    };
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
		BCReader.Exit();
		
		for(fname in BarCodes)
		{
      var input = document.createElement( "input" );
      input.name = fname;
      input.value = BarCodes[fname];
      form.appendChild(input);
		}

    dojo.io.bind(
      formNode: form,
      load: document.location.reload
    );
		
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
