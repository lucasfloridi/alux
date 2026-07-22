#include "totvs.ch"

#define PROCESSED 				"processed"
#define ERROR 					"errors"

/*/{Protheus.doc} User Function ImpTxtBal
	Rotina responsável pela importação de arquivos TXT da balança, obtidos a partir de um servidor FTP.
	@type  Function
	@author Diogo Mesquita
	@since 12/01/2021
	@version version
	@param param_name, param_type, param_descr
	@return return_var, return_type, return_description
	@example
	(examples)
	@see (links_or_references)
/*/
User Function ImpTxtBal( aParamJob )

	Private lJob			:= .F.
	Default aParamJob		:= {}
	
	If Len(aParamJob) > 0
		lJob		:= .T.
	EndIf
	
	// Seta a empresa quando for via JOB
	If lJob
		RpcSetType( 3 )
		RpcSetEnv(aParamJob[1],aParamJob[2])
	EndIf
	
	If lJob
		processTXT()
	Else
		FWMsgRun( ,{ || processTXT() } , ProcName() , "Processando, aguarde..."  )
	EndIf

	// Desloga da empresa quando for via JOB
	If lJob
		RpcClearEnv()
	EndIf

Return

/*/{Protheus.doc} processTXT
	Obtém os arquivos TXT local ou do servidor e executa o processamento.
	@type  Static Function
	@author Diogo Mesquita
	@since 12/01/2021
	@version version
	@param param_name, param_type, param_descr
	@return return_var, return_type, return_description
	@example
	(examples)
	@see (links_or_references)
	/*/
Static Function processTXT()

	Local cTXT			:= ""
	Local aTXTs			:= {}
	Local aCriaDir		:= {}
	Local cArqTXT		:= ""
	Local cDirTXT		:= ""
	Local nI			:= 0
	Local cDirArqSel	:= ""
	Local lManual		:= .F.
	Local oDlg			:= NIL
	Local oFont			:= NIL
	Local oMemo			:= NIL
	Local cMask     	:= "Arquivos Texto" + "(*.TXT)|*.txt|"
	
	AutoGrLog( Replicate( "-", 128 ) )
	AutoGrLog( "LOG DE IMPORTAÇÃO" )
	AutoGrLog( Replicate( "-", 128 ) )
	
	If !lJob
		If MsgYesNo("Deseja importar os arquivos TXT a partir de diretório local ?",FunDesc())
			lManual := .T.
			cDirArqSel := cGetFile( 'Arquivos (*.txt) | *.txt' , "Selecione o diretório de arquivos TXT",1,"C:\",.T.,GETF_LOCALHARD + GETF_RETDIRECTORY,.F.)
			aTXTs := Directory( cDirArqSel + "*.txt" , "D" )

			If Len(aTXTs) > 0
				// Cria os diretórios
				aCriaDir	:= criaDiretorios()
				If aCriaDir[01]
					cDirTXT	:= aCriaDir[02]
					For nI := 1 to Len(aTXTs)
						cArqTXT		:= aTXTs[nI,1]

						If CpyT2S(cDirArqSel + cArqTXT, cDirTXT, .F.)
							nHandle := FT_FUse(cDirTXT + cArqTXT)

							If nHandle == -1
								moveFile(cDirTXT, cArqTXT, ERROR)
								MsgAlert("Erro ao abrir o arquivo " + cArqTXT,FunDesc())
							Else
								FT_FGoTop()
								While !FT_FEOF()
									cTXT    := AnsiToOEM(FT_FReadLn())  
									cTXT    := OEMTOANSI(cTXT)
									gravaTXT( cTXT , cDirTXT, cArqTXT )
									FT_FSKIP()
								EndDo
								// Fecha o Arquivo		
								FT_FUse()
								moveFile(cDirTXT, cArqTXT, PROCESSED)
							EndIf
						EndIf
					Next nI
				Else
					MsgAlert("Falha na criação dos diretórios.",FunDesc())	
				EndIf
			Else
				MsgAlert("Nenhum arquivo TXT localizado para importação.",FunDesc())
			EndIf
		EndIf
	EndIf

	If !lManual
		// Cria os diretórios
		aCriaDir	:= criaDiretorios()
		If aCriaDir[01]
			cDirTXT	:= aCriaDir[02]
			aTXTs := Directory( cDirTXT + "*.txt" , "D" )

			If Len(aTXTs) > 0
				For nI := 1 to Len(aTXTs)
					cArqTXT		:= aTXTs[nI,1]
				
					nHandle := FT_FUse(cDirTXT + cArqTXT)
					If nHandle == -1
						moveFile(cDirTXT, cArqTXT, ERROR)
						If lJob
							Conout( "Balanca - Erro ao abrir o arquivo " + cArqTXT + "." )
						Else
							MsgAlert("Erro ao abrir o arquivo " + cArqTXT,FunDesc())
						EndIf
					Else
						FT_FGoTop()
						While !FT_FEOF()
							cTXT := FT_FReadLn()  
							gravaTXT( cTXT , cDirTXT, cArqTXT )
							FT_FSKIP()
						Enddo
						// Fecha o Arquivo		
						FT_FUse()	
						moveFile(cDirTXT, cArqTXT, PROCESSED)
					EndIf
				Next
			Else
				If lJob
					Conout( "Balanca - Nenhum arquivo TXT localizado para importação." )
				Else
					MsgAlert("Nenhum arquivo TXT localizado para importação.",FunDesc())
				EndIf
			EndIf
		Else
			If lJob
				Conout( "Balanca - Falha na criação dos diretórios." )
			Else
				MsgAlert("Falha na criação dos diretórios.",FunDesc())
			EndIf
		EndIf
	EndIf

	AutoGrLog( Replicate( "-", 128 ) )
	
	If !lJob

		cTexto := LeLog()

		Define Font oFont Name "Mono AS" Size 5, 12

		Define MsDialog oDlg Title "Importação concluída." From 3, 0 to 340, 417 Pixel

		@ 5, 5 Get oMemo Var cTexto Memo Size 200, 145 Of oDlg Pixel
		oMemo:bRClicked := { || AllwaysTrue() }
		oMemo:oFont     := oFont

		Define SButton From 153, 175 Type  1 Action oDlg:End() Enable Of oDlg Pixel // Apaga
		Define SButton From 153, 145 Type 13 Action ( cFile := cGetFile( cMask, "" ), If( cFile == "", .T., ;
		MemoWrite( cFile, cTexto ) ) ) Enable Of oDlg Pixel

		Activate MsDialog oDlg Center

	EndIf

Return

/*/{Protheus.doc} criaDiretorios
	Cria os diretorios nas pastas do Protheus.
	@type  Static Function
	@author Diogo Mesquita
	@since 12/01/2021
	@version version
	@param param_name, param_type, param_descr
	@return return_var, return_type, return_description
	@example
	(examples)
	@see (links_or_references)
	/*/
Static Function criaDiretorios()
	
	Local lRet			:= .T.
	Local cDirTXT		:= "\system\Balanca"
	Local cDirAnoMes 	:= "\" + SubStr( DTOS(dDataBase) , 1 , 6 )
	Local cDirDia		:= "\" + cValToChar( Day ( dDataBase ) )
	Local cDirFinal		:= ""
	
	// Cria o diretório na protheus_data
	If !(ExistDir(cDirTXT))
		lRet 	:= MakeDir(cDirTXT) == 0
	Else
		lRet	:= .T.
	EndIf
	
	// Cria o diretório Ano / Mês
	If lRet
		If !(ExistDir(cDirTXT + cDirAnoMes))
			lRet := MakeDir(cDirTXT + cDirAnoMes) == 0
		Else
			lRet	:= .T.
		EndIf
	Else
		lRet	:= .T.
	EndIf

	// Cria o diretório Mês / Dia
	If lRet
		If !(ExistDir(cDirTXT + cDirAnoMes + cDirDia))
			lRet := MakeDir(cDirTXT + cDirAnoMes + cDirDia) == 0
		Else
			lRet	:= .T.
		EndIf
	Else
		lRet	:= .T.
	EndIf
	
	// Retorna o diretório completo
	If lRet
		cDirFinal	:= cDirTXT + cDirAnoMes + cDirDia + "\"
	EndIf
	
Return { lRet , cDirFinal }

/*/{Protheus.doc} gravaTXT
	Realiza a gravação dos dados do arquivo TXT em tabela personalizada.
	@type  Static Function
	@author Diogo Mesquita
	@since 12/01/2021
	@version version
	@param param_name, param_type, param_descr
	@return return_var, return_type, return_description
	@example
	(examples)
	@see (links_or_references)
	/*/
Static Function gravaTXT( cTXT , cDirTXT, cArqTXT )
	
	Local nPesoIni		:= Val(Substr(cTXT,015,006))
	Local nPesoFim		:= Val(Substr(cTXT,021,006))
	Local nPesoLiq		:= Val(Substr(cTXT,027,006))
	Local dDtPesoIni	:= CtoD(Substr(cTXT,034,010))
	Local cHrPesoIni	:= Substr(cTXT,045,008)
	Local dDtPesoFim	:= CtoD(Substr(cTXT,054,010))
	Local cHrPesoFim	:= Substr(cTXT,065,008)
	Local cCodItem		:= Substr(cTXT,101,015)
	Local cTicket		:= Padr(SubStr(cArqTXT,1,At(".",cArqTXT)-1),TamSx3("ZZ1_SEQUEN")[1])
	
	BEGIN TRANSACTION
		DbSelectArea("ZZ1")
		ZZ1->(DbSetOrder(1)) // ZZ1_FILIAL + ZZ1_SEQUEN
		If !ZZ1->(DbSeek(xFilial("ZZ1") + cTicket))
			If RecLock("ZZ1",.T.)
				ZZ1->ZZ1_FILIAL	:= xFilial("ZZ1")
				ZZ1->ZZ1_SEQUEN	:= cTicket
				ZZ1->ZZ1_PESINI := nPesoIni
				ZZ1->ZZ1_PESFIM := nPesoFim
				ZZ1->ZZ1_PESLIQ := nPesoLiq
				ZZ1->ZZ1_DTPEIN := dDtPesoIni
				ZZ1->ZZ1_HRPEIN := cHrPesoIni
				ZZ1->ZZ1_DTPEFI := dDtPesoFim
				ZZ1->ZZ1_HRPEFI := cHrPesoFim
				ZZ1->ZZ1_CODITE := cCodItem
				ZZ1->ZZ1_ARQTXT	:= cDirTXT + cArqTXT
				ZZ1->(MsUnlock())
				AutoGrLog( "Ticket " + cTicket + " importado com sucesso!" + CRLF )
			EndIf
		Else
			AutoGrLog( "Ticket " + cTicket + " já existe!" + CRLF )
		EndIf
	END TRANSACTION
	
Return

/*/{Protheus.doc} moveFile
	Função para mover o arquivo para outra pasta após o processamento.
	@type  Static Function
	@author Diogo Mesquita
	@since 12/01/2021
	@version version
	@param param_name, param_type, param_descr
	@return return_var, return_type, return_description
	@example
	(examples)
	@see (links_or_references)
	/*/
Static Function moveFile(cFolder, cFile, cType)
	local cBarWindows	:= "\"
	local cBarLinux		:=  "/"
	Local cBarr			:= Iif(IsSrvUnix(), cBarLinux, cBarWindows)
	Local cOldFile		:= ""
	Local cNewFile  	:= ""
	Local cMsg			:= ""
	Local lRet 			:= .F.

	If !( Right(cFolder,01) $ cBarWindows + ";" + cBarLinux )
		cFolder += cBarr
	Endif	

	cType += cBarr
	
	cOldFile := cFolder + Alltrim(cFile)
	cNewFile := cFolder + cType + Alltrim(cFile)
	
	Begin Sequence
		
		MontaDir(cFolder+cType)
		
		If !ExistDir(cFolder+cType) .and. (MakeDir(cFolder+cType) != 0)
			cMsg := "Falha ao criar diretório " + cFolder + cType
			Break
		Endif
		
		If frename(cOldFile, cNewFile) == -1
			fErase(cNewFile)
			If frename(cOldFile, cNewFile) == -1
				cMsg := "Falha ao mover arquivo '" + cOldFile + "' para o arquivo '" + cNewFile + "'"
				Break
			Endif
		Endif
		
		lRet := .T.
		
	End Sequence
	
Return ({lRet,cMsg})

/*/{Protheus.doc} LeLog
	Função de leitura do LOG gerado.
	@type  Static Function
	@author Diogo Mesquita
	@since 27/02/2021
	@version version
	@param param_name, param_type, param_descr
	@return return_var, return_type, return_description
	@example
	(examples)
	@see (links_or_references)
	/*/
Static Function LeLog()
	Local cRet  := ""
	Local cFile := NomeAutoLog()
	Local cAux  := ""

	FT_FUSE( cFile )
	FT_FGOTOP()

	While !FT_FEOF()

		cAux := FT_FREADLN()

		If Len( cRet ) + Len( cAux ) < 1048000
			cRet += cAux + CRLF
		Else
			cRet += CRLF
			cRet += Replicate( "=" , 128 ) + CRLF
			cRet += "Tamanho de exibição maxima do LOG alcançado." + CRLF
			cRet += "LOG Completo no arquivo " + cFile + CRLF
			cRet += Replicate( "=" , 128 ) + CRLF
			Exit
		EndIf

		FT_FSKIP()
	End

	FT_FUSE()

Return cRet
