#include 'totvs.ch'

/*/{Protheus.doc} User Function GPM670FIM - Utilizado para incluir o titulo CP liberado de aprovacao
//Analista participante: Ana Flávia Souza
//version 1.0
//since 28/12/2023
/*/


User Function GPM670FIM()

Local cQueryUpd := ""

If FunName() == "GPEM670" .And. GetMv("MV_CTLIPAG")
	
	cQueryUpd := "UPDATE "+ RetSqlName("SE2") +" "
	cQueryUpd += "SET "
	cQueryUpd += "		E2_DATALIB = '"+ DtoS(dDataBase) +"', E2_USUALIB = '"+ cUserName +"', E2_STATLIB = '03' "
	cQueryUpd += "WHERE "
	cQueryUpd += "		D_E_L_E_T_ = ' ' AND "
	cQueryUpd += "		E2_FILIAL = '"+ xFilial("SE2") +"' AND "
	cQueryUpd += "		E2_NUM = '"+ RC1->RC1_NUMTIT +"'  AND "
	cQueryUpd += "		E2_PREFIXO = '"+ RC1->RC1_PREFIX +"' AND "
	cQueryUpd += "		E2_FORNECE = '"+ RC1->RC1_FORNEC +"' AND " 
	cQueryUpd += "		E2_LOJA = '"+ RC1->RC1_LOJA +"' "
	
	If TcSqlExec(cQueryUpd) <> 0
		UserException(TCSQLError())
	Endif
	
Endif

Return
