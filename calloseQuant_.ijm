// calloseQuant ImageJ macro
// Huang et al., 2020.

Dialog.create("Analysis of PD-associated callose");
	Dialog.addChoice("Analysis to perform", newArray("Method A","Method B"));
	Dialog.addChoice("Source Data", newArray("Active Single Image","Active Image Stack","Folder of Images"));
	Dialog.addDirectory("Data Folder","");
	
	Dialog.addMessage("Method A Parameters", 10);
	Dialog.addNumber("Peak prominence", 100);
	Dialog.addNumber("Measurement radius", 4);
	// peak promionence was discussed here: https://forum.image.sc/t/new-maxima-finder-menu-in-fiji/25504/5
	
	Dialog.addMessage("-or-", 10);
	Dialog.addMessage("Method B Parameters", 10);
	Dialog.addNumber("Rolling ball radius", 30);
	Dialog.addNumber("Mean filter radius", 3);
	Dialog.addNumber("Auto Local Threshold radius", 10);
	Dialog.addString("Analyze Particles size filter", "3-100");
	Dialog.addString("Analyze Particles circularity filter", "0.5-1");
Dialog.show();

method = Dialog.getChoice();
data = Dialog.getChoice();
folder = Dialog.getString();

prominence = Dialog.getNumber();
mRadius = Dialog.getNumber();

rollingRadius = Dialog.getNumber();
meanRadius = Dialog.getNumber();
localRadius = Dialog.getNumber();
sizeFilter = Dialog.getString();
circFilter = Dialog.getString();

run("Set Measurements...", "area mean standard min integrated median display redirect=None decimal=3");

if (data=="Active Single Image") {
	applyMethod();
}  else if (data=="Active Image Stack") { 
	idStack = getImageID;
	for (i=1;i<=nSlices; i++) {
		selectImage(idStack);
		run("Duplicate...","title=Slice_"+i+"_"+getTitle());
		applyMethod();
		close();
	}
}  else if (data=="Folder of Images") { 
	list = getFileList(folder);
	for (file=0; file<list.length; file++) {
		showProgress(file+1, list.length);
		open(folder+File.separator+list[file]);
		applyMethod();
		close("*");
	}
}
exit();

function applyMethod() {
	if (method=="Method A") doMethodA(); 
	else doMethodB();
}

function doMethodA() {
	print ("Applying Method A on "+getTitle+" slice # "+getSliceNumber());
	run("Grays");
	run("Select None");
	run("Find Maxima...", "prominence="+prominence+" output=[Point Selection]");
	getSelectionCoordinates(x,y);
	for (i=0;i<x.length;i++) {
		makeOval(x[i]-mRadius,y[i]-mRadius,mRadius*2,mRadius*2);
		run("Measure");
	}
}

function doMethodB() {
	print ("Applying Method B on "+getTitle+" slice # "+getSliceNumber());
	run("Subtract Background...", "rolling="+rollingRadius); 
	original_file_name = File.name;
	duplicated_file_name = File.nameWithoutExtension + "-1";
	run("Duplicate...", "title=&duplicated_file_name");
	run("Mean...", "radius="+mRadius);
	run("Auto Local Threshold...", "method=Bernsen radius="+localRadius+" parameter_1=0 parameter_2=0 white");
	setOption("BlackBackground", false);
	run("Set Measurements...", "area mean min integrated display redirect=[&original_file_name] decimal = 2");
	run("Analyze Particles...", "size="+sizeFilter+" circularity="+circFilter+" show=[Bare Outlines] display exclude");
}
