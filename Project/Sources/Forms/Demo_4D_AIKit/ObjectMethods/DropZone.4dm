var $path : Text
var $fileName : Text
var $pathParts : Collection
var $documents : Collection
var $index : Integer
var $pasteboardBlob : Blob
var $sep : Text

If (FORM Event.code=On Clicked)
	Select document(""; "pdf"; "Select a PDF file"; 0)
	If (OK=1)
		$path:=Document
	End if 
End if 


If (String($path)#"")
	var $file:=File($path; fk platform path)
	If ($file.extension=".pdf")
		
		Form.pdfFileName:=$file.name
		Form.pdfPath:=$file.platformPath
		Form.summaryText:="Ready to analyze "+$file.name+". Click Analyze to generate the summary."
	Else 
		ALERT("Please drop a PDF file. Only PDF documents are supported.")
	End if 
End if 

