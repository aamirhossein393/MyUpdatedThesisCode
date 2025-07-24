# compute moco link costs

function moco_link_costs_wo_mp(dist, carext, mocperkgCO2)

    mococar = fill(0.0, ta_data.number_of_nodes, ta_data.number_of_nodes)
    mocobus = fill(0.0, ta_data.number_of_nodes, ta_data.number_of_nodes)
    mocobike = fill(0.0, ta_data.number_of_nodes, ta_data.number_of_nodes) 

    # car 
    for i in 1:ta_data.number_of_nodes, j in 1:ta_data.number_of_nodes
        mococar[i,j] = dist[i,j] * carext * mocperkgCO2 #* mocomp
    end

    # bus
    for i in 1:ta_data.number_of_nodes, j in 1:ta_data.number_of_nodes
        mocobus[i,j] = dist[i,j] * busext * mocperkgCO2 #* mocomp
    end

    # bike
    for i in 1:ta_data.number_of_nodes, j in 1:ta_data.number_of_nodes
        mocobike[i,j] = dist[i,j] * bikeincentive #* mocomp
    end

    # update the MoCo link prices dict
    modes = [1,2,3]
    mpdictwomp = Dict()
    for i = 1:n, m in modes
        if m == 1
            price = mococar[ta_data.init_node[i], ta_data.term_node[i]]
            merge!(mpdictwomp,Dict((ta_data.init_node[i], ta_data.term_node[i], m) => price))
        elseif m == 2
            price = mocobus[ta_data.init_node[i], ta_data.term_node[i]]
            merge!(mpdictwomp,Dict((ta_data.init_node[i], ta_data.term_node[i], m) => price))
        elseif m == 3 # incentive
            price = mocobike[ta_data.init_node[i], ta_data.term_node[i]]
            merge!(mpdictwomp,Dict((ta_data.init_node[i], ta_data.term_node[i], m) => price))
        end
    end

    return(mpdictwomp)
end