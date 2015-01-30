function front=paretoGroup(X)

% PARETOGROUP  To get the Pareto Front from a given set of points.
% synopsis:           front =paretoGroup (objectiveMatrix)
% where:
%   objectiveMatrix: [number of points X number of objectives] array
%   front:           [number of points X 1] logical vector to indicate if ith
%                    point belongs to the Pareto Front (true) or not (false).
%
% by Yi Cao, Cranfield University, 31 June 2007
% 
% Identify the Pareto Front from a set of points in objective space is the 
% most important and also the most time-consuming task in multi-objective 
% optimization. This code splits the given objective set into several 
% smaller groups to be examined by the efficient paretofront algorithm. 
% Then, the Pareto Fronts of each group are combined as one set to be 
% checked by the paretofront algorithm to determine the overall Pareto
% Front. In this way, the overal computation time can be reduced about
% half.
%
% Example:
% X = rand(1000000,4);
% t0 = cputime;
% Y1=paretoGroup(X); %mex implementation without sorting.
% t1=cputime - t0;
% t0 = cputime;
% Y2=paretofront(X);
% t2=cputime - t0;
% isequal(Y1,Y2)    %shoudl be 1
% disp([t1 t2])     
% Computation time based on Intel(R) Core(TM)2 CPU T2500 @ 2.0GHz, 2.0 GB of RAM
% 0.6844    1.4404
%

[m,n]=size(X);
groupcut=floor(2^13/n);
gRoup=max(1,ceil(m/groupcut));
front=false(m,1);
for k=1:gRoup
    z0=(k-1)*groupcut;
    z=(z0+1):min(z0+groupcut,m);
    front(z)=paretofront(X(z,:));
end
if gRoup>1
    front(front)=paretofront(X(front,:));
end

%{

LICENCE:

Copyright (c) 2009, Yi Cao
All rights reserved.

Redistribution and use in source and binary forms, with or without
modification, are permitted provided that the following conditions are
met:

    * Redistributions of source code must retain the above copyright
      notice, this list of conditions and the following disclaimer.
    * Redistributions in binary form must reproduce the above copyright
      notice, this list of conditions and the following disclaimer in
      the documentation and/or other materials provided with the distribution

THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE
ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT OWNER OR CONTRIBUTORS BE
LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR
CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF
SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS
INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN
CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE)
ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE
POSSIBILITY OF SUCH DAMAGE.

%}