#include 'totvs.ch'
#include 'topconn.ch'

#define TITULO  "ALUX DO BRASIL"

/*/{Protheus.doc} ALAEST02
Rotina responsável por alocação dos Custos em partes na tabela SB9.
@type function
@author Felipe Silva.
@since 23/07/2025
/*/
user function ALAEST02()
    local cDataAtu := ""
    private oParamBox   := IpParamBoxObject():NewIpParamBoxObject("ALAEST02")

    AddParam()

    if oParamBox:Show()
        cDataAtu := DtoS(oParamBox:getValue("data"))

		Processa({|| ProcDados(cDataAtu)}, TITULO , "Processando dados..", .F.)		
	endif 
return

static function AddParam()
    local oParam := nil

	oParamBox:setTitle("Alocação dos Custos")

	oParam := IpParamObject():NewIpParamObject("data", "get", "Data Fechamento", "D", 70, TamSX3("B9_DATA")[01])
    oParam:SetRequired(.t.)
	oParamBox:addParam(oParam)
return

static function ProcDados(cDataAtu)
    local cAlias    := GetConsulta(cDataAtu)
    local nRecSB9   := 0
    local nRecSB1   := 0
    local nIni1     := 0
    local nCm1      := 0

    while(cAlias)->(!Eof())
        nRecSB9 := (cAlias)->RECSB9
        nRecSB1 := (cAlias)->RECSB1

        SB9->(DbGoTo(nRecSB9))
        SB1->(DbGoTo(nRecSB1))

        nIni1   := SB9->B9_VINI1
        nCm1    := SB9->B9_CM1

        if SB1->B1_ZCPARTE == "MPI"
            RecLock("SB9", .f.)
                SB9->B9_CP0101  := nIni1
                SB9->B9_CPM0101 := nCm1
            SB9->(MsUnlock())
        elseif SB1->B1_ZCPARTE == "EMB"
            RecLock("SB9", .f.)
                SB9->B9_CP0201  := nIni1
                SB9->B9_CPM0201 := nCm1
            SB9->(MsUnlock())
        elseif SB1->B1_ZCPARTE == "MTA"
            RecLock("SB9", .f.)
                SB9->B9_CP0301  := nIni1
                SB9->B9_CPM0301 := nCm1
            SB9->(MsUnlock())
        elseif SB1->B1_ZCPARTE == "ENE"
            RecLock("SB9", .f.)
                SB9->B9_CP0401  := nIni1
                SB9->B9_CPM0401 := nCm1
            SB9->(MsUnlock())
        elseif SB1->B1_ZCPARTE == "SUG"
            RecLock("SB9", .f.)
                SB9->B9_CP0501  := nIni1
                SB9->B9_CPM0501 := nCm1
            SB9->(MsUnlock())
        elseif SB1->B1_ZCPARTE == "COM"
            RecLock("SB9", .f.)
                SB9->B9_CP0601  := nIni1
                SB9->B9_CPM0601 := nCm1
            SB9->(MsUnlock())
        elseif SB1->B1_ZCPARTE == "FRE"
            RecLock("SB9", .f.)
                SB9->B9_CP0701  := nIni1
                SB9->B9_CPM0701 := nCm1
            SB9->(MsUnlock())
        elseif SB1->B1_ZCPARTE == "OCV"
            RecLock("SB9", .f.)
                SB9->B9_CP0801  := nIni1
                SB9->B9_CPM0801 := nCm1
            SB9->(MsUnlock())
        elseif SB1->B1_ZCPARTE == "MOD"
            RecLock("SB9", .f.)
                SB9->B9_CP0901  := nIni1
                SB9->B9_CPM0901 := nCm1
            SB9->(MsUnlock())
        elseif SB1->B1_ZCPARTE == "MAN"
            RecLock("SB9", .f.)
                SB9->B9_CP1001  := nIni1
                SB9->B9_CPM1001 := nCm1
            SB9->(MsUnlock())
        elseif SB1->B1_ZCPARTE == "SVT"
            RecLock("SB9", .f.)
                SB9->B9_CP1101  := nIni1
                SB9->B9_CPM1101 := nCm1
            SB9->(MsUnlock())
        elseif SB1->B1_ZCPARTE == "OCF"
            RecLock("SB9", .f.)
                SB9->B9_CP1201  := nIni1
                SB9->B9_CPM1201 := nCm1
            SB9->(MsUnlock())
        elseif SB1->B1_ZCPARTE == "DPR"
            RecLock("SB9", .f.)
                SB9->B9_CP1301  := nIni1
                SB9->B9_CPM1301 := nCm1
            SB9->(MsUnlock())
        elseif SB1->B1_ZCPARTE == "SUC"
            RecLock("SB9", .f.)
                SB9->B9_CP1401  := nIni1
                SB9->B9_CP1401 := nCm1
            SB9->(MsUnlock())
        elseif SB1->B1_ZCPARTE == "SAL"
            RecLock("SB9", .f.)
                SB9->B9_CP1501  := nIni1
                SB9->B9_CPM1501 := nCm1
            SB9->(MsUnlock())
        elseif SB1->B1_ZCPARTE == "OXI"
            RecLock("SB9", .f.)
                SB9->B9_CP1601  := nIni1
                SB9->B9_CPM1601 := nCm1
            SB9->(MsUnlock())
        endif

        (cAlias)->(DbSkip())
    enddo

    (cAlias)->(DbCloseArea())
return

static function GetConsulta(cDataAtu)
    local cAlias := ""
    local cQuery := ""

    cQuery += "SELECT" + CRLF
    cQuery += "    SB9.R_E_C_N_O_ AS RECSB9," + CRLF
    cQuery += "    SB1.R_E_C_N_O_ AS RECSB1" + CRLF

    cQuery += "FROM " + RetSqlTab("SB9") + "" + CRLF

    cQuery += "INNER JOIN " + RetSqlTab("SB1") + "" + CRLF
    cQuery += "    ON 1 = 1" + CRLF
    cQuery += "    AND SB1.B1_FILIAL = '" + FWxFilial("SB1") + "'" + CRLF
    cQuery += "    AND SB1.B1_COD = SB9.B9_COD" + CRLF
    cQuery += "    AND SB1.D_E_L_E_T_ = ' '" + CRLF

    cQuery += "WHERE" + CRLF
    cQuery += "    1 = 1" + CRLF
    cQuery += "    AND SB9.B9_FILIAL = '" + FWxFilial("SB9") + "'" + CRLF
    cQuery += "    AND SB9.B9_DATA = '" + cDataAtu + "'" + CRLF
    cQuery += "    AND SB9.D_E_L_E_T_ = ' '" + CRLF

    TcQuery cQuery new alias (cAlias := GetNextAlias())
return cAlias
