#include "totvs.ch"
#include "fwmvcdef.ch"

#define MVC_MAIN_ID		"MovPesBal"
#define MVC_MODEL_ID	"MMovPesBal"
#define TITLE_MODEL		"Movimentos de Pesagem da Balança"
#define ALIAS_FORM		"ZZ1"
#define ID_MODEL_FORM	ALIAS_FORM + "FORM"
#define ID_VIEW_FORM	"VIEW_FORM"

/*/{Protheus.doc} User Function MovPesBal
	Rotina responsável por permitir manipular os registros de pesagem da balança.
	@type  Function
	@author Diogo Mesquita
	@since 12/01/2021
	@version version
	@param param_name, param_type, param_descr
	@return return_var, return_type, return_description
	@example
	(examples)
	@see (links_or_references)
/*/
User Function MovPesBal()
	
	Local oBrowse := FWMBrowse():New()

	oBrowse:SetAlias(ALIAS_FORM) 

	oBrowse:AddLegend("Empty(ZZ1_UTILIZ)",  "GREEN", "Mov. de Balança Não Utilizado") 
	oBrowse:AddLegend("!Empty(ZZ1_UTILIZ)", "RED", 	 "Mov. de Balança Já Utilizado")

	oBrowse:SetDescription(TITLE_MODEL) 
	oBrowse:SetMenuDef(MVC_MAIN_ID)
	oBrowse:Activate()  
	
Return

/*/{Protheus.doc} menuDef
	@type  Static Function
	@author Diogo Mesquita
	@since 12/01/2021
	@version version
	@param param_name, param_type, param_descr
	@return return_var, return_type, return_description
	@example
	(examples)
	@see (links_or_references)
	/*/
Static Function menuDef()
    
	Local aRotina := {}
	Local cViewId := "VIEWDEF."+MVC_MAIN_ID
    
	ADD OPTION aRotina TITLE "Pesquisar"	ACTION 'PesqBrw'	OPERATION 1 ACCESS 0
    ADD OPTION aRotina TITLE "Visualizar"   ACTION cViewId 		OPERATION 2 ACCESS 0
    ADD OPTION aRotina TITLE "Incluir"      ACTION cViewId 		OPERATION 3 ACCESS 0
    ADD OPTION aRotina TITLE "Alterar"      ACTION cViewId 		OPERATION 4 ACCESS 0
    ADD OPTION aRotina TITLE "Excluir"      ACTION cViewId 		OPERATION 5 ACCESS 0
    ADD OPTION aRotina TITLE "Imprimir"     ACTION cViewId 		OPERATION 8 ACCESS 0
    ADD OPTION aRotina TITLE "Copiar"       ACTION cViewId 		OPERATION 9 ACCESS 0	
	
Return aRotina

/*/{Protheus.doc} modelDef
	@type  Static Function
	@author Diogo Mesquita
	@since 12/01/2021
	@version version
	@param param_name, param_type, param_descr
	@return return_var, return_type, return_description
	@example
	(examples)
	@see (links_or_references)
	/*/
Static Function modelDef()
    
	Local oStruct 	:= FWFormStruct( 1, ALIAS_FORM)
	Local oModel	:= MpFormModel():new(MVC_MODEL_ID)
    
	oModel:addFields(ID_MODEL_FORM, nil, oStruct) 
	oModel:getModel(ID_MODEL_FORM):setDescription(TITLE_MODEL)
	oModel:SetPrimaryKey({ 'ZZ1_FILIAL', 'ZZ1_SEQUEN'})
	
Return oModel

/*/{Protheus.doc} viewDef
	@type  Static Function
	@author Diogo Mesquita
	@since 12/01/2021
	@version version
	@param param_name, param_type, param_descr
	@return return_var, return_type, return_description
	@example
	(examples)
	@see (links_or_references)
	/*/
Static Function viewDef()

	Local oView		:= FwFormView():new()
	Local oModel	:= FwLoadModel(MVC_MAIN_ID)
	Local oStruct 	:= FWFormStruct( 2, ALIAS_FORM)	
    
	oView:setModel(oModel)
	oView:AddField(ID_VIEW_FORM	,oStruct, 	ID_MODEL_FORM)	
	oView:CreateHorizontalBox('MASTER'		,100 )
	oView:EnableTitleView(ID_VIEW_FORM,TITLE_MODEL)	
	oView:SetOwnerView(ID_VIEW_FORM	,'MASTER')

Return oView
