property _fileInfo : Object

Function uploadFile($path : 4D.File)
	
	TRACE
	
	// Create an AI client instance using the AIManagement class.
	var $clientAI:=cs.AIKit.OpenAI.new({provider: "OpenAI Provider"})
	
	// Upload a file to the AI service.
	// File(Form.pdfFileName) converts the file path into a File object.
	//
	// "user_data" specifies the purpose/category of the uploaded file.
	//
	// The expires_after option defines an automatic expiration policy:
	// - anchor: "created_at" means the expiration timer starts when the file is created.
	// - seconds: 3600 means the file will expire after 1 hour (3600 seconds).
	
	var $createRes:=$clientAI.files.create($path; "user_data"; {expires_after: {anchor: "created_at"; seconds: 3600}})
	
	// Check whether the upload was successful.
	If ($createRes.success)
		
		// If successful, store the uploaded file object in $file.
		This._fileInfo:=$createRes.file
		
		return True
		
	End if 
	
	return False
	
Function chatWithFile($myPrompt : Text) : Text
	
	If (This._fileInfo=Null)
		return "No File uploaded"
	End if 
	
	TRACE
	// Create an AI client instance using the AIManagement class.
	var $clientAI:=cs.AIKit.OpenAI.new()
	
	// System prompt sent to the AI model.
	// It defines the assistant's role and explains that files
	// have already been uploaded and must be analyzed.
	var $firstPrompt:="You are an assistant specializing in file analysis and parsing. Before we begin, several files have been uploaded to the server."
	$firstPrompt+=" Your task is to read and analyze these files, then extract the requested information."
	$firstPrompt+=" You must return a response in text format and in english that I can display directly in a web browser without Markdown tags or ```. The pictures are not allowed in the response"
	
	//// Initialize the discussion array with the system message.
	//// The discussion history will be sent to the AI model.
	var $chatHelper:=$clientAI.chat.create($firstPrompt; {model: "model openai"})
	
	// Create a user message containing the request prompt.
	var $message:=cs.AIKit.OpenAIMessage.new({role: "user"; content: $myPrompt})
	
	// Attach the uploaded file ID to the message.
	// This allows the AI model to access and analyze the file.
	$message.addFileId(This._fileInfo.id)
	
	$response:=$chatHelper.prompt($message)
	
	If ($response.success)
		return $response.choice.message.text
	End if 
	