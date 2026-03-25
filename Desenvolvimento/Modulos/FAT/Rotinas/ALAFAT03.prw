#include "Protheus.ch"

/*/{Protheus.doc} ALAFAT03
Fonte executado via gatilho do campo C6_PRODUTO para preencher o campo C6_INFAD em caso de pedido para cliente HONDA
@type function
@author Tiago Badoco - TOTVS IP
@since 08/03/2021
@return caracter, B5_DESCNFE
/*/
User Function ALAFAT03()
    Local cRet  := ""
    Local cCGC  := GetMv("ZZ_HONDA")

    If TRIM(POSICIONE("SA1", 1, xFilial("SA1")+M->C5_CLIENTE+M->C5_LOJACLI, "A1_CGC")) == TRIM(cCGC)
        cRet := GetMv("ZZ_INFADPR")
        cRet := STRTRAN(cRet, ";", CRLF)
    EndIf
    
Return cRet
