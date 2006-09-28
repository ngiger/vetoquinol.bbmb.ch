dojo.provide("ywesee.widget.InfoToggler");
dojo.require("dojo.widget.*");
dojo.require("dojo.lfx.html");

ywesee.widget.InfoToggler = function() {
	dojo.widget.HtmlWidget.call(this);

	this.widgetType = "InfoToggler";
	this.templatePath = dojo.uri.dojoUri("../javascript/widget/templates/InfoToggler.html");

	this.info = dojo.byId('info');

	this.message_open = '';
	this.message_close = '';
	this.status = '';

	this.toggleInfo = function() {
		if(this.status == 'open') {
			this.implode();
		}	else {
			this.explode();
		}
	}
	this.implode = function() { 
		//dojo.lfx.html.implode(this.info, this.toggler, 300);
    this.info.style.display = 'none';
		this.toggler.innerHTML = this.message_open;
		this.status = 'closed';
	}
	this.explode = function(){
		//dojo.lfx.html.explode(this.toggler, this.info, 300);
    this.info.style.display = 'block';
		this.toggler.innerHTML = this.message_close;
		this.status = 'open';
	}
	this.fillInTemplate = function(){
		this.toggleInfo();	
	}
}


dojo.inherits(ywesee.widget.InfoToggler, dojo.widget.HtmlWidget);
dojo.widget.tags.addParseTreeHandler("dojo:infotoggler");

