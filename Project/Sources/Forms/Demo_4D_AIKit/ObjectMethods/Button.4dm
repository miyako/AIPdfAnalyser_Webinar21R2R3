WA EXECUTE JAVASCRIPT FUNCTION(*; "web area"; "addUserMessage"; $result; Form.prompt)

var $response : Text:=Form.aiManager.chatWithFile(Form.prompt)

WA EXECUTE JAVASCRIPT FUNCTION(*; "web area"; "addAssistantMessage"; $result; $response)

Form.prompt:=""

