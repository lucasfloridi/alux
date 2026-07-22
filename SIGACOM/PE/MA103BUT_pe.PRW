#include "totvs.ch"

/*/{Protheus.doc} User Function MA103BUT
	Ponto de Entrada chamado a partir do código-fonte MATA103.PRW, permite ao usuário adicionar opções na barra de menus EnchoiceBar.
	@type  Function
	@author Diogo Mesquita
	@since 08/02/2021
	@version version
	@param param_name, param_type, param_descr
	@return return_var, return_type, return_description
	@example
	(examples)
	@see (links_or_references)
	/*/
User Function MA103BUT()
	
	Local aRet := {} 

	If Inclui // Inclui botao somente se for inclusao
		Setkey( VK_F8 ,{ || Processa({|| u_MarkPesBal() },"Carregando itens de pesagem da balança...") } )
        aAdd(aRet, { "AUTOM", { || Processa({|| u_MarkPesBal() },"Carregando itens de pesagem da balança...") },"Balança"})
	EndIf
	
Return aRet
