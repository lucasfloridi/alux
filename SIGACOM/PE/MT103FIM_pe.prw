#include 'totvs.ch'

/*/{Protheus.doc} User Function MT103FIM
	O ponto de entrada MT103FIM encontra-se no final da função A103NFISCAL.
    Após o destravamento de todas as tabelas envolvidas na gravação do documento de entrada, depois de fechar a operação realizada neste.
    É utilizado para realizar alguma operação após a gravação da NFE.
	@type  Function
	@author Diogo Mesquita
	@since 09/02/2021
	@version version
	@param param_name, param_type, param_descr
	@return return_var, return_type, return_description
	@example
	(examples)
	@see (links_or_references)
	/*/
User Function MT103FIM()

    Local nOpcao    := PARAMIXB[1]   // Opção Escolhida pelo usuario no aRotina
    Local nConfirma := PARAMIXB[2]   // Se o usuario confirmou a operação de gravação da NFECODIGO DE APLICAÇÃO DO USUARIO

    If (nOpcao == 3 .or. nOpcao == 4) .AND. nConfirma == 1
        u_UpdPesBal("S")
    EndIf

	If nOpcao == 5 .AND. nConfirma == 1
		u_UpdPesBal(" ")
	EndIf
	
	If FunName() == "MATA103" .And. GetMv("MV_CTLIPAG")
		U_LIBPAG()
	
	EndIf
    
Return

//Utilizado para gerar os titulos do contas a pagar liberados de aprovação - 28/12/2023
User Function LIBPAG()

Local cQueryUpd := ""
	
	cQueryUpd := "UPDATE "+ RetSqlName("SE2") +" "
	cQueryUpd += "SET "
	cQueryUpd += "		E2_DATALIB = '"+ DtoS(dDataBase) +"', E2_USUALIB = '"+ cUserName +"', E2_STATLIB = '03' "
	cQueryUpd += "WHERE "
	cQueryUpd += "		D_E_L_E_T_ = ' ' AND "
	cQueryUpd += "		E2_FILIAL = '"+ xFilial("SE2") +"' AND "
	cQueryUpd += "		E2_NUM = '"+ SF1->F1_DOC +"'  AND "
	cQueryUpd += "		E2_PREFIXO = '"+ SF1->F1_SERIE +"' AND "
	cQueryUpd += "		E2_FORNECE = '"+ SF1->F1_FORNECE +"' AND " 
	cQueryUpd += "		E2_LOJA = '"+ SF1->F1_LOJA +"' "
	
	If TcSqlExec(cQueryUpd) <> 0
		UserException(TCSQLError())
	Endif
	
Return
