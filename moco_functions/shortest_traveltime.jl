using TrafficAssignment

function shortest_traveltime(ta_data, link_travel_timec, link_travel_timeb, link_travel_timer)

    
    
    ### TRAVEL TIME
    # car
    ttsc = Inf*ones(ta_data.number_of_nodes, ta_data.number_of_nodes)
    graphc = TrafficAssignment.create_graph(ta_datac.init_node, ta_datac.term_node)
    for r=1:ta_data.number_of_nodes
        state = TrafficAssignment.TA_dijkstra_shortest_paths(graphc, link_travel_timec, r, ta_datac.init_node, ta_datac.term_node)
        ttsc[r, :] = state.dists'
    end

    # Get the size of the matrix
    n, m = size(ttsc)
    # Iterate over the indices of the matrix
    for i in 1:n
        for j in 1:m
            if isinf(ttsc[i, j])
                # Check if the transposed value exists within the bounds of the matrix
                if j <= n && i <= m
                    # Replace the 'Inf' value with the transposed value
                    ttsc[i, j] = 1000
                end
            end
        end
    end

    # bus
    ttsb = Inf*ones(ta_data.number_of_nodes, ta_data.number_of_nodes)
    graphb = TrafficAssignment.create_graph(ta_datab.init_node, ta_datab.term_node)
    for r=1:ta_data.number_of_nodes
        state = TrafficAssignment.TA_dijkstra_shortest_paths(graphb, link_travel_timeb, r, ta_datab.init_node, ta_datab.term_node)
        ttsb[r, :] = state.dists'
    end

    # Iterate over the indices of the matrix
    for i in 1:n
        for j in 1:m
            if isinf(ttsb[i, j])
                # Check if the transposed value exists within the bounds of the matrix
                if j <= n && i <= m
                    # Replace the 'Inf' value with the transposed value
                    ttsb[i, j] = 1000
                end
            end
        end
    end

    # rad
    ttsr = Inf*ones(ta_data.number_of_nodes, ta_data.number_of_nodes)
    graphr = TrafficAssignment.create_graph(ta_datar.init_node, ta_datar.term_node)
    for r=1:ta_data.number_of_nodes
        state = TrafficAssignment.TA_dijkstra_shortest_paths(graphr, link_travel_timer, r, ta_datar.init_node, ta_datar.term_node) 
        ttsr[r, :] = state.dists'
    end

    for i in 1:n
        for j in 1:m
            if isinf(ttsr[i, j])
                # Check if the transposed value exists within the bounds of the matrix
                if j <= n && i <= m
                    # Replace the 'Inf' value with the transposed value
                    ttsr[i, j] = 1000
                end
            end
        end
    end

    # ttsm = Dict()
    # for (i,j,m) in arcs
    #     if m == 1
    #         merge!(ttsm,Dict((i,j,m)=> ttsc[i,j]))
    #     end
    #     if m == 2
    #         merge!(ttsm,Dict((i,j,m)=> ttsb[i,j]))
    #     end
    #     if m == 3
    #         merge!(ttsm,Dict((i,j,m)=> ttsr[i,j]))
    #     end
    # end

    #ttsm = ttsm[1]
    
    return (ttsc, ttsb, ttsr)
end