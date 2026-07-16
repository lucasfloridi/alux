#Include 'Protheus.ch'
#Include 'TbiConn.ch'
#INCLUDE "TOTVS.CH"
#INCLUDE "rwmake.ch"
#INCLUDE "topconn.ch"

/*/{Protheus.doc} User Function F240BORD
    Ponto de entrada personalizado para adicionar N titulos ao borderô de pagamentos.
    @type  Function
    @author Gustavo N Andrade
    @since 14/02/2023
    @version version
    @param param_name, param_type, param_descr
    @return return_var, return_type, return_description
    @example
    (examples)
    @see (links_or_references)
    /*/


User Function F240BORD()

	Local aParamBox := {}
	Local dDate := ""
	Local cQuery := ''
    Local nStatus

	aAdd(aParamBox, {1,"Data De Agendamento"  ,Ctod(Space(8)),"","","","",50,.T.})

	If ParamBox(aParamBox,"Informe os parâmetro...")
		dDate   := MV_PAR01
	Endif

	cQuery := " UPDATE " + RetSqlName("SE2") + " SET E2_XPAG = '"+DtoS(dDate)+"'"
	cQuery += " WHERE D_E_L_E_T_ <> '*' AND E2_FILIAL = '"+xFilial("SE2")+"'"
	cQuery += " AND E2_NUMBOR = '" + cNumBor + "'"
	TCSQLEXEC(cQuery)

	nStatus := TCSqlExec(cQuery)

	if (nStatus < 0)
        MsgAlert(TCSQLError(), "TCSQLError")
		conout("TCSQLError() " + TCSQLError())
	endif

Return
