If (FORM Event.code=On Load)
	
	//var $path:=Folder(fk resources folder).file("4Dv20_LTS_brochure_French.pdf")
	var $path:=Folder(fk resources folder).file("4Dv20_LTS_brochure_Japanese.pdf")
	
	Form.pdfPath:=$path.platformPath
	Form.pdfFileName:=$path.name
	
	Form.aiManager:=cs.AIManager.new()
	
	WA SET CONTEXT(*; "web area"; Form.aiManager)
	
	WA OPEN URL(*; "web area"; "http://localhost/chat2.htm?"+Generate UUID)
	
	OBJECT SET ENABLED(*; "Button"; False)
	
End if 