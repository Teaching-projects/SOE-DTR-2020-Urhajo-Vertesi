#Sets and params
/*
Menek�lni kell az intergalaktikus rend�rs�g el�l.

Min�l gyorsabban a v�gpontban kell lenni.

Le kell sz�llni, ha elfogy az �zemanyag, nem sz�llhatok le olyan bolyg�kon, ahol j�r�r�znek.

A bolyg�knak van t�vols�ga a kezd�pontt�l(id�ben).

Minden lesz�ll�skor van egy ott elt�lt�tt id�.(ameddig a tankot felt�lt�m,)

Ha egy bolyg�n t�bb az elt�lt�tt id� mint 1 �ra, akkor elkapnak.

Menek�lni kell teh�t gyorsnak kell lenni, el kell d�nteni, hogy hogyan osztom be az id�t a kezd�st�l a v�gpontig hogy min�l gyorsabban a c�lba �rjek.(id� minimaliz�l�sa)
*/

#Sets and params

set Planets;

param DistanceInHour{Planets}; #hours
param TimeToFill {Planets}; #hours
param SafeFromPolice {Planets} binary;

param TotalDistance; #hours 
param TimeToDepleteTank; #hours
param TankAtStart; #hours
param ConsumptionUnit; #hours

#Variables

 var CurrentFillingTime{Planets} >= 0;

#Constraints

#El kell �rn�nk a c�lba
s.t. ReachEndOfRoute:
      (TankAtStart + sum {p in Planets} CurrentFillingTime[p]) * 1/ConsumptionUnit >= TotalDistance;

#Nem t�lthetj�k t�l a tankot
s.t. CannotGoOverTankCapacity{p in Planets}:
      CurrentFillingTime[p] <= TimeToDepleteTank*SafeFromPolice[p];

#Egy bolyg�n nem t�lthet�nk t�bb id�t mint amennyi er�forr�suk van
s.t. CannotGoOverTankTimeToFill{p in Planets}:
      CurrentFillingTime[p] <= TimeToFill[p]*SafeFromPolice[p];
      
#Egy bolyg�n nem t�lthet�nk t�bb id�t mint 60perc
s.t. CannotGoOver1hour{p in Planets}:
      CurrentFillingTime[p] <= 60;
      
#Objective function
#A Tot�l t�v ideje, + a t�lt�sek ideje, olyan helyeken ahol nincsenek rend�r�k
    minimize TotalTime:
      TotalDistance + sum{p in Planets} CurrentFillingTime[p]*SafeFromPolice[p];

solve;

#Printek
printf "\n";
printf "Alapt�vols�g: %d �ra\n", TotalDistance;
printf "Leggyorsabb id� amennyi alatt oda�r a haj�: %d �ra\n", TotalDistance + sum{p in Planets} CurrentFillingTime[p]*SafeFromPolice[p];
printf "\n";
printf "Bolyg�n t�lt�tt id�:\n";
for{p in Planets}{
	printf "%s %d �ra",p, CurrentFillingTime[p];
    printf ", Rend�rbiztos: %d\n",SafeFromPolice[p];
}
printf "\n";
#Data

data;

set Planets:= 
			Chiseunov Nilliliv Ognion Yandov Souria Ouphus;

param: 			DistanceInHour 		TimeToFill  SafeFromPolice:=
Chiseunov		20						30          0
Nilliliv		50						40          1
Ognion		    60						50          1
Yandov		    70						30          1
Souria		    80						20          0
Ouphus		    90						50          1;


param TotalDistance:= 120; #hour
param TankAtStart:= 40;
param TimeToDepleteTank := 40; #hour
param ConsumptionUnit := 1; #hour

end;