clear
clc

loadmatfile('A.mat');
loadmatfile('B.mat');
loadmatfile('H.mat');
loadmatfile('C.mat');

m=rank(B);
n=size(A);
n=n(1,1);
qw=rank(H);
p=rank(C);


[Q,Sigmaw,R]=svd(H);
Sigma1=Sigmaw(1:qw,:);
Q1=Q(:,1:qw);
Q2=Q(:,qw+1:$);

Ab=Q'*A*Q;
Bb=Q'*B;
Ab11=Ab(1:qw,1:qw);
Ab12=Ab(1:qw,qw+1:$);
Ab21=Ab(qw+1:$,1:qw);
Ab22=Ab(qw+1:$,qw+1:$);
Bb1=Bb(1:qw,:);
Bb2=Bb(qw+1:$,:);
Cb=C*Q;
Cb1=Cb(:,1:qw);
Cb2=Cb(:,qw+1:$);
Cb1p=(Cb1'*Cb1)^-1*Cb1';
dum1=size(Cb1p);
dum2=dum1(1,2);
dum3=dum1(1,1);
dum4=dum2-dum3;
//if dum4 ~= 0
//    M=rand(dum4,dum2);
//    while rank([Cb1p;M]) ~= dum2;
        M=rand(dum4,dum2);
//    end
//    N=[Cb1p;M];
//else
//    N=[Cb1p];
//    M=eye(p,p);
//end
//loadmatfile('M.mat');
N=[Cb1p;M];

At2=Ab22-Ab21*Cb1p*Cb2;
Bt2=Bb2;
Gt2=Ab21*Cb1p;
Ct=M*(eye(p,p)-Cb1*Cb1p)*Cb2;
Ht=M*(eye(p,p)-Cb1*Cb1p);
dum5=size(Cb1p*Cb2);
dum6=dum5(1,2);
Qbx=Q*[Cb1p*Cb2;eye(dum6,dum6)];
dum7=size(Cb1p);
dum8=dum7(1,2);
dum9=size(Q);
dum10=dum9(1,2);
dum11=dum10-dum7(1,1);
Qby=Q*[-Cb1p;zeros(dum11,dum8)];
dum15=size(M);

function [LME,LMI,OBJ]=UIO(XLIST)
[N,J,L,P1,P2,P3,gama1]= XLIST(:)
LME=list(Cb1p*C*B-Cb1p*Cb2*J-Bb1,Cb1p*C*A-Cb1p*Cb2*L*Ht*C,P1-P1',P2-P2',P3-P3')
LMI=list(-([N'-Ct'*L'+N-L*Ct+P1,At2+Gt2*C*Q2-L*Ht*C*Q2+L*Ct-N,Gt2*C*Q1-L*Ht*C*Q1,Bb2-J,zeros(n-qw,1);At2'+Q2'*C'*Gt2'-Q2'*C'*Ht'*L'+Ct'*L'-N',P2,zeros(n-qw,qw+m+1);Q1'*C'*Gt2'-Q1'*C'*Ht'*L',zeros(qw,n-qw),P3,zeros(qw,m+1);Bb2'-J',zeros(m,n-qw+qw+m+1);zeros(1,n-qw+n-qw+qw+m),-gama1]),P1,gama1,1e-1-gama1)
OBJ=[]
endfunction

N_0=-eye(n-qw,n-qw);
J_0=zeros(n-qw,m);
L_0=zeros(n-qw,p-qw);
P1_0=eye(n-qw,n-qw);
P2_0=eye(n-qw,n-qw);
P3_0=eye(qw,qw);
gama1_0=1e8;

Init_guess=list(N_0,J_0,L_0,P1_0,P2_0,P3_0,gama1_0);

Mbound=1e2;
abstol=1e-6;
nu=1;
maxiters=500;
reltol=1e-6;

Ans_LMI=lmisolver(Init_guess,UIO,[Mbound,abstol,nu,maxiters,reltol]);
//Ans_LMI=lmisolver(Init_guess,UIO);

N=Ans_LMI(1);
J=Ans_LMI(2);
L=Ans_LMI(3);
P1=Ans_LMI(4);
P2=Ans_LMI(5);
P3=Ans_LMI(6);
gama1=Ans_LMI(7);

savematfile('N.mat','N');
savematfile('J.mat','J');
savematfile('L.mat','L');
savematfile('M.mat','M');
