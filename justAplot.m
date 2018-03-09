scatter(statarray.docnum,statarray.mean_disp, 25,statarray.fedstate, 'filled')
set(gca, 'xScale','log');
set(gca, 'yScale','log');
xlabel('N; # of HCPs')
ylabel('<D>; Mean Displacements')
cmap = jet(20);
cmap = flipud(cmap(1:10,:));
colormap(cmap);
colorbar