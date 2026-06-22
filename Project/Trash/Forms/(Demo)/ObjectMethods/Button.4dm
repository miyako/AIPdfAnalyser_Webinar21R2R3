var $clientAI : cs.AIKit.OpenAI:=This.clientAI:=cs.AIKit.OpenAI.new($openAIKey)

var $res:=$clientAI.files.create(Folder("c:\\tmp"; fk platform path).file("2510.06364v1.pdf"); "user_data"; {expires_after: {anchor: "created_at"; seconds: 3600}})
Form.file1:=Bool($res.success) ? $res.file : Null

var $blob : Blob
DOCUMENT TO BLOB(Folder("c:\\tmp"; fk platform path).file("2510.07311v1.pdf").platformPath; $blob)
$res:=$clientAI.files.create($blob; "user_data"; {expires_after: {anchor: "created_at"; seconds: 3600}; fileName: "2510.07311v1.pdf"})
Form.file2:=Bool($res.success) ? $res.file : Null



var $list:=$clientAI.files.list()