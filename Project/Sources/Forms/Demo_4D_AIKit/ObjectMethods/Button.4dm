WA EXECUTE JAVASCRIPT FUNCTION(*; "web area"; "addUserMessage"; *; Form.prompt)

var $response : Text:=Form.aiManager.chatWithFile(Form.prompt)

WA EXECUTE JAVASCRIPT FUNCTION(*; "web area"; "addAssistantMessage"; *; $response)

Form.prompt:=""