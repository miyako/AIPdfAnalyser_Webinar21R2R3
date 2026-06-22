var $firstprompt:="You are an assistant specializing in file analysis and parsing. Before we begin, several files have been uploaded to the server. Your task is to read and analyze these files, then extract the requested information."

var $prompt:="Peux tu me donner le titre, le type mime, le résumé et les points clé ansi que l'auteur du fichier avec l'ID"

var $clientAI:=cs:C1710.AIManagement.new().clientAI

var $discussion:=[{role: "system"; content: $firstprompt}]

var $message:=cs:C1710.AIKit.OpenAIMessage.new({role: "user"; content: $prompt})

$message.addFileId(Form:C1466.file1.id)

$discussion.push($message)

Form:C1466.result1:=$clientAI.chat.completions.create($discussion; {model: "gpt-4o-mini"})

ds:C1482.People.Address.get()