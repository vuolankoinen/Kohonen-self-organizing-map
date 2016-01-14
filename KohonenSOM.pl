% Kohosen itseorganisoituva kartta.
% Datapisteet koordinaattien listoina, syöte listana datapisteistä.
% Olettaa häntäpäästä puuttuvat koordinaatit nolliksi.

koedata(X) :- X = [[10,0],[10,0.2],[10,9.8],[5,2.5],[5,7.6],[1,4.5],[0,4.9],[0.1,4.96],[0.21,5.3],[6,7],[8.1,9],[9,0.7],[2,4],[8.9,0.8],[4,6.8],[10,10.1],[9.7,9.9]].
koedata1(X) :- X = [[1,2,3],[1,3,3],[1,12,12],[3,5,10],[4,23,13],[1,50,12],[54,130,250],[14,45,340],[10,20,123],[30,234,1221],[32,120,80],[20,30,20],[45,200,340],[102,230,200],[20,30,20]].
vektorit3d(X) :- X = [[1, 0, 0], [0, 1, 0], [0, 0, 1]].
arvoVektorit(Monta, Tulos) :- apuAV(Monta, [], Tulos).
apuAV(0, Tulos, Tulos).
apuAV(Mont, A, Tulos) :- random(S1), random(S2), random(S3), Sv = [S1,S2,S3],
	M is Mont - 1, apuAV(M, [Sv|A],Tulos).
arvoVektorit(Monta, Data, Tulos) :- keskiarvot(Data,KA), apuAV3(Monta, Monta, KA, [], Tulos).
apuAV3(0,_,_, Tulos, Tulos).
apuAV3(Mont, Yht, KA, A, Tulos) :- listasumma(KA,[(Yht - 2 * Mont)/Yht,Mont,Mont],Sv),
	M is Mont - 1, apuAV3(M, Yht, KA, [Sv|A], Tulos).
apuAV3(Mont, Yht, KA, A, Tulos) :- listasumma(KA,[(Yht - 2 * Mont)/Yht,Mont / Yht, - Yht / Mont],Sv),
		M is Mont - 1, apuAV3(M, Yht, KA, [Sv|A], Tulos).
%arvoVektorit(Monta, Data, Tulos) :- keskiarvot(Data,KA), apuAV2(Monta, KA, [], Tulos).
%apuAV2(0,_, Tulos, Tulos).
%apuAV2(Mont, KA, A, Tulos) :- random(S1), random(S2), random(S3), listasumma(KA,[S1,S2,S3],Sv),
%	M is Mont - 1, apuAV2(M, KA, [Sv|A],Tulos).

%1-d-version selittävät vektorit muodostavat ketjun, eli kullakin on vain kaksi naapuria (paitsi päillä vain yksi).
som1d :- vektorit3d(Alkuvektorit), koedata(Data), som1d(Data, Alkuvektorit).
som1d([H|T]) :- vektorit3d(Alkuvektorit), som1d([H|T], Alkuvektorit).
som1d(Vektoreita) :- integer(Vektoreita), koedata(Data), arvoVektorit(Vektoreita, Data, AlkVektorit),
	som1d(Data,AlkVektorit).
som1d(Data, Vektorit) :- iter1d(Data, Vektorit, Data).

iter1d(Edelliset, Seuraavat, _) :- kutakuinkin(Edelliset,Seuraavat),
	print('Tulos:\n'), tulostaListoja(Seuraavat),!.
iter1d(_,S,Data) :- laskeUudet1d(S,Data).

laskeUudet1d(Edelliset,Data) :- luokitteleLahimpienMukaan(Edelliset, Data, Luokat),
	paivitaKeskiarvot(Luokat, Uudet),
	iter1d(Edelliset, Uudet, Data).

luokitteleLahimpienMukaan(Edustajat, Data, Tulos) :-
	puhtaatListat(Edustajat,[],L), apuLuokittele(Edustajat, Data, L, Tulos).
apuLuokittele(Edust, [D|Loput], Akk, Tulos) :-
	lahinLuokka(D, Edust, 0, -2,-2, N), lisaaLuokkaanN(D,Akk,N,Akkseur),
	lisaaLuokkaanN(D,Akkseur,N-1,Akkseur2),lisaaLuokkaanN(D,Akkseur2,N+1,Akkseur3),
	apuLuokittele(Edust, Loput,Akkseur3,Tulos),!.
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
apuLisaa(_,L,N,A,Tulos) :- N < 0, append(A,L,Tulos).
apuLisaa(A, [L|Loput], 0, Akk, Tulos) :- append(L,[A],Llisatty), append(Akk, [Llisatty], Alku),
	append(Alku,Loput,Tulos),!.
apuLisaa(A, [L|Loput], N, Akk, Tulos) :- Nseur is N - 1, append(Akk, [L], Akkseur),
	apuLisaa(A, Loput, Nseur, Akkseur, Tulos).
apuLisaa(_,[],_,A,A).


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
apuListas([],[H1|Loput1],Akk,Summat) :- append(Akk, [H1], Aseur),
	apuListas(Loput1,[],Aseur,Summat).
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

help :- print('This prolog-program is an implementation of Kohonen\''),print('s self-organizing map.\n The command \'som1d.\' or \'som1d(*parameters*).\' applies the 1-dimensional SOM,'),print(' that is, SOM where the vectors to summarize the data form a chain, i.e. they each have'),print(' just one neighbour - except at the ends of the chain, where'),print(' they have one. Parameters may include\n -the data to apply'),print(' the SOM on, in form of co-ordinate lists describing the data points, these lists in turn collected to a '),print('list e.g [[1,3,4.2],[2,3,0],[0,0.2,0.8]]\n -the number of vectors to use in describing the data\n -list of initial vectors to use\nThe process is vilnerable to bad choise of initial vectors.').