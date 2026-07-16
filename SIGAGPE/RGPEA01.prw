#Include 'Totvs.ch'
#Include 'FwMvcDef.ch'

#DEFINE MOD_DADOS 1
#DEFINE MOD_INTER 2

/*/{Protheus.doc} RGPEA01 
Cadastro de Tabela de Previdência Funsejem

@author  Michel Sander
@since   12/10/2022
@version P12.1.023
/*/

User function RGPEA01()
	
	Local oBrowse
 
	oBrowse := FWMBrowse():New()
	oBrowse:SetAlias('ZZ2')
	oBrowse:SetDescription('Previdência Privada FUNSEJEM')
   oBrowse:SetMenuDef("RGPEA01")
	oBrowse:Activate()

Return NIL

Static Function MenuDef()
	
	Local aRotina := {}

	ADD OPTION aRotina TITLE 'Pesquisar'  ACTION 'PesqBrw'          OPERATION 1 ACCESS 0
	ADD OPTION aRotina TITLE 'Visualizar' ACTION 'VIEWDEF.RGPEA01' OPERATION 2 ACCESS 0
	ADD OPTION aRotina TITLE 'Incluir'    ACTION 'VIEWDEF.RGPEA01' OPERATION 3 ACCESS 0
	ADD OPTION aRotina TITLE 'Alterar'    ACTION 'VIEWDEF.RGPEA01' OPERATION 4 ACCESS 0
	ADD OPTION aRotina TITLE 'Excluir'    ACTION 'VIEWDEF.RGPEA01' OPERATION 5 ACCESS 0

Return aRotina

Static Function ModelDef()
	
	Local oStruZZ2 := FWFormStruct(MOD_DADOS,"ZZ2", /*bAvalCampo*/,/*lViewUsado*/ )
	local oModel := MPFormModel():New('MRGPEA01', ,/*bValidPos*/ ,/*{|oModel| ZZ2Commit(oModel)}*/, )	
	
	oModel:AddFields('ZZ2MASTER', /*cOwner*/, oStruZZ2, /*bValidPre*/, /*bPosValidacao*/, /*bCarga*/ )
	oModel:SetDescription( 'Previdência Privada' )
	oModel:GetModel( 'ZZ2MASTER' ):SetDescription( 'Dados de Previdência' )
	oModel:SetPrimaryKey({'ZZ2_FILIAL', 'ZZ2_CODIGO' })

Return oModel

Static Function ViewDef()
	
	Local oModel   := FWLoadModel( 'RGPEA01' )
	Local oStruZZ2 := FWFormStruct( MOD_INTER, 'ZZ2' )
	Local oView    := FWFormView():New()
	
	oView:SetModel(oModel)
	oView:AddField( "VIEW_ZZ2", oStruZZ2, 'ZZ2MASTER')
	oView:CreateHorizontalBox( "TELA" , 100 )
	oView:SetOwnerView( "VIEW_ZZ2","TELA" )

Return oView
