property _fileInfo : Object
property stream : Boolean
property provider : Text
property model : Text
property _chatResult : Text
property _onResponse : 4D.Function

Class constructor()
	
	This.provider:="openai"
	This.model:="chat-reasoning"
	This.stream:=True
	This._chatResult:=""
	
Function onEventStreamFile($fileResult : cs.AIKit.OpenAIChatCompletionsStreamResult)
	
	var $success : Boolean
	$success:=($fileResult.terminated) && ($fileResult.success)
	
	If (Form=Null)
		return 
	End if 
	
	var $name : Text
	$name:=$fileResult.request.headers.name
	
	If ($success)
		Form._fileInfo:=$fileResult.data
		//WA EXECUTE JAVASCRIPT FUNCTION(*; "web area"; "addAssistantMessage"; $result; "The file "+$name+" has been uploaded successfully.")
		WA EXECUTE JAVASCRIPT FUNCTION(*; "web area"; "addAssistantMessage"; $success; $name+"をアップロードしました")
	Else 
		Form._fileInfo:=Null
		//WA EXECUTE JAVASCRIPT FUNCTION(*; "web area"; "addAssistantMessage"; $result; "Upload failed.")
		WA EXECUTE JAVASCRIPT FUNCTION(*; "web area"; "addAssistantMessage"; $success; "アップロードに失敗しました")
	End if 
	
Function onEventStreamChat($chatCompletionsResult : cs.AIKit.OpenAIChatCompletionsStreamResult)
	
	If ($chatCompletionsResult.success)
		If ($chatCompletionsResult.terminated)
			//complete result
			If ($chatCompletionsResult.choice#Null)
				If ($chatCompletionsResult.choice.message=Null)  //streaming
					$chatCompletionsResult:=JSON Parse(JSON Stringify($chatCompletionsResult))
					$chatCompletionsResult.choice.message:={role: "assistant"; content: This._chatResult}
				Else   //not streaming
					If ($chatCompletionsResult.choice.message.content#Null)
						This._chatResult+=$chatCompletionsResult.choice.message.content
						WA EXECUTE JAVASCRIPT FUNCTION(*; "web area"; "addAssistantMessage"; *; This._chatResult)
					End if 
				End if 
			Else 
				
			End if 
			//This.onCompletion($chatCompletionsResult)
		Else 
			//partial result
			If ($chatCompletionsResult.choice#Null)
				If ($chatCompletionsResult.choice.delta.text#"")
					
					If (This._chatResult="")
						If (Form#Null)
							//create bubble
							WA EXECUTE JAVASCRIPT FUNCTION(*; "web area"; "addAssistantMessage"; *; $chatCompletionsResult.choice.delta.text)
						End if 
					Else 
						//grow bubble
						WA EXECUTE JAVASCRIPT FUNCTION(*; "web area"; "appendAssistantMessage"; *; $chatCompletionsResult.choice.delta.text)
					End if 
					This._chatResult+=$chatCompletionsResult.choice.delta.text
				End if 
			Else 
			End if 
		End if 
	Else 
		If ($chatCompletionsResult.terminated)
			This._chatResult+=$chatCompletionsResult.errors.extract("message").join("\r")
			DELAY PROCESS(Current process; 60*30)
			If (OB Instance of(This._onResponse; 4D.Function))
				This._onResponse.call(This; $chatCompletionsResult)
			End if 
		End if 
	End if 
	
Function uploadFile($path : Text)
	
	var $file : 4D.File
	$file:=File($path; fk platform path)
	
	// Create an AI client instance using the AIManagement class.
	var $clientAI:=cs.AIKit.OpenAI.new({provider: This.provider})
	
	// Upload a file to the AI service.
	// File(Form.pdfFileName) converts the file path into a File object.
	// "user_data" specifies the purpose/category of the uploaded file.
	// The expires_after option defines an automatic expiration policy:
	// - anchor: "created_at" means the expiration timer starts when the file is created.
	// - seconds: 3600 means the file will expire after 1 hour (3600 seconds).
	
	var $FileParameters : cs.AIKit.OpenAIFileParameters
	$FileParameters:=cs.AIKit.OpenAIFileParameters.new(This)
	$FileParameters.formula:=This.onEventStreamFile
	$FileParameters.expires_after:={anchor: "created_at"; seconds: 3600}
	$FileParameters.extraHeaders:={name: $file.fullName}
	
	$clientAI.files.create($file; "user_data"; $FileParameters)
	
Function chatWithFile($myPrompt : Text) : Text
	
	If (Form._fileInfo=Null)
		//return "No File uploaded"
		return "ファイルがアップロードされていません"
	End if 
	
	This._chatResult:=""
	
	var $ChatCompletionsParameters : cs.AIKit.OpenAIChatCompletionsParameters
	$ChatCompletionsParameters:=cs.AIKit.OpenAIChatCompletionsParameters.new(This)
	$ChatCompletionsParameters.model:=This.model
	$ChatCompletionsParameters.stream:=This.stream
	$ChatCompletionsParameters.formula:=This.onEventStreamChat
	
	// Create an AI client instance using the AIManagement class.
	var $clientAI:=cs.AIKit.OpenAI.new()
	
	// System prompt sent to the AI model.
	// It defines the assistant's role and explains that files
	// have already been uploaded and must be analyzed.
	var $firstPrompt:="You are an assistant specializing in file analysis and parsing. Before we begin, several files have been uploaded to the server."
	$firstPrompt+=" Your task is to read and analyze these files, then extract the requested information."
	$firstPrompt+=" You must return a response in text format that I can display directly in a web browser without Markdown tags or ```. The pictures are not allowed in the response"
	$firstPrompt+=" You must respond in Japanese."
	
	//// Initialize the discussion array with the system message.
	//// The discussion history will be sent to the AI model.
	var $chatHelper:=$clientAI.chat.create($firstPrompt; $ChatCompletionsParameters)
	
	// Create a user message containing the request prompt.
	var $message:=cs.AIKit.OpenAIMessage.new({role: "user"; content: $myPrompt})
	
	// Attach the uploaded file ID to the message.
	// This allows the AI model to access and analyze the file.
	$message.addFileId(Form._fileInfo.id)
	
	$chatHelper.prompt($message)