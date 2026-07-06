If (FORM Event.code=On Clicked)
	
	var $path:=File(Form.pdfPath; fk platform path)
	var $result : Boolean:=Form.aiManager.uploadFile($path)
	
	If ($result)
		//WA EXECUTE JAVASCRIPT FUNCTION(*; "web area"; "addAssistantMessage"; $result; "The file "+$path.name+" has been uploaded successfully.")
		WA EXECUTE JAVASCRIPT FUNCTION(*; "web area"; "addAssistantMessage"; $result; $path.name+"をアップロードしました")
	Else 
		//WA EXECUTE JAVASCRIPT FUNCTION(*; "web area"; "addAssistantMessage"; $result; "Upload failed.")
		WA EXECUTE JAVASCRIPT FUNCTION(*; "web area"; "addAssistantMessage"; $result; "アップロードに失敗しました")
	End if 
	
End if 