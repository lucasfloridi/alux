#INCLUDE "PROTHEUS.CH"
#DEFINE DEZEMBRO "12"

/*/{Protheus.doc} RGPEA01
Roteiro de cálculo da Previdência FUNSEJEM 

@author  Michel Sander
@since   12/10/2022
@version P12.1.023
/*/

User FUnction RGPEM01()

   LOCAL aAreaSRA  := SRA->(GetArea())
   LOCAL aAreaRGB  := RGB->(GetArea())
   LOCAL aAreas    := { GetArea(), aAreaSRA, aAreaRGB }
   LOCAL nFunParte := nEmpParte := 0
   LOCAL cVBDesFol := GetNewPar("FS_ZZVBFUN","668")
   LOCAL cVBEmpFol := GetNewPar("FS_ZZVBEMP","E60")
   LOCAL cVBPerFol := GetNewPar("FS_ZZVBFOP","800")
   LOCAL cVBValFOl := GetNewPar("FS_ZZVBFOV","801")
   LOCAL cVBAdc13p := GetNewPar("FS_ZZVB13P","889")
   LOCAL cVBAdc13v := GetNewPar("FS_ZZVB13V","803")
   LOCAL cVBAdcPlp := GetNewPar("FS_ZZVBPLP","793")
   LOCAL cVBAdcPlv := GetNewPar("FS_ZZVBPLV","808")
   LOCAL aCodFol   := {}
   LOCAL cFilProc  := xFilial("SRA")
   LOCAL lGera     := .F.
   LOCAL nSal      := 0
   
   // Carrega id de calculo
   FP_CODFOL(@aCodFol,cFilProc)
   //fSalario(@nSal,@nSalH,@nSalD,@nSalM,"A")

   // Verifica o desconto de previdência do funcionário
   If SRA->RA_ZZFUNSE != "S" .Or. SRA->RA_SITFOLH == "D"
      Return 
   EndIf

   // Verifica Horista
   If SRA->RA_CATFUNC == 'H'
      nSal := SRA->RA_SALARIO * SRA->RA_HRSMES
   Else 
      nSal := SRA->RA_SALARIO 
   EndIf 

   ZZ2->(dbSetOrder(1))
   If ZZ2->(dbSeek(xFilial()+SRA->RA_ZZCODSE))
      If ZZ2->ZZ2_PERFUN > 0
         If nSal > ZZ2->ZZ2_TETFIN 
            nSal := ZZ2->ZZ2_TETFIN
         EndIf 
         nPerFun   := ZZ2->ZZ2_PERFUN
         nPerEmp   := ZZ2->ZZ2_PEREMP
         nFunParte := Round( ( ( nSal * nPerFun ) / 100 ), 2)
         nEmpParte := Round( ( ( nSal * nPerEmp ) / 100 ), 2)
         lGera     := .T.
      EndIf
   EndIf

   If (cRot == "PRV" .Or. cRot == "SEJ") .And. lGera
      If SRA->RA_ZZTIPDE $ "1*4*5"
         // Gera os valores de Previdência      
         FGravaVerba(cVBDesFol, nFunParte, nPerFun, "FOL")
         FGravaVerba(cVBEmpFol, nEmpParte, nPerEmp, "FOL")
         // Gera os adicionais de Previdência
         If SRA->RA_ZZGADIC == "S"
            If SRA->RA_ZZPERAD > 0
               nFunParte := Round( ( ( nSal * SRA->RA_ZZPERAD ) / 100 ), 2)
               FGravaVerba(cVBPerFol, nFunParte, SRA->RA_ZZPERAD, "FOL")
            EndIf 
            If SRA->RA_ZZVALAD > 0
               FGravaVerba(cVBValFol, SRA->RA_ZZVALAD, 0, "FOL")
            EndIf 
         EndIf 
      EndIf 
   ElseIf cRot == "132" .And. lGera
      If SRA->RA_ZZTIPDE $ "2*4*6"
         If SRA->RA_ZZPER13 > 0
            nFunParte := Round( ( ( nSal * SRA->RA_ZZPER13 ) / 100 ), 2)
            fGeraVerba(cVBAdc13p,nFunParte,SRA->RA_ZZPER13,,,,,,,,.T.)
         EndIf 
         If SRA->RA_ZZVLA13 > 0
            fGeraVerba(cVBAdc13v,SRA->RA_ZZVLA13,0,,,,,,,,.T.)
         EndIf 
      EndIf 
   ElseIf cRot == "PLR" .And. lGera
      nValPlr := fBuscaPd(aCodFol[0151,1],"V")
      If SRA->RA_ZZTIPDE $ "3*5*6"
         If SRA->RA_ZZPER13 > 0
            nFunParte := Round( ( ( nValPlr * SRA->RA_ZZPER13 ) / 100 ), 2)
            fGeraVerba(cVBAdcPlp,nFunParte,SRA->RA_ZZPER13,,,,,,,,.T.)
         EndIf 
         If SRA->RA_ZZVLA13 > 0
            fGeraVerba(cVBAdcPlv,SRA->RA_ZZVLA13,0,,,,,,,,.T.)
         EndIf 
      EndIf 
   EndIf

   AEval(aAreas,{|x| RestArea(x)})

Return

/*/{Protheus.doc} fGravaVerba
Grava o valor da previdência em lançamentos mensais

@author  Michel Sander
@since   12/10/2022
@version P12.1.023
/*/

Static Function fGravaVerba(cPdGrava,nValPD,nPerc,cRotFol)

	Local dDataRef      := cToD('//')

	dDataRef	:= Ctod("01/" + Substr(cPeriodo,5,2) + "/" + Substr(cPeriodo,1,4))
	
	DbSelectarea("RGB")
	RGB->(DbSetorder(1))
	If ( !RGB->(dbSeek(xFilial('RGB')+SRA->RA_MAT+cPdGrava)) )
		RecLock("RGB",.T.)
	Else
		RecLock("RGB",.F.)			
	EndIf

	RGB->RGB_FILIAL   := FWxFilial("RGB")
	RGB->RGB_PROCES   := SRA->RA_PROCES
	RGB->RGB_PERIOD   := cPeriodo
	RGB->RGB_SEMANA   := "01"
   RGB->RGB_ROTEIR   := cRotFol
	RGB->RGB_MAT      := SRA->RA_MAT
	RGB->RGB_PD       := cPdGrava
	RGB->RGB_TIPO1    := "V"
	RGB->RGB_HORAS    := nPerc
	RGB->RGB_VALOR    := nValPD
   RGB->RGB_DTREF    := dDataRef		//dDataBase RCH->RCH_DTFIM	
	RGB->RGB_CC       := SRA->RA_CC
   RGB->RGB_TIPO2    := "G"
	RGB->RGB_ROTORI   := cRot
	RGB->(MsUnLock())

Return

