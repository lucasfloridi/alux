#include "Protheus.ch"


/*/{Protheus.doc} A410CONS
Ponto de entrada para adicionar opções no menu Outras Ações dentro do Pedido de Venda.
@type function
@version 1.0
@author Tiago Badoco - TOTVS IP
@since 10/03/2021
@return array, array contendo as novas entradas
/*/
User Function A410CONS() 
    Local aBotao		:= {}	

	aAdd(aBotao,{"EDITABLE",{|| U_ALAFAT01()},"Apontamentos"})

Return aBotao
