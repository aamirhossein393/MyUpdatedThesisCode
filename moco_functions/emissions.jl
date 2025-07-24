# emissions

function emissions(carext, busext, ta_datac_mi, link_flowc_mi, link_flowb_mi, link_flowr_mi)

    modes = [1,2,3]

    caremissions = 0
    busemissions = 0
    bikeemissions = 0

    for i = 1:n, m in modes
        if m == 1
            caremissions += ta_datac.link_length[i] * carext * link_flowc_mi[i]
        elseif m == 2
            busemissions += ta_datab.link_length[i] * busext * link_flowb_mi[i]
        end
    end

    totalemissions = caremissions + busemissions

    return(totalemissions, caremissions, busemissions)
end