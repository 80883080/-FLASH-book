fl.outputPanel.clear();
var ccName = prompt("输入自定义组件的名字:","newCustomComponent");
if(ccName != null)
{
	var doc = fl.createDocument();
	var folderURI = fl.browseForFolderURL("选择自定义组件保存位置");
	if(folderURI != null)
	{
		fl.saveDocument(doc,folderURI+"/"+ccName+".fla");
	}
}