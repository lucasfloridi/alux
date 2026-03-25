#INCLUDE "PROTHEUS.CH"
#INCLUDE "Totvs.CH"

#DEFINE NTAMMAXLIN 1081

/*/{Protheus.doc} RGPEM02
Exportação de arquivo de Previdência FUNSEJEM

@author		Michel Sander
@since 		15/11/2022
@version 	12.1.33
/*/    

User Function RGPEM02()

   LOCAL cDescricao := ""
   LOCAL LOK        := .T.
   LOCAL bProcesso  := {|oSelf| lOk := RGPEM03(oSelf)}
   LOCAL cCadastro  := "Previdência Privada"

   PRIVATE cPerg    := "RGPEM02"
   PRIVATE cAliasSRA := GetNextAlias()
   PRIVATE nSalario := 0   
   PRIVATE cEstCiv  := "00"
   PRIVATE cDadBank := ""
   PRIVATE cTransf  := ""
   PRIVATE cValores := ""
   PRIVATE cDtSusp  := ""
   PRIVATE cPensao  := ""
   PRIVATE cDep     := ""   
   PRIVATE cRG      := ""
   PRIVATE cDemissa := ""

   // Parâmetros
   VerPerg()
   Pergunte( cPerg, .F. )

   // Tela de apresentação e processamento
   cDescricao := OemtoAnsi('Este programa faz a exportação do arquivo de Previdência') + CRLF
   cDescricao += OemtoAnsi('da empresa FUNSEJEM para os funcionarios que optaram')+CRLF
   cDescricao += OemtoAnsi('pelo desconto do benefício.')+CRLF
   TNewProcess():New( "RGPEM02", cCadastro, bProcesso, cDescricao, cPerg, , .T., 20, cDescricao, .T., .T. )

   If !lOk 
      ApMsgInfo("Não foram gerados dados para os parâmetros escolhidos.")
   EndIf 

Return 

/*/{Protheus.doc} RGPEM03
Processamento da função principal

@author		Michel Sander
@since 		15/11/2022
@version 	12.1.33
/*/    

Static Function RGPEM03(oSelf)

   LOCAL nReg      := 0
   LOCAL aLeiaute  := {}
   LOCAL cVBDesFol := AllTrim(GetNewPar("FS_ZZVBFUN","668"))
   LOCAL cVBEmpFol := AllTrim(GetNewPar("FS_ZZVBEMP","E60"))
   LOCAL cVBPerFol := AllTrim(GetNewPar("FS_ZZVBFOP","800"))
   LOCAL cVBValFOl := AllTrim(GetNewPar("FS_ZZVBFOV","801"))
   LOCAL cVBAdc13p := AllTrim(GetNewPar("FS_ZZVB13P","889"))
   LOCAL cVBAdc13v := AllTrim(GetNewPar("FS_ZZVB13V","803"))
   LOCAL cVBAdcPlp := AllTrim(GetNewPar("FS_ZZVBPLP","793"))
   LOCAL cVBAdcPlv := AllTrim(GetNewPar("FS_ZZVBPLV","808"))

   // Seleciona os funcionários que optaram por Previdência
   BEGINSQL Alias cAliasSRA
      SELECT RA_FILIAL, RA_MAT FROM %Table:SRA% SRA 
      WHERE RA_FILIAL BETWEEN %Exp:mv_par01% AND %Exp:mv_par02%
         AND RA_MAT BETWEEN %Exp:mv_par03% AND %Exp:mv_par04% 
         AND RA_ZZFUNSE = 'S'
         AND SRA.%NotDel%
         ORDER BY RA_FILIAL, RA_MAT
         ENDSQL 

   If SRA->(Eof())
      SRA->(dbCloseArea())
      Return .F.
   EndIf 
   
   // Cria arquivo TXT no destino
   nHdl := FCreate( mv_par07, 0)
   If nHdl < 0
      ApMsgStop('Erro de geração do arquivo TXT. Erro = ' +AllTrim(Str(fError())))
      Return .F.
   EndIf 

   // Configura o leiaute de exportação
   FWPrevLeiaute(@aLeiaute)

   // Prepara a régua de processamento
   (cAliasSRA)->(dbEval({||nReg++}))
   oSelf:SetRegua1(nReg)
   (cAliasSRA)->(dbGotop())
   RGB->(dbSetOrder(1))
   SRB->(dbSetOrder(1))
   SRQ->(dbSetOrder(1))

   // Exporta registros
   SRA->(dbSetOrder(1))
   While (cAliasSRA)->(!Eof())

      oSelf:IncRegua1( "Exportando benefícios...")

      If SRA->(dbSeek((cAliasSRA)->RA_FILIAL+(cAliasSRA)->RA_MAT))
         
         // Verifica filtro de situação de folha
         If ( !SRA->RA_SITFOLH $ mv_par05 )
            (cAliasSRA)->(dbSkip())
            Loop 
         EndIf 
         
         // Verifica filtro de categoria
         If ( !SRA->RA_CATFUNC $ mv_par06 ) 
            (cAliasSRA)->(dbSkip())
            Loop 
         EndIf 
         
         // Calcula o salário base do funcionário
         // Verifica Horista
         If SRA->RA_CATFUNC == 'H'
            nSalario := SRA->RA_SALARIO * SRA->RA_HRSMES
         Else 
            nSalario := SRA->RA_SALARIO 
         EndIf 

         // Status do contribuinte
         If StrZero(Month(SRA->RA_ZZDTVIG),2) == StrZero(Month(mv_par08),2)
            cStatus := "00"   // Incluido no mês
         Else
            cStatus := "20"   // Contribuinte Ativo
         EndIf 

         // Verifica contribuição suspensa
         cDtSusp := Repl("0",8)
         If !Empty(SRA->RA_ZZDTSUS)
            cMesSus := StrZero(Month(SRA->RA_ZZDTSUS),2)
            cAnoSus := StrZero(Year(SRA->RA_ZZDTSUS),4)
            cDtSusp := SubStr(SRA->RA_ZZDTSUS,7,2)+SubStr(SRA->RA_ZZDTSUS,5,2)+SubStr(SRA->RA_ZZDTSUS,1,4)
            If cMesSus == StrZero(Month(mv_par08),2) .And. cAnoSus == StrZero(Year(mv_par08),4)
               cStatus := "53"
            Else 
               (cAliasSRA)->(dbSkip())
               Loop
            EndIf 
         EndIf 

         // Verifica demitidos no mês de contribuição
         cDemissa := Repl("0",8)
         If !Empty(SRA->RA_DEMISSA)
            cMesDem := StrZero(Month(SRA->RA_DEMISSA),2)
            cAnoDem := StrZero(Year(SRA->RA_DEMISSA),4)
            cDemissa := SubStr(Dtos(SRA->RA_DEMISSA),7,2)+SubStr(Dtos(SRA->RA_DEMISSA),5,2)+SubStr(Dtos(SRA->RA_DEMISSA),1,4)
            If cMesDem == StrZero(Month(mv_par08),2) .And. cAnoDem == StrZero(Year(mv_par08),4)
               cStatus := "52"
            Else 
               (cAliasSRA)->(dbSkip())
               Loop
            EndIf 
         EndIf 

         // Endereco Completo 
         cEndCompl := PADR(SRA->(AllTrim(RA_ENDEREC)+" "+AllTrim(RA_NUMENDE)),100)+;
                      PADR(SRA->RA_BAIRRO,35)+;
                      PADR(SRA->RA_MUNICIP,35)+;
                      PADR(SRA->RA_ESTADO,2)+;
                      PADR(SRA->RA_CEP,8)

         // Dados Bancarios
         cDadBank  := PADR(SubStr(AllTrim(SRA->RA_BCDEPSA),1,3),3)+;
                      Space(02)+;
                      PADR(SubStr(AllTrim(SRA->RA_BCDEPSA),5,8),4)+;
                      Space(01)+;
                      PADR(AllTrim(Posicione("SA6",1,xFilial("SA6")+Subs(SRA->RA_BCDEPSA,1,3)+Subs(SRA->RA_BCDEPSA,4,5),"A6_NOMEAGE")),20)+;
                      PADR(SubStr(SRA->RA_CTDEPSA,1,8),10)+;
                      PADR(SubStr(SRA->RA_CTDEPSA,10,1),1)

         // Transferencias
         cTransf  := "000"+"00000"+Space(06)+"0000000000"+Space(2)+Space(2)
         
         //de-para de Estado Civil
         If SRA->RA_ESTCIVI == "S"
            cEstCiv  := "01"
         ElseIf SRA->RA_ESTCIVI == "C"
            cEstCiv  := "02"
         ElseIf SRA->RA_ESTCIVI == "V"
            cEstCiv  := "03"
         ElseIf SRA->RA_ESTCIVI == "D"
            cEstCiv  := "04"
         ElseIf SRA->RA_ESTCIVI == "Q"
            cEstCiv  := "05"
         ElseIf SRA->RA_ESTCIVI == "M"
            cEstCiv  := "06"
         Else
            cEstCiv  := "07"
         EndIf 

         // Busca os valores calculados de Previdência
         c1CodContr := "000"
         n1ValContr := 0
         n1PerContr := 0
         c1CodAdic  := c2CodAdic := c3CodAdic := "000"
         n1PerAdic  := n2PerAdic := n3PerAdic := 0
         n1ValAdic  := n2ValAdic := n3ValAdic := 0

         // Valor Contribuição EMPREGADO
         If RGB->(dbSeek(SRA->RA_FILIAL+SRA->RA_MAT+cVBDesFol))
            c1CodContr := "193"
            n1PerContr := RGB->RGB_HORAS
            n1ValContr := RGB->RGB_VALOR
         EndIf 

         // Valor Contribuição ADICIONAL
         If RGB->(dbSeek(SRA->RA_FILIAL+SRA->RA_MAT+cVBValFol)) .Or.;
               RGB->(dbSeek(SRA->RA_FILIAL+SRA->RA_MAT+cVBAdc13v)) .Or. ;
                  RGB->(dbSeek(SRA->RA_FILIAL+SRA->RA_MAT+cVBAdcPlv))
            c1CodAdic := "223"
            n1PerAdic := RGB->RGB_HORAS
            n1ValAdic := RGB->RGB_VALOR
         ElseIf RGB->(dbSeek(SRA->RA_FILIAL+SRA->RA_MAT+cVBPerFol)) .Or. ;
                  RGB->(dbSeek(SRA->RA_FILIAL+SRA->RA_MAT+cVBAdc13p)) .Or. ;
                     RGB->(dbSeek(SRA->RA_FILIAL+SRA->RA_MAT+cVBAdcPlp))
            c1CodAdic := "223"
            n1PerAdic := RGB->RGB_HORAS
            n1ValAdic := RGB->RGB_VALOR
         EndIf 

         // Valor Contribuição EMPRESA
         If RGB->(dbSeek(SRA->RA_FILIAL+SRA->RA_MAT+cVBEmpFol))
            c2CodAdic := "194"
            n2PerAdic := RGB->RGB_HORAS
            n2ValAdic := RGB->RGB_VALOR
         EndIf 

         // Se não houver valores calculados, despreza funcionário 
         If c1CodContr == "000" .And. c1CodAdic == "000" .And. c2CodAdic == "000"
            (cAliasSRA)->(dbSkip())
            Loop 
         EndIf 

         // Compõe os valores de contribuição
         cValores := c1CodContr +StrZero(Int(n1PerContr*100),5) +StrZero(Int(n1ValContr*100),17)
         cValores += c1CodAdic  +StrZero(Int(n1PerAdic*100),5)  +StrZero(Int(n1ValAdic*100),17)
         cValores += c2CodAdic  +StrZero(Int(n2PerAdic*100),5)  +StrZero(Int(n2ValAdic*100),17)

         // Verifica pagamento de Pensão
         cPensao := "N"
         If SRQ->(dbSeek(SRA->RA_FILIAL+SRA->RA_MAT))
            cPensao := "S"
         EndIf 

         // Verifica dependente
         cDep := Space(60)
         If SRB->(dbSeek(SRA->RA_FILIAL+SRA->RA_MAT))
            While SRB->(!Eof()) .And. SRB->RB_FILIAL+SRB->RB_MAT == SRA->RA_FILIAL+SRA->RA_MAT
               If AllTrim(SRB->RB_TPDEP) == '01'
                  cDep := PADR(AllTrim(SRB->RB_NOME),60)
               EndIf 
               SRB->(dbSkip())
            End 
         EndIf 

         // Padroniza o campo RG
         cRG := AllTrim(SRA->RA_RG)
         cRG := StrTran(cRG,".","")
         cRG := StrTran(cRG,"-","")

         // Grava a linha de dados no arquivo
         FWrite( nHdl, FWGeraLinhas( aLeiaute ) )

      EndIf 

      (cAliasSRA)->(dbSkip())

   END 

   // Encerra exportação
   FClose(nHdl)
   (cAliasSRA)->(dbCloseArea())

Return .T.

/*/{Protheus.doc} FWPrevLeiaute
Prepara o leiaute do arquivo de benefícios

@author		Michel Sander
@since 		15/11/2022
@version 	12.1.33
/*/    

Static Function FWPrevLeiaute(aLeiaute)

   aAdd( aLeiaute, { 'TIPO REG               ', 001, 001,   'C',   1,  0, .T. , '"I"' } )
   aAdd( aLeiaute, { 'PLANO                  ', 002, 004,   'N',   3,  0, .T. , '"001"' } )
   aAdd( aLeiaute, { 'PATROCINADORA          ', 005, 009,   'N',   5,  0, .T. , '"00012"' } ) 
   aAdd( aLeiaute, { 'FILIAL	               ', 010, 015,   'N',   6,  0, .T. , 'PADR(StrZero(Val(SRA->RA_FILIAL),4),6)' } )
   aAdd( aLeiaute, { 'SETOR                  ', 016, 025,   'C',  10,  0, .T. , 'Space(10)' } )
   aAdd( aLeiaute, { 'PERFIL_PARTICIPANTE    ', 026, 027,   'C',   2,  0, .T. , '"AA"' } )
   aAdd( aLeiaute, { 'PERFIL_PATROCINADORA   ', 028, 029,   'C',   2,  0, .T. , '"AA"' } )
   aAdd( aLeiaute, { 'STATUS                 ', 030, 031,   'N',   2,  0, .T. , 'cStatus' } )
   aAdd( aLeiaute, { 'CODIGO_FUNCIONAL       ', 032, 041,   'N',  10,  0, .T. , 'StrZero(Val(SRA->RA_MAT),10)' } )
   aAdd( aLeiaute, { 'NOME                   ', 042, 101,   'C',  60,  0, .T. , 'PADR(SRA->RA_NOME,60)' } )
   aAdd( aLeiaute, { 'CPF                    ', 102, 112,   'N',  11,  0, .T. , 'PADR(SRA->RA_CIC,11)' } )
   aAdd( aLeiaute, { 'NASCIMENTO             ', 113, 120,   'C',   8,  0, .T. , 'PADR(SubStr(Dtos(SRA->RA_NASC),7,2)+SubStr(Dtos(SRA->RA_NASC),5,2)+SubStr(Dtos(SRA->RA_NASC),1,4),8)' } )
   aAdd( aLeiaute, { 'ADMISSAO               ', 121, 128,   'C',   8,  0, .T. , 'PADR(SubStr(Dtos(SRA->RA_ADMISSA),7,2)+SubStr(Dtos(SRA->RA_ADMISSA),5,2)+SubStr(Dtos(SRA->RA_ADMISSA),1,4),8)' } )
   aAdd( aLeiaute, { 'DESLIGAMENTO           ', 129, 136,   'C',   8,  0, .T. , 'PADR(cDemissa,8)' } )
   aAdd( aLeiaute, { 'SUSPENSAO              ', 137, 144,   'C',   8,  0, .T. , 'PADR(cDtSusp,8)' } )
   aAdd( aLeiaute, { 'ADESAO_PLANO           ', 145, 152,   'C',   8,  0, .T. , 'PADR(SubStr(Dtos(SRA->RA_ADMISSA),7,2)+SubStr(Dtos(SRA->RA_ADMISSA),5,2)+SubStr(Dtos(SRA->RA_ADMISSA),1,4),8)' } )
   aAdd( aLeiaute, { 'DATA_EFETIVA_PLANO     ', 153, 160,   'C',   8,  0, .T. , 'PADR(SubStr(Dtos(SRA->RA_ADMISSA),7,2)+SubStr(Dtos(SRA->RA_ADMISSA),5,2)+SubStr(Dtos(SRA->RA_ADMISSA),1,4),8)' } )
   aAdd( aLeiaute, { 'SEXO                   ', 161, 161,   'C',   1,  0, .T. , 'PADR(SRA->RA_SEXO,1)' } )
   aAdd( aLeiaute, { 'ESTADO_CIVIL           ', 162, 163,   'C',   2,  0, .T. , 'cEstCiv' } )
   aAdd( aLeiaute, { 'RUA (END COMPLETO)     ', 164, 343,   'C', 180,  0, .T. , 'PADR(cEndCompl,180)' } )
   aAdd( aLeiaute, { 'DADOS BANCARIOS        ', 344, 384,   'C',  41,  0, .T. , 'PADR(cDadBank,41)' } )
   aAdd( aLeiaute, { 'RESERVADO              ', 385, 387,   'C',   3,  0, .T. , 'Space(03)' } )
   aAdd( aLeiaute, { 'TRANSFERENCIA          ', 388, 415,   'C',  28,  0, .T. , 'PADR(cTransf,28)' } )
   aAdd( aLeiaute, { 'TIPO_OPERACAO          ', 416, 416,   'C',   1,  0, .T. , 'Space(1)' } )
   aAdd( aLeiaute, { 'RESERVADO              ', 417, 421,   'C',   5,  0, .T. , '"00000"' } )
   aAdd( aLeiaute, { 'RESERVADO              ', 422, 427,   'C',   6,  0, .T. , '"000000"' } )   
   aAdd( aLeiaute, { 'RESERVADO              ', 428, 428,   'C',   1,  0, .T. , 'Space(1)' } )   
   aAdd( aLeiaute, { 'SALARIO_EMPRESTIMO     ', 429, 445,   'C',  17,  0, .T. , 'Repl("0",17)' } )   
   aAdd( aLeiaute, { 'RESERVADO              ', 446, 450,   'C',   5,  0, .T. , '"00000"' } )   
   aAdd( aLeiaute, { 'SALARIO_APLICAVEL      ', 451, 467,   'C',  17,  0, .T. , 'Strzero((nSalario*100),17)' } )
   aAdd( aLeiaute, { 'PERC_SALARIO_APLICAVEL ', 468, 472,   'C',   5,  0, .T. , '"00000"' } )
   aAdd( aLeiaute, { 'CONTRIBUICAO_VALORES   ', 473, 547,   'C',  75,  0, .T. , 'PADR(cValores,75)' } )
   aAdd( aLeiaute, { 'CONTRIB_TIPO3_CODIGO   ', 548, 550,   'C',   3,  0, .T. , 'Space(03)' } )
   aAdd( aLeiaute, { 'CONTRIB_TIPO3_PERCENT  ', 551, 555,   'C',   5,  0, .T. , '"00000"' } )
   aAdd( aLeiaute, { 'CONTRIB_TIPO3_VALOR    ', 556, 572,   'C',  17,  0, .T. , 'Repl("0",17)' } )   
   aAdd( aLeiaute, { 'CONTRIB_TIPO4_CODIGO   ', 573, 575,   'C',   3,  0, .T. , 'Space(03)' } )
   aAdd( aLeiaute, { 'CONTRIB_TIPO4_PERCENT  ', 576, 580,   'C',   5,  0, .T. , '"00000"' } )
   aAdd( aLeiaute, { 'CONTRIB_TIPO4_VALOR    ', 581, 597,   'C',  17,  0, .T. , 'Repl("0",17)' } )   
   aAdd( aLeiaute, { 'CONTRIB_TIPO5_CODIGO   ', 598, 600,   'C',   3,  0, .T. , 'Space(03)' } )
   aAdd( aLeiaute, { 'CONTRIB_TIPO5_PERCENT  ', 601, 605,   'C',   5,  0, .T. , '"00000"' } )
   aAdd( aLeiaute, { 'CONTRIB_TIPO5_VALOR    ', 606, 622,   'C',  17,  0, .T. , 'Repl("0",17)' } )   
   aAdd( aLeiaute, { 'CONTRIB_TIPO6_CODIGO   ', 623, 625,   'C',   3,  0, .T. , 'Space(03)' } )
   aAdd( aLeiaute, { 'CONTRIB_TIPO6_PERCENT  ', 626, 630,   'C',   5,  0, .T. , '"00000"' } )
   aAdd( aLeiaute, { 'CONTRIB_TIPO6_VALOR    ', 631, 647,   'C',  17,  0, .T. , 'Repl("0",17)' } )   
   aAdd( aLeiaute, { 'CONTRIB_TIPO7_CODIGO   ', 648, 650,   'C',   3,  0, .T. , 'Space(03)' } )
   aAdd( aLeiaute, { 'CONTRIB_TIPO7_PERCENT  ', 651, 655,   'C',   5,  0, .T. , '"00000"' } )
   aAdd( aLeiaute, { 'CONTRIB_TIPO7_VALOR    ', 656, 672,   'C',  17,  0, .T. , 'Repl("0",17)' } )   
   aAdd( aLeiaute, { 'CONTRIB_TIPO8_CODIGO   ', 673, 675,   'C',   3,  0, .T. , 'Space(03)' } )
   aAdd( aLeiaute, { 'CONTRIB_TIPO8_PERCENT  ', 676, 680,   'C',   5,  0, .T. , '"00000"' } )
   aAdd( aLeiaute, { 'CONTRIB_TIPO8_VALOR    ', 681, 697,   'C',  17,  0, .T. , 'Repl("0",17)' } )   
   aAdd( aLeiaute, { 'CONTRIB_TIPO9_CODIGO   ', 698, 700,   'C',   3,  0, .T. , 'Space(03)' } )
   aAdd( aLeiaute, { 'CONTRIB_TIPO9_PERCENT  ', 701, 705,   'C',   5,  0, .T. , '"00000"' } )
   aAdd( aLeiaute, { 'CONTRIB_TIPO9_VALOR    ', 706, 722,   'C',  17,  0, .T. , 'Repl("0",17)' } )   
   aAdd( aLeiaute, { 'NUM_DEPENDENTES_IR     ', 723, 725,   'C',   3,  0, .T. , 'PADR(SRA->RA_DEPIR,3)' } )
   aAdd( aLeiaute, { 'PENSAO ALIMENTICIA     ', 726, 726,   'C',   1,  0, .T. , 'cPensao' } )
   aAdd( aLeiaute, { 'TEMPO_INSS             ', 727, 729,   'C',   3,  0, .T. , '"000"' } )
   aAdd( aLeiaute, { 'NATURALIDADE           ', 730, 764,   'C',  35,  0, .T. , 'PADR(AllTrim(SRA->RA_NATURAL)+AllTrim(SRA->RA_MUNNASC),35)' } )
   aAdd( aLeiaute, { 'NACIONALIDADE          ', 765, 799,   'C',  35,  0, .T. , 'PADR(AllTrim(SRA->RA_NACIONA),35)' } )
   aAdd( aLeiaute, { 'RG                     ', 800, 819,   'C',  20,  0, .T. , 'PADR(AllTrim(cRG),20)' } )
   aAdd( aLeiaute, { 'ORGAO EMISSOR          ', 820, 824,   'C',   5,  0, .T. , 'PADR(AllTrim(SRA->RA_RGORG),5)' } )
   aAdd( aLeiaute, { 'DATA EMISSAO RG        ', 825, 832,   'C',   8,  0, .T. , 'PADR(If(Empty(SRA->RA_DTRGEXP),Repl("0",8),SubStr(Dtos(SRA->RA_DTRGEXP),7,2)+SubStr(Dtos(SRA->RA_DTRGEXP),5,2)+SubStr(Dtos(SRA->RA_DTRGEXP),1,4)),8)' } )
   aAdd( aLeiaute, { 'NOME DA MAE            ', 833, 892,   'C',  60,  0, .T. , 'PADR(AllTrim(SRA->RA_MAE),60)' } )
   aAdd( aLeiaute, { 'NAO CONSTA             ', 893, 968,   'C',  76,  0, .T. , 'Space(76)' } )
   aAdd( aLeiaute, { 'NOME CONJUGE           ', 969, 1028,  'C',  60,  0, .T. , 'PADR(cDep,60)' } )
   aAdd( aLeiaute, { 'DTA NASC CONJUGE       ', 1029,1036,  'C',   8,  0, .T. , 'Repl("0",8)' } )
   aAdd( aLeiaute, { 'FUNCAO                 ', 1037,1081,  'C',  45,  0, .T. , 'PADR(Posicione("SRJ",1,xFilial("SRJ")+SRA->RA_CODFUNC,"RJ_DESC"),45)' } )   

Return 

/*/{Protheus.doc} FWGeraLinhas
Gera linha no arquivo TXT de benefícios

@author		Michel Sander
@since 		15/11/2022
@version 	12.1.33
/*/    

Static Function FWGeraLinhas( aBeneficios )

   Local cLinha     	:= ''
   Local nI         	:= 0
   local cNomCampo	:= ""

   // Percorre o leiaute e gera a linha do benefício
   For nI := 1 To Len( aBeneficios )

      bAux      := &( '{ || ' + aBeneficios[nI][8] + ' } ' )
      
      cTipo     := aBeneficios[nI][4]
      nTamanho  := aBeneficios[nI][5]
      nDecimal  := aBeneficios[nI][6]
      lObrigat  := aBeneficios[nI][7]
      cNomCampo := PADR(aBeneficios[nI][1],40)
      
      uConteudo := EVal( bAux )
      uConteudo := IIf( ValType( uConteudo ) == 'U' , '', EverChar( uConteudo ) )
      
      If     cTipo == 'C'
            uConteudo := PADR( FwNoAccent(SubStr( AllTrim( uConteudo ), 1, nTamanho )), nTamanho )
      ElseIf cTipo == 'N'
            uConteudo := StrZero( Val( uConteudo ) * (10^nDecimal) , nTamanho )
      ElseIf cTipo == 'X'
            uConteudo := PADL( SubStr( AllTrim( uConteudo ), 1, nTamanho ), nTamanho )
      EndIf
      
      cLinha += uConteudo
      
   Next

   cLinha += Replicate( ' ', NTAMMAXLIN - Len( cLinha ) )+CRLF

Return ( cLinha )

/*/{Protheus.doc} EverChar
Identifica a estrutura do dado

@author		Michel Sander
@since 		15/11/2022
@version 	12.1.33
/*/    

Static Function EverChar( uCpoConver )

   Local cRet  := NIL
   Local cTipo := ''

   cTipo := ValType( uCpoConver )

   If cTipo == 'C'                    // Tipo Caracter
      cRet := uCpoConver
   ElseIf cTipo == 'N'                    // Tipo Numerico
      cRet := AllTrim( Str( uCpoConver ) )
   ElseIf cTipo == 'L'                    // Tipo Logico
      cRet := IIf( uCpoConver, '.T.', '.F.' )
   ElseIf cTipo == 'D'                    // Tipo Data
      cRet := DToC( uCpoConver )
   ElseIf cTipo == 'M'                    // Tipo Memo
      cRet := 'MEMO'
   ElseIf cTipo == 'A'                    // Tipo Array
      cRet := 'ARRAY[' + AllTrim( Str( Len( uCpoConver ) ) ) + ']'
   ElseIf cTipo == 'U'                    // Indefinido
      cRet := 'NIL'
   EndIf

Return ( cRet ) 

/*/{Protheus.doc} VerPerg
Grupo de parâmetros

@author		Michel Sander
@since 		15/11/2022
@version 	12.1.33
/*/    

Static Function VerPerg()

   LOCAL aAreaDic 	:= { SX1->(GetArea()) , GetArea() }
   LOCAL aEstrut  	:= {}
   LOCAL aStruDic 	:= SX1->( dbStruct() )
   LOCAL aDados	   := {}
   LOCAL nXa         := 0
   LOCAL nXb         := 0
   LOCAL nTam1    	:= Len( SX1->X1_GRUPO )
   LOCAL nTam2    	:= Len( SX1->X1_ORDEM )

   aEstrut := { 'X1_GRUPO'  , 'X1_ORDEM'  , 'X1_PERGUNT', 'X1_PERSPA' , 'X1_PERENG' , 'X1_VARIAVL', 'X1_TIPO'   , ;
               'X1_TAMANHO', 'X1_DECIMAL', 'X1_PRESEL' , 'X1_GSC'    , 'X1_VALID'  , 'X1_VAR01'  , 'X1_DEF01'  , ;
               'X1_DEFSPA1', 'X1_DEFENG1', 'X1_CNT01'  , 'X1_VAR02'  , 'X1_DEF02'  , 'X1_DEFSPA2', 'X1_DEFENG2', ;
               'X1_CNT02'  , 'X1_VAR03'  , 'X1_DEF03'  , 'X1_DEFSPA3', 'X1_DEFENG3', 'X1_CNT03'  , 'X1_VAR04'  , ;
               'X1_DEF04'  , 'X1_DEFSPA4', 'X1_DEFENG4', 'X1_CNT04'  , 'X1_VAR05'  , 'X1_DEF05'  , 'X1_DEFSPA5', ;
               'X1_DEFENG5', 'X1_CNT05'  , 'X1_F3'     , 'X1_PYME'   , 'X1_GRPSXG' , 'X1_HELP'   , 'X1_PICTURE', ;
               'X1_IDFIL'   }

   aAdd( aDados, {cPerg, "01", "Filial De ?"			 , "¿De Filial?"		 , "From Branch ?"		 , "mv_ch1", "C", TamSx3("RA_FILIAL")[1], 0, 0, "G", ""															, "mv_par01", ""		, ""		, ""		, "", "", ""			, ""			, ""			, "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "XM0"		, "", "033"	, ""} )
   aAdd( aDados, {cPerg, "02", "Filial Até ?"			 , "¿A Filial?"			 , "To Branch ?"		 , "mv_ch2", "C", TamSx3("RA_FILIAL")[1], 0, 0, "G", "naovazio"											, "mv_par02", ""		, ""		, ""		, "", "", ""			, ""			, ""			, "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "XM0"		, "", "033"	, ""} )
   aAdd( aDados, {cPerg, "03", "Matricula De ?"		 , "¿De Matricula?"		 , "From Registration ?" , "mv_ch3", "C", 6						, 0, 0, "G", ""															, "mv_par03", ""		, ""		, ""		, "", "", ""			, ""			, ""			, "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "SRA"		, "", ""	, ""} )
   aAdd( aDados, {cPerg, "04", "Matricula Até ?"		 , "¿A  Matricula?"		 , "To Registration ?"	 , "mv_ch4", "C", 6						, 0, 0, "G", "naovazio"												, "mv_par04", ""		, ""		, ""		, "", "", ""			, ""			, ""			, "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "SRA"		, "", ""	, ""} )
   aAdd( aDados, {cPerg, "05", "Situaçöes a Imp. ?"	 , "¿Situaciones a Imp.?", "Situations to Print?", "mv_ch5", "C", 5						, 0, 0, "G", "fSituacao"											, "mv_par05", ""		, ""		, ""		, "", "", ""			, ""			, ""			, "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", ""		, "", ""	, ""} )
   aAdd( aDados, {cPerg, "06", "Categorias a Imp. ?"	 , "¿Categorias a Imp.?" , "Categories to Print?", "mv_ch6", "C", 15					, 0, 0, "G", "fCategoria"												, "mv_par06", ""		, ""		, ""		, "", "", ""			, ""			, ""			, "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", ""		, "", ""	, ""} )
   aAdd( aDados, {cPerg, "07", "Arquivo de Saida ?"	 , "Arquivo de Saida ?"	 , "Arquivo de Saida?"	 , "mv_ch7", "C", 60					, 0, 0, "G", ""															, "mv_par07", ""		, ""		, ""		, "", "", ""			, ""			, ""			, "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", ""		, "", ""	, ""} )
   aAdd( aDados, {cPerg, "08", "Data de Geracao"	    , "Data de Geracao ?"	 , "Export Date"     	 , "mv_ch8", "D", 08					, 0, 0, "G", ""															, "mv_par08", ""		, ""		, ""		, "", "", ""			, ""			, ""			, "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", ""		, "", ""	, ""} )
   
   // Atualizando dicionário
   dbSelectArea( 'SX1' )
   SX1->( dbSetOrder( 1 ) )

   For nXa := 1 To Len( aDados )
      If !SX1->( dbSeek( PadR( aDados[nXa][1], nTam1 ) + PadR( aDados[nXa][2], nTam2 ) ) )
         RecLock( 'SX1', .T. )
         For nXb := 1 To Len( aDados[nXa] )
            If aScan( aStruDic, { |aX| PadR( aX[1], 10 ) == PadR( aEstrut[nXb], 10 ) } ) > 0
               SX1->( FieldPut( FieldPos( aEstrut[nXb] ), aDados[nXa][nXb] ) )
            EndIf
         Next nXb
         MsUnLock()
      EndIf
   Next nXa

   AEval(aAreaDic,{|x| RestArea(x)})

Return
