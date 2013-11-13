
var preview_row = document.getElementById('AlbumArt_row');
var preview_img = document.getElementById('AlbumArt_img');
var preview_name = document.getElementById('AA_filename');
var progressbar = document.getElementById('progressbar');

var holder = document.getElementById('drop_zone'),
    tests = {
      filereader: typeof FileReader != 'undefined',
      dnd: 'draggable' in document.createElement('span'),
      formdata: !!window.FormData,
      progress: "upload" in new XMLHttpRequest
    }, 
    support = {
      filereader: document.getElementById('filereader'),
      formdata: document.getElementById('formdata'),
      progress: document.getElementById('progress')
    },
    acceptedTypes = {
//      'image/png': true,
      'image/jpeg': true,
//      'image/gif': true,
      'audio/mpeg': true,
      'audio/mp4': true,
      'audio/ogg': true,
      'audio/L24': true,
      'audio/vnd.wav': true
    },
    progress = document.getElementById('uploadprogress'),
    fileupload = document.getElementById('upload');

"filereader formdata progress".split(' ').forEach(function (api) {
  if (tests[api] === false) {
    support[api].className = 'fail';
  } else {
    // FFS. I could have done el.hidden = true, but IE doesn't support
    // hidden, so I tried to create a polyfill that would extend the
    // Element.prototype, but then IE10 doesn't even give me access
    // to the Element object. Brilliant.
//    support[api].className = 'hidden';
  }
});

/* Name set by upload.php script */
function setName(name){
	preview_img.name = name;
}


function previewfile(file) {
	if (tests.filereader === true && acceptedTypes[file.type] === true) {

		if (file.type.split('/')[0]=="image"){
			var reader = new FileReader();
			reader.onload = function (event) {
				preview_img.src = event.target.result;
				preview_img.style.display = 'block';
				preview_img.name = file.name;
				preview_row.style.display = 'table-caption';
				preview_name.value = file.name;
				
			//problem: Assumes unique filenames on server!
			};
			reader.readAsDataURL(file);
			return "Image"
		}
		else{
			return "Audio";
			//display audio
		}
	} else {
		alert(file+" : Not a valid type.");
		return "Nope";
	}
}

function readfiles(files) {
//    debugger;
	var result="";

    var formData = tests.formdata ? new FormData() : null;
    for (var i = 0; i < files.length; i++) {
		if (tests.formdata) formData.append('filer', files[i]);
		result=previewfile(files[i]);

		// now post a new XHR request
		if ( result!="Nope" && tests.formdata ) {
		  var xhr = new XMLHttpRequest();
		  xhr.open('POST', 'assets/php/upload.php');
		  xhr.onload = function() {
			progressbar.style.width = '0%';
		  };

		  if (tests.progress) {
			xhr.upload.onprogress = function (event) {
			  if (event.lengthComputable) {
				var complete = (event.loaded / event.total * 100 | 0);
				progressbar.style.width=""+(complete*100)+"%";
			  }
			}
		  }

		  xhr.send(formData);
		  if (result=="Audio") addFileElem(files[i].name);
	  }
      resortNumbs()
      tableDnD.init(table);
    }
}

if (tests.dnd) { 
  holder.ondragover = function () { this.className = 'hover'; return false; };
  holder.ondragend = function () { this.className = ''; return false; };
  holder.ondrop = function (e) {
    this.className = '';
    e.preventDefault();
    readfiles(e.dataTransfer.files);
  }
} else {
  fileupload.className = 'hidden';
  fileupload.querySelector('input').onchange = function () {
    readfiles(this.files);
  };
}



