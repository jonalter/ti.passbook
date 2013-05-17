
var rows = [
	{
		title: "isPassLibraryAvailable",
		onClick: function(){
			Log("isPassLibraryAvailable: " + Passbook.isPassLibraryAvailable());
		}
	},
	{
		title: "Add Pass",
		onClick: function(){
			var file = Ti.Filesystem.getFile(Ti.Filesystem.resourcesDirectory, "passes", "Lollipop.pkpass");
			try {
				Passbook.addPass({
					passData: file.blob
				});
			} catch(err) {
				Log(err);
			}
		}
	},
	{
		title: "Add Bad Pass",
		onClick: function(){
			var file = Ti.Filesystem.getFile(Ti.Filesystem.resourcesDirectory, "passes", "LollipopBad.pkpass");
			try {
				Passbook.addPass({
					passData: file.blob
				});
			} catch(err) {
				Log(err);
			}
		}
	},
	{
		title: "Contains Pass",
		onClick: function(){
			var file = Ti.Filesystem.getFile(Ti.Filesystem.resourcesDirectory, "passes", "Lollipop.pkpass");
			try {
				var contains = Passbook.containsPass({
					passData: file.blob
				});
			} catch(err) {
				Log(err);
			}
			
			Log("Contains Pass: " + contains);
		}
	},
	{
		title: "Get Pass",
		onClick: function(){
			var pass = Passbook.getPass({
				passTypeIdentifier: "pass.com.appc.passkit.lollipop",
				serialNumber: "E5982H-I2"
			});	
			
			if (pass) {
				Log("Found Pass");
				Ti.API.info("============Start Pass===============");
				Ti.API.info("Pass: "+pass);
				Ti.API.info("authenticationToken: "+pass.authenticationToken);
				Ti.API.info("passTypeIdentifier: "+pass.passTypeIdentifier);
				Ti.API.info("serialNumber: "+pass.serialNumber);
				Ti.API.info("webServiceURL: "+pass.webServiceURL);
				
				Ti.API.info("localizedName: "+pass.localizedName);
				Ti.API.info("localizedDescription: "+pass.localizedDescription);
				Ti.API.info("organizationName: "+pass.organizationName);
				Ti.API.info("relevantDate: "+pass.relevantDate);
				Ti.API.info("passURL: "+pass.passURL);
				Ti.API.info("Year: "+pass.relevantDate.getFullYear());
				
				Ti.API.info("localizedValueForFieldKey: "+pass.localizedValueForFieldKey("testprop"));
				Ti.API.info("icon: "+pass.icon);
				Ti.API.info("============End Pass===============");
				
				if (pass.icon) {
					var iv = Ti.UI.createImageView({
						top: 0,
						left: 0,
						image: pass.icon
					});
					$.win.add(iv);
					iv.addEventListener("click", function() {
						$.win.remove(iv);
						iv = null;
					});
				}
			} else {
				Log("Pass Not Found");
			}
			
		}
	},
	{
		title: "Replace Pass",
		onClick: function(){
			var file = Ti.Filesystem.getFile(Ti.Filesystem.resourcesDirectory, "passes", "LollipopNewURL.pkpass");
			try {
				var success = Passbook.replacePass({
					passData: file.blob
				});	
			} catch(err) {
				Log(err);
			}
			
			Log("Replaced Pass: " + success);
		}
	},
	{
		title: "passes",
		onClick: function(){
			var passes = Passbook.passes;	
			
			Log("Passes: "+passes);
			for (var i = 0, j = passes.length; i < j; i++) {
				Log("Name of pass " + i + " is: " + passes[i].localizedName);
			}
		}
	},
	{
		title: "Show Pass",
		onClick: function(){
			var pass = Passbook.passes[0];
			
			if (!pass) {
				Log("No passes in library");
				return;
			}
			
			Passbook.showPass(pass);
			Ti.API.info("Showing Pass");
		}
	},
	{
		title: "Remove Pass",
		onClick: function(){
			var pass = Passbook.passes[0];
			if (!pass) {
				Log("No passes in library");
				return;
			}
			
			Passbook.removePass(pass);	
			Log("Pass Removed");
		}
	},
	{
		title: "Remove All Passes",
		onClick: function(){
			var passes = Passbook.passes;
			for (var i = 0, j = passes.length; i < j; i++) {
				Passbook.removePass(passes.pop());
			}
			Log("Removed all passes in library");
		}
	}
];

var Passbook = require("ti.passbook");

Passbook.addEventListener("addedpasses", function(e){
	Log("Library event: addedpasses");
	Ti.API.info("Library addedpasses event: " + JSON.stringify(e));
	var passes = e.passes;
	for (var i = 0, j = passes.length; i < j; i++) {
		Log("Added pass with serial: " + passes[i].serialNumber);
	}
});
Passbook.addEventListener("removedpasses", function(e){
	Log("Library event: removedpasses");
	Ti.API.info("Library removedpasses event: " + JSON.stringify(e));
	var passIds = e.passIds;
	for (var i = 0, j = passIds.length; i < j; i++) {
		Log("Removed pass with serial: " + passIds[i].serialNumber);
	}
});
Passbook.addEventListener("replacedpasses", function(e){
	Log("Library event: replacedpasses");
	Ti.API.info("Library replacedpasses event: " + JSON.stringify(e));
	var passes = e.passes;
	for (var i = 0, j = passes.length; i < j; i++) {
		Ti.API.info("Replaced pass with serial: " + passes[i].serialNumber);
	}
});

function Log(text) {
	$.textLog.value = text + "\n" + $.textLog.value;
	Ti.API.info(text);
}

function onRowClick(e) {  
    e.source.onClick && e.source.onClick();
}

$.tableView.data = rows;
$.win.open();

