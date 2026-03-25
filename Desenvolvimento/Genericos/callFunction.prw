#Include 'Protheus.ch'

User Function callFunction()	
	
	local cCodEmp		:= "01"
	local cCodFil 		:= "01"
	
	rpcsetenv(cCodEmp, cCodFil)

	X31UPDTABLE('ZZ1') 

	rpcclearenv()
	
Return

