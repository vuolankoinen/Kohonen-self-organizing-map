% Laskee klusterikeskipisteet
% Datapisteet koordinaattilistoina, syöte listana datapisteitä.
% Pisteitä vertaillessa olettaa häntäpäästä puuttuvat koordinaatit nolliksi. Dimensioiden kanssa ei
% siis ole niin turhantarkkaa. Keskipisteet mm. päätyvät alustuksestaan huolimatta oikeaan dimensioon.

koedata(X) :- X = [[1,2,3],[1,3,3],[1,12,12],[3,5,10],[4,23,13],[1,50,12],[54,130,250],[14,45,340],[10,20,123],[30,234,1221],[32,120,80],[20,30,20],[45,200,340],[102,230,200],[20,30,20]].
koedata2(X) :- X = [[2,3],[3,3],[12,12],[5,10],[23,13],[50,12],[130,250],[45,340],[10,123],[30,1221],[120,80],[30,20],[200,340],[102,230],[20,20]].
koedata3(X) :- X = [[2,3,34,1],[3,34,13,-2],[12,34,1,12],[5,34,1,10],[23,13,34,1],[50,12,34,1],[1,34,130,250],[4,34,15,340],[10,12,34,13],[3,34,10,1221],[1,34,120,80],[30,34,1,20],[20,34,10,340],[102,34,1,230],[20,34,1,20]].
vektorit3d(X) :- X = [[1, 0, 0], [0, 1, 0], [0, 0, 1]].
arvoVektorit(Monta, Tulos) :- apuAV(Monta, [], Tulos).
apuAV(0, Tulos, Tulos).
apuAV(Mont, A, Tulos) :- random(S1), random(S2), random(S3), Sv = [S1,S2,S3],
	M is Mont - 1, apuAV(M, [Sv|A],Tulos). 

k_means :- vektorit3d(Alkuvektorit), koedata(Data), k_means(Data, Alkuvektorit,1).
k_means([H|T]) :- vektorit3d(Alkuvektorit), k_means([H|T], Alkuvektorit,1).
k_means(Klustereita) :- arvoVektorit(Klustereita, AlkVektorit), koedata(Data), k_means(Data,AlkVektorit,1).
k_means(Data, Klustereita) :- arvoVektorit(Klustereita, AlkVektorit), k_means(Data,AlkVektorit,1).
k_means(Data, Vektorit,1) :- iter(Data, Vektorit, Data).

iter(Edelliset, Seuraavat, Data) :- kutakuinkin(Edelliset,Seuraavat),
	print('**Tulos.**\nRyppäiden keskipisteet:\n'), tulostaListoja(Seuraavat),
	luokitteleLahimpienMukaan(Seuraavat, Data, Jaotellut),
	print('Jako ryppäisiin:\n'), tulostaListoja(Jaotellut),!.
iter(_,S,Data) :- laskeUudet(S,Data).

laskeUudet(Edelliset,Data) :- luokitteleLahimpienMukaan(Edelliset, Data, Luokat),
	paivitaKeskiarvot(Luokat, Uudet),
	iter(Edelliset, Uudet, Data).

luokitteleLahimpienMukaan(Edustajat, Data, Tulos) :-
	puhtaatListat(Edustajat,[],L), apuLuokittele(Edustajat, Data, L, Tulos).
apuLuokittele(Edust, [D|Loput], Akk, Tulos) :-
	lahinLuokka(D, Edust, 0, -2,-2, N), lisaaLuokkaanN(D,Akk,N,Akkseur),
	apuLuokittele(Edust, Loput,Akkseur,Tulos),!.
apuLuokittele(_,[],Tulos,Tulos).

puhtaatListat([],Tulos,Tulos). %Yhtä monta tyhjää listaa kuin annetussa listassa alkioita.
puhtaatListat([_|Loput],Akk,Tulos) :- append(Akk,[[]],AkkS), puhtaatListat(Loput,AkkS,Tulos).

lahinLuokka(A, [Ed|Loput], 0,_,_,Tulos) :- %Eka luokka.
	erotus(A,Ed, Ero), lahinLuokka(A,Loput,1,Ero,0,Tulos).
lahinLuokka(A, [Ed|Loput], Mones,Paras,_,Tulos) :- erotus(A, Ed, Ero), Ero < Paras,
	M is Mones + 1,lahinLuokka(A, Loput, M, Ero, Mones, Tulos),!.
lahinLuokka(A, [_|Loput], Mones,Paras,Ehdokas,Tulos) :-
	M is Mones + 1,lahinLuokka(A, Loput, M, Paras, Ehdokas, Tulos),!.
lahinLuokka(_,[],_,_,Tulos,Tulos).

/* Tuuppaa listalistan N:nteen listaan alkion A loppuun.*/
lisaaLuokkaanN(Alkio, Luokat, N, Tulos) :- apuLisaa(Alkio, Luokat, N, [], Tulos).
apuLisaa(A, [L|Loput], 0, Akk, Tulos) :- append(L,[A],Llisatty), append(Akk, [Llisatty], Alku),
	append(Alku,Loput,Tulos),!.
apuLisaa(A, [L|Loput], N, Akk, Tulos) :- Nseur is N - 1, append(Akk, [L], Akkseur),
	apuLisaa(A, Loput, Nseur, Akkseur, Tulos).
apuLisaa(_,L,N,A,Tulos) :- N < 0, append(A,L,Tulos).

paivitaKeskiarvot(L, Tulos) :- apuKesk(L, [], Tulos).
apuKesk([L|Loput], Akk, Tulos) :- keskiarvot(L,Kesk), append(Akk, [Kesk], Akk2),
	apuKesk(Loput, Akk2, Tulos).
apuKesk([],Tulos,Tulos).

keskiarvot(L, Tulos) :- % koordinaattilistan keskiarvot koordinaateittain
	apuKAt(L, [], 0, Tulos),!.
apuKAt([],_,0,[0]).
apuKAt([L|Loput], Summat, Lukum, Tulos) :- listasumma(L,Summat,S), Lseur is Lukum +1,
	apuKAt(Loput,S,Lseur,Tulos).
apuKAt([],S,Luku,T) :- jakoAlkioittain(S,Luku,T).

listasumma(L1,L2,Summat) :- apuListas(L1,L2,[],Summat).
apuListas([],[],Summat,Summat).
apuListas([H1|Loput1],[],Akk,Summat) :- append(Akk, [H1], Aseur),
	apuListas(Loput1,[],Aseur,Summat).
%apuListas([],[H1|Loput1],Akk,Summat) :_-append(Akk, [H1], Aseur),
%	apuListas(Loput1,[],Aseur,Summat).
apuListas([H1|Loput1],[H2|Loput2],Akk,Summat) :- S is H1 + H2, append(Akk, [S], Aseur),
	apuListas(Loput1,Loput2,Aseur,Summat).

jakoAlkioittain(L, Jakaja, Tulos) :- apuJakoAlkioittain(L,Jakaja,[],Tulos).
apuJakoAlkioittain([],_,Tulos,Tulos).
apuJakoAlkioittain(_,0,_,_) :- print('****\n\nHei! Älä jaa nollalla!\n\n'''''),!,fail.
apuJakoAlkioittain([H|Loput],A,Akk,Tulos) :- Y is H / A, append(Akk,[Y],Akkseur),
	apuJakoAlkioittain(Loput,A,Akkseur,Tulos).


kutakuinkin(L1,L2) :- apuKutak(L1,L2,0,Ero), !, Ero < 0.02.
apuKutak([L1|Loput1],[L2|Loput2],Akk,Tulos) :- erotus(L1,L2,Ero), Akk2 is Akk + Ero, apuKutak(Loput1,Loput2,Akk2,Tulos).
apuKutak(_,_,Tulos,Tulos).
/* Huom. seuraava erotus vaikuttaa tuloksiin! */
erotus(L1,L2,Tulos) :- apuEro(L1,L2,0,Tulos),!.
apuEro([],[],Summa,Tulos) :- Tulos is sqrt(Summa).
apuEro([A1|Loput1],[A2|Loput2],Akk,Tulos) :- absE(A1,A2,Y), Akk2 is Akk + Y*Y,
	apuEro(Loput1,Loput2,Akk2,Tulos).
apuEro([L|Loput],[],Akk,Tulos) :- max(-L,L,Y), Akk2 is Akk + Y*Y, apuEro(Loput,[],Akk2,Tulos).
apuEro([],[L|Loput],Akk,Tulos) :- max(L,-L,Y), Akk2 is Akk + Y*Y, apuEro(Loput,[],Akk2,Tulos).
absE(A,B,Tulos) :- T is A - B, max(T,-T,Tulos).
max(A,B,B) :- B > A,!.
max(A,_,A).

tulostaListoja([Lista|Loput]) :- apuTulostaListoja(Lista), tulostaListoja(Loput).
tulostaListoja([]) :- print('\n').
apuTulostaListoja([Alk|Loput]) :- print(Alk),print('  '), apuTulostaListoja(Loput).
apuTulostaListoja([]) :- print('\n').