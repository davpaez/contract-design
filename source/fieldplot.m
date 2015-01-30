clear al
close all
clc

nx = 50;
ny = 30;

xmin = 0;
xmax = 25;

ymin = 0;
ymax = 100;

[x,y] = meshgrid(linspace(xmin,xmax,nx), linspace(ymin,ymax,ny));

a = 1.3;
b = 1.3;
vi = 100;

dy = -a*b*((vi-y)./a).^((b-1)/b) - 0.01 - 0.6*x;
r = ( 1 + dy.^2 ).^0.5;

sc = 1.5;

py = sc * dy./r;
px = sc * 1./r;  

figure
h = quiver(x,y,px,py);
h.ShowArrowHead = 'off';
h.AutoScale = 'off';
h.AutoScaleFactor = 0;
xlim( [0, 25]);
ylim( [0, 100]);