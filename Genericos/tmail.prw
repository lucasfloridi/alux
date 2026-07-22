#INCLUDE "TOTVS.CH"
#INCLUDE "RESTFUL.CH"
#Include "TBICONN.ch"
#Include "TOPCONN.ch"
#define _CR chr(13)+Chr(10)

//Exemplo TMailMessage com Imagem
//Este exemplo de uso da classe TMailMessage, visa o uso e explicação de dois métodos da classe:
//SetConfirmRead() e AddAttHTag().
//SetConfirmRead() tem como objetivo, mandar uma solicitação de resposta de Leitura para a pessoa
//que receber o e-mail, podendo ela optar por mandar ou não.
//AddAttHTag() tem como objetivo incluir tags no cabeçalho(header) da mensagem. Obs: este cabeçalho
//não é cabeçalho do corpo da mensagem.
//Neste exemplo da função usaremos uma tag para colocarmos a imagem no corpo do texto, após
//carregar a imagem, atribuimos um ID para ele, da seguinte forma: 'Content-ID: &lt;ID_siga.jpg&gt;'
//A parte em negrito significa o ID que atribuimos para a imagem, o que está entre as aspas deve
//ser seguido por padrão com o protocolo.
//Note que quando criamos o html que compõe a mensagem usamos esse ID:
//oMessage:cBody   := 'Teste&lt;br&gt;&lt;img src='cid:ID_siga.jpg'&gt;'
//Assim a imagem será carregada normalmente.
User Function tEnvMail(_cTo,_cSubject,_cBody,_cAnexo,_cCco)
	Local oServer := TMailManager():New()
	Local oMessage := TMailMessage():New()
	Local nErro := 0
	Local nErr       := 0
	Local cServer    := GetMV("MV_RELSERV")
	Local cAccount   := GetMV("MV_RELACNT")
	Local cPass      := GetMV("MV_RELPSW")
	Local lAutentica := GetMV("MV_RELAUTH")
	Local cFrom      := GetMV("MV_RELFROM")
	Local lUsaSSL    := GetMV("MV_RELSSL")
	Local lUsaTLS    := GetMV("MV_RELTLS")
	Local nTimeout   := GetMV("MV_RELTIME")
	Local nPorta     := 587
	Local nPos       := 0

	// MV_RELSERV vem no formato "servidor:porta". Separa host e porta.
	nPos := At(":", cServer)
	If nPos > 0
		nPorta  := Val(SubStr(cServer, nPos + 1))
		cServer := SubStr(cServer, 1, nPos - 1)
	EndIf

	oServer:SetUseSSL(lUsaSSL)
	oServer:SetUseTLS(lUsaTLS)
	oServer:Init( "", cServer, cAccount, cPass, 0, nPorta )
	If oServer:SetSMTPTimeout(nTimeout) <> 0
		FWAlertInfo(DTOC(Date()) + " " + Time() + " - " + "[ERROR] Falha ao definir timeout!","_003")
		ConOut(DTOC(Date())   + " " + Time() + " - " + "[ERROR] Falha ao definir timeout!")
		lRetMail := .F.
		Return .F.
	EndIf
	If( (nErro := oServer:SmtpConnect()) != 0 )
		FWAlertInfo( "Não conectou.", oServer:GetErrorString( nErro ) )
		Return .t.
	EndIf
	If lAutentica
		nErr := oServer:SmtpAuth(cAccount, cPass)
		If nErr <> 0
			MsgAlert(DTOC(Date()) + " " + Time() + " - " + "[ERROR] Falha ao autenticar: " + AllTrim(Str(nErr)) + " - " + AllTrim(oServer:getErrorString(nErr)) + "!", "_005")
			ConOut(DTOC(Date())   + " " + Time() + " - " + "[ERROR] Falha ao autenticar: " + AllTrim(Str(nErr)) + " - " + AllTrim(oServer:getErrorString(nErr)) + "!")
			oServer:SmtpDisconnect()
			lRetMail:= .F.
			Return .F.
		EndIf
	EndIf
	oMessage:Clear()
	oMessage:cFrom           := cFrom
	//Altere
	oMessage:cTo             := _cTo
	//Altere
	oMessage:cCc             := ""
	oMessage:cBcc            := _cCco
	oMessage:cSubject        := _cSubject
	oMessage:cBody           := _cBody
	oMessage:MsgBodyType( "text/html" )

	// Para solicitar confimação de envio
	//oMessage:SetConfirmRead( .T. )

	// Adiciona um anexo, nesse caso a imagem esta no root
	If !Empty(_cAnexo)
		oMessage:AttachFile( _cAnexo )
	EndIf

	// Essa tag, é a referecia para o arquivo ser mostrado no corpo, o nome declarado nela deve ser o usado no HTML
	// oMessage:AddAttHTag( 'Content-ID: &lt;mlogo.png&gt;' )
	nErro := oMessage:Send( oServer )
	If( nErro != 0 )
		FwalertError( oServer:GetErrorString( nErro ) ,"Não enviou o e-mail.")
		Return .f.
	EndIf
	nErro := oServer:SmtpDisconnect()
	If( nErro != 0 )
		FwalertError( oServer:GetErrorString( nErro ) ,"Não desconectou.")
		Return .f.
	EndIf
Return .t.
