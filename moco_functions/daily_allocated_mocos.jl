function calculate_daily_mocos_needed(ta_datac, ta_datab, ta_datar, dist, carext, busext, bikeincentive, mocperkgCO2, mocomp, link_flowc, link_flowb, link_flowr)

    # # Getting the start data
    # # car
    # link_flowc, link_travel_timec, objectivec =
    # ta_frank_wolfe(ta_datac, method=:cfw, max_iter_no=50000, step=:newton, log=:off, tol=1e-3)

    # # bus
    # link_flowb, link_travel_timeb, objectiveb =
    # ta_frank_wolfe(ta_datab, method=:cfw, max_iter_no=50000, step=:newton, log=:off, tol=1e-3)

    # # rad
    # link_flowr, link_travel_timer, objectiver =
    # ta_frank_wolfe(ta_datar, method=:cfw, max_iter_no=50000, step=:newton, log=:off, tol=1e-3)

    mococar = fill(0.0, ta_data.number_of_nodes, ta_data.number_of_nodes)
    mocobus = fill(0.0, ta_data.number_of_nodes, ta_data.number_of_nodes)
    mocobike = fill(0.0, ta_data.number_of_nodes, ta_data.number_of_nodes) 

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

    # update the MoCo link prices dict
    mpdictmc = Dict()
    modes = [1,2,3]
    for i = 1:n, m in modes
        if m == 1
            price = mococar[ta_datac.init_node[i], ta_datac.term_node[i]]
            merge!(mpdictmc,Dict((ta_datac.init_node[i], ta_datac.term_node[i], m) => price))
        elseif m == 2
            price = mocobus[ta_datab.init_node[i], ta_datab.term_node[i]]
            merge!(mpdictmc,Dict((ta_datab.init_node[i], ta_datab.term_node[i], m) => price))
        elseif m == 3 # incentive
            price = mocobike[ta_datar.init_node[i], ta_datar.term_node[i]]
            merge!(mpdictmc,Dict((ta_datar.init_node[i], ta_datar.term_node[i], m) => price))
        end
    end

    # Computing moco total costs for all users within the network -> makes the allocated coins
    totalcostsc = []
    for i = 1:n, m = 1
        costs = mpdictmc[(ta_data.init_node[i], ta_data.term_node[i],m)] * link_flowc[i]
        push!(totalcostsc, costs)
    end

    totalcostsb = []
    for i = 1:n, m = 2
        costs = mpdictmc[(ta_data.init_node[i], ta_data.term_node[i],m)] * link_flowb[i]
        push!(totalcostsb, costs)
    end

    totalcostsr = []
    for i = 1:n, m = 3
        costs = mpdictmc[(ta_data.init_node[i], ta_data.term_node[i],m)] * link_flowr[i]
        push!(totalcostsr, costs)
    end
    totalmococosts = sum(totalcostsc) + sum(totalcostsb) + sum(totalcostsr)
    totalcostsc = sum(totalcostsc)
    totalcostsb = sum(totalcostsb)
    totalcostsr = sum(totalcostsr)

    return(totalmococosts, totalcostsc, totalcostsb, totalcostsr)
end