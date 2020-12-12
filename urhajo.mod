#Sets and params
/*
Menekülni kell az intergalaktikus rendõrség elõl.

Minél gyorsabban a végpontban kell lenni.

Le kell szállni, ha elfogy az üzemanyag, nem szállhatok le olyan bolygókon, ahol járõröznek.

A bolygóknak van távolsága a kezdõponttól(idõben).

Minden leszálláskor van egy ott eltöltött idõ.(ameddig a tankot feltöltöm,)

Ha egy bolygón több az eltöltött idõ mint 1 óra, akkor elkapnak.

Menekülni kell tehát gyorsnak kell lenni, el kell dönteni, hogy hogyan osztom be az idõt a kezdéstõl a végpontig hogy minél gyorsabban a célba érjek.(idõ minimalizálása)
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

#El kell érnünk a célba
s.t. ReachEndOfRoute:
      (TankAtStart + sum {p in Planets} CurrentFillingTime[p]) * 1/ConsumptionUnit >= TotalDistance;

#Nem tölthetjük túl a tankot
s.t. CannotGoOverTankCapacity{p in Planets}:
      CurrentFillingTime[p] <= TimeToDepleteTank*SafeFromPolice[p];

#Egy bolygón nem tölthetünk több idõt mint amennyi erõforrásuk van
s.t. CannotGoOverTankTimeToFill{p in Planets}:
      CurrentFillingTime[p] <= TimeToFill[p]*SafeFromPolice[p];
      
#Egy bolygón nem tölthetünk több idõt mint 60perc
s.t. CannotGoOver1hour{p in Planets}:
      CurrentFillingTime[p] <= 60;
      
#Objective function
#A Totál táv ideje, + a töltések ideje, olyan helyeken ahol nincsenek rendõrök
    minimize TotalTime:
      TotalDistance + sum{p in Planets} CurrentFillingTime[p]*SafeFromPolice[p];

solve;

#Printek
printf "\n";
printf "Alaptávolság: %d óra\n", TotalDistance;
printf "Leggyorsabb idõ amennyi alatt odaér a hajó: %d óra\n", TotalDistance + sum{p in Planets} CurrentFillingTime[p]*SafeFromPolice[p];
printf "\n";
printf "Bolygón töltött idõ:\n";
for{p in Planets}{
	printf "%s %d óra",p, CurrentFillingTime[p];
    printf ", Rendõrbiztos: %d\n",SafeFromPolice[p];
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