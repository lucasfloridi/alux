#include 'totvs.ch'

/*/{Protheus.doc} User Function M250BUT
	O ponto de entrada M250BUT é utilizado para adicionar botões na barra de ferramentas do apontamento de produção simples.
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
User Function M250BUT()
    
    Local nOpc          := PARAMIXB[1]
    Local aRet      := {}
    
    If nOpc == 3 // Inclui botao somente se for inclusao
        Setkey( VK_F8 ,{ || Processa({|| u_MarkPesBal() },"Carregando itens de pesagem da balança...") } )
        aAdd(aRet,{"AUTOM", { || Processa({|| u_MarkPesBal() },"Carregando itens de pesagem da balança...") },"Balança"})
    EndIf
            
Return aRet
