/* Tämä on mielivaltaisuloitteinen perceptron. */
/* Jos harjoitusdata annetaan komennolla harjoitteleVaroen(P,N), ohjelma antaa periksi tuhannen
   iteraation jälkeen ja siirtyy sovittamaan dataa olettaen yhden tai kaksi pistettä väärin 
   luokitelluiksi.*/


/* Saa lineaarisesti separoituvaa harjoitusdataa syötteenä. 
   Harjoitusdata on jaettu kahteen luokkaan valmiiksi. */


pos(X) :- X = [[2,1],[6,2],[4,1],[12,5],[2,-23]].
neg(X) :- X = [[2,5],[6,10],[4,5],[12,23],[-2,3]].

/* Iteroi painokerroinvektoria W kunnes se jakaa harjoitusdatan oikein. */
harjoittele :- pos([P1|P]),neg(N),
	       append(P1,[1],EkaArvaus),
	       sovita(EkaArvaus,[P1|P],N),
	       write('Sovitus onnistui, jakovektori: '),
	       ratk(X),write(X),nl,!.

harjoittele([P1|P],N) :-
    append(P1,[1],EkaArvaus),
    sovita(EkaArvaus,[P1|P],N),
    write('Sovitus onnistui, jakovektori: '),
    ratk(X),write(X),nl,!.

harjoittele(P,N, Arvaus) :-
		 sovita(Arvaus,P,N),
		 write('Sovitus onnistui, jakovektori: '),
		 ratk(X),write(X),nl,!.

sovita(W,P,N) :- apusovitus(W,P,N,P,N).

/* Käydään läpi kahta viimeistä listaa. Väärän luokittelun löytyessä korjataan jakovektoria ja
   aloitetaan listojen läpikäynti alusta. */
apusovitus(W,_,_,[],[]) :- siisti(W,Wlopullinen), asserta(ratk(Wlopullinen)). %Listat päästiin loppuun.
apusovitus(W,P,N,[X|Loput],N2) :- testipiste(W,X,T),T>=0, apusovitus(W,P,N,Loput,N2).
apusovitus(W,P,N,[X|Loput],N2) :- testipiste(W,X,T),T<0, %Virheellisesti negatiivinen.
				  korjaaPlus(W,X,Wuusi),!,
				  apusovitus(Wuusi,P,N,P,N).
apusovitus(W,P,N,[],[X|Loput]) :- testipiste(W,X,T),T<0,apusovitus(W,P,N,[],Loput).
apusovitus(W,P,N,[],[X|Loput]) :- testipiste(W,X,T),T>=0, %Virheellisesti positiivinen.
				  korjaaMiinus(W,X,Wuusi),!,
				  apusovitus(Wuusi,P,N,P,N).



/* Saadessaan pisteen, luokittelee sen jompaan kumpaan luokkaan. 
   Toimii myös pistelistalle. */
luokitteleLista([]).
luokitteleLista([P1|Loput]) :- luokittele(P1), luokitteleLista(Loput).

luokittele([]).
luokittele(X) :- ratk(W), testipiste(W,X,T), 
		 write('Piste '),write(X),apuluok(T),!.
apuluok(T) :- T<0, write(' kuuluu negatiiviseen luokkaan.'),nl,!.
apuluok(T) :- write(' kuuluu positiiviseen luokkaan.'),nl,!.


/* Apuvälineitä. */
/* ************* */

%itseisarvo
abs(Luku,Itseisarvo) :- Luku<0, Itseisarvo = -Luku,!.
abs(X,X).

/* Tämä ottaa mukaan ylimääräisen pisteen, joka mahdollistaa muutkin kuin origon kautta kulkevat ratkaisut.
   Siis pistetulo, jossa toisen kerrottavan loppuun on lisätty ylimääräinen koordinaatti 1. */
testipiste(W,Piste,Tulos) :- pistetulo(W,Piste,V), append(Alku,[Viimeinen],W), Tulos is V+Viimeinen.

%Laskee vektorin komponenteista pois toisen vektorin normitetut komponentit.
korjaaMiinus(W,X,Korjattu) :- append(X,[1],X2), alkioidenItseisarvojenSumma(X,Normi),
			apukorjaus(W,X2,Normi,[],Korjattu).

%Laskee vektorin komponentteihin lisää toisen vektorin normitetut komponentit.
korjaaPlus(W,X,Korjattu) :- append(X,[1],X2), alkioidenItseisarvojenSumma(X,Normi), Nor2 = -Normi,
			apukorjaus(W,X2,Nor2,[],Korjattu).

%Muuttaa vektoria komponenteittain toisen vektorin normitetuilla komponenteilla. 
apukorjaus([],_,_,Korjattu,Korjattu).
apukorjaus([W|LoputW],[X|LoputX],Normi,Akkum,Tulos) :-
    Seur is W-(X/Normi), %Jokaista koordinaattia korjataan pisteen normitetulla koordinaatilla.
    append(Akkum,[Seur],Ak),
    apukorjaus(LoputW,LoputX,Normi,Ak,Tulos).

%Laskee pistetuloa niin pitkälle kuin lyhyemmässä vektorissa riittää koordinaatteja.
pistetulo(_,[],0).
pistetulo([],_,0).
pistetulo([X|L1],[Y|L2],T) :- pistetulo(L1,L2,Rek), T is Rek + X*Y.

%Summaa vektorin komponenttien itseisarvot.
alkioidenItseisarvojenSumma(X,Summa) :- apusumma(X,0,Summa). %Palauttaa nollavektorille 1.
apusumma([],0,1).
apusumma([],Summa,Summa).
apusumma([X|Loput],Akkum,Tulos) :- abs(X,Xabs),Akk is Akkum + Xabs, apusumma(Loput,Akk,Tulos).

/* Palauttaa vektorin skaalattuna siten, että sen itseisarvoltaan pienin komponentti on 1 
   - ellei se alkuperäisessä vektorissa ollut 0. */
siisti(V,V) :- pieninKoordinaatti(V,0).
siisti(Vektori,VektoriJonkaPieninArvoOnYksi) :-
    pieninKoordinaatti(Vektori,Pienin), jaaKomponentit(Vektori,Pienin,VektoriJonkaPieninArvoOnYksi).

%Palauttaa vektorin komponenttien itseisarvoista pienimmän.
pieninKoordinaatti([Eka|Loput],Pienin) :- apupienin(Loput,Eka,Pienin).
apupienin([],T,T).
apupienin([E|L],P,T) :- vrt(E,P,Min), apupienin(L,Min,T).

%Jakaa vektorin kaikki komponentit annetulla jakajalla.
jaaKomponentit(V,Jakaja,T) :- apujaa(V,Jakaja,[],T).
apujaa([],_,T,T).
apujaa([E|Loput],J,Akk,Tulos) :- Jaettu is E/J,append(Akk,[Jaettu],Akkum),apujaa(Loput,J,Akkum,Tulos).

%Palauttaa kahdesta luvusta pienemmän itseisarvon.
vrt(X1,X2,Eka) :- abs(X1,Eka), abs(X2,Toka), Eka<Toka,!.
vrt(X1,X2,T) :- !, abs(X2,T).


/* Toinen toteutus harjoittelusta, tämä antaa periksi ison iteraatiomäärän jälkeen ja koettaa sitten kohdella yksittäisiä pisteitä väärin luokiteltuna. */

/* Iteroi painokerroinvektoria W kunnes se jakaa harjoitusdatan oikein. */
harjoitteleVaroen :- pos([P1|P]),neg(N),
	       append(P1,[1],EkaArvaus),
	       sovita2(EkaArvaus,[P1|P],N),
	       write('Sovitus onnistui, jakovektori: '),
	       ratk(X),write(X),nl,!.

harjoitteleVaroen([P1|P],N) :-
    append(P1,[1],EkaArvaus),
    sovita2(EkaArvaus,[P1|P],N),
    write('Sovitus onnistui, jakovektori: '),
    ratk(X),write(X),nl,!.

harjoitteleVaroen(P,N, Arvaus) :-
		 sovita2(Arvaus,P,N),
		 write('Sovitus onnistui, jakovektori: '),
		 ratk(X),write(X),nl,!.

sovita2(W,P,N) :- apusovitus2(1,W,P,N,P,N).
sovita2(W,P,N) :- append(L1,[X|L2],P),append(L1,L2,P2), %Siirretään X kohinana negatiiviseksi.
		 apusovitus2(1,W,P2,[X|N],P2,[X|N]), write('Data ei ollut lineaarisesti separoituvaa. Ratkaisun saamiseksi piste '),write(X),write(' luokiteltiin uudelleen negatiiviseksi. '). 
sovita2(W,P,N) :- append(L1,[X|L2],N),append(L1,L2,N2), %Siirretään X kohinana positiiviseksi.
		  apusovitus2(1,W,[X|P],N2,[X|P],N2),  write('Data ei ollut lineaarisesti separoituvaa. Ratkaisun saamiseksi piste '),write(X),write(' luokiteltiin uudelleen positiiviseksi. ').
sovita2(W,P,N) :- append(L1,[X|L2],P),append(L1,L2,P2), %Siirretään X kohinana negatiiviseksi
		  append(L3,[Y|L4],N),append(L3,L4,N2), % JA siirretään Y positiiviseksi.
		  apusovitus2(800,W,[Y|P2],[X|N2],P2,[X|N]), write('Data ei ollut lineaarisesti separoituvaa. Ratkaisun saamiseksi piste '),write(X),write(' luokiteltiin uudelleen negatiiviseksi ja piste '),
		  write(Y),write(' uudelleen positiiviseksi. '). 

apusovitus2(1000,_,_,_,_,_) :- !,fail.
apusovitus2(Laskuri,W,_,_,[],[]) :- siisti(W,Wlopullinen), asserta(ratk(Wlopullinen)). %Listat päästiin loppuun.
apusovitus2(Laskuri,W,P,N,[X|Loput],N2) :- testipiste(W,X,T),T>=0, apusovitus2(Laskuri,W,P,N,Loput,N2).
apusovitus2(Laskuri,W,P,N,[X|Loput],N2) :- testipiste(W,X,T),T<0, %Virheellisesti negatiivinen.
				  korjaaPlus(W,X,Wuusi),L2 is 1+Laskuri,!,
				  apusovitus2(L2,Wuusi,P,N,P,N).
apusovitus2(Laskuri,W,P,N,[],[X|Loput]) :- testipiste(W,X,T),T<0,apusovitus2(Laskuri,W,P,N,[],Loput).
apusovitus2(Laskuri,W,P,N,[],[X|Loput]) :- testipiste(W,X,T),T>=0, %Virheellisesti positiivinen.
				  korjaaMiinus(W,X,Wuusi),L2 is 1+Laskuri,!,
				  apusovitus2(L2,Wuusi,P,N,P,N).
