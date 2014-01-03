var table=null
var tableDnD=null

function createGuid(){
    return 'xxxxxxxx'.replace(/x/g, function(c) {
        var r = Math.random()*16|0, v = c === 'x' ? r : (r&0x3|0x8);
        return v.toString(16);
    });
}

function removeRow(guid){
	var index=0;
	for (var i=1, row;row = table.rows[i];i++) {
		var r_guid = row.cells[4].innerHTML
		if (guid == r_guid){
			index = i;
			table.deleteRow(index);
			resortNumbs()
			return 1;
		}
	}
	return -1
}

function addYoutube(){
	var yt_l = document.getElementById('youtube_link')
	var yt_n = document.getElementById('youtube_name')
	
	var yt_link = yt_l.value;
	var yt_name = yt_n.value;
	
	if (!yt_name.contains(".mp3")){
		yt_name +=".mp3"
	}
	addFileElem(yt_name,true,yt_link);
	yt_l.value = "<youtube.com>"
	yt_n.value = "<filename.mp3>"
}


function printOutTable(){
	//Print <Author>\t<Filename>\t<youtube>
	var text=""
	
	for (var i=1, row;row = table.rows[i];i++) {
		var cells = row.cells;
		var author = cells[1].getElementsByTagName('input')[0].value;
		var filename = cells[2].innerHTML;
		var ytube= cells[5].innerHTML;
		
		text += author+"\t"+filename+"\t"+ytube+'\n'
	}
	alert(text);
}


function rewriteTable(file){
	if (file) {
		var r = new FileReader();
		r.onload = function(e) {
			var contents = e.target.result;
			//alert(contents);
			var lines = contents.split('\n')
			for (var l=0; l < lines.length; l++){
				//Author  Filename Youtbue
				var tokes = lines[l].split('\t');
				if (tokes.length<2) continue
				
				tokes[1] = tokes[1].trim()				
				if(tokes[1].length==0) tokes[1]=" "
				
				addFileElem(tokes[1],true, tokes[2].trim(),tokes[0].trim())
			}
			tableDnD = new TableDnD();

			
		}
		r.readAsText(file);
    } else { 
		alert("Failed to load file");
    }	
}


function addFileElem(text,resort=false, link="",author=""){
	
	if (text.contains("'")){
		alert('"'+text+'"'+"\n\nPlease no apostrophes in file names!")
		return
	}
	
	var uuid = createGuid()
	
	var row = table.insertRow(-1); //last
	var elem0 = row.insertCell(0); //#Track
	var elem1 = row.insertCell(1); //Author
	var elem2 = row.insertCell(2); //Filename
	var elem3 = row.insertCell(3); //Delete?
	var elem4 = row.insertCell(4); //uuid, hidden
	var elem5 = row.insertCell(5); //youtube link, hidden
	
	elem0.innerHTML = "x"
	elem0.style.textAlign = "center"
	elem1.innerHTML = '<input type="text" name="author" style="width:100px;text-align:center;" value="'+author+'">'
	elem2.innerHTML = text
	elem3.innerHTML = '<input type="button" value="x" style="width:25px;height:25px" onclick=\'removeRow("'+uuid+'")\' >'
	elem4.innerHTML = uuid
	elem4.style.display = "none"
	elem5.innerHTML = link
	elem5.style.display = "none"
	
	if (resort==true) resortNumbs();
}

/*function handleFileSelect(e) {
	if(!e.target.files) return;
	var files = e.target.files;
	
//	for (t in table.rows.length) table.deleteRow()    	//Clear Table
	//Rebuild
	for(var i=0; i<files.length; i++){
		addFileElem( files[i].name );
	}
	resortNumbs()
	tableDnD.init(table);
}*/

function resortNumbs(){
	for (var i=1, row;row = table.rows[i];i++) {
		var pad = "00";
		var res = (pad+i).slice(-pad.length);
		row.cells[0].innerHTML = res
	}
}

function sendData(){
	var empty = "none_given";

	//Fill empties
	for (var i=1, row;row = table.rows[i]; i++) {
		var box = row.cells[1].getElementsByTagName("input")[0]
		var auth = box.value.trim()
		if (auth == "" || auth == empty || auth.length == 0){
			box.value = empty;
		}
		else if (auth.split(' ').length > 1){
			alert("No spaces please")
			return false
		}


	}
	if (table.rows.length <= 1) return false 

	document.getElementById('json_name').value = writeList();
	document.getElementById('json_name_youtube').value = writeYoutube();
	return true
}

function inputValue(idval){
	return document.getElementById(idval).value
}

function writeList(){
	str='Name: ' + inputValue('album_name')+
		'\n#'+'\n#'+
		'\nTheme: '+ inputValue('theme_name')+
		'\nAuthor: '+ inputValue('author_name')+
		'\n#'+'\n#';
		
	for (var i=1, row;row = table.rows[i]; i++) {
		cel_vars = row.cells;
		str += '\n'+cel_vars[1].getElementsByTagName('input')[0].value+'\t'+	//author
			   cel_vars[0].innerHTML + '\t' +									//#track
			   cel_vars[2].innerHTML;											//filename
	}
	str+='\n'
//	alert(str)
	return str
}

function writeYoutube(){
	str=""
	for (var i=1, row;row = table.rows[i]; i++) {
		var cel_vars = row.cells;
		var link=cel_vars[5].innerHTML.trim();
		
		if (link.length >= 1){
			str += 	link+'\t'+cel_vars[2].innerHTML.trim()+'\n\n';		//youtube link + desired filename, double spaced
		}
	}
	return str
}

window.onload = function() {
	table = document.getElementById('songlist');
	tableDnD = new TableDnD();
	
	//Make headers non droppable
	var header_row = table.rows[0];
	header_row.setAttribute("NoDrag",true)
	header_row.setAttribute("NoDrop",true)
	
	//Override drop method to calculate number indexes
	tableDnD.onDrop = function (){	resortNumbs(); }
	
}
