#Include "rwmake.ch"  

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±ºSilvino Martins  - Uso Sispag - 29/01/2021                             º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Programa para tratamento do Valor do Outras Entidades.	  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±º  	                                                      			  º±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/

User Function VLRTRLOU() 

	Local _Area 	:= GetArea()
	Local _nValTot	:= 0
	Local _nEntid	:= 0
	Local nSoma		:= Strzero(nSomaValor*100,14)
	Local cQuery	:= ""
	
	// Tratamento da Query
	If Select("TMP") > 0
		TMP->( DbCloseArea() )
	EndIf
	cQuery := " SELECT SUM((E2_XOUTENT) ) VLROTUENT FROM " + RetSqlName("SE2") + " SE2 "
	cQuery += " INNER JOIN " + RetSqlName("SEA") + " SEA " 
	cQuery += " 	ON EA_FILIAL = E2_FILIAL AND EA_NUMBOR = E2_NUMBOR AND EA_NUM = E2_NUM AND EA_PARCELA = E2_PARCELA AND SEA.D_E_L_E_T_ = ' ' " 
	cQuery += " WHERE SE2.D_E_L_E_T_ = ' ' "
	cQuery += " AND E2_NUMBOR = EA_NUMBOR "
	DbUseArea(.T., "TOPCONN", TCGenQry(,,cQuery), "TMP", .F., .T.)

	_nEntid := TMP->VLROTUENT
	
	If _nEntid > 0 
	_nValTot := Str(_nEntid)                                                                     	
	_nValTot := Strzero(_nEntid*100,14)
	Else
		_nValTot := nSoma
	EndIf
	      
	RestArea(_Area)

Return(_nValTot) 
