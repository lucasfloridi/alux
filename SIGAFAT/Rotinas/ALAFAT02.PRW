#INCLUDE "totvs.ch"

/* 
Nome       		: U_ALAFAT02() -> Nil
Descrição  		: Gera o arquivo de AE para as notas selecionadas
Ponto	   		: Rotina executada pelo fonte ALXFAT01
Nota       		: -
Ambiente   		: FATURAMENTO
Cliente			: ALFAGOMMA
Autor      		: José Eustáquio Ladeira Júnior - FSW - Totvs RP    
Data Criação 	: 11/12/2014
Param. Pers 	: -
Campos Pers.	: -

Nº Revisão		: 00
Data Revisão	: -
Revisor			: -
Nota			: -
*/

User Function ALAFAT02()
	Local oNFSEClass	:= ParamIXB[1]				//Classe Template de NF-e recebida como parametro
	Local aDados		:= oNFSEClass:aDados		//Array de dados
	Local aDadosCab		:= oNFSEClass:aDadosCab		//Array com a estrutura dos dados
	Local aDadosCabIt	:= oNFSEClass:aDadosCabIt
	Local aRet			:= {}
	Local aRetorno		:= {}     

	Private nSeq	:= 0
	Private nReg    := 0

	//Caso o template retorne dados de nota
	If Len(aDados) > 0		

		nSeq := GetMv("MV_CTRLTRA") + 1

		//Carrega o cabecalho
		SetHeader(@aRet,oNFSEClass,aDadosCab,aDados)
        
		//Carrega as notas e itens
		SetDetail(@aRet,oNFSEClass,aDadosCab,aDados)
		
	    //Carrega o rodape
		SetFooter(@aRet,oNFSEClass,aDadosCab,aDados)
	
		PutMv("MV_CTRLTRA",nSeq)

		aRetorno := {2,aRet,"",""}		
	Endif	
	
Return aRetorno


Static Function SetHeader(aRet,oNFSEClass,aDadosCab,aDados)

	Local cRet	:= ""

    cRet += "ITP" // ITP
    cRet += "004" // PROCESSO
    cRet += "17" // VERSÃO
    cRet += strzero(nSeq,5) // CONTROLE
    cRet += Subs(DtoS(SF2->F2_EMISSAO),3,6) // DATA DA TRANSMISSAO
    cRet += Subs(SF2->F2_HORA,1,2)+Subs(SF2->F2_HORA,4,2)+"00" // HORA DA TRANSMISSAO
    cRet += SM0->M0_CGC // CNPJ ALUX
    cRet += alltrim(GdFieldGet("A1_CGC",1,Nil,aDadosCab,aDados)) // CNPJ TOYOTA
    cRet += subs(GdFieldGet("A1_ZZIDCLI",1,Nil,aDadosCab,aDados)+space(8),1,8) // COD INTERNO TRANSMISSOR
    cRet += "00069603" // COD INTERNO RECEPTOR
    cRet += subs(SM0->M0_NOMECOM,1,25)
    cRet += subs(GdFieldGet("A1_NOME",1,Nil,aDadosCab,aDados),1,25)
    cRet += space(9)
    cRet += CRLF

    nReg++
    
	aAdd(aRet,cRet)	
	
Return Nil


Static Function setDetail(aRet,oNFSEClass,aDadosCab,aDados)
	
	Local nI		:= 0
	Local nJ		:= 0
	
	Local cAE1		:= ""
	Local cNF2		:= ""
	Local cAE2		:= ""
	Local cAE4		:= ""
	Local cAE7		:= ""
	Local cItem		:= ""
	Local cPed		:= ""
	Local cRet		:= ""

	Local aItens	:= {}
		
	//Loop nos itens passados pelo Template
	For nI := 1 to Len(aDados)

		aItens := GdFieldGet("ITENS",nI,Nil,aDadosCab,aDados)
		cPed := SD2->D2_PEDIDO		//busca pedido cliente

		cAE1 := "AE1"
		cAE1 += subs(GdFieldGet("F2_DOC",nI,Nil,aDadosCab,aDados),4,6) // Numero da NF
		cAE1 += GdFieldGet("F2_SERIE",nI,Nil,aDadosCab,aDados) + " " // Serie da NF
		cAE1 += Subs(DtoS(GdFieldGet("F2_EMISSAO",nI,Nil,aDadosCab,aDados)),3,6) // Data de Emissão
		cAE1 += strzero(0,3) // Quantidade de itens
		cAE1 += strzero(GdFieldGet("F2_VALBRUT",nI,Nil,aDadosCab,aDados)*100,17) // Valor total da NF
		cAE1 += "2" // Quantidade de casas decimais
		cAE1 += aItens[1,10] // CFOP
		cAE1 += strzero(GdFieldGet("F2_VALICM",nI,Nil,aDadosCab,aDados)*100,17) // Valor total do ICMS
		cAE1 += getVenc(GdFieldGet("F2_DOC",nI,Nil,aDadosCab,aDados),GdFieldGet("F2_SERIE",nI,Nil,aDadosCab,aDados)) // Data de vencimento do doc
		cAE1 += "04" // Especie da NF
		cAE1 += strzero(GdFieldGet("F2_VALIPI",nI,Nil,aDadosCab,aDados)*100,17) // Valor total do IPI
		cAE1 += SUBSTR(GetMv("ZZ_FDESTOY") + SPACE(3), 1, 3) // Cod fábrica de destino
		cAE1 += Subs(DtoS(SF2->F2_EMISSAO),3,6) // Data de previsão da NF
		cAE1 += strzero(0, 4) // Pedido de entrega
		cAE1 += Subs(Posicione("SX5",1,xFilial("SX5")+"13"+aItens[1,10],"X5_DESCRI"),1,15) // Desrição da Natureza
		cAE1 += strzero(0, 6) // Data de embarque da mercadoria
		cAE1 += strzero(0, 4) // Hora de embarque da mercadoria
		cAE1 += strzero(0, 3) // Espaço
		cAE1 += CRLF

		nReg++
		
		cNF2 := "NF2"
		cNF2 += strzero((GdFieldGet("F2_DESPESA",nI,Nil,aDadosCab,aDados)+GdFieldGet("F2_FRETE",nI,Nil,aDadosCab,aDados)+GdFieldGet("F2_SEGURO",nI,Nil,aDadosCab,aDados))*100,12)
		cNF2 += strzero(GdFieldGet("F2_FRETE",nI,Nil,aDadosCab,aDados)*100,12)
		cNF2 += strzero(GdFieldGet("F2_SEGURO",nI,Nil,aDadosCab,aDados)*100,12)		
		cNF2 += strzero(GdFieldGet("F2_DESCONT",nI,Nil,aDadosCab,aDados)*100,12)
		cNF2 += strzero(GdFieldGet("F2_BASEICM",nI,Nil,aDadosCab,aDados)*100,12)
		cNF2 += StrZero(0,12)
		cNF2 += StrZero(0,6)
		cNF2 += StrZero(0,6)
		cNF2 += space(4)
		cNF2 += space(3)
		cNF2 += space(5)
		cNF2 += StrZero(0,12)
		cNF2 += space(17)
		cNF2 += CRLF
		
		nReg++
		
		//Monta os itens
		cItem := ""
		
		For nJ := 1 to Len(aItens)
	        
	        nPos := AT("#",aItens[nJ,2])
	        
	        cAE2 := "AE2"
	        cAE2 += StrZero(nJ,3)				//item
	        cAE2 += subs(SD2->D2_PEDIDO+space(12),1,12)	//pedcom
	        cAE2 += subs(POSICIONE("SB1", 1, xFilial("SB1")+aItens[nJ,2], "B1_ZZCODTO")+space(30),1,30)	//codigo item
	        cAE2 += StrZero(aItens[nJ,3]*100,9)		        //quantidade
	        cAE2 += iif(aItens[nJ,4]=="PC","EA",aItens[nJ,4])			//um
	        cAE2 += subs("00"+aItens[nJ,5]+space(10),1,10)	//ncm
			cAE2 += StrZero(aItens[nJ,6]*100,4)			//aliquota ipi
			cAE2 += StrZero(aItens[nJ,7]*100000,12)		//preço unitário
	        cAE2 += StrZero(0,9)				//quantidade
	        cAE2 += SPACE(2)			//um
	        cAE2 += StrZero(0,9)				//quantidade
	        cAE2 += SPACE(2)			//um
	        cAE2 += iif(Posicione("SF4",1,xFilial("SF4")+aItens[nJ,21],"F4_DUPLIC")=="S","P","X")				//tipo de fornecimento
	        cAE2 += "0000"								//percentual de desconto
	        cAE2 += StrZero(0,11)						//valor desconto
	        cAE2 += iif(npos==0,Space(04),space(2)+Subs(aItens[nJ,2],npos+1,2))	//alteração técnica
			cAE2 += space(1)
			cAE2 += CRLF
	        
	        nReg++
	        
	        cAE4 := "AE4"
			cAE4 += StrZero(aItens[nJ,11]*100,4)		//aliquota icms
			cAE4 += StrZero(aItens[nJ,12]*100,17)		//base icms
			cAE4 += StrZero(aItens[nJ,13]*100,17)		//vlr icms
			cAE4 += StrZero(aItens[nJ,14]*100,17)		//vlr ipi
			cAE4 += subs(aItens[nJ,15],2,2)				//cst
			cAE4 += space(30)							//numero desenho
			cAE4 += StrZero(0,6)						//validade desenho
			cAE4 += space(13)							//pedido revenda
			cAE4 += StrZero(aItens[nJ,16]*aItens[nJ,3]*100,5)	//peso
	        cAE4 += "1"									//fator multiplicador
	        cAE4 += StrZero(aItens[nJ,20]*100,12)		//valor total
	        cAE4 += "0"
	        cAE4 += CRLF
	        
	        nReg++

	        cAE7 := "AE7"
			cAE7 += StrZero(0, 100)								//pais origem
			cAE7 += space(25)
			cAE7 += CRLF
			
			nReg++
            
			cItem += cAE2 + cAE4 + cAE7

		next nX
		
		cRet := cAE1 + cNF2 + cItem

		aAdd(aRet,cRet)
	
	Next nI

Return Nil



Static Function setFooter(aRet,oNFSEClass,aDadosCab,aDados,aDadosItCab)

	Local cRet	:= ""
	
	cRet := "FTP"
    cRet += strzero(nSeq,5)
	cRet += strzero(nReg+1,9)
	cRet += strzero(SF2->F2_VALBRUT*100,17)
	cRet += "C"
	cRet += Space(93)
	cRet += CRLF
	
	aAdd(aRet,cRet)	
	
Return Nil



static function getVenc(cDoc,cSer)

	Local cVenc := ""
	
 	dbSelectArea("SE1")
	SE1->(dbSetOrder(1))
    If SE1->(DbSeek(xFilial("SE1")+cSer+cDoc))  //F2_DUPLI
		cVenc:=Subs(Dtos(SE1->E1_VENCTO),3,6)
	Else
		cVenc:='000000'
	Endif

return(cVenc)
 