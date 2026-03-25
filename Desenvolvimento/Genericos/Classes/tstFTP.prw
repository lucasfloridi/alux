#Include 'Protheus.ch'

User Function tstFTP()

	Local cFTP		:= "189.20.97.122"
	Local cUser		:= "Totvs"
	Local cPassW	:= "Totvs@2018"
	Local nPorta	:= 21
	Local oFTP		:= ConnectFTP():New()
	
	oFTP:setServer( cFTP )
	oFTP:setUser( cUser )
	oFTP:setSenha( cPassW )
	oFTP:setPorta( nPorta )
	
	If oFTP:Connect()
		MsgAlert("Conexão Ok!")
		oFTP:Disconnect()
	Else
		MsgAlert("ERRO Conexão!")
	EndIf

Return
