function load_network(ta_data, ta_datac, ta_datab, ta_datar)

    # - - #
    # Retrieve some indicators and parameters of the selected model
    od_pair = ta_data.od_pairs
    nodes  = 1:ta_data.number_of_nodes # -> is returned
    nnodes = size(nodes,1); # -> is returned
    zones = 1:ta_data.number_of_zones # -> is returned
    nzones = ta_data.number_of_zones # -> is returned
    n      = ta_data.number_of_links # -> is returned
    modes   = [1, 2, 3] # 1=car; 2=bus; 3=rad

    # - - #
    # Generate sets (tuples) that store the structural infomration of the model
    # List the arcs in the network
    arcs = Array{Tuple{Int64,Int64,Int64}}(undef,0) # -> is returned
    for i = 1:n, m in modes
        if ta_data.init_node[i] in nodes && ta_data.term_node[i] in nodes
            push!(arcs,(ta_data.init_node[i], ta_data.term_node[i], m))
        end
    end

    # Travel demand car: Make it a full matrix if it is not provided from the data
    demandc = zeros(Float64, ta_datac.number_of_nodes, ta_datac.number_of_nodes) # -> is returned
    for i in 1:size(ta_datac.travel_demand, 1),j in 1:size(ta_datac.travel_demand, 2)
            demandc[i,j] = ta_datac.travel_demand[i,j]
    end

    # Travel demand bus: Make it a full matrix if it is not provided from the data
    demandb = zeros(Float64, ta_datab.number_of_nodes, ta_datab.number_of_nodes) # -> is returned
    for i in 1:size(ta_datab.travel_demand, 1),j in 1:size(ta_datab.travel_demand, 2)
            demandb[i,j] = ta_datab.travel_demand[i,j]
    end

    # Travel demand rad: Make it a full matrix if it is not provided from the data
    demandr = zeros(Float64, ta_datar.number_of_nodes, ta_datar.number_of_nodes) # -> is returned
    for i in 1:size(ta_datar.travel_demand, 1),j in 1:size(ta_datar.travel_demand, 2)
            demandr[i,j] = ta_datar.travel_demand[i,j]
    end

    totaldemand = demandc + demandb + demandr # -> is returned

    # A set of active destinations
    destinations = Array{Int64}(undef,0) # -> is returned
    for i in nodes, j in nodes
        if demandc[i, j] > 0
            push!(destinations,j)
        end
    end
    for i in nodes, j in nodes
        if demandr[i, j] > 0
            push!(destinations,j)
        end
    end
    for i in nodes, j in nodes
        if demandb[i, j] > 0
            push!(destinations,j)
        end
    end
    unique!(destinations)

    # A set of arcs with destination k
    arcdest = Array{Tuple{Int64,Int64,Int64,Int64}}(undef, 0) # -> is returned
    for i = 1:n, k in destinations, m in modes
        if ta_data.init_node[i] in nodes && ta_data.term_node[i] in nodes && ta_data.init_node[i] != k
                push!(arcdest, (ta_data.init_node[i], ta_data.term_node[i], k, m))
        end
    end

    # Store the demand in a dict for lookup via sets
    demand_dict     = Dict() # -> is returned
    for i in nodes, j in nodes, m in modes
        if m == 1
            merge!(demand_dict,Dict((i,j,m)=>demandc[i,j]))
        elseif m == 2
            merge!(demand_dict,Dict((i,j,m)=>demandb[i,j]))
        elseif m == 3
            merge!(demand_dict,Dict((i,j,m)=>demandr[i,j]))
        end
    end

    # A set that informs on whether a connection is an od pair or not
    isod = Array{Tuple{Int64,Int64,Int64}}(undef, 0) # -> is returned
    for i in nodes, j in destinations, m in modes
        if (i,j,m) in keys(demand_dict)
            push!(isod, (i, j, m))
        end
    end


    # Create a dictionary for the BPR function
    bpr = Dict() # -> is returned
    # car
    for i in 1:ta_datac.number_of_links
        if ta_datac.init_node[i] in nodes && ta_datac.term_node[i] in nodes
            merge!(bpr,Dict((ta_datac.init_node[i], ta_datac.term_node[i], 1) => 
                        [ta_datac.free_flow_time[i],                                                    # 1 = fftt
                        ta_datac.b[i],                                                                  # 2 = b
                        ta_datac.capacity[i],                                                           # 3 = capacity
                        ta_datac.power[i]]))                                                            # 4 = power
        end
    end

    # bus
    for i in 1:ta_datab.number_of_links
        if ta_datab.init_node[i] in nodes && ta_datab.term_node[i] in nodes
            merge!(bpr,Dict((ta_datab.init_node[i], ta_datab.term_node[i], 2) => 
                        [ta_datab.free_flow_time[i],                                                    # 1 = fftt
                        ta_datab.b[i],                                                                  # 2 = b
                        ta_datab.capacity[i],                                                           # 3 = capacity
                        1]))                                                                            # 4 = power # ta_datab.power[i]
        end
    end

    # bike
    for i in 1:ta_datar.number_of_links
        if ta_datar.init_node[i] in nodes && ta_datar.term_node[i] in nodes
            merge!(bpr,Dict((ta_datar.init_node[i], ta_datar.term_node[i], 3) => [ta_datar.free_flow_time[i], # 1 = fftt
                        ta_datar.b[i],                                                                   # 2 = b
                        ta_datar.capacity[i],                                                            # 3 = capacity
                        1]))                                                             # 4 = power # ta_datar.power[i]
        end
    end
    return (nodes, nnodes, zones, nzones, n, arcs, demandc, demandb, demandr, totaldemand, destinations, arcdest, demand_dict, isod, bpr)  
end

