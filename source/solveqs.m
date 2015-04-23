% Script to test solving simultaneous ODE
close all
clear all
clc

import experiments.*

% State vector x = ( f,d,ba,v )

fare = 72/10e7;

contEnvForce = @CommonFnc.continuousEnvForce;
contRespFun = @CommonFnc.continuousRespFunction;
demand = @CommonFnc.demandFunction;
revenue = @CommonFnc.revenueRate;

v_f = @(t,v) contRespFun(   contEnvForce(t), ...
                            demand(v, fare), ...
                            v, ...
                            t);

d_f = @(v) demand(v, fare);

ba_f = @(v) revenue(demand(v, fare), fare);

fun = @(t,x) [  v_f(t,x(1)); ...
                d_f(x(1));...
                ba_f(x(1))];
     
tic
[t,x] = ode45(fun, [0,5], [80;0;-400]);
toc


plot(t,x(:,1))
figure
plot(t,x(:,2))
figure
plot(t,x(:,3))