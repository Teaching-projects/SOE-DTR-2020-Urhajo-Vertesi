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

param Distance{Planets}; #lightyear
param TimeToFill {Planets}; #hour
param SafeFromPolice {Planets} binary;

param TotalDistance; #lightyear 
param TankCapacity; #liter
param TankAtStart; #liter
param Consumption; #liter/hour

#Variables

 var CurrentFillingTime{Planets} >= 0; #töltési idõ

#Constraints

#El kell érnünk a célba
s.t. ReachEndOfRoute:
      (TankAtStart + sum {p in Planets} CurrentFillingTime[p]) * Consumption >= TotalDistance;

#Nem tölthetjük túl a tankot
s.t. CannotGoOverTankCapacity{p in Planets}:
      TankAtStart + sum {p2 in Planets: Distance[p2] < Distance[p]} CurrentFillingTime[p2] - Distance[p] * Consumption + CurrentFillingTime[p] <= TankCapacity;

#Nem fogyhat ki a tank
s.t. TankCannotBeZero{p in Planets}:
            TankAtStart + sum {p2 in Planets: Distance[p2] < Distance[p]} CurrentFillingTime[p2] - Distance[p] * Consumption + CurrentFillingTime[p] >= 0;

#Egy bolygón nem tölthetünk több idõt mint amennyi erõforrásuk van
s.t. CannotGoOverTankTimeToFill{p in Planets}:
      CurrentFillingTime[p] <= TimeToFill[p]*SafeFromPolice[p];
      
#Egy bolygón nem tölthetünk több idõt mint 30óra
s.t. CannotGoOver1hour{p in Planets}:
      CurrentFillingTime[p] <= 30;

      
#Objective function
#A Totál táv ideje, + a töltések ideje, olyan helyeken ahol nincsenek rendõrök
    minimize TotalTime:
      TotalDistance + sum{p in Planets} CurrentFillingTime[p]*SafeFromPolice[p];

solve;

#Printek
printf "\n";
printf "Alaptávolság: %d fényév\n", TotalDistance;
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

param: 			Distance 		TimeToFill  SafeFromPolice:=
Chiseunov		20						30          0
Nilliliv		50						40          1
Ognion		    60						50          1
Yandov		    70						30          1
Souria		    80						20          0
Ouphus		    90						50          1;


param TotalDistance:= 120; #lightyear
param TankAtStart:= 40; #Liter
param TankCapacity := 40; #Liter
param Consumption := 1; #liter/hour

end;