using TrafficAssignment

function shortest_path(ta_data)
    dist = 1000*ones(ta_data.number_of_nodes, ta_data.number_of_nodes)
    graph = TrafficAssignment.create_graph(ta_data.init_node, ta_data.term_node)
    for r=1:ta_data.number_of_nodes
        state = TrafficAssignment.TA_dijkstra_shortest_paths(graph, ta_data.link_length, r, ta_data.init_node, ta_data.term_node) # , ta_data.first_thru_node
        dist[r, :] = state.dists'
    end
    # result: shortest paths distances matrix

    # Get the size of the matrix
    n, m = size(dist)

    # Iterate over the indices of the matrix
    for i in 1:n
        for j in 1:m
            if isinf(dist[i, j])
                # Check if the transposed value exists within the bounds of the matrix
                if j <= n && i <= m
                    # Replace the 'Inf' value with the transposed value
                    dist[i, j] = 1000
                end
            end
        end
    end



    # # add the mode (i,j,m)
    # distm = Dict()
    # for (i,j,m) in arcs
    #     merge!(distm,Dict((i,j,m)=> dist[i,j]))
    # end
    return (dist)
end