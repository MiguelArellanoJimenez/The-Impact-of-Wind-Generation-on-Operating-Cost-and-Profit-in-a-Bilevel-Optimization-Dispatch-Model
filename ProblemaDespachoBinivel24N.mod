option solver KNITRO; #solucionador para problemas no lineales  

#Parametros para el calculo del tiempo de computo 
param tc_s>=0; #(segundos)
param tc_min>=0; #(minutos)

#parametros para la solucion del modelo de optimizacion binivel
param Nnodos; #parametro del numero de nodos
param Ncargas; #parametro del numero de cargas
param Ngeneradores; #parametro del numero de participantes
param Nlineas; #parametro del numero de lineas
param Nescenarios; #parametro del numero de escenarios de generacion eolica
param Nperiodos; #parametro del numero de periordos del despacho de un dia en adelanto
param CostoGenerador{i in 1..Ngeneradores}; #parametro costo marginal lineal del participante i
param CostoVenta{i in 1..Ngeneradores}; #parametro del costo por vender potencia en el mercado para el balance de potencia
param CostoCompra{i in 1..Ngeneradores}; #parametro del costo por comprar potencia en el mercado para el balance de potencia
param LimiteCompra{i in 1..Ngeneradores}; #parametro del limite de potencia comprada en el mercado para el balance de potencia
param LimiteVenta{i in 1..Ngeneradores}; #parametro del limite de potencia vendida en el mercado para el balance de potencia
param Flexible{i in 1..Ngeneradores}; #parametro que indica si el participante es flexible
param Convencional{i in 1..Ngeneradores}; #parametro que indica si el participante es flexible
param PotGenMin{i in 1.. Ngeneradores}; #parametro de la potencia minima del participante i
param PotGenMax{i in 1.. Ngeneradores}; #parametro de la potencia maxima del participante i
param NG{i in 1..Ngeneradores}; #vector que indica en que nodos de encuentra el participante termico i para su liquidacion
param IncNodCarga{i in 1..Ncargas,j in 1..Nnodos}; #matriz que indica en que nodos se encuentran la carga i
param IncNodGen{i in 1..Ngeneradores, j in 1..Nnodos}; #matriz que indica en que nodos se encuentran el participante termico i para la operacion
param IncGenFlex{i in 1..Ngeneradores, j in 1..Nnodos}; #matriz que indica en que nodos se encuentra los participantes flexibles 
param IncGenEolico{i in 1..Ngeneradores, j in 1..Nnodos}; #matriz que indica en que nodos se encuentra el participante eolico
param CapLin{i in 1..Nlineas, j in 1..4}; #parametro que indica el limite termico de la linea 
param M{i in 1..Nnodos, j in 1..Nlineas}; #matriz que indica la incidencia de lineas en nodos
param B{i in 1..Nnodos, j in 1..Nnodos}; #matriz de suseptancias 
param Probabilidad{j in 1..Nescenarios}; #parametro que indica la probabilidad de ocurrencia del escenario i
param PotenciaP{j in 1..Nescenarios}; #parametro que indica la potencia probable bajo el escenario i
param Carga{i in 1..Nperiodos, j in 1..Nnodos}; #parametro de la carga bajo el periodo considerado

#variables para la etapa de operacion del sistema de un dia en adelanto
var Delta{i in 1..Nnodos}; #vector variable de angulos de voltaje nodal
var PotGenerador{i in 1..Ngeneradores} >= 0; #vector variable de la potencia de salida del participante i
var F{i in 1..Nlineas}; #vector variable de flujo en la linea i
param L{i in 1..Nnodos}; #vector de cargas en nodos


#variables y parametros para la etapa para el balance de potencia del sistema
var DeltaEscenario{i in 1..Nnodos, j in 1..Nescenarios}; #matriz variable de angulos de voltaje nodal por escenario
var rPG{i in 1..Ngeneradores, j in 1..Nescenarios} >= 0; #matriz variable de potencia vendida por el participante i en el escenario j
var rNG{i in 1..Ngeneradores, j in 1..Nescenarios} >= 0; #matriz variable de potencia comprada por el participante i en el escenario j
var FB{i in 1..Nlineas, j in 1..Nescenarios}; #matriz variable del flujo positivo de la linea i en el escenario j
var Lshed{i in 1..Nnodos, j in 1..Nescenarios} >= 0; #matriz variable del tiro de carga i en el escenario j
param PBalance{i in 1..Ngeneradores, j in 1..Nescenarios}; #variable que indica la potencia requerida para el balance en el escenario j
var PotDerra{i in 1..Nescenarios} >=0; #matriz variable de la potencia no inyectada a la red por el generador eolico por escenario i
param CBalance; #variable del costo total de la etapa para el balance de potencia
param COperacion; #variable del costo de operacion de un dia en adelanto
param CTiroC; #varianble del costo del tiro de carga

#parametros para el calculo del beneficio de los participantes
param PMLese{i in 1..Nnodos, j in 1..Nescenarios}; #matriz variable del calculo de PML del nodo i por escenario j 
param Liquidacion{i in 1..Ngeneradores,j in 1..Nescenarios}; #matriz variable del la liquidacion del participante termico i en el escenario j
param CostoOperacion{i in 1..Ngeneradores,j in 1..Nescenarios}; #matriz variable del costo operativo del participante i en el escenario j
param Beneficio{i in 1..Ngeneradores,j in 1..Nescenarios}; #matriz variable del beneficio del participante i en el escenario j
param BeneficioEsperanza{i in 1..Ngeneradores}; #matriz del beneficio de los participantes en esperanza

#parametros para la escritura de resultados
param Despacho{i in 1..Nperiodos, j in 1..Ngeneradores};
param PML{i in 1..Nperiodos, j in 1..Nnodos};
param AuPot {i in 1..Ngeneradores, j in 1..Nescenarios};
param DisPot {i in 1..Ngeneradores, j in 1..Nescenarios};
param PD {i in 1..Nescenarios};

#variables para las condiciones KKT del nivel inferior
var Lambda{i in 1..Nnodos}; #variable del multiplicador lambda para la restriccion del flujo de potencia en el nodo i
var MiuFlujoLineaInferior{i in 1..Nlineas} >= 0; #variable del multiplicador mu para la restriccion del flujo minimo de linea i
var MiuFlujoLineaSuperior{i in 1..Nlineas} >= 0; #variable del multiplicador mu para la restriccion del flujo maximo de linea i
var MiuPotGenSup{i in 1..Ngeneradores} >= 0; #variable del multiplicador mu para la restriccion del potencia maxima del participante i
var MiuPotGenInf{i in 1..Ngeneradores} >= 0; #variable del multiplicador mu para la restriccion del potencia minima del participante i
var PWMAX >= 0; #variable de potencia maxima a despachar por el participante eolico i

#funcion objetivo a minimizar
minimize CostoTotal: 
		sum{i in 1..Ngeneradores}(CostoGenerador[i]*PotGenerador[i]) 
		+sum{i in 1..Nescenarios}(Probabilidad[i]*(sum{k in 1..Ngeneradores}(Flexible[k]*
		(CostoVenta[k]*rPG[k,i]-CostoCompra[k]*rNG[k,i]))+2000*(sum{k in 1..Nnodos}(Lshed[k,i]))));
				
#restricciones del problema de nivel superior del sistema				

#restringe el nodo 1 como nodo slack en cada escenario
subject to NodoReferenciaEscenario{i in 1..Nescenarios}:
		DeltaEscenario[1,i] = 0;

#restringe que la potencia de balance mas la potencia eolica probable mas los flujos de operacion y balance sea igual a 0 en cada escenario j
subject to BalanceNodalEscenario{i in 1..Nnodos, j in 1..Nescenarios}:
  		  (sum{k in 1..Ngeneradores}(IncGenFlex[k,i]*(rPG[k,j]-rNG[k,j])))
		+ (Lshed[i,j]) 
		+ (sum{k in 1..Ngeneradores}(IncGenEolico[k,i]*(PotenciaP[j] - PotGenerador[12] - PotDerra[j] )))
		- (sum{l in 1..Nnodos}(B[i,l]*(Delta[i]-Delta[l]))) 
		+ (sum{m in 1..Nnodos}(B[i,m]*(DeltaEscenario[i,j]-DeltaEscenario[m,j]))) = 0;
			
#restringe la varuable FPbalance a un valor positivo para cada escenario j
subject to FlujoBalance{i in 1..Nlineas, j in 1..Nescenarios}:
		FB[i,j]=( CapLin[i,4] * ( DeltaEscenario[CapLin[i,1],j]- DeltaEscenario[CapLin[i,2],j] ) );	
		
#restringe el flujo positivo de la linea i a un valor maximo por cada escenario j
subject to LimFluLinBal{i in 1..Nlineas, j in 1..Nescenarios}:
		-CapLin[i,3] <= FB[i,j] <= CapLin[i,3];
		
#restringe la potencia de venta del participante i por cada escenario j
subject to LimiteGeneradoresBalancePos{i in 1..Ngeneradores, j in 1..Nescenarios}:
		(PotGenerador[i] + (Flexible[i]*rPG[i,j])) <= PotGenMax[i];
			
#restringe la potencia de compra del participante i por cada escenario j
subject to LimiteGeneradoresBalanceNeg{i in 1..Ngeneradores, j in 1..Nescenarios}:
		(PotGenerador[i] - (Flexible[i]*rNG[i,j])) >= PotGenMin[i];

#restringe la venta de potencia a un valor maximo por participante i para cada escenario j
subject to AumentoPotencia{i in 1..Ngeneradores, j in 1..Nescenarios}:
		Flexible[i]*rPG[i,j] <= LimiteCompra[i];

#restringe la compra de potencia a un valor maximo por participante i para cada escenario j
subject to DisminucionPotencia{i in 1..Ngeneradores, j in 1..Nescenarios}:
		Flexible[i]*rNG[i,j] <= LimiteVenta[i]; 	
			
#restringe la potencia que no se inyecta a la red por el participante eolico para cada escenario j
subject to LimDerram{i in 1..Nescenarios}:
		PotDerra[i] <= PotenciaP[i];

#restringe el tiro de carga por nodo i para cada escenario j
subject to LimTiro{i in 1..Nnodos, j in 1..Nescenarios}:
		Lshed[i,j] <= L[i];

#restringe la potencia maxima a despachar a los limites maximos y minimos del participante eolico
subject to LimPWMAX:
		PotGenMin[12] <= PWMAX <= PotGenMax[12];

#restricciones de condiciones KKT

#restriccion del lagrangiano con respecto a la potencia
subject to LagrangianoP{i in 1..Ngeneradores}:
		CostoGenerador[i] + sum{j in 1..Nnodos}(IncNodGen[i,j]*Lambda[j])
		+ sum{j in 1..Nnodos}(IncNodGen[i,j]* MiuPotGenSup[i])
		- sum{j in 1..Nnodos}(IncNodGen[i,j]* MiuPotGenInf[i])= 0;

#restriccion del lagrangiano con respecto a los angulos de voltaje nodal 
subject to LagrangianoTeta{i in 1..Nnodos}:
		sum{j in 1..Nnodos}(Lambda[i]*B[i,j])
	   -sum{j in 1..Nnodos}(Lambda[j]*B[i,j])
	   +sum{j in 1..Nlineas}(M[i,j]*(MiuFlujoLineaSuperior[j] 
	   			- MiuFlujoLineaInferior[j])) = 0;
	   			
#restricciones de factibilidad del problema inferior (etapa de operacion)

#restringe el nodo 1 como nodo slack
subject to NodoReferencia:
				Delta[1] = 0;
				
#restringe que los flujos de potencia mas la potencia de salida de los participantes menos la demanda es 0
subject to BalanceNodal{i in 1..Nnodos}:	
		+ sum{j in 1..Nnodos}( B[i,j]*(Delta[i]-Delta[j]) ) 
		+ sum{j in 1..Ngeneradores}(IncNodGen[j,i]*PotGenerador[j])
		- L[i] = 0;	
				 
#restringe la varuable FP a un valor positivo
subject to FlujoPos{i in 1..Nlineas}:
		F[i] = ( CapLin[i,4] * ( Delta[CapLin[i,1]] - Delta[CapLin[i,2]] ) );	

#restringe el flujo positivo de la linea i a un valor maximo
subject to LimFluLin{i in 1..Nlineas}:
	   -CapLin[i,3] <= F[i] <= CapLin[i,3];
				 	 				
#restringe la potencia de salida del participantes i a un valor maximo
subject to LimGenMax{i in 1..Ngeneradores-1}:
		PotGenerador[i] <= PotGenMax[i];
		
#restringe la potencia de salida del participantes termicos i a un valor minima
subject to LimGenMin{i in 1..Ngeneradores}:
		PotGenerador[i] >= PotGenMin[i];
		
#restringe la potencia de salida del participante eolico a la variable multinivel	
subject to PwMax:
		PotGenerador[12] <= PWMAX;
		
#restricciones de complementariedad u holgura complementaria
subject to MiuFLI{i in 1..Nlineas}:
		MiuFlujoLineaInferior[i]*(-F[i] + CapLin[i,3]) = 0;
		
subject to MiuFLS{i in 1..Nlineas}:
		MiuFlujoLineaSuperior[i]*(F[i] - CapLin[i,3]) = 0;		
	
subject to MiuPGS{i in 1..Ngeneradores-1}:
		MiuPotGenSup[i]*(PotGenerador[i] - PotGenMax[i]) = 0;

subject to MiuPGSW:
		MiuPotGenSup[12]*(PotGenerador[12] - PWMAX) = 0;
	
subject to MiuPGI{i in 1..Ngeneradores}:
		MiuPotGenInf[i]*(-PotGenerador[i] + PotGenMin[i]) = 0;
	