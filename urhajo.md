
# DTR beadandó

## Bevezetés

A Döntéstámogató rendszerek tárgyra szánt beadandóm egy űrhajós menekülés. Az űrhajónak az intergalaktikus rendőrség elől kell menekülnie. Célunk hogy minél gyorsabban eljussunk a végponthoz, anélkül hogy a rendőrség elkapna minket. Ennek feltétele, hogy nem szállunk le olyan bolygón ahol a rendőrség járőrözik, és nem fogy el az üzemanyagunk a repülés közben. Mindent órában mérünk, így a kezdeti üzemanyag, a maradék üzemanyag, a töltés ideje, és az össztávolság is órában mérendő. Egy bolygón töltött idő nem haladhatja meg a 30 órát, különben a rendőrség elkap minket. Így kell spórolnunk az üzemanyaggal, hogy ne maradjunk az űrben két állomás között.

## Beviteli adatok

A következőkben az adatokat fogom bemutatni, amelyekkel a jelenleg bemutatott modell fog futni.

A modell egyetlen halmazból áll, a bolygóknak a halmazából. A bolygók neve egy generátorból lett létrehozva.

```ampl
set Planets;
```

Három paramétert kell definiálnom, amely a halmazra vonatkoznak. A DistanceInHour a kezdettől való távolságot jelenti órákbanban, a TimeToFill az az idő, amelyet egy bolygón lehet tölteni, ez függ attól hogy mennyi nyersanyaguk van, amelyből tudjuk tölteni az űrhajót, ha csak 20 van, úgy abban a tekintetben kell spórolni az üzemanyaggal. A SafeFromPolice pedig az információ, amely megállapítja, hogy van e rendőrség a bolygón vagy nem, amennyiben van, oda nem tudunk leszállni, különben a küldetésnek vége.

A további paraméterek "globálisak" azaz nem egy-egy bolygó tulajdonságait írják le.
Ebből négyet definiáltam, amelyek a TotalDistance, ami az össztávolságot adja meg, a töltesi idők nélkül. A TimeToDepleteTank, az azon érték, amely azt írja le, hogy mennyi időbe kerül az, hogy kiürüljön a tank. A TankAtStart, pedig természetesen azt jelenti, hogy a kezdetben mennyi üzemanyaggal indulunk. Legutolsó sorban a ConsumptionUnit, amely azt írha le, hogy óránként mennyi egységet fogyaszt a tankunk. Ezek mind órában mérendő értékek.

```ampl
param DistanceInHour{Planets}; #hours
param TimeToFill {Planets}; #hours
param SafeFromPolice {Planets} binary;

param TotalDistance; #hours 
param TimeToDepleteTank; #hours
param TankAtStart; #hours
param ConsumptionUnit; #hours
```
Váltzóm csak egyetlen egy lesz. Amely arra vonatkozik, hogy egy bolygón mennyi időt töltöttünk a tank feltöltésével.

```ampl
var CurrentFillingTime{Planets} >= 0;
```

A modell sikerét a korlátozások fogják jelenti, amellyel megszabjuk, hogy milyen feltételek mentén számoljon a modellünk, ezen feladat esetében négyet definiáltam.
Az első arra vonatkozik, hogy el kell jutnunk a célba, ez úgy fog működni, hogy a kezdő kapacitáshoz hozzáadjuk a fogyasztást, szorozva a bolygónkénti üzemanyagtöltéssel,amelynek nagyobbnak kell lennie mint az össztávolság, hiszen mindenképpen a  célba akarunk érni. Esetünkben a fogyasztás egyébként egy egység.

A második korlátozás arra vonatkozik, hogy a tankunkat nem tölthetjük túl, mint a teljes kapacitás.

A harmadik korlátozás megszabja, hogy egy bolygón nem tölthetünk többet, mint amennyi nyersanyaggal rendelkeznek.

Legutolsó sorban pedig az utolsó korlátozás azt csinálja, hogy egy bolygón nem tölthetünk 30 óránál több időt, hiszen akkor elkapnának minket a rendőrök.

Két korlátozás be van szorozva a SafeFromPolice paraméterrel, amely azt mutatja meg, hogy vannak e rendőrök a bolygón, így ahol nem biztonságos, ott 0 lesz, Így a korlátozás megszabja, hogy oda nem szállhat le az űrhajó.

```ampl
#El kell érnünk a célba
s.t. ReachEndOfRoute:
      (TankAtStart + sum {p in Planets} CurrentFillingTime[p]) * 1/ConsumptionUnit >= TotalDistance;

#Nem tölthetjük túl a tankot
s.t. CannotGoOverTankCapacity{p in Planets}:
      CurrentFillingTime[p] <= TimeToDepleteTank*SafeFromPolice[p];

#Egy bolygón nem tölthetünk több időt mint amennyi erőforrásuk van
s.t. CannotGoOverTankTimeToFill{p in Planets}:
      CurrentFillingTime[p] <= TimeToFill[p]*SafeFromPolice[p];
      
#Egy bolygón nem tölthetünk több időt mint 30óra
s.t. CannotGoOver30hour{p in Planets}:
      CurrentFillingTime[p] <= 30;
```

A modell célja az idő minimalizálása, a feltételek mellett. Az össztávolsághoz hozzáadjuk annak a szummáját, hogy mennyi időt töltöttünk töltéssel egy bolygón, szorozva azzal hogy azon a bolygón vannak e rendőrök, hiszen amennyiben vannak, úgy eleve nem is szállhatunk ott le.

```ampl
minimize TotalTime:
      TotalDistance + sum{p in Planets} CurrentFillingTime[p]*SafeFromPolice[p];
```

A következő kiíratást készítettem az adatok, amelyen látható, hogy az első bolygón nem szált le tankolni az űrhajó, hiszen ott rendőrök voltak. Az alaptávolsághoz képest 80 órába kerültek a tankolások, valamint látni rajta, hogy a második, a harmadik, és a negyedik bolygón állt meg, mivel ott teljesültek a feltételek.

```ampl
printf "\n";
printf "Alaptávolság: %d óra\n", TotalDistance;
printf "Leggyorsabb idő amennyi alatt odaér a hajó: %d óra\n", TotalDistance + sum{p in Planets} CurrentFillingTime[p]*SafeFromPolice[p];
printf "\n";
printf "Bolygón töltött idő:\n";
for{p in Planets}{
	printf "%s %d óra",p, CurrentFillingTime[p];
    printf ", Rendőrbiztos: %d\n",SafeFromPolice[p];
}
printf "\n";
```

## Adatok feltöltése
```ampl
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
```
## Teljes kód
```ampl
#Sets and params
/*
Menekülni kell az intergalaktikus rendőrség elől.

Minél gyorsabban a végpontban kell lenni.

Le kell szállni, ha elfogy az üzemanyag, nem szállhatok le olyan bolygókon, ahol járőröznek.

A bolygóknak van távolsága a kezdőponttól(időben).

Minden leszálláskor van egy ott eltöltött idő.(ameddig a tankot feltöltöm,)

Ha egy bolygón több az eltöltött idő mint 1 óra, akkor elkapnak.

Menekülni kell tehát gyorsnak kell lenni, el kell dönteni, hogy hogyan osztom be az időt a kezdéstől a végpontig hogy minél gyorsabban a célba érjek.(idő minimalizálása)
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

#Egy bolygón nem tölthetünk több időt mint amennyi erőforrásuk van
s.t. CannotGoOverTankTimeToFill{p in Planets}:
      CurrentFillingTime[p] <= TimeToFill[p]*SafeFromPolice[p];
      
#Egy bolygón nem tölthetünk több időt mint 30óra
s.t. CannotGoOver1hour{p in Planets}:
      CurrentFillingTime[p] <= 30;
      
#Objective function
#A Totál táv ideje, + a töltések ideje, olyan helyeken ahol nincsenek rendőrök
    minimize TotalTime:
      TotalDistance + sum{p in Planets} CurrentFillingTime[p]*SafeFromPolice[p];

solve;

#Printek
printf "\n";
printf "Alaptávolság: %d óra\n", TotalDistance;
printf "Leggyorsabb idő amennyi alatt odaér a hajó: %d óra\n", TotalDistance + sum{p in Planets} CurrentFillingTime[p]*SafeFromPolice[p];
printf "\n";
printf "Bolygón töltött idő:\n";
for{p in Planets}{
	printf "%s %d óra",p, CurrentFillingTime[p];
    printf ", Rendőrbiztos: %d\n",SafeFromPolice[p];
}
printf "\n";
#Data

data;

set Planets:= Chiseunov Nilliliv Ognion Yandov Souria Ouphus;

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
```
## Futtatás után

A modell lefuttatása után optimális megoldást kapunk. 

```ampl
Problem:    urhajo
Rows:       20
Columns:    6
Non-zeros:  28
Status:     OPTIMAL
Objective:  TotalTime = 200 (MINimum)

OPTIMAL LP SOLUTION FOUND
Time used:   0.0 secs
Memory used: 0.1 Mb (120727 bytes)
```
A kiiratás vizuálisan a következő ábrán látható:

```ampl
Alaptávolság: 120 óra
Leggyorsabb idő amennyi alatt odaér a hajó: 200 óra

Bolygón töltött idő:
Chiseunov 0 óra, Rendőrbiztos: 0
Nilliliv 30 óra, Rendőrbiztos: 1
Ognion 30 óra, Rendőrbiztos: 1
Yandov 20 óra, Rendőrbiztos: 1
Souria 0 óra, Rendőrbiztos: 0
Ouphus 0 óra, Rendőrbiztos: 1
```
**A második, a harmadik, és a negyedik bolygón kell leszállnunk az optimális megoldás eléréséhez, és ez 200 órát fog igénybe venni.**
