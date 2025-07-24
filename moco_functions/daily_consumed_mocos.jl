# calculate consumed mocos in last ta_data

function consumed_mocos(ta_data, link_flowc, link_flowb, link_flowr)

    modes = [1,2,3]

    mocoscar = 0
    mocosbus = 0
    mocosbike = 0

    for i = 1:n, m in modes
        if m == 1
            mocoscar += mpdictwomp[ta_data.init_node[i], ta_data.term_node[i], m] * link_flowc[i]
        elseif m == 2
            mocosbus += mpdictwomp[ta_data.init_node[i], ta_data.term_node[i], m] * link_flowb[i]
        elseif m == 3 # incentive
            mocosbike += mpdictwomp[ta_data.init_node[i], ta_data.term_node[i], m] * link_flowr[i]
        end
    end

    mocostotal = mocoscar + mocosbus + mocosbike

    return(mocostotal, mocoscar, mocosbus, mocosbike)
end