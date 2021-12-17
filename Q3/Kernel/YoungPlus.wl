(* -*- mode:math -*- *)

(* N.B.: This package contains some symbols from Bernd Buenther's
   IrrCharSymGrp.m v2.0 (posted on the Wolfram Community).  *)

Get["Q3`"]

BeginPackage["Q3`"]

`QuissoPlus`$Version = StringJoin[
  $Input, " v",
  StringSplit["$Revision: 1.5 $"][[2]], " (",
  StringSplit["$Date: 2021-12-05 11:05:24+09 $"][[2]], ") ",
  "Mahn-Soo Choi"
 ];

ClearAll @@ Evaluate @ Unprotect[
  CoxeterTest, NTranspDecomp, ExpandNTrDecom,
  YoungsNaturalReprValue, YoungsNaturalRepresentation,
  YoungsSeminormalReprValue, YoungsSeminormalRepresentation,
  Seminormal2Natural,
  InvariantYMetric,
  YnrCharacterTest,
  NormSquareOfTableau, WeakLeftBruhatGraph ];


NTranspDecomp::usage="NTranspDecomp[pi_?PermutationListQ] represents pi as product of transpositions of immediate neighbors. An entry value of k in the returned list denotes the transposition (k,k+1).\[IndentingNewLine]Attention: Permutations are multiplied right to left like right operators, not like functions!"


ExpandNTrDecom::usage="ExpandNTrDecom[ntr_List] is the inverse operation of NTranspDecomp."


InvariantYMetric::usage="InvariantYMetric[\[Lambda]_?YoungShapeQ] is the scalar product invariant under Young's natural presentation corresponding to the integer partition \[Lambda]."


CoxeterTest::usage="CoxeterTest[ynr_] applied to the matrices of Young's natural representation checks whether these matrices satisfy Coxeter's relations, as they must. So unless you tamper with the definitions this function should always return TRUE."


YnrCharacterTest::usage="YnrCharacterTest[ynr_,\[Lambda]_] applied to the matrices of Young's natural representation corresponding to the integer partition \[Lambda] computes the character and compares it to the relevant entry in the character table. So unless you tamper with the definitions this function should always return TRUE. A complete test would be for instance: \[IndentingNewLine]testPartition=RandomPartition[5];\[IndentingNewLine]testYnr=YoungsNaturalRepresentation[testPartition];\[IndentingNewLine]CoxeterTest[testYnr]&&YnrCharacterTest[testYnr,testPartition]"


WeakLeftBruhatGraph::usage="WeakLeftBruhatGraph[\[Lambda]_?YoungShapeQ] Construct weak left Bruhat graph of standard tableaux.
Start with rowwise ordered tableau (observe that it is smallest with respect to weak left Bruhat ordering) and then do breadth first algorithm.
Output is a record with two components; first is the list of stanard tableaux.
Second is the list of weighted edges, where weight i means that the transposition (i,i+1) the first connected tableau to the second. The edges are given as three component record with the first two components denoting the indices of the connected tableaux and the third record the weight."


Seminormal2Natural::usage="Seminormal2natural[\[Lambda]_?YoungShapeQ] The transformation matrix turning the seminormal presentation into the natural presentation. Each row vector is the expansion of a natural basis vector in terms of the seminormal basis vectors."


NormSquareOfTableau::usage="NormSquareOfTableau[myTableau_] computes the norm squares of the seminormal basis vectors."


YoungsNaturalRepresentation::usage="YoungsNaturalRepresentation[\[Lambda]_?YoungShapeQ] computes the matrices of Young's natural representation of the symmetric group corresponding to the integer partition \[Lambda] by transforming the seminormal representation. The function returns the images of the transpositions of immediate neighbors, listed in order of the transposed elements. The matrices are supposed to operate from the right on row vectors."


YoungsSeminormalRepresentation::usage="YoungsSeminormalRepresentation[\[Lambda]_?YoungShapeQ] computes the matrices of Young's seminormal representation of the symmetric group corresponding to the integer partition \[Lambda]. The function returns the images of the transpositions of immediate neighbors, listed in order of the transposed elements. The matrices are supposed to operate from the right on row vectors."


YoungsNaturalReprValue::usage="YoungsNaturalReprValue[\[Lambda]_?YoungShapeQ,pi_?PermutationListQ] is the matrix assigned to permutation \[Pi] by Young's natural representation corresponding to partition \[Lambda]."


YoungsSeminormalReprValue::usage="YoungsSeminormalReprValue[\[Lambda]_?YoungShapeQ,pi_?PermutationListQ] is the matrix assigned to permutation \[Pi] by Young's seminormal representation corresponding to partition \[Lambda]."


Begin["`Private`"]

NTranspDecomp[pi_?PermutationListQ]:=
Module[{idx=1,transList={},pi2=pi},While[idx<Length[pi2],
If[pi2[[idx]]<pi2[[idx+1]],idx++,
transList=Append[transList,idx];
pi2=System`Permute[pi2,System`Cycles[{{idx,idx+1}}]];
If[idx>1,idx--,idx++]]];transList];


ExpandNTrDecom[ntr_List]:=PermutationList[Apply[PermutationProduct,System`Cycles[{{#,#+1}}]&/@ntr]];


CoxeterTest[ynr_]:=And[Apply[And,(#.#==IdentityMatrix[Length[ynr[[1]]]])&/@ynr],
And@@Table[ynr[[r]].ynr[[r+1]].ynr[[r]]==ynr[[r+1]].ynr[[r]].ynr[[r+1]],{r,Length[ynr]-1}],
And@@Flatten[Table[ynr[[r]].ynr[[s]]==ynr[[s]].ynr[[r]],
{r,Length[ynr]-2},{s,r+2,Length[ynr]}]]];


Seminormal2Natural[\[Lambda]_?YoungShapeQ]:=youngAuxiliary[\[Lambda],1]/; Total[\[Lambda]]>1


YoungsNaturalRepresentation[\[Lambda]_?YoungShapeQ]:=youngAuxiliary[\[Lambda],2]/; Total[\[Lambda]]>1


YoungsSeminormalRepresentation[\[Lambda]_?YoungShapeQ]:=youngAuxiliary[\[Lambda],3]/; Total[\[Lambda]]>1


NormSquareOfTableau[myTableau_] := With[
  {trshape=YoungTranspose[Length/@myTableau]},
  Product[
    If[((i2>i1)\[Or](j2>j1))\[And](Part[myTableau,i1,j1]>Part[myTableau,i2,j2]),
1-1/(i1-j1-i2+j2)^2,1],
  {j1,1,Length[trshape]},{i1,1,Part[trshape,j1]},
  {j2,j1,Length[trshape]},{i2,1,Part[trshape,j2]}]
 ]

YoungsNaturalReprValue[pp_?YoungShapeQ,pi_?PermutationListQ]:=If[pi==Range[Total[pp]],IdentityMatrix[CountYoungTableaux[pp]],Dot@@Extract[YoungsNaturalRepresentation[pp],Partition[NTranspDecomp[pi],1]]]/;Total[pp]==Length[pi];


YoungsSeminormalReprValue[pp_?YoungShapeQ,pi_?PermutationListQ] := If[
  pi==Range[Total[pp]],
  IdentityMatrix[CountYoungTableaux[pp]],
  Dot @@ Extract[
    YoungsSeminormalRepresentation[pp],
    Partition[NTranspDecomp[pi], 1]
   ]
 ] /; Total[pp]==Length[pi];


cTypeRepresentative[\[Lambda]_?YoungShapeQ]:=
Flatten[Apply[Range,Transpose[{Prepend[Drop[#,-1]+1,1],#-1}],{1}]]&[Accumulate[\[Lambda]]];


YnrCharacterTest[ynr_,\[Lambda]_]:=(
  Append[
    Tr /@ Apply[
      Dot,
      Extract[ynr,#]& /@ Partition[#,1]& /@ cTypeRepresentative /@
        Drop[IntegerPartitions[Total[\[Lambda]]],-1], {1}
     ],
    Length[ynr[[1]]]
   ] == Part[
     SymmetricGroupCharacters @ Total[\[Lambda]],
     Part[Position[IntegerPartitions[Total[\[Lambda]]],\[Lambda]], 1, 1]
    ]
 );


InvariantYMetric[\[Lambda]_?YoungShapeQ]:=
With[{wlbg1=WeakLeftBruhatGraph[\[Lambda]],
transform=Seminormal2Natural[\[Lambda]]},
Times@@Factorial/@YoungTranspose[\[Lambda]]transform.DiagonalMatrix[NormSquareOfTableau/@First/@wlbg1].Transpose[transform]];


predPermutations1[invPList_,curPos_,sourcePos_]:=MapIndexed[{System`Permute[invPList,First[#1]],{curPos,sourcePos,Last[#1]}}&,{System`Cycles[{{#,#+1}}],#}&/@Flatten[Position[Differences[invPList],x_/;x<0]]];


predPermutations2[invPListList_,curPos_,sourcePos_]:=
MapIndexed[{First[Part[#1,1]],Function[x,ReplacePart[x,1->Part[x,1]+First[#2]]]/@Part[#1,2]}& ,
Transpose/@Gather[
Join@@MapIndexed[predPermutations1[#1,curPos,sourcePos+First[#2]]&,
First/@invPListList],
(Part[#1,1]==Part[#2,1])&]];


rowWiseInvPList[\[Lambda]_?YoungShapeQ]:=
PermutationList[System`InversePermutation[PermutationCycles[Join@@YoungTranspose[(Range@@#)&/@Drop[FoldList[{1+Last[#1],#2+Last[#1]}&,{0,0},\[Lambda]],1]]]],Total[\[Lambda]]];


WeakLeftBruhatGraph[\[Lambda]_?YoungShapeQ]:=
With[{x=rowWiseInvPList[\[Lambda]],n=Total[\[Lambda]],
shape=Drop[FoldList[{1+Last[#1],#2+Last[#1]}&,{0,0},YoungTranspose[\[Lambda]]],1]},
Function[v,{YoungTranspose[Function[w,Take[PermutationList[System`InversePermutation[PermutationCycles[Part[v,1]]],n],w]]/@shape],
Part[v,2]}]/@
Flatten[Nest[Append[#,predPermutations2[
Last[#],Length[Flatten[#,1]],Length[Flatten[#,1]]-Length[Last[#]]]]&,
{{{x,{}}}},permInversions[x]],1]];


youngAuxiliary[\[Lambda]_,modus_]:=
(* modus=1: only transform; modus=2: natural presentation; modus=3: seminormal presentation *)
With[{wlbg1=WeakLeftBruhatGraph[\[Lambda]]},
Module[{wlbgAdjacencyLists,contentVectors,spanningTree,transform,tnorm,tinv,semimatrix},
(* The following expression computes the adjacency lists of the weak left Bruhat graph;an entrySubscript[a, ij]may have four different meanings,depending on the following cases:i) IfSubscript[a, ij]=ithen j and j+1 are contained in the same row of tableau i.ii) IfSubscript[a, ij]=-ithen j and j+1 are contained in the same column of tableau i.iii) IfSubscript[a, ij]\[NotEqual]\[PlusMinus]ibutSubscript[a, ij]<0then i and i+1 appear inverted in tableau i and application of the admissible transposition (j,j+1) turns tableau i into tableauSubscript[a, ij],thus removing an inversion.iv) IfSubscript[a, ij]\[NotEqual]\[PlusMinus]ibutSubscript[a, ij]>0then i and i+1 appear in correct order in tableau i and application of the admissible transposition (j,j+1) turns tableau i into tableauSubscript[a, ij],thus adding an inversion. *)
wlbgAdjacencyLists=Normal[SparseArray[
(({Part[#,1],Part[#,3]}->Part[#,2])&/@ Flatten[Part[#,2]&/@wlbg1,1])
~Join~
(({Part[#,2],Part[#,3]}->-Part[#,1])&/@ Flatten[Part[#,2]&/@wlbg1,1])
~Join~
Flatten[MapIndexed[Function[{v,w},Function[u,{First[w],u}->First[w]]/@v],Function[v,Last/@Select[Transpose[{Flatten[Function[u,Append[u,0]]/@(Differences/@v)],Flatten[v]}],Function[u,First[u]==1]]]/@(First/@wlbg1)]]
~Join~
Flatten[MapIndexed[Function[{v,w},Function[u,{First[w],u}->-First[w]]/@v],Function[v,Last/@Select[Transpose[{Flatten[Function[u,Append[u,0]]/@(Differences/@v)],Flatten[v]}],Function[u,First[u]==1]]]/@(YoungTranspose[#]&/@(First/@wlbg1))]],{Length[wlbg1],Total[\[Lambda]]-1}]
];
contentVectors=Function[u,Normal[SparseArray[Flatten[MapIndexed[Function[{v1,v2},{v1->Last[v2]-First[v2]}],First[u],{2}]],{Total[\[Lambda]]}]]]/@wlbg1;
If[modus!=3,
	spanningTree=If[Length[wlbg1]==1,{},First/@MapIndexed[Drop[#1/.(Rule[{a_},b_]):>{First[#2],a,b},-1]&,ArrayRules/@SparseArray[Flatten[Function[v,Function[u,{Part[u,2],Part[u,1]}->Part[u,3]]/@Last[v]]/@Drop[wlbg1,1]],{Length[wlbg1]-1,Length[wlbg1]}]]];
	transform=SparseArray[{Length[wlbg1],Length[wlbg1]}->1,{Length[wlbg1],Length[wlbg1]}];
	Module[{k,r,s,x},For[i=Length[spanningTree],i>0,i--,
	(* e_i = s_r e_k is the base vector to be constructed. *)
	k=Part[spanningTree,i,2];
	r=Part[spanningTree,i,3];
	For[j=k,j<=Length[wlbg1],j++,
	(* v_j is a Young vector appearing in e_k with coefficient x. *)
	x=Part[transform,k,j];
	If[x==0,Continue[]];
	s=Part[wlbgAdjacencyLists,j,r];
	Switch[s,
	(* row inversion *) j,Part[transform,i,j]+=x,
	(* column inversion *) -j,Part[transform,i,j]-=x,
	(* removing an inversion *) x_/;x<0,Part[transform,i,j]+=x/(Part[contentVectors,j,r+1]-Part[contentVectors,j,r]);
	Part[transform,i,-s]+= x (1-1/(Part[contentVectors,j,r+1]-Part[contentVectors,j,r])^2),
	(* admissibly adding an inversion *)_,Part[transform,i,s]+=x;
	Part[transform,i,j]+=x/(Part[contentVectors,j,r+1]-Part[contentVectors,j,r]);
	]]]];
	tnorm=Normal[transform]];
If[modus==1,Return[tnorm]];
semimatrix=Normal[SparseArray[Flatten[Module[{s},Table[s=Part[wlbgAdjacencyLists,k,r];
Switch[s,
(* row inversion *) k,{{r,k,k}->1},
(* column inversion *) -k,{{r,k,k}->-1},
(* removing an inversion *) x_/;x<0,
{{r,k,k}->1/(Part[contentVectors,k,r+1]-Part[contentVectors,k,r]),
{r,k,-s}->1-1/(Part[contentVectors,k,r+1]-Part[contentVectors,k,r])^2},
(* admissibly adding an inversion *)_,
{{r,k,k}->1/(Part[contentVectors,k,r+1]-Part[contentVectors,k,r]),
{r,k,s}->1}],
{r,Total[\[Lambda]]-1},{k,Length[wlbg1]}]]],
{Total[\[Lambda]]-1,Length[wlbg1],Length[wlbg1]}]];
If[modus==3,Return[semimatrix]];
tinv=Inverse[tnorm];
tnorm.#.tinv&/@ semimatrix
]];


End[]

Q3Protect[];

EndPackage[]
