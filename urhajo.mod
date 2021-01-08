#Sets and params

set Planets;

param Distance{Planets}; #lightyear
param TimeToEmptyAvailableRescource {Planets}; #hour
param SafeFromPolice {Planets} binary;
param FillSpeed {Planets}; #liter/hour

param TotalDistance; #lightyear 
param TankCapacity; #liter
param TankAtStart; #liter
param Consumption; #liter/hour

#Variables

 var CurrentFillingTime{Planets} >= 0; #töltési idõ

#Constraints

#El kell érnünk a célba
s.t. ReachEndOfRoute:
      (TankAtStart + sum {p in Planets} CurrentFillingTime[p]*FillSpeed[p]) * Consumption >= TotalDistance;

#Nem tölthetjük túl a tankot
s.t. CannotGoOverTankCapacity{p in Planets}:
      TankAtStart + sum {p2 in Planets: Distance[p2] < Distance[p]} CurrentFillingTime[p2]*FillSpeed[p2] - Distance[p] * Consumption + (CurrentFillingTime[p]*FillSpeed[p]) <= TankCapacity;

#Nem fogyhat ki a tank
s.t. TankCannotBeZero{p in Planets}:
            TankAtStart + sum {p2 in Planets: Distance[p2] < Distance[p]} CurrentFillingTime[p2]*FillSpeed[p2] * Consumption >= Distance[p];

#Egy bolygón nem tölthetünk több idõt mint amennyi erõforrásuk van
s.t. CannotGoOverAvailableRescource{p in Planets}:
      CurrentFillingTime[p] <= TimeToEmptyAvailableRescource[p]*SafeFromPolice[p];
      
#Egy bolygón nem tölthetünk több idõt mint 30óra
s.t. CannotGoOver1hour{p in Planets}:
      CurrentFillingTime[p] <= 30;

      
#Objective function
#A Totál táv ideje, + a töltések ideje, olyan helyeken ahol nincsenek rendõrök
    minimize TotalTime:
      TotalDistance + sum{p in Planets} CurrentFillingTime[p];

solve;

#Printek
printf "\n";
printf "Alaptávolság: %d fényév\n", TotalDistance;
printf "Leggyorsabb idõ amennyi alatt odaér a hajó: %d óra\n", TotalDistance + sum{p in Planets} CurrentFillingTime[p];
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
			Chiseunov Nilliliv Ognion Yandov Souria Ouphus ThadusE97 Durn08P Alea Isomia Vicrosie Tulvaomia;

param: 			Distance 		    TimeToEmptyAvailableRescource  FillSpeed  SafeFromPolice:=
Chiseunov		20						        20                    3            1
Nilliliv		35						        40                    3            1
Ognion		    50						        10                    4            0
Yandov		    70						        30                    1            1
Souria		    80						        20                    2            1
Ouphus		    90						        50                    4            0
ThadusE97		100						        30                    2            1
Durn08P		    120						        40                    3            0
Alea		    140						        50                    2            1
Isomia		    170						        30                    1            1
Vicrosie		200					            20                    2            1
Tulvaomia	    220						        50                    4            1;


param TotalDistance:= 250; #lightyear
param TankAtStart:= 40; #Liter
param TankCapacity := 40; #Liter
param Consumption := 1; #liter/hour

end;