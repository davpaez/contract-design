% Test for building dynamic histogram

close all

rlzArray = experim.gameEvals.realizations;

n_rlz = length(rlzArray);

maxTime = 0;
for i = 1:n_rlz
    st = rlzArray{i}.nature.infrastructure.history.getData();
    time{i} = st.time;
    perf{i} = st.value;
    len(i) = length(st.time);
    maxSpace(i) = max(diff(st.time));
    
    mt = st.time(end);
    if mt > maxTime
        maxTime = mt;
    end
end

numberSections = floor(maxTime/max(maxSpace)); % Minimum number of divisions

clear st mt i maxSpace

minPerf = inf;
interval = maxTime/numberSections;
for i=1:numberSections
    lb = (interval)*(i-1);
    ub = (interval)*i;
    
    T(i) = (lb + ub)/2;
    P{i} = [];
    
    % Mean value for each section of each realization path
    meanPerfVector = zeros(n_rlz,1);
    for j=1:n_rlz
        timeVector = time{j};
        perfVector = perf{j};
        
        idx = (timeVector>(lb) & timeVector<=ub);
        clipTime = timeVector(idx);
        clipPerf = perfVector(idx);
        realInterv = max(clipTime)-min(clipTime);
        if realInterv> 0
            meanPerf = trapz(timeVector(idx),perfVector(idx))/(max(timeVector(idx))-min(timeVector(idx)));
        else
            meanPerf = mean(perfVector(idx));
        end
        
        if meanPerf < minPerf
            minPerf = meanPerf;
        end
        
        meanPerfVector(j) = meanPerf;
        assert(~isnan(meanPerf))
    end
    P{i} = meanPerfVector;
end

perfRange = 100-minPerf;
nbins = 50;
perfInterval = perfRange/nbins;
edges = linspace(minPerf,100,nbins+1);

sz = numberSections*n_rlz;
t = zeros(sz,1);
p = zeros(sz,1);
cont = 1;
m = zeros(nbins, numberSections);
for i=1:numberSections
    for j=1:n_rlz
        t(cont) = T(i);
        p(cont) = P{i}(j);
        cont = cont + 1;
    end
    
    % 
    frec = histcounts(P{i}, edges);
    prel = ((frec)/n_rlz)';
    assert((sum(prel)-1)<eps*4);
    m(:,i) = prel;
end

figure
plot(t,p,'*')
xlabel('Time')
ylabel('Perf')

figure
imagesc([interval/2:interval:maxTime],[minPerf+perfInterval/2:perfInterval:100],m)
h = colorbar;
h.Label.String = 'Relative frequency';
set(gca,'YDir','normal')
xlabel('Time')
ylabel('Perf')
