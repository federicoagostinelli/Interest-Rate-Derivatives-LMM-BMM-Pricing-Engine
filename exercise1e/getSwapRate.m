function swapRate = getSwapRate(market, matYears, freq, basis)
    % GETSWAPRATE_GENERIC Calcola il tasso Par Swap con convenzioni personalizzabili.
    %
    % Input:
    %   market   : struct con le date e i discount factor
    %   matYears : scadenza dello swap in anni (es. 6 o 10)
    %   freq     : numero di pagamenti all'anno (1=Annuale, 2=Semestrale, 4=Trimestrale)
    %   basis    : convenzione daycount per yearfrac (es. 2 = Act/360, 6 = 30E/360)
    
    refDate   = market.dates(1);
    dates     = market.dates;
    discounts = market.discounts;
    
    getDF = @(d) getDiscountFactorByZeroRatesLinearInterp(...
                     refDate, d, dates, discounts);
                 
    % 1. Calcolo del numero totale di periodi e dei mesi per ogni periodo
    nPeriods = matYears * freq;
    monthsStep = 12 / freq; 
    
    couponDates = NaT(nPeriods, 1);
    
    for k = 1:nPeriods
        % Avanziamo dinamicamente in base alla frequenza
        couponDates(k) = refDate + calmonths(monthsStep * k);
    end
    
    allDates  = [refDate; couponDates];
    
    % 2. Calcolo delle frazioni d'anno usando la 'basis' passata in input
    taus      = yearfrac(allDates(1:end-1), allDates(2:end), basis);
    
    dfCoupons = arrayfun(getDF, couponDates);
    
    BPV      = sum(taus .* dfCoupons);
    df_TN    = dfCoupons(end);
    
    swapRate = (1 - df_TN) / BPV;
end