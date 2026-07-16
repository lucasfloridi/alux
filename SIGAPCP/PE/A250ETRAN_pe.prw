#include 'totvs.ch'

/*/{Protheus.doc} User Function A250ETRAN
	O ponto de entrada 'A250ETRAN' é executado após gravação total dos movimentos, na inclusão do apontamento de produção simples.
	@type  Function
	@author Diogo Mesquita
	@since 10/02/2021
	@version version
	@param param_name, param_type, param_descr
	@return return_var, return_type, return_description
	@example
	(examples)
	@see (links_or_references)
	/*/
User Function A250ETRAN()
	
	u_UpdPesBal("S")
    
Return
