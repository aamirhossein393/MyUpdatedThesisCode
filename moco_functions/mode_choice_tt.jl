function mode_choice(ta_data, totaldemand, dist, carext, busext, bikeincentive, mocperkgCO2, mocomp, ttsc, ttsb, ttsr)

### MODE CHOICE

 

    # mode-choice parameter
    # internal travel costs per mode
    carcostspkm = 0.55 # [euro per pkm] -- source ADAC average car (VW Golf)
    pttripcosts = 1.24 # [euro] 50 euro germany ticket divided by 20 working days times two trips per day (commuting)


    # low income
    # ┌──────────────┬──────────┬───────────┬───────────┐
    # │              │     Coef │ Std. Err. │    Z-stat │
    # ├──────────────┼──────────┼───────────┼───────────┤
    # │ βtravel_time │ -2.75122 │   0.24638 │ -11.16646 │
    # │        βcost │ -4.64978 │   1.06749 │  -4.35581 │ -> the higher the cost, the higher the disutility
    # │        βdist │  1.20162 │   0.44904 │   2.67597 │
    # │    βmocoloss │ -0.55587 │   0.44949 │  -1.23666 │
    # │         αcar │ -0.05517 │   0.05216 │  -1.05780 │
    # │         αrad │  0.37835 │   0.05265 │   7.18671 │
    # │    βmocogain │ 63.35069 │  10.21436 │   6.20212 │  -> the higher the incentive, the lower the bike disutility
    # │        αwalk │ -0.41500 │   0.08651 │  -4.79700 │
    # │          αpt │  0.00000 │       NaN │       NaN │
    # └──────────────┴──────────┴───────────┴───────────┘

    # βtravel_time = -2.75122
    # βcost        = -4.64978
    # βdist        = 1.20162
    # βmocoloss    = -0.55587

    # αcar         = 0.051517     # -0.05517 (out of SP survey & biogeme)
    # αrad         = -1.17835      # 0.37835 (out of SP survey & biogeme)

    # βmocogain    = 63.35069
    # # αwalk = -0.41500
    # αpt          = 0.00000

    # new try αcar = 0
    # ┌──────────────┬──────────┬───────────┬───────────┐
    # │              │     Coef │ Std. Err. │    Z-stat │
    # ├──────────────┼──────────┼───────────┼───────────┤
    # │          αpt │  0.05517 │   0.05216 │   1.05780 │
    # │ βtravel_time │ -2.75122 │   0.24638 │ -11.16646 │
    # │        βcost │ -4.64978 │   1.06749 │  -4.35581 │
    # │        βdist │  1.20162 │   0.44904 │   2.67597 │
    # │    βmocoloss │ -0.55587 │   0.44949 │  -1.23666 │
    # │         αrad │  0.43352 │   0.06025 │   7.19505 │
    # │    βmocogain │ 63.35069 │  10.21436 │   6.20212 │
    # │        αwalk │ -0.35983 │   0.09459 │  -3.80404 │
    # │         αcar │  0.00000 │       NaN │       NaN │
    # └──────────────┴──────────┴───────────┴───────────┘

    βtravel_time = -2.75122
    βcost        = -4.64978
    βdist        = 1.20162
    βmocoloss    = 0.55587 # negative! (TRB reminder)

    αpt          = 0.23517     # 0.05517 (out of SP survey & biogeme)
    αrad         = -0.65852      # best: -1.53352  // 0.37835 (out of SP survey & biogeme)

    βmocogain    = 63.35069
    # αwalk = -0.41500
    αcar = 0.000
   


    ### compute total demand of modes
    #totaldemand = ta_datac.travel_demand + ta_datab.travel_demand + ta_datar.travel_demand


    ### compute moco charges including market price
    # initialize moco charge matrix
    mococar = fill(0.0, ta_data.number_of_nodes, ta_data.number_of_nodes)
    mocobus = fill(0.0, ta_data.number_of_nodes, ta_data.number_of_nodes)
    mocobike = fill(0.0, ta_data.number_of_nodes, ta_data.number_of_nodes) 

    # compute moco charges based on distance, externalities, coin ext value, and market price
    # car 
    for i in 1:ta_data.number_of_nodes, j in 1:ta_data.number_of_nodes
        mococar[i,j] = dist[i,j] * carext * mocperkgCO2 * mocomp
    end

    # bus
    for i in 1:ta_data.number_of_nodes, j in 1:ta_data.number_of_nodes
        mocobus[i,j] = dist[i,j] * busext * mocperkgCO2 * mocomp
    end

    # bike
    for i in 1:ta_data.number_of_nodes, j in 1:ta_data.number_of_nodes
        mocobike[i,j] = dist[i,j] * bikeincentive * mocomp
    end

    # update the MoCo link charges dict
    modes = [1,2,3]
    mpdict = Dict()
    # z = ta_data.number_of_zones
    for i = 1:n, m in modes
        if m == 1
            price = mococar[ta_data.init_node[i], ta_data.term_node[i]]
            merge!(mpdict,Dict((ta_data.init_node[i], ta_data.term_node[i], m) => price))
        elseif m == 2
            price = mocobus[ta_data.init_node[i], ta_data.term_node[i]]
            merge!(mpdict,Dict((ta_data.init_node[i], ta_data.term_node[i], m) => price))
        elseif m == 3 # incentive
            price = mocobike[ta_data.init_node[i], ta_data.term_node[i]]
            merge!(mpdict,Dict((ta_data.init_node[i], ta_data.term_node[i], m) => price))
        end
    end

    ### compute car travel costs based on costs per pkm and distance
    # initialize moco charge matrix
    carcosts = fill(0.0, ta_data.number_of_nodes, ta_data.number_of_nodes)
    
    # compute moco charges based on distance, externalities, coin ext value, and market price
    # car 
    for i in 1:ta_data.number_of_nodes, j in 1:ta_data.number_of_nodes
        carcosts[i,j] = dist[i,j] * carcostspkm
    end

    

    
    ### compute the mode utilities per user group and per mode
    # entire data set
    
    ucar = Array{Float64}(undef, ta_data.number_of_nodes, ta_data.number_of_nodes)
    for i in 1:ta_data.number_of_nodes, j in 1:ta_data.number_of_nodes
        ucar[i, j] = αcar    + βtravel_time * ttsc[i,j] / 100       +  βcost * carcosts[i,j]  / 100     + βdist * dist[i,j] / 100    - βmocoloss * mococar[i,j] / 100
    end

    ubus = Array{Float64}(undef, ta_data.number_of_nodes, ta_data.number_of_nodes)
    for i in 1:ta_data.number_of_nodes, j in 1:ta_data.number_of_nodes
        ubus[i, j] = αpt     + βtravel_time * ttsb[i,j] / 100    +  βcost * pttripcosts / 100    + βdist * dist[i,j] / 100    - βmocoloss * mocobus[i,j] / 100
    end

    ubike = Array{Float64}(undef, ta_data.number_of_nodes, ta_data.number_of_nodes)
    for i in 1:ta_data.number_of_nodes, j in 1:ta_data.number_of_nodes
        ubike[i, j] =  αrad    + βtravel_time * ttsr[i,j] / 100                                   - βdist * dist[i,j] / 100    - βmocogain * mocobike[i,j] / 100 # algebraic sign before moco incentive changed from '+' to '-' since values in SP survey are positive and in julia model negative
    end



    # Calculate mode probabilities

    # # - CAR - #
    probcar = Array{Float64}(undef, nnodes, nnodes)

    for i in 1:nnodes, j in 1:nnodes
        if i == j 
            probcar[i,j] = 0.0
        else
            probcar[i,j] = 
            ( exp(ucar[i,j]) / 
            ( exp(ucar[i,j]) + exp(ubike[i,j]) + exp(ubus[i,j]) )
            )
        end
    end

    # # - BIKE - #
    probbike = Array{Float64}(undef, nnodes, nnodes)

    for i in 1:nnodes, j in 1:nnodes
        if i == j
            probbike[i,j] = 0.0
        else
            probbike[i,j] = 
            ( exp(ubike[i,j]) / 
            ( exp(ucar[i,j]) + exp(ubike[i,j]) + exp(ubus[i,j]) )
            )
        end
    end

    # # - BUS - #
    probbus = Array{Float64}(undef, nnodes, nnodes)

    for i in 1:nnodes, j in 1:nnodes
        if i == j
            probbus[i,j] = 0.0
        else
            probbus[i,j] = 
            ( exp(ubus[i,j]) / 
            ( exp(ucar[i,j]) + exp(ubike[i,j]) + exp(ubus[i,j]) )
            )
        end
    end


    totalprobcar = Any[]
    totalprobbus = Any[]
    totalprobbike = Any[]
    
    totalprob_li = probcar + probbus + probbike

    # Result: Probabilities for each mode  

    # CHECK IF SUM(DEMANDS) = 100%

    # Calculate the mode demands (od matrices)
    demandc = zeros(Float64, nzones, nzones)
    for i in 1:size(ta_datac.travel_demand, 1),j in 1:size(ta_datac.travel_demand, 2)
        demandc[i,j] = totaldemand[i,j] * probcar[i,j]
    end

    # OD BUS
    demandb = zeros(Float64, nzones, nzones)
    for i in 1:size(ta_datab.travel_demand, 1),j in 1:size(ta_datab.travel_demand, 2)
        demandb[i,j] = totaldemand[i,j] * probbus[i,j]
    end

    # OD BIKE
    demandr = zeros(Float64, nzones, nzones)
    for i in 1:size(ta_datar.travel_demand, 1),j in 1:size(ta_datar.travel_demand, 2)
        demandr[i,j] =  totaldemand[i,j] * probbike[i,j]
    end

    totaldemandaftermc = demandc + demandb + demandr


    # println("sq car demand li = ", sqcardemand_li)
    # println("sq bus demand li = ", sqbusdemand_li)
    # println("sq bike demand li = ", sqraddemand_li)
    # println("sq total li demand = ", sqcardemand_li)

    # println("mc car demand li = ", demandc)
    # println("mc bus demand li = ", demandb)
    # println("mc bike demand li = ", demandr)
    # println("mc total li demand = ", totaldemandaftermc)
    


    return (mpdict, demandc, demandb, demandr, totaldemandaftermc, ucar, ubus, ubike)

end