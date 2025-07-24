# transportation model containing mode-choice and traffic assignment
using CSV, DataFrames

function transportation_model(ta_data, mocomp, bikeincentive, mocperkgCO2, ttsc, ttsb, ttsr)

    # # Update link travel times 
    # # Read the CSV file of the current link travel times into a DataFrame
    # dftt = CSV.read("traveltimes.csv", DataFrame)
    # # Store the current link travel times into arrays
    # link_travel_timec = dftt.link_travel_timec
    # link_travel_timeb = dftt.link_travel_timeb
    # link_travel_timer = dftt.link_travel_timer



    # compute shortest travel times for mode-choice >>> function shortest_traveltime(basenet, dist)
    #ttsc, ttsb, ttsr = shortest_traveltime(ta_data, link_travel_timec, link_travel_timeb, link_travel_timer)

    ### mode-choice
    mpdict, demandc, demandb, demandr = mode_choice(ta_data, totaldemand, dist, 0.147, 0.065, bikeincentive, mocperkgCO2, mocomp, ttsc, ttsb, ttsr) # bikeincentive -0.000035 (gerade testweise bei 0)
 
    cardem = sum(demandc)
    busdem = sum(demandb)
    bikedem = sum(demandr)

    # update the travel demand based on mode-choice
    ta_datac.travel_demand = demandc
    ta_datab.travel_demand = demandb
    ta_datar.travel_demand = demandr


    ### update the generalized link costs in network data
    # CAR
    for i in 1:ta_datac.number_of_links 
        ta_datac.toll[i] = ta_data.link_length[i] * carext * mocperkgCO2 * mocomp
    end

    # BUS
    for i in 1:ta_datab.number_of_links 
        ta_datab.toll[i] = ta_datab.link_length[i] * busext * mocperkgCO2 * mocomp
    end

    # CAR (current placeholder ext = 0)
    for i in 1:ta_datar.number_of_links 
        ta_datar.toll[i] = ta_datar.link_length[i] * bikeincentive * mocperkgCO2 * mocomp
    end

    ### FW
    # CAR: compute new link flows and link travel times
    link_flowc, link_travel_timec, objectivec =
    ta_frank_wolfe(ta_datac, method=:cfw, max_iter_no=50, step=:exact, log=:off, tol=1e-2)

    # BUS: compute new link flows and link travel times
    link_flowb, link_travel_timeb, objectiveb =
    ta_frank_wolfe(ta_datab, method=:cfw, max_iter_no=25, step=:exact, log=:off, tol=1e-1)

    # BIKE: compute new link flows and link travel times
    link_flowr, link_travel_timer, objectiver =
    ta_frank_wolfe(ta_datar, method=:cfw, max_iter_no=25, step=:exact, log=:off, tol=1e-1)

    # # Update link travel times
    # # Create a DataFrame
    # dftt = DataFrame(link_travel_timec = link_travel_timec,
    # link_travel_timeb = link_travel_timeb,
    # link_travel_timer = link_travel_timer)
    # # Write the DataFrame to a CSV file
    # CSV.write("traveltimes.csv", dftt)

    # dftt = DataFrame(link_travel_timec = link_travel_timecsq,
    # link_travel_timeb = link_travel_timebsq,
    # link_travel_timer = link_travel_timersq)
    # # Write the DataFrame to a CSV file
    # CSV.write("traveltimes.csv", dftt)

    ### COMPUTE RESULTS

    # take VOT out of result link travel times
    link_travel_timec = link_travel_timec ./ 30 
    link_travel_timeb = link_travel_timeb ./ 20
    link_travel_timer = link_travel_timer ./ 20


    total_tt_c = dot(link_flowc, link_travel_timec)
    total_tt_b = dot(link_flowb, link_travel_timeb)
    total_tt_r = dot(link_flowr, link_travel_timer)
    total_tt = total_tt_c + total_tt_b + total_tt_r

    flowscar = sum(link_flowc)
    flowsbus = sum(link_flowb)
    flowsbike = sum(link_flowr)

    totaldistcar = dot(link_flowc, ta_data.link_length)
    totaldistbus = dot(link_flowb, ta_data.link_length)
    totaldistrad = dot(link_flowr, ta_data.link_length)

    ### compute consumed mocos in TA above

    mocostotal, mocoscar, mocosbus, mocosbike = consumed_mocos(ta_data, link_flowc, link_flowb, link_flowr)

    totalemissions, caremissions, busemissions =
    emissions(carext, busext, ta_datac, link_flowc, link_flowb, link_flowr)

    # write the link flows to csv for plots
    dfflows = DataFrame(
        init_node = ta_data.init_node,
        term_node = ta_data.term_node,
        link_flowc = link_flowc,
        link_flowb = link_flowb,
        link_flowr = link_flowr
        )
    # Write the DataFrame to a CSV file
    CSV.write("flows.csv", dfflows)

    return(mocostotal, cardem, busdem, bikedem, mocoscar, mocosbus, mocosbike, flowscar, flowsbus, flowsbike, totalemissions, caremissions, busemissions, total_tt, total_tt_c, total_tt_b, total_tt_r, link_travel_timec, link_travel_timeb, link_travel_timer, totaldistcar, totaldistbus, totaldistrad)

end