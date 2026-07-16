
#INCLUDE "PROTDEF.CH"
#INCLUDE "RWMAKE.CH" 

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±³Programa  ³ SANTTRIB    												   ±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ CNAB SISPAG - Banco do SANTANDER (Pagamento de Tributos)   ³±±
±±			 ³ Gps (Modalidade 17)										   ±±
±±			 ³ Darf Normal (Modalidade 16)								   ±±
±±			 ³ Darf Simples (Modalidade 18)								   ±±
±±			 ³ Gare SP (ICMS/DR/ITCMD) (Modalidade 22)					   ±±
±±			 ³ Ipva (Modalidade 25)										   ±±
±±			 ³ Dpvat (Modalidade 26)									   ±±
±±			 ³ Licenciamento (Modalidade 27)							   ±±
±±			 ³ Fgts (Modalidade 35)										   ±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±³ Silvino Martins FIT - Uso Cnab de Tributos SANTANDER - 29/01/2021      ±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/

User Function SANTTRIB()                      

Local _cRet		:=""
Local _cCodUF	:=""
Local _cCodMun	:=""
Local _cCodPla	:=""

If SEA->EA_MODELO$"17" //Pagamento GPS
	_cRet:=PadL(Substr(SE2->E2_XESCRT,1,4),6,"0")							//Codigo do pagamento / pos. 111-116	
	_cRet+="02"																//Tipo de Inscr. Contribuinte / pos. 117-118
	_cRet+=PADL(ALLTRIM(SM0->M0_CGC),14,"0")								//Identificação do Contribuinte - CNPJ/CGC/CPF / 119-132
	_cRet+="17"																//Cod. pgto do Contribuinte / pos. 133-134
	_cRet+=STRZERO(MONTH(SE2->E2_XCOMPET),2)+STR(YEAR(SE2->E2_XCOMPET),4)	//Competencia / pos. 135-140
	_cRet+=STRZERO(SE2->E2_SALDO*100,15)									//Valor de pagamento do INSS / 141-155
	_cRet+=STRZERO(SE2->E2_ACRESC*100,15)									//Valor somado ao valor do documento / 156-170
	_cRet+=REPL("0",15)														//Atualização monetaria /	171-185
	_cRet+=Space(45)														//Uso da empresa / 186-230
ElseIf SEA->EA_MODELO$"16" //Pagamento de Darf Normal
	_cRet:=PadL(Substr(SE2->E2_XESCRT,1,4),6,"0")									//Codigo do pagamento / pos. 111-116		
	_cRet+="02"																//Tipo de Inscr. Contribuinte / pos. 117-118
	_cRet+=PADL(ALLTRIM(SM0->M0_CGC),14,"0")								//Identificação do Contribuinte - CNPJ/CGC/CPF / 119-132
	_cRet+="16"																//Cod. pgto do Contribuinte / pos. 133-134	
	_cRet+=StrZero(Day(SE2->E2_XCOMPET),2)+STRZERO(MONTH(SE2->E2_XCOMPET),2)+STR(YEAR(SE2->E2_XCOMPET),4) //Competencia / 135-142
	_cRet+=IIF(EMPTY(SE2->E2_XIDDARF),STRZERO(0,17),STRZERO(VAL(SUBSTR(SE2->E2_XIDDARF,1,17)),17))	//Numero de referencia / 047-063									//Numero de referencia / 143-159
	_cRet+=STRZERO(SE2->E2_SALDO*100,15)									//Valor Principal / 160-174
	_cRet+=STRZERO(SE2->E2_MULTA*100,15)									//Valor da Multa / 175-189
	_cRet+=STRZERO(SE2->E2_ACRESC*100,16)									//Valor de Juros+Encargos / 190-204
	_cRet+=StrZero(Day(SE2->E2_VENCREA),2)+STRZERO(MONTH(SE2->E2_VENCREA),2)+STR(YEAR(SE2->E2_VENCREA),4)//Data de Vencimento / 205-212
	_cRet+=space(18)		                              					// Brancos / 213-230
ElseIf SEA->EA_MODELO$"18"//Pagamento de Darf Simples
	_cRet:="006106"															//Codigo do pagamento / pos. 111-116		
	_cRet+="02"																//Tipo de Inscr. Contribuinte / pos. 117-118
	_cRet+=PADL(ALLTRIM(SM0->M0_CGC),14,"0")								//Identificação do Contribuinte - CNPJ/CGC/CPF / 119-132
	_cRet+="18"																//Cod. pgto do Contribuinte / pos. 133-134	
	_cRet+=StrZero(Day(SE2->E2_XCOMPET),2)+STRZERO(MONTH(SE2->E2_XCOMPET),2)+STR(YEAR(SE2->E2_XCOMPET),4) //Competencia / 135-142
	_cRet+=STRZERO(SE2->E2_XESVRBA*100,15)									//Valor da receita bruta acumulada / 143-157
	_cRet+=STRZERO(SE2->E2_XESPRB,7)									  		//Percentual da receita Bruta / 158-164
	_cRet+=STRZERO(SE2->E2_SALDO*100,15)									//Valor Principal / 165-179
	_cRet+=STRZERO(SE2->E2_MULTA*100,15)									//Valor da Multa / 180-194
	_cRet+=STRTRAN(STRZERO(SE2->E2_JUROS+SE2->E2_ACRESC*100,15,2),".","")	//Valor de Juros+Encargos / 195-209
	_cRet+=space(21)		                              					// Brancos / 210-230
ElseIf SEA->EA_MODELO$"22" .Or. SEA->EA_MODELO$"23" .Or. SEA->EA_MODELO$"24"//Pagamento de Gare-SP (ICMS (22)/DR (23) /ITCMD(24))
	_cRet:=PadL(Substr(SE2->E2_CODRET,1,4),6,"0")							//Codigo do pagamento / pos. 111-116		
	_cRet+="02"																//Tipo de Inscr. Contribuinte / pos. 117-118
	_cRet+=PADL(ALLTRIM(SM0->M0_CGC),14,"0")								//Identificação do Contribuinte - CNPJ/CGC/CPF / 119-132
	_cRet+="22"																//Cod. pgto do Contribuinte / pos. 133-134	
	_cRet+=StrZero(Day(SE2->E2_VENCREA),2)+STRZERO(MONTH(SE2->E2_VENCREA),2)+STR(YEAR(SE2->E2_VENCREA),4)//Data de Vencimento / 135-142
	_cRet+=PADL(ALLTRIM(SM0->M0_INSC),12,"0")								//Identificação do Contribuinte - IE / 143-154	
	_cRet+=STRZERO(SE2->E2_XESCDA,13)									    //Numero da divida ativa / 155-167	
	_cRet+=STRZERO(MONTH(SE2->E2_XCOMPET),2)+STR(YEAR(SE2->E2_XCOMPET),4)	//Competencia / pos. 168-173
	_cRet+=STRZEROSTRZERO(SE2->E2_XESNPN,13)								//Numero da parcela / 174-186
	_cRet+=STRZERO(SE2->E2_SALDO*100,15)									//Valor de pagamento / 187-201
	_cRet+=STRZERO((SE2->E2_JUROS+SE2->E2_ACRESC)*100,14)					//Valor de Juros+Encargos / 202-215
	_cRet+=STRZERO(SE2->E2_MULTA*100,14)									//Valor da Multa / 216-229
	_cRet+=space(1)			                              					// Brancos / 230-230
ElseIf SEA->EA_MODELO$"25" //Pagamentto de IPVA
	_cRet:=Padl(Substr(SE2->E2_XESCRT,1,4),6,"0")							//Codigo da Receita do Tributo / pos. 111-116
	_cRet+=STRZERO(val(SE2->E2_ESTIC),02)									//Tipo de Identificação do Contribuinte / pos. 117-118
	_cRet+=PADL(ALLTRIM(SM0->M0_CGC),14,"0")								//Identificação do Contribuinte - CNPJ/CGC/CPF / 119-132
	_cRet+=Alltrim(SEA->EA_MODELO)											//Codigo de identificação do contribuinte - Modelo de pagamento / 133-134
	_cRet+=STR(YEAR(SE2->E2_XCOMPET),4)										//Competencia / 135-138
	_cCodRen:=Posicione("DA3",1,xFilial("DA3")+SE2->E2_XESCODVE,"DA3_RENAVA")
	_cRet+=PADL(ALLTRIM(_cCodVei),9,"0")									//Codigo do Renavan / 139-147
	_cCodUF:=Posicione("DA3",1,xFilial("DA3")+SE2->E2_XESCODVE,"DA3_ESTPLA")	
	_cRet+=_cCodUF															//UF do estado do veiculo / 148-149
	_cCodMun:=Posicione("DA3",1,xFilial("DA3")+SE2->E2_XESCODVE,"DA3_CODMUN")	
	_cRet+=_cCodMun															//Codigo do Municipio / 150-154
	_cCodPla:=Posicione("DA3",1,xFilial("DA3")+SE2->E2_XESCODVE,"DA3_PLACA")	
	_cRet+=_cCodPla                                                         //Placa do Veiculo / 155-161
	_cRet+=Alltrim(SE2->E2_XESOPIP)											//Codigo da cond. de pgto / 162-162
	_cRet+=Space(68)														//Exclusivo Febraban / 163-230		
ElseIf SEA->EA_MODELO$"27" //Pagamento DPVAT
	_cRet:=Padl(Substr(SE2->E2_XESCRT,1,4),6,"0")							//Codigo da Receita do Tributo / pos. 111-116
	_cRet+=STRZERO(val(SE2->E2_ESTIC),02)									//Tipo de Identificação do Contribuinte / pos. 117-118
	_cRet+=PADL(ALLTRIM(SM0->M0_CGC),14,"0")								//Identificação do Contribuinte - CNPJ/CGC/CPF / 119-132
	_cRet+=Alltrim(SEA->EA_MODELO)											//Codigo de identificação do contribuinte - Modelo de pagamento / 133-134
	_cRet+=STR(YEAR(SE2->E2_XCOMPET),4)										//Competencia / 135-138
	_cCodRen:=Posicione("DA3",1,xFilial("DA3")+SE2->E2_XESCODVE,"DA3_RENAVA")
	_cRet+=PADL(ALLTRIM(_cCodVei),9,"0")									//Codigo do Renavan / 139-147
	_cCodUF:=Posicione("DA3",1,xFilial("DA3")+SE2->E2_XESCODVE,"DA3_ESTPLA")	
	_cRet+=_cCodUF															//UF do estado do veiculo / 148-149
	_cCodMun:=Posicione("DA3",1,xFilial("DA3")+SE2->E2_XESCODVE,"DA3_CODMUN")	
	_cRet+=_cCodMun															//Codigo do Municipio / 150-154
	_cCodPla:=Posicione("DA3",1,xFilial("DA3")+SE2->E2_XESCODVE,"DA3_PLACA")	
	_cRet+=_cCodPla                                                         //Placa do Veiculo / 155-161
	_cRet+=Alltrim(SE2->E2_XESOPIP)											//Codigo da cond. de pgto / 162-162
	_cRet+=Space(68)														//Exclusivo Febraban / 163-230		
ElseIf SEA->EA_MODELO$"26" // Pagamento de Licenciamento
	_cRet:=Padl(Substr(SE2->E2_XESCRT,1,4),6,"0")							//Codigo da Receita do Tributo / pos. 111-116
	_cRet+=STRZERO(val(SE2->E2_ESTIC),02)									//Tipo de Identificação do Contribuinte / pos. 117-118
	_cRet+=PADL(ALLTRIM(SM0->M0_CGC),14,"0")								//Identificação do Contribuinte - CNPJ/CGC/CPF / 119-132
	_cRet+=Alltrim(SEA->EA_MODELO)											//Codigo de identificação do contribuinte - Modelo de pagamento / 133-134
	_cRet+=STR(YEAR(SE2->E2_XCOMPET),4)										//Competencia / 135-138
	_cCodRen:=Posicione("DA3",1,xFilial("DA3")+SE2->E2_XESCODVE,"DA3_RENAVA")
	_cRet+=PADL(ALLTRIM(_cCodVei),9,"0")									//Codigo do Renavan / 139-147
	_cCodUF:=Posicione("DA3",1,xFilial("DA3")+SE2->E2_XESCODVE,"DA3_ESTPLA")	
	_cRet+=_cCodUF															//UF do estado do veiculo / 148-149
	_cCodMun:=Posicione("DA3",1,xFilial("DA3")+SE2->E2_XESCODVE,"DA3_CODMUN")	
	_cRet+=_cCodMun															//Codigo do Municipio / 150-154
	_cCodPla:=Posicione("DA3",1,xFilial("DA3")+SE2->E2_XESCODVEI,"DA3_PLACA")	
	_cRet+=_cCodPla                                                         //Placa do Veiculo / 155-161
	_cRet+=Alltrim(SE2->E2_XESOPIP)											//Codigo da cond. de pgto / 162-162
	_cRet+=Alltrim(SE2->E2_XESCRVL)											//Opção de Retirada do CRVL / 163-163		
	_cRet+=Space(67)														//Exclusivo Febraban / 164-230
ElseIf SEA->EA_MODELO$"35" // Pagamento de FGTS c/ Codigo de Barras
	_cRet:="11"																//Codigo do tributo / pos. 018-019	
	_cRet+=PadL(Substr(SE2->E2_XESCRT,1,6),6,"0")									//Codigo do pagamento / pos. 020-023		
	_cRet+="2"																//Tipo de Inscr. Contribuinte / pos. 024-024
	_cRet+=PADL(ALLTRIM(SM0->M0_CGC),14,"0")								//Identificação do Contribuinte - CNPJ/CGC/CPF / 025-038
	_cRet+=SUBSTR(SE2->E2_CODBAR,1,48)										//Codigo de Barras / 039-086
	_cRet+=STRZERO(SE2->E2_XESNFGTS,16)										//Ident. do FGTS / 087-102
	_cRet+=STRZERO(SE2->E2_XESLACRE,9)										//Lacre do FGTS / 103-111
	_cRet+=STRZERO(SE2->E2_XESDGLAC,2)										//DG Lacre do FGTS / 112-113
	_cRet+=Substr(sm0->m0_nomecom,1,30)										//Nome do Contribuinte / 114-143
	_cRet+=StrZero(Day(SE2->E2_VENCREA),2)+STRZERO(MONTH(SE2->E2_VENCREA),2)+STR(YEAR(SE2->E2_VENCREA),4)//Data de pagamento  / 144-151
	_cRet+=STRZERO(SE2->E2_SALDO*100,14)									//Valor de pagamento / 152-165
	_cRet+=space(30)		                              					// Brancos / 166-195
Endif
Return(_cRet)

                   

