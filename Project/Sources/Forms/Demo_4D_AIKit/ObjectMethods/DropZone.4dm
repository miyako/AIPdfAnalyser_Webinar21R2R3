var $path : Text
var $fileName : Text
var $pathParts : Collection
var $documents : Collection
var $index : Integer
var $pasteboardBlob : Blob
var $sep : Text

Case of 
	: (FORM Event.code=On Drag Over)
		
		$path:=Get file from pasteboard(1)
		If (Test path name($path)#Is a document)
			return -1
		End if 
		
		var $file:=File($path; fk platform path)
		If ($file.extension#".pdf")
			return -1
		End if 
		
		return 0
		
	: (FORM Event.code=On Drop)
		
		$path:=Get file from pasteboard(1)
		$file:=File($path; fk platform path)
		Form.pdfFileName:=$file.name
		Form.pdfPath:=$file.platformPath
	: (FORM Event.code=On Clicked)
		//Select document(""; "pdf"; "Select a PDF file"; 0)
		var $name : Text:=Select document(Get 4D folder(Current resources folder); \
			".pdf"; \
			"PDFファイルを選択してください"; \
			Use sheet window)
		If (OK=1)
			$file:=File(DOCUMENT; fk platform path)
			Form.pdfFileName:=$file.name
			Form.pdfPath:=$file.platformPath
		End if 
		
End case 