
  
# DTR beadandó

## Bevezetés

A Döntéstámogató rendszerek tárgyra szánt beadandóm egy űrhajós menekülés. Az űrhajónak az intergalaktikus rendőrség elől kell menekülnie. Célunk hogy minél gyorsabban eljussunk a végponthoz, anélkül hogy a rendőrség elkapna minket. Ennek feltétele, hogy nem szállunk le olyan bolygón ahol a rendőrség járőrözik, és nem fogy el az üzemanyagunk a repülés közben. A távolságot fényévben, az üzemenyag űrtartamát,és a fogyasztást literben a bolygón töltéssel eltöltött időt pedig órában mérjük.  Egy bolygón töltött idő nem haladhatja meg a 30 órát, különben a rendőrség elkap minket. Így kell spórolnunk az üzemanyaggal, hogy ne maradjunk az űrben két állomás között.

## Beviteli adatok

A következőkben az adatokat fogom bemutatni, amelyekkel a jelenleg bemutatott modell fog futni.

A modell egyetlen halmazból áll, a bolygóknak a halmazából. A bolygók neve egy generátorból lett létrehozva.

```ampl
set Planets;
```

Négy paramétert kell definiálnom, amely a halmazra vonatkoznak. A Distance a kezdettől való távolságot jelenti fényévben, a TimeToEmptyAvailableRescource az az idő, amely alatt elfogy az ott tárolt nyersanyaguk amiből az üzemanyagot tudjuk tölteni, ez függ attól hogy mennyi nyersanyaguk van, amelyből tudjuk tölteni az űrhajót, ha csak 20 van, úgy abban a tekintetben kell spórolni az idővel. Viszont a következő paraméter,  a FillSpeed ami az mutatja meg, hogy milyen gyorsan tudják tölteni a tankot, ha 2-es sebességgel tölt egy 20 nyersanyagos bolygó állomása, úgy 40 liter üzemanyagot tudunk tankolni 20 helyett, mintha csak 1-es sebességgel töltenénk. A SafeFromPolice pedig az információ, amely megállapítja, hogy van e rendőrség a bolygón vagy nem, amennyiben van, oda nem tudunk leszállni, különben a küldetésnek vége.

A további paraméterek "globálisak" azaz nem egy-egy bolygó tulajdonságait írják le.
Ebből négyet definiáltam, amelyek a TotalDistance, ami az össztávolságot adja meg, a töltesi idők nélkül. A TankCapacity , az azon érték, amely azt írja le, hogy mennyi liter üzemanyag fér bele a tankba. A TankAtStart, pedig természetesen azt jelenti, hogy a kezdetben mennyi üzemanyaggal indulunk. Legutolsó sorban a Consumption, amely azt írha le, hogy óránként mennyi egységet fogyaszt a tankunk óránként.

```ampl
param Distance{Planets}; #lightyear
param TimeToEmptyAvailableRescource {Planets}; #hour
param SafeFromPolice {Planets} binary;
param FillSpeed {Planets}; #liter/hour

param TotalDistance; #lightyear 
param TankCapacity; #liter
param TankAtStart; #liter
param Consumption; #liter/hour
```
Váltzóm csak egyetlen egy lesz. Amely arra vonatkozik, hogy egy bolygón mennyi időt töltöttünk a tank feltöltésével.

```ampl
var CurrentFillingTime{Planets} >= 0; #töltési idő
```

## Korlátozások
A modell sikerét a korlátozások fogják jelenti, amellyel megszabjuk, hogy milyen feltételek mentén számoljon a modellünk, ezen feladat esetében ötöt definiáltam.

Az első arra vonatkozik, hogy el kell jutnunk a célba, ez úgy fog működni, hogy a kezdő kapacitáshoz hozzáadjuk a fogyasztást, szorozva a bolygónkénti üzemanyagtöltéssel és a sebességgel,amelynek nagyobbnak kell lennie mint az össztávolság, hiszen mindenképpen a  célba akarunk érni.

```ampl
#El kell érnünk a célba
s.t. ReachEndOfRoute:
      (TankAtStart + sum {p in Planets} CurrentFillingTime[p]*FillSpeed[p]) * Consumption >= TotalDistance;
```
A Tankunk nem mehet 0 alá, és a tankkapacítás, azaz 40 fölé, egy korábbi előadás példájának segítségével ezt úgy oldottam meg, hogy a modell megnézi mennyi van még a tankunkban, mielőtt elhagyjuk a bolygót, és ezt az adatot veti össze a felső, és az alsó határértékkel.
```ampl
#Nem tölthetjük túl a tankot
s.t. CannotGoOverTankCapacity{p in Planets}:
      TankAtStart + sum {p2 in Planets: Distance[p2] < Distance[p]} CurrentFillingTime[p2]*FillSpeed[p2] - Distance[p] * Consumption + (CurrentFillingTime[p]*FillSpeed[p]) <= TankCapacity;
```
```ampl
#Nem fogyhat ki a tank
s.t. TankCannotBeZero{p in Planets}:
            TankAtStart + sum {p2 in Planets: Distance[p2] < Distance[p]} CurrentFillingTime[p2]*FillSpeed[p2] * Consumption >= Distance[p];
```
A bolygón véges mennyiségű nyersanyag van amit felhasználhatunk üzemanyagnak, így ezzel a korlátozással azt figyelem, hogy meddig lehetek a bolygón, hozzávetve hogy egyáltalán a rendőrök miatt le lehet-e szállni arra a bolygóra.
```ampl
#Egy bolygón nem tölthetünk több időt mint amennyi erőforrásuk van
s.t. CannotGoOverAvailableRescource{p in Planets}:
      CurrentFillingTime[p] <= TimeToEmptyAvailableRescource[p]*SafeFromPolice[p];

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
      TotalDistance + sum{p in Planets} CurrentFillingTime[p];
```

A következő kiíratást készítettem az adatok, amelyen látható, hogy az első bolygón nem szált le tankolni az űrhajó, hiszen ott rendőrök voltak. Az alaptávolsághoz képest 80 órába kerültek a tankolások, valamint látni rajta, hogy a második, a harmadik, és a negyedik bolygón állt meg, mivel ott teljesültek a feltételek.

```ampl
printf "\n";
printf "Alaptávolság: %d fényév\n", TotalDistance;
printf "Leggyorsabb idő amennyi alatt odaér a hajó: %d óra\n", TotalDistance + sum{p in Planets} CurrentFillingTime[p];
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
```

## Futtatás után

A modell lefuttatása után optimális megoldást kapunk. 

```ampl
Problem:    urhajo
Rows:       50
Columns:    12
Non-zeros:  192
Status:     OPTIMAL
Objective:  TotalTime = 354.1666667 (MINimum)

OPTIMAL LP SOLUTION FOUND
Time used:   0.0 secs
Memory used: 0.1 Mb (148540 bytes)
```
A kiiratás vizuálisan a következő ábrán látható:

```ampl
Alaptávolság: 250 fényév
Leggyorsabb idő amennyi alatt odaér a hajó: 354 óra

Bolygón töltött idő:
Chiseunov 7 óra, Rendőrbiztos: 1
Nilliliv 5 óra, Rendőrbiztos: 1
Ognion 0 óra, Rendőrbiztos: 0
Yandov 5 óra, Rendőrbiztos: 1
Souria 20 óra, Rendőrbiztos: 1
Ouphus 0 óra, Rendőrbiztos: 0
ThadusE97 10 óra, Rendőrbiztos: 1
Durn08P 0 óra, Rendőrbiztos: 0
Alea 20 óra, Rendőrbiztos: 1
Isomia 20 óra, Rendőrbiztos: 1
Vicrosie 10 óra, Rendőrbiztos: 1
Tulvaomia 8 óra, Rendőrbiztos: 1
```
**A fenti kimenet mutatja a modellünk kimenetelét, ahol láthatjuk hogy figyelembe véve a rendőröket, a töltési sebességet, és a nyersanyagok rendelkezésre állását, úgy az utat 354 óra alatt teszi meg az űrhajó az utat a jelenlegi adatokkal.**
