#include "protheus.ch"
#include "report.ch"

#define DMPAPER_A4 9

/*/{Protheus.doc} RGPER01
Relatório de conferência dos valores de Previdência 

@author 		Michel Sander
@since 		15/10/2022
@version 	12.1.33
/*/    

User Function RGPER01()

	PRIVATE  nDesc, nBase, nTDesc, nTBase
   PRIVATE cAliasSRA := GetNextAlias()
   PRIVATE cVBDesFol := GetNewPar("FS_ZZVBFUN","668")
   PRIVATE cVBEmpFol := GetNewPar("FS_ZZVBEMP","E60")
   PRIVATE cVBAdcFol := GetNewPar("FS_ZZVBFAD","769")
   PRIVATE cVB13AFol := GetNewPar("FS_ZZVB13A","889")
   PRIVATE cVBPADFol := GetNewPar("FS_ZZVBPAD","793")
	PRIVATE oReport
	PRIVATE oSection
   

	oReport := ReportDef()
	oReport:PrintDialog()

Return

/*/{Protheus.doc} ReportDef
Processamento do Relatório

@author 		Michel Sander
@since 		15/10/2022
@version 	12.1.33
/*/    

Static function ReportDef()

	Local cTitulo	:= 'Valores de Previdência Privada FUNSEJEM'
	Local cBitMap := GetSrvProfString("Startpath","") + "lgmid.png"
   LOCAL cPerg   := "RGPR01"
   LOCAL aPerg   := {}
   Private aOrdem    := {OemToAnsi("Nome"),OemToAnsi("Centro de Custo"),OemToAnsi("Nome + Centro de Custo")}   //"Nome"###"Centro de Custo"###"Nome+Centro de Custo"

	// Monta os parâmetros 
	FCriaParam( cPerg, @aPerg )
	
	// Cria os parâmetros no SX1
	FPergunta( cPerg, aPerg )
   Pergunte(cPerg, .F.)

   oReport := TReport():New('RGPER01', cTitulo, cPerg , {|oReport| PrintReport(oReport)},"Impressão do Relatório de Previdência FUNSEJEM")
   If File(cBitMap)
      oReport:SayBitmap(10,20,cBitMap,80,65)
   EndIf

   oReport:oPage:nPaperSize:= 9
   oReport:nfontbody:= 6
   oReport:cfontbody:= "Courier New"
   oReport:SetLandScape()
   oReport:SetLeftMargin(5)
   oReport:SetTotalInLine(.F.)
   oReport:ShowHeader()

   If MV_PAR09 == 1
      oSection := TRSection():New(oReport,"Previdência FUNSEJEM",{cAliasSRA},aOrdem , .F., .T.)
      TRCell():New(oSection,"RA_FILIAL" ,cAliasSRA, "Filial"         ,PesqPict('SRA','RA_FILIAL') ,TamSX3("RA_FILIAL")[1]      ,,,"LEFT",,"LEFT")
      TRCell():New(oSection,"RA_MAT"    ,cAliasSRA, "Matricula"      ,PesqPict('SRA','RA_MAT')    ,TamSX3("RA_MAT")[1]	       ,,,"LEFT",,"LEFT")
      TRCell():New(oSection,"RA_NOME"   ,cAliasSRA, "Nome"           ,PesqPict('SRA','RA_NOME')   ,TamSX3("RA_NOME")[1]        ,,,"LEFT",,"LEFT")
      TRCell():New(oSection,"RA_ADMISSA",cAliasSRA, "Admissão"       ,PesqPict('SRA','RA_ADMISSA'),TamSX3("RA_ADMISSA")[1]     ,,,"LEFT",,"LEFT")
      TRCell():New(oSection,"RA_CC"     ,cAliasSRA, "Centro Custo"   ,PesqPict('SRA','RA_CC')     ,TamSX3("RA_CC")[1]	       ,,,"LEFT",,"LEFT")
      TRCell():New(oSection,"RA_ZZCODSE",cAliasSRA, "Cod. Previd."   ,PesqPict('SRA','RA_ZZCODSE'),TamSX3("RA_ZZCODSE")[1]     ,,,"LEFT",,"LEFT")
      TRCell():New(oSection,"RA_SALARIO",cAliasSRA, "Salário Base R$",PesqPict('SRA','RA_SALARIO'),TamSX3("RA_SALARIO")[1]     ,,,"LEFT",,"LEFT")
      TRCell():New(oSection,"ZZ2_PERFUN",cAliasSRA, "% Contr. Func." ,PesqPict('ZZ2','ZZ2_PERFUN'),TamSX3("ZZ2_PERFUN")[1]     ,,,"LEFT",,"LEFT")
      TRCell():New(oSection,"ZZ2_PEREMP",cAliasSRA, "% Contr. Empr." ,PesqPict('ZZ2','ZZ2_PEREMP'),TamSX3("ZZ2_PEREMP")[1]     ,,,"LEFT",,"LEFT")
      TRCell():New(oSection,"nDesc"     , ,"Valor Funcionario",/*Picture*/ ,15,/*lPixel*/,{|| nDesc    })
      TRCell():New(oSection,"nBase"     , ,"Valor Empresa",/*Picture*/ ,15,/*lPixel*/,{|| nBase    })
   Else
      oSection := TRSection():New(oReport,"Previdência FUNSEJEM",{cAliasSRA},aOrdem , .F., .T.)
      TRCell():New(oSection,"RA_FILIAL" ,cAliasSRA, "Filial"         ,PesqPict('SRA','RA_FILIAL') ,TamSX3("RA_FILIAL")[1]      ,,,"LEFT",,"LEFT")
      TRCell():New(oSection,"RA_CC"     ,cAliasSRA, "Centro Custo"   ,PesqPict('SRA','RA_CC')     ,TamSX3("RA_CC")[1]	       ,,,"LEFT",,"LEFT")
      TRCell():New(oSection,"RA_ZZCODSE",cAliasSRA, "Cod. Previd."   ,PesqPict('SRA','RA_ZZCODSE'),TamSX3("RA_ZZCODSE")[1]     ,,,"LEFT",,"LEFT")
      TRCell():New(oSection,"nDesc"     , ,"Valor Centro Custo",/*Picture*/ ,15,/*lPixel*/,{|| nDesc    })
      TRCell():New(oSection,"nBase"     , ,"Valor Empresa",/*Picture*/ ,15,/*lPixel*/,{|| nBase    })
   EndIf 

   oSection:SetTotalInLine(.F.)
   oSecTot := TRSection():New(oReport,"Totalizadores","", NIL, .F., .T.)
   TRCell():New(oSecTot,'nTDesc'	,"",'Total Funcionário' , PesqPict('RGB','RGB_VALOR'),15	, ,{|| nTDesc },"RIGHT",,"LEFT")
   TRCell():New(oSecTot,'nTBase'	,"",'Total Empresa'     , PesqPict('RGB','RGB_VALOR'),15	, ,{|| nTBase },"RIGHT",,"LEFT")
   //oSecTot:SetHeaderSection(.F.)

Return ( oReport )

/*/{Protheus.doc} PrintReport
Impressão do relatório

@author 		Michel Sander
@since 		15/10/2022
@version 	12.1.33

/*/
Static Function PrintReport(oReport)

	Local oSection  := oReport:Section(1)
   Local oTotal    := oReport:Section(2)
	Local nXi       := 0
   Local nCount    := 0
   Local cCond     := ""
   Private nOrdem  := oSection:GetOrder()

	oSection:init()

   If nOrdem == 1
      cOrdem := "%SRA.RA_FILIAL,SRA.RA_NOME%"
   ElseIf nOrdem == 2
      cOrdem := "%SRA.RA_FILIAL,SRA.RA_CC%"
   ElseIf nOrdem == 3
      cOrdem := "%SRA.RA_FILIAL,SRA.RA_NOME,SRA.RA_CC%"
   EndIf

   //cCond     := IIf(MV_PAR09 == 1,"%ORDER BY RA_FILIAL, RA_MAT%","%ORDER BY RA_FILIAL, RA_CC%")
   BEGINSQL Alias cAliasSRA 
      SELECT RA_FILIAL, RA_MAT, RA_NOME, RA_CC, RA_ADMISSA, RA_SALARIO, RA_ZZCODSE, SRA.R_E_C_N_O_ SRARECNO, ZZ2.* 
               FROM %Table:SRA% SRA
               INNER JOIN %Table:ZZ2% ZZ2
                     ON SRA.RA_FILIAL = ZZ2.ZZ2_FILIAL 
                     AND SRA.RA_ZZCODSE = ZZ2.ZZ2_COD
                     AND ZZ2.%NotDel%
      WHERE RA_FILIAL   BETWEEN %Exp:MV_PAR01% AND %Exp:MV_PAR02%
            AND RA_MAT  BETWEEN %Exp:MV_PAR03% AND %Exp:MV_PAR04%
            AND RA_CC   BETWEEN %Exp:MV_PAR05% AND %Exp:MV_PAR06%
            AND RA_SITFOLH <> 'D'
            AND RA_ZZFUNSE = 'S'
            AND SRA.%NotDel%
           //%Exp:cCond%
            ORDER BY %exp:cOrdem%
            ENDSQL
   
   TcSetField(cAliasSRA,"RA_ADMISSA","D",TamSX3("RA_ADMISSA")[1],TamSX3("RA_ADMISSA")[2])
   nTDesc := nTBase := 0
   (cAliasSRA)->(dbEval({|| nCount++}))
   (cAliasSRA)->(dbGotop())
   DbSelectarea("RGB")
   RGB->(DbSetorder(1))

   oReport:SetMeter(nCount)
	While (cAliasSRA)->(!EOf())

      If MV_PAR09 == 1 
         cFilUso := (cAliasSRA)->RA_FILIAL 
         cMatUso := (cAliasSRA)->RA_MAT
      Else 
         cFilUso := (cAliasSRA)->RA_FILIAL 
         cMatUso := (cAliasSRA)->RA_CC
      EndIf 

      cCond := "(cAliasSRA)->RA_FILIAL+(cAliasSRA)->RA_MAT == cFilUso+cMatUso"
      While (cAliasSRA)->(!Eof()) .And. &cCond

         SRA->(dbGoto((cAliasSRA)->SRARECNO))
         oReport:IncMeter()

         nDesc := nBase := nVal1 := nVal2 := 0
         If RGB->(dbSeek(xFilial('RGB')+SRA->RA_MAT+cVBDesFol)) 
            nDesc := Transform(RGB->RGB_VALOR,"@E 99,999,999.99")
            nTDesc += RGB->RGB_VALOR
            nVal1 := RGB->RGB_VALOR
         endif
         If RGB->(dbSeek(xFilial('RGB')+SRA->RA_MAT+cVBEmpFol)) 
            nBase := Transform(RGB->RGB_VALOR,"@E 99,999,999.99")
            nTBase += RGB->RGB_VALOR
            nVal2 := RGB->RGB_VALOR
         endif

         If nVal1+nVal2 <= 0
            (cAliasSRA)->(dbSkip())
            Loop 
         EndIf 

         oSection:Printline()
	      oSection:lHeaderSection := (oReport:nDevice <> 4) //Não imprime cabeçalho novamente se for impressao em excel
         (cAliasSRA)->(dbSkip())

      End 

      If MV_PAR09 == 2
         oReport:ThinLine()
         oReport:PrintText("")
      EndIf 

	EndDo

   (cAliasSRA)->(dbCloseArea())
   oTotal:Init()
   oTotal:Printline()
   oTotal:Finish()   
	oReport:ThinLine()
	oReport:PrintText("")
	oSection:Finish()

Return

/*/{Protheus.doc} FCriaParam
Função que os parâmetros do relatório

@author	   Michel Sander
@since	   15/10/2022
@return		Nil
/*/

Static Function FCriaParam( cPerg, aPerg )
	
	Aadd(aPerg,{cPerg,"Filial De "		   ,"C",13,0,"G",""	,"AK5"	,"","","","",""})
	Aadd(aPerg,{cPerg,"Filial Ate "		   ,"C",13,0,"G",""	,"AK5"	,"","","","",""})
	Aadd(aPerg,{cPerg,"Matricula De "		,"C",06,0,"G",""	,"SRA"	,"","","","",""})
	Aadd(aPerg,{cPerg,"Matricula Ate "		,"C",06,0,"G",""  ,"SRA"	,"","","","",""})
	Aadd(aPerg,{cPerg,"Centro Custo De "	,"C",09,0,"G",""	,"CTT"	,"","","","",""})
	Aadd(aPerg,{cPerg,"Centro Custo Ate "	,"C",09,0,"G",""	,"CTT"	,"","","","",""})
	Aadd(aPerg,{cPerg,"Cod. Previd. De "	,"C",06,0,"G",""	,"ZZ2"	,"","","","",""})
	Aadd(aPerg,{cPerg,"Cod. Previd. Ate "	,"C",06,0,"G",""	,"ZZ2"	,"","","","",""})
	Aadd(aPerg,{cPerg,"Tipo Relatório "	   ,"N",01,0,"C",""	,""   	,"Analitico","Sinteico","","",""})

Return()

/*/{Protheus.doc} FPergunta

Função que cria as perguntas do relatório

@author	  	Michel Sander
@since		15/10/2022
@return		Nil
/*/
//-------------------------------------------------------------------
Static Function FPergunta(cGrupo, aPerguntas)
	
	Local aArea      := GetArea()
	Local nXZ := 0
	Local nXY := 0
	
	//Abrindo Area Arquivo Trabalho Grupo Perguntas / Parametros: SX1 ...
	DbSelectArea("SX1")
	DbSetOrder(1) //Filial+Grupo+Orgem.
	
	//Varrendo Grupo Perguntas: ...
	For nxZ := 1 To Len(aPerguntas)
		
		// Adequação para Versão 10, Grupo agora tem 10 caracteres.
		RecLock("SX1", !DbSeek(cGrupo+Space(10 - Len(cGrupo))+StrZero(nxZ,2)))
		SX1->X1_GRUPO   :=  cGrupo
		SX1->X1_ORDEM   :=  StrZero(nxZ,2)
		SX1->X1_PERGUNT :=  aPerguntas[nxZ,2]
		SX1->X1_VARIAVL :=  "Mv_Ch"+IIf(nxZ <=9,AllTrim(Str(nxZ)),Chr(nxZ + 55))
		SX1->X1_TIPO    :=  aPerguntas[nxZ,3]
		SX1->X1_TAMANHO :=  aPerguntas[nxZ,4]
		SX1->X1_DECIMAL :=  aPerguntas[nxZ,5]
		SX1->X1_GSC     :=  aPerguntas[nxZ,6]
		SX1->X1_VAR01   :=  "Mv_Par"+StrZero(nxZ,2)
		SX1->X1_VALID   :=  aPerguntas[nxZ,7]
		SX1->X1_F3      :=  aPerguntas[nxZ,8]

		If (aPerguntas[nxZ,6] == "C")
			For nxY := 9 To 13
				If (aPerguntas[nxZ,nxY] == "")
					Exit
				Else
					Do Case
					Case ((nxY - 8) == 1)
						SX1->X1_DEF01 := aPerguntas[nxZ,nxY]
					Case ((nxY - 8) == 2)
						SX1->X1_DEF02 := aPerguntas[nxZ,nxY]
					Case ((nxY - 8) == 3)
						SX1->X1_DEF03 := aPerguntas[nxZ,nxY]
					Case ((nxY - 8 ) == 4)
						SX1->X1_DEF04 := aPerguntas[nxZ,nxY]
					Case ((nxY - 8) == 5)
						SX1->X1_DEF05 := aPerguntas[nxZ,nxY]
					EndCase
				EndIf
			Next
		EndIf

		SX1->(MsUnLock())

	Next nxZ
	
	//Restaura Ambiente Origem.
	RestArea(aArea)
	
Return Nil
