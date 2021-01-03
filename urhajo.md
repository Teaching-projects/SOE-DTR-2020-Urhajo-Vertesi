
  
# DTR beadandó

## Bevezetés

A Döntéstámogató rendszerek tárgyra szánt beadandóm egy űrhajós menekülés. Az űrhajónak az intergalaktikus rendőrség elől kell menekülnie. Célunk hogy minél gyorsabban eljussunk a végponthoz, anélkül hogy a rendőrség elkapna minket. Ennek feltétele, hogy nem szállunk le olyan bolygón ahol a rendőrség járőrözik, és nem fogy el az üzemanyagunk a repülés közben. A távolságot fényévben, az üzemenyag űrtartamát,és a fogyasztást literben a bolygón töltéssel eltöltött időt pedig órában mérjük.  Egy bolygón töltött idő nem haladhatja meg a 30 órát, különben a rendőrség elkap minket. Így kell spórolnunk az üzemanyaggal, hogy ne maradjunk az űrben két állomás között.

## Beviteli adatok

A következőkben az adatokat fogom bemutatni, amelyekkel a jelenleg bemutatott modell fog futni.

A modell egyetlen halmazból áll, a bolygóknak a halmazából. A bolygók neve egy generátorból lett létrehozva.

```ampl
set Planets;
```

Három paramétert kell definiálnom, amely a halmazra vonatkoznak. A Distance a kezdettől való távolságot jelenti fényévben, a TimeToFill az az idő, amelyet egy bolygón lehet tölteni, ez függ attól hogy mennyi nyersanyaguk van, amelyből tudjuk tölteni az űrhajót, ha csak 20 van, úgy abban a tekintetben kell spórolni az üzemanyaggal. A SafeFromPolice pedig az információ, amely megállapítja, hogy van e rendőrség a bolygón vagy nem, amennyiben van, oda nem tudunk leszállni, különben a küldetésnek vége.

A további paraméterek "globálisak" azaz nem egy-egy bolygó tulajdonságait írják le.
Ebből négyet definiáltam, amelyek a TotalDistance, ami az össztávolságot adja meg, a töltesi idők nélkül. A TankCapacity , az azon érték, amely azt írja le, hogy mennyi liter üzemanyag fér bele a tankba. A TankAtStart, pedig természetesen azt jelenti, hogy a kezdetben mennyi üzemanyaggal indulunk. Legutolsó sorban a Consumption, amely azt írha le, hogy óránként mennyi egységet fogyaszt a tankunk óránként.

```ampl
param Distance{Planets}; #lightyear
param TimeToFill {Planets}; #hour
param SafeFromPolice {Planets} binary;

param TotalDistance; #lightyear 
param TankCapacity; #liter
param TankAtStart; #liter
param Consumption; #liter/hour
```
Váltzóm csak egyetlen egy lesz. Amely arra vonatkozik, hogy egy bolygón mennyi időt töltöttünk a tank feltöltésével.

```ampl
var CurrentFillingTime{Planets} >= 0; #töltési idő
```
A modell sikerét a korlátozások fogják jelenti, amellyel megszabjuk, hogy milyen feltételek mentén számoljon a modellünk, ezen feladat esetében négyet definiáltam.

Az első arra vonatkozik, hogy el kell jutnunk a célba, ez úgy fog működni, hogy a kezdő kapacitáshoz hozzáadjuk a fogyasztást, szorozva a bolygónkénti üzemanyagtöltéssel,amelynek nagyobbnak kell lennie mint az össztávolság, hiszen mindenképpen a  célba akarunk érni.

```ampl
#El kell érnünk a célba
s.t. ReachEndOfRoute:
      (TankAtStart + sum {p in Planets} CurrentFillingTime[p]) * Consumption >= TotalDistance;
```
A Tankunk nem mehet 0 alá, és a tankkapacítás, azaz 40 fölé, egy korábbi előadás példájának segítségével ezt úgy oldottam meg, hogy a modell megnézi mennyi van még a tankunkban, mielőtt elhagyjuk a bolygót, és ezt az adatot veti össze a felső, és az alsó határértékkel.
```ampl
#Nem tölthetjük túl a tankot
s.t. CannotGoOverTankCapacity{p in Planets}:
      TankAtStart + sum {p2 in Planets: Distance[p2] < Distance[p]} CurrentFillingTime[p2] - Distance[p] * Consumption + CurrentFillingTime[p] <= TankCapacity;
```
```ampl
#Nem fogyhat ki a tank
s.t. TankCannotBeZero{p in Planets}:
            TankAtStart + sum {p2 in Planets: Distance[p2] < Distance[p]} CurrentFillingTime[p2] - Distance[p] * Consumption + CurrentFillingTime[p] >= 0;
```
A bolygón véges mennyiségű nyersanyag van amit felhasználhatunk üzemanyagnak, így ezzel a korlátozással azt figyelem, hogy meddig lehetek a bolygón, hozzávetve hogy egyáltalán a rendőrök miatt le lehet-e szállni arra a bolygóra.
```ampl
#Egy bolygón nem tölthetünk több időt mint amennyi erőforrásuk van
s.t. CannotGoOverTankTimeToFill{p in Planets}:
      CurrentFillingTime[p] <= TimeToFill[p]*SafeFromPolice[p];
   ```
A rendelkezésre álló nyersanyag ellenére sem lehetünk 30 óránál többet egy bolygón, így hogyha az ott tartózkodás eléri ezt az időt, a hajónak fel kell szállnia, különben elkapják.
```ampl
#Egy bolygón nem tölthetünk több időt mint 30óra
s.t. CannotGoOver1hour{p in Planets}:
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
printf "Alaptávolság: %d fényév\n", TotalDistance;
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
```

## Futtatás után

A modell lefuttatása után optimális megoldást kapunk. 

```ampl
.Problem:    urhajo
Rows:       20
Columns:    6
Non-zeros:  28
Status:     OPTIMAL
Objective:  TotalTime = 200 (MINimum)

OPTIMAL LP SOLUTION FOUND
Time used:   0.0 secs
Memory used: 0.1 Mb (129330 bytes)
```
A kiiratás vizuálisan a következő ábrán látható:

```ampl
Alaptávolság: 120 fényév
Leggyorsabb idő amennyi alatt odaér a hajó: 200 óra

Bolygón töltött idő:
Chiseunov 0 óra, Rendőrbiztos: 0
Nilliliv 30 óra, Rendőrbiztos: 1
Ognion 30 óra, Rendőrbiztos: 1
Yandov 10 óra, Rendőrbiztos: 1
Souria 0 óra, Rendőrbiztos: 0
Ouphus 10 óra, Rendőrbiztos: 1
```
**Minden olyan bolygón le kellett egyszer szállnunk, ahol nincsenek rendőrök, és maximum 30 órát töltött a hajó egy bolygón annak ellenére, hogy lett volna még nyersanyaguk, hiszen úgy a rendőrök elkapták volna.**
