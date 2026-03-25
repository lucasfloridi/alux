#include "totvs.ch"
#include "topconn.ch"

#Define		NOME_FUNCAO 	"TOTVS IP ConnectFTP"
#Define		BARRA_DIR		"/"

//-----------------------------------------------------------------
/*/{Protheus.doc} ConnectFTP
Classe de Conexão ao FTP

@type		Class
@author		Julio Lisboa
@since 		05/05/2016
@Return		nil
/*/
//-----------------------------------------------------------------
CLASS ConnectFTP

	Data cServer as String
	Data nPorta as Numeric
	Data cUser as String
	Data cSenha as String
	Data lConIP as Loogic
	Data cExtensao as String
	Data cDiretorio as String
	Data lJob as Loogic
	Data lOk as Loogic

	Method setServer()
	Method setPorta()
	Method setUser()
	Method setSenha()
	Method setConIP()
	Method setExtensao()
	Method setDiretorio()
	Method setIsJob()

	Method getServer()
	Method getPorta()
	Method getUser()
	Method getSenha()
	Method getConIP()
	Method getExtensao()
	Method getDiretorio()
	Method getIsJob()

	METHOD New() CONSTRUCTOR
	Method Connect()
	Method Disconnect()
	Method listaDir()
	Method isConnect()
	Method baixaArq()
	Method uploadArq()
	Method deletaArq()

ENDCLASS

//-----------------------------------------------------------------
/*/{Protheus.doc} New
Método Construtor

@type		Method
@author		Julio Lisboa
@since 		05/05/2016
@Return		nil
/*/
//-----------------------------------------------------------------
Method New(cServer,nPorta,cUser,cSenha,lConIP,cExtensao,cDiretorio,lJob) Class ConnectFTP

	Default cServer		:= ""
	Default nPorta		:= 0
	Default cUser		:= ""
	Default cSenha		:= ""
	Default lConIP		:= .F.
	Default cExtensao	:= ""
	Default cDiretorio	:= ""
	Default lJob		:= GetRemoteType() == -1

	Self:cServer		:= cServer
	Self:nPorta			:= nPorta
	Self:cUser			:= cUser
	Self:cSenha			:= cSenha
	Self:lConIP			:= lConIP
	Self:lOk			:= .F.
	Self:cExtensao		:= cExtensao
	Self:cDiretorio		:= cDiretorio
	Self:lJob			:= lJob

Return

//-----------------------------------------------------------------
/*/{Protheus.doc} setServer
Método que Configura o server

@type		Method
@author		Julio Lisboa
@since 		05/05/2016
@Return		nil
/*/
//-----------------------------------------------------------------
Method setServer(cServer) Class ConnectFTP
	Self:cServer := cServer
Return

//-----------------------------------------------------------------
/*/{Protheus.doc} setPorta
Método que Configura a Porta

@type		Method
@author		Julio Lisboa
@since 		05/05/2016
@Return		nil
/*/
//-----------------------------------------------------------------
Method setPorta(nPorta) Class ConnectFTP
	Self:nPorta := nPorta
Return

//-----------------------------------------------------------------
/*/{Protheus.doc} setUser
Método que Configura o Usuário

@type		Method
@author		Julio Lisboa
@since 		05/05/2016
@Return		nil
/*/
//-----------------------------------------------------------------
Method setUser(cUser) Class ConnectFTP
	Self:cUser := cUser
Return

//-----------------------------------------------------------------
/*/{Protheus.doc} setSenha
Método que Configura a Senha

@type		Method
@author		Julio Lisboa
@since 		05/05/2016
@Return		nil
/*/
//-----------------------------------------------------------------
Method setSenha(cSenha) Class ConnectFTP
	Self:cSenha := cSenha
Return

//-----------------------------------------------------------------
/*/{Protheus.doc} setConIP
Método que Configura se utiliza conexão por IP

@type		Method
@author		Julio Lisboa
@since 		05/05/2016
@Return		nil
/*/
//-----------------------------------------------------------------
Method setConIP(lConIP) Class ConnectFTP
	Self:lConIP := lConIP
Return

//-----------------------------------------------------------------
/*/{Protheus.doc} setExtensao
Método que Configura a extensao dos arquivos

@type		Method
@author		Julio Lisboa
@since 		05/05/2016
@Return		nil
/*/
//-----------------------------------------------------------------
Method setExtensao(cExtensao) Class ConnectFTP
	Self:cExtensao := cExtensao
Return

//-----------------------------------------------------------------
/*/{Protheus.doc} setDiretorio
Método que Configura o diretorio onde serão buscados os arquivos

@type		Method
@author		Julio Lisboa
@since 		05/05/2016
@Return		nil
/*/
//-----------------------------------------------------------------
Method setDiretorio(cDiretorio) Class ConnectFTP
	
	Local cCaminho		:= ""
	Default cDiretorio	:= ""
	
	If SubStr(cDiretorio,Len(cDiretorio),1) == BARRA_DIR
		cCaminho := cDiretorio
	Else
		cCaminho := cDiretorio + BARRA_DIR
	EndIf	
	
	If FTPDirChange(cCaminho)
		Self:cDiretorio := cCaminho
	Else
		ImpLog("Não foi possível mudar o diretório para [" + cCaminho + "]",Self:getIsJob())
	EndIf
	
Return

//-----------------------------------------------------------------
/*/{Protheus.doc} setIsJob
Método que Configura se está sendo executado via JOB

@type		Method
@author		Julio Lisboa
@since 		05/05/2016
@Return		nil
/*/
//-----------------------------------------------------------------
Method setIsJob(lJob) Class ConnectFTP
	Self:lJob := lJob
Return

//-----------------------------------------------------------------
/*/{Protheus.doc} getServer
Método que Retorna o Server

@type		Method
@author		Julio Lisboa
@since 		05/05/2016
@Return		Self:cServer
/*/
//-----------------------------------------------------------------
Method getServer() Class ConnectFTP
Return Self:cServer

//-----------------------------------------------------------------
/*/{Protheus.doc} getPorta
Método que Retorna a porta

@type		Method
@author		Julio Lisboa
@since 		05/05/2016
@Return		Self:nPorta
/*/
//-----------------------------------------------------------------
Method getPorta() Class ConnectFTP
Return Self:nPorta

//-----------------------------------------------------------------
/*/{Protheus.doc} getUser
Método que Retorna o usuário

@type		Method
@author		Julio Lisboa
@since 		05/05/2016
@Return		Self:cUser
/*/
//-----------------------------------------------------------------
Method getUser() Class ConnectFTP
Return Self:cUser

//-----------------------------------------------------------------
/*/{Protheus.doc} getSenha
Método que Retorna a senha

@type		Method
@author		Julio Lisboa
@since 		05/05/2016
@Return		Self:cSenha
/*/
//-----------------------------------------------------------------
Method getSenha() Class ConnectFTP
Return Self:cSenha

//-----------------------------------------------------------------
/*/{Protheus.doc} getConIP
Método que Retorna se utiliza conexão por IP

@type		Method
@author		Julio Lisboa
@since 		05/05/2016
@Return		Self:lConIP
/*/
//-----------------------------------------------------------------
Method getConIP() Class ConnectFTP
Return Self:lConIP

//-----------------------------------------------------------------
/*/{Protheus.doc} getExtensao
Método que Retorna a extensao dos arquivos

@type		Method
@author		Julio Lisboa
@since 		05/05/2016
@Return		Self:cExtensao
/*/
//-----------------------------------------------------------------
Method getExtensao() Class ConnectFTP
Return Self:cExtensao

//-----------------------------------------------------------------
/*/{Protheus.doc} getDiretorio
Método que Retorna o diretorio

@type		Method
@author		Julio Lisboa
@since 		05/05/2016
@Return		Self:cDiretorio
/*/
//-----------------------------------------------------------------
Method getDiretorio() Class ConnectFTP
Return Self:cDiretorio

//-----------------------------------------------------------------
/*/{Protheus.doc} getIsJob
Método que Retorna se está sendo executado via JOB

@type		Method
@author		Julio Lisboa
@since 		05/05/2016
@Return		Self:lJob
/*/
//-----------------------------------------------------------------
Method getIsJob() Class ConnectFTP
Return Self:lJob

//-----------------------------------------------------------------
/*/{Protheus.doc} isConnect()
Método que Retorna se está conectado ao FTP

@type		Method
@author		Julio Lisboa
@since 		05/05/2016
@Return		Self:lOk
/*/
//-----------------------------------------------------------------
Method isConnect() Class ConnectFTP
Return Self:lOk

//-----------------------------------------------------------------
/*/{Protheus.doc} Connect
Método que Conecta no FTP

@type		Method
@author		Julio Lisboa
@since 		05/05/2016
@Return		nil
/*/
//-----------------------------------------------------------------
Method Connect() Class ConnectFTP
	
	Local cMensagem		:= ""
	
	//Verifica se estão preenchidos os dados de conexão
	If !Empty(Self:getServer()) .AND. !Empty(Self:getUser()) .AND. !Empty(Self:getSenha())
		
		If FTPConnect(Self:getServer(),Self:getPorta(),Self:getUser(),Self:getSenha(),Self:getConIP())
			cMensagem	:= "CONECTADO"
			ImpLog(cMensagem,Self:getIsJob())
			
			Self:lOk	:= .T.
		Else
			cMensagem	:= "NÃO CONECTADO"
			ImpLog(cMensagem,Self:getIsJob())
			
			cMensagem	:= "Server [" + Self:getServer() + "]"
			cMensagem	+= "User [" + Self:getUser() + "]"
			cMensagem	+= "Senha [" + Self:getSenha() + "]"			
			
			ImpLog(cMensagem,Self:getIsJob())
		EndIf
	Else
		cMensagem	:= "ERRO - Faltam Informações - "
		cMensagem	+= "Server [" + Self:getServer() + "]"
		cMensagem	+= "User [" + Self:getUser() + "]"
		cMensagem	+= "Senha [" + Self:getSenha() + "]"
		
		ImpLog(cMensagem,Self:getIsJob())
	EndIf

Return (Self:isConnect())

//-----------------------------------------------------------------
/*/{Protheus.doc} Disconnect
Método que desconecta do FTP

@type		Method
@author		Julio Lisboa
@since 		05/05/2016
@Return		nil
/*/
//-----------------------------------------------------------------
Method Disconnect() Class ConnectFTP
	
	Local cMensagem		:= ""
	
	If FTPDisconnect()
		cMensagem	:= "DESCONECTADO COM SUCESSO"
		ImpLog(cMensagem,Self:getIsJob())
		Self:lOk	:= .F.
	Else
		cMensagem	:= "NÃO FOI POSSÍVEL DESCONECTAR"
		ImpLog(cMensagem,Self:getIsJob())
	EndIf

Return !(Self:isConnect())

//-----------------------------------------------------------------
/*/{Protheus.doc} listaDir
Lista os Arquivos Especificados

@type		Method
@author		Julio Lisboa
@since 		05/05/2016
@Return		nil
/*/
//-----------------------------------------------------------------
Method listaDir( cFiltro ) Class ConnectFTP
	
	Local aRet			:= {}
	Local cMensagem 	:= ""
	Local cCaminho		:= ""
	Local lDir			:= .F.
	
	Default cFiltro		:= ""
	
	If !Empty(Self:getDiretorio())
		cMensagem	 += "DIRETORIO : "
		cMensagem	 += "[" + Self:getDiretorio() + "] "
		
		lDir := .T.
	EndIf

	If Empty(cFiltro)
		cMensagem	 += "EXTENSÃO: "
		cMensagem	 += "[" + Self:getExtensao() + "]"
		
		aRet := FTPDirectory(Self:getExtensao())
	Else
		cMensagem	 += "ARQUIVO: "
		cMensagem	 += "[" + cFiltro + "]"
		
		aRet := FTPDirectory( cFiltro + Self:getExtensao() )
	EndIf

	ImpLog(cMensagem,Self:getIsJob())

Return (aRet)

//-----------------------------------------------------------------
/*/{Protheus.doc} baixaArq
Realiza o download do arquivo

@type		Method
@author		Julio Lisboa
@since 		09/05/2016
@Return		lOk
/*/
//-----------------------------------------------------------------
Method baixaArq(cNovoArq,cArqFTP) Class ConnectFTP
	
	Local lOk			:= .F.
	Local cCaminho		:= ""
	Local cMensagem		:= ""
	
	Default cNovoArq 	:= ""
	Default cArqFTP		:= ""
	
	If !Empty(cNovoArq) .AND. !Empty(cArqFTP)
		
		If File(cNovoArq)
			cMensagem		:= "Arquivo "
			cMensagem		:= "[" + cNovoArq + "]"
			cMensagem		:= " já existente."
		Else
			lOk	:= FTPDownload(cNovoArq,cArqFTP)
		EndIf
		
		If lOk
			cMensagem := "Download do Arquivo FTP "
			cMensagem += "[" + cArqFTP + "] para "
			cMensagem += "[" + cNovoArq + "] com sucesso !"
			
			ImpLog(cMensagem,Self:getIsJob())
		Else
			cMensagem := "Não foi possível Efetuar o download do Arquivo FTP "
			cMensagem += "[" + cArqFTP + "] para "
			cMensagem += "[" + cNovoArq + "]"
			
			ImpLog(cMensagem,Self:getIsJob())
		EndIf
	Else
		cMensagem	:= "Nenhum Arquivo Selecionado."
		ImpLog(cMensagem,Self:getIsJob())
	EndIf

Return lOk

//-----------------------------------------------------------------
/*/{Protheus.doc} uploadArq
Realiza o Upload do arquivo

@type		Method
@author		Julio Lisboa
@since 		18/05/2016
@Return		lOk
/*/
//-----------------------------------------------------------------
Method uploadArq(cArqLocal,cArqFTP) Class ConnectFTP
	
	Local lOk			:= .F.
	Local cCaminho		:= ""
	Local cMensagem		:= ""
	
	Default cArqLocal 	:= ""
	Default cArqFTP		:= ""
	
	If !Empty(cArqLocal) .AND. !Empty(cArqFTP)
		lOk	:= FTPUpload(cArqLocal,cArqFTP)
		
		If lOk
			cMensagem := "Upload do Arquivo FTP "
			cMensagem += "[" + cArqLocal + "] para "
			cMensagem += "[" + cArqFTP + "] com sucesso !"
			
			ImpLog(cMensagem,Self:getIsJob())
		Else
			cMensagem := "Não foi possível Efetuar o Upload do Arquivo FTP "
			cMensagem += "[" + cArqLocal + "] para "
			cMensagem += "[" + cArqFTP + "]"
			
			ImpLog(cMensagem,Self:getIsJob())
		EndIf
	Else
		cMensagem	:= "Nenhum Arquivo Selecionado."
		ImpLog(cMensagem,Self:getIsJob())
	EndIf

Return lOk

//-----------------------------------------------------------------
/*/{Protheus.doc} deletaArq
Realiza o arquivo do FTP

@type		Method
@author		Julio Lisboa
@since 		10/08/2016
@Return		lOk
/*/
//-----------------------------------------------------------------
Method deletaArq(cArquivo) Class ConnectFTP
	
	Local lOk			:= .F.
	Local cMensagem		:= ""
	
	Default cArquivo 	:= ""
	
	If !Empty(cArquivo)
		lOk	:= FTPErase(cArquivo)
		
		If lOk
			cMensagem	:= "Deletado o Arquivo "
			cMensagem	+= "[" + cArquivo + "]"
		Else
			cMensagem	:= "Não foi Deletado o Arquivo "
			cMensagem	+= "[" + cArquivo + "]"
		EndIf
		
		ImpLog(cMensagem,Self:getIsJob())
	Else
		cMensagem	:= "Nenhum Arquivo Selecionado."
		ImpLog(cMensagem,Self:getIsJob())
	EndIf
		
Return lOk

//-----------------------------------------------------------------
/*/{Protheus.doc}	ImpLog
Gera Informação no Log

@type		Function
@author 	Julio Lisboa - FSW TOTVS IP Campinas
@since		05/05/2016
@return		nil
/*/
//-----------------------------------------------------------------
Static Function ImpLog(cTexto,lJob)
	
	Local cData			:= DTOC(dDataBase)
	Local cHora			:= Time()
	
	Default cTexto		:= ""
	Default lJob		:= .F.
	
	If !Empty(cTexto)
		If lJob
			Conout("[" + cData + " " + cHora + "] " + NOME_FUNCAO + " - " + cTexto)
		Else
			//MsgAlert("[" + cData + " " + cHora + "] - " + cTexto,NOME_FUNCAO)
			Aviso(NOME_FUNCAO,"[" + cData + " " + cHora + "] - " + cTexto,{"OK"},1)
		EndIf
	EndIf
	
Return
